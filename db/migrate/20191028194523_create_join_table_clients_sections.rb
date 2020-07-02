# frozen_string_literal: true

class CreateJoinTableClientsSections < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :clients, :sections do |t|
      t.index %i[client_id section_id], unique: true
    end
  end
end
