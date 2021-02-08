module StatusesHelper
  def status_color(name)
    case name
    when 'not started'
      'secondary text-white'
    when 'in progress'
      'primary text-white'
    when 'exported'
      'dark text-white'
    when 'on cron'
      'warning'
    when 'blocked'
      'danger text-white'
    end
  end
end
