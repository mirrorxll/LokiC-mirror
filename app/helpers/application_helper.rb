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
    if (current_account.types & ['manager', 'editor']).any?
      true
    elsif record.developer == current_account
      true
    else
      false
    end
  end
end
