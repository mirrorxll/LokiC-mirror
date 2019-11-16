class CreateSummernoteUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :summernote_uploads do |t|

      t.timestamps
    end
  end
end
