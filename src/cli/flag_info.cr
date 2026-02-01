module Hwaro
  module CLI
    struct FlagInfo
      getter short : String?
      getter long : String
      getter description : String
      getter has_arg : Bool

      def initialize(@short, @long, @description, @has_arg)
      end
    end
  end
end
