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
* grub2/shimx64.efi - SHIM SecureBoot loader for x86-64 signed with UEFI SA
* grub2/shimia32.efi - SHIM SecureBoot loader for i386 signed with UEFI SA
* grub2/shimiaa64.efi - SHIM SecureBoot loader for ARM64 signed with UEFI SA
* grub/bootx64.efi - Grub bootloader for x86-64
* grub/bootia32.efi - Grub bootloader for i386

We also include SHIM SecureBoot loaders signed by Red Hat or Fedora keys, in
order to use them you need to upload CA certificate into UEFI firmware. These
are for RHEL builds:

* grub2/shimx64-redhat.efi
* grub2/shimia32-redhat.efi
* grub2/shimiaa64-redhat.efi

And for Fedora builds:

* grub2/shimx64-fedora.efi
* grub2/shimia32-fedora.efi
* grub2/shimiaa64-fedora.efi

(*) - this is a workaround for Foreman 1.13-1.15 (will be removed in the future)

We do not ship PXELinux for now, there hasn't been a release for several years
in upstream and last version 6.04 does not work well in UEFI. Nightly builds
look better and there's been some activity, hopefully once new release is done
we can include PXELinux both BIOS and UEFI once it gets into Fedora Rawhide.

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

## UEFI in 32bit mode

Some cheap systems have 32bit UEFI while the hardware is 64bit capable. For
this reason, we ship shimia32.efi which is compatible, make sure to select
ix86 architecture in Foreman for the particular host when provisioning it.

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

## Which shim version to use

This chapter was written by Laszlo Ersek from Red Hat engineering as a
blueprint how to identify and verify signatures in shim bootloaders.

For "shim.efi" (on RHEL-7.3), "pesign" prints:

    $ pesign --show-signature --in=/boot/efi/EFI/redhat/shim.efi
    ---------------------------------------------
    certificate address is 0x7f2c4a001380
    Content was not encrypted.
    Content is detached; signature cannot be verified.
    The signer's common name is Microsoft Windows UEFI Driver Publisher
    No signer email address.
    No signing time included.
    There were certs or crls included.
    ---------------------------------------------

For "shim.efi", "sbverify" prints:

    $ sbverify --no-verify --verbose /boot/efi/EFI/redhat/shim.efi
    warning: data remaining[1175520 vs 1295704]: gaps between PE/COFF sections?
    image signature issuers:
     - /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
    image signature certificates:
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/OU=MOPR/CN=Microsoft Windows UEFI Driver Publisher
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
     - subject: /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation UEFI CA 2011
       issuer:  /C=US/ST=Washington/L=Redmond/O=Microsoft Corporation/CN=Microsoft Corporation Third Party Marketplace Root
    certificate store:
    Signature verification OK

So, the "shim.efi" binary was signed with the private key of

    Microsoft Windows UEFI Driver Publisher

The certificate for that entity was issued by

    Microsoft Corporation UEFI CA 2011

which in turn was issued by

    Microsoft Corporation Third Party Marketplace Root

The certificate that belongs to "Microsoft Corporation UEFI CA 2011" is
expected to be present in the "db" authenticated non-volatile UEFI
variable (= "authorized signature database") on all systems that passed
the Windows Logo certification, and so they will accept "shim.efi".

For "shim-redhat.efi", "pesign" prints:

    $ pesign --show-signature --in=/boot/efi/EFI/redhat/shim-redhat.efi
    ---------------------------------------------
    certificate address is 0x7f0800e01380
    Content was not encrypted.
    Content is detached; signature cannot be verified.
    The signer's common name is Red Hat Secure Boot (signing key 1)
    The signer's email address is secalert@redhat.com
    Signing time: Mon Jul 20, 2015
    There were certs or crls included.
    ---------------------------------------------

For "shim-redhat.efi", "sbverify" prints:

    $ sbverify --no-verify --verbose /boot/efi/EFI/redhat/shim-redhat.efi
    warning: data remaining[1169360 vs 1289544]: gaps between PE/COFF sections?
    image signature issuers:
     - /CN=Red Hat Secure Boot (CA key 1)/emailAddress=secalert@redhat.com
    image signature certificates:
     - subject: /CN=Red Hat Secure Boot (signing key 1)/emailAddress=secalert@redhat.com
       issuer:  /CN=Red Hat Secure Boot (CA key 1)/emailAddress=secalert@redhat.com
     - subject: /CN=Red Hat Secure Boot (CA key 1)/emailAddress=secalert@redhat.com
       issuer:  /CN=Red Hat Secure Boot (CA key 1)/emailAddress=secalert@redhat.com
    certificate store:
    Signature verification OK

So, in this case the binary was signed with the private key of

    Red Hat Secure Boot (signing key 1)

whose certificate was issued by

    Red Hat Secure Boot (CA key 1)

whose self-signed certificate is what we terminate the certificate chain
with.

On a Windows Logo-carrying machine, "shim.efi" can be used. Otherwise, you
could decide to trust Red Hat, and enroll the "Red Hat Secure Boot (CA key 1)"
cert in "db" manually. Then "shim-redhat.efi" would be accepted again.

## Contribute

Use our github Issues, Pull Requests and Foreman mailing list for
communication:

https://theforeman.org/contribute.html

