# Server Compass PHP Laravel Demo

A compact Laravel 12 sample that surfaces public environment variables with safe defaults while keeping secrets on the server.

## Features
- Home page lists public env vars with a `Not set` fallback when values are missing
- JSON endpoint at `/api/env` returns the same public values for programmatic checks
- Private env vars stay server-side and never reach the browser
- Ships with SQLite enabled so `php artisan serve` works immediately

## Getting Started
1. Requirements: PHP 8.2+ and Composer.
2. Install dependencies (if needed):
   ```bash
   composer install
   ```
3. Configure environment:
   ```bash
   cp .env.example .env
   php artisan key:generate   # not needed if you use the existing .env in this repo
   ```
4. Start the server:
   ```bash
   php artisan serve
   ```
5. Open `http://localhost:8000` for the UI or `http://localhost:8000/api/env` for JSON.

## Environment Variables
Public (shown in UI and `/api/env`):
- `APP_NAME` (default: `ServerCompass PHP laravel`)
- `API_URL` (default: `https://api.servercompass.app`)
- `ENVIRONMENT` (default: `production`)
- `VERSION` (default: `1.0.0`)

Private (server-only, not sent to the browser):
- `DATABASE_URL` (default: `postgresql://user:password@localhost:5432/servercompass`)
- `API_SECRET_KEY` (default: `your-secret-key-here`)

Unset variables render as `Not set` so you can immediately see what needs to be configured without leaking sensitive values.
