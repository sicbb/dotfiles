# dotfiles

My configs for [Omarchy](https://omarchy.org) (Arch Linux + Hyprland), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

```bash
git clone https://github.com/sicbb/dotfiles.git
cd dotfiles
./install.sh
```

The script

1. installs `stow` if it is missing,
2. installs the packages the configs need (asks first),
3. moves existing files that are in the way to `~/.dotfiles-backup-<timestamp>`,
4. links all configs into `$HOME` with Stow,
5. reloads Hyprland if it is running.

It never overwrites anything and is safe to run as often as you like.

### Options

```bash
./install.sh                 # link everything
./install.sh hyprland bash   # only the named packages
./install.sh -n              # dry run: only show what would happen
./install.sh -u ghostty      # remove a package's links again
./install.sh --no-deps       # don't install packages, only link
./install.sh -h              # help
```

## Packages

Each directory is a Stow package. Its contents mirror the path relative to `$HOME`.

| Package | Target | Requires |
|---|---|---|
| `bash` | `~/.bashrc`: pacman/yay aliases on top of the Omarchy defaults | |
| `bin` | `~/.local/bin/`: `protonvault.sh` (sync the KeePass database with Proton Drive), `wow-patch` (move the WoW ICONS folder aside during Battle.net patches) | Proton Drive CLI for `protonvault.sh` |
| `brave` | `~/.config/brave-origin-flags.conf`: Wayland, libsecret, Omarchy extensions | `brave-origin-bin` |
| `ghostty` | `~/.config/ghostty/config` | `ghostty`, `ttf-cascadia-mono-nerd` |
| `hyprland` | `~/.config/hypr/`: `bindings.lua`, `hyprland.lua`, `input.lua` (German layout, nodeadkeys), `looknfeel.lua`, `monitors.lua` (3-monitor setup, workspace and window rules) | |
| `starship` | `~/.config/starship.toml`: Catppuccin Mocha prompt | `starship` |

The packages in the "Requires" column are listed in the `DEPS` table in `install.sh` and installed automatically. The Proton Drive CLI is only available in the AUR and has to be installed by hand.

`monitors.lua` is tailored to my desktop (`DP-1`, `DP-2`, `HDMI-A-1`). Adjust it on other machines.

## Stow settings

`.stowrc` in the repo root sets:

- `--target=~`: links into `$HOME`, wherever the repo lives.
- `--no-folding`: always links individual files, never whole directories. Omarchy puts its own files into `~/.config/hypr` and similar directories, and those would otherwise end up in the repo.

Stow only reads `.stowrc` from the current directory, so always run Stow commands inside the repo (`install.sh` changes there by itself).

## Adding a new config

```bash
mkdir -p waybar/.config/waybar
mv ~/.config/waybar/config.jsonc waybar/.config/waybar/
./install.sh waybar
```

If the config needs a package, add it to `DEPS` in `install.sh`:

```bash
[waybar]="waybar"
```

## Editing

The files in `$HOME` are symlinks into the repo, so changes land here directly and only need to be committed. Hyprland picks up changes with `hyprctl reload`; Bash and Starship apply in the next terminal.

Note: the repo must be reachable at login. If it lives on a drive that isn't mounted, the links point nowhere.
