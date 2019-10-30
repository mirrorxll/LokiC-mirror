# frozen_string_literal: true

class DataLocation < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories
end
