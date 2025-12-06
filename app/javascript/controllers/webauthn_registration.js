// JavaScript for passkey registration
import { create } from "@github/webauthn-json"

// Get CSRF token
const getCsrfToken = () => document.querySelector('[name="csrf-token"]').content

// Get form element (DOMContentLoaded may have already fired with importmap)
const form = document.getElementById("registration-form")

if (form) {
  form.addEventListener("submit", async (e) => {
    e.preventDefault()
    const friendlyName = document.getElementById("friendly_name").value
    const errorMessage = document.getElementById("error-message")

    try {
      // 1. Get registration options from server
      const response = await fetch("/registrations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCsrfToken()
        },
        credentials: "same-origin",
        body: JSON.stringify({ friendly_name: friendlyName })
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(error.errors?.join(", ") || "登録オプションの取得に失敗しました")
      }

      const json = await response.json()

      // 2. Create passkey using WebAuthn API
      const credential = await create({ publicKey: json })

      // 3. Send authenticator info to server
      const params = new URLSearchParams({ friendly_name: friendlyName })
      const callbackResponse = await fetch(`/registrations/callback?${params}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCsrfToken()
        },
        credentials: "same-origin",
        body: JSON.stringify(credential)
      })

      if (!callbackResponse.ok) {
        const error = await callbackResponse.json()
        throw new Error(error.errors?.join(", ") || "パスキーの登録に失敗しました")
      }

      // Redirect to home on success
      window.location.href = "/"
    } catch (e) {
      console.error(e)
      errorMessage.textContent = e.message || "パスキーの登録に失敗しました"
    }
  })
}
