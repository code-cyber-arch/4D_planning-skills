#!/bin/sh
# Rebuilds the upload-ready zip for every skill in .claude/skills/.
# Run after editing any SKILL.md, then commit the rebuilt zip(s).
#
#   ./build-zip.sh              rebuild all skills
#   ./build-zip.sh timeline-jsx rebuild one skill
set -e
cd "$(dirname "$0")"

build() {
  name="$1"
  if [ ! -f ".claude/skills/$name/SKILL.md" ]; then
    echo "error: .claude/skills/$name/SKILL.md not found" >&2
    exit 1
  fi
  rm -rf .build && mkdir -p .build
  cp -R ".claude/skills/$name" ".build/$name"
  find .build -name '.DS_Store' -delete
  rm -f "dist/$name.zip"
  mkdir -p dist
  (cd .build && zip -q -r -X "../dist/$name.zip" "$name" -x '.*' '__MACOSX/*')
  rm -rf .build
  echo "Rebuilt dist/$name.zip"
}

if [ $# -gt 0 ]; then
  build "$1"
else
  for d in .claude/skills/*/; do build "$(basename "$d")"; done
fi

echo
ls -lh dist/*.zip
