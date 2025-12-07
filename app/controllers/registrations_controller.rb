# frozen_string_literal: true

class RegistrationsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    unless current_user.webauthn_id
      current_user.update!(webauthn_id: WebAuthn.generate_user_id)
    end

    options = relying_party.options_for_registration(
      user: {
        name: current_user.email,
        id: current_user.webauthn_id
      },
      attestation: 'none',
      authenticator_selection: {
        authenticator_attachment: 'platform',
        resident_key: 'discouraged',
        user_verification: 'required'
      }
    )

    session[:creation_registration] = { challenge: options.challenge }

    respond_to do |format|
      format.json { render json: options }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.json { render json: { errors: [ e.message ] }, status: :unprocessable_entity }
    end
  end

  def callback
    webauthn_credential = relying_party.verify_registration(
      params,
      session.dig('creation_registration', 'challenge'),
      user_verification: true
    )
    current_user.credentials.create!(
      external_id: Base64.strict_encode64(webauthn_credential.raw_id),
      friendly_name: params[:friendly_name],
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count
    )
    render json: { status: 'ok' }
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid => e
    Rails.logger.error { e }
    render json: { errors: [ e.message ] }, status: :unprocessable_entity
  ensure
    session.delete('creation_registration')
  end
end
