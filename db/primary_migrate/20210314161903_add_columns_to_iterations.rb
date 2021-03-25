# frozen_string_literal: true

class AddColumnsToIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :iterations, :kill_population, :boolean,
               default: false, after: :removing_from_pl
    add_column :iterations, :kill_story_samples, :boolean,
               default: false, after: :kill_population
    add_column :iterations, :kill_creation, :boolean,
               default: false, after: :kill_story_samples
    add_column :iterations, :kill_schedule, :boolean,
               default: false, after: :kill_creation
    add_column :iterations, :kill_export, :boolean,
               default: false, after: :kill_schedule
    add_column :iterations, :kill_removing_from_pl, :boolean,
               default: false, after: :kill_export
  end
end
