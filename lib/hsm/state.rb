module HSM
  class State
    attr_reader :id, :handler
    attr_accessor :owner

    def initialize(id)
      @id = id.intern
      @handler = {}
      @on_enter = nil
      @on_exit = nil
      @owner = nil
      yield self if block_given?
    end

    def has_ancestor(other)
      if self.owner.container == nil
        return false
      end
      if self.owner.container == other
        return true
      end
      self.owner.container.has_ancestor(other);
    end

    def has_ancestor_statemachine(stateMachine)
      self.owner.path.each do |subMachine|
        if subMachine == stateMachine
          return true
        end
      end
      false
    end

    def enter(_last_state, data = {})
      @on_enter.call(data) unless @on_enter.nil?
    end

    def exit
      @on_exit.call unless @on_exit.nil?
    end

    def add_handler(event, &block)
      @handler[event] = block
    end

    # rubocop:disable Style/TrivialAccessors
    def on_enter(&block)
      @on_enter = block
    end

    def on_exit(&block)
      @on_exit = block
    end
    # rubocop:enable Style/TrivialAccessors
  end
end
