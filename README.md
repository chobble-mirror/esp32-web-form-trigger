# ESP32 Web Form Trigger

A Ruby on Rails application for collecting contact form submissions and triggering credits on arcade machines.

## Overview

This application allows you to:

1. Create customizable contact forms
2. Associate forms with specific devices (arcade machines)
3. Collect user information through form submissions
4. Email submissions to designated contacts
5. Provide an API for devices to check and claim credits

## Models

### Devices

- ID: A 12 character random string (auto-generated)
- Name: Name of the device
- Location: Optional location description

### Forms

- Header image: Optional image for the form
- Visual customization: Background color, text color, button color, button text color
- Content: Button text, header text (markdown)
- Field options: Enable/disable name, email, phone, address, postcode fields
- Terms and conditions: Optional markdown text
- Thank you text: Optional markdown text shown after submission
- Target email: Where submissions should be sent

### Submissions

Each submission records:
- Associated form and device
- User details (name, email, phone, address, postcode) based on enabled fields
- Credit status (claimed/unclaimed)
- Email delivery status and timestamp

## API Endpoints

For devices to check and claim credits:

- `GET /api/v1/credits/check/:device_id` - Check available credits
- `POST /api/v1/credits/claim/:device_id` - Claim a credit

## Public Form URLs

Public-facing form URLs follow this pattern:
```
/form/:form_id/:device_id
```

## Development

### Requirements

- Ruby 3.4+
- Rails 8.0+
- Redcarpet (for markdown processing)
- Active Storage (for image uploads)

### Setup

1. Clone the repository
2. Run `bundle install`
3. Run `rails db:migrate`
4. Start the server with `rails server`

## Design Notes

- Uses semantic HTML with MVB.css styling
- Avoids custom CSS classes
- All admin interfaces follow consistent patterns
