// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

// Handle image removal with confirmation dialog
document.addEventListener('turbo:load', () => {
  document.querySelectorAll('.remove-image').forEach(link => {
    link.addEventListener('click', function(event) {
      event.preventDefault();

      const confirmMessage = this.dataset.confirm;
      const imageType = this.dataset.imageType;
      const formId = this.dataset.formId;

      if (confirm(confirmMessage)) {
        // Create a form to submit the deletion request
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `/forms/${formId}/remove_image`;

        // Add CSRF token
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = csrfToken;
        form.appendChild(csrfInput);

        // Add method override to use PATCH
        const methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'PATCH';
        form.appendChild(methodInput);

        // Add image type
        const imageTypeInput = document.createElement('input');
        imageTypeInput.type = 'hidden';
        imageTypeInput.name = 'image_type';
        imageTypeInput.value = imageType;
        form.appendChild(imageTypeInput);

        // Submit the form
        document.body.appendChild(form);
        form.submit();
      }
    });
  });
});
