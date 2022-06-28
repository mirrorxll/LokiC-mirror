# frozen_string_literal: true

module AccessLevels
  PERMISSIONS = {
    manager: {
      work_requests: {
        grid: { created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        billed_for_entire_project: { show: true, edit_form: true },
        eta: { show: true, edit_form: true }
      },
      factoid_requests: {
        grid: { created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        templates: { show: true, edit_form: true }
      },
      multi_tasks: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        assignment_to_form: true,
        assistants_form: true,
        notifications_to_form: true,
        progress_status: { show: true, edit_form: true },
        comments: { show: true, new_form: true, edit_form: true, delete: true },
        notes: { show: true, new_form: true },
        sub_tasks: { show: true, new_form: true }
      },
      scrape_tasks: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        tags: { show: true, edit_form: true },
        assignment_to_form: true,
        instructions: { show: true, edit_form: true },
        evaluation_document: { show: true, edit_form: true }
      },
      data_sets: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        assignment_to_sheriff_form: true,
        assignment_to_responsible_form: true,
        table_locations: { show: true, edit_form: true }
      },
      story_types: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        assignment_to_form: true,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true }
      },
      factoid_types: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        assignment_to_form: true,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true }
      }
    },

    user: {
      work_requests: {
        grid: { created: true, all: false, archived: false },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        billed_for_entire_project: { show: false, edit_form: false },
        eta: { show: false, edit_form: false }
      },
      factoid_requests: {
        grid: { created: true, all: false, archived: false },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        templates: { show: true, edit_form: true }
      },
      multi_tasks: {
        grid: { assigned: true, created: true, all: false, archived: false },
        new_form: true,
        edit_form: true,
        assignment_to_form: true,
        assistants_form: true,
        notifications_to_form: true,
        progress_status: { show: true, edit_form: true },
        comments: { show: true, new_form: true, edit_form: true, delete: true },
        notes: { show: true, new_form: true },
        sub_tasks: { show: true, new_form: true }
      },
      scrape_tasks: {
        grid: { assigned: true, created: false, all: false, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: true },
        tags: { show: false, edit_form: false },
        assignment_to_form: false,
        instructions: { show: true, edit_form: false },
        evaluation_document: { show: true, edit_form: false }
      },
      data_sets: {
        grid: { assigned: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_sheriff_form: false,
        assignment_to_responsible_form: false,
        table_locations: { show: true, edit_form: true }
      },
      story_types: {
        grid: { assigned: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_form: false,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true }
      },
      factoid_types: {
        grid: { assigned: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_form: false,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true }
      }
    },

    guest: {
      work_requests: {
        grid: { created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        billed_for_entire_project: { show: false, edit_form: false },
        eta: { show: false, edit_form: false }
      },
      factoid_requests: {
        grid: { created: false, all: false, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        templates: { show: true, edit_form: false }
      },
      multi_tasks: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_form: false,
        assistants_form: false,
        notifications_to_form: false,
        progress_status: { show: true, edit_form: false },
        comments: { show: true, new_form: false, edit_form: false, delete: false },
        notes: { show: true, new_form: false },
        sub_tasks: { show: true, new_form: false }
      },
      scrape_tasks: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        tags: { show: false, edit_form: false },
        assignment_to_form: false,
        instructions: { show: true, edit_form: false },
        evaluation_document: { show: true, edit_form: false }
      },
      data_sets: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_sheriff_form: false,
        assignment_to_responsible_form: false,
        table_locations: { show: true, edit_form: false }
      },
      story_types: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_form: false,
        iterations: { show: true, new_form: false, edit_form: false },
        progress_status: { show: true, edit_form: false }
      },
      factoid_types: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        assignment_to_form: false,
        iterations: { show: true, new_form: false, edit_form: false },
        progress_status: { show: true, edit_form: false }
      }
    }
  }.deep_stringify_keys.freeze
end
