# frozen_string_literal: true

class ChangeHistory < ApplicationRecord
  belongs_to :history, polymorphic: true
  belongs_to :account, optional: true
end
