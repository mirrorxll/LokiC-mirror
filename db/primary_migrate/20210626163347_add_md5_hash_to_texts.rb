# frozen_string_literal: true

class AddMd5HashToTexts < ActiveRecord::Migration[6.0]
  def change
    add_column :texts, :md5hash, :string,
               after: :id, index: true
  end
end
