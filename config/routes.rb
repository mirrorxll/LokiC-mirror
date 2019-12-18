# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords'
  }

  root 'stories#index'
  resources :data_locations

  resources :stories do
    resources :data_locations, only: %i[] do
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

    resources :staging_tables, path: 'staging_table', except: %i[index new]
    resources :codes, path: 'upload_code', only: %i[create destroy]

    resources :populations, path: 'populate', only: %i[] do
      post    :execute, on: :collection
      delete  :purge, on: :collection
    end
  end
end
