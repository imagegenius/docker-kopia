<!-- DO NOT EDIT THIS FILE MANUALLY  -->

# [imagegenius/kopia](https://github.com/imagegenius/docker-kopia)

[![GitHub Release](https://img.shields.io/github/release/imagegenius/docker-kopia.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/imagegenius/docker-kopia/releases)
[![GitHub Package Repository](https://shields.io/badge/GitHub%20Package-blue?logo=github&logoColor=ffffff&style=for-the-badge)](https://github.com/imagegenius/docker-kopia/packages)
[![Jenkins Build](https://img.shields.io/jenkins/build?labelColor=555555&logoColor=ffffff&style=for-the-badge&jobUrl=https%3A%2F%2Fci.imagegenius.io%2Fjob%2FDocker-Pipeline-Builders%2Fjob%2Fdocker-kopia%2Fjob%2Fmain%2F&logo=jenkins)](https://ci.imagegenius.io/job/Docker-Pipeline-Builders/job/docker-kopia/job/main/)
[![IG CI](https://img.shields.io/badge/dynamic/yaml?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=CI&query=CI&url=https%3A%2F%2Fci-tests.imagegenius.io%2Fkopia%2Flatest-main%2Fci-status.yml)](https://ci-tests.imagegenius.io/kopia/latest-main/index.html)

[Kopia](https://kopia.io/) is a fast and secure open-source backup/restore tool that allows you to create encrypted snapshots of your data and save the snapshots to remote or cloud storage of your choice, to network-attached storage or server, or locally on your machine.

[![kopia](https://raw.githubusercontent.com/kopia/kopia/master/icons/kopia.svg)](https://kopia.io/)

## Supported Architectures

We use Docker manifest for cross-platform compatibility. More details can be found on [Docker's website](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

To obtain the appropriate image for your architecture, simply pull `ghcr.io/imagegenius/kopia:latest`. Alternatively, you can also obtain specific architecture images by using tags.

This image supports the following architectures:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | amd64-\<version tag\> |
| arm64 | ✅ | arm64v8-\<version tag\> |
| armhf | ❌ | |

## Usage

Example snippets to start creating a container:

### Docker Compose

```yaml
---
version: "2.1"
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
    volumes:
      - </path/to/appdata>:/config
      - </path/to/source>:/source
      - </path/to/uploads>:/cache
      - </path/to/local>:/local #optional
    ports:
      - 51515:51515
    devices:
      - /dev/fuse:/dev/fuse
    restart: unless-stopped
```

### Docker CLI ([Click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=kopia \
  --hostname=kopia \
  --cap-add=SYS_ADMIN \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e USERNAME=kopia \
  -e PASSWORD=kopia \
  -e KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true `#optional` \
  -p 51515:51515 \
  -v </path/to/appdata>:/config \
  -v </path/to/source>:/source \
  -v </path/to/uploads>:/cache \
  -v </path/to/local>:/local `#optional` \
  --device /dev/fuse:/dev/fuse \
  --restart unless-stopped \
  ghcr.io/imagegenius/kopia:latest

```

## Variables

To configure the container, pass variables at runtime using the format `<external>:<internal>`. For instance, `-p 8080:80` exposes port `80` inside the container, making it accessible outside the container via the host's IP on port `8080`.

| Variable | Description |
| :----: | --- |
| `--hostname=` | Set hostname for the container. |
| `-p 51515` | WebUI Port |
| `-e PUID=1000` | UID for permissions - see below for explanation |
| `-e PGID=1000` | GID for permissions - see below for explanation |
| `-e TZ=Etc/UTC` | Specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e USERNAME=kopia` | Specify a username to access the WebUI |
| `-e PASSWORD=kopia` | Specify the password that you WILL use when creating a repository, this is also the password to access the WebUI |
| `-e KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true` | Automatically connect to repository |
| `-v /config` | Appdata Path |
| `-v /source` | Backup Source Path |
| `-v /cache` | Temporary Uploads Path (Cache) |
| `-v /local` | Path for local filesystem repositories |
| `--device /dev/fuse` | Allows fuse mounts to function |

## Umask for running applications

All of our images allow overriding the default umask setting for services started within the containers using the optional -e UMASK=022 option. Note that umask works differently than chmod and subtracts permissions based on its value, not adding. For more information, please refer to the Wikipedia article on umask [here](https://en.wikipedia.org/wiki/Umask).

## User / Group Identifiers

To avoid permissions issues when using volumes (`-v` flags) between the host OS and the container, you can specify the user (`PUID`) and group (`PGID`). Make sure that the volume directories on the host are owned by the same user you specify, and the issues will disappear.

Example: `PUID=1000` and `PGID=1000`. To find your PUID and PGID, run `id user`.

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Updating the Container

Most of our images are static, versioned, and require an image update and container recreation to update the app. We do not recommend or support updating apps inside the container. Check the [Application Setup](#application-setup) section for recommendations for the specific image.

Instructions for updating containers:

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull kopia`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d kopia`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull ghcr.io/imagegenius/kopia:latest`
* Stop the running container: `docker stop kopia`
* Delete the container: `docker rm kopia`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

## Versions

* **14.04.23:** - BREAKING: move cache from /tmp to /cache.
* **11.04.23:** - fix run script ('kopia server' to 'kopia server start')
* **28.03.23:** - set home in service
* **23.03.23:** - add fuse package
* **21.03.23:** - Add service checks
* **26.01.23:** - Initial release.
