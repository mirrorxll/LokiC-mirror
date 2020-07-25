# frozen_string_literal: true

class ExportConfiguration < ApplicationRecord # :nodoc:
  belongs_to :story_type
  belongs_to :publication,  optional: true
  belongs_to :tag,          optional: true

  has_many :samples

  validates_uniqueness_of :publication_id, scope: [:story_type_id]

  def skipped?
    skipped
  end

  def self.update_tags(params = {})
    return if params.empty?

    params.each do |exp_cfg_id, tag|
      find(exp_cfg_id).update(
        skipped: tag[:skip],
        tag_id: tag[:tag_id]
      )
    end
  end
end
