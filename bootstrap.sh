#!/usr/bin/env bash
# Remote entrypoint: curl -fsSL https://raw.githubusercontent.com/kamilomelo/lakonicode/main/bootstrap.sh | bash
set -euo pipefail

repo=${LAKONICODE_REPOSITORY:-kamilomelo/lakonicode}
ref=${LAKONICODE_REF:-main}
if [[ ! $repo =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ || ! $ref =~ ^[a-zA-Z0-9._/-]+$ || $ref == *..* ]]; then
    printf '%s\n' 'Invalid repository or ref' >&2
    exit 2
fi
for program in curl tar mktemp; do
    command -v "$program" >/dev/null || { printf 'Missing required command: %s\n' "$program" >&2; exit 1; }
done

temporary=$(mktemp -d "${TMPDIR:-/tmp}/lakonicode.XXXXXXXX")
trap 'rm -rf -- "$temporary"' EXIT
url=${LAKONICODE_ARCHIVE_URL:-https://codeload.github.com/$repo/tar.gz/$ref}
printf 'Downloading %s at %s\n' "$repo" "$ref" >&2
curl -fsSL --retry 3 "$url" -o "$temporary/repo.tar.gz"
mkdir "$temporary/repo"
tar -xzf "$temporary/repo.tar.gz" -C "$temporary/repo" --strip-components=1
[[ -f $temporary/repo/install.sh ]] || {
    printf '%s\n' 'Download is missing the installer' >&2
    exit 1
}
bash "$temporary/repo/install.sh" "$@"
