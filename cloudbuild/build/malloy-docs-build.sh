#!/usr/bin/env sh
set -euxo pipefail

nix-shell --quiet --pure --command "$(cat <<NIXCMD
  set -euxo pipefail
  cd /workspace
  npm ci --silent
  gem update --system
  bundle install
  npm run docs-build
NIXCMD
)"
