# frozen_string_literal: true

class RenameBodyInChangeHistory < ActiveRecord::Migration[6.0]
  def change
    rename_column :change_history, :body, :note
  end
end
