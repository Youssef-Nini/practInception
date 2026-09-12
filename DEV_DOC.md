# Developer Documentation — Inception

This document describes how to set up, build, and work on the Inception project from a
developer's perspective.

## 1. Prerequisites

- A Linux virtual machine with:
  - `docker` and the `docker compose` plugin installed.
  - `make`.
- A hosts entry (or DNS record) resolving `ynini.42.fr` to the VM's own IP address, so
  the NGINX container can be reached by that domain name.

## 2. Repository layout

```
.
├── Makefile
└── srcs
    ├── docker-compose.yml
    ├── .env                      # not committed — see below
    └── requirements
        ├── nginx
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress
        │   ├── Dockerfile
        │   └── tools/entrypoint.sh
        └── mariadb
            ├── Dockerfile
            ├── conf/50-server.cnf
            └── tools/entrypoint.sh
```

## 3. Setting up the environment from scratch

1. Clone the repository.
2. Create the `srcs/.env` file (never commit this file — add it to `.gitignore`). At
   minimum it should define:
   ```
   DOMAIN_NAME=ynini.42.fr
   MYSQL_ROOT_PASSWORD=...
   MYSQL_DATABASE=...
   MYSQL_ADMIN_USER=...
   MYSQL_ADMIN_PASSWORD=...
   MYSQL_USER=...
   MYSQL_PASSWORD=...
   WORDPRESS_TITLE=...
   WP_ADMIN_USER=...
   WP_ADMIN_PASSWORD=...
   WP_ADMIN_EMAIL=...
   WP_USER=...
   WP_USER_EMAIL=...
   WP_USER_PASSWORD=...
   ```
   *(Adjust the variable names to match what your `entrypoint.sh` scripts actually
   expect.)*
3. If you're using Docker secrets instead of (or in addition to) plain environment
   variables for passwords, place the secret files under a `secrets/` folder at the repo
   root and reference them in `docker-compose.yml` via the top-level `secrets:` key —
   this keeps passwords out of `docker inspect` output.
4. Make sure `srcs/.env` and any secrets files are listed in `.gitignore` before your
   first commit.

## 4. Building and launching the project

```bash
make
```

This target:
1. Creates the host data directories (`/home/ynini/data/mariadb`,
   `/home/ynini/data/wordpress`) used by the named volumes.
2. Runs `docker compose -f ./srcs/docker-compose.yml up --build -d`, which builds the
   three custom images (`nginx`, `wordpress`, `mariadb`) from their respective
   Dockerfiles and starts the containers in detached mode.

Other targets:

```bash
make down     # docker compose down — stops and removes containers, keeps volumes/images
make clean    # down --volumes --rmi all, then removes the host data directory
make fclean   # clean + docker system prune -a --volumes -f
make re       # fclean then all — full rebuild from scratch
```

## 5. Managing containers and volumes

Useful `docker compose` / `docker` commands (run from the repo root, or add
`-f ./srcs/docker-compose.yml` if not already using the Makefile):

```bash
docker compose -f srcs/docker-compose.yml ps        # list container status
docker compose -f srcs/docker-compose.yml logs -f   # follow logs of all services
docker compose -f srcs/docker-compose.yml logs -f nginx   # logs of one service
docker exec -it wordpress sh                        # shell into a running container
docker network ls                                   # confirm the `inception` network exists
docker volume ls                                    # list volumes
docker volume inspect srcs_mariadb_data             # inspect a volume's mountpoint
```

## 6. Data storage and persistence

- `mariadb_data` and `wordpress_data` are declared as named volumes in
  `docker-compose.yml`.
- Both are backed by host paths under `/home/ynini/data` (`/home/ynini/data/mariadb` and
  `/home/ynini/data/wordpress`), created by `make` before the stack starts.
- Because the data lives on the host filesystem rather than inside the container's
  writable layer, WordPress content and the MariaDB database survive
  `docker compose down`, container restarts, and even a reboot of the VM — as long as
  `make clean` (which explicitly deletes the host data directory) is not run.