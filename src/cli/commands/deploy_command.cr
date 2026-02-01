require "../../cli/base_command"
require "../../config/options/deploy_options"
require "../../models/config"
require "../../services/deployer"
require "../../utils/logger"

module Hwaro
  module CLI
    module Commands
      class DeployCommand < BaseCommand(Config::Options::DeployOptions)
        @list_targets = false

        def name : String
          "deploy"
        end

        def description : String
          "Deploy the built site using config.toml"
        end

        def default_options : Config::Options::DeployOptions
          @list_targets = false
          Config::Options::DeployOptions.new
        end

        def setup_flags(parser : OptionParser, options : Config::Options::DeployOptions)
          parser.banner = "Usage: hwaro deploy [options] [target ...]"

          flag(parser, "-s DIR", "--source DIR", "Source directory to deploy (default: deployment.source_dir or public)") { |dir| options.source_dir = dir }
          flag(parser, nil, "--dry-run", "Show planned changes without writing") { options.dry_run = true }
          flag(parser, nil, "--confirm", "Ask for confirmation before deploying") { options.confirm = true }
          flag(parser, nil, "--force", "Force upload/copy (ignore file comparisons)") { options.force = true }
          flag(parser, nil, "--max-deletes N", "Maximum number of deletes (default: deployment.maxDeletes or 256, -1 disables)") { |n| options.max_deletes = n.to_i }
          flag(parser, nil, "--list-targets", "List configured deployment targets and exit") { @list_targets = true }
        end

        def execute(options : Config::Options::DeployOptions, args : Array(String))
          if @list_targets
            print_targets
            return
          end

          # Handle args as targets
          options.targets = args

          ok = Services::Deployer.new.run(options)
          exit(1) unless ok
        end

        private def print_targets
          config = Models::Config.load
          deployment = config.deployment
          if deployment.targets.empty?
            Logger.info "No deployment targets configured."
            return
          end

          Logger.info "Deployment targets:"
          deployment.targets.each do |t|
            url = t.url.empty? ? "(no url)" : t.url
            extra = t.command ? " (command)" : ""
            Logger.info "  #{t.name.ljust(16)} #{url}#{extra}"
          end
        end
      end
    end
  end
end
