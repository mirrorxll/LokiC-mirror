# frozen_string_literal: true

class CreateDataSamples < ActiveRecord::Migration[6.0]
  def change
    create_table :data_samples do |t|
      t.belongs_to :scrape_task

      t.string :local_file
      t.string :remote_url
      t.timestamps
    end
  end
end
