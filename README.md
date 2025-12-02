
# StarSocial

StarSocial is a small multi-user social/posts Django application originally scaffolded from an older Django tutorial. It allows users
to sign up, create posts, create and join groups, and browse posts by user or group.

This README documents the end-to-end flow of the application, development tooling, how to run locally, and how to deploy the project
to Vercel using a Docker build (the repo already contains a `Dockerfile` and `vercel.json`).

**Status:** Running locally and prepared for Docker-based deployment.

-----

## High-level architecture & flow

- Web framework: Django (modernized to work with Django 5.x in this repo).
- Database: SQLite for development (`db.sqlite3` in the repo). For production use a managed DB (Postgres, etc.).
- Apps:
	- `accounts` — authentication and signup views
	- `posts` — Post model and views (create, list, detail, delete)
	- `groups` — Group model and group membership management
	- `simplesocial` — project settings, root urls, wsgi

Request flow (example: a user loads the homepage):

1. Browser requests `/` → routed in `simplesocial/urls.py` to `simplesocial.views.HomePage`.
2. View checks `request.user` and renders templates from `templates/` using context processors.
3. Templates include static assets via `{% static %}` and link to CSS/JS in `static/`.
4. When a user creates a post, the `posts` app saves the `Post` model and stores rendered HTML for the post message.

Models overview (brief):
- `accounts`: uses Django's auth system (`get_user_model()` if customized).
- `posts.Post`: stores `user`, `message`, `message_html`, `group` (optional), `created_at`.
- `groups.Group`: `name`, `slug`, `description`, `description_html`, members via `GroupMember` join model.

-----

## Development tooling

- Python 3.11 (project venv used in development: `.venv`)
- Django 5.x (modernized from original tutorial code)
- Whitenoise + Gunicorn for serving static files and running WSGI in production containers
- Vercel: Docker-based deployment using `vercel.json` and `Dockerfile`

-----

## Local development — quick start

Prerequisites: `python` 3.11, `git`, and PowerShell (Windows). The repo contains a `.venv` created for development.

1. Activate virtualenv (Windows PowerShell example):

```powershell
Set-Location -LiteralPath 'd:\Computer_Science\Projects\Data_Github_Profile\web-dev\starsocial\StarSocial'
.venv\Scripts\Activate.ps1
```

2. Install dependencies (if you need to recreate venv):

```powershell
python -m pip install -r requirements.txt
```

3. Apply migrations and create a superuser (interactive):

```powershell
.venv\Scripts\python.exe manage.py migrate
.venv\Scripts\python.exe manage.py createsuperuser
```

4. Run the development server:

```powershell
.venv\Scripts\python.exe manage.py runserver
# open http://127.0.0.1:8000
```

5. Admin: `http://127.0.0.1:8000/admin/` — log in with the superuser you created.

-----

## Tests

This project contains no dedicated unit tests beyond app skeletons. You can run `manage.py check` for a quick validation:

```powershell
.venv\Scripts\python.exe manage.py check
```

-----

## Deployment (Vercel using Docker)

This repository is prepared to deploy on Vercel using its Docker builder. The repo includes:

- `Dockerfile` — builds a Python image, installs requirements, copies the source, and runs an `entrypoint.sh`.
- `entrypoint.sh` — runs migrations, `collectstatic`, and starts Gunicorn.
- `vercel.json` — instructs Vercel to use the Dockerfile build.

Steps to deploy on Vercel (web UI):

1. Go to https://vercel.com and sign in.
2. New Project → Import Git Repository → choose `ankiphr09/StarSocial`.
3. In Project Settings → Environment Variables, add:
	 - `DEBUG` = `False`
	 - `ALLOWED_HOSTS` = `<your-domain>.vercel.app` (or `*` for quick tests)
	 - `SECRET_KEY` = `<a-secure-random-string>`
	 - (Optional) `PORT` = `8000` — Vercel normally provides the port automatically but the container uses `$PORT`.
4. Deploy — Vercel will build the Docker image and start the container. The container runs migrations and `collectstatic` on start.

Notes and recommendations:
- Running migrations on container start is convenient but can be risky for complex production deployments. Consider running migrations manually from CI or via an admin task for production.
- For production DB use a managed PostgreSQL instance and set `DATABASES` accordingly via environment variables.

-----

## Environment variables (summary)

- `DEBUG` — `False` in production
- `ALLOWED_HOSTS` — comma-separated list of allowed hosts
- `SECRET_KEY` — a secure secret to override the value in source
- `PORT` — optional; entrypoint supports binding to `$PORT`

-----

## Admin and content management

- Admin is available at `/admin/`. Create staff accounts (is_staff) or superusers for admin access.
- The admin currently registers `Post` and `Group`. I can add improved admin classes (search, list_display, inlines) if you want.

-----

## Troubleshooting

- If you see template errors about `{% load staticfiles %}` or `is_authenticated()` — those were modernized. Ensure your local environment uses current code from `master` and `requirements.txt` is installed.
- If Docker builds fail on Vercel with timeouts, try a different host (Render, Railway) — I can prepare instructions.

-----

## Files of interest

- `simplesocial/settings.py` — project settings (static, middleware, environment-aware settings)
- `simplesocial/urls.py` — root URL routing
- `posts/`, `groups/`, `accounts/` — Django apps with models, views, templates
- `templates/` — project-level templates (base.html, index.html, etc.)
- `static/` — static CSS/JS used by templates

-----

If you want, I can also:
- Add richer admin customizations (list_display, filters, inlines)
- Prepare a Render/Railway deployment alternative (Procfile + simpler instructions)
- Add automated migration/deploy steps in CI (GitHub Actions)

Pick one and I'll implement it next.
