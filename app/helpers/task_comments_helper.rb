# frozen_string_literal: true

module TaskCommentsHelper
  def accounts_for_assignment
    if @multi_task.parent
      (@multi_task.assignment_to.to_a + [@multi_task.creator] + @multi_task.parent.assignment_to.to_a).uniq.map { |account| [account.first_name.to_s + ' ' + account.last_name.to_s, account.id] }
    else
      (@multi_task.assignment_to.to_a + [@multi_task.creator]).uniq.map { |account| [account.first_name.to_s + ' ' + account.last_name.to_s, account.id] }
    end
  end
end
