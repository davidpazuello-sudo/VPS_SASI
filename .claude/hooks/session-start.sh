#!/bin/bash
set -euo pipefail

# Only relevant in Claude Code on the web (ephemeral remote containers).
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Reinstalls the persistent SASI VPS SSH identity at the start of every
# session, so the server always sees the same key without it having to be
# regenerated (and re-registered with the admin) each time.
if [ -z "${SASI_VPS_SSH_KEY:-}" ]; then
  echo "SASI_VPS_SSH_KEY secret not set; skipping VPS SSH key setup." >&2
  exit 0
fi

mkdir -p ~/.ssh
chmod 700 ~/.ssh

printf '%s\n' "$SASI_VPS_SSH_KEY" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/id_ed25519.pub

# Pin the VPS host key instead of disabling StrictHostKeyChecking, so the
# connection stays protected against MITM while avoiding the interactive
# "are you sure you want to continue connecting?" prompt.
touch ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
if ! ssh-keygen -F 82.29.60.60 -f ~/.ssh/known_hosts >/dev/null 2>&1; then
  ssh-keyscan -H 82.29.60.60 >> ~/.ssh/known_hosts 2>/dev/null || true
fi
