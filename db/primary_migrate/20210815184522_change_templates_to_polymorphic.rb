# frozen_string_literal: true

class ChangeTemplatesToPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :templates, :story_type_id
    rename_column :templates, :story_type_id, :template_id
    add_column :templates, :template_type, :string, after: :id
    add_index :templates, %i[template_type template_id]

    Template.reset_column_information
    Template.update_all(template_type: 'StoryType')
  end
end
