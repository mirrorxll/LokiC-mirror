# frozen_string_literal: true

class Text < ApplicationRecord
  belongs_to :text, polymorphic: true
end
