module AfterResponse

  def self.callbacks
    Callbacks.callbacks
  end

  def self.transient_callbacks
    Callbacks.transient_callbacks
  end

  def self.append_after_response(&block)
    Callbacks.append_after_response(&block)
  end

  def self.append_transient_after_response(&block)
    Callbacks.append_transient_after_response(&block)
  end

  module Callbacks

    module Helpers
      def self.included(mod)
        mod.send(:include, TransientHelpers)
        mod.send(:extend, ModuleHelpers)
      end
    end

    # ApplicationController should include this
    module TransientHelpers
      def after_response(&block)
        AfterResponse.append_transient_after_response(&block)
      end
    end

    # ApplicationController should extend this
    module ModuleHelpers
      def after_response(&block)
        AfterResponse.append_after_response(&block)
      end
    end

    def self.append_after_response(&block)
      if AfterResponse.bufferable?
        callbacks << block
      else
        block.call
      end
    end

    def self.append_transient_after_response(&block)
      if AfterResponse.bufferable?
        transient_callbacks << block
      else
        block.call
      end
    end

    def self.callbacks
      Thread.current[:__after_response_callbacks__] ||= []
    end

    def self.transient_callbacks
      Thread.current[:__transient_after_response_callbacks__] ||= []
    end

    def self.all_callbacks
      transient_callbacks + callbacks
    end

    def self.perform_after_response_callbacks!
      all_callbacks.each do |b|
        b.call
      end
    ensure
      AfterResponse.transient_callbacks.clear
    end

  end

end
