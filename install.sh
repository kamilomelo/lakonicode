#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

usage() {
    cat <<'EOF'
Usage: ./install.sh [--dry-run | --replace]

With no options, install new files and safely update unchanged managed files.
  --dry-run  Preview changes without writing anything.
  --replace  Back up and replace locally changed or unowned files.

Only the listed OpenCode files are managed. No files are removed.
EOF
}

apply=true replace=false
for arg in "$@"; do
    case $arg in
        --dry-run) apply=false ;;
        --replace) replace=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
if [[ $replace == true && $apply == false ]]; then
    printf '%s\n' '--dry-run and --replace cannot be combined' >&2
    exit 2
fi

for program in curl mktemp; do
    command -v "$program" >/dev/null || { printf 'Missing required command: %s\n' "$program" >&2; exit 1; }
done
temp=
formatter=$(mktemp "${TMPDIR:-/tmp}/lakonicode-formatter.XXXXXXXX")
cleanup() {
    [[ -z $temp ]] || rm -f -- "$temp"
    rm -f -- "$formatter"
}
trap cleanup EXIT
curl -fsSL --retry 3 https://raw.githubusercontent.com/kamilomelo/kartouche/main/bash/kartouche.sh -o "$formatter"
source "$formatter"
KT_NAME=lakonicode
KT_VERSION=0.1.0
KT_DESCRIPTION='OpenCode file installer'
KT_PAUSE_SECONDS=0

command -v sha256sum >/dev/null || { printf '%s\n' 'sha256sum is required' >&2; exit 1; }
config=${XDG_CONFIG_HOME:-$HOME/.config}/opencode
[[ $config == /* ]] || { printf '%s\n' 'XDG_CONFIG_HOME must be an absolute path' >&2; exit 2; }
manifest=$config/.lakonicode-manifest.tsv
if [[ -L $manifest || ( -e $manifest && ! -f $manifest ) ]]; then
    printf 'Refusing non-regular manifest: %s\n' "$manifest" >&2
    exit 1
fi

files=(
    AGENTS.md
    agents/research.md
    agents/document.md
    skills/lakonic/SKILL.md
    commands/lakonic.md
    commands/lakonic-review.md
    commands/lakonic-audit.md
)

declare -A owned=() actions=() hashes=()
keys=()
if [[ -f $manifest ]]; then
    while IFS=$'\t' read -r path digest extra; do
        if [[ -z $path || ! $digest =~ ^[[:xdigit:]]{64}$ || -n $extra ]]; then
            printf 'Invalid manifest: %s\n' "$manifest" >&2
            exit 1
        fi
        if [[ ! ${owned[$path]+exists} ]]; then keys+=("$path"); fi
        owned[$path]=$digest
    done < "$manifest"
fi

conflicts=0 blocked=0
summary=()
for path in "${files[@]}"; do
    source_file=$root/$path
    [[ -f $source_file && ! -L $source_file ]] || { printf 'Missing source: %s\n' "$source_file" >&2; exit 1; }
    hashes[$path]=$(sha256sum "$source_file")
    hashes[$path]=${hashes[$path]%% *}
    target=$config/$path
    if [[ -L $target || ( -e $target && ! -f $target ) ]]; then
        actions[$path]=blocked
        ((blocked+=1))
    elif [[ ! -e $target ]]; then
        actions[$path]=install
    else
        current=$(sha256sum "$target")
        current=${current%% *}
        if [[ $current == "${hashes[$path]}" ]]; then
            if [[ ${owned[$path]:-} == "$current" ]]; then actions[$path]=unchanged
            else actions[$path]=adopt; fi
        elif [[ ${owned[$path]:-} == "$current" ]]; then
            actions[$path]=update
        else
            actions[$path]=conflict
            ((conflicts+=1))
        fi
    fi
    label=${actions[$path]}
    case $label in
        blocked) outcome=failed ;;
        conflict)
            if [[ $apply == true && $replace == true ]]; then label=replace; outcome=ok
            else outcome=failed; fi
            ;;
        unchanged) outcome=skipped ;;
        *) outcome=ok ;;
    esac
    summary+=("$label $path" "$outcome")
done

if [[ $apply == true ]]; then kt_banner 'Apply'; else kt_banner 'Preview (no changes)'; fi
for path in "${files[@]}"; do
    label=${actions[$path]}
    [[ $label == conflict && $apply == true && $replace == true ]] && label=replace
    printf '  %-9s %s\n' "$label" "$path" >&2
done
kt_summary log "${summary[@]}"

if (( blocked )); then
    printf 'Refusing %d non-regular target(s).\n' "$blocked" >&2
    exit 1
fi
if [[ $apply == false ]]; then
    printf 'Run ./install.sh to install; use --replace for conflicts.\n' >&2
    exit 0
fi
if (( conflicts )) && [[ $replace == false ]]; then
    printf 'No changes made: %d conflict(s). Review them before using --replace.\n' "$conflicts" >&2
    exit 1
fi

changed=false
for path in "${files[@]}"; do
    target=$config/$path
    case ${actions[$path]} in
        unchanged) continue ;;
        adopt) : ;;
        install|update|conflict)
            mkdir -p -- "$(dirname -- "$target")"
            if [[ -e $target ]]; then
                backup=$(mktemp "${target}.bak.XXXXXX")
                cp -p -- "$target" "$backup" || { rm -f -- "$backup"; exit 1; }
                printf 'Backup: %s\n' "$backup" >&2
            fi
            temp=$(mktemp "${target}.tmp.XXXXXX")
            cp -- "$root/$path" "$temp"
            chmod 0644 "$temp"
            mv -f -- "$temp" "$target"
            temp=
            ;;
    esac
    if [[ ! ${owned[$path]+exists} ]]; then keys+=("$path"); fi
    owned[$path]=${hashes[$path]}
    changed=true
done

if [[ $changed == true ]]; then
    mkdir -p -- "$config"
    temp=$(mktemp "$manifest.tmp.XXXXXX")
    for path in "${keys[@]}"; do printf '%s\t%s\n' "$path" "${owned[$path]}" >> "$temp"; done
    chmod 0600 "$temp"
    mv -f -- "$temp" "$manifest"
    temp=
fi
printf 'Done. %s\n' "$([[ $changed == true ]] && printf 'Managed files recorded.' || printf 'Nothing changed.')" >&2
