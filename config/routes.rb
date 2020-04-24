# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'

  devise_for :accounts, controllers: { registrations: 'registrations', sessions: 'sessions' }

  root 'story_types#index'

  resources :slack_accounts, only: %i[] do
    put :sync
  end

  resources :data_sets do
    put :evaluate, on: :member

    resources :story_types, only: %i[new create]
  end

  resources :story_types, except: %i[new create] do
    get :properties

    resource :template, only: %i[edit update]

    resources :clients, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resource :frequency, only: %i[] do
      put :include, on: :collection
      put :exclude, on: :collection
    end

    resource :tag, only: %i[] do
      put :include, on: :collection
      put :exclude, on: :collection
    end

    resource :photo_bucket, only: %i[] do
      put :include, on: :collection
      put :exclude, on: :collection
    end

    resource :developer, only: %i[] do
      put :include, on: :collection
      put :exclude, on: :collection
    end

    resource :staging_table, only: %i[show create destroy] do
      post    :attach
      delete  :detach
      put     :truncate
      put     :sync

      resource :columns, only: %i[edit update]
      resource :index, only: %i[new create destroy]
    end

    resource :code, path: 'upload_code', only: %i[create destroy]

    resource :population, path: 'populate', only: %i[] do
      post    :execute, on: :collection
      delete  :purge, on: :collection
    end

    resources :export_configurations, only: :create do
      get :check, on: :collection
    end
  end
end
