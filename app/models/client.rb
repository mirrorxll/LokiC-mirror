# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :story_types, join_table: 'story_types__clients'

  has_many :projects
end
