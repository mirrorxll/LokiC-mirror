# frozen_string_literal: true

class ChangeHistory < ApplicationRecord
  belongs_to :history, polymorphic: true
end
