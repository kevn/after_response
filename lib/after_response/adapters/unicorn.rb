class Unicorn::HttpServer
  alias _process_client process_client
  undef_method :process_client
  def process_client(client)
    _process_client(client)
    AfterResponse::Callbacks.perform_after_response_callbacks!
  end
end
