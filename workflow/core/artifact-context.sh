#!/usr/bin/env bash

# Resolve the workflow artifact root and the product Git worktree.
# This file is intentionally framework- and runtime-neutral.

artifact_canonical_dir() {
    local candidate="$1"
    [[ -d "$candidate" ]] || return 1
    (CDPATH='' cd "$candidate" && pwd -P)
}

artifact_binding_value() {
    local binding_file="$1"
    local key="$2"
    sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*\"\(.*\)\"[[:space:]]*$/\1/p" "$binding_file" | head -1
}

artifact_is_inside_or_equal() {
    local child="$1"
    local parent="$2"
    [[ "$child" == "$parent" || "$child" == "$parent/"* ]]
}

artifact_context_load() {
    local requested_root="$1"
    local binding_file
    local bound_spec_root
    local declared_product_git_root
    local actual_product_git_root
    local product_prefix

    ARTIFACT_SPEC_ROOT="$(artifact_canonical_dir "$requested_root")" || {
        printf 'FAIL: workflow spec root is not a directory: %s\n' "$requested_root" >&2
        return 1
    }
    ARTIFACT_MODE="in-repo"
    ARTIFACT_PRODUCT_ROOT="$ARTIFACT_SPEC_ROOT"
    ARTIFACT_GIT_ROOT="$(git -C "$ARTIFACT_SPEC_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
    ARTIFACT_PATHSPEC="."
    ARTIFACT_PRODUCT_PREFIX=""

    binding_file="$ARTIFACT_SPEC_ROOT/.specify/external-project.toml"
    [[ -f "$binding_file" ]] || {
        [[ -n "$ARTIFACT_GIT_ROOT" ]] || {
            printf 'FAIL: in-repo workflow requires a Git worktree: %s\n' "$ARTIFACT_SPEC_ROOT" >&2
            return 1
        }
        return 0
    }

    [[ "$(artifact_binding_value "$binding_file" artifact_mode)" == external ]] || {
        printf 'FAIL: external binding must declare artifact_mode = "external": %s\n' "$binding_file" >&2
        return 1
    }
    bound_spec_root="$(artifact_canonical_dir "$(artifact_binding_value "$binding_file" spec_root)")" || {
        printf 'FAIL: external binding spec_root is missing or invalid: %s\n' "$binding_file" >&2
        return 1
    }
    [[ "$bound_spec_root" == "$ARTIFACT_SPEC_ROOT" ]] || {
        printf 'FAIL: external binding spec_root does not match the current spec root\n' >&2
        return 1
    }

    ARTIFACT_PRODUCT_ROOT="$(artifact_canonical_dir "$(artifact_binding_value "$binding_file" product_root)")" || {
        printf 'FAIL: external binding product_root is missing or invalid: %s\n' "$binding_file" >&2
        return 1
    }
    declared_product_git_root="$(artifact_canonical_dir "$(artifact_binding_value "$binding_file" product_git_root)")" || {
        printf 'FAIL: external binding product_git_root is missing or invalid: %s\n' "$binding_file" >&2
        return 1
    }
    actual_product_git_root="$(git -C "$ARTIFACT_PRODUCT_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
    actual_product_git_root="$(artifact_canonical_dir "$actual_product_git_root")" || {
        printf 'FAIL: external product root is not inside a Git worktree: %s\n' "$ARTIFACT_PRODUCT_ROOT" >&2
        return 1
    }
    [[ "$declared_product_git_root" == "$actual_product_git_root" ]] || {
        printf 'FAIL: external binding product_git_root does not match Git\n' >&2
        return 1
    }
    artifact_is_inside_or_equal "$ARTIFACT_SPEC_ROOT" "$actual_product_git_root" && {
        printf 'FAIL: external spec root must be outside the product Git worktree\n' >&2
        return 1
    }

    product_prefix="$(git -C "$ARTIFACT_PRODUCT_ROOT" rev-parse --show-prefix 2>/dev/null || true)"
    ARTIFACT_PRODUCT_PREFIX="${product_prefix%/}"
    ARTIFACT_GIT_ROOT="$actual_product_git_root"
    ARTIFACT_PATHSPEC="${ARTIFACT_PRODUCT_PREFIX:-.}"
    ARTIFACT_MODE="external"
}

artifact_product_relative_path() {
    local git_relative_path="$1"
    if [[ "$ARTIFACT_MODE" == external && -n "$ARTIFACT_PRODUCT_PREFIX" ]]; then
        case "$git_relative_path" in
            "$ARTIFACT_PRODUCT_PREFIX"/*)
                printf '%s\n' "${git_relative_path#"$ARTIFACT_PRODUCT_PREFIX"/}"
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    fi
    printf '%s\n' "$git_relative_path"
}

artifact_git() {
    git -C "$ARTIFACT_GIT_ROOT" "$@"
}
