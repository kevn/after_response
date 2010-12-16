require 'ostruct'
require 'after_response/callbacks'

module AfterResponse

  CONTAINER_ADAPTERS = [
    OpenStruct.new(
      :name => :passenger3,
      :test => lambda{ defined?(PhusionPassenger) && PhusionPassenger::AbstractRequestHandler.private_instance_methods.include?("accept_and_process_next_request") },
      :lib  => 'after_response/adapters/passenger3'
    ),
    OpenStruct.new(
      :name => :passenger2,
      :test => lambda{ defined?(PhusionPassenger) && PhusionPassenger::VERSION_STRING == '2.2.14' },
      :lib  => 'after_response/adapters/passenger2'
    ),
    OpenStruct.new(
      :name => :unicorn_middleware,
      :test => lambda{ defined?(Unicorn) },
      :lib  => 'after_response/adapters/unicorn_middleware'
    ),
    # FIXME: Find a better way to inspect the installed Rack middleware for the above and fallback
    # to monkeypatch if middleware isn't installed.
    # OpenStruct.new(
    #   :name => :unicorn_monkeypatch,
    #   :test => lambda{ defined?(Unicorn) },
    #   :lib  => 'after_response/adapters/unicorn_monkeypatch'
    # )
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
    current_container
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
