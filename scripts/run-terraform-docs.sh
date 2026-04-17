#!/usr/bin/env sh

set -eu

VERSION="v0.20.0"

ROOT_DIR=$(
  CDPATH= cd -- "$(dirname -- "$0")/.." && pwd
)
BIN_DIR="$ROOT_DIR/.tools/bin"
PINNED_BIN="$BIN_DIR/terraform-docs-$VERSION"

version_matches() {
  "$1" --version 2>/dev/null | grep -q "terraform-docs version $VERSION"
}

download_pinned_binary() {
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)

  case "$os" in
    darwin|linux) ;;
    *)
      echo "unsupported OS: $os" >&2
      exit 1
      ;;
  esac

  case "$arch" in
    x86_64|amd64)
      arch="amd64"
      ;;
    arm64|aarch64)
      arch="arm64"
      ;;
    *)
      echo "unsupported architecture: $arch" >&2
      exit 1
      ;;
  esac

  archive=$(mktemp "${TMPDIR:-/tmp}/terraform-docs.XXXXXX.tar.gz")
  trap 'rm -f "$archive"' EXIT HUP INT TERM

  mkdir -p "$BIN_DIR"

  curl -fsSL \
    -o "$archive" \
    "https://github.com/terraform-docs/terraform-docs/releases/download/$VERSION/terraform-docs-$VERSION-$os-$arch.tar.gz"
  tar -xzf "$archive" -C "$BIN_DIR" terraform-docs
  mv "$BIN_DIR/terraform-docs" "$PINNED_BIN"
  chmod +x "$PINNED_BIN"
}

if [ -n "${TERRAFORM_DOCS_BIN:-}" ]; then
  exec "$TERRAFORM_DOCS_BIN" "$@"
fi

if [ -x "$PINNED_BIN" ] && version_matches "$PINNED_BIN"; then
  exec "$PINNED_BIN" "$@"
fi

if command -v terraform-docs >/dev/null 2>&1 && version_matches "$(command -v terraform-docs)"; then
  exec "$(command -v terraform-docs)" "$@"
fi

download_pinned_binary
exec "$PINNED_BIN" "$@"
