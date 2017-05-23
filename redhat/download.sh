#!/bin/bash
#
# This script requires brew client configured with a brew instance.
#

GRUB1_RHEL_VER=6.9
GRUB2_RHEL_VER=7.4
rm *.rpm
brew download-build $(brew --quiet latest-build RHEL-$GRUB1_RHEL_VER-Z grub | awk '{ print $1 }')
brew download-build $(brew --quiet latest-build rhel-$GRUB2_RHEL_VER-z grub2 | awk '{ print $1 }')
brew download-build $(brew --quiet latest-build rhel-$GRUB2_RHEL_VER-z shim | awk '{ print $1 }')
rm *.src.rpm
brew download-build $(brew --quiet latest-build rhel-$GRUB2_RHEL_VER-z shim-signed | awk '{ print $1 }')

ls *rpm > package-list.txt
