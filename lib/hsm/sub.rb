module HSM
  class Sub < State
    attr_reader :sub

    def initialize(id, sub_machine, &init)
      super id, &init
      @sub = sub_machine
      @sub.container = self
    end

    def enter(_prev_state, _data = {})
      super
      @sub.setup
    end

    def exit
      @sub.teardown
      super
    end

    def handle_event(*args)
      @sub._handle_event(*args)
    end
  end
end
