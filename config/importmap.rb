# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

# Explicitly pin our local JavaScript modules with absolute paths
pin "form_fields", to: "form_fields.js", preload: true
pin "form_preview", to: "form_preview.js", preload: true
