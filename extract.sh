#!/bin/bash -e

TODAY=$(date +%Y%m%d%H%M)
PPC_MODULES="all_video boot btrfs cat configfile echo ext2 fat font gfxmenu gfxterm gzio halt hfsplus iso9660 jpeg loadenv loopback lvm mdraid09 mdraid1x minicmd normal part_apple part_msdos part_gpt password_pbkdf2 png reboot search search_fs_uuid search_fs_file search_label serial sleep syslinuxcfg test tftp video xfs linux"
[ -f local.conf ] && source local.conf

cleanup() {
  if [[ -d tftpboot ]]; then
    find tftpboot -type f
    rm -rf tftpboot
  fi
  mkdir -p tftpboot/{grub,grub2}
}
trap "cleanup" SIGHUP SIGINT SIGTERM EXIT
cleanup

extract() {
  local DIR=$1
  local ARCH=$2
  local FILE=$3
  local FILECHECK=${4:-$3}
  echo "Extracting $FILE"
  pushd $DIR &>/dev/null
    for F in *.$ARCH.rpm; do rpm2cpio $F | cpio --quiet -vidm $FILE; done
  popd &>/dev/null
  if [[ ! -f $DIR/$FILECHECK ]]; then
    echo "$FILECHECK was not found in $DIR/*.$ARCH.rpm"
    exit 1
  fi
}

dist() {
  local TAG=$1
  chmod 644 tftpboot/{grub,grub2}/* 2>/dev/null || true
  OUTPUT=dist/foreman-bootloaders-$TAG-${TODAY}.tar.bz2
  tar --sort=name -cjf $OUTPUT tftpboot/
  echo "Created $OUTPUT"
  cleanup
}

DIST=fedora
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shim.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shim-$DIST.efi
mv ./$DIST/boot/efi/EFI/$DIST/shim.efi tftpboot/grub2/shimx64.efi
mv ./$DIST/boot/efi/EFI/$DIST/shim-fedora.efi tftpboot/grub2/shimx64-fedora.efi
extract $DIST aarch64 ./boot/efi/EFI/$DIST/shim.efi
extract $DIST aarch64 ./boot/efi/EFI/$DIST/shim-$DIST.efi
mv ./$DIST/boot/efi/EFI/$DIST/shim.efi tftpboot/grub2/shimaa64.efi
mv ./$DIST/boot/efi/EFI/$DIST/shim-fedora.efi tftpboot/grub2/shimaa64-fedora.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/grubx64.efi
extract $DIST i686 ./boot/efi/EFI/$DIST/grubia32.efi
mv ./$DIST/boot/efi/EFI/$DIST/*.efi tftpboot/grub2/
for A in ppc64 ppc64le; do
  extract $DIST $A ./usr/lib/grub/powerpc-ieee1275/\* ./usr/lib/grub/powerpc-ieee1275/fs.lst
  grub2-mkimage -O powerpc-ieee1275 -d ./$DIST/usr/lib/grub/powerpc-ieee1275 -o tftpboot/grub2/grub$A.elf -p "" $PPC_MODULES
  rm -rf ./$DIST/usr/lib/grub/powerpc-ieee1275

  # workaround for http://projects.theforeman.org/issues/16706
  ln -sf grub$A.elf tftpboot/grub2/grub$A.efi
done
extract $DIST x86_64 ./boot/efi/EFI/redhat/grub.efi
mv ./$DIST/boot/efi/EFI/redhat/grub.efi tftpboot/grub/grubx64.efi
extract $DIST i686 ./boot/efi/EFI/redhat/grub.efi
mv ./$DIST/boot/efi/EFI/redhat/grub.efi tftpboot/grub/grubia32.efi
dist $DIST

DIST=redhat
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shimx64.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shimx64-$DIST.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shimia32.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/shimia32-$DIST.efi
extract $DIST aarch64 ./boot/efi/EFI/$DIST/shimaa64.efi
extract $DIST aarch64 ./boot/efi/EFI/$DIST/shimaa64-$DIST.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/grubx64.efi
extract $DIST x86_64 ./boot/efi/EFI/$DIST/grubia32.efi
extract $DIST aarch64 ./boot/efi/EFI/$DIST/grubaa64.efi
mv ./$DIST/boot/efi/EFI/$DIST/*.efi tftpboot/grub2/
for A in ppc64 ppc64le; do
  extract $DIST noarch ./usr/lib/grub/powerpc-ieee1275/\* ./usr/lib/grub/powerpc-ieee1275/fs.lst
  grub2-mkimage -O powerpc-ieee1275 -d ./$DIST/usr/lib/grub/powerpc-ieee1275 -o tftpboot/grub2/grub$A.elf -p "" $PPC_MODULES
  rm -rf ./$DIST/usr/lib/grub/powerpc-ieee1275

  # workaround for http://projects.theforeman.org/issues/16706
  ln -sf grub$A.elf tftpboot/grub2/grub$A.efi
done
extract $DIST x86_64 ./boot/efi/EFI/$DIST/grub.efi
mv ./$DIST/boot/efi/EFI/$DIST/grub.efi tftpboot/grub/grubx64.efi
# Foreman expects grub under this naming convention
ln -sf grubx64.efi tftpboot/grub/bootx64.efi
extract $DIST i686 ./boot/efi/EFI/$DIST/grub.efi
mv ./$DIST/boot/efi/EFI/$DIST/grub.efi tftpboot/grub/grubia32.efi
# Foreman expects grub under this naming convention
ln -sf grubia32.efi tftpboot/grub/bootia32.efi
dist $DIST
