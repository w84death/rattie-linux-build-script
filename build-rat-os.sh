#!/bin/bash
# ******************************************************************************
# RATTIE LINUX - 2018.06
# ******************************************************************************


# ******************************************************************************
# SETTINGS
# ******************************************************************************

SCRIPT_NAME="RATTIE LINUX Build Script"
SCRIPT_VERSION="0.2"
LINUX_NAME="RATTIE LINUX"
DISTRIBUTION_VERSION="2018.6"
ARCH="x86_64"
KERNEL_VERSION="4.17"
KERNEL_BRANCH="4.x"
BUSYBOX_VERSION="1.28.4"
SYSLINUX_VERSION="6.03"
NCURSES_VERSION="6.1"
NANO_VERSION="2.9.8"
NANO_BRANCH="2.9"
LINKS_VERSION="2.16"
UTIL_VERSION="2.32"

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
    --menu "Create the ${LINUX_NAME} Operating System. Run each step in order." 18 64 10 \
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
    WIDTH=48; HEIGHT=12; fi
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --msgbox "${2}" ${HEIGHT} ${WIDTH}
}

ask_dialog() {
    dialog --stdout \
    --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --yesno "${2}" 12 48
}

# ******************************************************************************
# MENUS
# ******************************************************************************

menu_introduction () {
    show_dialog "INTRODUCTION" "Welcome to the ${SCRIPT_NAME}. This is a simple file that will create a working Linux distribution from scratch.\nIt will download all the sources, complie them and put everything into the ISO image. Have fun!" \
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
    ask_dialog "BUILD KERNEL" "Build Linux Kernel ${KERNEL_VERSION}" \
    && build_kernel \
    && MENU_ITEM_SELECTED=3 \
    && show_dialog "BUILD KERNEL" "Done."
    return 0
}
menu_build_busybox () {
    ask_dialog "BUILD BUSYBOX" "Build BusyBox ${BUSYBOX_VERSION}" \
    && build_busybox \
    && MENU_ITEM_SELECTED=4 \
    && show_dialog "BUILD BUSYBOX" "Done."
    return 0
}

menu_build_extras () {
    ask_dialog "BUILD EXTRAS" "Build extra packages like ncurses, nano, links." \
    && build_extras \
    && MENU_ITEM_SELECTED=5 \
    && show_dialog "BUILD EXTRAS" "Done."
    return 0
}

menu_generate_rootfs () {
    ask_dialog "GENERATE ROOTFS" "Generate root file system." \
    && generate_rootfs \
    && MENU_ITEM_SELECTED=6 \
    && show_dialog "GENERATE ROOTFS" "Done."
    return 0
}

menu_generate_iso () {
    ask_dialog "GENERATE ISO" "Generate ISO image." \
    && generate_iso \
    && MENU_ITEM_SELECTED=7 \
    && show_dialog "GENERATE ISO" "Done."
    return 0
}

menu_qemu () {
    ask_dialog "TEST IMAGE IN QEMU" "Test generated image on emulated computer (QEMU)." \
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
    return 0
}

build_busybox () {
    return 0
}

build_extras () {
    return 0
}

generate_rootfs () {
    return 0
}

generate_iso () {
    return 0
}

test_qemu () {
    return 0
}

clean_files () {
    return 0
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
