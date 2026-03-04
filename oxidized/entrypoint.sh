#!/bin/sh
set -eu

CONFIG_DIR="/home/oxidized/.config/oxidized"
SSH_DIR="/home/oxidized/.ssh"

mkdir -p "$CONFIG_DIR"
mkdir -p "$SSH_DIR"

# config обязателен
if [ -f /home/oxidized/config ]; then
  cp /home/oxidized/config "$CONFIG_DIR/config"
fi

# router.db может быть либо в образе, либо примонтирован в CONFIG_DIR
if [ -f /home/oxidized/router.db ]; then
  cp /home/oxidized/router.db "$CONFIG_DIR/router.db"
fi

# ssh config опционально
if [ -f /home/oxidized/ssh_config ]; then
  cp /home/oxidized/ssh_config "$SSH_DIR/config"
fi

# Запуск через bundler: гарантирует наличие бинаря
exec bundle exec oxidized