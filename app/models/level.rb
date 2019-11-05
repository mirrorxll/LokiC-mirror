# frozen_string_literal: true

class Level < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__levels'
end
