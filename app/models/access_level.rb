# frozen_string_literal: true

class AccessLevel < ApplicationRecord
  belongs_to :branch

  has_many :account_cards

  validates_uniqueness_of :branch_id, scope: :name, case_sensitive: true

  def guest?
    name.eql?('guest')
  end
end
