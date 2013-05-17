
module EEteeDisableGC
  def run(&block)
    if toplevel
      GC.disable
    end
    
    super
    
    if toplevel
      GC.enable()
      GC.start()
    end
  end
  
end

puts "GC disabled during tests"


EEtee::Context.__send__(:include, EEteeDisableGC)
