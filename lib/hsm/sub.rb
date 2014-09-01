module HSM
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
end
