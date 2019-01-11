class CreateNewspaperWorksDerivativeAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :newspaper_works_derivative_attachments do |t|
      t.string :fileset_id
      t.string :path
      t.string :destination_name

      t.timestamps
    end
    add_index :newspaper_works_derivative_attachments, :fileset_id
  end
end
