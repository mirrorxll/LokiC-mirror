# frozen_string_literal: true

class CreateHleFileBlobs < ActiveRecord::Migration[6.0]
  def change
    return if Table.exists?('hle_file_blobs')

    create_table :hle_file_blobs do |t|
      t.belongs_to :story_type
      t.binary :file_blob, limit: 10.megabyte
    end

    add_index :hle_file_blobs, :story_type_id, name: :hle_file_blobs_story_type_id_uindex, unique: true
  end
end
