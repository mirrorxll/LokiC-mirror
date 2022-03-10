# frozen_string_literal: true

class CreateJoinTableClientsPublications < ActiveRecord::Migration[6.0]
  def change
    create_table :clients_opportunities do |t|
      t.bigint :client_id
      t.string :opportunity_id, limit: 36
      t.timestamps
    end

    add_index :clients_opportunities, %i[client_id opportunity_id], unique: true
  end
end
