class CreateJoinTablePublicationTag < ActiveRecord::Migration[5.2]
  def change
    create_join_table :publications, :tags do |t|
      t.index %i[publication_id tag_id], unique: true
    end
  end
end
