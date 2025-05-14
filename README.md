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

- `GET /api/v1/credits/check` - Check available credits
- `POST /api/v1/credits/claim` - Claim a credit

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

## Email Configuration

The application uses ActionMailer with SolidQueue background processing for email deliveries.

### Configuration via Environment Variables

Configure email settings in `.env` using these variables:

```
# SMTP Email settings
SMTP_SERVER=smtp.example.com      # SMTP server hostname
SMTP_PORT=587                     # SMTP port (usually 587 for TLS)
SMTP_DOMAIN=example.com           # Domain used in HELO
SMTP_USERNAME=user@example.com    # SMTP login username
SMTP_PASSWORD=your_password       # SMTP login password
SMTP_AUTH=plain                   # Authentication type (plain, login, cram_md5)
SMTP_STARTTLS=true                # Enable STARTTLS (true/false)
DEFAULT_EMAIL_FROM=noreply@example.com  # Default sender address
```

### Email Queue Monitoring

Administrators can monitor the email queue status at `/email_queues`. This page shows:

- Queue summary statistics
- Pending email jobs
- Failed submissions with retry options
- Failed jobs with error details
- Recently completed emails

### Background Processing

Email delivery happens asynchronously using SolidQueue:

1. Start the worker with: `bin/jobs start`
2. Monitor workers with: `bin/jobs stats`
3. Run in production: Set `JOB_CONCURRENCY` env var (default: 1)

### Docker Deployment

The application includes Docker configuration that automatically runs both the web server and the job worker:

```bash
# Build and run using Docker
docker build -t esp32-form-app .
docker run -d -p 3000:3000 \
  -e RAILS_MASTER_KEY=your_master_key \
  -e SMTP_SERVER=smtp.example.com \
  -e SMTP_USERNAME=user@example.com \
  -e SMTP_PASSWORD=password \
  esp32-form-app

# Or use Docker Compose
docker-compose up -d
```

The Docker setup:

- Runs Rails server and SolidQueue worker in the same container
- Automatically migrates the database on startup
- Ensures clean shutdown of both processes
- Configures email delivery via environment variables
