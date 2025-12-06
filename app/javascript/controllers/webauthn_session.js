// JavaScript for passkey authentication
import { get } from "@github/webauthn-json"

// Get CSRF token
const getCsrfToken = () => document.querySelector('[name="csrf-token"]').content

// Get form element (DOMContentLoaded may have already fired with importmap)
const form = document.getElementById("session-form")

if (form) {
  form.addEventListener("submit", async (e) => {
    e.preventDefault()
    const email = document.getElementById("email").value
    const errorMessage = document.getElementById("error-message")

    try {
      // 1. Get authentication options from server
      const response = await fetch("/sessions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCsrfToken()
        },
        credentials: "same-origin",
        body: JSON.stringify({ email })
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(error.errors?.join(", ") || "認証オプションの取得に失敗しました")
      }

      const json = await response.json()

      // 2. Authenticate using WebAuthn API
      const credential = await get({ publicKey: json })

      // 3. Send authentication info to server
      const callbackResponse = await fetch("/sessions/callback", {
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
        throw new Error(error.errors?.join(", ") || "パスキー認証に失敗しました")
      }

      // Redirect to home on success
      window.location.href = "/"
    } catch (e) {
      console.error(e)
      errorMessage.textContent = e.message || "パスキー認証に失敗しました"
    }
  })
}
