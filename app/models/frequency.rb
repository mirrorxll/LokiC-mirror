# frozen_string_literal: true

class Frequency < ApplicationRecord
  def self.regular
    Frequency.where.not(name: 'manual input')
  end
end
