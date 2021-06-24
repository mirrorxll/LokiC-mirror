# frozen_string_literal: true

class AddLastDistributedAtToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :distributed_at, :datetime, after: :name
  end
end
