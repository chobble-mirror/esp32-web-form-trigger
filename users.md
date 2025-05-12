# User Account Creation

## User Types and Registration Flow

### First User (Admin)

- The first user to register on the system automatically becomes an admin
- Has full system access

### Regular Users

- Can register through /signup by themselves
- Non-admin users can only change their password after login

### Admin Users

- Can access all pages
- Can change the admin status of other users
- Can reset other user passwords and change emails
- Cannot change their own admin status

## Registration Process

### Required Fields

- Email (used as username)
- Password
- Password confirmation

### Validation Rules

- Email must be valid format
- Password must meet minimum complexity requirements
- No duplicate email addresses allowed
