# frozen_string_literal: true

class ScrapeInstruction < ApplicationRecord
  before_save do
    regexp = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; '\
             'font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" '\
             'title="Froala Editor">Froala Editor</a></p>'

    self.body = body&.gsub(/#{Regexp.escape(regexp)}/, '')
  end

  belongs_to :scrape_task
end
