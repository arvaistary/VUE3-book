#!/usr/bin/env bash

# Deterministic scanner for workflow traces in an isolated Git worktree.
# It scans only the checked changes and never writes to that worktree.

set -uo pipefail

SPEC_ROOT=""
FINDINGS=0

usage() {
    printf '%s\n' 'Usage: check-no-trace.sh [--spec-root PATH]'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --spec-root)
            [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 2; }
            SPEC_ROOT="$2"
            shift 2
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

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
WORKFLOW_ROOT="$(CDPATH='' cd "$SCRIPT_DIR/../.." && pwd -P)"
[[ -n "$SPEC_ROOT" ]] || SPEC_ROOT="$WORKFLOW_ROOT"
source "$SCRIPT_DIR/artifact-context.sh"
artifact_context_load "$SPEC_ROOT" || exit 2

if [[ "$ARTIFACT_MODE" != external ]]; then
    printf 'PASS: no-trace scan skipped (artifact mode: in-repo)\n'
    exit 0
fi

CONFIG="$ARTIFACT_SPEC_ROOT/.specify/no-trace-patterns.toml"
if [[ ! -f "$CONFIG" ]]; then
    printf 'FAIL: isolated mode requires scanner config: %s\n' "$CONFIG" >&2
    exit 2
fi

parse_array() {
    local key="$1"
    awk -v wanted="$key" '
        function emit(line, start, match_len, value) {
            while (match(line, /"[^"]*"/)) {
                start = RSTART
                match_len = RLENGTH
                value = substr(line, start + 1, match_len - 2)
                print value
                line = substr(line, start + match_len)
            }
        }
        {
            line = $0
            if (!reading && line ~ "^[[:space:]]*" wanted "[[:space:]]*=") reading = 1
            if (reading) {
                emit(line)
                if (index(line, "]") > 0) reading = 0
            }
        }
    ' "$CONFIG"
}

PATH_PATTERNS=()
CONTENT_PATTERNS=()
while IFS= read -r value; do [[ -n "$value" ]] && PATH_PATTERNS+=("$value"); done < <(parse_array path_patterns)
while IFS= read -r value; do [[ -n "$value" ]] && CONTENT_PATTERNS+=("$value"); done < <(parse_array content_patterns)
[[ ${#PATH_PATTERNS[@]} -gt 0 ]] || { printf 'FAIL: scanner config has no path_patterns\n' >&2; exit 2; }
[[ ${#CONTENT_PATTERNS[@]} -gt 0 ]] || { printf 'FAIL: scanner config has no content_patterns\n' >&2; exit 2; }

CASE_SETTING="$(sed -n 's/^[[:space:]]*case_insensitive_content[[:space:]]*=[[:space:]]*\(.*\)[[:space:]]*$/\1/p' "$CONFIG" | head -1 | tr -d '[:space:]')"
MAX_BYTES="$(sed -n 's/^[[:space:]]*text_file_max_bytes[[:space:]]*=[[:space:]]*\([0-9][0-9]*\)[[:space:]]*$/\1/p' "$CONFIG" | head -1)"
if [[ -z "$CASE_SETTING" ]]; then
    CASE_INSENSITIVE=true
else
    case "$CASE_SETTING" in
        true|false) CASE_INSENSITIVE="$CASE_SETTING" ;;
        *) printf 'FAIL: invalid case_insensitive_content\n' >&2; exit 2 ;;
    esac
fi
[[ -n "$MAX_BYTES" ]] || MAX_BYTES=1048576
[[ "$MAX_BYTES" =~ ^[0-9]+$ && "$MAX_BYTES" -gt 0 ]] || { printf 'FAIL: invalid text_file_max_bytes\n' >&2; exit 2; }

finding() {
    local source="$1"
    local path="$2"
    local pattern="$3"
    local line="${4:-}"
    if [[ -n "$line" ]]; then
        printf 'FINDING: %s %s:%s [%s]\n' "$source" "$path" "$line" "$pattern"
    else
        printf 'FINDING: %s %s [%s]\n' "$source" "$path" "$pattern"
    fi
    FINDINGS=$((FINDINGS + 1))
}

path_matches() {
    local path="$1"
    local pattern="$2"
    local stripped="${pattern%/}"
    [[ "$path" == "$stripped" || "$path" == "$pattern"* || "$path" == */"$pattern"* || "$path" == */"$stripped" ]]
}

content_matches() {
    local content="$1"
    local pattern="$2"
    if [[ "$CASE_INSENSITIVE" == true ]]; then
        printf '%s\n' "$content" | LC_ALL=C grep -Fqi -- "$pattern"
    else
        printf '%s\n' "$content" | LC_ALL=C grep -Fq -- "$pattern"
    fi
}

scan_path_list() {
    local source="$1"
    local git_path
    local product_path
    shift
    while IFS= read -r git_path; do
        [[ -n "$git_path" ]] || continue
        product_path="$(artifact_product_relative_path "$git_path" 2>/dev/null || true)"
        [[ -n "$product_path" ]] || continue
        for pattern in "${PATH_PATTERNS[@]}"; do
            if path_matches "$product_path" "$pattern"; then
                finding "$source" "$product_path" "$pattern"
            fi
        done
    done < <(artifact_git "$@" -- "$ARTIFACT_PATHSPEC")
}

scan_diff_content() {
    local source="$1"
    local diff_text
    local line
    local current_path=""
    local current_line=""
    local git_path
    local product_path
    local added
    shift
    diff_text="$(artifact_git "$@" --unified=0 -- "$ARTIFACT_PATHSPEC")"
    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            '+++ b/'*)
                git_path="${line#+++ b/}"
                product_path="$(artifact_product_relative_path "$git_path" 2>/dev/null || true)"
                current_path="$product_path"
                current_line=""
                ;;
            '@@ '*)
                current_line=""
                for part in $line; do
                    case "$part" in
                        +[0-9]*)
                            current_line="${part#+}"
                            current_line="${current_line%%,*}"
                            ;;
                    esac
                done
                ;;
            +++*) ;;
            +*)
                [[ -n "$current_path" && -n "$current_line" ]] || continue
                added="${line:1}"
                for pattern in "${CONTENT_PATTERNS[@]}"; do
                    if content_matches "$added" "$pattern"; then
                        finding "$source" "$current_path" "$pattern" "$current_line"
                    fi
                done
                current_line=$((current_line + 1))
                ;;
            -*) ;;
            *)
                [[ -n "$current_line" ]] || continue
                current_line=$((current_line + 1))
                ;;
        esac
    done <<< "$diff_text"
}

scan_untracked_content() {
    local git_path
    local product_path
    local absolute_path
    local byte_count
    local line_number
    local content
    while IFS= read -r git_path; do
        [[ -n "$git_path" ]] || continue
        product_path="$(artifact_product_relative_path "$git_path" 2>/dev/null || true)"
        [[ -n "$product_path" ]] || continue
        absolute_path="$ARTIFACT_PRODUCT_ROOT/$product_path"
        [[ -f "$absolute_path" ]] || continue
        byte_count="$(wc -c < "$absolute_path" | tr -d ' ')"
        [[ "$byte_count" =~ ^[0-9]+$ && "$byte_count" -le "$MAX_BYTES" ]] || continue
        if LC_ALL=C grep -Iq . "$absolute_path" 2>/dev/null; then
            line_number=0
            while IFS= read -r content || [[ -n "$content" ]]; do
                line_number=$((line_number + 1))
                for pattern in "${CONTENT_PATTERNS[@]}"; do
                    if content_matches "$content" "$pattern"; then
                        finding 'untracked-content' "$product_path" "$pattern" "$line_number"
                    fi
                done
            done < "$absolute_path"
        else
            for pattern in "${CONTENT_PATTERNS[@]}"; do
                if LC_ALL=C grep -aFqi -- "$pattern" "$absolute_path" 2>/dev/null; then
                    finding 'untracked-content' "$product_path" "$pattern"
                fi
            done
        fi
    done < <(artifact_git ls-files --others --exclude-standard -- "$ARTIFACT_PATHSPEC")
}

scan_path_list staged-path diff --cached --name-only
scan_path_list unstaged-path diff --name-only
scan_path_list untracked-path ls-files --others --exclude-standard
scan_diff_content staged-diff diff --cached
scan_diff_content unstaged-diff diff
scan_untracked_content

if [[ "$FINDINGS" -gt 0 ]]; then
    printf 'No-trace scan: FAILED (%d finding(s))\n' "$FINDINGS" >&2
    exit 1
fi
printf 'No-trace scan: PASSED (%s)\n' "$ARTIFACT_PRODUCT_ROOT"
