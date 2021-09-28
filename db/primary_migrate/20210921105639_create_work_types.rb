# frozen_string_literal: true

class CreateWorkTypes < ActiveRecord::Migration[6.0]
  def up
    create_table :work_types do |t|
      t.integer :work, index: true
      t.string  :name
      t.boolean :hidden, default: true
      t.timestamps
    end

    database = Rails.configuration.database_configuration[Rails.env]['secondary']['database']
    names = ActiveRecord::Base.connection.exec_query("select name from #{database}.type_of_works;").to_a

    names.map { |t| t['name'] }.each { |name| WorkType.create!(work: 0, name: name) }
  end

  def down
    drop_table :work_types
  end
end
