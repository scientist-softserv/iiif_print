module IiifPrint
  class PendingRelationship < ApplicationRecord
    validates :parent_id, presence: true
    validates :child_title, presence: true
    validates :child_order, presence: true
  end
end
