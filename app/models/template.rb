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

  scope :with_soon_revision, -> { where(revised: true).where('revision <= ?', Date.today + 8.days) }
  scope :revision_needed,    -> { where.not(revision: nil).where('revision <= ?', Date.today + 7.days) }

  def expired_revision?
    revision.present? && revision < Date.today
  end
end
