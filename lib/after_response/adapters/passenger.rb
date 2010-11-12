class PhusionPassenger::Rack::RequestHandler
  
  include AfterResponse::ActivityBuffer
  include AfterResponse::PerformActivityBuffer
  
  def process_request_with_after_response(*args)
    returning(process_request_without_after_response(*args)) do
      perform_after_response_buffer!
    end
  end
  alias_method_chain :process_request, :after_response
  
end
