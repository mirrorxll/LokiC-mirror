# fronzen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }
  authenticate :account, ->(u) { u.account_type.name.eql?('manager') } do
    ActiveAdmin.routes(self)
    mount Sidekiq::Web => '/sidekiq'
  end

  mount ActionCable.server, at: '/cable'

  root 'story_types#index'

  resources :data_sets do
    patch :evaluate, on: :member
    get   :properties, on: :member

    resources :story_types, only: %i[new create]
  end

  resources :story_types, except: %i[new create] do
    get :distributed, on: :collection
    get :properties
    get :canceling_edit, on: :member

    resources :templates, path: :template, only: %i[edit update] do
      patch :save, on: :member
    end

    resources :clients, only: [] do
      post    :include, on: :collection
      delete  :exclude, on: :member

      resources :tags, only: [] do
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
      post    :attach,    on: :collection
      delete  :detach,    on: :member
      patch   :sync,      on: :member
      get     :section,   on: :collection

      resources :columns, only: %i[edit update]
      resources :indices, only: %i[new create destroy]
    end

    resources :codes, only: %i[create destroy show]

    resources :export_configurations, only: :create do
      get   :section,     on: :collection
      patch :update_tags, on: :collection
    end

    resources :fact_checking_docs do
      get :template
      post :send_to_slack_channel

      resources :reviewers_feedback, only: %i[new create] do
        post :approve, on: :collection
      end
      resources :editors_feedback, only: %i[new create] do
        post :approve, on: :collection
      end
    end

    resources :iterations do
      resources :statuses, only: [] do
        get   :form,    on: :collection
        patch :change,  on: :collection
      end

      resources :populations, path: 'populate', only: %i[create destroy]

      resources :samples, only: :show do
        post   :create_and_generate_auto_feedback, on: :collection
        delete :purge_sampled,                     on: :collection
        get    :section,                           on: :collection
      end

      resources :auto_feedback_confirmations, only: [] do
        patch :confirm, on: :member
      end

      resources :creations, path: 'create_samples', only: :create do
        delete :purge_all, on: :collection
      end

      resources :schedules, path: 'schedule', only: [] do
        post  :manual,    on: :collection
        post  :backdate,  on: :collection
        post  :auto,      on: :collection
        patch :purge,     on: :collection
        get   :section,   on: :collection
      end

      resources :exports, path: 'export', only: [] do
        post :production,       on: :collection
        get  :exported_stories, on: :collection
        get  :section,          on: :collection
      end
    end
  end

  # summernote image upload/destroy points
  resources :uploads, only: %i[create destroy]

  resources :slack_accounts, only: %i[] do
    patch :sync
  end
end
