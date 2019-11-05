# frozen_string_literal: true

class Frequency < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__frequencies'
end
