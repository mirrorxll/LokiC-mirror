# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root 'root#index'

  mount ActionCable.server, at: '/cable'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Sidekiq::Web => '/sidekiq'

  # create/destroy user session
  get    'sign_in',  to: 'authenticates/sessions#new'
  post   'sign_in',  to: 'authenticates/sessions#create'
  delete 'sign_out', to: 'authenticates/sessions#destroy'

  # reset user password
  get   'send_password_reset_email', to: 'authenticates/passwords#new'
  post  'send_password_reset_email', to: 'authenticates/passwords#create'
  get   'password_reset',            to: 'authenticates/passwords#edit'
  patch 'password_reset',            to: 'authenticates/passwords#update'

  # edit user profile
  get   'profile', to: 'authenticates/registrations#edit'
  patch 'profile', to: 'authenticates/registrations#update'

  resources :accounts do
    scope module: :accounts do
      resources :roles, only: %i[index new create update]
      resources :access_levels, only: %i[index new create update]

      resource :impersonate, only: %i[create destroy]
    end
  end

  namespace :api, constraints: { format: :json } do
    resources :work_requests, only: :update

    scope module: :story_types, path: 'story_types/:story_type_id' do
      resources :template, only: :update
    end

    scope module: :work_requests, path: 'work_requests', as: 'work_request_collections' do
      resources :clients, only: [] do
        get :find_by_name, on: :collection, path: 'bla_bla_bla'
      end
    end

    scope module: :factoid_requests, path: 'factoid_requests', as: 'factoid_request' do
      resources :opportunities, only: :index
    end

    scope module: :work_requests, path: 'work_requests/:id', as: 'work_request_members' do
      resources :project_statuses, only: [] do
        get :all_deleted, on: :collection
      end
    end

    resources :clients, only: :index do
      resources :publications, only: :index do
        resources :publication_tags, path: :tags, as: :tags, only: :index
      end

      resources :client_tags, path: :tags, as: :tags, only: :index
    end

    resources :main_opportunities, only: :index do
      resources :main_opportunity_revenue_types, path: :revenue_types, as: :revenue_types, only: :index
    end

    resources :main_agencies, only: :index do
      resources :main_agency_opportunities, path: :opportunities, as: :opportunities, only: :index
    end

    resources :scrape_tasks, only: [] do
      get :names, on: :collection
      get :data_set_locations, on: :collection
    end

    resources :schemas, only: :index
    resources :table_locations, only: %i[index create destroy]
    resources :data_samples, only: :show

    scope module: :scrape_tasks, path: 'scrape_tasks/:scrape_task_id', as: 'scrape_tasks' do
      resources :tasks, only: %i[create destroy]
    end

    resources :tasks, only: [] do
      get :titles, on: :collection
      get :subtasks, on: :member
    end

    scope module: :tasks, path: 'tasks/:task_id', as: 'tasks' do
      resources :statuses, only: :update
    end

    resources :shown_samples, only: :update

    get 'publication_scopes', to: 'publications#scopes'
    get 'all_publications_scope_id', to: 'publications#all_pubs_scope_id'
    get 'all_local_publications_scope_id', to: 'publications#all_local_pubs_scope_id'
    get 'all_statewide_publications_scope_id', to: 'publications#all_statewide_pubs_scope_id'
  end

  scope module: :work_requests do
    resources :work_requests, controller: :main, except: :destroy do
      resource :archive, only: :update
      resource :progress_status, only: :update
      resource :sow_cell, only: :update
    end
  end

  scope module: :factoid_requests do
    resources :factoid_requests, controller: :main, except: :destroy do
      resource :progress_status, only: :update
    end
  end

  resources :tasks do
    get  :add_subtask,    on: :collection
    get  :new_subtask,    on: :collection
    post :create_subtask, on: :collection

    resources :progress_statuses, controller: 'task_statuses', only: [] do
      patch :change, on: :collection
      post  :comment, on: :collection
      patch :subtasks,      on: :collection
    end

    resources :checklists, controller: 'task_checklists', only: %i[new create edit update] do
      patch :confirm,   on: :member
    end

    resources :receipts, controller: 'task_receipts', only: :index do
      patch :confirm,   on: :collection
    end

    resources :comments, controller: 'task_comments', only: %i[new create edit update destroy]

    resources :assignments, controller: 'task_assignments', only: [] do
      get   :edit,   on: :collection
      patch :update, on: :collection
      get   :cancel, on: :collection
    end

    resources :notes, controller: 'task_notes', only: %i[new create edit update] do
      get :cancel_edit, on: :member
    end
  end
  resources :task_tracking_hours, controller: 'task_tracking_hours', only: :index

  resources :scrape_tasks, except: :destroy do
    patch :evaluate

    scope module: 'scrape_tasks' do
      resources :progress_statuses, only: [] do
        patch :change, on: :collection
      end

      resource :instruction, only: %i[edit update] do
        get   :cancel_edit
        patch :autosave
      end

      resource :evaluation_doc, only: %i[edit update] do
        get   :cancel_edit
        patch :autosave
      end

      resources :tags, only: [] do
        post :include, on: :collection
        delete :exclude
      end

      resources :tasks, only: :new
    end
  end
  resources :data_sets, except: %i[new] do
    get :properties, on: :member

    resources :story_types, only: %i[new create]
    resources :article_types, only: %i[new create]
  end

  resources :table_locations, only: :new
  resources :data_samples, only: %i[index]

  resources :article_types, except: %i[new create] do
    get   :properties_form
    get   :canceling_rename,  on: :member
    patch :update_sections,   on: :member
    patch :change_data_set,   on: :member

    scope module: :article_types do
      resources :templates, path: :template, only: %i[show edit update] do
        patch :save, on: :member
      end

      resources :progress_statuses, only: [] do
        patch :change, on: :collection
      end

      resources :frequencies, path: :frequency, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :developers, only: [] do
        patch   :include, on: :collection
        delete  :exclude, on: :member
      end

      resources :staging_tables, only: %i[show create destroy] do
        post    :attach,         on: :collection
        patch   :sync,           on: :member
        get     :canceling_edit, on: :collection

        resources :columns, controller: :staging_table_columns, only: %i[edit update]
        resources :indices, controller: :staging_table_indices, only: %i[new create destroy]
      end

      resources :codes, only: [] do
        get    :show,   on: :collection
        post   :attach, on: :collection
        put    :reload, on: :collection
      end

      resources :fact_checking_docs do
        get   :template
        post  :send_to_reviewers_channel
        patch :save, on: :member

        resources :reviewers_feedback, only: %i[new create] do
          patch :confirm, on: :member
        end

        resources :editors_feedback, only: %i[new create] do
          patch :confirm, on: :member
        end
      end

      resources :iterations, only: %i[create update] do
        patch :apply, on: :member

        resources :populations, path: :populate, only: [] do
          post   :execute, on: :collection
          delete :purge,   on: :collection
        end

        resources :samples, only: %i[index show] do
          post   :generate, on: :collection
          delete :purge,    on: :collection
        end

        resources :articles, only: :index

        resources :creations, only: [] do
          post   :execute, on: :collection
          delete :purge,   on: :collection
        end

        resources :exports, path: :export, only: [] do
          post   :execute,                  on: :collection
          delete :remove_exported_articles, on: :collection
          get    :articles,                 on: :collection
        end
      end

      resources :topics, only: [] do
        patch :change,           on: :member
        get   :get_descriptions, on: :collection
      end
    end
  end
  resources :story_types, except: %i[new create] do
    get   :properties_form
    get   :canceling_edit,  on: :member
    patch :update_sections, on: :member
    patch :change_data_set, on: :member

    scope module: :story_types do
      resources :templates, path: :template, only: %i[show edit update] do
        patch :save, on: :member
      end

      resources :clients, only: [] do
        post    :include, on: :collection
        delete  :exclude, on: :member

        resources :publications, only: [] do
          post   :include, on: :collection
          delete :exclude, on: :member
        end

        resources :tags, only: [] do
          post   :include, on: :collection
          delete :exclude, on: :member
        end

        resources :sections, only: %i[create destroy]
      end

      resources :excepted_publications, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :default_opportunities do
        patch :set, on: :collection
      end

      resources :opportunities

      resources :progress_statuses, only: [] do
        patch :change, on: :collection
      end

      resources :levels, path: :level, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :frequencies, path: :frequency, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :photo_buckets, path: :photo_bucket, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :developers, only: [] do
        patch   :include, on: :collection
        delete  :exclude, on: :member
      end

      resources :staging_tables, only: %i[show create destroy] do
        post    :attach,         on: :collection
        patch   :sync,           on: :member
        get     :canceling_edit, on: :collection

        resources :columns, controller: :staging_table_columns, only: %i[edit update]
        resources :indices, controller: :staging_table_indices, only: %i[new create destroy]
      end

      resources :codes, only: [] do
        get    :show,   on: :collection
        post   :attach, on: :collection
        put    :reload, on: :collection
      end

      resources :export_configurations, only: :create do
        patch :update_tags, on: :collection
      end

      resources :fact_checking_docs do
        get   :template
        post  :send_to_reviewers_channel
        patch :save, on: :member

        resources :reviewers_feedback, only: %i[new create] do
          patch :confirm, on: :member
        end

        resources :editors_feedback, only: %i[new create] do
          patch :confirm, on: :member
        end
      end

      resources :cron_tabs, only: %i[edit update]

      resources :iterations, controller: :iterations, only: %i[create update] do
        patch :apply, on: :member
        delete :purge, on: :member

        resources :populations, controller: :populations, path: :populate, only: [] do
          post   :execute, on: :collection
          delete :purge,   on: :collection
        end

        resources :samples, only: %i[index show] do
          post   :create_and_gen_auto_feedback, on: :collection
          delete :purge_sampled, on: :collection
        end

        resources :auto_feedback_confirmations, only: [] do
          patch :confirm, on: :member
        end

        resources :creations, only: [] do
          post   :execute,   on: :collection
          delete :purge, on: :collection
        end

        resources :schedules, path: :schedule, only: [] do
          post  :manual,    on: :collection
          post  :backdate,  on: :collection
          post  :auto,      on: :collection
          patch :purge,     on: :collection
          get   :show_form, on: :collection
        end

        resources :exports, path: :export, only: [] do
          post   :execute,                 on: :collection
          delete :remove_exported_stories, on: :collection
          get    :stories,                 on: :collection
        end

        resources :exported_story_types, only: [] do
          get  :show_editor_report,    on: :collection
          get  :show_manager_report,   on: :collection
          post :submit_editor_report,  on: :collection
          post :submit_manager_report, on: :collection
        end
      end

      resource :reminder, only: [] do
        patch :confirm
        patch :disprove
        patch :turn_off
      end

      post '/sidekiq_breaks', to: 'sidekiq_breaks#cancel'
    end
  end
  resources :shown_samples,        controller: 'story_types/shown_samples',        only: :index
  resources :exported_story_types, controller: 'story_types/exported_story_types', only: :index
  resources :archived_story_types, controller: 'story_types/archived_story_types', only: :index
  resources :production_removals,  only: :index

  resources :developers_productions, only: [] do
    get :scores,          on: :collection
    get :show_hours,      on: :collection
    get :exported_counts, on: :collection
  end

  resources :press_release_reports, path: '/press_release_report', only: %i[index] do
    get :get_report, on: :collection
    post :show_report, on: :collection
  end

  resources :tracking_hours, only: %i[new create update destroy index] do
    post   :submit_forms,  on: :collection
    delete :exclude_row,   on: :member

    post   :add_form,      on: :collection
    get    :assembleds,    on: :collection
    post   :google_sheets, on: :collection
    post   :properties,    on: :collection
    post   :import_data,   on: :collection
    get    :dev_hours,     on: :collection
    post   :confirm,       on: :collection
  end

  resources :images, only: [] do
    post :upload,   on: :collection
    get  :download, on: :collection
  end
end
