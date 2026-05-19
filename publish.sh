#!/bin/bash

set -e

pdm run mkdocs build
rm -rf /var/www/nerdsquad.xyz
mv ./site /var/www/nerdsquad.xyz
echo "done!"

