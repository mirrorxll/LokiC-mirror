# frozen_string_literal: true

class CreateStoryTypeOpportunities < ActiveRecord::Migration[6.0]
  def change
    create_table :story_type_opportunities do |t|
      t.belongs_to :story_type
      t.belongs_to :client
      t.belongs_to :publication

      t.string :opportunity_id,      limit: 36, index: true
      t.string :opportunity_type_id, limit: 36
      t.string :content_type_id,     limit: 36

      t.boolean :exist, default: true
      t.timestamps
    end
  end
end
