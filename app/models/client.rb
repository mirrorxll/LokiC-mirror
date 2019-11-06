# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__clients'

  has_many :projects
end
