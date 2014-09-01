module HSM
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
