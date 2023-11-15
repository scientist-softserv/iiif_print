class AddModelDetailsToIiifPrintPendingRelationships < ActiveRecord::Migration[5.2]
  def change
    add_column :iiif_print_pending_relationships, :parent_model, :string
    add_column :iiif_print_pending_relationships, :child_model, :string
    add_column :iiif_print_pending_relationships, :file_id, :string
  end
end
