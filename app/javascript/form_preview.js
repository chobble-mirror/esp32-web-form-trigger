// Form preview functionality
document.addEventListener('turbo:load', function() {
  setupFormPreview();
});

// Regular DOMContentLoaded fallback
document.addEventListener('DOMContentLoaded', function() {
  setupFormPreview();
});

function setupFormPreview() {
  // Get the form preview elements
  const preview = document.getElementById('form-preview');
  if (!preview) return;

  // Get color input fields
  const backgroundColorInput = document.getElementById('form_background_color');
  const textColorInput = document.getElementById('form_text_color');
  const buttonColorInput = document.getElementById('form_button_color');
  const buttonTextColorInput = document.getElementById('form_button_text_color');
  const buttonTextInput = document.getElementById('form_button_text');

  // Set up event listeners for all inputs
  [backgroundColorInput, textColorInput, buttonColorInput, buttonTextColorInput, buttonTextInput].forEach(input => {
    if (input) {
      // Initialize preview with current values
      updatePreview();
      
      // Update preview when input changes
      input.addEventListener('input', updatePreview);
    }
  });

  function updatePreview() {
    // Get current values
    const backgroundColor = backgroundColorInput.value;
    const textColor = textColorInput.value;
    const buttonColor = buttonColorInput.value;
    const buttonTextColor = buttonTextColorInput.value;
    const buttonText = buttonTextInput.value || 'Submit';

    // Update preview styles
    preview.style.backgroundColor = backgroundColor;
    preview.style.color = textColor;
    
    const previewButton = preview.querySelector('.preview-button');
    if (previewButton) {
      previewButton.style.backgroundColor = buttonColor;
      previewButton.style.color = buttonTextColor;
      previewButton.textContent = buttonText;
    }
  }
}