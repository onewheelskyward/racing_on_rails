module Concerns
  module Category
    module FriendlyParam
      def Category.find_by_friendly_param(param)
        category_count = count_by_friendly_param(param)
        case category_count
        when 0
          nil
        when 1
          Category.first(:conditions => ['friendly_param = ?', param])
        else
          raise AmbiguousParamException, "#{category_count} occurrences of #{param}"
        end
      end

      def set_friendly_param
        self.friendly_param = to_friendly_param
      end

      # Lowercase underscore
      def to_friendly_param
        name.underscore.gsub('+', '_plus').gsub(/[^\w]+/, '_').gsub(/^_/, '').gsub(/_$/, '').gsub(/_+/, '_')
      end
    end

    class AmbiguousParamException < Exception
    end
  end
end
