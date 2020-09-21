# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "user_agent_parser"
require "json"
require 'open3'

# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Uap < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "uap"

  # Replace the message with this value.
  config :source, :validate => :string, :default => "message"

  config :python_file, :validate => :string, :default => ""


  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)

    if (event.get(@source).nil? || event.get(@source).empty?)
        @logger.debug("Event to filter, event 'source' field: " + @source + " was null(nil) or blank, doing nothing")
        return
    end

    ua_string = event.get(@source)

    @logger.info(ua_string)
    # Replace the event ua_string with our ua_string as configured in the
    # config file.

    if @python_file
        cmd = @python_file + ' "'+ua_string+'"'
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          result = stdout.read
          ua = JSON.parse(result)
          event.set("ua_device", ua["device"])
          event.set("ua_brand", ua["brand"])
          event.set("ua_os", ua["os"])
          event.set("ua_os_ver", ua["os_version"])
          event.set("ua_browser", ua["browser"])
          event.set("ua_browser_ver", ua["browser_version"])
          event.set("ua_device_type", ua["device_type"])
        end
    end

    # correct debugging log statement for reference
    # using the event.get API
    
    @logger.debug? && @logger.debug("Message is now: #{event.get("@source")}")
    
    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Example
