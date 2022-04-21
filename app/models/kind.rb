# frozen_string_literal: true

class Kind < ApplicationRecord
  belongs_to :parent_kind, class_name: 'Kind', optional: true
  has_many :sub_kinds, class_name: 'Kind', foreign_key: 'parent_kind_id'
  has_and_belongs_to_many :topics

  scope :parent_kinds, -> { where(parent_kind_id: nil) }
  scope :sub_kinds,    -> { where.not(parent_kind_id: nil) }
end
