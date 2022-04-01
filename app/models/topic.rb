# frozen_string_literal: true

class Topic < ApplicationRecord
  KIND_TYPES = %i[Person Organization Geo].freeze

  enum kind: KIND_TYPES
end
