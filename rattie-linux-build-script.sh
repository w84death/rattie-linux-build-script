#!/bin/bash
# ******************************************************************************
# RATTIE LINUX - 2018.06
# ******************************************************************************


# ******************************************************************************
# SETTINGS
# ******************************************************************************

SCRIPT_NAME="RATTIE LINUX - Research Operating System - Build Script"
SCRIPT_VERSION="1.1-RC1"
LINUX_NAME="RATTIE LINUX"
DISTRIBUTION_VERSION="2018.6"

ARCH="x86_64"
KERNEL_BRANCH="3.x"
KERNEL_VERSION="3.16.56"
BUSYBOX_VERSION="1.28.4"
SYSLINUX_VERSION="6.03"
NCURSES_VERSION="6.1"
NANO_VERSION="2.9.8"
NANO_BRANCH="2.9"

# FIGLET_VERSION="2.2.5"
# ftp://ftp.figlet.org/pub/figlet/program/unix/figlet-${FIGLET_VERSION}.tar.gz
# LINKS_VERSION="2.16"

BASEDIR=`realpath --no-symlinks $PWD`
SOURCEDIR=${BASEDIR}/sources
ROOTFSDIR=${BASEDIR}/rootfs
ISODIR=${BASEDIR}/iso

MENU_ITEM_SELECTED=0
DIALOG_OUT=/tmp/dialog_$$
CFLAGS="-Os -s -fno-stack-protector -fomit-frame-pointer -U_FORTIFY_SOURCE"
JFLAG=4

# ******************************************************************************
# DIALOG FUNCTIONS
# ******************************************************************************

show_main_menu() {
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "MAIN MENU" \
    --default-item "${1}" \
    --menu "The ${LINUX_NAME} Research Operating System by kj/P1X." 18 64 10 \
    0 "INTRODUCTION" \
    1 "PREPARE DIRECTORIES" \
    2 "BUILD KERNEL" \
    3 "BUILD BUSYBOX" \
    4 "BUILD EXTRAS" \
    5 "GENERATE ROOTFS" \
    6 "GENERATE ISO" \
    7 "TEST IMAGE IN QEMU" \
    8 "CLEAN FILES" \
    9 "QUIT" 2> ${DIALOG_OUT}
}

show_dialog() {
    if [ ${#2} -le 24 ]; then
    WIDTH=24; HEIGHT=6; else
    WIDTH=64; HEIGHT=14; fi
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --msgbox "${2}" ${HEIGHT} ${WIDTH}
}

ask_dialog() {
    dialog --stdout \
    --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --yesno "${2}" 14 64
}

# ******************************************************************************
# MENUS
# ******************************************************************************

menu_introduction () {
    show_dialog "INTRODUCTION" "${LINUX_NAME} is an Research Operating System. This is a simple file that will create a working Linux distribution from scratch.\nIt will download all the sources, complie them and put everything into the ISO image.\nRead instuctions, learnd and have fun!" \
    && MENU_ITEM_SELECTED=1
    return 0
}

menu_prepare_dirs () {
    ask_dialog "PREPARE DIRECTORIES" "Create empty folders to work with." \
    && prepare_dirs \
    && MENU_ITEM_SELECTED=2 \
    && show_dialog "PREPARE DIRECTORIES" "Done."
    return 0
}

menu_build_kernel () {
    ask_dialog "BUILD KERNEL" "Linux Kernel ${KERNEL_VERSION}:\n - download and extract\n - configure\n - build" \
    && build_kernel \
    && MENU_ITEM_SELECTED=3 \
    && show_dialog "BUILD KERNEL" "Done."
    return 0
}
menu_build_busybox () {
    ask_dialog "BUILD BUSYBOX" "Build BusyBox ${BUSYBOX_VERSION}:\n - download and extract\n - configure\n - build" \
    && build_busybox \
    && MENU_ITEM_SELECTED=4 \
    && show_dialog "BUILD BUSYBOX" "Done."
    return 0
}

menu_build_extras () {
    ask_dialog "BUILD EXTRAS" "Build ncurses, nano, links each doing:\n - download and extract\n - configure\n - build" \
    && build_extras \
    && MENU_ITEM_SELECTED=5 \
    && show_dialog "BUILD EXTRAS" "Done."
    return 0
}

menu_generate_rootfs () {
    ask_dialog "GENERATE ROOTFS" "Generate root file system:\n - compress file tree" \
    && generate_rootfs \
    && MENU_ITEM_SELECTED=6 \
    && show_dialog "GENERATE ROOTFS" "Done."
    return 0
}

menu_generate_iso () {
    ask_dialog "GENERATE ISO" "Generate ISO image:\n - copy nessesary files to ISO directory\n - build image" \
    && generate_iso \
    && MENU_ITEM_SELECTED=7 \
    && show_dialog "GENERATE ISO" "Done."
    return 0
}

menu_qemu () {
    ask_dialog "TEST IMAGE IN QEMU" "Test generated image on emulated computer (QEMU):\n - x86_64\n - 128MB ram\n - cdrom" \
    && test_qemu \
    && MENU_ITEM_SELECTED=8 \
    && show_dialog "TEST IMAGE IN QEMU" "Done."
    return 0
}

menu_clean () {
    ask_dialog "CLEAN FILES" "Remove all archives, sources and temporary files." \
    && clean_files \
    && MENU_ITEM_SELECTED=9 \
    && show_dialog "CLEAN FILES" "Done."
    return 0
}


loop_menu () {
    show_main_menu ${MENU_ITEM_SELECTED}
    choice=$(cat ${DIALOG_OUT})

    case $choice in
        0) menu_introduction && loop_menu ;;
        1) menu_prepare_dirs && loop_menu ;;
        2) menu_build_kernel && loop_menu ;;
        3) menu_build_busybox && loop_menu ;;
        4) menu_build_extras && loop_menu ;;
        5) menu_generate_rootfs && loop_menu ;;
        6) menu_generate_iso && loop_menu ;;
        7) menu_qemu && loop_menu ;;
        8) menu_clean && loop_menu ;;
        9) exit;;
    esac
}

# ******************************************************************************
# MAGIC HAPPENS HERE
# ******************************************************************************

prepare_dirs () {
    cd ${BASEDIR}
    if [ ! -d ${SOURCEDIR} ];
    then
        mkdir ${SOURCEDIR}
    fi
    if [ ! -d ${ROOTFSDIR} ];
    then
        mkdir ${ROOTFSDIR}
    fi
    if [ ! -d ${ISODIR} ];
    then
        mkdir ${ISODIR}
    fi
}

build_kernel () {
    cd ${SOURCEDIR}
    wget -O kernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_BRANCH}/linux-${KERNEL_VERSION}.tar.xz
    tar -xvf kernel.tar.xz && rm kernel.tar.xz

    cd linux-${KERNEL_VERSION}
    make clean
    make defconfig
    sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"${LINUX_NAME}\"/" .config
    sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config
    sed -i "s/.*LOGO_LINUX_CLUT224.*/LOGO_LINUX_CLUT224=y/" .config
    cp ${BASEDIR}/rattie_logo_224.ppm drivers/video/logo/logo_linux_clut224.ppm
    sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config

    make bzImage -j ${JFLAG}
    cp arch/x86/boot/bzImage ${ISODIR}/kernel.gz
}

build_busybox () {
    cd ${SOURCEDIR}
    wget -O busybox.tar.bz2 http://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2
    tar -xvf busybox.tar.bz2 && rm busybox.tar.bz2

    cd busybox-${BUSYBOX_VERSION}
    make clean
    make defconfig
    sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
    make busybox -j ${JFLAG}
    make install
}

build_extras () {
    # mkdir cd ${SOURCEDIR}/temprootfs
    # build_ncurses
    # build_nano
    return 0
}


build_ncurses () {
    cd ${SOURCEDIR}
    wget -O ncurses.tar.gz https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
    tar -xvf ncurses.tar.gz && rm ncurses.tar.gz

    cd ncurses-${NCURSES_VERSION}
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    CFLAGS="${CFLAGS}" ./configure \
            --prefix=/usr \
            --with-termlib \
            --with-terminfo-dirs=/lib/terminfo \
            --with-default-terminfo-dirs=/lib/terminfo \
            --without-normal \
            --without-debug \
            --without-cxx-binding \
            --with-abi-version=5 \
            --enable-widec \
            --enable-pc-files \
            --with-shared \
            CPPFLAGS=-I$PWD/ncurses/widechar \
            LDFLAGS=-L$PWD/lib \
            CPPFLAGS="-P"

    make -j ${JFLAG}
    make -j ${JFLAG} install DESTDIR=${SOURCEDIR}/temprootfs

    cd ${SOURCEDIR}/temprootfs/usr/lib
    ln -s libncursesw.so.5 libncurses.so.5
    ln -s libncurses.so.5 libncurses.so
    ln -s libtinfow.so.5 libtinfo.so.5
    ln -s libtinfo.so.5 libtinfo.so
}

build_nano () {
    cd ${SOURCEDIR}
    wget -O nano.tar.xz https://nano-editor.org/dist/v${NANO_BRANCH}/nano-$NANO_VERSION.tar.xz
    tar -xvf nano.tar.xz && rm nano.tar.xz

    cd nano-$NANO_VERSION
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    CFLAGS="${CFLAGS}" ./configure \
            --prefix=/usr \
            LDFLAGS=-L$${SOURCEDIR}/temprootfs/usr/include

    make -j ${JFLAG}
    make -j ${JFLAG} install DESTDIR=${SOURCEDIR}/temprootfs
}

generate_rootfs () {
    rm -rf ${ROOTFSDIR} && mkdir  ${ROOTFSDIR}
    cd ${SOURCEDIR}/busybox-${BUSYBOX_VERSION}/_install
    cp -R . ${ROOTFSDIR}
    if [ -d ${SOURCEDIR}/temprootfs ];
    then
    cd ${SOURCEDIR}/temprootfs
    cp -R . ${ROOTFSDIR}
    fi
    cd ${ROOTFSDIR}
    rm -f linuxrc

    mkdir dev
    mkdir etc
    mkdir proc
    mkdir src
    mkdir sys
    mkdir tmp && chmod 1777 tmp

    cd etc
    touch motd
    echo >> motd
    echo ' ------------------------------------ 2018.6 ' >> motd
    echo '                   ^..^__                    ' >> motd
    echo '                   *,, , )_-                 ' >> motd
    echo '                 RATTIE LINUX                ' >> motd
    echo '          Research Operating System          ' >> motd
    echo '  ------------------------------------------ ' >> motd
    echo >> motd

    touch bootscript.sh
    echo '#!/bin/sh' >> bootscript.sh
    echo 'dmesg -n 1' >> bootscript.sh
    echo 'mount -t devtmpfs none /dev' >> bootscript.sh
    echo 'mount -t proc none /proc' >> bootscript.sh
    echo 'mount -t sysfs none /sys' >> bootscript.sh
    echo >> bootscript.sh
    chmod +x bootscript.sh

    touch inittab
    echo '::sysinit:/etc/bootscript.sh' >> inittab
    echo '::restart:/sbin/init' >> inittab
    echo '::ctrlaltdel:/sbin/reboot' >> inittab
    echo '::once:cat /etc/motd' >> inittab
    echo '::respawn:/bin/cttyhack /bin/sh' >> inittab
    echo 'tty2::once:cat /etc/motd' >> inittab
    echo 'tty2::respawn:/bin/sh' >> inittab
    echo 'tty3::once:cat /etc/motd' >> inittab
    echo 'tty3::respawn:/bin/sh' >> inittab
    echo 'tty4::once:cat /etc/motd' >> inittab
    echo 'tty4::respawn:/bin/sh' >> inittab
    echo >> inittab

    touch group
    echo 'root:x:0:root' >> group
    echo >> group

    touch passwd
    echo 'root:R.8MSU0Z/1ttM:0:0:Linux User,,,:/root:/bin/sh' >> passwd
    echo >> passwd

    cd ${ROOTFSDIR}

    touch init
    echo '#!/bin/sh' >> init
    echo 'exec /sbin/init' >> init
    echo >> init
    chmod +x init

    chown -R root:root .
    find . | cpio -H newc -o | gzip > ${ISODIR}/rootfs.gz
}

generate_iso () {
    if [ ! -d ${SOURCEDIR}/syslinux-${SYSLINUX_VERSION} ];
    then
        cd ${SOURCEDIR}
        wget -O syslinux.tar.xz http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-${SYSLINUX_VERSION}.tar.xz
        tar -xvf syslinux.tar.xz && rm syslinux.tar.xz
    fi
    cd ${SOURCEDIR}/syslinux-${SYSLINUX_VERSION}
    cp bios/core/isolinux.bin ${ISODIR}/
    cp bios/com32/elflink/ldlinux/ldlinux.c32 ${ISODIR}
    cp bios/com32/libutil/libutil.c32 ${ISODIR}
    cp bios/com32/menu/menu.c32 ${ISODIR}
    cd ${ISODIR}
    rm isolinux.cfg && touch isolinux.cfg
    echo 'default kernel.gz initrd=rootfs.gz vga=791' >> isolinux.cfg
    echo 'UI menu.c32 ' >> isolinux.cfg
    echo 'PROMPT 0 ' >> isolinux.cfg
    echo >> isolinux.cfg
    echo 'MENU TITLE RATTIE LINUX 2018.6: ' >> isolinux.cfg
    echo 'TIMEOUT 60 ' >> isolinux.cfg
    echo 'DEFAULT rattie ' >> isolinux.cfg
    echo >> isolinux.cfg
    echo 'LABEL rattie                      ' >> isolinux.cfg
    echo ' MENU LABEL RATTIE HiRES          ' >> isolinux.cfg
    echo ' KERNEL kernel.gz                 ' >> isolinux.cfg
    echo ' APPEND initrd=rootfs.gz vga=791 ' >> isolinux.cfg
    echo >> isolinux.cfg
    echo 'LABEL rattie_vga ' >> isolinux.cfg
    echo ' MENU LABEL RATTIE CHOOSE RES ' >> isolinux.cfg
    echo ' KERNEL kernel.gz ' >> isolinux.cfg
    echo ' APPEND initrd=rootfs.gz vga=ask ' >> isolinux.cfg

    rm ${BASEDIR}/rattie_linux.iso

    xorriso \
        -as mkisofs \
        -o ${BASEDIR}/rattie_linux.iso \
        -b isolinux.bin \
        -c boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        ./
}

test_qemu () {
    cd ${BASEDIR}
    if [ -f rattie_linux.iso ];
    then
        qemu-system-x86_64 -m 128M -cdrom rattie_linux.iso -boot d -vga std
    fi
}

clean_files () {
    rm -rf ${SOURCEDIR}
    rm -rf ${ROOTFSDIR}
    rm -rf ${ISODIR}
}

# ******************************************************************************
# RUN SCRIPT
# ******************************************************************************

set -ex
loop_menu
set -ex

# ******************************************************************************
# EOF
# ******************************************************************************
