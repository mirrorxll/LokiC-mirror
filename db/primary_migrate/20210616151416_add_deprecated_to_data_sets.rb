# frozen_string_literal: true

class AddDeprecatedToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sets, :deprecated, :boolean,
               default: false, after: :id
  end
end
