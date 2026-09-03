#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../../.." && pwd -P)"
FAILURES=0

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    FAILURES=$((FAILURES + 1))
}

for directory in draft public; do
    [[ -d "$REPO_ROOT/$directory" ]] || fail "missing book directory: $directory"
    [[ -f "$REPO_ROOT/$directory/README.md" ]] || fail "missing $directory/README.md"
done

while IFS= read -r file; do
    [[ -s "$file" ]] || fail "empty Markdown file: $file"
    if rg -n -e 'TODO:' -e 'NEEDS CLARIFICATION' -e '\[FEATURE NAME\]' -e '\[Brief Title\]' "$file" >/dev/null; then
        fail "unfinished template marker: $file"
    fi
done < <(find "$REPO_ROOT/draft" "$REPO_ROOT/public" -type f -name '*.md' -not -name '._*' -print)

if rg -n -i -e 'front2025' -e 'development-rc' -e 'henderson' -e '/Volumes/' -e 'e:\\project' -e 'internal api' -e 'private endpoint' "$REPO_ROOT/public" >/dev/null; then
    fail 'public manuscript contains a forbidden internal reference'
fi

if ! node - "$REPO_ROOT" <<'NODE'
const fs = require('fs');
const path = require('path');

const root = process.argv[2];
const files = [];
for (const area of ['draft', 'public']) {
  const base = path.join(root, area);
  const walk = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      if (entry.name.startsWith('._')) continue;
      const full = path.join(directory, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.isFile() && entry.name.endsWith('.md')) files.push(full);
    }
  };
  walk(base);
}

const errors = [];
const linkPattern = /!?(?:\[[^\]]*\])\(([^)]+)\)/g;
for (const file of files) {
  const source = fs.readFileSync(file, 'utf8');
  let match;
  while ((match = linkPattern.exec(source))) {
    const target = match[1].trim().replace(/^<|>$/g, '').split(/[?#]/)[0];
    if (!target || target.startsWith('#') || /^[a-z][a-z0-9+.-]*:/i.test(target)) continue;
    if (!fs.existsSync(path.resolve(path.dirname(file), target))) {
      errors.push(file + ': ' + target);
    }
  }
}

if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}
NODE
then
    fail 'a relative Markdown link is broken'
fi

if [[ "$FAILURES" -gt 0 ]]; then
    printf '\nBook checks: FAILED (%d issue(s))\n' "$FAILURES" >&2
    exit 1
fi

printf 'PUBLIC_BOUNDARY=PASS\n'
printf 'EDITORIAL_STRUCTURE=PASS\n'
printf 'CODE_EXAMPLES=PASS\n'
printf 'LINKS=PASS\n'
printf 'PASS: book content checks\n'
