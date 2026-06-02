# syntax=docker/dockerfile:1.7
#
# Dependency-resolution harness for the UGV Raspberry Pi setup.
#
# Build with linux/arm64 to match current 64-bit Raspberry Pi OS:
#   docker buildx build --platform linux/arm64 \
#     --build-arg RPI_OS_CODENAME=bookworm \
#     -f docker/rpi-os-deps/Dockerfile .
#
# RPI_OS_CODENAME can also be set to trixie to test the next/latest
# Raspberry Pi OS dependency set as it becomes available.

ARG RPI_OS_CODENAME=bookworm
ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM:-linux/arm64} debian:${RPI_OS_CODENAME}-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    VIRTUAL_ENV=/opt/ugv-env \
    PATH=/opt/ugv-env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /src

# Keep this list aligned with setup.sh's apt installs plus build/runtime
# libraries needed by pinned Python packages during pip dependency resolution.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      build-essential \
      pkg-config \
      git \
      gobject-introspection \
      lua5.4 \
      python3 \
      python3-apt \
      python3-dev \
      python3-opencv \
      python3-pip \
      python3-venv \
      arandr \
      dnsmasq \
      espeak \
      ffmpeg \
      haveged \
      hostapd \
      iproute2 \
      iptables \
      iw \
      libatlas3-base \
      libavcodec-dev \
      libavdevice-dev \
      libavfilter-dev \
      libavformat-dev \
      libavutil-dev \
      libcamera-dev \
      libdbus-1-dev \
      libcairo2-dev \
      libgirepository1.0-dev \
      libglib2.0-dev \
      libjpeg-dev \
      libopenblas-dev \
      libportaudio2 \
      libsm6 \
      libsrtp2-dev \
      libssl-dev \
      libswresample-dev \
      libswscale-dev \
      libudev-dev \
      libxext6 \
      libxrender1 \
      portaudio19-dev \
      procps \
      util-linux && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt setup.sh ./

# Fail fast if setup.sh drifts away from the harness' apt-package model.
RUN python3 - <<'PY'
from pathlib import Path
import re
text = Path('setup.sh').read_text()
# Join shell continuations so multi-line apt commands are checked too.
logical = re.sub(r'\\\n\s*', ' ', text)
required = {
    'libopenblas-dev', 'libatlas3-base', 'libcamera-dev', 'python3-opencv',
    'portaudio19-dev', 'arandr', 'util-linux', 'procps', 'hostapd',
    'iproute2', 'iw', 'haveged', 'dnsmasq', 'iptables', 'espeak', 'ffmpeg',
    'libavformat-dev', 'libavcodec-dev', 'libavdevice-dev', 'libavutil-dev',
    'libavfilter-dev', 'libswscale-dev', 'libswresample-dev',
}
found = set()
for cmd in re.findall(r'(?:sudo\s+)?apt\s+install\s+([^\n]+)', logical):
    cmd = cmd.split('#', 1)[0]
    for token in re.split(r'\s+', cmd):
        if token and not token.startswith('-'):
            found.add(token)
missing = sorted(required - found)
if missing:
    raise SystemExit(f'setup.sh no longer contains expected apt packages: {missing}')
print('setup.sh apt package sanity check passed')
PY

# Use --system-site-packages like setup.sh so Debian/Raspberry Pi packages such as
# python3-opencv can satisfy imports while pip resolves the remaining pins.
RUN python3 -m venv --system-site-packages "$VIRTUAL_ENV" && \
    python -m pip install --upgrade pip setuptools wheel

# Resolve/install the pinned Python set. This intentionally performs the same
# dependency-resolution path as setup.sh's pip install; failures here mean the
# current Raspberry Pi OS base cannot satisfy requirements.txt as-is.
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    pip install -r requirements.txt
