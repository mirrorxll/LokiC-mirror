# frozen_string_literal: true

class ExportConfiguration < ApplicationRecord # :nodoc:
  belongs_to :story_type
  belongs_to :publication,  optional: true
  belongs_to :tag,          optional: true

  has_many :samples

  validates_uniqueness_of :publication_id, scope: [:story_type_id]
end
