require "../../cli/base_command"
require "../../config/options/new_options"
require "../../services/creator"
require "../../utils/logger"

module Hwaro
  module CLI
    module Commands
      class NewCommand < BaseCommand(Config::Options::NewOptions)
        def name : String
          "new"
        end

        def description : String
          "Create a new content file"
        end

        def default_options : Config::Options::NewOptions
          Config::Options::NewOptions.new
        end

        def setup_flags(parser : OptionParser, options : Config::Options::NewOptions)
          parser.banner = "Usage: hwaro new [path]"
          flag(parser, "-t TITLE", "--title=TITLE", "Content title") { |t| options.title = t }
        end

        def execute(options : Config::Options::NewOptions, args : Array(String))
          if args.any?
            options.path = args.first
          end
          Services::Creator.new.run(options)
        end
      end
    end
  end
end
