module AfterResponse

  module Adapters
    #
    # Example (in config.ru):
    #
    #     require 'after_response/adapters/unicorn'
    #
    #     use AfterResponse::Adapters::Unicorn
    class UnicornMiddleware < Struct.new(:app)

      def initialize(app)
        STDOUT.puts "[AfterResponse] => Unicorn middleware initialize"
        super(app)
      end

      def call(env)
        STDOUT.puts "[AfterResponse] => Unicorn middleware call"
        app.call(env)
      end

      def each(&block)
        STDOUT.puts "[AfterResponse] => Unicorn middleware each"
        body.each(&block)
      end

      def close
        STDOUT.puts "[AfterResponse] => Unicorn middleware close"
        body.close if body.respond_to?(:close)
        AfterResponse::Callbacks.perform_after_response_callbacks!
      end

    end
  end
end
