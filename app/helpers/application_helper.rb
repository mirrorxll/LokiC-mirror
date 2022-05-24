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
    toast_code = lambda do |type, title, message|
      <<~SCRIPT
        <script>
          toastr.#{type}(`#{message}`, `#{title}`, {
            showMethod: 'slideDown',
            hideMethod: 'slideUp',
            closeMethod: 'slideUp',
            closeDuration: 300,
            timeOut: #{type.eql?('success') ? 5000 : 0},
            extendedTimeOut: #{type.eql?('success') ? 5000 : 0},
            closeButton: true,
            tapToDismiss: false
          });
        </script>
      SCRIPT
    end

    toasts = flash.each_with_object([]) do |(type, notifications), flash_messages|
      notifications.each do |group, message|
        title = group.to_s.humanize.upcase

        if message.is_a?(Array)
          message.each { |msg| flash_messages << toast_code.call(type.to_s, title, msg) }
        else
          flash_messages << toast_code.call(type.to_s, title, message)
        end
      end
    end

    toasts.join("\n").html_safe
  end
end
