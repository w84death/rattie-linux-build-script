# RATTIE LINUX Research Operating System - Build Script

                   ^..^__
                   *,, , )_-
                 RATTIE LINUX
           Research Operating System
    ------------------------------------------
       B A S H    B U I L D    S C R I P T
    ------------------------------------------

**ALL EXTRA APPLICATIONS ARE NOT RECOGIZABLE BY ROOT USER AT THE MOMENT. I'M LOOKING FOR A HELP TO FIX THAT**

This is a simple script that will create a working Linux distribution from scratch.

It will download all the sources, compile them and put everything into the ISO image. Have fun!

Version **2018.6 v1.3**:

    KERNEL_BRANCH="4.x"; KERNEL_VERSION="4.4.135"
    BUSYBOX_VERSION="1.28.4"
    SYSLINUX_VERSION="6.03"

Extra applications:

    KBD_VERSION="2.0.4"
    NCURSES_VERSION="6.1"
    VIM_VERSION="8.1"; VIM_DIR="81"
    NANO_BRANCH="2.9"; NANO_VERSION="2.9.8"
    FIGLET_VERSION="2.2.5"
    LINKS_VERSION="2.16"
    VRMS_VERSION="1.21"

Final ISO size: **10.1 MB** (10,094,592 bytes)

## ToC of the script

    0 "INTRODUCTION"
    1 "PREPARE DIRECTORIES"
    2 "BUILD KERNEL"
    3 "BUILD BUSYBOX"
    4 "BUILD EXTRAS"
    5 "GENERATE ROOTFS"
    6 "GENERATE ISO"
    7 "TEST IMAGE IN QEMU"
    8 "CLEAN FILES"

## Media

![The script - main menu](https://i.imgur.com/Ch8PRfN.png)

![The script - introduction](https://i.imgur.com/su6xgcC.png)

![Rattie Linux in action - boot](https://i.imgur.com/om6mM9Y.png)

![Rattie Linux in action - login](https://i.imgur.com/4rDYj8H.png)

![Rattie Linux in action - uname](https://i.imgur.com/k2sHOCo.png)

## Inspiration

I have a little experience in LFS and Arch. Minimal Linux Scripts is something new to me. I base my work on those projects:

- [The Dao of Minimal Linux Live](http://minimal.idzona.com/the_dao_of_minimal_linux_live.txt)
- [Minimal Linux Script](https://github.com/ivandavidov/minimal-linux-script/blob/master/minimal.sh)
- [Minimal Linux Live](http://minimal.idzona.com)

## Requiments

Around **1.5GiB** free space.

Ubuntu/Debian

    sudo apt-get install wget bc build-essential gawk xorriso dialog qemu texinfo libncurses5-dev libncursesw5-dev
