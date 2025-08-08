#!/usr/bin/env bash
# Copyright 2025 Daytona Platforms Inc.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

echo "→ build-sdk"

# Ensure we are in libs/sdk-python
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}/.."

# If a version is provided via env, update [project] version in pyproject.toml
if [[ -n "${PYPI_PKG_VERSION:-}" || -n "${DEFAULT_PACKAGE_VERSION:-}" ]]; then
  VER="${PYPI_PKG_VERSION:-$DEFAULT_PACKAGE_VERSION}"
  echo "Setting version=${VER} in pyproject.toml"
  sed -i -E "s/^version = \".*\"/version = \"${VER}\"/" pyproject.toml
else
  echo "Using version from pyproject.toml"
fi

# Ensure build tool is available (PEP 517 frontend)
python -m pip install --upgrade build >/dev/null 2>&1 || true

# Build package with current name (daytona)
python -m build

# Build alternative package name (daytona_sdk)
ORIGINAL_NAME="daytona"
ALT_NAME="daytona_sdk"

cleanup() {
  # Revert file/folder renames if needed
  if [[ -d "src/${ALT_NAME}" ]]; then
    mv "src/${ALT_NAME}" "src/${ORIGINAL_NAME}" || true
  fi
  sed -i -E "s/^name = \".*\"/name = \"${ORIGINAL_NAME}\"/" pyproject.toml 2>/dev/null || true
}
trap cleanup EXIT

mv "src/${ORIGINAL_NAME}" "src/${ALT_NAME}"
sed -i -E "s/^name = \".*\"/name = \"${ALT_NAME}\"/" pyproject.toml
python -m build

# Explicitly cleanup and disable trap
cleanup
trap - EXIT
