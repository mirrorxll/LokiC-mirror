# frozen_string_literal: true

class TimeFrame < ApplicationRecord
  has_many :samples
end
