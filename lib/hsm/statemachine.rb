module HSM
  class StateMachine
    attr_reader :state, :states

    def initialize
      @state = nil
      @states = []
      yield self if block_given?
    end

    def handle_event(event, *data)
      fail Uninitialized unless @state
      if @state.handler.include?(event)
        @logger.debug "handle_event #{event}" unless @logger.nil?
        next_state_id, args = @state.handler[event].call(*data)

        # Allow states to handle events without switching states
        return if next_state_id.nil?

        next_state = (@states.select { |s| s.id == next_state_id }).first
        if next_state
          switch_state(next_state, args)
        else
          @logger.error "Unknown state '#{next_state_id}' returned from handler" unless @logger.nil?
          fail UnknownState
        end
      elsif @state.is_a? Sub
        @state.handle_event event, *data
      end
    end

    def setup
      fail NoStates if @states.empty?
      switch_state(@states.first)
    end

    def teardown
    end

    def add_state(state)
      fail BlockGiven if block_given?
      fail Initialized if @state
      fail NotAState unless state.is_a?(State)
      fail StateIdConflict if @states.map(&:id).index state.id
      @states << state
      state # TODO: maybe remove? or replace with chaining mechanisms...
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
