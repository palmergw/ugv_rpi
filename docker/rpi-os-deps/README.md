# Raspberry Pi OS dependency test harness

This repository's `setup.sh` installs Debian/Raspberry Pi OS packages and then
runs `pip install -r requirements.txt` inside a virtual environment. The Docker
harness in this directory checks that those apt packages and Python pins still
resolve on Raspberry Pi OS-compatible Debian bases before the installer is run on
real hardware.

## What it tests

- Builds an arm64 Debian base matching Raspberry Pi OS (`bookworm` by default).
- Installs the apt packages used by `setup.sh`, plus build libraries needed by
  pinned Python packages.
- Creates a virtual environment with `--system-site-packages`, matching
  `setup.sh`.
- Runs `pip install -r requirements.txt` so dependency resolver or wheel/build
  failures are caught in CI.
- Also runs against `trixie` in GitHub Actions to track the latest/next
  Raspberry Pi OS dependency set.

The harness does not run the full `setup.sh` because that script intentionally
edits `/boot`, disables Bluetooth services, copies udev/audio files into system
locations, and changes user groups. Those side effects belong on a Raspberry Pi,
not inside CI.

## Run locally

From the repository root:

```sh
scripts/test-rpi-os-deps.sh          # bookworm, linux/arm64
scripts/test-rpi-os-deps.sh trixie   # latest/next Raspberry Pi OS base
```

To test 32-bit Raspberry Pi OS instead:

```sh
PLATFORM=linux/arm/v7 scripts/test-rpi-os-deps.sh bookworm
```

The script requires Docker with Buildx. Cross-architecture builds need QEMU
registered on the host; the GitHub Actions workflow does this automatically with
`docker/setup-qemu-action`.

## CI

`.github/workflows/rpi-os-deps.yml` runs on pull requests that touch dependency
inputs, weekly on Monday, and on manual dispatch. The matrix tests both:

- `bookworm`: the currently supported Raspberry Pi OS/Debian 12 target reflected
  in `requirements.txt`.
- `trixie`: the latest/next Raspberry Pi OS/Debian 13 target for early warning
  when pinned packages stop resolving.
