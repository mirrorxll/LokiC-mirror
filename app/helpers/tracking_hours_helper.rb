module TrackingHoursHelper
  def weeks
    Week.where(begin: Date.today - 2.month .. Date.today).last(5)
  end
end
