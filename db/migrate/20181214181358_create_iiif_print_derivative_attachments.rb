class CreateIiifPrintDerivativeAttachments < ActiveRecord::Migration[5.0]
  def change
    unless table_exists?(:iiif_print_derivative_attachments)
      create_table :iiif_print_derivative_attachments do |t|
        t.string :fileset_id
        t.string :path
        t.string :destination_name

        t.timestamps
      end
      add_index :iiif_print_derivative_attachments, :fileset_id
    end
  end
end
