# frozen_string_literal: true

class Story < ApplicationRecord # :nodoc:
  has_rich_text :headline
  has_rich_text :body
  has_rich_text :description

  belongs_to :writer,     class_name: 'User'
  belongs_to :developer,  class_name: 'User', optional: true

  has_and_belongs_to_many :clients,         join_table: 'stories__clients'
  has_and_belongs_to_many :data_locations,  join_table: 'stories__data_locations'
  has_and_belongs_to_many :sections,        join_table: 'stories__sections'
  has_and_belongs_to_many :tags,            join_table: 'stories__tags'
  has_and_belongs_to_many :photo_buckets,   join_table: 'stories__photo_buckets'
end
