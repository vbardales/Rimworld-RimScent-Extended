#!/usr/bin/env bash
set -euo pipefail

# Prints the body of the "## [<version>]" section of a Keep a Changelog file, without the heading.
file="${1:?usage: changelog-section.sh CHANGELOG.md X.Y.Z}"
version="${2:?usage: changelog-section.sh CHANGELOG.md X.Y.Z}"

body="$(awk -v heading="## [$version]" '
  index($0, heading) == 1 { found = 1; next }
  found && /^## \[/ { exit }
  found { print }
' "$file" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')"

if [[ -z "${body//[[:space:]]/}" ]]; then
  echo "no non-empty '## [$version]' section in $file" >&2
  exit 1
fi
printf '%s\n' "$body"
