require "../../cli/base_command"
require "../../config/options/build_options"
require "../../core/build/builder"
require "../../content/hooks"
require "../../utils/logger"

module Hwaro
  module CLI
    module Commands
      class BuildCommand < BaseCommand(Config::Options::BuildOptions)
        def name : String
          "build"
        end

        def description : String
          "Build the project"
        end

        def default_options : Config::Options::BuildOptions
          Config::Options::BuildOptions.new
        end

        def setup_flags(parser : OptionParser, options : Config::Options::BuildOptions)
          parser.banner = "Usage: hwaro build [options]"

          flag(parser, "-o DIR", "--output-dir DIR", "Output directory (default: public)") { |dir| options.output_dir = dir }
          flag(parser, nil, "--base-url URL", "Override base_url from config.toml") { |url| options.base_url = url }
          flag(parser, "-d", "--drafts", "Include draft content") { options.drafts = true }
          flag(parser, nil, "--minify", "Minify HTML output (and minified json, xml)") { options.minify = true }
          flag(parser, nil, "--no-parallel", "Disable parallel file processing") { options.parallel = false }
          flag(parser, nil, "--cache", "Enable build caching (skip unchanged files)") { options.cache = true }
          flag(parser, nil, "--skip-highlighting", "Disable syntax highlighting") { options.highlight = false }
          flag(parser, "-v", "--verbose", "Show detailed output including generated files") { options.verbose = true }
          flag(parser, nil, "--profile", "Show build timing profile for each phase") { options.profile = true }
        end

        def execute(options : Config::Options::BuildOptions, args : Array(String))
          builder = Core::Build::Builder.new

          # Set logger level based on verbose option
          if options.verbose
            Logger.level = Logger::Level::Debug
          end

          # Register content hooks with lifecycle
          Content::Hooks.all.each do |hookable|
            builder.register(hookable)
          end

          builder.run(options)
        end
      end
    end
  end
end
