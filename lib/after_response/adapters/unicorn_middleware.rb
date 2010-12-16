module AfterResponse

  module Adapters
    #
    # Example (in config.ru):
    #
    #     require 'after_response/adapters/unicorn'
    #
    #     use AfterResponse::Adapters::UnicornMiddleware
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

      # In Unicorn, this is called _after_ the socket is closed. (Not true for at least passenger3)
      def close
        body.close if body.respond_to?(:close)
        AfterResponse::Callbacks.perform_after_response_callbacks!
      end

    end
  end
end
