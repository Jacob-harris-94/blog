#!/bin/bash

set -e  # exit on first error
set -vx # show unexpanded and expanded commands before running

PATH="~/.local/bin:${PATH}"
echo "$pwd"

HASH_BEFORE=$(git rev-parse --short HEAD)

git pull

HASH_AFTER=$(git rev-parse --short HEAD)

if [ "$HASH_BEFORE" = "$HASH_AFTER" ]; then
	echo "no change, exiting" && exit 0
fi

./publish.sh

echo "done!"
