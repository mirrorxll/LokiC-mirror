class AddResponsibleEditorToDataSets < ActiveRecord::Migration[6.0]
  def change
    change_table :data_sets do |t|
      t.belongs_to :responsible_editor, after: :sheriff_id
    end
  end
end
