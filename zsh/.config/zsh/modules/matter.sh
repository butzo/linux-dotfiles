#!/bin/sh
# ESP-Matter dev environment. Only ever loaded when the SDK is present (guard in
# rc.d/modules.zsh), so this just defines the heavy `get-idf` entrypoint.
load-matter() {
    get-idf() {
        export ESP_MATTER_PATH="$HOME/git/esp-matter"
        export IDF_CCACHE_ENABLE=1
        source "$HOME/git/esp-idf/export.sh"
        source "$HOME/git/esp-matter/export.sh"
        idf.py set-target esp32c6
    }
}
