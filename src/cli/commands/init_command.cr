require "../../cli/base_command"
require "../../config/options/init_options"
require "../../services/initializer"

module Hwaro
  module CLI
    module Commands
      class InitCommand < BaseCommand(Config::Options::InitOptions)
        def name : String
          "init"
        end

        def description : String
          "Initialize a new project"
        end

        def default_options : Config::Options::InitOptions
          Config::Options::InitOptions.new
        end

        def setup_flags(parser : OptionParser, options : Config::Options::InitOptions)
          parser.banner = "Usage: hwaro init [path] [options]"

          flag(parser, "-f", "--force", "Force creation even if directory is not empty") { options.force = true }

          flag(parser, nil, "--scaffold TYPE", "Scaffold type: simple, blog, docs (default: simple)") do |type|
            begin
              options.scaffold = Config::Options::ScaffoldType.from_string(type)
            rescue ex : ArgumentError
              Logger.error ex.message.not_nil!
              Logger.info "Available scaffolds:"
              Logger.info "  simple  - Basic pages structure with homepage and about page"
              Logger.info "  blog    - Blog-focused structure with posts, archives, and taxonomies"
              Logger.info "  docs    - Documentation-focused structure with organized sections and sidebar"
              exit(1)
            end
          end

          flag(parser, nil, "--skip-agents-md", "Skip creating AGENTS.md file") { options.skip_agents_md = true }
          flag(parser, nil, "--skip-sample-content", "Skip creating sample content files") { options.skip_sample_content = true }
          flag(parser, nil, "--skip-taxonomies", "Skip taxonomies configuration and templates") { options.skip_taxonomies = true }

          flag(parser, nil, "--include-multilingual LANGS", "Enable multilingual support (e.g., en,ko)") do |langs|
            options.multilingual_languages = langs.split(",").map(&.strip).reject(&.empty?)
          end
        end

        protected def setup_parser(parser : OptionParser, options : Config::Options::InitOptions)
          super
          parser.on("-h", "--help", "Show this help") do
            Logger.info parser.to_s
            Logger.info ""
            Logger.info "Available scaffolds:"
            Logger.info "  simple  - Basic pages structure with homepage and about page (default)"
            Logger.info "  blog    - Blog-focused structure with posts, archives, and taxonomies"
            Logger.info "  docs    - Documentation-focused structure with organized sections and sidebar"
            exit
          end
        end

        def execute(options : Config::Options::InitOptions, args : Array(String))
          if args.any?
            options.path = args.first
          end
          Services::Initializer.new.run(options)
        end
      end
    end
  end
end
