# frozen_string_literal: true

module ApplicationHelper
  def tab_title
    @tab_title || 'LokiC'
  end

  def previous_week
    Week.where(begin: Date.today.beginning_of_week.last_week).first
  end

  def current_week
    Week.where(begin: Date.today.beginning_of_week).first
  end

  def correct_account?(record)
    if (current_account.types & ['manager']).any?
      true
    elsif record.respond_to?('developer')
      record.developer.eql?(current_account)
    elsif record.respond_to?('scraper')
      record.scraper.eql?(current_account)
    end
  end
end
