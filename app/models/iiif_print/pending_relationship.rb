module IiifPrint
  class PendingRelationship < ApplicationRecord
    validates :parent_id, presence: true
    validates :child_title, presence: true
    validates :order, presence: true
  end
end