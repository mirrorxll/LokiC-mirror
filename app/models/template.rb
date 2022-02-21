# frozen_sting_literal: true

class Template < ApplicationRecord
  belongs_to :templateable, polymorphic: true

  before_create do
    self.body = '<p>HEADLINE:</p><p><br></p><p>TEASER:</p><p><br></p><p>BODY:</p><p><br></p>'
  end

  before_save do
    regexp = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; '\
             'font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" '\
             'title="Froala Editor">Froala Editor</a></p>'

    self.body = body&.gsub(/#{Regexp.escape(regexp)}/, '')
  end

  joins_raw_sql = "INNER JOIN story_types ON templates.templateable_type = 'StoryType' AND templates.templateable_id ="\
                  ' story_types.id INNER JOIN statuses ON story_types.status_id = statuses.id'
  scope :alive,           -> { joins(joins_raw_sql).where.not('statuses.name': %w[archived canceled deleted done]) }
  scope :revision_needed, -> { alive.where.not(revision: nil).where('revision <= ?', Date.today + 1.week) }


  def expired_revision?
    revision.present? && revision < Date.today
  end
end
