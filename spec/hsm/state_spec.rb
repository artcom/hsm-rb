require 'spec_helper'

module HSM
  describe State do

    let(:on) {
      State.new("on")
    }

    let(:noState) {
      State.new("none")
    }

    let(:subsub) {
      Sub.new(:subsub, StateMachine.new do |sm|
        sm.add_state(on)
      end)
    }

    let(:sub) {
      StateMachine.new do |sm|
        sm.add_state(subsub)
      end
    }

    let(:noSM) {
      StateMachine.new do |sm|
        sm.add_state(noState)
      end 
    }

    it 'can be instantianted with just an id' do
      state = State.new :foo
      expect(state).to be_a(State)
      expect(state.id).to eq(:foo)
    end

    it 'converts state ids to symbols' do
      state = State.new 'foo'
      expect(state).to be_a(State)
      expect(state.id).to eq(:foo)
    end

    it 'can have handlers for events' do
      state = State.new 'myState'
      state.add_handler :toggle do
        -1
      end
      state.add_handler :toggle do
        1
      end
      expect(state.handler[:toggle]).to be_a(Proc)
      expect(state.handler[:toggle].call).to eq(1)

      # can also be specified via block
      other_state = State.new 'offmaybe' do |s|
        s.add_handler :happens do
          'wrong'
        end
        s.add_handler :happens do
          'happened'
        end
      end
      expect(other_state.handler[:happens]).to be_a(Proc)
      expect(other_state.handler[:happens].call).to eq('happened')
    end

    it 'can have one on_enter/on_exit handler' do
      state = State.new 'myState'

      state.on_enter do
        'foo'
      end
      state.on_enter do
        'on_enter'
      end

      state.on_exit do
        'bar'
      end
      state.on_exit do
        'on_exit'
      end

      expect(state.instance_variable_get(:@on_enter)).to be_a(Proc)
      expect(state.instance_variable_get(:@on_enter).call).to eq('on_enter')
      expect(state.instance_variable_get(:@on_exit)).to be_a(Proc)
      expect(state.instance_variable_get(:@on_exit).call).to eq('on_exit')
    end

    context 'state nesting and hierarchy' do

      before {
        sub.setup
      }

      it 'can tell wether it is ancestor of a given state' do
        expect(on.has_ancestor(subsub)).to be_truthy
        expect(on.has_ancestor(noState)).to be_falsy
      end

      it 'can tell wether it is owned by a given statemachine' do
        expect(on.has_ancestor_statemachine(sub)).to be_truthy
        expect(on.has_ancestor_statemachine(noSM)).to be_falsy
      end

    end
  end
end
