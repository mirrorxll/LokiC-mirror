class CreateExceptedPublications < ActiveRecord::Migration[6.0]
  def change
    create_table :excepted_publications do |t|
      t.belongs_to :story_type
      t.belongs_to :client
      t.belongs_to :publication
      t.timestamps
    end
  end
end
