class CreateJoinTableStoryStoryTag < ActiveRecord::Migration[6.0]
  def change
    create_join_table :stories, :story_tags, table_name: 'stories__story_tags' do |t|
      # t.index [:story_id, :story_tag_id]
      # t.index [:story_tag_id, :story_id]
    end
  end
end
