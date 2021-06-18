# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }

  authenticate :account, ->(u) { u.types.include?('manager') } do
    ActiveAdmin.routes(self)
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :accounts, only: [:index] do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end

  mount ActionCable.server, at: '/cable'

  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      resources :clients, only: [] do
        get :visible, on: :collection
        get :tags
        get :publications
      end

      resources :shown_samples, only: :update
    end
  end

  root 'story_types#index'

  get '/iterations/:id', to: 'iterations#show'

  resources :images, only: :create, defaults: { format: :json } do
    get    :show,    on: :collection, path: '/:name', name: /.*/
    delete :destroy, on: :collection, path: '/:name', name: /.*/
  end

  resources :data_sets, except: %i[new] do
    get :properties, on: :member

    resources :story_types, only: %i[new create]
  end

  resources :story_types, except: %i[new create] do
    get   :properties

    patch :update_sections, on: :member

    patch :change_data_set, on: :member

    patch '/change_progress_status', to: 'progress_statuses#change'

    resources(:progress_statuses, only: []) { patch :change, on: :collection }

    resources :templates, path: :template, only: %i[show edit update] do
      patch :save, on: :member
    end

    resources :clients, only: [] do
      post    :include, on: :collection
      delete  :exclude, on: :member

      resources :tags, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end

      resources :publications, only: [] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end
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
      delete  :detach,         on: :member
      patch   :sync,           on: :member
      get     :canceling_edit, on: :collection

      resources :columns, only: %i[edit update]
      resources :indices, only: %i[new create destroy]
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

    resources :cron_tabs

    resources :iterations, only: %i[create update] do
      patch :apply, on: :member
      delete :purge, on: :member

      resources :populations, path: 'populate', only: [] do
        post   :execute, on: :collection
        delete :purge,   on: :collection
      end

      resources :samples, only: %i[index show] do
        post   :create_and_generate_auto_feedback, on: :collection
        delete :purge_sampled,                     on: :collection
      end

      resources :auto_feedback_confirmations, only: [] do
        patch :confirm, on: :member
      end

      resources :creations, only: [] do
        post   :execute,   on: :collection
        delete :purge_all, on: :collection
      end

      resources :schedules, path: 'schedule', only: [] do
        post  :manual,    on: :collection
        post  :backdate,  on: :collection
        post  :auto,      on: :collection
        patch :purge,     on: :collection
        get   :show_form, on: :collection
      end

      resources :exports, path: 'export', only: [] do
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
  end

  resources :shown_samples,        only: :index
  resources :exported_story_types, only: :index
  resources :production_removals,  only: :index

  resources :slack_accounts, only: %i[] do
    patch :sync
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

  resources :developers_productions, only: [] do
    get :scores,          on: :collection
    get :show_hours,      on: :collection
    get :exported_counts, on: :collection
  end
end
