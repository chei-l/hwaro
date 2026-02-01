require "option_parser"
require "../../cli/base_command"
require "./tool/convert_command"
require "./tool/list_command"
require "./tool/check_command"
require "../../utils/logger"

module Hwaro
  module CLI
    module Commands
      struct ToolOptions; end

      class ToolCommand < BaseCommand(ToolOptions)
        SUBCOMMANDS = {
          "convert" => "Convert frontmatter format (YAML <-> TOML)",
          "list"    => "List content files (all, drafts, published)",
          "check"   => "Check for dead links in content files",
        }

        def name : String
          "tool"
        end

        def description : String
          "Utility tools (convert, etc.)"
        end

        def default_options : ToolOptions
          ToolOptions.new
        end

        def setup_flags(parser : OptionParser, options : ToolOptions)
          parser.banner = "Usage: hwaro tool <subcommand> [options]"
        end

        protected def setup_parser(parser : OptionParser, options : ToolOptions)
          super
          parser.separator ""
          parser.separator "Available subcommands:"
          SUBCOMMANDS.each do |name, desc|
            parser.separator "  #{name.ljust(10)} #{desc}"
          end
          parser.separator ""
          parser.separator "Run 'hwaro tool <subcommand> --help' for more information on a subcommand."
        end

        def execute(options : ToolOptions, args : Array(String))
          if args.empty?
            print_help
            exit(1)
          end

          subcommand = args.shift

          case subcommand
          when "convert"
            Tool::ConvertCommand.new.run(args)
          when "list"
            Tool::ListCommand.new.run(args)
          when "check"
            Tool::CheckCommand.new.run(args)
          when "-h", "--help", "help"
            print_help
          else
            Logger.error "Unknown subcommand: #{subcommand}"
            print_help
            exit(1)
          end
        end

        private def print_help
          Logger.info "Usage: hwaro tool <subcommand> [options]"
          Logger.info ""
          Logger.info "Available subcommands:"
          SUBCOMMANDS.each do |name, description|
            Logger.info "  #{name.ljust(10)} #{description}"
          end
          Logger.info ""
          Logger.info "Run 'hwaro tool <subcommand> --help' for more information on a subcommand."
        end
      end
    end
  end
end
