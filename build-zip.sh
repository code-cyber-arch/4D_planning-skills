#!/bin/sh
# Rebuilds timeline-jsx.zip from the source skill file.
# Run this after editing AE/timeline/timeline-jsx-SKILL.md, then commit the zip.
set -e
cd "$(dirname "$0")"
rm -rf .build && mkdir -p .build/timeline-jsx
cp AE/timeline/timeline-jsx-SKILL.md .build/timeline-jsx/SKILL.md
rm -f timeline-jsx.zip
(cd .build && zip -q -r -X ../timeline-jsx.zip timeline-jsx -x '.*' '__MACOSX/*')
rm -rf .build
echo "Rebuilt timeline-jsx.zip"
unzip -l timeline-jsx.zip
