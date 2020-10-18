module ApplicationHelper
  def tab_title
    @tab_title || 'LokiC'
  end

  def previous_week
    Week.where(end: Date.today.end_of_week - 7).first
  end
end
