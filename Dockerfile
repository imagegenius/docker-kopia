# syntax=docker/dockerfile:1
# check=skip=InvalidDefaultArgInFrom

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# set version label
ARG TARGETARCH
ARG VERSION
LABEL maintainer="hydazz"
LABEL org.opencontainers.image.authors="hydazz"

# environment settings
ENV \
  KOPIA_CONFIG_PATH=/config/repository.config \
  KOPIA_LOG_DIR=/config/log \
  KOPIA_CACHE_DIRECTORY=/cache \
  RCLONE_CONFIG=/config/rclone.conf \
  KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true \
  KOPIA_CHECK_FOR_UPDATES=false

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    apache2-utils \
    curl \
    docker-cli \
    findutils \
    fuse \
    openssl \
    rclone \
    sqlite && \
  echo "**** download kopia ****" && \
  KOPIA_ARCH="${TARGETARCH}" && \
  if [ "${KOPIA_ARCH}" = "amd64" ]; then \
    KOPIA_ARCH="x64"; \
  fi && \
  curl -fsSL "https://github.com/kopia/kopia/releases/download/${VERSION}/kopia-${VERSION#v}-linux-${KOPIA_ARCH}.tar.gz" | \
    tar xzf - -C /usr/local/bin --strip-components 1 && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /root/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 51515
VOLUME /config /source /backups /cache
