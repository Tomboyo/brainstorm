require 'brainstorm'

require 'logger'

module Brainstorm::Logging

  LOGGER = Logger.new(STDOUT,
    level: :warn,
    datetime_format: '%H:%M:%S',
    formatter:  proc do |severity, datetime, _progname, msg|
      "#{datetime} #{severity} - #{msg}\n"
    end)

  def log_error(msg, e = nil)
    error_message =
      if e.nil?
        ""
      else
        " - caused by `#{e}`\n#{e.backtrace.join("\n")}"
      end

    LOGGER.error("#{msg}#{error_message}")
  end

end