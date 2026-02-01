require "./command"
require "./commands/init_command"
require "./commands/build_command"
require "./commands/serve_command"
require "./commands/new_command"
require "./commands/deploy_command"
require "./commands/tool_command"
require "./commands/completion_command"
require "../utils/logger"

module Hwaro
  module CLI
    # Temporary adapter for transition
    class ProcCommand < Command
      getter name : String
      getter description : String

      def initialize(@name, @description, @proc : Proc(Array(String), Nil))
      end

      def run(args : Array(String)) : Nil
        @proc.call(args)
      end
    end

    # Command registry for dynamic command management
    # Allows plugins to register new commands at runtime
    class CommandRegistry
      @@commands = {} of String => Command

      # Register a command object
      def self.register(command : Command)
        @@commands[command.name] = command
      end

      # Register a command with its handler (Legacy support)
      def self.register(name : String, description : String, &handler : Array(String) -> Nil)
        register(ProcCommand.new(name, description, handler))
      end

      # Get a command by name
      def self.get(name : String) : Command?
        @@commands[name]?
      end

      # Check if a command exists
      def self.has?(name : String) : Bool
        @@commands.has_key?(name)
      end

      # Get all registered command names
      def self.names : Array(String)
        @@commands.keys.sort!
      end

      # Get command description
      def self.description(name : String) : String
        if cmd = get(name)
          cmd.description
        else
          ""
        end
      end

      # List all commands with descriptions
      def self.all : Array({name: String, description: String})
        names.map { |n| {name: n, description: description(n)} }
      end

      # Get all registered command objects
      def self.commands : Array(Command)
        @@commands.values
      end
    end

    class Runner
      def initialize
        # Register built-in commands
        register_default_commands
      end

      def run
        if ARGV.empty?
          print_help
          exit
        end

        command_name = ARGV.shift
        args = ARGV.dup

        case command_name
        when "version", "-v", "--version"
          Logger.info "hwaro version #{Hwaro::VERSION}"
        when "help", "-h", "--help"
          print_help
        else
          # Try to get command from registry
          if command = CommandRegistry.get(command_name)
            command.run(args)
          else
            Logger.error "Unknown command: #{command_name}"
            print_help
            exit(1)
          end
        end
      rescue ex : OptionParser::InvalidOption
        Logger.error "Error: #{ex.message}"
        exit(1)
      rescue ex : Exception
        Logger.error "Error: #{ex.message}"
        exit(1)
      end

      private def register_default_commands
        # Register init command
        CommandRegistry.register(Commands::InitCommand.new)

        # Register build command
        CommandRegistry.register(Commands::BuildCommand.new)

        # Register serve command
        CommandRegistry.register(Commands::ServeCommand.new)

        # Register new command
        CommandRegistry.register(Commands::NewCommand.new)

        # Register deploy command
        CommandRegistry.register(Commands::DeployCommand.new)

        # Register tool command
        CommandRegistry.register(Commands::ToolCommand.new)

        # Register completion command
        CommandRegistry.register(Commands::CompletionCommand.new)
      end

      private def print_help
        Logger.info "Usage: hwaro <command> [options]"
        Logger.info "Hwaro is a fast and lightweight static site generator written in Crystal."
        Logger.info ""
        Logger.info "Commands:"

        # Define priority order
        priority = ["init", "build", "serve", "new", "deploy"]

        # Print registered commands
        CommandRegistry.all.sort_by { |cmd|
          priority.index(cmd[:name]) || priority.size
        }.each do |cmd|
          Logger.info "  #{cmd[:name].ljust(8)} #{cmd[:description]}"
        end

        Logger.info "  version  Show version"
        Logger.info "  help     Show this help"
        Logger.info ""
        Logger.info "Run 'hwaro <command> --help' for more information on a command."
      end
    end
  end
end
