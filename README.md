*This project has been created as part of the 42 curriculum by ynini.*

# Inception

## Description

Inception is a system administration project whose goal is to build a small, self-contained
web infrastructure entirely with Docker, orchestrated through `docker compose`, and run
inside a personal virtual machine.

The stack is made of three custom-built services, each running in its own dedicated
container, with no pre-built (DockerHub) images other than the base `alpine`/`debian`
image used as the starting point for every Dockerfile:

- **NGINX** — the single entry point of the infrastructure, serving HTTPS only
  (TLSv1.2 / TLSv1.3) on port 443.
- **WordPress + php-fpm** — the WordPress application and PHP processor, with no NGINX
  bundled inside the container.
- **MariaDB** — the database engine backing WordPress, with no NGINX bundled inside the
  container.

The three containers communicate with each other over a dedicated Docker network
(`inception`), and WordPress's data (site files and database) is kept on the host so it
survives container restarts and rebuilds.

## Instructions

### Requirements

- A Linux virtual machine (or equivalent host) with `docker` and the `docker compose`
  plugin installed.
- `make`.
- A local hosts entry (or DNS record) pointing `ynini.42.fr` to the VM's IP address.

### Build & run

```bash
make          # creates the host data directories and builds/starts every container
```

### Stop

```bash
make down     # stops and removes the containers, keeps images and volumes
```

### Clean

```bash
make clean    # stops everything, removes volumes/images, wipes the host data directory
make fclean   # clean + prunes the whole local Docker system
make re       # fclean + all
```

### Access

Once the stack is up, open:

```
https://ynini.42.fr
```

in a browser. Port 80 (HTTP) is not exposed — only 443 (HTTPS) is. The certificate is
self-signed, so the browser will show a security warning the first time; this is expected.


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)

**How AI was used:** 

- **Learning & Conceptual Understanding:** Used to ask questions and learn low-level concepts regarding container isolation, network bridging, and volume persistence.
- **Debugging & Troubleshooting:** Assisted in debugging configuration anomalies within the custom NGINX setups, MariaDB installation scripts, and system behavior.
- **Documentation Support:** Used AI to improve the clarity, grammar, and structure of the project documentation, including this README.

## Project design choices

### Virtual Machines vs Docker

A virtual machine virtualizes an entire hardware stack and runs a full guest OS on top of
a hypervisor, which makes it heavier to start, to duplicate, and to scale. A Docker
container instead shares the host's kernel and only isolates the process, filesystem, and
network at the OS level, which makes it much lighter and faster to start and to
reproduce. In this project, the VM provides the outer isolation boundary required by the
subject, and Docker is used *inside* that VM to isolate and orchestrate each service
(NGINX, WordPress, MariaDB) independently, without the overhead of one VM per service.

### Secrets vs Environment Variables

Environment variables (here stored in `srcs/.env`) are convenient for non-sensitive
configuration (domain name, database name, usernames) but they are visible in
`docker inspect`, in the container's environment, and can end up in logs — which makes
them a poor fit for actual credentials. Docker secrets, by contrast, are mounted as
in-memory files inside the container (typically under `/run/secrets/`) and are never
exposed through `docker inspect` or process listings, which is the recommended way to
handle passwords and API keys. *(Note: document here which mechanism you actually used
for passwords — the subject expects secrets or an equivalent locally-ignored file for
credentials, on top of the `.env` for non-sensitive values.)*

### Docker Network vs Host Network

With `network: host`, a container shares the host's network namespace directly, which
removes network isolation between the container and the host (and between containers)
and is explicitly forbidden by the subject. A user-defined Docker network (the
`inception` bridge network used here) instead gives each container its own network
namespace, lets containers reach each other by service name through Docker's internal
DNS, and only exposes the ports that are explicitly published — in this project, only
NGINX's port 443 is published to the host, while WordPress and MariaDB stay reachable
only from inside the `inception` network.

### Docker Volumes vs Bind Mounts

A bind mount maps an arbitrary host path directly into the container and is managed
entirely by the user, with no lifecycle management from Docker. A named volume is
created and managed by Docker itself (`docker volume create/inspect/rm`), which makes it
more portable, easier to back up, and safer to reuse across container rebuilds — this is
why the subject requires named volumes rather than bind mounts for the WordPress
database and website files. In this project, `mariadb_data` and `wordpress_data` are
declared as named volumes whose data is stored under `/home/ynini/data` on the host.