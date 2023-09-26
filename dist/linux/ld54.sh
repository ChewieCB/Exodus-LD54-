#!/bin/sh
echo -ne '\033c\033]0;LD54\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ld54.x86_64" "$@"
