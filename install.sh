#!/usr/bin/env bash
# Links the dotfiles into $HOME with GNU Stow.
#
# Usage:
#   ./install.sh                 link all packages
#   ./install.sh hyprland bash   link only the named packages
#   ./install.sh -n              dry run: show what would happen
#   ./install.sh -u [pkg...]     remove the links again
#   ./install.sh --no-deps       skip installing the packages the configs need
#
# Missing system packages the configs need (see DEPS below) are installed with
# pacman after asking. Real files that are in the way are moved to
# ~/.dotfiles-backup-<timestamp> before linking, so nothing gets overwritten.

set -euo pipefail

# System packages each dotfiles package needs, installed with pacman.
declare -A DEPS=(
  [ghostty]="ghostty ttf-cascadia-mono-nerd"
  [starship]="starship"
  [brave]="brave-origin-bin"
)

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
cd "$DOTFILES" # stow reads .stowrc (target, no-folding) from here

dry_run=false
install_deps=true
mode=stow
packages=()

for arg in "$@"; do
  case "$arg" in
    -n | --dry-run) dry_run=true ;;
    -u | --uninstall) mode=unstow ;;
    --no-deps) install_deps=false ;;
    -h | --help)
      sed -n '2,14s/^# \{0,1\}//p' "$0"
      exit 0
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
    *) packages+=("${arg%/}") ;;
  esac
done

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is not installed." >&2
  if command -v pacman >/dev/null 2>&1; then
    read -rp "Install it with 'sudo pacman -S stow'? [Y/n] " answer
    [[ "${answer:-y}" =~ ^[Yy]$ ]] || exit 1
    sudo pacman -S --needed stow
  else
    echo "Install stow with your package manager and run this again." >&2
    exit 1
  fi
fi

if [ ${#packages[@]} -eq 0 ]; then
  for dir in */; do packages+=("${dir%/}"); done
fi

for pkg in "${packages[@]}"; do
  if [ ! -d "$pkg" ]; then
    echo "No such package: $pkg" >&2
    exit 1
  fi
done

stow_flags=(-v)
$dry_run && stow_flags+=(-n)

if [ "$mode" = unstow ]; then
  stow "${stow_flags[@]}" -D "${packages[@]}"
  exit 0
fi

# Install the system packages the selected configs need.
if $install_deps; then
  missing=()
  for pkg in "${packages[@]}"; do
    for dep in ${DEPS[$pkg]:-}; do
      if ! pacman -Q "$dep" >/dev/null 2>&1 && [[ ! " ${missing[*]} " == *" $dep "* ]]; then
        missing+=("$dep")
      fi
    done
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing packages: ${missing[*]}"
    if $dry_run; then
      echo "INSTALL (dry run): sudo pacman -S --needed ${missing[*]}"
    elif ! command -v pacman >/dev/null 2>&1; then
      echo "pacman not found; install them manually." >&2
    else
      read -rp "Install them with pacman? [Y/n] " answer
      if [[ "${answer:-y}" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed "${missing[@]}"
      else
        echo "Skipping package installation."
      fi
    fi
  fi
fi

# Move anything out of the way that stow would refuse to replace: real files,
# and symlinks that point somewhere other than this repo.
backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
backed_up=0

for pkg in "${packages[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$pkg"/}"
    target="$HOME/$rel"

    if [ -L "$target" ]; then
      [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ] && continue
    elif [ ! -e "$target" ]; then
      continue
    fi

    if $dry_run; then
      echo "BACKUP (dry run): ~/$rel"
    else
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target" "$backup/$rel"
      echo "BACKUP: ~/$rel"
    fi
    backed_up=$((backed_up + 1))
  done < <(find "$pkg" \( -type f -o -type l \) -print0)
done

stow "${stow_flags[@]}" -R "${packages[@]}"

if [ "$backed_up" -gt 0 ] && ! $dry_run; then
  echo "Moved $backed_up existing file(s) to $backup"
fi

if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && ! $dry_run; then
  hyprctl reload >/dev/null && echo "Reloaded Hyprland"
fi
