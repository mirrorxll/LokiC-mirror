# frozen_string_literal: true

class ContentType < ApplicationRecord
  has_and_belongs_to_many :opportunities
end
