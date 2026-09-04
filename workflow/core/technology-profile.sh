#!/usr/bin/env bash

# Small, dependency-free reader for a trusted workflow technology profile.
# The file is deliberately not sourced: profile values are data, not shell
# code. Project adapters may use the returned commands with an explicit
# bash -c because commands are part of the repository's trusted adapter.

profile_value() {
    local profile_path="$1"
    local key="$2"

    [[ -f "$profile_path" ]] || return 1
    [[ "$key" =~ ^[A-Z][A-Z0-9_]*$ ]] || return 1

    awk -v wanted="$key" '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        {
            line = $0
            sub(/^[[:space:]]*/, "", line)
            split(line, parts, "=")
            if (parts[1] == wanted) {
                sub(/^[^=]*=/, "", line)
                sub(/[[:space:]]*$/, "", line)
                print line
                exit
            }
        }
    ' "$profile_path"
}

profile_require() {
    local profile_path="$1"
    local key="$2"
    local value

    value="$(profile_value "$profile_path" "$key")"
    [[ -n "$value" ]] || {
        printf 'FAIL: technology profile is missing %s: %s\n' "$key" "$profile_path" >&2
        return 1
    }
    printf '%s' "$value"
}

profile_key_for_artifact_role() {
    local role="$1"
    local normalized

    normalized="$(printf '%s' "$role" | sed 's/[^A-Za-z0-9]/_/g' | tr '[:lower:]' '[:upper:]')"
    [[ -n "$normalized" ]] || return 1
    printf 'ARTIFACT_%s' "$normalized"
}

profile_expand_patterns() {
    local profile_path="$1"
    local patterns="$2"
    local pattern role key resolved

    while IFS= read -r pattern; do
        [[ -n "$pattern" ]] || continue
        if [[ "$pattern" == artifact:* ]]; then
            role="${pattern#artifact:}"
            key="$(profile_key_for_artifact_role "$role")" || return 1
            resolved="$(profile_value "$profile_path" "$key")"
            if [[ -z "$resolved" ]]; then
                printf 'FAIL: technology profile has no mapping for %s (%s)\n' "$pattern" "$key" >&2
                return 1
            fi
            printf '%s\n' "$resolved"
        else
            printf '%s\n' "$pattern"
        fi
    done <<< "$patterns"
}

profile_validate() {
    local profile_path="$1"
    local version profile_id validation_errors

    [[ -f "$profile_path" ]] || {
        printf 'FAIL: technology profile not found: %s\n' "$profile_path" >&2
        return 1
    }
    version="$(profile_value "$profile_path" PROFILE_VERSION)"
    profile_id="$(profile_value "$profile_path" PROFILE_ID)"
    [[ "$version" == '1' ]] || {
        printf 'FAIL: technology profile PROFILE_VERSION must be 1: %s\n' "$profile_path" >&2
        return 1
    }
    [[ -n "$profile_id" ]] || {
        printf 'FAIL: technology profile PROFILE_ID is missing: %s\n' "$profile_path" >&2
        return 1
    }

    if ! validation_errors="$(awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        ! /^[A-Z][A-Z0-9_]*=/ {
            printf "FAIL: invalid technology profile line %d\n", NR
            invalid = 1
            next
        }
        {
            key = $0
            sub(/=.*/, "", key)
            if (seen[key]++) {
                printf "FAIL: duplicate technology profile key: %s\n", key
                invalid = 1
            }
        }
        END { exit(invalid ? 1 : 0) }
    ' "$profile_path")"; then
        printf '%s\n' "$validation_errors" >&2
        return 1
    fi
}
