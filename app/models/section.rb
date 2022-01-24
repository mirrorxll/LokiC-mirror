# frozen_string_literal: true

class Section < ApplicationRecord
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :st_cl_pub_tags,
                          class_name: 'StoryTypeClientPublicationTag',
                          join_table: 'story_type_client_sections'
end
