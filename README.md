# Foreman PXE bootloaders

This repository contains distribution packages and scripts to generate tarball
containing Grub and Grub2 bootloaders for PXE/BOOTP use on TFTP Foreman Proxy.
The bootloader binaries are downloaded from various distributions:

* Red Hat Enterprise Linux 6 and 7
* Fedora 18 and Rawhide

Currently supported architectures:

* x86-64
* i386
* ARM64 (Only RHEL)
* PPC64
* PPC64 LE

Each source distribution supports different combination of architectures.

## Download

Download from dist/ directory in this git repository.

## Shipped bootloaders

* grub2/grubaa64.efi - Grub2 bootloader for ARM64
* grub2/grubx64.efi - Grub2 bootloader for x86-64
* grub2/grubppc64.elf - Grub2 bootloader for PPC64
* grub2/grubppc64le.elf - Grub2 bootloader for PPC64LE
* grub2/grubppc64.efi - symlink to ELF (*)
* grub2/grubppc64le.efi - symlink to ELF (*)
* grub2/shimx64.efi - SHIM SecureBoot loader for x86-64
* grub2/shimia32.efi - SHIM SecureBoot loader for i386
* grub2/shimiaa64.efi - SHIM SecureBoot loader for ARM64
* grub/bootx64.efi - Grub bootloader for x86-64
* grub/bootia32.efi - Grub bootloader for i386

(*) - this is a workaround for Foreman 1.13-1.15 (will be removed in the future)

## Which one to pick

Grub1 is was taken from Fedora 18 and RHEL/CentOS 6 and Grub2 is from
Fedora Rawhide and RHEL/CentOS 7. There are several packages you can get from
here:

* foreman-bootloaders-redhat-XXXXXX.tar.bz2
* foreman-bootloaders-fedora-XXXXXX.tar.bz2

The best option is to get RHEL builds ("redhat") as it is a stable choice,
provides widest range of architectures and will not change. If you want latest
and greatest builds, go for Fedora ("fedora") which is up-to-date build from
Rawhide, but Grub1 is no longer maintained there (Fedora 18).

Note you can still boot non-redhat systems with "redhat" bootloaders including
Ubuntu, Debian or OpenSUSE. See below for more info.

## Usage

Foreman users can install provided distribution package called
`foreman-bootloaders` directly from Foreman repositories. If you are using
older version, or not using Foreman at all, generate and deploy tarball from
this repository.

Clone this repository, use `download` scripts in individual directories to
download packages from Fedora Koji or Brew and use script called `extract` to
generate tarballs. If you don't have access to Koji instance, RPM packages can
be downloaded manually, their names are stored in package-list.txt files.

## Ubuntu and Debian support

We currently do not provide loaders from these distributions for two reasons.
First and foremost, only Red Hat carries patches in Grub and Grub2 which makes
it to search for configuration filenames based on MAC address (the patch is
called 0025-Search-for-specific-config-file-for-netboot.patch). There is a
workaround that has been merged in Foreman 1.15 default configuration, but
that's only for Grub2, for more information see our ticket:

http://projects.theforeman.org/issues/16654

Second, Debian does not ship SecureBoot signed loaders at all. Approach in Red
Hat distributions is via Shim pre-loader which is also available in Ubuntu,
but only for Grub2 (shim-signed, grub-efi-amd64-signed).

Since loaders from Red Hat distributions work well with Ubuntu or Debian
clients, we decided not to ship them for now. Feel free to contribute builds
from other distributions.

## Contribute

Use our github Issues, Pull Requests and Foreman mailing list for
communication:

https://theforeman.org/contribute.html

