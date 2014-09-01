module HSM
  class State
    attr_reader :id, :handler

    def initialize(id)
      @id = id
      @handler = {}
      @on_enter = nil
      @on_exit = nil
      yield self if block_given?
    end

    def enter(_last_state, data = {})
      @on_enter.call(data) unless @on_enter.nil?
    end

    def exit
      @on_exit.call(data) unless @on_exit.nil?
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
