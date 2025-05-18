#!/bin/sh
#
#  Common shell functions which may be used by any hook script
#
#  If you find that a distribution-specific hook script or two
# are doing the same thing more than once it should be added here.
#
#  This script also includes a logging utility which you're encouraged
# to use.
#
#  The routines here may be freely called from any role script(s) you
# might develop.
#
# Steve
# --
#



#
#  If we're running verbosely show a message, otherwise swallow it.
#
logMessage ()
{
    message="$*"

    if [ -n "${verbose}" ]; then
        echo $message
    fi
}



#
#  Test the given condition is true, and if not abort.
#
#  Sample usage:
#    assert "$LINENO" "${verbose}"
#
assert ()
{
    lineno="?"

    if [ -n "${LINENO}" ]; then
        # our shell defines variable LINENO, great!
        lineno=$1
        shift
    fi

    if [ ! "$*" ] ; then
        echo "assert failed: $0:$lineno [$*]"
        exit
    fi
}


#
#  Install a number of Debian packages via apt-get including Recommends.
#
#  We take special care so that daemons shouldn't start after installation
# which they might otherwise do.
#
installDebianPackageAndRecommends ()
{
    prefix=$1
    shift

    #
    # Log our options
    #
    logMessage "Installing Debian packages $@ to prefix ${prefix}"

    #
    #  We require a package + prefix
    #
    assert "$LINENO" "${prefix}"

    #
    # Prefix must be a directory.
    #
    assert "$LINENO" -d ${prefix}

    #
    #  Use policy-rc to stop any daemons from starting.
    #
    printf '#!/bin/sh\nexit 101\n' > ${prefix}/usr/sbin/policy-rc.d
    chmod +x ${prefix}/usr/sbin/policy-rc.d

    #
    # Disable the start-stop-daemon - this shouldn't be necessary
    # with the policy-rc.d addition above, however leaving it in
    # place won't hurt ..
    #
    disableStartStopDaemon ${prefix}

    #
    # Install the packages
    #
    DEBIAN_FRONTEND=noninteractive chroot ${prefix} /usr/bin/apt-get --yes install "$@" 2>&1 | sed --expression="s/\rExtracting templates from packages: [0-9]\+%//g;s/(Reading database ... \([0-9]\+%\)\?\r//g"

    #
    #  Remove the policy-rc.d script.
    #
    rm -f ${prefix}/usr/sbin/policy-rc.d

    #
    # Re-enable the start-stop-daemon
    #
    enableStartStopDaemon ${prefix}

}

#
#  Install a number of Debian packages via apt-get, but without Recommends
#
#  We take special care so that daemons shouldn't start after installation
# which they might otherwise do.
#
#  NOTE:  Function not renamed with trailing "s" for compatibility reasons.
#
installDebianPackage ()
{
    prefix=$1
    shift

    installDebianPackageAndRecommends ${prefix} -o APT::Install-Recommends=false "$@"
}

#
#  Generate a Debian-/Ubuntu-compliant menu.lst for legacy GRUB
#
generateDebianGrubMenuLst ()
{
    prefix="$1"
    DOMU_ISSUE="$2"
    DOMU_KERNEL="$3"
    DOMU_RAMDISK="$4"

    #
    # Log our options
    #
    logMessage "Generating a legacy GRUB menu.lst into prefix ${prefix}"

    #
    #  We require at least 3 parameters
    #
    assert "$LINENO" "${prefix}"
    assert "$LINENO" "${DOMU_ISSUE}"
    assert "$LINENO" "${DOMU_KERNEL}"

    #
    # Prefix must be a directory, kernel a file
    #
    assert "$LINENO" -d ${prefix}
    assert "$LINENO" -f "${prefix}/boot/${DOMU_KERNEL}"

    #
    # Generate a menu.lst for pygrub
    #

    mkdir -p ${prefix}/boot/grub
    cat << E_O_MENU > ${prefix}/boot/grub/menu.lst
default         0
timeout         2

### BEGIN AUTOMAGIC KERNELS LIST
## lines between the AUTOMAGIC KERNELS LIST markers will be modified
## by the debian update-grub script except for the default options below

## DO NOT UNCOMMENT THEM, Just edit them to your needs

## ## Start Default Options ##
## default kernel options
## default kernel options for automagic boot options
## If you want special options for specific kernels use kopt_x_y_z
## where x.y.z is kernel version. Minor versions can be omitted.
## e.g. kopt=root=/dev/hda1 ro
##      kopt_2_6_8=root=/dev/hdc1 ro
##      kopt_2_6_8_2_686=root=/dev/hdc2 ro
# kopt=root=/dev/xvda ro earlyprintk=xen

## default grub root device
## e.g. groot=(hd0,0)
# groot=(hd0,0)

## should update-grub create alternative automagic boot options
## e.g. alternative=true
##      alternative=false
# alternative=true

## should update-grub lock alternative automagic boot options
## e.g. lockalternative=true
##      lockalternative=false
# lockalternative=false

## additional options to use with the default boot option, but not with the
## alternatives
## e.g. defoptions=vga=791 resume=/dev/hda5
# defoptions=

## should update-grub lock old automagic boot options
## e.g. lockold=false
##      lockold=true
# lockold=false

## altoption boot targets option
## multiple altoptions lines are allowed
## e.g. altoptions=(extra menu suffix) extra boot options
##      altoptions=(single-user) single
# altoptions=(single-user mode) single

## controls how many kernels should be put into the menu.lst
## only counts the first occurrence of a kernel, not the
## alternative kernel options
## e.g. howmany=all
##      howmany=7
# howmany=all

## should update-grub create memtest86 boot option
## e.g. memtest86=true
##      memtest86=false
# memtest86=false

## should update-grub adjust the value of the default booted system
## can be true or false
# updatedefaultentry=false

## should update-grub add savedefault to the default options
## can be true or false
# savedefault=false

## ## End Default Options ##

### END DEBIAN AUTOMAGIC KERNELS LIST

# Entries statically generated bu xen-tools upon installation. Maybe
# removed manually if the entries above (generated by update-grub)
# seem to work fine.

title           $DOMU_ISSUE
root            (hd0,0)
kernel          /boot/$DOMU_KERNEL root=/dev/xvda ro earlyprintk=xen
initrd          /boot/$DOMU_RAMDISK

title           $DOMU_ISSUE (Single-User)
root            (hd0,0)
kernel          /boot/$DOMU_KERNEL root=/dev/xvda ro single earlyprintk=xen
initrd          /boot/$DOMU_RAMDISK

title           $DOMU_ISSUE (Default Kernel)
root            (hd0,0)
kernel          /vmlinuz root=/dev/xvda ro earlyprintk=xen
initrd          /initrd.img

title           $DOMU_ISSUE (Default Kernel, Single-User)
root            (hd0,0)
kernel          /vmlinuz root=/dev/xvda ro single earlyprintk=xen
initrd          /initrd.img

E_O_MENU


}



#
# Disable the start-stop-daemon
#
disableStartStopDaemon ()
{
   local prefix="$1"
   assert "$LINENO" "${prefix}"
   for starter in start-stop-daemon initctl; do
      local daemonfile="${prefix}/sbin/${starter}"

      if [ -e "${daemonfile}" ]; then
         mv "${daemonfile}" "${daemonfile}.REAL"
         echo '#!/bin/sh' > "${daemonfile}"
         echo "echo \"Warning: Fake ${starter} called, doing nothing\"" >> "${daemonfile}"

         chmod 755 "${daemonfile}"
         logMessage "${starter} disabled / made a stub."
      fi
   done
}



#
# Enable the start-stop-daemon
#
enableStartStopDaemon ()
{
   local prefix=$1
   assert "$LINENO" "${prefix}"
   for starter in start-stop-daemon initctl; do
      local daemonfile="${prefix}/sbin/${starter}"

      #
      #  If the disabled file is present then enable it.
      #
      if [ -e "${daemonfile}.REAL" ]; then
          mv "${daemonfile}.REAL" "${daemonfile}"
          logMessage "${starter} restored to working order."
      fi
   done
}



#
#  Remove the specified Debian packages.
#
#  NOTE:  Function not renamed with trailing "s" for compatibility reasons.
#
removeDebianPackage ()
{
    prefix=$1
    shift

    #
    # Log our options
    #
    logMessage "Purging Debian package $@ from prefix ${prefix}"

    #
    #  We require a prefix
    #
    assert "$LINENO" "${prefix}"

    #
    # Prefix must be a directory.
    #
    assert "$LINENO" -d ${prefix}

    #
    # Purge the packages we've been given.
    #
    chroot ${prefix} /usr/bin/apt-get remove --yes --purge "$@"

}


#
#  Install a RPM package via yum
#
installRPMPackage ()
{
    prefix=$1
    package=$2

    #
    # Log our options
    #
    logMessage "Installing RPM ${package} to prefix ${prefix}"

    #
    #  We require a package + prefix
    #
    assert "$LINENO" "${package}"
    assert "$LINENO" "${prefix}"

    #
    # Prefix must be a directory.
    #
    assert "$LINENO" -d ${prefix}

    #
    # Install the package
    #
    chroot ${prefix} /usr/bin/yum -y install ${package}
}

# Backwards Compatibility Function
installCentOS4Package () ( installRPMPackage "$@" )


#
#  Functions to test if we're on a redhatesk or debianesk system
#
isDeb() ( [ -x $1/usr/bin/apt-get -a -x $1/usr/bin/dpkg ] )
isYum() ( [ -x $1/usr/bin/yum ] )


#
#  Install a package using whatever package management tool is available
#
installPackage ()
{
        prefix=$1
        package=$2

        if isDeb ; then
                installDebianPackage "$@"

        elif isYum ; then
                installRPMPackage "$@"

        else
                logMessage "Unable to install package ${package}; no package manager found"
        fi
}



#
#  Install a package upon a gentoo system via emerge.
#
# TODO: STUB
#
installGentooPackage ()
{
    prefix=$1
    package=$2

    #
    # Log our options
    #
    logMessage "Installing Gentoo package ${package} to prefix ${prefix}"

    logMessage "NOTE: Not doing anything - this is a stub - FIXME"

}
