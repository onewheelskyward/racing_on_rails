module Concerns
  module Audit
    extend ActiveSupport::Concern
    
    included do
      before_save :set_updated_by
    end

    module InstanceMethods
      def created_by
        versions.first.try(:user)
      end

      def updated_by
        p "Audit#updated_by"
        versions.last.try(:user)
      end

      def set_updated_by
        @updated_by = @updated_by || Person.current
        true
      end

      def created_from_result?
        !created_by.nil? && created_by.kind_of?(::Event)
      end
      
      def updated_after_created?
        created_at && updated_at && ((updated_at - created_at) > 1.hour)
      end
    end
  end
end
