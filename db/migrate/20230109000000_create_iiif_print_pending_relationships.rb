class CreateIiifPrintPendingRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :iiif_print_pending_relationships do |t|
      t.string :child_title, null: false
      t.string :parent_id, null: false
      t.string :order, null: false
      t.timestamps
    end
    add_index :iiif_print_pending_relationships, :parent_id
  end
end
