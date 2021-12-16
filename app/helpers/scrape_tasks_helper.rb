# frozen_string_literal: true

module ScrapeTasksHelper
  def multi_tasks_to_options(model)
    attached_tasks = model.pluck(:task_id).to_a.compact

    Task.where.not(id: attached_tasks).where(parent_task_id: nil).map do |task|
      parent = Task.where(id: task.id)
      list = (parent + task.subtasks)

      [task.title, list.map { |tag| ["#{tag.id} -- #{tag.title}", tag.id] }]
    end
  end
end
