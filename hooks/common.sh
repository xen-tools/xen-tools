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

    if [ ! -z "${verbose}" ]; then
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

    if [ ! $* ] ; then
        echo "assert failed: $0:$lineno [$*]"
        exit
    fi
}


#
#  Install a number of Debian packages via apt-get.
#
#  We take special care so that daemons shouldn't start after installation
# which they might otherwise do.
#
#  NOTE:  Function not renamed with trailing "s" for compatability reasons.
#
installDebianPackage ()
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
    printf '#!/bin/bash\nexit 101\n' > ${prefix}/usr/sbin/policy-rc.d
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
    mount -t devpts devpts ${prefix}/dev/pts
    DEBIAN_FRONTEND=noninteractive chroot ${prefix} /usr/bin/apt-get --yes --force-yes install "$@"
    umount ${prefix}/dev/pts

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
# Disable the start-stop-daemon
#
disableStartStopDaemon ()
{
   local prefix="$1"
   assert "$LINENO" "${prefix}"
   local daemonfile="${prefix}/sbin/start-stop-daemon"

   mv "${daemonfile}" "${daemonfile}.REAL"
   echo '#!/bin/sh' > "${daemonfile}"
   echo "echo \"Warning: Fake start-stop-daemon called, doing nothing\"" >> "${daemonfile}"

   chmod 755 "${daemonfile}"
   logMessage "start-stop-daemon disabled / made a stub."
}



#
# Enable the start-stop-daemon
#
enableStartStopDaemon ()
{
   local prefix=$1
   assert "$LINENO" "${prefix}"
   local daemonfile="${prefix}/sbin/start-stop-daemon"

   #
   #  If the disabled file is present then enable it.
   #
   if [ -e "${daemonfile}.REAL" ]; then
       mv "${daemonfile}.REAL" "${daemonfile}"
       logMessage "start-stop-daemon restored to working order."
   fi

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
    logMessage "Purging Debian package ${package} from prefix ${prefix}"

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
#  Install a CentOS4 package via yum
#
installCentOS4Package ()
{
    prefix=$1
    package=$2

    #
    # Log our options
    #
    logMessage "Installing CentOS4 ${package} to prefix ${prefix}"

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

