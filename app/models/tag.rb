# frozen_string_literal: true

class Tag < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__tags'
end
