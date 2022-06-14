# frozen_string_literal: true

module AccessLevels
  PERMISSIONS = {
    manager: {
      work_requests: {
        index: {
          list: { your: true, all: true, archived: true },
          create: true
        },
        show: {
          edit: true,
          archive: true,
          progress_status: true,
          billed_for_entire_project?: true,
          eta: true
        }
      },
      factoid_requests: {
        index: {
          list: { your: true, all: true, archived: true },
          create: true
        },
        show: {
          edit: true,
          progress_status: true,
          templates: { edit: true }
        }
      },
      multi_tasks: {
        index: {
          list: { your: true, all: true, assigned: true, archived: true },
          create: true
        },
        show: {
          edit: true,
          assignment_to: true,
          assistants_to: true,
          notifications_to: true,
          progress_status: true,
          comments: true,
          confirm_receipts: true,
          sub_tasks: { create: true }
        }
      },
      scrape_tasks: {
        index: {
          list: { your: true, all: true, archived: true },
          create: true
        },
        show: {
          edit: true,
          assignment_to: true,
          progress_status: true,
          tags: { edit: true },
          instructions: { edit: true },
          evaluation_document: { edit: true },
          data_sets: { create: true }
        }
      },
      data_sets: {
        index: {
          list: { your: true, all: true, archived: true },
          create: true
        },
        show: {
          table_locations: true,
          story_types: {
            create: true,
            assignment_to: true
          },
          factoid_types: {
            create: true,
            assignment_to: true
          },
          edit: true
        }
      },
      story_types: {
        index: {
          list: { your: true, all: true, archived: true },
          create: true
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
          list: { your: true, all: true, archived: true },
          create: true
        },
        show: {
          edit: true,
          assignment_to: true,
          iterations: true,
          progress_status: true,
          template: true
        }
      },
      accounts: {
        index: {
          list: { active: true, deactivated: true },
          create: true,
          impersonate: true
        },
        show: {
          edit: true,
          impersonate: true,
          status: true,
          roles: { edit: true },
          branches: { edit: true }
        }
      }
    },


    user: {
      work_requests: {
        index: {
          list: { your: true, all: false, archived: false },
          create: true
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
          create: true
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
          create: true
        },
        show: {
          assignment_to: true,
          assistants_to: true,
          notifications_to: true,
          progress_status: true,
          comments: true,
          confirm_receipts: true,
          sub_tasks: true,
          edit: true
        }
      },
      scrape_tasks: {
        index: {
          list: { your: true, all: true, archived: false },
          create: false
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
          create: true
        },
        show: {
          table_locations: true,
          story_types: {
            create: true,
            assignment_to: true
          },
          factoid_types: {
            create: true,
            assignment_to: true
          },
          edit: true
        }
      },
      story_types: {
        index: {
          list: { your: true, all: true, archived: false },
          create: true
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
          create: true
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
          create: false,
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
      work_requests: { read_only: true },
      factoid_requests: { read_only: true },
      multi_tasks: { read_only: true },
      scrape_tasks: { read_only: true },
      data_sets: { read_only: true },
      story_types: { read_only: true },
      factoid_types: { read_only: true },
      accounts: { read_only: true }
    }
  }.with_indifferent_access.freeze
end
