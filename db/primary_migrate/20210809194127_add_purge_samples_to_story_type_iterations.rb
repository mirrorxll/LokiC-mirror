# frozen_string_literal: true

class AddPurgeSamplesToStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :story_type_iterations, :purge_samples, :boolean, after: :sample_args
  end
end
