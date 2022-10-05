# frozen_string_literal: true

class CreateHleFileArticleTypeBlobs < ActiveRecord::Migration[6.0]
  def change
    return if Table.exists?('hle_file_article_type_blobs')

    create_table :hle_file_article_type_blobs do |t|
      t.belongs_to :article_type

      t.binary :file_blob, limit: 10.megabyte
      add_index :hle_file_article_type_blobs, :article_type_id, name: :hle_file_article_type_blobs_article_type_id_uindex, unique: true
    end
  end
end
