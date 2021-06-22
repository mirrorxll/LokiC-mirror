# frozen_string_literal: true

class ChangeHistory < ApplicationRecord
  belongs_to :historyable, polymorphic: true
end
