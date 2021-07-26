# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :alert, polymorphic: true
end
