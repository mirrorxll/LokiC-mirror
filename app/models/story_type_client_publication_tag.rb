# frozen_string_literal: true

class StoryTypeClientPublicationTag < ApplicationRecord
  before_create :set_default_sections
  before_destroy { sections.clear }

  belongs_to :story_type
  belongs_to :client,      optional: true
  belongs_to :tag,         optional: true
  belongs_to :publication, optional: true

  has_and_belongs_to_many :sections, join_table: 'story_type_client_sections'

  private

  def set_default_sections
    client.sections.each { |cl_section| sections << cl_section }
  end
end
