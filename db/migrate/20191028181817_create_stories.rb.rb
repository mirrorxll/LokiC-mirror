# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :stories do |t|
      t.string  :name,            default: 'New Story Type'
      t.string  :headline,        default: ''
      t.string  :body,            default: ''
      t.string  :description,     default: ''
      t.date    :desired_launch,  default: nil
      t.date    :last_launch,     default: nil
      t.date    :last_export,     default: nil
      t.date    :deadline,        default: nil
      t.string  :status,          default: 'Not Started'

      t.belongs_to :developer
      t.belongs_to :writer

      t.timestamps
    end
  end
end
