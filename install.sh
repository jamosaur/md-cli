#!/bin/sh
# Install the md CLI from GitHub releases.
#
#   curl -fsSL https://raw.githubusercontent.com/jamosaur/md-cli/main/install.sh | sh
#
# Environment:
#   MD_INSTALL_DIR  where to put the binary (default: ~/.local/bin)
#   MD_VERSION      a specific version, e.g. 0.1.0 (default: latest)
set -eu

REPO="jamosaur/md-cli"
INSTALL_DIR="${MD_INSTALL_DIR:-$HOME/.local/bin}"

fail() { echo "md install: $*" >&2; exit 1; }

case "$(uname -s)" in
  Linux) os=linux ;;
  Darwin) os=darwin ;;
  *) fail "unsupported OS $(uname -s); on Windows download the .zip from https://github.com/$REPO/releases" ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) fail "unsupported architecture $(uname -m)" ;;
esac

if [ -n "${MD_VERSION:-}" ]; then
  version="${MD_VERSION#v}"
else
  # The /releases/latest page redirects to /releases/tag/vX.Y.Z.
  url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest")" ||
    fail "couldn't reach GitHub"
  version="${url##*/v}"
  case "$version" in [0-9]*) ;; *) fail "no releases found at https://github.com/$REPO/releases" ;; esac
fi

asset="md-cli_${version}_${os}_${arch}.tar.gz"
base="https://github.com/$REPO/releases/download/v$version"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading md $version for $os/$arch..."
curl -fsSL -o "$tmp/$asset" "$base/$asset" || fail "download failed: $base/$asset"
curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt" || fail "download failed: checksums.txt"

expected="$(grep " $asset\$" "$tmp/checksums.txt" | cut -d' ' -f1)"
[ -n "$expected" ] || fail "$asset is missing from checksums.txt"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$tmp/$asset" | cut -d' ' -f1)"
else
  actual="$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)"
fi
[ "$expected" = "$actual" ] || fail "checksum mismatch for $asset"

tar -xzf "$tmp/$asset" -C "$tmp" md
mkdir -p "$INSTALL_DIR"
mv "$tmp/md" "$INSTALL_DIR/md"
chmod 755 "$INSTALL_DIR/md"

echo "Installed $("$INSTALL_DIR/md" version) to $INSTALL_DIR/md"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Note: $INSTALL_DIR isn't on your PATH. Add it, e.g. export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
echo "Keep it up to date with: md update"
