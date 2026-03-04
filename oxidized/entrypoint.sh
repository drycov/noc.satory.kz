#!/bin/sh

CONFIG_DIR=/root/.config/oxidized
ROOT_DIR=/root

mkdir -p $CONFIG_DIR

cp /opt/oxidized/config $CONFIG_DIR/config
cp /opt/oxidized/router.db $CONFIG_DIR/router.db
cp /opt/oxidized/ssh/config $ROOT_DIR/.ssh/config

exec oxidized