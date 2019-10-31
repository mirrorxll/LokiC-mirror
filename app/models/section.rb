# frozen_string_literal: true

class Section < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__sections'
end
