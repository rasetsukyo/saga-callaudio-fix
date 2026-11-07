#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rm -f saga-callaudio-fix.zip
zip -r9 saga-callaudio-fix.zip module.prop system -x '*.DS_Store'
echo "built $(pwd)/saga-callaudio-fix.zip"
