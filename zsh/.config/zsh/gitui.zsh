#!/usr/bin/bash

alias 'gitui'='eval $(ssh-agent) >/dev/null && ssh-add >/dev/null 2>&1 && gitui && ssh-agent -k >/dev/null'
