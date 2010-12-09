# ACK... Passenger < 3.0 sucks because request loop can't be wrapped to do what we need.
# https://github.com/FooBarWidget/passenger/blob/release-2.2.14/lib/phusion_passenger/abstract_request_handler.rb
# We have to overwrite the entire AbstractRequestHandler#main_loop method. Here goes.

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
          # All this crap to add one line...
          AfterResponse::Callbacks.perform_after_response_callbacks!
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
