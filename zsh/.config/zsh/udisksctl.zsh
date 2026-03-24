#!/usr/bin/zsh

mnt() {
    udisksctl mount -b "$@"
}
umnt() {
    udisksctl unmount -b "$@"
}
# Completion: all block devices (disk + part) for `mnt`
_udisk_blockdevs() {
    local -a devs luks
    devs=("${(@f)$(lsblk -lnp -o NAME,TYPE | awk '$2 ~ /^(disk|part)$/{print $1}')}")
    luks=("${(@f)$(ls /dev/mapper 2>/dev/null | grep -vE 'control|swap|cryptswap|luks-[0-9a-f]+' | sed 's|^|/dev/mapper/|')}")
    _describe 'block devices' devs
    (( $#luks )) && _describe 'LUKS mappings' luks
}
# Completion: only mounted block devices for `umnt`
_udisk_mounted_blockdevs() {
    local -a devs luks
    devs=("${(@f)$(lsblk -lnp -o NAME,MOUNTPOINT | awk '$2!=""{print $1}')}")
    luks=("${(@M)devs:#/dev/mapper/*}")
    _describe 'mounted block devices' devs
    (( $#luks )) && _describe 'mounted LUKS mappings' luks
}
compdef _udisk_blockdevs mnt
compdef _udisk_mounted_blockdevs umnt

#alias mnt="udisksctl mount --block-device"
#alias umnt="udisksctl unmount -b"