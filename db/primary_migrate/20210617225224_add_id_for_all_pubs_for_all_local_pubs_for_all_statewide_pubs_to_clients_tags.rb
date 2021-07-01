# frozen_string_literal: true

class AddIdForAllPubsForAllLocalPubsForAllStatewidePubsToClientsTags < ActiveRecord::Migration[6.0]
  def change
    add_column :clients_tags, :id, :primary_key, first: true
    add_column :clients_tags, :for_all_pubs, :boolean
    add_column :clients_tags, :for_local_pubs, :boolean
    add_column :clients_tags, :for_statewide_pubs, :boolean
  end
end
