# frozen_string_literal: true

class Status < ApplicationRecord
  has_and_belongs_to_many :iterations
end
