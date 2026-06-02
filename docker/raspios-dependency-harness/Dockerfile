# syntax=docker/dockerfile:1.7
#
# Build harness for setup.sh on current Raspberry Pi OS-compatible Bookworm userspace.
# It runs as linux/arm64 so setup.sh's dpkg architecture probe follows the
# Raspberry Pi path instead of trying to edit /proc/cmdline on the host arch.

FROM --platform=$TARGETPLATFORM debian:bookworm-slim AS harness

ARG TARGETPLATFORM=linux/arm64
ARG RASPIOS_CODENAME=bookworm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    PYQT5_LICENSE=accepted \
    USER=pi

# Raspberry Pi OS is Debian plus the Raspberry Pi package archive. Start from
# Debian Bookworm and add archive.raspberrypi.com so packages such as
# libcamera-dev resolve the same way they do on current Raspberry Pi OS.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lua5.4 \
        python3 \
        python3-pip \
        python3-venv \
        sudo \
        time \
    && curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key \
        | gpg --dearmor -o /usr/share/keyrings/raspberrypi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/raspberrypi-archive-keyring.gpg] http://archive.raspberrypi.com/debian/ ${RASPIOS_CODENAME} main" \
        > /etc/apt/sources.list.d/raspi.list \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

# setup.sh legitimately edits boot config and calls host-only service/udev
# commands. Provide container-safe fixtures/shims so dependency installation is
# what fails the build, not the lack of real Pi hardware or systemd.
RUN useradd -m -s /bin/bash pi \
    && mkdir -p /boot/firmware /etc/udev/rules.d /usr/local/harness-bin \
    && printf 'console=ttyAMA0,115200 console=serial0,115200 root=/dev/mmcblk0p2 rw\n' > /boot/firmware/cmdline.txt \
    && printf '# Raspberry Pi firmware config fixture for setup.sh\n' > /boot/firmware/config.txt \
    && ln -sf /usr/bin/lua5.4 /usr/local/bin/lua \
    && printf '#!/bin/sh\necho "[harness] systemctl $*" >&2\nexit 0\n' > /usr/local/harness-bin/systemctl \
    && printf '#!/bin/sh\necho "[harness] udevadm $*" >&2\nexit 0\n' > /usr/local/harness-bin/udevadm \
    && printf '#!/bin/sh\necho "[harness] usermod $*" >&2\nexit 0\n' > /usr/local/harness-bin/usermod \
    && printf '#!/bin/sh\necho pi\n' > /usr/local/harness-bin/logname \
    && chmod +x /usr/local/harness-bin/*

ENV PATH=/usr/local/harness-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /home/pi/ugv_rpi
COPY --chown=pi:pi . /home/pi/ugv_rpi

# Run the real installer and keep enough diagnostics in the Docker log to make
# dependency failures actionable in CI. Do not use --index here; CI should test
# the default upstream Raspberry Pi OS/Debian/PyPI resolution path.
RUN chmod +x ./setup.sh \
    && echo "[harness] target platform: ${TARGETPLATFORM}" \
    && dpkg --print-architecture \
    && /usr/bin/time -v bash -o pipefail -c './setup.sh 2>&1 | tee /var/log/ugv-setup.log' \
    || { status=$?; \
         echo "[harness] setup.sh failed with exit status ${status}"; \
         echo "[harness] last 200 lines from /var/log/ugv-setup.log:"; \
         tail -n 200 /var/log/ugv-setup.log || true; \
         exit "${status}"; \
       }
