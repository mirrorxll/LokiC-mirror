# frozen_string_literal: true

class TableLocation < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :host
  belongs_to :schema
end

