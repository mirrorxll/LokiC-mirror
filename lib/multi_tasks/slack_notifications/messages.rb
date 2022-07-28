# frozen_string_literal: true

module MultiTasks
  module SlackNotifications
    module Messages
      module_function

      def created(task, account_name)
        pt_url = task.pivotal_tracker_url
        pt_name = task.pivotal_tracker_name

        "*[ LokiC ] | #{account_name} |* The task <#{generate_task_url(task)}|#{task.title}> created. "\
        "#{pt_url.blank? ? '' : "This task corresponds to the Pivotal Tracker task <#{pt_url}|#{pt_name.blank? ? 'click' : pt_name}>. "}"\
        "#{task.deadline.blank? ? "": "ETA for this task: *#{task.deadline}*."}"
      end

      def changed_status(task, account_name)
        pt_url = task.pivotal_tracker_url
        pt_name = task.pivotal_tracker_name

        "*[ LokiC ] | #{account_name} |* The task <#{generate_task_url(task)}|#{task.title}> status has been moved to *#{task.status.name}*. "\
        "#{pt_url.blank? ? '' : "This task corresponds to the Pivotal Tracker task <#{pt_url}|#{pt_name.blank? ? 'click' : pt_name}>. "}"\
        "#{task.deadline.blank? ? "": "ETA for this task: *#{task.deadline}*."}"
      end

      def subtask_created(task, account_name)
        pt_url = task.pivotal_tracker_url
        pt_name = task.pivotal_tracker_name

        "*[ LokiC ] | #{account_name} |* A subtask <#{generate_task_url(task)}|#{task.title}> has been created for the task <#{generate_task_url(task.parent)}|#{task.parent.title}>. "\
        "#{pt_url.blank? ? '' : "This subtask corresponds to the Pivotal Tracker task <#{pt_url}|#{pt_name.blank? ? 'click' : pt_name}>. "}"\
        "#{task.deadline.blank? ? "": "ETA for this subtask: *#{task.deadline}*."}"
      end

      def subtask_changed_status(task, account_name)
        pt_url = task.parent.pivotal_tracker_url
        pt_name = task.parent.pivotal_tracker_name

        puts pt_url
        "*[ LokiC ] | #{account_name} |* A subtask has been updated for the task <#{generate_task_url(task.parent)}|#{task.parent.title}>. "\
        "The subtask is <#{generate_task_url(task)}|#{task.title}>, and it's status has changed to *#{task.status.name}*. "\
        "#{pt_url.blank? ? '' : "This task corresponds to the Pivotal Tracker task <#{pt_url}|#{pt_name.blank? ? 'click' : pt_name}>. "}"\
        "#{task.deadline.blank? ? "": "ETA for this task: *#{task.deadline}*."}"
      end

      def generate_task_url(task)
        host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
        "#{host}#{Rails.application.routes.url_helpers.multi_task_path(task)}"
      end

    end
  end
end
