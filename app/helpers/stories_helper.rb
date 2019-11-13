# frozen_string_literal: true

module StoriesHelper # :nodoc:
  def statuses
    ['Not Started', 'In Progress', 'Exported', 'On Cron', 'Blocked']
  end

  def select_statuses?
    action_name.eql?('show')
  end

  def onchange_submit?
    action_name.eql?('show') ? { onchange: 'this.submit();' } : {}
  end
end
