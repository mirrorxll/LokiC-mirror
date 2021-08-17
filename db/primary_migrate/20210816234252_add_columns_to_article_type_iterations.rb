# frozen_string_literal: true

class AddColumnsToArticleTypeIterations < ActiveRecord::Migration[6.0]
  def change
    change_table :article_type_iterations do |t|
      t.string  :population_args, after: :population
      t.boolean :purge_population, after: :population_args
      t.string  :sample_args, limit: 1_000, after: :samples
      t.boolean :purge_samples, after: :sample_args
      t.boolean :purge_creation, after: :creation
    end
  end
end
