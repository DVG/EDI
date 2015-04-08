require 'logging'

module EDI
  class Logger

    def self.logger
      @logger ||= _create_logger
    end

    def self.debug(message)
      logger.debug message
    end

    def self.info(message)
      logger.info message
    end

private

    def self._create_logger
      l = Logging.logger['EDI']
      l.level = EDI.config.log_level
      l.add_appenders \
        Logging.appenders.stdout,
        Logging.appenders.file('log/EDI.log')
      l
    end

  end
end
