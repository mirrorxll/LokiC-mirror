# frozen_string_literal: true

module AccessLevels
  PERMISSIONS = {
    manager: {
      work_requests: {
        grid: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        archive: true,
        progress_status: true,
        billed_for_entire_project?: { show: true, edit: true },
        eta: { show: true, edit: true }
      },
      factoid_requests: {
        grid: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        progress_status: true,
        templates: true
      },
      multi_tasks: {
        grid: { assigned: true, your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        assistants_to: true,
        notifications_to: true,
        progress_status: true,
        comments: true,
        confirm_receipts: true,
        sub_tasks: { show: true, new: true }
      },
      scrape_tasks: {
        grid: { assigned: true, your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        progress_status: true,
        tags: { show: true, edit: true },
        instructions: true,
        evaluation_document: true
      },
      data_sets: {
        grid: { assigned: true, your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to_sheriff: true,
        assignment_to_responsible: true,
        table_locations: true
      },
      story_types: {
        grid: { assigned: true, your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        iterations: true,
        progress_status: true,
        comment: true,
        gather_task_id: true,
        template: true
      },
      factoid_types: {
        grid: { assigned: true, your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        iterations: true,
        progress_status: true,
        template: true
      }
    },

    user: {
      work_requests: {
        grid: { your: true, all: false, archived: false },
        new: true,
        edit: true,
        archive: false,
        progress_status: false,
        billed_for_entire_project?: { show: false, edit: false },
        eta: { show: false, edit: false }
      },
      factoid_requests: {
        grid: { your: true, all: false, archived: false },
        new: true,
        edit: true,
        progress_status: false,
        templates: true
      },
      multi_tasks: {
        grid: { assigned: true, your: true, all: false, archived: false },
        new: true,
        edit: true,
        assignment_to: true,
        assistants_to: true,
        notifications_to: true,
        progress_status: true,
        comments: true,
        confirm_receipts: true,
        sub_tasks: { show: true, new: true }
      },
      scrape_tasks: {
        grid: { assigned: true, your: false, all: false, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        progress_status: true,
        tags: { show: false, edit: false },
        instructions: false,
        evaluation_document: false
      },
      data_sets: {
        grid: { assigned: true, your: false, all: true, archived: false },
        new: true,
        edit: true,
        assignment_to_sheriff: true,
        assignment_to_responsible: true,
        table_locations: true
      },
      story_types: {
        grid: { assigned: true, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        iterations: true,
        progress_status: true,
        comment: false,
        gather_task_id: false,
        template: false
      },
      factoid_types: {
        grid: { assigned: true, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        iterations: true,
        progress_status: true,
        template: false
      }
    },

    guest: {
      work_requests: {
        grid: { your: false, all: true, archived: false },
        new: false,
        edit: false,
        archive: false,
        progress_status: false,
        billed_for_entire_project?: { show: false, edit: false },
        eta: { show: false, edit: false }
      },
      factoid_requests: {
        grid: { your: false, all: true, archived: false },
        new: false,
        edit: false,
        progress_status: false,
        templates: false
      },
      multi_tasks: {
        grid: { assigned: false, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        assistants_to: false,
        notifications_to: false,
        progress_status: false,
        comments: false,
        confirm_receipts: false,
        sub_tasks: { show: false, new: false }
      },
      scrape_tasks: {
        grid: { assigned: false, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        progress_status: false,
        tags: { show: false, edit: false },
        instructions: false,
        evaluation_document: false
      },
      data_sets: {
        grid: { assigned: false, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to_sheriff: false,
        assignment_to_responsible: false,
        table_locations: false
      },
      story_types: {
        grid: { assigned: false, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        iterations: false,
        progress_status: false,
        comment: false,
        gather_task_id: false,
        template: false
      },
      factoid_types: {
        grid: { assigned: false, your: false, all: true, archived: false },
        new: false,
        edit: false,
        assignment_to: false,
        iterations: false,
        progress_status: false,
        template: false
      }
    }
  }.deep_stringify_keys.freeze
end
