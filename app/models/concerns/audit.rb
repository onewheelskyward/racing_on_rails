module Concerns
  module Audit
    extend ActiveSupport::Concern
    
    included do
      before_create :set_created_by, :set_updated_by
      before_save :set_updated_by

      belongs_to :created_by, :polymorphic => true
      belongs_to :updated_by, :polymorphic => true
    end

    module InstanceMethods
      def set_updated_by
        if !updated_by_id_changed? && Person.current
          self.updated_by = Person.current
        end
        true
      end
      
      def set_created_by
        if created_by.nil? && Person.current
          self.created_by = Person.current
        end
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
