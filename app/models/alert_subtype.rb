# frozen_string_literal: true

class AlertSubtype < ApplicationRecord
  has_many :alerts
end
