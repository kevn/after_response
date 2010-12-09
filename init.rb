require 'after_response'

AfterResponse.attach_to_current_container!

ActionController::Base.send(:include, AfterResponse::Callbacks)
