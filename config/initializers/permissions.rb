# frozen_string_literal: true

module AccessLevels
  PERMISSIONS = {
    manager: {
      work_requests: {
        list: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        archive: true,
        progress_status: true,
        billed_for_entire_project?: { show: { edit: true } },
        eta: { show: { edit: true } }
      },
      factoid_requests: {
        list: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        progress_status: true,
        templates: true
      },
      multi_tasks: {
        list: { your: true, all: true, assigned: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        assistants_to: true,
        notifications_to: true,
        progress_status: true,
        comments: true,
        confirm_receipts: true
      },
      scrape_tasks: {
        list: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        progress_status: true,
        tags: true,
        instructions: true,
        evaluation_document: true
      },
      data_sets: {
        list: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        table_locations: true
      },
      story_types: {
        list: { your: true, all: true, archived: true },
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
        list: { your: true, all: true, archived: true },
        new: true,
        edit: true,
        assignment_to: true,
        iterations: true,
        progress_status: true,
        template: true
      },
      accounts: {
        list: { active: true, deactivated: true },
        new: true,
        edit: true,
        impersonate: true,
        status: true,
        roles: true,
        branches: true
      }
    },


    user: {
      work_requests: {
        index: {
          list: { your: true, all: false, archived: false },
          new: true
        },
        show: {
          edit: true,
          archive: false,
          progress_status: true,
          billed_for_entire_project?: false,
          eta: false
        }
      },
      factoid_requests: {
        index: {
          list: { your: true, all: false, archived: false },
          new: true
        },
        show: {
          edit: true,
          progress_status: true,
          templates: { edit: true }
        }
      },
      multi_tasks: {
        index: {
          list: { your: true, all: false, assigned: true, archived: false },
          new: true
        },
        show: {
          edit: true,
          assignment_to: true,
          assistants_to: true,
          notifications_to: true,
          progress_status: true,
          comments: true,
          confirm_receipts: true,
          sub_tasks: false
        }
      },
      scrape_tasks: {
        index: {
          list: { your: true, all: true, archived: false },
          new: false
        },
        show: {
          edit: false,
          assignment_to: false,
          progress_status: true,
          tags: { edit: false },
          instructions: { edit: false },
          evaluation_document: { edit: false },
          data_sets: false
        }
      },
      data_sets: {
        index: {
          list: { your: true, all: true, archived: true },
          new: true
        },
        show: {
          table_locations: true,
          story_types: {
            new: true,
            assignment_to: true
          },
          factoid_types: {
            new: true,
            assignment_to: true
          },
          edit: true
        }
      },
      story_types: {
        index: {
          list: { your: true, all: true, archived: false },
          new: true
        },
        show: {
          edit: true,
          assignment_to: true,
          iterations: true,
          progress_status: true,
          comment: true,
          gather_task_id: true,
          template: true
        }
      },
      factoid_types: {
        index: {
          list: { your: true, all: true, archived: false },
          new: true
        },
        show: {
          assignment_to: true,
          iterations: true,
          progress_status: true,
          template: true
        }
      },
      accounts: {
        index: {
          list: { active: true, deactivated: false },
          new: false,
          impersonate: true
        },
        show: {
          edit: false,
          impersonate: true,
          status: false,
          roles: { edit: false },
          branches: { edit: false }
        }
      }
    },

    guest: {
      work_requests: {},
      factoid_requests: {},
      multi_tasks: {},
      scrape_tasks: {},
      data_sets: {},
      story_types: {},
      factoid_types: {},
      accounts: {}
    }
  }.with_indifferent_access.freeze
end
