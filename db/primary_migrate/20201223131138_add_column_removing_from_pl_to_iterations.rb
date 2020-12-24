# frozen_string_literal: true

class AddColumnRemovingFromPlToIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :iterations,
               :removing_from_pl,
               :boolean,
               default: false, after: :export
  end
end
