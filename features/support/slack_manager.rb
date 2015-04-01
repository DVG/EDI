class SlackManager
  require 'childprocess'
  attr_accessor :slack, :slack_log, :slack_port

  def initialize
    @slack_port = find_available_port
    @slack = ChildProcess.build "sh", "-c", "thin start -R features/support/config.ru -p #{slack_port}"
    @slack_log = slack.io.stdout = slack.io.stderr = Tempfile.new('slack-log')
  end

  def start_stack
    puts "Starting Fake Slack"
    slack.start
  end

  def stop_stack
    slack.interrupt
  end

private

  def wait_for_processes_started
    begin
      Timeout::timeout(5) do
        loop do
          break if process_started?
        end
      end
    rescue
      slack.interrupt
    end
  end

  def process_started?
    open(slack_log).read.include? "Listening on 0.0.0.0:#{slack_port}"
  end


  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    server.addr[1]
  ensure
    server.close if server
  end

end
