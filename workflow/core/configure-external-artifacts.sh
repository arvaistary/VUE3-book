#!/usr/bin/env bash

# Bind a sidecar Spec-Kit root to an existing product Git worktree.

set -uo pipefail

PRODUCT_ROOT=""
OVERWRITE=false

usage() {
    printf '%s\n' 'Usage: configure-external-artifacts.sh --product-root PATH [--overwrite]'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --product-root)
            [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 2; }
            PRODUCT_ROOT="$2"
            shift 2
            ;;
        --overwrite)
            OVERWRITE=true
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

[[ -n "$PRODUCT_ROOT" ]] || { usage >&2; exit 2; }
SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SPEC_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../.." && pwd -P)"
PRODUCT_ROOT="$(CDPATH='' cd "$PRODUCT_ROOT" 2>/dev/null && pwd -P)" || {
    printf 'FAIL: product root is not an existing directory: %s\n' "$PRODUCT_ROOT" >&2
    exit 1
}
PRODUCT_GIT_ROOT="$(git -C "$PRODUCT_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
PRODUCT_GIT_ROOT="$(CDPATH='' cd "$PRODUCT_GIT_ROOT" 2>/dev/null && pwd -P)" || {
    printf 'FAIL: product root is not inside a Git worktree: %s\n' "$PRODUCT_ROOT" >&2
    exit 1
}
if [[ "$SPEC_ROOT" == "$PRODUCT_GIT_ROOT" || "$SPEC_ROOT" == "$PRODUCT_GIT_ROOT/"* ]]; then
    printf 'FAIL: sidecar spec root must be outside the product Git worktree\n' >&2
    exit 1
fi

BINDING_FILE="$SPEC_ROOT/.specify/external-project.toml"
if [[ -f "$BINDING_FILE" && "$OVERWRITE" != true ]]; then
    EXISTING_PRODUCT="$(sed -n 's/^product_root[[:space:]]*=[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' "$BINDING_FILE" | head -1)"
    if [[ "$EXISTING_PRODUCT" != "$PRODUCT_ROOT" ]]; then
        printf 'FAIL: external binding already points to another product root; use --overwrite explicitly\n' >&2
        exit 1
    fi
fi

mkdir -p "$(dirname "$BINDING_FILE")"
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$BINDING_FILE" <<EOF
artifact_mode = "external"
spec_root = "$SPEC_ROOT"
product_root = "$PRODUCT_ROOT"
product_git_root = "$PRODUCT_GIT_ROOT"
created_at = "$CREATED_AT"
updated_at = "$CREATED_AT"
EOF

SCANNER_CONFIG="$SPEC_ROOT/.specify/no-trace-patterns.toml"
if [[ ! -f "$SCANNER_CONFIG" && -f "$SPEC_ROOT/.specify/templates/no-trace-patterns-template.toml" ]]; then
    cp "$SPEC_ROOT/.specify/templates/no-trace-patterns-template.toml" "$SCANNER_CONFIG"
fi

printf 'PASS: external artifacts binding\n'
printf 'SPEC_ROOT: %s\nPRODUCT_ROOT: %s\nPRODUCT_GIT_ROOT: %s\n' "$SPEC_ROOT" "$PRODUCT_ROOT" "$PRODUCT_GIT_ROOT"
