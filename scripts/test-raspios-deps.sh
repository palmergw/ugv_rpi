#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKERFILE="${ROOT_DIR}/docker/raspios-dependency-harness/Dockerfile"
LOG_DIR="${ROOT_DIR}/artifacts/raspios-dependency-harness"
LOG_FILE="${LOG_DIR}/docker-build.log"
IMAGE_TAG="${IMAGE_TAG:-ugv-rpi:raspios-dependency-harness}"
PLATFORM="${PLATFORM:-linux/arm64}"
NO_CACHE="${NO_CACHE:-0}"

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required to run the Raspberry Pi OS dependency harness" >&2
  echo "install Docker with buildx support, then re-run: $0" >&2
  exit 127
fi

mkdir -p "${LOG_DIR}"

build_args=(
  buildx build
  --progress plain
  --platform "${PLATFORM}"
  --file "${DOCKERFILE}"
  --tag "${IMAGE_TAG}"
  --load
)

if [[ "${NO_CACHE}" == "1" ]]; then
  build_args+=(--no-cache)
fi

build_args+=("${ROOT_DIR}")

echo "Running Raspberry Pi OS dependency harness"
echo "  root:      ${ROOT_DIR}"
echo "  platform:  ${PLATFORM}"
echo "  image tag: ${IMAGE_TAG}"
echo "  log:       ${LOG_FILE}"
echo

set +e
docker "${build_args[@]}" 2>&1 | tee "${LOG_FILE}"
status=${PIPESTATUS[0]}
set -e

if [[ "${status}" -ne 0 ]]; then
  echo
  echo "Harness failed with exit status ${status}."
  echo "Inspect the full Docker build log at: ${LOG_FILE}"
  echo "The final Dockerfile step prints the last 200 setup.sh log lines above."
  exit "${status}"
fi

echo
echo "Harness passed. setup.sh completed inside ${PLATFORM} Raspberry Pi OS-compatible container."
echo "Full log: ${LOG_FILE}"
