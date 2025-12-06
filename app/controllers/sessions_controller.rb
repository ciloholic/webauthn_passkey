# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      get_options = relying_party.options_for_authentication(
        allow: user.credentials.pluck(:external_id),
        user_verification: 'required'
      )

      session[:current_authentication] = { challenge: get_options.challenge, email: params[:email] }

      respond_to do |format|
        format.json { render json: get_options }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: [ "Email doesn't exist" ] }, status: :unprocessable_entity }
      end
    end
  end

  def callback
    user = User.find_by(email: session.dig('current_authentication', 'email'))
    unless user
      return render json: { errors: [ "#{params[:email]} doesn't exist." ] }, status: :unprocessable_entity
    end

    begin
      verified, credential = relying_party.verify_authentication(
        params,
        session.dig('current_authentication', 'challenge'),
        user_verification: true
      ) do |webauthn_credential|
        user.credentials.find_by(external_id: Base64.strict_encode64(webauthn_credential.raw_id))
      end

      credential.update!(sign_count: verified.sign_count)
      sign_in(user)

      render json: { status: 'ok' }
    rescue WebAuthn::Error, ActiveRecord::RecordInvalid => e
      render json: { errors: [ e.message ] }, status: :unprocessable_entity
    ensure
      session.delete('current_authentication')
    end
  end
end
