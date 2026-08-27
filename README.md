# WordPress Docker blueprint

Reusable local WordPress stack for new client projects. Each site is `https://local.project-name.dev`, with a persistent MySQL database, Mailpit for email, and WP-CLI.

This folder is a **template**, not a live site. Git lives at this project root (next to `docker-compose.yml`), not inside `wp-content/` and not inside WordPress core.

## Valet → Docker

| Valet | This stack |
| --- | --- |
| Folder in `~/Sites` | Clone/copy this repo, set `PROJECT_NAME` in `.env` |
| `project.test` | `https://local.project-name.dev` |
| MySQL via Homebrew | MySQL 8.0.32 in Docker (named volume) |
| Edit theme files on disk | Same: `wp-content/themes`, `plugins`, `uploads` |

Valet also binds ports 80 and 443. Stop it before starting the proxy: `valet stop`.

## What runs

- **wp-proxy** — shared Caddy reverse proxy (ports 80/443). Start once, leave it running.
- **Per project** — WordPress (PHP 8.3 + Apache), MySQL 8.0.32, Mailpit. WP-CLI runs on demand.

WordPress core stays in a Docker volume. Your custom code and `wordpress/wp-config.php` are bind-mounted from this repo.

## New project from this blueprint

1. On GitHub, mark this repo as a **template**, then **Use this template** for the client (or copy the folder and `git init` at the copy’s root).
2. Clone to something like `~/Code/acme`.
3. Copy env and set the slug (letters, numbers, hyphens):

   ```bash
   cp .env.example .env
   ```

   Set `PROJECT_NAME` and `COMPOSE_PROJECT_NAME` to `acme` (and a unique `MYSQL_PORT` if another site already uses 3306).
4. Open Docker Desktop. Then:

   ```bash
   ./scripts/start.sh
   ```

   First run builds the WordPress image (cached after that), starts the proxy, and adds hosts entries (`sudo` for `/etc/hosts`).
5. Once per Mac, trust Caddy’s local HTTPS certificate:

   ```bash
   ./scripts/trust-caddy-ca.sh
   ```

6. Open `https://local.acme.dev` and finish the WordPress installer. Then:

   ```bash
   ./scripts/install-plugins.sh
   ```

   (or run `./scripts/start.sh` again). That installs and activates Query Monitor, Advanced Custom Fields, and Safe SVG.

Mail inbox: `https://mail.local.acme.dev`.

In Docker Desktop you will see **wp-proxy** (leave running) and **acme** (start/stop per project).

## Everyday commands

```bash
./scripts/start.sh          # proxy + this site
docker compose stop         # stop this site only
docker compose down         # remove this site’s containers (database volume stays)
docker compose down -v      # also delete the database volume (site content in MySQL is gone)
```

WP-CLI (no install on the Mac):

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
- Deleting that volume, or `docker compose down -v`, **deletes the database**

### TablePlus

- Host: `127.0.0.1`
- Port: `3306` (or `MYSQL_PORT` in `.env`)
- User / password / database: values in `.env`
- SSL: off

MySQL is bound to localhost only.

### Save the DB in Git (SQL dump)

Do not commit the Docker volume. Export SQL instead:

```bash
./scripts/db-export.sh    # writes backups/wordpress.sql
./scripts/db-import.sh    # load that file into the running database
```

Keep client repos **private**. Dumps contain users, emails, and post content.

On a **new empty volume**, MySQL auto-imports `backups/wordpress.sql` if that file is present (`/docker-entrypoint-initdb.d`). After the volume exists, use `db-import.sh` to refresh it (or delete the volume and start again).

`.env` is gitignored. Commit `.env.example`. After clone: `cp .env.example .env`.

`wp-content/uploads` is **not** inside the SQL dump. Commit media, or copy it separately.

## wp-config.php

[`wordpress/wp-config.php`](wordpress/wp-config.php) is bind-mounted to `/var/www/html/wp-config.php`. Edit it in Cursor; it persists on disk and is committed with the project.

Database user and password still come from `.env` (`getenv_docker`). Site URL is built from `PROJECT_NAME` (`https://local.PROJECT_NAME.dev`).

For a new client, optionally replace the salt constants with a fresh set from [the WordPress secret-key service](https://api.wordpress.org/secret-key/1.1/salt/).

## Mailpit

WordPress sends mail through **msmtp** using `SMTP_HOST=mailpit` (no plugin, no Postfix). Messages never leave your Mac. The inbox is in-memory and clears if you recreate the Mailpit container.

Test after WordPress is installed:

```bash
./scripts/wp eval 'wp_mail("you@example.com", "Test", "Hello from Docker");'
```

Then open `https://mail.local.PROJECT_NAME.dev`.

## Default plugins

Hello Dolly and Akismet are not present (`wp-content/plugins` replaces the image plugin directory).

After core is installed, `./scripts/install-plugins.sh` reads `config/plugins.txt` and installs:

- [Query Monitor](https://wordpress.org/plugins/query-monitor/)
- [Advanced Custom Fields](https://wordpress.org/plugins/advanced-custom-fields/) (free .org plugin, not ACF Pro)
- [Safe SVG](https://wordpress.org/plugins/safe-svg/)

Those plugin folders are gitignored. Custom plugins you add under `wp-content/plugins` are still committed. Default Twenty* themes are hidden while `wp-content/themes` is bind-mounted; install a theme in wp-admin, with `./scripts/wp theme install`, or drop a theme into `wp-content/themes/`.

## HTTPS and `.dev`

`.dev` is a real TLD and browsers require HTTPS. This stack serves HTTPS and adds `/etc/hosts` lines so `local.project-name.dev` points at `127.0.0.1` on your Mac only.

Firefox uses its own certificate store; import Caddy’s CA there if Chrome/Safari are fine but Firefox is not.

## Layout

```text
docker-compose.yml      # this site
proxy/                  # shared Caddy, run once
.env.example
wordpress/wp-config.php # persistent, editable config
wp-content/             # themes, plugins, uploads
backups/wordpress.sql   # optional Git snapshot of the DB
scripts/start.sh
```
