# WordPress Docker blueprint

Reusable local WordPress stack for new client projects. Each site is `https://local.project-name.dev`, with a persistent MySQL database, Mailpit for email, and WP-CLI.

This folder is a **template**, not a live site. Git lives at this project root (next to `docker-compose.yml`), not inside `wp-content/` and not inside WordPress core.

Run `valet stop` before starting if Laravel Valet is still using ports 80 and 443.

## New project

1. Copy this blueprint (GitHub **Use this template**, or copy the folder). Git at the project root.
2. `cp .env.example .env` and set `PROJECT_NAME` and `COMPOSE_PROJECT_NAME` to the client slug (e.g. `acme`). Change `MYSQL_PORT` if 3306 is already in use.
3. `valet stop` if Valet is running.
4. `./scripts/add-host.sh` once per project name (needs `sudo`), or add these lines to `/etc/hosts` yourself:
   - `127.0.0.1 local.acme.dev`
   - `127.0.0.1 mail.local.acme.dev`
5. `docker compose up -d` — first run builds images. Site: `https://local.acme.dev`. Mail: `https://mail.local.acme.dev`.
6. Once on this Mac: `./scripts/trust-caddy-ca.sh` (trusts local HTTPS in the browser).
7. Finish the WordPress installer in the browser, then `./scripts/install-plugins.sh` (Query Monitor, ACF, Safe SVG).

## Everyday commands

```bash
docker compose up -d       # start
docker compose stop        # pause
docker compose down        # remove containers (database volume stays)
docker compose down -v     # also delete the database volume
```

Only one project can bind ports 80/443 at a time. Run `docker compose down` here before starting another site.

WordPress core stays in a Docker volume. Your custom code and [`wordpress/wp-config.php`](wordpress/wp-config.php) are bind-mounted from this repo.

## WP-CLI

```bash
./scripts/wp plugin list
./scripts/wp theme list
./scripts/wp option get siteurl
./scripts/wp search-replace 'http://old' 'https://local.acme.dev'
```

Equivalent: `docker compose run --rm wpcli plugin list`.

## Database

MySQL files live in a Docker **named volume**, not in this folder.

- Docker Desktop → **Volumes** → `{COMPOSE_PROJECT_NAME}_db_data` (example: `acme_db_data`)
- Stopping or removing **containers** keeps the data
- `docker compose down -v` **deletes the database**

### TablePlus

- Host: `127.0.0.1`
- Port: `3306` (or `MYSQL_PORT` in `.env`)
- User / password / database: values in `.env`
- SSL: off

### Save the DB in Git (SQL dump)

```bash
./scripts/db-export.sh    # writes backups/wordpress.sql
./scripts/db-import.sh    # load into the running database
```

Keep client repos **private**. Dumps contain users, emails, and post content.

On a **new empty volume**, MySQL auto-imports `backups/wordpress.sql` if present. After the volume exists, use `db-import.sh` to refresh it.

`.env` is gitignored. Commit `.env.example`. `wp-content/uploads` is not inside the SQL dump.

## wp-config.php

[`wordpress/wp-config.php`](wordpress/wp-config.php) is bind-mounted to `/var/www/html/wp-config.php`. Edit it in Cursor; it persists on disk and is committed with the project.

Database credentials come from `.env` (`getenv_docker`). Site URL is `https://local.PROJECT_NAME.dev`.

For a new client, optionally replace the salt constants from [the WordPress secret-key service](https://api.wordpress.org/secret-key/1.1/salt/).

## Mailpit

WordPress sends mail through **msmtp** to Mailpit (`SMTP_HOST=mailpit`). Test after install:

```bash
./scripts/wp eval 'wp_mail("you@example.com", "Test", "Hello from Docker");'
```

Then open `https://mail.local.PROJECT_NAME.dev`.

## Default plugins

After core is installed, `./scripts/install-plugins.sh` reads `config/plugins.txt`:

- [Query Monitor](https://wordpress.org/plugins/query-monitor/)
- [Advanced Custom Fields](https://wordpress.org/plugins/advanced-custom-fields/)
- [Safe SVG](https://wordpress.org/plugins/safe-svg/)

Those plugin folders are gitignored. Custom plugins under `wp-content/plugins` are still committed.

## Layout

```text
docker-compose.yml      # WordPress, MySQL, Mailpit, Caddy
.env.example
wordpress/wp-config.php
wp-content/
backups/wordpress.sql
scripts/
```
