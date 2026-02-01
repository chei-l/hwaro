require "../../cli/base_command"
require "../../config/options/serve_options"
require "../../services/server/server"
require "../../utils/logger"

module Hwaro
  module CLI
    module Commands
      class ServeCommand < BaseCommand(Config::Options::ServeOptions)
        def name : String
          "serve"
        end

        def description : String
          "Serve the project and watch for changes"
        end

        def default_options : Config::Options::ServeOptions
          Config::Options::ServeOptions.new
        end

        def setup_flags(parser : OptionParser, options : Config::Options::ServeOptions)
          parser.banner = "Usage: hwaro serve [options]"

          flag(parser, "-b HOST", "--bind HOST", "Bind address (default: 0.0.0.0)") { |h| options.host = h }
          flag(parser, "-p PORT", "--port PORT", "Port to listen on (default: 3000)") { |p| options.port = p.to_i }
          flag(parser, nil, "--base-url URL", "Override base_url from config.toml") { |url| options.base_url = url }
          flag(parser, "-d", "--drafts", "Include draft content") { options.drafts = true }
          flag(parser, nil, "--open", "Open browser after starting server") { options.open_browser = true }
          flag(parser, "-v", "--verbose", "Show detailed output including generated files") { options.verbose = true }
        end

        def execute(options : Config::Options::ServeOptions, args : Array(String))
          Services::Server.new.run(options)
        end
      end
    end
  end
end
