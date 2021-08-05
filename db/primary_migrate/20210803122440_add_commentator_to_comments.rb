# frozen_string_literal: true

class AddCommentatorToComments < ActiveRecord::Migration[6.0]
  def change
    add_reference :comments, :commentator, class_name: 'Account', after: :body
  end
end
