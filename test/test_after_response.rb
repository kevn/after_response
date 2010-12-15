require File.dirname(__FILE__) + '/helper'
class AfterResponseTest < Test::Unit::TestCase
  
  def setup
    AfterResponse.logger.level = Logger::FATAL
  end

  def teardown
    AfterResponse.reset!
  end

  def test_attach_to_current_container
    AfterResponse.attach_to_current_container!
    assert !AfterResponse.bufferable?
  end

  def test_attach_to_fake_current_container
    attach_to_fake_current_container
    assert AfterResponse.bufferable?
    assert defined?(AfterResponse::FakeAdapter)
  end

  def test_attach_to_fake_container_callback
    attach_to_fake_current_container
    assert AfterResponse.bufferable?
    some_value = 0
    AfterResponse.append_after_response do
      some_value = 1
    end
    assert_equal 0, some_value
    AfterResponse::FakeAdapter.perform_after_response_callbacks!
    assert_equal 1, some_value
  end

protected
  def attach_to_fake_current_container
    AfterResponse::CONTAINER_ADAPTERS << OpenStruct.new(
      :name => :fake,
      :test => lambda{ true },
      :lib  => File.dirname(__FILE__) + '/fake_adapter'
    ) unless AfterResponse::CONTAINER_ADAPTERS.detect{ |adapter| adapter.name == :fake }
    AfterResponse.attach_to_current_container!
  end

end