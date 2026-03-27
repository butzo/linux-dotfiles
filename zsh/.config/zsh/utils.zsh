#!/usr/bin/zsh

load-zsh-config() {
    local pkg="$1"
    local config_file=$(find -L "$HOME/.config/zsh" -maxdepth 1 -name "${pkg}.*" -print -quit)
    
    if [[ ! -f "$config_file" ]]; then
        #echo "Configuration $config_file for '$pkg' not found."
        return
    fi
    
    if ! command -v "$pkg" &> /dev/null; then
        echo "Package '$pkg' not found. Install $pkg? (y/N/d-delete config): "
        read -k choice?
        echo
        case "$choice" in
            y|Y) $(get-install-cmd) "$pkg" ;;
            d|D) rm "$config_file" && echo "$config_file file deleted." && return ;;
            n|N) echo "Installation cancelled." && return ;;
            *) echo "Invalid choice. Installation cancelled." && return ;;
        esac
    fi
    
    if ! command -v "$pkg" &> /dev/null; then
        echo "Package '$pkg' installation failed."
        return
    fi
    
    source "$config_file"
}

aur_helper="yay"

get-install-cmd() {
    local distro
    local sudo_prefix=""
    
    # Check if already root
    [[ $EUID -ne 0 ]] && sudo_prefix="sudo "
    
    # Detect the Linux distribution
    if [[ -f /etc/os-release ]]; then
        distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        echo "Unable to detect distribution" >&2
        return 1
    fi
    
    case "$distro" in
        arch|manjaro|artix)
            # Check for AUR helpers first
            if command -v "$aur_helper" &> /dev/null; then
                echo "$aur_helper -S"
            elif command -v yay &> /dev/null; then
                echo "yay -S"
            elif command -v paru &> /dev/null; then
                echo "paru -S"
            else
                # Neither paru nor yay found, need to install paru first
                install-aur_helper "$aur_helper"
                echo "$aur_helper -S"
            fi
            ;;
        fedora|rhel|centos|rocky|alma)
            echo "${sudo_prefix}dnf install"
            ;;
        debian|ubuntu|linuxmint|pop)
            echo "${sudo_prefix}apt install"
            ;;
        alpine)
            echo "${sudo_prefix}apk add"
            ;;
        opensuse*|sle)
            echo "${sudo_prefix}zypper install"
            ;;
        void)
            echo "${sudo_prefix}xbps-install -S"
            ;;
        gentoo)
            echo "${sudo_prefix}emerge"
            ;;
        nixos|nix)
            echo "nix-env -iA"
            ;;
        *)
            echo "Unknown distribution: $distro" >&2
            return 1
            ;;
    esac
}

install-aur_helper() {
    local helper="${1:-"$aur_helper"}"
    echo "$helper not found. Installing $helper from AUR..."
    
    # Create a temporary directory
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" RETURN
    
    cd "$tmp_dir" || return 1
    
    # Clone repository
    git clone "https://aur.archlinux.org/$helper.git" || return 1
    cd "$helper" || return 1
    
    # Build and install
    makepkg -si || return 1
    
    echo "$helper installed successfully!"
}

count-updates() {
    local distro
    local count=0
    
    # Detect the Linux distribution
    if [[ -f /etc/os-release ]]; then
        distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        echo "Unable to detect distribution" >&2
        return 1
    fi
    
    case "$distro" in
        arch|manjaro|artix|cachyos)
            # Official repo updates
            if command -v checkupdates &> /dev/null; then
                count=$((count + $(checkupdates 2>/dev/null | wc -l)))
            fi
            # AUR updates
            if command -v "$aur_helper" &> /dev/null; then
                count=$((count + $($aur_helper -Qua 2>/dev/null | wc -l)))
            fi
            ;;
        fedora|rhel|centos|rocky|alma)
            count=$(dnf check-update 2>/dev/null | grep -c "^[a-zA-Z]")
            ;;
        debian|ubuntu|linuxmint|pop)
            count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
            ;;
        alpine)
            count=$(apk version -l '<' 2>/dev/null | wc -l)
            ;;
        opensuse*|sle)
            count=$(zypper list-updates 2>/dev/null | grep -c "^v")
            ;;
        void)
            count=$(xbps-install -Sun 2>/dev/null | wc -l)
            ;;
        gentoo)
            count=$(emerge -puDN @world 2>/dev/null | grep -c "^\[")
            ;;
        nixos|nix)
            count=$(nix-channel --update 2>/dev/null && nix-env -u --dry-run 2>&1 | grep -c "upgrading")
            ;;
        *)
            echo "Unknown distribution: $distro" >&2
            return 1
            ;;
    esac
    
    echo "$count"
}

update-all() {
    local distro
    
    # Detect the Linux distribution
    if [[ -f /etc/os-release ]]; then
        distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        echo "Unable to detect distribution" >&2
        return 1
    fi
    
    case "$distro" in
        arch|manjaro|artix|cachyos)
            if command -v "$aur_helper" &> /dev/null; then
                $aur_helper -Suy
            else
                sudo pacman -Syu
            fi
            ;;
        fedora|rhel|centos|rocky|alma)
            sudo dnf upgrade --refresh -y
            ;;
        debian|ubuntu|linuxmint|pop)
            sudo apt update && sudo apt upgrade -y
            ;;
        alpine)
            sudo apk update && sudo apk upgrade
            ;;
        opensuse*|sle)
            sudo zypper refresh && sudo zypper update -y
            ;;
        void)
            sudo xbps-install -Suv
            ;;
        gentoo)
            sudo emerge --update --deep --newuse @world
            ;;
        nixos|nix)
            nix-channel --update && nix-env -u '*'
            ;;
        *)
            echo "Unknown distribution: $distro" >&2
            return 1
            ;;
    esac
}

alias cu='count-updates'
alias ua='update-all'