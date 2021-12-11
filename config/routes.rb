# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root 'root#index'

  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }

  mount ActionCable.server, at: '/cable'

  authenticate :account, ->(u) { u.types.include?('manager') } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :accounts, only: [:index] do
    post :impersonate,        on: :member
    post :stop_impersonating, on: :collection
  end

  namespace :api, constraints: { format: :json } do
    scope module: :work_requests do
      resources :work_types, only: [] do
        post :find_or_create, on: :collection
      end

      resources :clients, only: [] do
        get :find, on: :collection
      end

      resources :underwriting_projects, only: [] do
        post :find_or_create, on: :collection
      end

      resources :invoice_types, only: [] do
        post :find_or_create, on: :collection
      end

      resources :invoice_frequencies, only: [] do
        post :find_or_create, on: :collection
      end
    end

    resources :work_requests, only: :update

    resources :clients, only: :index do
      resources :publications, only: :index do
        resources :publication_tags, path: :tags, as: :tags, only: :index
      end

      resources :client_tags, path: :tags, as: :tags, only: :index
    end

    resources :scrape_tasks, only: [] do
      get :names, on: :collection
      get :data_set_locations, on: :collection
    end

    resources :tasks, only: [] do
      get :titles,   on: :collection
      get :subtasks, on: :member
    end

    resources :shown_samples, only: :update

    get 'publication_scopes', to: 'publications#scopes'
    get 'all_publications_scope_id', to: 'publications#all_pubs_scope_id'
    get 'all_local_publications_scope_id', to: 'publications#all_local_pubs_scope_id'
    get 'all_statewide_publications_scope_id', to: 'publications#all_statewide_pubs_scope_id'
  end

  resources :work_requests, except: :destroy do
    scope module: :work_requests do
      resources :progress_statuses, only: [] do
        patch :change, on: :collection
      end
    end
  end

  resources :data_sets, except: %i[new] do
    get :properties, on: :member

    resources :story_types, only: %i[new create]
    resources :article_types, only: %i[new create]
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
      end

      resources :excepted_publications, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

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
    end
  end

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
      end
    end
  end

  resources :scrape_tasks, except: :destroy do
    get   :cancel_edit
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
    end
  end

  resources :tasks do
    resources :progress_statuses, controller: 'task_statuses', only: [] do
      patch :change,        on: :collection
      post  :comment,        on: :collection
      patch :subtasks,      on: :collection
    end

    resources :comments, controller: 'task_comments', only: %i[new create]

    resources :assignments, controller: 'task_assignments', only: [] do
      get   :edit,   on: :collection
      patch :update, on: :collection
      get   :cancel, on: :collection
    end
  end

  resources :shown_samples,        controller: 'story_types/shown_samples',        only: :index
  resources :exported_story_types, controller: 'story_types/exported_story_types', only: :index
  resources :production_removals,  only: :index

  resources :developers_productions, only: [] do
    get :scores,          on: :collection
    get :show_hours,      on: :collection
    get :exported_counts, on: :collection
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
