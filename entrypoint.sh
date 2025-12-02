#!/bin/sh
set -e

# Default port
: "${PORT:=8000}"

# Run DB migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start Gunicorn
exec gunicorn simplesocial.wsgi:application --bind 0.0.0.0:${PORT} --workers 3
