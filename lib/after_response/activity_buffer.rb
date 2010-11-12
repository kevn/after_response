module AfterResponse
  
  def self.callbacks
    ActivityBuffer.callbacks
  end
  
  def self.append_after_response
    ActivityBuffer.append_after_response
  end
  
  module ActivityBuffer
    
    def self.append_after_response(&block)
      if AfterResponse.bufferable?
        after_response_callbacks << block
      else
        block.call
      end
    end
    
    def self.callbacks
      Thread.current[:__after_response_callbacks__] ||= []
    end
    
    delegate :callbacks, :append_after_response, :to => 'self.class'
    
  end
  
  module PerformActivityBuffer
    
    def perform_after_response_buffer!
      AfterResponse.callbacks.each do |b|
        b.call
      end
    ensure
      AfterResponse.callbacks.clear
    end
    
  end
  
end
