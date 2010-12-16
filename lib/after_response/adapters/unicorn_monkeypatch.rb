class Unicorn::HttpServer
  alias process_client_without_after_response process_client
  undef_method :process_client
  def process_client(client)
    result = process_client_without_after_response(client)
    AfterResponse::Callbacks.perform_after_response_callbacks!
    result
  end
end
