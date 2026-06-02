#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/test-rpi-os-deps.sh [CODENAME] [--load]

Build the Raspberry Pi OS dependency-resolution Docker harness.

Arguments:
  CODENAME   Debian/Raspberry Pi OS codename to test (default: bookworm).
             Use trixie to exercise the next/latest Raspberry Pi OS base.
  --load     Load the resulting image into the local Docker image store.

Environment overrides:
  PLATFORM   Target platform for Raspberry Pi OS (default: linux/arm64).
  DOCKER     Docker-compatible CLI (default: docker).

Examples:
  scripts/test-rpi-os-deps.sh
  scripts/test-rpi-os-deps.sh trixie
  PLATFORM=linux/arm/v7 scripts/test-rpi-os-deps.sh bookworm
EOF
}

codename="${1:-bookworm}"
load_flag=""
if [[ "${codename}" == "-h" || "${codename}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ "${2:-}" == "--load" || "${1:-}" == "--load" ]]; then
  load_flag="--load"
  if [[ "${1:-}" == "--load" ]]; then
    codename="bookworm"
  fi
fi

platform="${PLATFORM:-linux/arm64}"
docker_cli="${DOCKER:-docker}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v "${docker_cli}" >/dev/null 2>&1; then
  echo "error: ${docker_cli} is not installed or not on PATH" >&2
  exit 127
fi

cd "${repo_root}"
"${docker_cli}" buildx build \
  --platform "${platform}" \
  --progress plain \
  --build-arg "RPI_OS_CODENAME=${codename}" \
  --tag "ugv-rpi-deps:${codename}-${platform//\//-}" \
  ${load_flag:+${load_flag}} \
  -f docker/rpi-os-deps/Dockerfile \
  .
