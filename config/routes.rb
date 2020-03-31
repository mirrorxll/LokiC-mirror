# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  mount Sidekiq::Web => '/sidekiq'

  root 'story_types#index'
  resources :data_sets

  resources :story_types do
    put :dates, on: :member
    put :dev_status, on: :member

    resources :data_sets, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :clients, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :sections, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :tags, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :photo_buckets, only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :frequencies, path: 'frequency', only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resources :levels, path: 'level', only: %i[] do
      post    :include, on: :collection
      delete  :exclude, on: :member
    end

    resource :staging_table, only: %i[show create destroy] do
      post    :attach
      delete  :detach
      put     :truncate
      put     :sync

      resource :columns, only: %i[edit update]
      resource :index, only: %i[new create destroy]
    end

    resources :codes, path: 'upload_code', only: %i[create destroy]

    resources :populations, path: 'populate', only: %i[] do
      post    :execute, on: :collection
      delete  :purge, on: :collection
    end
  end
end
