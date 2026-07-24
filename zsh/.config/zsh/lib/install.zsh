#!/usr/bin/zsh
# Package installation helpers. Distro-aware so the same config deploys across
# Arch/Fedora/Debian/etc. Functions only — nothing here runs at source time, so
# this file is free to load on every shell.

# Preferred AUR helper on Arch-family systems.
aur_helper="yay"

# Interactive yes/no prompt used by the ensure-* helpers below.
_ensure-prompt() {
    printf "Package providing '%s' not found. Install? (y/N) " "$1"
    local choice; read -k choice; echo
    [[ "$choice" == [yY] ]]
}

# ensure-pkg <cmd> [pkgname]
# Guarantee <cmd> is available; if missing, offer to install <pkgname>
# (default = <cmd>) via the distro's default package manager.
# Returns 0 when the command is available afterwards.
ensure-pkg() {
    local cmd="$1" pkg="${2:-$1}"
    command -v "$cmd" &>/dev/null && return 0
    _ensure-prompt "$cmd" || return 1
    eval "$(get-install-cmd) $pkg"
    command -v "$cmd" &>/dev/null
}

# ensure-custom <cmd> <installer...>
# Like ensure-pkg but runs an arbitrary installer (e.g. a flatpak/AUR/upstream
# script) when <cmd> is missing, for packages the default manager can't provide.
ensure-custom() {
    local cmd="$1"; shift
    command -v "$cmd" &>/dev/null && return 0
    _ensure-prompt "$cmd" || return 1
    "$@"
    command -v "$cmd" &>/dev/null
}

# Print the install command for the current distro, e.g. "sudo apt install".
get-install-cmd() {
    local distro sudo_prefix=""
    [[ $EUID -ne 0 ]] && sudo_prefix="sudo "

    if [[ -f /etc/os-release ]]; then
        distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        echo "Unable to detect distribution" >&2
        return 1
    fi

    case "$distro" in
        arch|manjaro|artix|cachyos)
            if command -v "$aur_helper" &>/dev/null; then
                echo "$aur_helper -S"
            elif command -v yay &>/dev/null; then
                echo "yay -S"
            elif command -v paru &>/dev/null; then
                echo "paru -S"
            else
                install-aur_helper "$aur_helper"
                echo "$aur_helper -S"
            fi
            ;;
        fedora|rhel|centos|rocky|alma) echo "${sudo_prefix}dnf install" ;;
        debian|ubuntu|linuxmint|pop)   echo "${sudo_prefix}apt install" ;;
        alpine)                        echo "${sudo_prefix}apk add" ;;
        opensuse*|sle)                 echo "${sudo_prefix}zypper install" ;;
        void)                          echo "${sudo_prefix}xbps-install -S" ;;
        gentoo)                        echo "${sudo_prefix}emerge" ;;
        nixos|nix)                     echo "nix-env -iA" ;;
        *) echo "Unknown distribution: $distro" >&2; return 1 ;;
    esac
}

# Bootstrap an AUR helper (yay/paru) by building it from the AUR.
install-aur_helper() {
    local helper="${1:-$aur_helper}"
    echo "$helper not found. Installing $helper from AUR..."
    local tmp_dir; tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" RETURN
    cd "$tmp_dir" || return 1
    git clone "https://aur.archlinux.org/$helper.git" || return 1
    cd "$helper" || return 1
    makepkg -si || return 1
    echo "$helper installed successfully!"
}
