if PhusionPassenger::AbstractRequestHandler.methods.include?('accept_and_process_next_request')
  # This method is in Passenger 3.0

  class PhusionPassenger::AbstractRequestHandler
  
  protected
    def accept_and_process_next_request_with_after_response(*args)
      returning(accept_and_process_next_request_without_after_response(*args)) do
        AfterResponse::ActivityBuffer.perform_after_response_buffer!
      end
    end
    alias_method_chain :accept_and_process_next_request, :after_response
  
  end
elsif PhusionPassenger::VERSION_STRING == '2.2.14'
# ACK... Passenger < 3.0 can't be supported because its request loop can't be interfered with.
# https://github.com/FooBarWidget/passenger/blob/release-2.2.14/lib/phusion_passenger/abstract_request_handler.rb
# We'd have to copy & paste the entire AbstractRequestHandler#main_loop method. Here goes.

  class PhusionPassenger::AbstractRequestHandler
    # Enter the request handler's main loop.
  	def main_loop
  		reset_signal_handlers
  		begin
  			@graceful_termination_pipe = IO.pipe
  			@graceful_termination_pipe[0].close_on_exec!
  			@graceful_termination_pipe[1].close_on_exec!

  			@main_loop_thread_lock.synchronize do
  				@main_loop_generation += 1
  				@main_loop_running = true
  				@main_loop_thread_cond.broadcast
  			end

  			install_useful_signal_handlers

  			while true
  				@iterations += 1
  				client = accept_connection
  				if client.nil?
  					break
  				end
  				begin
  					headers, input = parse_request(client)
  					if headers
  						if headers[REQUEST_METHOD] == PING
  							process_ping(headers, input, client)
  						else
  							process_request(headers, input, client)
  						end
  					end
  				rescue IOError, SocketError, SystemCallError => e
  					print_exception("Passenger RequestHandler", e)
  				ensure
  					# 'input' is the same as 'client' so we don't
  					# need to close that.
  					# The 'close_write' here prevents forked child
  					# processes from unintentionally keeping the
  					# connection open.
  					client.close_write rescue nil
  					client.close rescue nil
            # All this crap to add one line... BOOOOO!
            AfterResponse::ActivityBuffer.perform_after_response_buffer!
  				end
  				@processed_requests += 1
  			end
  		rescue EOFError
  			# Exit main loop.
  		rescue Interrupt
  			# Exit main loop.
  		rescue SignalException => signal
  			if signal.message != HARD_TERMINATION_SIGNAL &&
  			   signal.message != SOFT_TERMINATION_SIGNAL
  				raise
  			end
  		ensure
  			revert_signal_handlers
  			@main_loop_thread_lock.synchronize do
  				@graceful_termination_pipe[0].close rescue nil
  				@graceful_termination_pipe[1].close rescue nil
  				@main_loop_generation += 1
  				@main_loop_running = false
  				@main_loop_thread_cond.broadcast
  			end
  		end
  	end
  end

else
  raise "Unsupported Passenger version: #{PhusionPassenger::VERSION_STRING}"

end
