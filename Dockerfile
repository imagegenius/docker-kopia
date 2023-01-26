FROM ghcr.io/imagegenius/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KOPIA_VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz"

# environment settings
ENV HOME="/tmp" \
  KOPIA_CONFIG_PATH=/config/repository.config \
  KOPIA_LOG_DIR=/config/log \
  KOPIA_CACHE_DIRECTORY=/tmp \
  RCLONE_CONFIG=/config/rclone.conf \
  KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false \
  KOPIA_CHECK_FOR_UPDATES=false

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    make \
    go && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    rclone \
    fuse3 && \
  echo "**** download kopia ****" && \
  mkdir -p \
    /tmp/kopia && \
  if [ -z ${KOPIA_VERSION} ]; then \
    KOPIA_VERSION=$(curl -sL https://api.github.com/repos/kopia/kopia/releases/latest | \
      jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/kopia.tar.gz -L \
    "https://github.com/kopia/kopia/archive/${KOPIA_VERSION}/kopia-${KOPIA_VERSION}.tar.gz" && \
  tar xf \
    /tmp/kopia.tar.gz -C \
    /tmp/kopia --strip-components=1 && \
  cd /tmp/kopia && \
  make install && \
  mv \
    /tmp/go/bin/kopia \
    /app/kopia && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/*

ENV HOME="/config"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 51515
VOLUME /config /source /backups
