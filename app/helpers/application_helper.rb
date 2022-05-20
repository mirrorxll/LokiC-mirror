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

  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = 'warning' if type.include?('task_notification')
      text = '<script>' \
                "toastr.#{type}('#{message}', 'Unconfirmed task notification', " \
                                "{ showMethod: 'slideDown', hideMethod: 'slideUp', closeMethod: 'slideUp', " \
                                'timeOut: 0, extendedTimeOut: 0, closeButton: true, tapToDismiss: false }) ' \
             '</script>'
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end
end
