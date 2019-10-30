# frozen_string_literal: true

class StoryTag < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__story_tags'
end
