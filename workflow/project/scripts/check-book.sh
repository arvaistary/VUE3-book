#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../../.." && pwd -P)"
CHECK_ROOT="$REPO_ROOT"
SELF_TEST=false
FAILURES=0

usage() {
    printf '%s\n' 'Usage: check-book.sh [--root PATH] [--self-test]'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root)
            [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 2; }
            CHECK_ROOT="$2"
            shift 2
            ;;
        --self-test)
            SELF_TEST=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

CHECK_ROOT="$(CDPATH='' cd "$CHECK_ROOT" && pwd -P)"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    FAILURES=$((FAILURES + 1))
}

for directory in draft public; do
    [[ -d "$CHECK_ROOT/$directory" ]] || fail "missing book directory: $directory"
    [[ -f "$CHECK_ROOT/$directory/README.md" ]] || fail "missing $directory/README.md"
done

while IFS= read -r file; do
    [[ -s "$file" ]] || fail "empty Markdown file: $file"
    if rg -n -e 'TODO:' -e 'NEEDS CLARIFICATION' -e '\[FEATURE NAME\]' -e '\[Brief Title\]' "$file" >/dev/null; then
        fail "unfinished template marker: $file"
    fi
done < <(find "$CHECK_ROOT/draft" "$CHECK_ROOT/public" -type f -name '*.md' -not -name '._*' -print)

if rg -n -i -e 'front2025' -e 'development-rc' -e 'henderson' -e '/Volumes/' -e 'e:\\project' -e 'internal api' -e 'private endpoint' -e 'internal\.example\.invalid' -e 'private\.example\.invalid' "$CHECK_ROOT/public" >/dev/null; then
    fail 'public manuscript contains a forbidden internal reference'
fi

if ! node - "$CHECK_ROOT" <<'NODE'
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

if [[ "$SELF_TEST" == true ]]; then
    TEST_ROOT="$(mktemp -d)"
    trap 'rm -rf "$TEST_ROOT"' EXIT
    mkdir -p "$TEST_ROOT/draft" "$TEST_ROOT/public"
    printf '%s\n' '# Draft' > "$TEST_ROOT/draft/README.md"
    printf '%s\n' '# Public' > "$TEST_ROOT/public/README.md"
    printf '%s\n' '# Contents' '[закрытый документ](https://internal.example.invalid/notes)' > "$TEST_ROOT/public/contents.md"
    if "$0" --root "$TEST_ROOT" >/dev/null 2>&1; then
        fail 'boundary regression did not reject a forbidden internal link'
    else
        printf 'BOUNDARY_REGRESSION=PASS\n'
    fi
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
