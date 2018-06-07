#!/bin/bash
# ******************************************************************************
# RATTIE LINUX - 2018.06
# ******************************************************************************


# ******************************************************************************
# SETTINGS
# ******************************************************************************

SCRIPT_NAME="RATTIE LINUX - Research Operating System - Build Script"
SCRIPT_VERSION="1.3-RC3"
LINUX_NAME="RATTIE LINUX"
DISTRIBUTION_VERSION="2018.6"
ISO_FILENAME="rattie_linux-${SCRIPT_VERSION}.iso"

# BASE
KERNEL_BRANCH="3.x"; KERNEL_VERSION="3.16.56"
BUSYBOX_VERSION="1.28.4"
SYSLINUX_VERSION="6.03"

# EXTRAS
KBD_VERSION="2.0.4"
NCURSES_VERSION="6.1"
VIM_VERSION="8.1"; VIM_DIR="81"
NANO_BRANCH="2.9"; NANO_VERSION="2.9.8"
FIGLET_VERSION="2.2.5"
VRMS_VERSION="1.21"

BASEDIR=`realpath --no-symlinks $PWD`
SOURCEDIR=${BASEDIR}/sources
ROOTFSDIR=${BASEDIR}/rootfs
ISODIR=${BASEDIR}/iso

CFLAGS="-march=native -O2 -pipe"
CXXFLAGS="-march=native -O2 -pipe"
JFLAG=4

MENU_ITEM_SELECTED=0
DIALOG_OUT=/tmp/dialog_$$

# ******************************************************************************
# DIALOG FUNCTIONS
# ******************************************************************************

show_main_menu () {
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "MAIN MENU" \
    --default-item "${1}" \
    --menu "It's small, it's fast and it's cute.\nIt is ${LINUX_NAME} Research Operating System v${SCRIPT_VERSION}" 18 64 10 \
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

show_dialog () {
    if [ ${#2} -le 24 ]; then
    WIDTH=24; HEIGHT=6; else
    WIDTH=64; HEIGHT=14; fi
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --msgbox "${2}" ${HEIGHT} ${WIDTH}
}

ask_dialog () {
    dialog --stdout \
    --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --yesno "${2}" 14 64
}

check_error_dialog () {
    if [ $? -gt 0 ];
    then
        show_dialog "An error occured ;o" "There was a problem with ${1}.\nCheck the console output. Fix the problem and come back to the last step."
        exit
    fi
}

# ******************************************************************************
# MENUS
# ******************************************************************************

menu_introduction () {
    show_dialog "INTRODUCTION" "${LINUX_NAME} is an Research Operating System.\n\nThis is a simple file that will create a working Linux distribution from scratch.\nIt will download all the sources, complie them and put everything into the ISO image.\n\nRead instuctions, learnd and have fun!\n\n - kj/P1X" \
    && MENU_ITEM_SELECTED=1
    return 0
}

menu_prepare_dirs () {
    ask_dialog "PREPARE DIRECTORIES" "Create empty folders to work with.\n - /sources for all the source code\n - /rootfs for our root tree\n - /iso for ISO file" \
    && prepare_dirs \
    && MENU_ITEM_SELECTED=2 \
    && show_dialog "PREPARE DIRECTORIES" "Done."
    return 0
}

menu_build_kernel () {
    ask_dialog "BUILD KERNEL" "Linux Kernel ${KERNEL_VERSION} - this is the hearth of the operating system.\n\nRecipe:\n - download and extract\n - configure\n - build" \
    && build_kernel \
    && MENU_ITEM_SELECTED=3 \
    && show_dialog "BUILD KERNEL" "Done."
    return 0
}
menu_build_busybox () {
    ask_dialog "BUILD BUSYBOX" "Build BusyBox ${BUSYBOX_VERSION} - all the basic stuff like cp, ls, etc.\n\nRecipe:\n - download and extract\n - configure\n - build" \
    && build_busybox \
    && MENU_ITEM_SELECTED=4 \
    && show_dialog "BUILD BUSYBOX" "Done."
    return 0
}

menu_build_extras () {
    ask_dialog "BUILD EXTRAS" "Build additional software.\n - kbd (for font change support)\n - ncurses (lot of stuff needs this)\n - nano\n - vim\n - figlet (just for fun)\n - vrms (Virtual Richard M. Stallman)" \
    && build_extras \
    && MENU_ITEM_SELECTED=5 \
    && show_dialog "BUILD EXTRAS" "Done."
    return 0
}

menu_generate_rootfs () {
    ask_dialog "GENERATE ROOTFS" "Generate root file system. Combines all of the created files in a one directory tree.\n\nRecipe:\n - generates default /etc files (configs).\n - compress file tree" \
    && generate_rootfs \
    && MENU_ITEM_SELECTED=6 \
    && show_dialog "GENERATE ROOTFS" "Done."
    return 0
}

menu_generate_iso () {
    ask_dialog "GENERATE ISO" "Generate ISO image to boot from.\n\nRecipe:\n - download SysLinux \n - copy nessesary files to ISO directory\n - build image" \
    && generate_iso \
    && MENU_ITEM_SELECTED=7 \
    && show_dialog "GENERATE ISO" "Done."
    return 0
}

menu_qemu () {
    ask_dialog "TEST IMAGE IN QEMU" "Test generated image on emulated computer (QEMU):\n - x86_64\n - 128MB ram\n - cdrom\n\nLOGIN: root\nPASSWORD: root" \
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
    make defconfig \
        -j ${JFLAG}
    sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"${LINUX_NAME}\"/" .config
    sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config
    sed -i "s/.*LOGO_LINUX_CLUT224.*/LOGO_LINUX_CLUT224=y/" .config
    cp ${BASEDIR}/rattie_logo_224.ppm drivers/video/logo/logo_linux_clut224.ppm
    sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config

    make bzImage \
        -j ${JFLAG}
     cp arch/x86/boot/bzImage ${ISODIR}/kernel.gz

    check_error_dialog "linux-${KERNEL_VERSION}"
}

build_busybox () {
    cd ${SOURCEDIR}
    wget -O busybox.tar.bz2 http://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2
    tar -xvf busybox.tar.bz2 && rm busybox.tar.bz2

    cd busybox-${BUSYBOX_VERSION}
    make clean
    make defconfig
    sed -i 's|.*CONFIG_STATIC.*|CONFIG_STATIC=y|' .config
    make busybox \
        -j ${JFLAG}

    make install \
        -j ${JFLAG}

    rm -rf ${ROOTFSDIR} && mkdir ${ROOTFSDIR}
    cd _install
    cp -R . ${ROOTFSDIR}

    check_error_dialog "busybox-${BUSYBOX_VERSION}"
}

build_extras () {
    build_ncurses
    build_kbd
    build_nano
    build_vim
    build_figlet
    build_vrms

    check_error_dialog "Building extras"

    # strip -g \
    #     ${ROOTFSDIR}/bin/* \
    #     ${ROOTFSDIR}/sbin/* \
    #     ${ROOTFSDIR}/lib/* \
    #     ${ROOTFSDIR}/usr/* \
    #     ${ROOTFSDIR}/usr/bin/* \
    #     2>/dev/null

    # # hack; strip always returns !0, or gets stuck without 2>/dev/null
    # MENU_ITEM_SELECTED=5
}

build_kbd () {
    cd ${SOURCEDIR}
    rm -rf kbd-${KBD_VERSION}
    wget -O kbd.tar.gz https://www.kernel.org/pub/linux/utils/kbd/kbd-${KBD_VERSION}.tar.gz
    tar -xvf kbd.tar.gz && rm kbd.tar.gz

    cd kbd-${KBD_VERSION}
    if [ -f Makefile ] ; then
            make clean -j ${JFLAG}
    fi
    CFLAGS="$CFLAGS" ./configure \
        --prefix=/usr \
        --disable-vlock

    make -j ${JFLAG}
    make install -j ${JFLAG} \
        DESTDIR=${ROOTFSDIR}

    check_error_dialog "kbd-${KBD_VERSION}"
}

build_figlet () {
    cd ${SOURCEDIR}
    rm -rf figlet-${FIGLET_VERSION}
    wget -O figlet.tar.gz ftp://ftp.figlet.org/pub/figlet/program/unix/figlet-${FIGLET_VERSION}.tar.gz
    tar -xvf figlet.tar.gz && rm figlet.tar.gz

    cd figlet-${FIGLET_VERSION}
    if [ -f Makefile ] ; then
        make clean -j ${JFLAG}
    fi

    sed -i 's|/usr/local|'${ROOTFSDIR}/usr'|g' Makefile
    make install -j ${JFLAG}

    check_error_dialog "figlet-${FIGLET_VERSION}"
}

build_ncurses () {
    cd ${SOURCEDIR}
    rm -rf ncurses-${NCURSES_VERSION}
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
    make install -j ${JFLAG}  \
        DESTDIR=${ROOTFSDIR}

    # cd ${SOURCEDIR}/temprootfs/usr/lib
    # ln -s libncursesw.so.5 libncurses.so.5
    # ln -s libncurses.so.5 libncurses.so
    # ln -s libtinfow.so.5 libtinfo.so.5
    # ln -s libtinfo.so.5 libtinfo.so

    check_error_dialog "ncurses-${NCURSES_VERSION}"
}

build_nano () {
    cd ${SOURCEDIR}
    rm -rf nano-${NANO_VERSION}
    wget -O nano.tar.xz https://nano-editor.org/dist/v${NANO_BRANCH}/nano-${NANO_VERSION}.tar.xz
    tar -xvf nano.tar.xz && rm nano.tar.xz

    cd nano-${NANO_VERSION}
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    CFLAGS="${CFLAGS}" ./configure \
        --prefix=/usr \
        LDFLAGS=-L$PWD/lib

    make -j ${JFLAG}
    make install -j ${JFLAG} \
        DESTDIR=${ROOTFSDIR}

    check_error_dialog "nano-${NANO_VERSION}"
}

build_vim () {
    cd ${SOURCEDIR}
    rm -rf vim${VIM_DIR}
    wget -O vim.tar.bz2 http://ftp2.pl.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
    tar -xvf vim.tar.bz2 && rm vim.tar.bz2

    cd vim${VIM_DIR}
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    CFLAGS="${CFLAGS}" ./configure \
        --prefix=/usr \
        LDFLAGS=-L$PWD/lib

    make -j ${JFLAG}
    make install \
        -j ${JFLAG} \
        DESTDIR=${ROOTFSDIR}

    check_error_dialog "vim-${VIM_VERSION}"
}

build_vrms () {
    cd ${SOURCEDIR}
    rm -rf vrms
    wget -O vrms.tar.xz http://ftp.pl.debian.org/debian/pool/main/v/vrms/vrms_${VRMS_VERSION}.tar.xz
    tar -xvf vrms.tar.xz && vrms.tar.xz

    cp vrms/vrms ${ROOTFSDIR}/usr/bin/vrms

    check_error_dialog "vrms_${VRMS_VERSION}"
}

generate_rootfs () {
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
    echo '                   "..^__                    ' >> motd
    echo '                   *,,-,_).-~                ' >> motd
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
    echo '::askfirst:-/bin/login' >> inittab
    echo 'tty2::once:cat /etc/motd' >> inittab
    echo 'tty2::askfirst:-/bin/sh' >> inittab
    echo 'tty3::once:cat /etc/motd' >> inittab
    echo 'tty3::askfirst:-/bin/sh' >> inittab
    echo 'tty4::once:cat /etc/motd' >> inittab
    echo 'tty4::askfirst:-/bin/sh' >> inittab
    echo >> inittab

    touch group
    echo 'root:x:0:root' >> group
    echo >> group

    touch passwd
    echo 'root:R.8MSU0Z/1ttM:0:0:Fluffy Rattie,,,:/root:/bin/sh' >> passwd
    echo >> passwd

    cd ${ROOTFSDIR}

    touch init
    echo '#!/bin/sh' >> init
    echo 'exec /sbin/init' >> init
    echo >> init
    chmod +x init

    # sudo chown -R root:root .
    find . | cpio -R root:root -H newc -o | gzip > ${ISODIR}/rootfs.gz

    check_error_dialog "rootfs"
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
    echo 'MENU TITLE RATTIE LINUX 2018.6 /'${SCRIPT_VERSION}': ' >> isolinux.cfg
    echo 'TIMEOUT 60 ' >> isolinux.cfg
    echo 'DEFAULT rattie ' >> isolinux.cfg
    echo >> isolinux.cfg
    echo 'LABEL rattie ' >> isolinux.cfg
    echo ' MENU LABEL START RATTIE LINUX [KERNEL:'${KERNEL_VERSION}']' >> isolinux.cfg
    echo ' KERNEL kernel.gz ' >> isolinux.cfg
    echo ' APPEND initrd=rootfs.gz vga=791 ' >> isolinux.cfg
    echo >> isolinux.cfg
    echo 'LABEL rattie_vga ' >> isolinux.cfg
    echo ' MENU LABEL CHOOSE RESOLUTION ' >> isolinux.cfg
    echo ' KERNEL kernel.gz ' >> isolinux.cfg
    echo ' APPEND initrd=rootfs.gz vga=ask ' >> isolinux.cfg

    rm ${BASEDIR}/${ISO_FILENAME}

    xorriso \
        -as mkisofs \
        -o ${BASEDIR}/${ISO_FILENAME} \
        -b isolinux.bin \
        -c boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        ./

    check_error_dialog "generating ISO"
}


test_qemu () {
    cd ${BASEDIR}
    if [ -f ${ISO_FILENAME} ];
    then
        qemu-system-x86_64 -m 128M -cdrom ${ISO_FILENAME} -boot d -vga std
    fi
    check_error_dialog "${ISO_FILENAME}"
}

clean_files () {
    sudo rm -rf ${SOURCEDIR}
    sudo rm -rf ${ROOTFSDIR}
    sudo rm -rf ${ISODIR}
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
