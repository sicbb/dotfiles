#!/usr/bin/env bash
set -euo pipefail

# --- config: adjust these two paths to match your setup ---
REMOTE_PATH="/my-files/Private/KeePass/pass.kdbx"
LOCAL_PATH="$HOME/Downloads/pass.kdbx"
# ------------------------------------------------------------

usage() {
    echo "Usage: $(basename "$0") {pull|push}"
    echo "  pull  Download vault from Proton Drive to local disk"
    echo "  push  Upload local vault to Proton Drive (overwrites remote)"
    exit 1
}

pull() {
    local dest_dir
    dest_dir="$(dirname "$LOCAL_PATH")"
    mkdir -p "$dest_dir"

    local tmp_dir
    tmp_dir="$(mktemp -d)"

    echo "Downloading $REMOTE_PATH ..."
    proton-drive fs download "$REMOTE_PATH" "$tmp_dir"

    local filename
    filename="$(basename "$REMOTE_PATH")"
    mv -f "$tmp_dir/$filename" "$LOCAL_PATH"
    rmdir "$tmp_dir"

    echo "Saved to $LOCAL_PATH"
}

push() {
    if [[ ! -f "$LOCAL_PATH" ]]; then
        echo "Local file not found: $LOCAL_PATH" >&2
        exit 1
    fi

    local remote_dir
    remote_dir="$(dirname "$REMOTE_PATH")"

    echo "Uploading $LOCAL_PATH ..."
    proton-drive fs upload "$LOCAL_PATH" "$remote_dir" --file-conflict-strategy replace

    echo "Uploaded to $REMOTE_PATH"
}

case "${1:-}" in
    pull) pull ;;
    push) push ;;
    *) usage ;;
esac
