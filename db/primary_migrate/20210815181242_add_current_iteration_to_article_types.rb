# frozen_string_literal: true

class AddCurrentIterationToArticleTypes < ActiveRecord::Migration[6.0]
  def change
    change_table :article_types do |t|
      t.belongs_to :current_iteration, after: :status_id
    end
  end
end
