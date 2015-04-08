module EDI
  module API
    class Response
      require 'json'
      attr_accessor :status, :response
      alias_method :code, :status

      def initialize(response)
        @status = response.code
        @response = response.body
      end

      def response
        JSON.parse @response
      end

      def unparsed_response
        @response
      end

      def ok?
        status == 200
      end

      def not_ok?
        !ok?
      end

    end
  end
end
