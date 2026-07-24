#!/usr/bin/zsh
# rnote: handwriting/notes app shipped as a Flatpak. zsh-specific (compdef),
# hence the .zsh module.
load-rnote() {
    # Define the wrapper unconditionally — cheap, no fork at startup. The flatpak
    # presence check (a fork) is deferred to first invocation, so it never costs
    # anything on headless shells where rnote is never run.
    rnote() {
        if ! flatpak info com.github.flxzt.rnote &>/dev/null; then
            _ensure-prompt rnote || return 1
            flatpak install -y flathub com.github.flxzt.rnote || return 1
        fi
        # Launch detached so the shell isn't blocked; suppress flatpak noise.
        setsid -f flatpak run com.github.flxzt.rnote "$@" >/dev/null 2>&1
    }
    compdef '_files -g "*.(#i)(pdf|xopp|rnote)"' rnote
}
