# frozen_string_literal: true

class ChangeColumnBodyInComments < ActiveRecord::Migration[6.0]
  def up
    change_column :comments, :body, :text
  end

  def down
    change_column :comments, :body, :string, limit: 2000
  end
end
