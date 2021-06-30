# frozen_string_literal: true

class ChangeHistory < ApplicationRecord
  belongs_to :history, polymorphic: true
  belongs_to :history_event
  belongs_to :note, class_name: 'Text'
end
