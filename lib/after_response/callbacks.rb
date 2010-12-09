module AfterResponse
  
  def self.callbacks
    Callbacks.callbacks
  end
  
  def self.append_after_response(&block)
    Callbacks.append_after_response(&block)
  end
  
  module Callbacks
    
    def self.append_after_response(&block)
      if AfterResponse.bufferable?
        callbacks << block
      else
        block.call
      end
    end
    
    def self.callbacks
      Thread.current[:__after_response_callbacks__] ||= []
    end
    
    def self.perform_after_response_callbacks!
      AfterResponse.callbacks.each do |b|
        b.call
      end
    ensure
      AfterResponse.callbacks.clear
    end
    
  end
  
end
