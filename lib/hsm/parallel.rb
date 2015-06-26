module HSM
  class Parallel < State
    attr_reader :subs

    def initialize(id, sub_machines, &init)
      super id, &init
      @subs = sub_machines
    end

    def enter(_prev_state, _data = {})
      super
      @subs.each do |sub|
        sub.setup
      end
    end

    def exit
      @subs.each do |sub|
        sub.teardown
      end
      super
    end

    def handle_event(*args)
      handled = false;
      @subs.each do |sub|
        if sub._handle_event(*args) == true
          handled = true
        end
      end
      return handled
    end
  end
end
