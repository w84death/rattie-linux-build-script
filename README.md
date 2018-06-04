# RATTIE LINUX Build Script

    ----------------------------------- 2018.6
                    ^..^__
                    *,, , )_-
        Welcome to RATTIE LINUX by kj/P1X
    ------------------------------------------


This is a simple script that will create a working Linux distribution from scratch.

It will download all the sources, compile them and put everything into the ISO image. Have fun!

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

![The script](https://i.imgur.com/hijWGm6.png)

![Rattie Linux in action](https://i.imgur.com/3jVu9Jy.png)

## Inspiration

I have a little experience in LFS and Arch. Minimal Linux Scripts is something new to me. I base my work on those projects:

- [The Dao of Minimal Linux Live](http://minimal.idzona.com/the_dao_of_minimal_linux_live.txt)
- [Minimal Linux Script](https://github.com/ivandavidov/minimal-linux-script/blob/master/minimal.sh)
- [Minimal Linux Live](http://minimal.idzona.com)

## Requiments

Around **1.5GiB** free space.

Ubuntu/Debian

    sudo apt-get install wget bc build-essential gawk xorriso dialog qemu texinfo libncurses5-dev libncursesw5-dev
