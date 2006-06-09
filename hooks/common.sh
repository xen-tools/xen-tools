#
#  Common shell functions which may be used by any hook script
#
#  If you find that a distribution-specific hook script or two
# are doing the same thing more than once it should be added here.
#
#  This script also includes a logging utility which you're encouraged
# to use.
#
# Steve
# -- 
#



#
#  If we're running verbosely show a message, otherwise swallow it.
#
function logMessage
{
    message="$*"

    if [ ! -z "${verbose}" ]; then
	echo $message
    fi
}



#
#  Install a Debian package via apt-get.
#
function installDebianPackage
{
    prefix=$1
    package=$2

    #
    # Log our options
    #
    logMessage "Installing Debian package ${package} to prefix ${prefix}"

    #
    # Make sure the prefix exists.
    #
    if [ -z "${prefix}" ]; then
	logMessage "Prefix '${prefix}' does not exist.  Abortin"
	return
    fi

    #
    # Install the package
    #
    DEBIAN_FRONTEND=noninteractive chroot ${prefix} /usr/bin/apt-get --yes --force-yes install ${package}

}



#
#  Install a CentOS4 package via yum
#
function installCentOS4Package
{
    prefix=$1
    package=$2

    #
    # Log our options
    #
    logMessage "Installing CentOS4 ${package} to prefix ${prefix}"

    #
    # Make sure the prefix exists.
    #
    if [ -z "${prefix}" ]; then
	logMessage "Prefix '${prefix}' does not exist.  Abortin"
	return
    fi

    #
    # Install the package
    #
    chroot ${prefix} /usr/bin/yum -y install ${package}
}
