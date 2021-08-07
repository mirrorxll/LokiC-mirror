# frozen_string_literal: true

class AddColumnToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types,
               :staging_table_attached,
               :boolean,
               after: :last_export

    StoryType.all.each do |st|
      next if st.staging_table.blank?

      st.update!(staging_table_attached: true)
    end
  end
end
