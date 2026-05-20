#!/bin/bash

set -e  # exit on first error
set -vx # show unexpanded and expanded commands before running

PATH="~/.local/bin:${PATH}"
echo "$pwd"

git pull

# TODO: hash comparison

./publish.sh

echo "done!"
