require 'spec_helper'

module HSM
  describe State do

    it 'can be instantianted with just an id' do
      state = State.new 'foo'
      expect(state).to be_a(State)
      expect(state.id).to eq('foo')
    end
  end
end
