# frozen_string_literal: true

class CreateTypesOfWork < ActiveRecord::Migration[6.0]
  def up
    create_table :types_of_work do |t|
      t.integer :work, index: true
      t.string  :name
      t.timestamps
    end

    database = Rails.configuration.database_configuration[Rails.env]['secondary']['database']
    names = ActiveRecord::Base.connection.exec_query("select name from #{database}.type_of_works;").to_a

    names.map { |t| t['name'] }.each { |name| TypeOfWork.create!(work: 0, name: name) }
  end

  def down
    drop_table :types_of_work
  end
end
