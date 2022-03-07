# frozen_string_literal: true

class CreateOpportunitiesPublications < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities_publications do |t|
      t.bigint :opportunity_id
      t.bigint :publication_id
    end

    add_index :opportunities_publications, %i[opportunity_id publication_id], name: 'index_on_o__p'
    add_index :opportunities_publications, %i[publication_id opportunity_id], name: 'index_on_p__o'
  end
end
