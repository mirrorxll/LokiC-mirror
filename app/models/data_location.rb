# frozen_string_literal: true

class DataLocation < ApplicationRecord # :nodoc:
  has_many :stories

  belongs_to :user
end
