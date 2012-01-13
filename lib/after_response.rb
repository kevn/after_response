require 'ostruct'
require 'after_response/callbacks'
require 'after_response/adapters/unicorn_middleware'

module AfterResponse

  CONTAINER_ADAPTERS = [
    OpenStruct.new(
      :name => :passenger3,
      :test => lambda{ defined?(PhusionPassenger) && PhusionPassenger::AbstractRequestHandler.private_instance_methods.include?("accept_and_process_next_request") },
      :lib  => 'after_response/adapters/passenger3'
    ),
    OpenStruct.new(
      :name => :passenger2,
      # This has only been tested on 2.2.14 and 2.2.15. Other 2.2.x might work if the main_loop method is unchanged.
      :test => lambda{ defined?(PhusionPassenger) && ['2.2.14', '2.2.15'].include?(PhusionPassenger::VERSION_STRING) },
      :lib  => 'after_response/adapters/passenger2_2'
    ),
    OpenStruct.new(
      :name => :unicorn_middleware,
      # TODO: Find a more general non-Rails-specific way of inspecting installed middleware
      :test => lambda{ 
                       # Use the appropriate middleware object for Rails2 or Rails 3
                       mw = defined?(ActionController::Dispatcher.middleware) ? ActionController::Dispatcher.middleware.active : Rails.application.config.middleware
                       
                       defined?(Unicorn::HttpServer) &&
                       defined?(Rails)   &&
                       mw.detect{|m| m == AfterResponse::Adapters::UnicornMiddleware }
               }
    )
  ]

  def self.attach_to_current_container!
    return if @after_response_attached
    if current_container
      require(current_container.lib) if current_container.lib
      @after_response_attached = true
      logger.info{ "[AfterResponse] => Callback hook installed for #{current_container.name}" }
    else
      logger.info{ "[AfterResponse] => No supported container found. AfterResponse will not buffer." }
    end
  end

  def self.reset!
    @after_response_attached = @current_container = @logger = nil
  end

  def self.current_container
    @current_container ||= CONTAINER_ADAPTERS.detect{|c| c.test.call }
  end

  # AfterResponse is in a bufferable state mode only if it is running under a supported container
  # where an after_response callback hook was installed and if an after_response callback
  # was installed that calls Starboard::EventQueue.flush!
  def self.bufferable?
    @after_response_attached
  end

  # If a container adapter isn't available, this method can be called to enable the buffering of events,
  # and Starboard::EventQueue.flush! must be called manually
  def self.buffer_and_flush_manually!
    @after_response_attached ||= begin
      raise "Callback hook already installed for #{current_container.name}" if current_container
      logger.info{ "[AfterResponse] => Will flush manually" }
      true
    end
  end

  def self.logger
    @logger ||= begin
      if defined?(Rails)
        Rails.logger
      else
        require 'logger'
        Logger.new($stdout)
      end
    end
  end

end
