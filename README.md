# [imagegenius/kopia](https://github.com/imagegenius/docker-kopia)

[![GitHub Release](https://img.shields.io/github/release/imagegenius/docker-kopia.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/imagegenius/docker-kopia/releases)
[![GitHub Package Repository](https://shields.io/badge/GitHub%20Package-blue?logo=github&logoColor=ffffff&style=for-the-badge)](https://github.com/imagegenius/docker-kopia/packages)

Kopia is a fast and secure open-source backup/restore tool that allows you to create encrypted snapshots of your data and save the snapshots to remote or cloud storage of your choice, to network-attached storage or server, or locally on your machine.

[![kopia](https://raw.githubusercontent.com/kopia/kopia/master/icons/kopia.svg)](https://kopia.io/)

## Variants

| Tag      | Description                   | Platforms    |
| -------- | ----------------------------- | ------------ |
| `latest` | Alpine + latest Kopia release | amd64, arm64 |

Pin a specific upstream Kopia release with the semver tag:

```text
ghcr.io/imagegenius/kopia:0.23.0
```

## Requirements

- **Config volume**: mount `/config` for Kopia repository config, logs, and credentials.
- **FUSE**: mount `/dev/fuse` and add `SYS_ADMIN` if using filesystem mounts.
- **Credentials**: set `USERNAME` and `PASSWORD` on first start to generate `/config/htpasswd`.

## Usage

### Docker Compose

```yaml
---
services:
  kopia:
    image: ghcr.io/imagegenius/kopia:latest
    container_name: kopia
    hostname: kopia
    cap_add:
      - SYS_ADMIN
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - USERNAME=kopia
      - PASSWORD=kopia
      - KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true #optional
      - CLI_ARGS= #optional
    volumes:
      - path_to_appdata:/config
      - path_to_source:/source
      - path_to_cache:/cache
      - path_to_local:/local #optional
    ports:
      - 51515:51515
    devices:
      - /dev/fuse:/dev/fuse
    restart: unless-stopped
```

## Parameters

| Parameter                                      | Function                                                                                     |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `--hostname=kopia`                             | Container hostname                                                                           |
| `--cap-add=SYS_ADMIN`                          | Required for FUSE mounts                                                                     |
| `--device /dev/fuse:/dev/fuse`                 | Allows FUSE mounts to function                                                              |
| `-p 51515`                                     | WebUI port                                                                                   |
| `-e PUID=1000`                                 | UID for permissions — see below                                                              |
| `-e PGID=1000`                                 | GID for permissions — see below                                                              |
| `-e TZ=Etc/UTC`                                | Timezone, see [this list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `-e USERNAME=kopia`                            | Username used to generate `/config/htpasswd` on first start                                  |
| `-e PASSWORD=kopia`                            | Password used to generate `/config/htpasswd` on first start                                  |
| `-e KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true` | Persist repository credentials after connect                                                 |
| `-e CLI_ARGS=`                                 | Override arguments after the `kopia` command                                                 |
| `-v /config`                                   | Kopia config, logs, and htpasswd                                                            |
| `-v /source`                                   | Backup source path                                                                           |
| `-v /cache`                                    | Temporary upload/cache path                                                                  |
| `-v /local`                                    | Local filesystem repository path                                                             |

## Application Setup

By default, Kopia starts with:

```bash
kopia server start \
  --insecure \
  --disable-csrf-token-checks \
  --address=0.0.0.0:51515 \
  --htpasswd-file /config/htpasswd
```

Set `CLI_ARGS` to override the arguments after `kopia`. Keep `CLI_ARGS` on one line.

## User / Group IDs & umask

Set `PUID=1000` `PGID=1000` to match volume ownership on the host (`id user` to find yours). Optionally `UMASK=022` (works subtractively, not additively).

## Updating

```bash
docker pull ghcr.io/imagegenius/kopia:latest
docker stop kopia && docker rm kopia
# recreate with the same docker run parameters
docker image prune  # optional: remove dangling images
```

Or with compose: `docker compose pull && docker compose up -d`.

## Support

- Issues: <https://github.com/imagegenius/docker-kopia/issues>
- Kopia: <https://kopia.io/>

## How this image is built

This repo is built with GitHub Actions, based on the workflow shape from [home-operations/containers](https://github.com/home-operations/containers).

- The container starts from [linuxserver/docker-baseimage-alpine](https://github.com/linuxserver/docker-baseimage-alpine).
- Kopia is installed from the upstream release tarball pinned in [`docker-bake.hcl`](docker-bake.hcl).
- Version and base-image inputs are selected by [`docker-bake.hcl`](docker-bake.hcl).
- s6-overlay bits live under [`root/`](root).
- Renovate tracks Kopia and build input bumps from the bake annotations.
