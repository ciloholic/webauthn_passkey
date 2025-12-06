# frozen_string_literal: true

class Credential < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :friendly_name, presence: true, length: { maximum: 16 }
  validates :sign_count, presence: true
end
