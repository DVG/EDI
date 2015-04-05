ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'json'
require 'edi'
require 'byebug'
require 'vcr'
require_relative './support/shared_contexts/service'
require_relative './support/shared_contexts/server'
require 'edi/test_support/test_support'
require 'feature_spec_helper'

include Rack::Test::Methods
include EDI::TestSupport

def app
  EDI::Core
end

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.around(:each) do |example|
    class TestService < EDI::Service
      def run

      end
    end
    class OtherTestService < EDI::Service
      def run

      end
    end
    class TestServer < EDI::Core
    end

    example.run

    EDI.clear_services

    Object.send :remove_const, :TestServer
    Object.send :remove_const, :TestService
    Object.send :remove_const, :OtherTestService
  end
  config.include ServerContext
  config.include ServiceContext
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/support/fixtures/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.filter_sensitive_data("<SLACK_WEBHOOK_URL>") { ENV["SLACK_WEBHOOK_URL"] }
  config.allow_http_connections_when_no_cassette = true
end
