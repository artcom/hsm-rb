module HSM
  require 'hsm/state'
  require 'hsm/sub'
  require 'hsm/parallel'
  require 'hsm/statemachine'

  %i(Uninitialized
     Initialized
     SelfNesting
     StateIdConflict
     UnknownState).each do |class_name|
    klass = Class.new(Exception)
    const_set class_name, klass
  end
end
