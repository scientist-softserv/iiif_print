module IiifPrint
  module Logging
    class << self
      attr_accessor :configured
    end
    self.configured = []

    def logger
      @logger = Rails.logger
    end

    # Log message, as in standard logger, but use message_format on message.
    # @param severity [Integer] log level/severity, e.g. Logger::INFO == 2
    # @param msg [String] Log message to be formatted by message_format
    # @param progname [String] (optional)
    def log(severity, msg, progname = nil, &block)
      logger.add(severity, message_format(msg), progname, &block)
    end

    # Simpler alternative to .log, with default severity, message_format
    #   wrapping.
    # @param msg [String] Log message to be formatted by message_format
    # @param severity [Integer] log level/severity, e.g. Logger::INFO == 2
    # @param progname [String]
    def write_log(msg, severity = Logger::INFO, progname = nil)
      logger.add(severity, message_format(msg), progname)
    end

    # format message, distinct from per-output formatting, to be used in
    #   all logging channels Rails.logger broadcasts to.  This wrapping
    #   indicates in parenthetical prefix which class is acting to
    #   produce message.
    # @param msg [String]
    def message_format(msg)
      "(#{self.class}) #{msg}"
    end

    # Should be called by consuming class, prior to use of .logger method
    #   has checks to prevent duplicate configuration if already configured.
    def configure_logger(name)
      @logger = Rails.logger
      return if IiifPrint::Logging.configured.include?(name)
      path = Rails.root.join("log/#{name}.log")
      @named_log = ActiveSupport::Logger.new(path)
      @named_log.formatter = proc do |_severity, datetime, _progname, msg|
        "#{datetime}: #{msg}\n"
      end
      # rails will log to named_log in addition to any other configured
      #   or default logging destinations:
      @logger.extend(ActiveSupport::Logger.broadcast(@named_log))
      IiifPrint::Logging.configured.push(name)
    end
  end
end
