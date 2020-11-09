# frozen_string_literal: true

class CreateLinkAssembleds < ActiveRecord::Migration[6.0]
  def change
    create_table :link_assembleds do |t|
      t.belongs_to :week
      t.string     :link
      t.boolean    :in_process, default: false
    end
  end
end
