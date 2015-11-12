#!/bin/bash

# exit out if we're not root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

list_all_services() {
    service --status-all | less -P "le Services"
}

set_update_settings() {
# these are the recommended settings set in software-properties-gtk
    echo "APT::Periodic::Update-Package-Lists "2";
    APT::Periodic::Download-Upgradeable-Packages "1";
    APT::Periodic::AutocleanInterval "0";
    APT::Periodic::Unattended-Upgrade "1";" > /etc/apt/apt.conf.d/10periodic
    echo "Set apt update settings"
}

disable_ssh_root_login() {
    if [[ -f /etc/ssh/sshd_config ]]; then
        sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
    else
        echo "No SSH server detected so nothing changed"
    fi
    echo "Disabled SSH root login"
}

find_media_files_in_dir() {
    mediaroot="/home/"
    mimes="image/\|video/\|audio/\|model/\|music/"
    pushd $mediaroot > /dev/null
    find -type f -print0 | xargs -0 file --mime-type | grep $mimes | less -P "le Media Files"
    popd > /dev/null
}

enable_repositories() {
    echo "#deb cdrom:[Ubuntu 12.04.1 LTS _Precise Pangolin_ - Release i386 (20120817.3)]/ precise main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise main restricted
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted
    deb http://us.archive.ubuntu.com/ubuntu/ precise universe
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise universe
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
    deb http://us.archive.ubuntu.com/ubuntu/ precise multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise multiverse
    deb http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse
    deb http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
    deb-src http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
    deb http://security.ubuntu.com/ubuntu precise-security main restricted
    deb-src http://security.ubuntu.com/ubuntu precise-security main restricted
    deb http://security.ubuntu.com/ubuntu precise-security universe
    deb-src http://security.ubuntu.com/ubuntu precise-security universe
    deb http://security.ubuntu.com/ubuntu precise-security multiverse
    deb-src http://security.ubuntu.com/ubuntu precise-security multiverse
    # deb http://archive.canonical.com/ubuntu precise partner
    # deb-src http://archive.canonical.com/ubuntu precise partner
    deb http://extras.ubuntu.com/ubuntu precise main
    deb-src http://extras.ubuntu.com/ubuntu precise main" > /etc/apt/sources.list
    echo "created standard sources.list."
}

preserve_root_uid() {
    if [[ $(grep root /etc/passwd | wc -l) -gt 1 ]]; then
        grep root /etc/passwd | wc -l
    else
        echo "UID 0 is reserved to root"
    fi
}

remove_hacking_tools() {
    # Why not?
    apt-get autoremove --purge john netcat nmap hydra aircrack-ng
    echo "Hacking tools should be removed now"
}

check_no_pass() {
    sed -i s/NOPASSWD:// /etc/sudoers
    echo "Removed any instances of NOPASSWD in sudoers"
}

list_sensitive_groups() {
    echo "Members of group 'adm':"
    grep adm /etc/group | cut -d ':' -f 4 
    echo "Members of group 'root':"
    grep root /etc/group | cut -d ':' -f 4
    echo "Members of group 'sudo':"
    grep sudo /etc/group | cut -d ':' -f 4
}

echo "##### Setting apt update settings #####"
set_update_settings

echo "##### Enabling default apt repositoriess #####"
enable_repositories

echo "##### Disabling SSH root login #####"
disable_ssh_root_login

echo "##### Making sure root is the only user with UID 0 #####"
preserve_root_uid

echo "##### Removing any 'hacking tools' from system #####"
remove_hacking_tools

echo "##### Listing all currently active services #####"
list_all_services

echo "##### Removing any instances of NOPASSWD in /etc/sudoers #####"
check_no_pass

echo "##### Searching for any media files in /home #####"
find_media_files_in_dir

echo "##### Listing users in sensitive groups #####"
list_sensitive_groups

echo "##### Thank you for using our script! Goodbye! #####"
