module AfterResponse
  module FakeAdapter
    def self.perform_after_response_callbacks!
      AfterResponse::Callbacks.perform_after_response_callbacks!
    end
  end
end
