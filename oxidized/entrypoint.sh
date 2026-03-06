#!/bin/sh
set -eu

CONFIG_DIR="/home/oxidized/.config/oxidized"
SSH_DIR="/home/oxidized/.ssh"

mkdir -p "$CONFIG_DIR"
mkdir -p "$SSH_DIR"

if [ -f /home/oxidized/config ]; then
  cp /home/oxidized/config "$CONFIG_DIR/config"
fi

if [ -f /home/oxidized/router.db ]; then
  cp /home/oxidized/router.db "$CONFIG_DIR/router.db"
fi

if [ -f /home/oxidized/ssh/config ]; then
  cp /home/oxidized/ssh/config "$SSH_DIR/config"
fi

chmod 700 "$SSH_DIR" || true
chmod 600 "$SSH_DIR/config" 2>/dev/null || true

exec bundle exec oxidized