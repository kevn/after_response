module AfterResponse

  module Adapters
    #
    # Example (in config.ru):
    #
    #     require 'after_response/adapters/unicorn'
    #
    #     use AfterResponse::Adapters::Unicorn
    class UnicornMiddleware < Struct.new(:app, :body)

      def initialize(app)
        super(app)
      end

      def call(env)
        status, headers, self.body = app.call(env)
        [ status, headers, self ]
      end

      def each(&block)
        body.each(&block)
      end

      def close
        body.close if body.respond_to?(:close)
        AfterResponse::Callbacks.perform_after_response_callbacks!
      end

    end
  end
end
