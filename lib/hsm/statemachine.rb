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

    def on_enter(&block)
      @on_enter = block
    end

    def on_exit(&block)
      @on_exit = block
    end
  end

  class Sub < State
    attr_reader :sub

    def initialize(id, sub_machine, &init)
      super id, &init
      @sub = sub_machine
    end

    def enter(_prev_state, _data = {})
      @sub.setup
    end

    def exit
      @sub.teardown
    end

    def handle_event(*args)
      @sub.handle_event(*args)
    end
  end

#  class Parallel < State
#  end

  class StateMachine
    attr_reader :state

    def initialize
      @state = nil
      @states = []
      yield self if block_given?
    end

    def handle_event(event, *data)
      if @state.handler.include?(event)
        @logger.debug "handle_event #{event}" unless @logger.nil?
        next_state_id, args = @state.handler[event].call(*data)
        next_state = (@states.select { |s| s.id == next_state_id }).first
        if next_state
          switch_state(next_state, args)
        else
          @logger.error "Unknown state '#{next_state_id}' returned from handler" unless @logger.nil?
        end
      elsif @state.is_a? Sub
        @state.handle_event event, *data
      end
    end

    def setup
      switch_state(@states.first)
    end

    def teardown
    end

    def add_state(state, &init)
      new_state = State.new state, &init
      @states << new_state
    end

    def add_sub(state, sub, &init)
      @states << Sub.new(state, sub, &init)
    end

    private

    def switch_state(next_state, args = {})
      @logger.debug "switching state #{@state ? @state.id : 'nil'} -> #{next_state ? next_state.id : 'nil'}" unless @logger.nil?
      @state.exit if @state
      old_state = @state
      @state = next_state
      @state.enter old_state, args
    end
  end
end
