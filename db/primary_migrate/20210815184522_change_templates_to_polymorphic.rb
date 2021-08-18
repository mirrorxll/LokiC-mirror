# frozen_string_literal: true

class ChangeTemplatesToPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :templates, :story_type_id
    rename_column :templates, :story_type_id, :templateable_id
    add_column :templates, :templateable_type, :string, after: :id
    add_index :templates, %i[templateable_type templateable_id]

    Template.reset_column_information
    Template.update_all(templateable_type: 'StoryType')
  end
end
