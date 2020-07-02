# fronzen_string_literal: true

class CreateOutput < ActiveRecord::Migration[6.0]
  def change
    create_table :outputs do |t|
      t.string  :headline, limit: 300
      t.string  :teaser,   limit: 500
      t.text    :body,     limit: 2.megabytes - 1
    end
  end
end
