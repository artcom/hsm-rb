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
      @subs.each do |sub|
        sub.handle_event(*args)
      end
    end
  end
end
