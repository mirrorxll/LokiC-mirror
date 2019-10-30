# frozen_string_literal: true

class Story < ApplicationRecord # :nodoc:
  belongs_to :developer,  class_name: 'User', optional: true
  belongs_to :writer,     class_name: 'User'

  has_one :template

  has_and_belongs_to_many :clients
  has_and_belongs_to_many :data_locations
  has_and_belongs_to_many :story_sections
  has_and_belongs_to_many :story_tags
end
