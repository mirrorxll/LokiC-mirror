# frozen_string_literal: true

class CreateOpportunitiesContentTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities_content_types, id: false, force: true do |t|
      t.string   :id, primary_key: true
      t.string   :opportunity_id, limit: 36
      t.string   :content_type_id, limit: 36
      t.datetime :archived_at, index: true
      t.timestamps
    end

    add_index :opportunities_content_types, %i[opportunity_id content_type_id], name: 'index_on_o__ct'
    add_index :opportunities_content_types, %i[content_type_id opportunity_id], name: 'index_on_ct__o'
  end
end
