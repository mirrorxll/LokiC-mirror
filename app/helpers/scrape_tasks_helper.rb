# frozen_string_literal: true

module ScrapeTasksHelper
  def multi_tasks_to_options
    MultiTask.where(parent_task_id: nil).map do |task|
      parent = MultiTask.where(id: task.id)
      list = (parent + task.subtasks)

      [task.title, list.map { |tag| ["##{tag.id} #{tag.title}", tag.id] }]
    end
  end
end
