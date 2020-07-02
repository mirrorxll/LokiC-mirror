module StatusesHelper
  def status_color(name)
    case name
    when 'not started'
      'secondary'
    when 'in progress'
      'primary'
    when 'exported'
      'dark'
    when 'on cron'
      'warning'
    when 'blocked'
      'danger'
    end
  end
end
