# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@github/webauthn-json', to: '@github--webauthn-json.js' # @2.1.1
pin_all_from 'app/javascript/controllers', under: 'controllers'
