# frozen_string_literal: true

class CreateOpportunitiesPublications < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities_publications, id: false do |t|
      t.string   :id, limit: 36, primary_key: true
      t.string   :opportunity_id, limit: 36
      t.bigint   :publication_id
      t.datetime :archived_at, index: true
      t.timestamps
    end

    add_index :opportunities_publications, %i[opportunity_id publication_id], name: 'index_on_o__p'
    add_index :opportunities_publications, %i[publication_id opportunity_id], name: 'index_on_p__o'
  end
end
