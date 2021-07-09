# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :alert, polymorphic: true
  belongs_to :alert_subtype, foreign_key: :subtype_id
  belongs_to :note
end
