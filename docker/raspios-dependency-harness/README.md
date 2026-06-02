# Raspberry Pi OS dependency harness

This directory contains a Docker-based harness that runs `setup.sh` in a current Raspberry Pi OS-compatible Bookworm userspace and fails with a focused log when Debian, Raspberry Pi OS, or Python dependency resolution breaks.

The harness uses an arm64 Docker build (`--platform linux/arm64`) so `setup.sh` follows its Raspberry Pi code path. It starts from Debian Bookworm, adds the Raspberry Pi package archive, creates the boot files that `setup.sh` edits, and shims hardware/systemd-only commands (`systemctl`, `udevadm`, `usermod`, `logname`) so the build exercises dependency installation rather than failing only because the container is not real hardware.

## Run locally

From the repository root:

```bash
scripts/test-raspios-deps.sh
```

Useful overrides:

```bash
# Rebuild without cache
NO_CACHE=1 scripts/test-raspios-deps.sh

# Use a custom tag or platform
IMAGE_TAG=ugv-rpi:deps PLATFORM=linux/arm64 scripts/test-raspios-deps.sh
```

Requirements:

- Docker with Buildx support.
- QEMU/binfmt support for arm64 when running on a non-arm64 host. Docker Desktop usually enables this. On Linux, install binfmt support or run the included GitHub Actions workflow, which sets it up automatically.

## CI

`.github/workflows/raspios-dependency-harness.yml` runs the same script on pull requests and manual dispatches. The workflow uploads `artifacts/raspios-dependency-harness/docker-build.log` when the build fails so dependency errors are visible without re-running locally.

## Iteration path

1. Run `scripts/test-raspios-deps.sh`.
2. If it fails, read the final 200 lines printed by the Dockerfile and the full log in `artifacts/raspios-dependency-harness/docker-build.log`.
3. Fix the package pin, apt package, or installer step that failed.
4. Re-run with `NO_CACHE=1` when testing changes to apt or pip resolution.
5. Keep hardware-specific commands shimmed in the Dockerfile unless the goal is to test real Raspberry Pi hardware behavior; this harness is specifically for dependency resolution.

## Known limitations

This is not a full hardware integration test. It does not validate camera, serial, udev, audio, or systemd behavior on a physical Raspberry Pi. It is intended to catch dependency drift against current Raspberry Pi OS before testing on real hardware.
