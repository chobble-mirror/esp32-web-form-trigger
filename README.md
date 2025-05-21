# ESP32-WEB-FORM-TRIGGER

Rails app for form collection → ESP32 pin activation.

## Core Components

### Models
- `Device`: 12-char ID, name, location
- `Form`: Customizable fields, styling, target email
- `Submission`: User data, trigger status, delivery metadata

### API
- `GET /api/v1/credits/check` - Query available triggers
- `POST /api/v1/credits/claim` - Execute pin trigger

### URL Schema
Form endpoint: `/form/:form_id/:device_id`

## Technical Specifications

### Requirements
- Ruby 3.4+
- Rails 8.0+
- Dependencies: Redcarpet, ActiveStorage, SolidQueue

### Installation
```
git clone <repo>
bundle install
rails db:migrate
rails server
```

### Email Configuration
Set vars in `.env`:
```
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=user@example.com
SMTP_PASSWORD=password
SMTP_AUTH=plain
SMTP_STARTTLS=true
DEFAULT_EMAIL_FROM=noreply@example.com
```

### Queue Management
```
bin/jobs start       # Start worker
bin/jobs stats       # Monitor stats
JOB_CONCURRENCY=n    # Set worker threads (default: 1)
```

### Docker Deployment
```
docker build -t esp32-form-app .
docker run -p 3000:3000 -e RAILS_MASTER_KEY=key -e SMTP_SERVER=smtp.example.com esp32-form-app

# Alternative
docker-compose up -d
```