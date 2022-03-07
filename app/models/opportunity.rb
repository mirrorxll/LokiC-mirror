# frozen_string_literal: true

class Opportunity < ApplicationRecord
  belongs_to :agency

  has_many :opportunity_content_types
  has_many :content_types, through: :opportunity_content_types

  has_many :opportunity_opportunity_types
  has_many :opportunity_types, through: :opportunity_opportunity_types
end
