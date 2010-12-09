
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
    )
  ]

  def self.attach_to_current_container!
    return if @after_response_attached
    if current_container
      require(current_container.lib)
      @after_response_attached = true
      Rails.logger.info{ "[AfterResponse] => Callback hook installed for #{current_container.name}" }
    else
      Rails.logger.info{ "[AfterResponse] => No supported container found. AfterResponse will not buffer." }
    end
  end

  def self.current_container
    @current_container ||= CONTAINER_ADAPTERS.detect{|c| c.test.call }
  end

  def self.bufferable?
    @current_container
  end

end
