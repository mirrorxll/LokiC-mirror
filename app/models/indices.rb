# frozen_string_literal: true

class Indices < ApplicationRecord
  serialize :list, Hash

  belongs_to :staging_table
end
