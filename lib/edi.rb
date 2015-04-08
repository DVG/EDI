require 'active_support'
require 'active_support/string_inquirer'
require 'edi/core_ext'
require "edi/version"
require 'edi/core'
require 'edi/dsl'
require 'edi/postable'
require 'edi/environment'
require 'edi/service'
require 'edi/exceptions'
require 'edi/interpreter'
require 'edi/refinements'
require 'edi/services'
require 'edi/service_runner'
require 'edi/slack'
require 'edi/api/response'
require 'edi/configuration'
require 'edi/http_utilities'
require 'edi/application'
require 'edi/utilities/array_responder'
require 'edi/schedule'
require 'edi/job'
require 'edi/logger'
require 'edi/websocket'
module EDI
  class << self
    attr_accessor :services, :websocket
    def services
      @services ||= []
    end

    def register_services(*args)
      args.each { |klass| services << klass}
      EDI::Interpreter.build_determine_service
    end

    def clear_services
      @services = []
    end

    def bootstrap
      require File.join EDI.root, "config", "environment"
      EDI::Application.initialize!
    end

    def root
      self.config.root
    end

    def env
      self.config.environment ||= ActiveSupport::StringInquirer.new(ENV["edi_ENV"] || ENV["RACK_ENV"] || "development")
    end

    def env=(environment)
      self.config.environment = ActiveSupport::StringInquirer.new(environment)
    end

    def websocket
      @websocket ||= Websocket::Client.new
    end

    def runner
      ServiceRunner
    end

    def bot_name
      self.config.bot_name
    end

    def bot_token
      @bot_token ||= ENV["SLACK_EDI_TOKEN"]
    end

    def channels
      @channels ||= []
    end

    def add_channel(channel)
      channels << channel
    end

    def send_message(message, channel_name: "general", channel_id: nil)
      EDI.websocket.send_message(message, channel_name: channel_name, channel_id: channel_id)
    end
  end
  include EDI::HTTPUtilities
  include EDI::Configuration
end
