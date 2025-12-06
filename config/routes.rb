# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # ヘルスチェック
  get 'up' => 'rails/health#show', as: :rails_health_check

  # ホーム
  get 'home' => 'home#index', as: :home

  # パスキー登録
  resources :registrations, only: %i[new create] do
    collection do
      post :callback
    end
  end

  # パスキー認証
  resources :sessions, only: %i[new create] do
    collection do
      post :callback
    end
  end

  root 'home#index'
end
