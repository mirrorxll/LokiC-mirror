# frozen_string_literal: true

class AddTimestampsToArticleTypeIterations < ActiveRecord::Migration[6.0]
  def change
    change_table :article_type_iterations, &:timestamps
  end
end
