# frozen_string_literal: true

class AddStatusToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_reference :data_sets, :status, after: :id
  end
end
