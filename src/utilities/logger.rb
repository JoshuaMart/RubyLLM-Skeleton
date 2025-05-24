# frozen_string_literal: true

require 'logger'
require 'colorize'

module Utilities
  class Logs
    # Creates a singleton logger
    def self.logger
      return @logger if @logger

      @logger = Logger.new($stdout)
      @logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }

      @logger
    end

    # Set the log level for the previous logger
    def self.level=(level)
      logger.level = level.downcase.to_sym
    end

    def self.fatal(message)
      logger.fatal(message.red)

      exit
    end

    def self.info(message)
      logger.info(message.green)
    end

    def self.control(message)
      logger.info(message.light_blue)
    end

    def self.debug(message)
      logger.debug(message.light_magenta)
    end

    def self.warn(message)
      logger.warn(message.yellow)
    end
  end
end
