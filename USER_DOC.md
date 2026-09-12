# User Documentation — Inception

This document explains, in simple terms, how to use the Inception stack as an end user
or administrator. No development knowledge is required to follow it.

## 1. What the stack provides

The project runs three services together:

| Service   | What it does                                                    |
|-----------|-------------------------------------------------------------------|
| NGINX     | The only door into the infrastructure. Serves the site over HTTPS (port 443). |
| WordPress | The website and blog engine (with php-fpm), running behind NGINX. |
| MariaDB   | The database that stores all of WordPress's content and users.   |

You never talk to WordPress or MariaDB directly — everything goes through NGINX.

## 2. Starting and stopping the project

From the root of the repository:

```bash
make        # builds the images (if needed) and starts all three containers
```

To check that everything is running:

```bash
docker ps
```

You should see three containers: `nginx`, `wordpress`, and `mariadb`, all with a status
of `Up`.

To stop the project (without deleting your data):

```bash
make down
```

To start it again later:

```bash
make
```

## 3. Accessing the website and the administration panel

- **Website:** open `https://ynini.42.fr` in your browser.
- **Admin panel:** open `https://ynini.42.fr/wp-admin` and log in with a WordPress
  account.

Two things to know beforehand:

- Only HTTPS (port 443) works. Trying `http://ynini.42.fr` (port 80) will fail — this is
  intentional, NGINX is the only entry point and only listens on 443.
- The certificate is self-signed, so your browser will show a "not secure" / certificate
  warning the first time. This is expected for this project; you can safely proceed.

There are two WordPress accounts set up:

- A regular/editor account, for publishing and editing content.
- An administrator account, whose username deliberately does **not** contain
  "admin"/"administrator" (as required by the subject).

## 4. Locating and managing credentials

- All environment variables, including passwords, are stored in a local srcs/.env file. This file is excluded from Git via .gitignore and is not committed. Docker secrets are not used in this project.

## 5. Checking that the services are running correctly

- `docker ps` — confirms all three containers are `Up` and not restarting in a loop.
- `docker compose -f srcs/docker-compose.yml logs -f` — tails the logs of all services if
  something looks wrong.
- Opening `https://ynini.42.fr` and seeing the WordPress site (not the WordPress
  installation wizard) confirms WordPress and MariaDB are correctly linked.
- Logging into `/wp-admin` and successfully editing a page confirms the database
  connection and file persistence are both working.
- If you reboot the host machine and run `make` again, your previous WordPress content
  should still be there — this confirms the volumes are persisting data correctly.