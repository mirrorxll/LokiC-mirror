# frozen_string_literal: true

class Schema < ApplicationRecord
  belongs_to :host

  has_many :table_locations
end
