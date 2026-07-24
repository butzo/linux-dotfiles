#!/bin/sh
# eza: modern `ls` replacement. Aliases only apply when eza is present; the
# plain-ls fallbacks live in rc.d/interactive.zsh for when it is not.
load-eza() {
    ensure-pkg eza || return
    alias ls='eza --icons=always'
    alias la='eza -a --icons=always'
    alias ll='eza -l --icons=always'
    alias lla='eza -al --icons=always'
    alias lt='eza --tree --level=1 --icons=always'
    alias lat='eza -a --tree --level=1 --icons=always'
    alias llt='eza -l --tree --level=1 --icons=always'
    alias llat='eza -al --tree --level=1 --icons=always'
}
