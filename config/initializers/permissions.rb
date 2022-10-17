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
        progress_status: { show: true, edit_form: true },
        assignment_to: { show: true, edit_form: true },
        assistants: { show: true, edit_form: true },
        notification_to: { show: true, edit_form: true },
        comments: { show: true, new_form: true, edit_form: true, delete: true },
        notes: { show: true, new_form: true, edit_form: true },
        sub_tasks: { show: true, new_form: true }
      },
      scrape_tasks: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        scraper: { show: true, edit_form: true },
        tags: { show: true, edit_form: true },
        multi_tasks: { show: true, edit_form: true },
        data_sets: { show: true, edit_form: true },
        table_locations: { show: true, edit_form: true },
        git_links: { show: true, edit_form: true },
        conversation: { show: true, post_messages: true, edit_messages: true },
        instructions: { show: true, edit_form: true },
        evaluation_document: { show: true, edit_form: true }
      },
      data_sets: {
        grid: { assigned: true, responsible: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        status: { show: true, edit_form: true},
        sheriff: { show: true, edit_form: true },
        responsible_editor: { show: true, edit_form: true },
        scrape_tasks: { show: true, edit_form: true},
        table_locations: { show: true, edit_form: true },
        story_types: true,
        factoid_types: true
      },
      story_types: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true },
        template: { show: true, edit_form: true },
        editor: { show: true, edit_form: true },
        developer: { show: true, edit_form: true },
        comment: { show: true, edit_form: true }
      },
      factoid_types: {
        grid: { assigned: true, created: true, all: true, archived: true },
        new_form: true,
        edit_form: true,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true },
        template: { show: true, edit_form: true },
        editor: { show: true, edit_form: true },
        developer: { show: true, edit_form: true },
        comment: { show: true, edit_form: true }
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
        grid: { assigned: true, created: true, all: true, archived: false },
        new_form: true,
        edit_form: true,
        progress_status: { show: true, edit_form: true },
        assignment_to: { show: true, edit_form: true },
        assistants: { show: true, edit_form: true },
        notification_to: { show: true, edit_form: true },
        comments: { show: true, new_form: true, edit_form: true, delete: true },
        notes: { show: true, new_form: true, edit_form: true },
        sub_tasks: { show: true, new_form: true }
      },
      scrape_tasks: {
        grid: { assigned: true, created: false, all: false, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: true },
        scraper: { show: true, edit_form: false },
        tags: { show: true, edit_form: false },
        multi_tasks: { show: true, edit_form: false },
        data_sets: { show: true, edit_form: false },
        table_locations: { show: true, edit_form: true },
        git_links: { show: true, edit_form: false },
        conversation: { show: true, post_messages: true, edit_messages: true },
        instructions: { show: true, edit_form: false },
        evaluation_document: { show: true, edit_form: false }
      },
      data_sets: {
        grid: { assigned: true, responsible: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        status: { show: true, edit_form: true},
        sheriff: { show: true, edit_form: false },
        responsible_editor: { show: true, edit_form: false },
        scrape_tasks: { show: true, edit_form: false },
        table_locations: { show: true, edit_form: false },
        story_types: true,
        factoid_types: true
      },
      story_types: {
        grid: { assigned: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true },
        template: { show: true, edit_form: false },
        editor: { show: true, edit_form: false },
        developer: { show: true, edit_form: false },
        comment: { show: true, edit_form: false }
      },
      factoid_types: {
        grid: { assigned: true, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        iterations: { show: true, new_form: true, edit_form: true },
        progress_status: { show: true, edit_form: true },
        template: { show: true, edit_form: false },
        editor: { show: true, edit_form: false },
        developer: { show: true, edit_form: false },
        comment: { show: true, edit_form: false }
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
        grid: { created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        templates: { show: true, edit_form: false }
      },
      multi_tasks: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        assignment_to: { show: true, edit_form: false },
        assistants: { show: true, edit_form: false },
        notification_to: { show: true, edit_form: false },
        comments: { show: true, new_form: false, edit_form: false, delete: false },
        notes: { show: true, new_form: true, edit_form: true },
        sub_tasks: { show: true, new_form: false }
      },
      scrape_tasks: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        progress_status: { show: true, edit_form: false },
        scraper: { show: true, edit_form: false },
        tags: { show: true, edit_form: false },
        multi_tasks: { show: true, edit_form: false },
        data_sets: { show: true, edit_form: false },
        table_locations: { show: true, edit_form: false },
        git_links: { show: true, edit_form: false },
        conversation: { show: true, post_messages: false, edit_messages: false },
        instructions: { show: true, edit_form: false },
        evaluation_document: { show: true, edit_form: false }
      },
      data_sets: {
        grid: { assigned: false, responsible: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        status: { show: true, edit_form: true },
        sheriff: { show: true, edit_form: false },
        responsible_editor: { show: true, edit_form: false },
        scrape_tasks: { show: true, edit_form: false },
        table_locations: { show: true, edit_form: false },
        story_types: true,
        factoid_types: true
      },
      story_types: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        iterations: { show: true, new_form: false, edit_form: false },
        progress_status: { show: true, edit_form: false },
        template: { show: true, edit_form: false },
        editor: { show: true, edit_form: false },
        developer: { show: true, edit_form: false },
        comment: { show: true, edit_form: false }
      },
      factoid_types: {
        grid: { assigned: false, created: false, all: true, archived: false },
        new_form: false,
        edit_form: false,
        iterations: { show: true, new_form: false, edit_form: false },
        progress_status: { show: true, edit_form: false },
        template: { show: true, edit_form: false },
        editor: { show: true, edit_form: false },
        developer: { show: true, edit_form: false },
        comment: { show: true, edit_form: false }
      }
    }
  }.deep_stringify_keys.freeze
end
