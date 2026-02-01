require "./flag_info"

module Hwaro
  module CLI
    abstract class Command
      abstract def name : String
      abstract def description : String
      abstract def run(args : Array(String))

      # For completion
      def flags : Array(FlagInfo)
        [] of FlagInfo
      end
    end
  end
end
