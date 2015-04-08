require 'thor'
module EDI
  class CLI < Thor
    include Thor::Actions

    attr_reader :name

    desc "new BOT_NAME", "Sets up a new EDI project"
    def new(name)
      @name = Thor::Util.snake_case(name)
      directory(:project, @name)
    end

    desc "start", "Bootup the EDI Application"
    def start(*args)
      EDI::Logger.info "Starting EDI Slackbot"
      run_command("ruby boot.rb")
    end

    desc "generate", "Generate service NAME"
    def generate(type, name)
      @name = Thor::Util.snake_case(name)
      generate_service(@name)
    end

private

    def run_command(command)
      system(command)
    end

    def generate_service(name)
      template("services/%name%.rb.tt", "bot/services/#{name}.rb")
    end

  end
end
