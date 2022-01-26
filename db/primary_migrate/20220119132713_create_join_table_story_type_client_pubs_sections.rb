# frozen_string_literal: true

class CreateJoinTableStoryTypeClientPubsSections < ActiveRecord::Migration[6.0]
  def change
    create_join_table :story_type_client_publication_tags, :sections, table_name: 'story_type_client_sections' do |t|
      t.index %i[story_type_client_publication_tag_id section_id], unique: true, name: 'st_cl_pub_tags__sections_uniq_index'
    end
  end
end
