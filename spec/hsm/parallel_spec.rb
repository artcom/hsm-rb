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
  describe :Parallel do
    let(:parallel) {
      # Two simple Statemachines that toggle between on/off
      # for capslock/numlock and contained parallely in a keyboard toggle
      # statemachine.
      numlock_sm = StateMachine.new do |sm|
        sm.add_state(CustomState.new(:numlock_off) do |s|
          s.on_enter { s.calls << 'numlock_off__on_enter' }
          s.on_exit { s.calls << 'numlock_off_on_exit' }
          s.add_handler(:numlock) {
            next :numlock_on
          }
        end)
        sm.add_state(CustomState.new(:numlock_on) do |s|
          s.on_enter { s.calls << 'numlock_on__on_enter' }
          s.on_exit { s.calls << 'numlock_on__on_exit' }
          s.add_handler(:numlock) {
            next :numlock_off
          }
        end)
      end
      capslock_sm = StateMachine.new do |sm|
        sm.add_state(CustomState.new(:capslock_off) do |s|
          s.on_enter { s.calls << 'capslock_off__on_enter' }
          s.on_exit { s.calls << 'capslock_off__on_exit' }
          s.add_handler(:capslock) {
            next :capslock_on
          }
        end)
        sm.add_state(CustomState.new(:capslock_on) do |s|
          s.on_enter { s.calls << 'capslock_on__on_enter' }
          s.on_exit { s.calls << 'capslock_on__on_exit' }
          s.add_handler(:capslock) {
            next :capslock_off
          }
        end)
      end
      StateMachine.new do |sm|
        sm.add_state(CustomState.new(:keyboard_off) do |s|
          s.add_handler(:plug) {
            next :keyboard_on
          }
        end)
        sm.add_state(Parallel.new(:keyboard_on, [numlock_sm, capslock_sm]) do |s|
          s.add_handler(:unplug) {
            next :keyboard_off
          }
        end)
      end
    }

    before { parallel.setup }

    it 'is off (unplugged) initially' do
      expect(parallel.state.id).to eq(:keyboard_off)
    end

    it 'has capslock and numlock initially off when plugged' do
      parallel.handle_event :plug
      expect(parallel.state.id).to eq(:keyboard_on)
      expect(parallel.state.subs.first.state.id).to eq(:numlock_off)
      expect(parallel.state.subs.last.state.id).to eq(:capslock_off)
    end

    context 'when unplugged' do
      before {
        parallel.handle_event :plug
        parallel.handle_event :unplug
      }

      it 'does not react to capslock' do
        expect(parallel.states.last.subs.last.states.first.calls).to eq(%w(
          capslock_off__on_enter
          capslock_off__on_exit
        ))
      end
    end

    context 'when plugged in' do
      before {
        # parallel.setup
        parallel.handle_event :plug
      }

      it 'is actually plugged in' do
        expect(parallel.state.id).to eq(:keyboard_on)
      end

      it 'can toggle capslock independently from numlock' do
        parallel.handle_event :capslock
        expect(parallel.state.subs.last.state.id).to eq(:capslock_on)
        expect(parallel.state.subs.first.state.id).to eq(:numlock_off)

        parallel.handle_event :capslock
        expect(parallel.state.subs.last.state.id).to eq(:capslock_off)
        expect(parallel.state.subs.first.state.id).to eq(:numlock_off)
      end

      it 'can toggle numlock independently from capslock' do
        parallel.handle_event :numlock
        expect(parallel.state.subs.first.state.id).to eq(:numlock_on)
        expect(parallel.state.subs.last.state.id).to eq(:capslock_off)

        parallel.handle_event :numlock
        expect(parallel.state.subs.first.state.id).to eq(:numlock_off)
        expect(parallel.state.subs.last.state.id).to eq(:capslock_off)
      end

      it 'tears down contained parallel statemachines correctly' do
        parallel.handle_event :unplug
        expect(parallel.states.last.subs.first.states.first.calls).to eq(%w(
          numlock_off__on_enter
          numlock_off_on_exit
        ))
        expect(parallel.states.last.subs.last.states.first.calls).to eq(%w(
          capslock_off__on_enter
          capslock_off__on_exit
        ))
      end

      it 'reinitializes submachines to initial states when replugged' do
        parallel.handle_event :numlock
        parallel.handle_event :capslock
        expect(parallel.state.subs.first.state.id).to eq(:numlock_on)
        expect(parallel.state.subs.last.state.id).to eq(:capslock_on)
        parallel.handle_event :unplug
        parallel.handle_event :plug
        expect(parallel.state.subs.first.state.id).to eq(:numlock_off)
        expect(parallel.state.subs.last.state.id).to eq(:capslock_off)
      end
    end
  end
end
