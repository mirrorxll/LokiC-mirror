# frozen_string_literal: true

module DevelopersProductionsHelper # :nodoc:
  def weeks(begin_date)
    begin_week = begin_date - (begin_date.wday - 1)
    Week.where(begin: begin_week .. Date.today)
  end

  def date_month_ago
    Date.today.prev_month
  end

end
