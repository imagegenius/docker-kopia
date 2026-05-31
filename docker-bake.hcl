target "docker-metadata-action" {}

variable "APP" {
  default = "kopia"
}

variable "BASE_IMAGE" {
  # renovate: datasource=docker depName=ghcr.io/linuxserver/baseimage-alpine versioning=docker
  default = "ghcr.io/linuxserver/baseimage-alpine:edge@sha256:1057860e846ec83fd3dfdb2b01af36c405e6079bdccfb36642cc5161e2bb41cf"
}

variable "VERSION" {
  # renovate: datasource=github-releases depName=kopia/kopia
  default = "v0.23.0"
}

variable "SOURCE" {
  default = "https://github.com/kopia/kopia"
}

group "default" {
  targets = ["image-local"]
}

target "image-base" {
  inherits = ["docker-metadata-action"]
  args = {
    APP        = "${APP}"
    BASE_IMAGE = "${BASE_IMAGE}"
    VERSION    = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

target "image" {
  inherits  = ["image-base"]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "image-local" {
  inherits = ["image-base"]
  output   = ["type=docker"]
  tags     = ["${APP}:local"]
}
