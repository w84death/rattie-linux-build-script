# RATTIE LINUX Research Operating System - Build Script

                   ^..^__  
                   *,, , )_- 
                 RATTIE LINUX 
           Research Operating System
    ------------------------------------------
       B A S H    B U I L D    S C R I P T
    ------------------------------------------


This is a simple script that will create a working Linux distribution from scratch.

It will download all the sources, compile them and put everything into the ISO image. Have fun!

Version **2018.6 v1.1**:

- Linux **3.16.56**
- BusyBox **1.28.4**
- SysLinux **6.03**
- Extras: ncurses 6.1, nano 2.9.8 (broken atm)

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
