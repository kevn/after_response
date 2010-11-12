
module AfterResponse
  
  CONTAINER_ADAPTERS = [
    OpenStruct.new(
      :name => :passenger,
      :test => lambda{ defined?(PhusionPassenger) },
      :lib => 'after_response/adapters/passenger'
    )
  ]
  
  def self.attach_to_current_container
    current_container && require(current_container.lib)
  end
  
  def self.current_container
    @current_container ||= CONTAINER_ADAPTERS.detect{|c| c.test.call }
  end
  
  def self.bufferable?
    @current_container
  end
  
end
