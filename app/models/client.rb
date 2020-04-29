# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  # The author depends on the client.
  # For different clients, samples from
  # different authors are published.
  belongs_to :author

  has_many :publications

  has_and_belongs_to_many :story_types
  has_and_belongs_to_many :sections
end
