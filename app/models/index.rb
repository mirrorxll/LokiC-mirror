# frozen_string_literal: true

class Index < ApplicationRecord
  serialize :list, Hash

  belongs_to :staging_table
end
