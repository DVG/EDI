module EDI
  module Configuration
    require 'active_support'
    require 'active_support/configurable'
    require 'active_support/dependencies'
    def self.included(base)
      base.include ActiveSupport::Configurable
      base.configure do |config|
        # Bot Name
        config.bot_name = "EDI"

        # These messages can be overridden in the Application configuration. If an array of strings are provided,
        # a random one will be selected
        config.hello_message = "Hello, I'm #{config.bot_name}"
        config.default_response = "What is this, I don't even"
        config.unfit_environment_response = "I'm really sorry, but that service needs to be configured"
        config.third_party_api_failure_respone = "Most unfortunately, that service is not working right now."
        config.standard_error_response = "I'm sorry, Something went wrong."

        # Autoload Services
        config.autoload_paths = ["bot/services"]

        # Postable Configuration
        config.default_channel = "#general"

        # Bot Token Variable
        config.bot_token = ENV["SLACK_EDI_TOKEN"]

        # Log Level. Valid Values are :development, :production, :silent
        config.log_level = :debug
      end
    end
  end
end
