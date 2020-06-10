# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }
  mount ActionCable.server, at: '/cable'

  acc_access = ->(u) { %w[super-user manager].include?(u.account_type.name) }
  authenticate :account, acc_access do
    mount Sidekiq::Web => '/sidekiq'

    resources :data_sets do
      put :evaluate, on: :member

      resources :story_types, only: %i[new create]
    end
  end

  root 'story_types#index'

  resources :slack_accounts, only: %i[] do
    put :sync
  end

  resources :story_types, except: %i[new create] do
    get :properties

    resources :statuses, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :templates, path: :template, only: %i[edit update]

    resources :clients, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member

      resources :tags, only: %i[] do
        post   :include, on: :collection
        delete :exclude, on: :member
      end
    end

    resources :frequencies, path: :frequency, only: %i[] do
      post   :include, on: :collection
      delete :exclude, on: :member
    end

    resources :photo_buckets, path: :photo_bucket, only: %i[] do
      post   :include, on: :collection
      delete :exclude, on: :member
    end

    resources :developers, only: %i[] do
      put :include, on: :collection
      delete :exclude, on: :member
    end

    resources :staging_tables, only: %i[show create destroy] do
      post    :attach,    on: :collection
      delete  :detach,    on: :member
      delete  :truncate,  on: :member
      put     :sync,      on: :member

      resources :columns, only: %i[edit update]
      resources :indices, only: %i[new create destroy]
    end

    resources :codes, only: %i[create destroy]

    resources :populations, path: 'populate', only: %i[create destroy]

    resources :export_configurations, only: :create

    resources :samples, except: %i[new edit update destroy] do
      get :render_samples_section, on: :collection
      delete :purge_sampled, on: :member
    end

    resources :creations, path: 'create_stories', only: %i[create destroy] do
      delete :purge_all, on: :collection
    end

    resources :schedules, path: 'schedule', only: %i[] do
      post  :manual,    on: :collection
      post  :backdate,  on: :collection
      post  :auto,      on: :collection
      put   :purge,     on: :collection
    end

    resources :exports, only: %i[] do
      post :staging,    on: :collection
      post :production, on: :collection
    end
  end
end
