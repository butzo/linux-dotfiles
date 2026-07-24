#!/usr/bin/zsh
# System update helpers (count / list / apply) across distros. Functions only —
# nothing runs at source time, so this stays cheap to load on every shell.

# Write "official aur" counts to the runtime file the waybar module reads and
# refresh it (SIGRTMIN+8). No-op when no bar is running (headless/TTY).
_sync-update-state() {
	if pgrep -x waybar &>/dev/null; then
		print -r -- "$1 $2" >"${XDG_RUNTIME_DIR:-/tmp}/waybar-updates"
		pkill -SIGRTMIN+8 waybar 2>/dev/null
	fi
}

# Print the number of available package updates (official + AUR on Arch).
count-updates() {
	local distro count=0 official=0 aur=0
	if [[ -f /etc/os-release ]]; then
		distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
	else
		echo "Unable to detect distribution" >&2
		return 1
	fi

	case "$distro" in
	arch | manjaro | artix | cachyos)
		command -v checkupdates &>/dev/null &&
			official=$(checkupdates 2>/dev/null | wc -l)
		command -v "$aur_helper" &>/dev/null &&
			aur=$($aur_helper -Qua 2>/dev/null | wc -l)
		count=$((official + aur))
		_sync-update-state "$official" "$aur"
		;;
	fedora | rhel | centos | rocky | alma) count=$(dnf check-update 2>/dev/null | grep -c "^[a-zA-Z]") ;;
	debian | ubuntu | linuxmint | pop) count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable") ;;
	alpine) count=$(apk version -l '<' 2>/dev/null | wc -l) ;;
	opensuse* | sle) count=$(zypper list-updates 2>/dev/null | grep -c "^v") ;;
	void) count=$(xbps-install -Sun 2>/dev/null | wc -l) ;;
	gentoo) count=$(emerge -puDN @world 2>/dev/null | grep -c "^\[") ;;
	nixos | nix) count=$(nix-channel --update 2>/dev/null && nix-env -u --dry-run 2>&1 | grep -c "upgrading") ;;
	*)
		echo "Unknown distribution: $distro" >&2
		return 1
		;;
	esac

	echo "$count"
}

# Apply all available system updates for the current distro.
update-all() {
	local distro
	if [[ -f /etc/os-release ]]; then
		distro=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
	else
		echo "Unable to detect distribution" >&2
		return 1
	fi

	case "$distro" in
	arch | manjaro | artix | cachyos)
		if command -v "$aur_helper" &>/dev/null; then
			$aur_helper -Suy
		else
			sudo pacman -Syu
		fi
		;;
	fedora | rhel | centos | rocky | alma) sudo dnf upgrade --refresh -y ;;
	debian | ubuntu | linuxmint | pop) sudo apt update && sudo apt upgrade -y ;;
	alpine) sudo apk update && sudo apk upgrade ;;
	opensuse* | sle) sudo zypper refresh && sudo zypper update -y ;;
	void) sudo xbps-install -Suv ;;
	gentoo) sudo emerge --update --deep --newuse @world ;;
	nixos | nix) nix-channel --update && nix-env -u '*' ;;
	*)
		echo "Unknown distribution: $distro" >&2
		return 1
		;;
	esac

	# Clear the update reminder now that everything is applied.
	_sync-update-state 0 0
	return 0
}

# List pending updates, split by official repos and AUR (Arch-family).
list-updates() {
	local official aur
	official=$(checkupdates 2>/dev/null)
	aur=$(command -v "$aur_helper" &>/dev/null && $aur_helper -Qua 2>/dev/null)

	# Keep the waybar counts in sync with what we just fetched.
	_sync-update-state "$(print -rn -- "$official" | grep -c .)" \
		"$(print -rn -- "$aur" | grep -c .)"

	[[ -n "$official" ]] && {
		echo "=== Official repos ==="
		echo "$official"
	}
	[[ -n "$aur" ]] && {
		echo "=== AUR ==="
		echo "$aur"
	}
	[[ -z "$official" && -z "$aur" ]] && echo "System is up to date."
}

alias cu='count-updates'
alias lu='list-updates'
alias ua='update-all'
