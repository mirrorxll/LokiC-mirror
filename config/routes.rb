# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }

  root 'stories#index'

  resources :stories do
    resources :clients, only: %i[index] do
      post    :add,     on: :collection
      delete  :remove,  on: :member
    end

    resources :data_locations, only: %i[index new create destroy] do
      post    :add,     on: :member
      delete  :remove,  on: :member
    end

    resources :sections, only: %i[index] do
      post    :add,     on: :member
      delete  :remove,  on: :member
    end

    resources :tags, only: %i[index] do
      post    :add,     on: :member
      delete  :remove,  on: :member
    end

    resources :photo_buckets, only: %i[index] do
      post    :add,     on: :member
      delete  :remove,  on: :member
    end
  end
end
