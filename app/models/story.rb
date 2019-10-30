# frozen_string_literal: true

class Story < ApplicationRecord # :nodoc:
  belongs_to :developer,  class_name: 'User', optional: true
  belongs_to :writer,     class_name: 'User'

  has_one :template

  has_and_belongs_to_many :clients,         join_table: 'stories__clients'
  has_and_belongs_to_many :data_locations,  join_table: 'stories__data_locations'
  has_and_belongs_to_many :story_sections,  join_table: 'stories__story_sections'
  has_and_belongs_to_many :story_tags,      join_table: 'stories__story_tags'
  has_and_belongs_to_many :photo_buckets,   join_table: 'stories__photo_buckets'
end
