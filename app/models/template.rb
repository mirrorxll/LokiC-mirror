# frozen_sting_literal: true

class Template < ApplicationRecord
  belongs_to :templateable, polymorphic: true
  # belongs_to :story_type, -> { where('templates.templateable_type': 'StoryType') }, foreign_key: :templateable_id

  before_create do
    self.body = '<p>HEADLINE:</p><p><br></p><p>TEASER:</p><p><br></p><p>BODY:</p><p><br></p>'
  end

  before_save do
    regexp = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; '\
             'font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" '\
             'title="Froala Editor">Froala Editor</a></p>'

    self.body = body&.gsub(/#{Regexp.escape(regexp)}/, '')
  end

  # scope :alive, -> { joins(story_type: :status).where.not('statuses.name': ['canceled', 'deleted', 'done', 'archived']) }
  scope :revision_needed, -> { alive.where.not(revision: nil).where('revision <= ?', Date.today + 1.week) }
  scope :type_of, -> (type) { where(templateable_type: type) }
  scope :alive, -> { type_of('StoryType') }


  def expired_revision?
    revision.present? && revision < Date.today
  end
end
