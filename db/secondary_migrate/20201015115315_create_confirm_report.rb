# frozen_string_literal: true

class CreateConfirmReport < ActiveRecord::Migration[6.0]
  def change
    create_table :confirm_reports do |t|
      t.belongs_to :week
      t.belongs_to :developer
    end
  end
end
