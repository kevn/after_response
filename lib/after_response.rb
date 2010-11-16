
module AfterResponse
  
  CONTAINER_ADAPTERS = [
    OpenStruct.new(
      :name => :passenger,
      :test => lambda{ defined?(PhusionPassenger) },
      :lib => 'after_response/adapters/passenger'
    )
  ]
  
  def self.attach_to_current_container
    return if @after_response_attached
    if current_container
      require(current_container.lib)
      @after_response_attached = true
      Rails.logger.info{ "AfterResponse callback hook installed for #{current_container.name}" }
    end
  end
  
  def self.current_container
    @current_container ||= CONTAINER_ADAPTERS.detect{|c| c.test.call }
  end
  
  def self.bufferable?
    @current_container
  end
  
end
