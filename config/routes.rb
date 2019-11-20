# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }

  root 'stories#index'
  resources :data_locations, except: %i[]
  resources :summernote_uploads, only: %i[create destroy]

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
  end
end
