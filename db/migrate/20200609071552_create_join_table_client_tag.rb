# frozen_string_literal: true

class CreateJoinTableClientTag < ActiveRecord::Migration[6.0]
  def change
    create_join_table :clients, :tags do |t|
      t.index %i[client_id tag_id], unique: true
    end
  end
end
