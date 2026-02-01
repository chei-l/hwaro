require "option_parser"
require "./command"
require "./flag_info"
require "../utils/logger"

module Hwaro
  module CLI
    abstract class BaseCommand(T) < Command
      @flags_loaded = false
      @stored_flags = [] of FlagInfo

      # Abstract methods for subclasses
      abstract def default_options : T
      abstract def setup_flags(parser : OptionParser, options : T)
      abstract def execute(options : T, args : Array(String))

      def flags : Array(FlagInfo)
        ensure_flags_loaded
        @stored_flags
      end

      def run(args : Array(String)) : Nil
        options = default_options
        parser = OptionParser.new
        parser.banner = banner

        setup_parser(parser, options)

        parser.parse(args)
        execute(options, parser.unknown_args)
        nil
      rescue ex : OptionParser::InvalidOption
        Logger.error "Error: #{ex.message}"
        exit(1)
      rescue ex : Exception
        Logger.error "Error: #{ex.message}"
        exit(1)
      end

      protected def banner
        "Usage: hwaro #{name} [options]"
      end

      # Hook to allow custom parser setup (e.g. unknown args)
      protected def setup_parser(parser : OptionParser, options : T)
        setup_flags(parser, options)
        parser.on("-h", "--help", "Show this help") { Logger.info parser.to_s; exit }
        @flags_loaded = true
      end

      # Helper to define flags and record them
      protected def flag(parser : OptionParser, short : String?, long : String, description : String, &block : String ->)
        record_flag(short, long, description, true)
        if short
          parser.on(short, long, description, &block)
        else
          parser.on(long, description, &block)
        end
      end

      protected def flag(parser : OptionParser, short : String?, long : String, description : String, &block : ->)
        record_flag(short, long, description, false)
        if short
          parser.on(short, long, description, &block)
        else
          parser.on(long, description, &block)
        end
      end

      private def record_flag(short, long, description, has_arg)
        # Avoid duplicates if called multiple times
        return if @flags_loaded
        @stored_flags << FlagInfo.new(short, long, description, has_arg)
      end

      private def ensure_flags_loaded
        return if @flags_loaded
        parser = OptionParser.new
        # We need a dummy options object to run setup_flags
        opts = default_options
        setup_flags(parser, opts)
        @flags_loaded = true
      end
    end
  end
end
