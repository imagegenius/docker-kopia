target "docker-metadata-action" {}

variable "APP" {
  default = "kopia"
}

variable "VERSION" {
  # renovate: datasource=github-releases depName=kopia/kopia
  default = "v0.23.1"
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
    APP     = "${APP}"
    VERSION = "${VERSION}"
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
