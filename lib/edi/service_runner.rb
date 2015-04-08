class ServiceRunner

    attr_accessor :message, :service
    def initialize(message:)
      @message = message
    end

    def execute
      self.service = EDI::Interpreter.new(message).determine_service.new(message)
      EDI::Logger.info "Service: #{service.class} invoked"
      begin
        _run_service
      rescue EDI::UnfitEnvironmentException => e
        EDI::ArrayResponder.new(EDI.config.unfit_environment_response).respond
      rescue EDI::ThirdPartyAPIFailure
        EDI::ArrayResponder.new(EDI.config.third_party_api_failure_respone).respond
      rescue => e
        EDI::ArrayResponder.new(EDI.config.standard_error_response).respond
      end
    end

private

    def _run_service
      service.validate_environment
      service.invoke
    end

end
