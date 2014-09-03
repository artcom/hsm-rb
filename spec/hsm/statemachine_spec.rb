require 'spec_helper'

module HSM
  class Recorder
    attr_accessor :events
    def initialize
      @events = []
    end
  end

  class CustomState < State
    attr_accessor :calls, :recorder

    def initialize(*args)
      super
      @calls = []
    end
  end

  class CustomSub < Sub
    attr_accessor :calls, :recorder

    def initialize(*args)
      super
      @calls = []
    end
  end

  describe StateMachine do

    it 'can be instantiated empty' do
      expect(subject).to be_a(StateMachine)
    end

    let(:recorder) { Recorder.new }

    let(:ss) {
      # Simple Statemachine with states :on and :off
      # :on  --toggle--> :off
      # :off --toggle--> :off
      StateMachine.new do |sm|
        sm.add_state(CustomState.new(:on) do |s|
          s.on_enter { |_data|
            s.calls << ':on on_enter'
            s.recorder.events << ':on on_enter' if s.recorder
          }
          s.on_exit { |_data|
            s.calls << ':on on_exit'
            s.recorder.events << ':on on_exit' if s.recorder
          }

          s.add_handler(:toggle) { next :off }
          s.add_handler(:noop) { nil }
        end)
        sm.add_state(CustomState.new(:off) do |s|
          s.on_enter { |_data|
            s.calls << ':off on_enter'
            s.recorder.events << ':off on_enter' if s.recorder
          }
          s.on_exit { |_data|
            s.calls << ':off on_exit'
            s.recorder.events << ':off on_exit' if s.recorder
          }

          s.add_handler(:toggle) { next :on }
        end)
      end
    }

    let(:sub) {
      # Additional switch over the simple statemachine.
      # with states
      #   :powered_on (the simple Statemachine) and
      #   :powered_off (just a state)
      #
      # Events / Transitions:
      #  :powered_on  --power_off--> :powered_off
      #  :powered_off --power_on-->  :powered_on
      #  ss events
      StateMachine.new do |sm|
        sm.add_state(State.new(:powered_off) do |s|
          s.add_handler(:power_on) {
            next :powered_on
          }
        end)
        sm.add_state(CustomSub.new(:powered_on, ss) do |s|
          s.on_enter { |_data|
            s.calls << ':powered_on on_enter'
            s.recorder.events << ':powered_on on_enter' if s.recorder
          }
          s.on_exit { |_data|
            s.calls << ':powered_on on_exit'
            s.recorder.events << ':powered_on on_exit' if s.recorder
          }
          s.add_handler(:power_off) { next :powered_off }
        end)
      end
    }

    it 'disallows events being processed when uninitialized' do
      expect { ss.handle_event :foo }.to raise_error(Uninitialized)
    end

    it 'returns state when add_state is called' do
      expect(ss.add_state(State.new :foo)).to be_a(State)
    end

    it 'allows only State-Like objects to be added' do
      expect { ss.add_state('Foo') }.to raise_error(NotAState)
    end

    it 'returns submachine when add_state is called' do
      statemachine = StateMachine.new
      expect(statemachine.add_state(Sub.new :foo, ss)).to be_a(Sub)
      expect(statemachine.add_state(Sub.new :bar, ss)).to be_a(State)
    end

    it 'disallows two identically named states being added' do
      sm = StateMachine.new
      sm.add_state State.new(:angora_rabbit)
      expect { sm.add_state State.new(:angora_rabbit) }.to raise_error(StateIdConflict)
    end

    it 'disallows two identically named states being added even when one name was given as string' do
      sm = StateMachine.new
      sm.add_state State.new(:angora_rabbit)
      expect { sm.add_state State.new('angora_rabbit') }.to raise_error(StateIdConflict)
    end

    it 'disallows switching to unknown states' do
      statemachine = StateMachine.new do |sm|
        sm.add_state(State.new(:first) do |s|
          s.add_handler(:foo) {
            next :bar
          }
        end)
      end
      statemachine.setup
      expect { statemachine.handle_event(:foo) }.to raise_error(UnknownState)
    end

    context 'empty statemachine' do
      it 'cannot start' do
        statemachine = StateMachine.new
        expect { statemachine.setup }.to raise_error(NoStates)
      end
    end

    context 'simple statemachine' do
      before { ss.setup }

      it 'is :on initially' do
        expect(ss.state.id).to eq(:on)
      end

      it 'is :off after toggle event' do
        ss.handle_event :toggle
        expect(ss.state.id).to eq(:off)
      end

      it 'get its on_enter/on_exit handlers called' do
        expect(ss.state.calls).to eq([':on on_enter'])
        ss.handle_event :toggle
        expect(ss.states.first.calls).to eq([':on on_enter', ':on on_exit'])
        expect(ss.state.calls).to eq([':off on_enter'])
      end

      it 'can be toggled :off and :on again' do
        ss.handle_event :toggle
        ss.handle_event :toggle
        expect(ss.state.id).to eq(:on)
      end

      it 'disallows modification when already initialized' do
        expect { ss.add_state(State.new :fuzzy) }.to raise_error(Initialized)
      end

      it 'permits handling events without switching state' do
        ss.handle_event :noop
        expect(ss.state.id).to eq(:on)
      end
    end

    context 'sub statemachine' do
      before {
        sub.states.last.recorder = recorder
        sub.states.last.sub.states.first.recorder = recorder
        sub.setup
      }

      it 'is initially powered off' do
        expect(sub.state.id).to eq(:powered_off)
      end

      context 'when powered on' do
        before { sub.handle_event :power_on }

        it 'is on' do
          expect(sub.state.id).to eq(:powered_on)
        end

        it 'can be powered off and enter/exit handlers get called in correct order' do
          sub.handle_event :power_off
          expect(sub.state.id).to eq(:powered_off)
          expect(recorder.events).to eq([
            ':powered_on on_enter',
            ':on on_enter',
            ':on on_exit',
            ':powered_on on_exit'
          ])
        end

        it 'has a submachine which is initially :on and its on_enter_called' do
          expect(sub.state.sub.state.id).to eq(:on)
          expect(sub.state.calls).to eq([':powered_on on_enter'])
        end

        it 'has a submachine which can be toggled :off' do
          sub.handle_event :toggle
          expect(sub.state.sub.state.id).to eq(:off)
        end

        it 'has a submachine which can be toggled :off and :on again' do
          sub.handle_event :toggle
          sub.handle_event :toggle
          expect(sub.state.sub.state.id).to eq(:on)
        end

        it 'has a submachine that resets to :on when repowered' do
          sub.handle_event :toggle # submachine is now :off
          sub.handle_event :power_off
          sub.handle_event :power_on
          expect(sub.state.sub.state.id).to eq(:on)
          expect(sub.state.calls).to eq([
            ':powered_on on_enter',
            ':powered_on on_exit',
            ':powered_on on_enter'
          ])
        end
      end
    end
  end
end
