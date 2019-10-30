# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :stories do |t|
      t.string  :name,            default: ''
      t.string  :description,     default: ''
      t.string  :frequency,       default: ''
      t.string  :level,           default: ''
      t.date    :desired_launch,  default: nil
      t.date    :last_launch,     default: nil
      t.date    :last_export,     default: nil
      t.date    :deadline,        default: nil
      t.boolean :status,          default: true
      t.string  :staging_table,   default: ''
      t.boolean :blocked,         default: false

      t.belongs_to :developer
      t.belongs_to :writer

      t.timestamps
    end
  end
end
