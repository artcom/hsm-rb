require 'spec_helper'

module HSM
  describe StateMachine do

    it 'can be instantiated empty' do
      expect(subject).to be_a(StateMachine)
    end

    let(:ss) {
      # Simple Statemachine with states :on and :off
      # :on  --toggle--> :off
      # :off --toggle--> :off
      StateMachine.new do |sm|
        sm.add_state(:on) do |s|
          s.add_handler(:toggle) { next :off }
        end
        sm.add_state(:off) do |s|
          s.add_handler(:toggle) { next :on }
        end
      end
    }

    it 'disallows events being processed when uninitialized' do
      expect { ss.handle_event :foo }.to raise_error(Uninitialized)
    end

    context 'empty statemachine' do
      it 'cannot start' do
        statemachine = StateMachine.new
        expect { statemachine.setup }.to raise_error(Uninitialized)
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

      it 'can be toggled :off and :on again' do
        ss.handle_event :toggle
        ss.handle_event :toggle
        expect(ss.state.id).to eq(:on)
      end
    end

    context 'sub statemachine' do
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
          sm.add_state(:powered_off) do |s|
            s.add_handler(:power_on) { next :powered_on }
          end
          sm.add_sub(:powered_on, ss) do |s|
            s.add_handler(:power_off) { next :powered_off }
          end
        end
      }

      before { sub.setup }

      it 'is initially powered off' do
        expect(sub.state.id).to eq(:powered_off)
      end

      context 'when powered on' do
        before { sub.handle_event :power_on }

        it 'is on' do
          expect(sub.state.id).to eq(:powered_on)
        end
        it 'has a submachine which is initially :on' do
          expect(sub.state.sub.state.id).to eq(:on)
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
        end
      end
    end
  end
end
