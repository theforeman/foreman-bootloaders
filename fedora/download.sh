#!/bin/bash
#
# This script requires fedora koji client configured.
#

rm *.rpm
koji download-build $(koji --quiet latest-build f18 grub | awk '{ print $1 }')
koji download-build $(koji --quiet latest-build rawhide grub2 | awk '{ print $1 }')
koji download-build $(koji --quiet latest-build rawhide shim | awk '{ print $1 }')
koji download-build $(koji --quiet latest-build rawhide shim-signed | awk '{ print $1 }')
rm *.src.rpm

ls *rpm > package-list.txt
