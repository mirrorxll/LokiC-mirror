# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :stories do |t|
      t.string  :type_name
      t.string  :headline
      t.string  :teaser, limit: 500
      t.text    :body, limit: 100_000
      t.string  :description, limit: 1000
      t.date    :desired_launch
      t.date    :last_launch
      t.date    :last_export
      t.date    :deadline
      t.string  :dev_status, default: 'Not Started'

      t.belongs_to :editor
      t.belongs_to :developer
      t.belongs_to :data_location

      t.timestamps
    end
  end
end
