# frozen_string_literal: true

module Api
  module V1
    module MultiTasks
      class MainController < MultiTasksController
        def index
          render json: (Task.all.map do |multi_task|
            assigned_to = []
            assigned = multi_task.main_assignee
            assistants = multi_task.assistants
            informed = multi_task.notification_to

            if assigned
              assigned_to << {
                employee: assigned.name,
                role: 'assigned',
                status: multi_task.status.name
              }
            end

            assistants.each do |a|
              task_assistant = multi_task.task_assistants.find_by(account: a)

              assigned_to << {
                employee: a.name,
                role: 'assistant',
                status: task_assistant.done? ? 'done' : multi_task.status.name
              }
            end

            informed.each do |i|
              assigned_to << {
                employee: i.name,
                role: 'informed',
                status: multi_task.status.name
              }
            end

            {
              number: multi_task.id,
              created_by: multi_task.creator.name,
              assigned_to: assigned_to,
              name: multi_task.title,
              opportunities: multi_task.agency_opportunity_revenue_types.map { |o| o.opportunity&.name }.compact,
              deadline: multi_task.deadline,
              main_task_id: multi_task.parent&.id,
              created_at: multi_task.created_at.utc
            }
          end)
        end
      end
    end
  end
end
