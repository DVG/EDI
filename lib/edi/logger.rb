require 'logging'

module EDI
  class Logger
    def initialize
      @log_level = EDI.config.log_level
      @logger = Logging.logger['edi']
      @logger.level = @log_level
      @logger.add_appenders \
        Logging.appenders.stdout,
        Logging.appenders.file('log/edi.log')
    end

    def debug(message)
      @logger.debug message
    end

    def info(message)
      @logger.info message
    end

  end
end
