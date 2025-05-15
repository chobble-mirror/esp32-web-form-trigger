import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="animation"
export default class extends Controller {
  connect() {
    // Initialize controller
  }

  pulse(event) {
    // Add a one-time click animation
    const button = this.element
    
    // Prevent animation if button is disabled
    if (button.disabled) return
    
    // Add click animation class
    button.classList.add('click-animation')
    
    // Play a more dramatic click effect
    button.style.animation = 'buttonClick 0.5s'
    
    // Remove the animation class after it completes
    setTimeout(() => {
      button.style.animation = ''
      button.classList.remove('click-animation')
    }, 500)
  }
}