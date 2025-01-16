#!/bin/bash

set -x

# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

docker login -u "$DOCKERHUB_USER" -p "$DOCKERHUB_TOKEN"
docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

docker info

docker buildx create --config "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/buildkitd.toml --name multiarch-builder --driver docker-container --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --use
docker buildx inspect --bootstrap

docker run --privileged --rm "${TORADEX_INTERNAL_DOCKERHUB_CACHE}/tonistiigi/binfmt" --install arm64,arm
