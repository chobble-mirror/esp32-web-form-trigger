document.addEventListener('turbo:load', function() {
  setupFieldCustomization();
});

// Regular DOMContentLoaded fallback
document.addEventListener('DOMContentLoaded', function() {
  setupFieldCustomization();
});

// Function to toggle field customization visibility
function setupFieldCustomization() {
  const fieldToggles = document.querySelectorAll('.field-toggle input[type="checkbox"]');
  
  // Initial setup based on checkbox states
  fieldToggles.forEach(checkbox => {
    const fieldGroup = checkbox.closest('.field-group');
    const customization = fieldGroup.querySelector('.field-customization');
    
    if (customization) {
      customization.style.display = checkbox.checked ? 'grid' : 'none';
    }
    
    // Add event listener for changes
    checkbox.addEventListener('change', function() {
      if (customization) {
        customization.style.display = this.checked ? 'grid' : 'none';
      }
    });
  });
}