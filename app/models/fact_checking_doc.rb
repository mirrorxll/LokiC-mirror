# frozen_string_literal: true

class FactCheckingDoc < ApplicationRecord
  before_save :drop_negative_margins

  belongs_to :fcdable, polymorphic: true

  has_many :reviewers_feedback
  has_many :editors_feedback

  before_save do
    regexp = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; '\
             'font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" '\
             'title="Froala Editor">Froala Editor</a></p>'

    self.body = body&.gsub(/#{Regexp.escape(regexp)}/, '')
  end

  def approval_editors
    editors_feedback.where(approvable: true).uniq(&:editor).map(&:editor)
  end

  private

  def drop_negative_margins
    body&.gsub!(/margin[-a-z:]+[^;]*-\d+[^;]*;/, '')
  end
end
