#!/bin/sh
# gitui: terminal UI for git. Wrap it to spin up a one-shot ssh-agent so signed
# commits / remote pushes work, then tear the agent down on exit.
load-gitui() {
    ensure-pkg gitui || return
    alias gitui='eval $(ssh-agent) >/dev/null && ssh-add >/dev/null 2>&1 && gitui && ssh-agent -k >/dev/null'
}
