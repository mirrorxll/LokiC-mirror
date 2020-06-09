# frozen_string_literal: true

class Publication < ApplicationRecord # :nodoc:
  belongs_to :client

  has_and_belongs_to_many :tags
end
