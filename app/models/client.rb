# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories

  has_many :communities
end
