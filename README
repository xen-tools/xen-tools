xen-tools
---------

Homepage:
    http://www.xen-tools.org/software/xen-tools

Git Repository:
    http://gitorious.org/xen-tools

Mailing Lists:
    http://www.xen-tools.org/software/xen-tools/lists.html

About:
  Xen-tools contains a collection of Perl scripts for working with Xen
 guest images under Linux.

  Using this software, you can easily create new Xen guests configured
 to be accessible over the network via OpenSSH.

  xen-tools currently has scripts to install most releases of Debian
 (starting with 3.1 "Sarge") and Ubuntu (starting with 6.06 LTS
 "Dapper") and some RPM-based distributions.

  However, currently only Debian and Ubuntu releases are tested and
 known to work, i.e.:

	Debian:
	  * Sarge 3.1 (i386 only)
	  * Etch 4.0
	  * Lenny 5.0
	  * Squeeze 6.0
	  * Wheezy 7.0 (preliminary support as it's not yet available)
	  * Sid (works at least at the moment of writing :-)

	Ubuntu:
	  * Dapper Drake 6.06
	  * Edgy Eft 6.10
	  * Feisty Fawn 7.04
	  * Gutsy Gibbon 7.10
	  * Hardy Heron 8.04 (see [1])
	  * Interpid Ibex 8.10
	  * Jaunty Jackaplope 9.04
	  * Karmic Koala 9.10
	  * Lucid Lynx 10.04
	  * Maverick Meerkat 10.10 (works at least at the moment of writing :-)
	  * Natty Narwhal 11.04 (preliminary support as it's not yet available)

  [1] There is an issue with debootstrap on hardy not installing ksyslogd
      This can be fixed by chrooting into the newly installed system
      and removing the startup scripts. See:
      http://www.linux-vserver.org/Installing_Ubuntu_8.04_Hardy_as_guest

  Xen-Tools are available prepackaged in Debian and as source tar-ball
 for local installation. Installing from source should work flawlessly
 on most Linux systems that meet the installation requirements.

Requirements
------------

  To use these tools you'll need the following software:

        * debootstrap
        * Perl
        * The Perl module "Text::Template"
        * The Perl module "Config::IniFiles"
          - Both of these modules are available as Debian packages,
            or direct from http://www.cpan.org/ for non-Debian distributions.
        * Make, if you are not installing through a package manager

  You can try to install RPM-based distributions such as CentOS, or
 Fedora Core, but you will need a correctly installed and configured
 "rinse" package. This is currently not supported.

  If you wish to create new Xen instances which may be controlled by
 users via a login shell you can have a look at the (currently
 unmaintained) xen-shell package which is available from:

          http://xen-tools.org/software/xen-shell/


Installation
------------

As root or with sudo, execute "make install".

See debian/README.source how to build the Debian package from a
checked out copy of the git repository (i.e. without a source tar
ball).


The Scripts
-----------

  Here is a brief description of each included script, for more
 thorough documentation please consult the appropriate man page.


xen-create-image
----------------

  This script is designed to create new images which may be used
 with the Xen hypervisor.

  This script performs the initial setup, then delegates the real
 work to a collection of helper scripts:

    * xt-install-image
      Installs a distribution into a directory.

    * xt-customize-image
      Run a collection of hook scripts to configure the freshly 
      installed system.

    * xt-create-xen-config
      Create a configuration file in /etc/xen such that Xen can
      boot the newly created machine.

    * xt-guess-suite-and-mirror
      In case of a Debian or Ubuntu Dom0, this script tries to guess
      the most suitable suite and mirror for DomUs based on the Dom0's
      /etc/apt/sources.list.


xen-create-nfs
--------------

  This script is similar in spirit to xen-create-image, but much
 less complex.  It allows the creation of Xen guests which are
 diskless, mounting their root filesystem over a remote NFS-share.

  There are not many options to tweak, but still a useful addition 
 to the suite.


xen-delete-image
----------------

  This script will allow you to completely remove Xen instances
 which have previously been created by xen-create-image, this
 includes removing the storage block devices from the system,
 and deleting the Xen configuration file.


xen-list-images
---------------

  List all the created images beneath a given root directory along
 with a brief overview of their setup details.


xen-update-image
----------------

  This script runs "apt-get update; apt-get upgrade" for a given
 Xen image.

  NOTES: 

  *  The image should not be running or corruption will occur!
  *  The script should only be used for Xen instances of Debian or
    a Debian-derived distribution.


-- 
The Xen-Tools Developer Team
