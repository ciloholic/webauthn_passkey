# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # WebAuthn Relying Party configuration
  def relying_party
    @relying_party ||= WebAuthn::RelyingParty.new(
      allowed_origins: [ ENV.fetch('WEBAUTHN_ORIGIN', 'http://localhost:3000') ],
      name: 'WebAuthn Passkey App'
    )
  end
end
