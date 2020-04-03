# frozen_string_literal: true

class Section < ApplicationRecord
  has_and_belongs_to_many :clients
end