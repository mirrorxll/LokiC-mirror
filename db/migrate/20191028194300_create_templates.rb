class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.belongs_to :story_type

      t.string :body, limit: 15_000, default: '<p>HEADLINE:</p><p><br></p><p>TEASER:</p><p><br></p><p>BODY:</p><p><br></p>'
      t.timestamps
    end
  end
end
