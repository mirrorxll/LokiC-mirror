# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_many :publications

  has_and_belongs_to_many :story_types
  has_and_belongs_to_many :sections
end
