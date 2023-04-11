FROM ghcr.io/imagegenius/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KOPIA_VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz"

# environment settings
ENV KOPIA_CONFIG_PATH=/config/repository.config \
  KOPIA_LOG_DIR=/config/log \
  KOPIA_CACHE_DIRECTORY=/tmp \
  RCLONE_CONFIG=/config/rclone.conf \
  KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true \
  KOPIA_CHECK_FOR_UPDATES=false

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    go \
    make && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    fuse3 \
    rclone && \
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
  echo "**** install kopia ****" && \
  cd /tmp/kopia && \
  make install && \
  mv \
    /root/go/bin/kopia \
    /usr/local/bin/kopia && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/go/ \
    /root/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 51515
VOLUME /config /source /backups /tmp
