class PhusionPassenger::AbstractRequestHandler

protected
  def accept_and_process_next_request_with_after_response(*args)
    returning(accept_and_process_next_request_without_after_response(*args)) do
      AfterResponse::Callbacks.perform_after_response_callbacks!
    end
  end
  alias_method_chain :accept_and_process_next_request, :after_response

end