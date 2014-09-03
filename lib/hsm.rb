module HSM
  require 'hsm/state'
  require 'hsm/sub'
  require 'hsm/parallel'
  require 'hsm/statemachine'

  %i(Uninitialized
     Initialized
     StateIdConflict
     UnknownState
     BlockGiven
     NotAState
     NoStates).each do |class_name|
    klass = Class.new(Exception)
    const_set class_name, klass
  end
end
