# frozen_string_literal: true

module TaskCommentsHelper
  def accounts_for_assignment
    if @task.parent
      (@task.assignment_to.to_a + [@task.creator] + @task.parent.assignment_to.to_a).uniq.map { |account| [account.first_name.to_s + ' ' + account.last_name.to_s, account.id] }
    else
      (@task.assignment_to.to_a + [@task.creator]).uniq.map { |account| [account.first_name.to_s + ' ' + account.last_name.to_s, account.id] }
    end
  end
end
