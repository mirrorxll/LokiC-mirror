# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }
  mount ActionCable.server, at: '/cable'

  acc_access =
    ->(u) { %w[super-user manager editor].include?(u.account_type.name) }

  authenticate :account, acc_access do
    mount Sidekiq::Web => '/sidekiq'

    resources :data_sets do
      patch :evaluate, on: :member

      resources :story_types, only: %i[new create]
    end
  end

  root 'story_types#index'

  resources :slack_accounts, only: %i[] do
    patch :sync
  end

  resources :story_types, except: %i[new create] do
    get :properties

    resources :statuses, only: [] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :templates, path: :template, only: %i[edit update]

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
      put :include, on: :collection
      delete :exclude, on: :member
    end

    resources :staging_tables, only: %i[show create destroy] do
      post    :attach,    on: :collection
      delete  :truncate,  on: :member
      patch   :sync,      on: :member

      resources :columns, only: %i[edit update]
      resources :indices, only: %i[new create destroy]
    end

    resources :codes, only: %i[create destroy]

    resources :populations, path: 'populate', only: %i[create destroy]

    resources :export_configurations, only: :create do
      get :section, on: :collection
      patch :update_tags, on: :collection
    end

    resources :samples, except: %i[new edit update destroy] do
      get :section, on: :collection
      delete :purge_sampled, on: :collection
    end

    resources :creations, path: 'create_stories', only: %i[create destroy] do
      delete :purge_all, on: :collection
    end

    resources :schedules, path: 'schedule', only: [] do
      post  :manual,    on: :collection
      post  :backdate,  on: :collection
      post  :auto,      on: :collection
      patch :purge,     on: :collection
    end

    resources :exports, only: [] do
      post :staging,    on: :collection
      post :production, on: :collection
    end
  end
end
