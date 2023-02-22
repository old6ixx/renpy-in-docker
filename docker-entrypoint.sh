#!/bin/bash
set -e

# Config exec user
PUID=${PUID:-0}
PGID=${PGID:-0}

groupmod -o -g "$PGID" renpy
usermod -o -u "$PUID" renpy

su renpy -c "./renpy.sh $*"
