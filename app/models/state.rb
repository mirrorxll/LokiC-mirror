# frozen_string_literal: true

class State < ApplicationRecord
  has_many :data_sets

  def name
    "#{full_name} (#{short_name})"
  end
end
