require 'logger'

module EDI
  class Logger
    def self.info(message)
      logger.info message unless EDI.config.log_level == :silent
    end

    def self.warn(message)
      logger.warn message unless EDI.config.log_level == :silent
    end

    def self.error(message)
      logger.error message unless EDI.config.log_level == :silent
    end

private

    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end
  end
end
