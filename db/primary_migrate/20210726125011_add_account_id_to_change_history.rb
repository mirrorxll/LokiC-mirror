# frozen_string_literal: true

class AddAccountIdToChangeHistory < ActiveRecord::Migration[6.0]
  def change
    add_reference :change_history, :account, after: :body
  end
end
