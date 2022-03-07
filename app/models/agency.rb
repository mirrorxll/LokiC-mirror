# frozen_string_literal: true

class Agency < ApplicationRecord # :nodoc:
  has_many :opportunities
end
