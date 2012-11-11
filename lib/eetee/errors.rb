module EEtee
  
  class AssertionFailed < RuntimeError
    attr_accessor :test
        
  end
  
  class Error < RuntimeError
    attr_accessor :error, :test
    
    def initialize(error, test)
      @error = error
      @test = test
    end
  end
  
end
