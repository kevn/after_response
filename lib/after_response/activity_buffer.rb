module AfterResponse
  
  def self.callbacks
    ActivityBuffer.callbacks
  end
  
  def self.append_after_response(&block)
    ActivityBuffer.append_after_response(&block)
  end
  
  module ActivityBuffer
    
    def self.append_after_response(&block)
      Rails.logger.debug{ "Appending after_response in thread #{Thread.current.inspect}" }
      if AfterResponse.bufferable?
        Rails.logger.debug{ "Buffering after_response block..." }
        callbacks << block
      else
        Rails.logger.debug{ "Calling after_response block due to !bufferable?..." }
        block.call
      end
    end
    
    def self.callbacks
      Thread.current[:__after_response_callbacks__] ||= []
    end
    
    def self.perform_after_response_buffer!
      Rails.logger.debug{ "Calling after_response blocks..." }
      Rails.logger.debug{ "Calling blocks for thread #{Thread.current.inspect}" }
      AfterResponse.callbacks.each do |b|
        Rails.logger.debug{ " * Calling after_response block #{b}" }
        b.call
      end
    ensure
      AfterResponse.callbacks.clear
    end
    
  end
  
end
