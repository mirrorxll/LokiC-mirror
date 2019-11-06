# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }

  root 'stories#index'
  resources :data_locations

  resources :stories do
    resources :data_locations, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resources :clients, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resources :sections, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resources :tags, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resources :photo_buckets, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resource :frequency, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resource :level, only: %i[] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end
  end
end
