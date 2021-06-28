# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :alert, polymorphic: true
  belongs_to :subtype, class_name: 'AlertSubtype'
  belongs_to :message, class_name: 'Text'
end
