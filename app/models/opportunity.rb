# frozen_string_literal: true

class Opportunity < ApplicationRecord
  belongs_to :agency, optional: true

  has_many :opportunity_content_types, -> { where(archived_at: nil) }
  has_many :content_types, through: :opportunity_content_types

  has_many :opportunity_opportunity_types, -> { where(archived_at: nil) }
  has_many :opportunity_types, through: :opportunity_opportunity_types
end
