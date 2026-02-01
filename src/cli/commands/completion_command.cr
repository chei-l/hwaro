require "../../cli/base_command"
require "../../cli/runner"

module Hwaro
  module CLI
    module Commands
      struct CompletionOptions; end

      class CompletionCommand < BaseCommand(CompletionOptions)
        def name : String
          "completion"
        end

        def description : String
          "Generate shell completion scripts"
        end

        def default_options : CompletionOptions
          CompletionOptions.new
        end

        def setup_flags(parser : OptionParser, options : CompletionOptions)
          parser.banner = "Usage: hwaro completion [shell]"
        end

        def execute(options : CompletionOptions, args : Array(String))
          if args.empty?
            Logger.error "Shell not specified. Supported shells: zsh, bash, fish"
            exit(1)
          end

          shell = args.first.downcase

          case shell
          when "zsh"
            generate_zsh
          when "bash"
            generate_bash
          when "fish"
            generate_fish
          else
            Logger.error "Unsupported shell: #{shell}"
            exit(1)
          end
        end

        private def generate_zsh
          puts "#compdef hwaro"
          puts
          puts "_hwaro() {"
          puts "  local context state state_descr line"
          puts "  typeset -A opt_args"
          puts
          puts "  _arguments -C \\"
          puts "    '1: :_hwaro_commands' \\"
          puts "    '*:: :->args'"
          puts
          puts "  case $state in"
          puts "    (args)"
          puts "      case $words[1] in"

          CommandRegistry.commands.sort_by(&:name).each do |cmd|
            puts "        (#{cmd.name})"
            puts "          _arguments \\"
            cmd.flags.each do |flag|
              desc = escape_zsh(flag.description)
              spec = ""

              if short = flag.short
                short_clean = short.sub(/^-/, "")
                long_clean = flag.long.split(" ").first
                spec += "{-#{short_clean},#{long_clean}}"
              else
                spec += flag.long.split(" ").first
              end

              spec += "[#{desc}]"

              if flag.has_arg
                spec += ":arg:"
              end

              puts "            '#{spec}' \\"
            end
            puts "            ;;"
          end

          puts "      esac"
          puts "      ;;"
          puts "  esac"
          puts "}"
          puts
          puts "_hwaro_commands() {"
          puts "  local -a commands"
          puts "  commands=("
          CommandRegistry.commands.sort_by(&:name).each do |cmd|
            puts "    '#{cmd.name}:#{escape_zsh(cmd.description)}'"
          end
          puts "  )"
          puts "  _describe 'command' commands"
          puts "}"
        end

        private def generate_bash
          puts "_hwaro_completion() {"
          puts "  local cur prev commands"
          puts "  cur=\"${COMP_WORDS[COMP_CWORD]}\""
          puts "  prev=\"${COMP_WORDS[COMP_CWORD-1]}\""
          puts "  commands=\"#{CommandRegistry.names.join(" ")}\""
          puts
          puts "  if [ $COMP_CWORD -eq 1 ]; then"
          puts "    COMPREPLY=( $(compgen -W \"$commands\" -- $cur) )"
          puts "    return 0"
          puts "  fi"
          puts
          puts "  case \"${COMP_WORDS[1]}\" in"

          CommandRegistry.commands.sort_by(&:name).each do |cmd|
            puts "    #{cmd.name})"
            flags_list = cmd.flags.map { |f|
              l = f.long.split(" ").first
              s = f.short
              s ? "#{l} #{s}" : l
            }.join(" ")
            puts "      COMPREPLY=( $(compgen -W \"#{flags_list}\" -- $cur) )"
            puts "      ;;"
          end

          puts "  esac"
          puts "}"
          puts "complete -F _hwaro_completion hwaro"
        end

        private def generate_fish
          puts "complete -c hwaro -f"

          all_commands = CommandRegistry.names.join(" ")

          CommandRegistry.commands.sort_by(&:name).each do |cmd|
            puts "complete -c hwaro -n \"not __fish_seen_subcommand_from #{all_commands}\" -a \"#{cmd.name}\" -d \"#{escape_fish(cmd.description)}\""

            cmd.flags.each do |flag|
              s_part = ""
              if short = flag.short
                s_part = "-s #{short.sub(/^-/, "")}"
              end

              l_clean = flag.long.sub(/^--/, "").split(" ").first
              l_part = "-l #{l_clean}"

              d_part = "-d \"#{escape_fish(flag.description)}\""

              puts "complete -c hwaro -n \"__fish_seen_subcommand_from #{cmd.name}\" #{s_part} #{l_part} #{d_part}"
            end
          end
        end

        private def escape_zsh(str : String) : String
          str.gsub("'", "'\\''").gsub("[", "\\[").gsub("]", "\\]")
        end

        private def escape_fish(str : String) : String
          str.gsub("\"", "\\\"")
        end
      end
    end
  end
end
