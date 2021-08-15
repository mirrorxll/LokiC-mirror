# frozen_string_literal: true

class ChangeFactCheckingDocsToPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :fact_checking_docs, :story_type_id
    rename_column :fact_checking_docs, :story_type_id, :fcd_id
    add_column :fact_checking_docs, :fcd_type, :string, after: :id
    add_index :fact_checking_docs, %i[fcd_type fcd_id]

    FactCheckingDoc.reset_column_information
    FactCheckingDoc.update_all(fcd_type: 'StoryType')
  end
end
