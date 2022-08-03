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

  def toastr_js_flash(to_flash = {})
    toast_code = lambda do |type, title, message|
      <<~SCRIPT
        ;
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
      SCRIPT
    end

    toasts = (to_flash.present? ? to_flash : flash).each_with_object([]) do |(type, notifications), flashes|
      notifications.each do |attr, message|
        title = attr.to_s.humanize.upcase

        if message.is_a?(Array)
          message.each { |msg| flashes << toast_code.call(type.to_s, title, msg) }
        else
          flashes << toast_code.call(type.to_s, title, message)
        end
      end
    end

    toasts.join("\n").html_safe
  end

  def current_account_permissions(branch_name, accesses = [])
    permissions = instance_variable_get("@#{branch_name}_permissions")

    if permissions
      access = true
      accesses.each_with_index { |a, i| access = i.zero? ? permissions[a] : access[a] }

      access
    else
      false
    end
  end
end
