module IiifPrint
  class PendingRelationship < ApplicationRecord
    validates :parent_id, presence: true
    validates :child_title, presence: true
    validates :child_order, presence: true
    validates :parent_model, presence: true
    validates :child_model, presence: true
    validates :file_id, presence: true
  end
end
