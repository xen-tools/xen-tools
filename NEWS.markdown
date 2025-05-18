xen-tools 4.10.0 (TODO: UNRELEASED)
===================================

New Features
------------

* Add support for specifying guest type. (GH #64; PR by Arno Bakker
  @arno481)
* Rename xm.tmpl to xl.tmpl and use more modern settings in the configuration file.
* Use UUIDs for fstab.
* Add PVGrub2/grub2-xen support.
* Add HVM UEFI support.
* Add PVH UEFI support.
* Add UEFI-ESP partition support for UEFI.

Distribution Releases Changes
-----------------------------

* Preliminary support for
  + Ubuntu 23.10 Mantic Minotaur
* Declare the following releases as EoL:
  + Ubuntu 22.10 Kinetic Kudu
* Debian Trixie is now Testing → remove dont-test flag

Other Changes
-------------

* Switch to pure Semantic Versioning including trailing zeros.
* Sync examples for "fs" and "fs" defaults in xen-create-image with
  (effective) values in xen-tools.conf: ext3 → ext4
* Remove useless tests.


xen-tools 4.9.2 (released 06 Feb 2023)
======================================

Distribution Releases Changes
-----------------------------

* Support for
  + Ubuntu 21.10 Impish Indri (EoL)
  + Ubuntu 22.04 Jammy Jellyfish (LTS)
  + Ubuntu 22.10 Kinetic Kudu
* Preliminary support for
  + Debian 14 Forky
  + Ubuntu 23.04 Lunar Lobster
* Declare the following releases as EoL:
  + Ubuntu 12.04 Precise Pangolin (LTS)
  + Ubuntu 20.10 Groovy Gorilla
  + Ubuntu 21.04 Hirsute Hippo
* xt-guess-suite-and-mirror:
  + Bump default Ubuntu fallback release to 22.04 Jammy LTS.
  + Add support for Ubuntu Ports APT repos (i.e. Xen on ARM64).

Documentation
-------------

* Place hints on "vsyscall=emulate" on more visible places.

Other Changes
-------------

* Fix bashism in release testing target "tidy".


xen-tools 4.9.1 (released 24 Oct 2021)
======================================

Bug Fixes
---------

* Fix missing `|` in regex in `hooks/debian/20-setup-apt`. (Closes
  Debian bug report #997668)

Other Changes
-------------

* Make test `xt/gitignore.t` work with git releases ≥ 2.32.0.
* Travis CI: stop testing again Perl `dev`. It seems to no more exist.
* Also create an `.orig.tar.xz` signature upon `make release`.


xen-tools 4.9 (released 29 Dec 2020)
====================================

New Features
------------

* Add Debian install rules for arm64. (GH #62; PR by Ian McLinden
  @ianmclinden)
* Add netplan p2p support for Ubuntu. (GH #58; PR by Volker Janzen
  @frootmig)

Bug Fixes
---------

* Fix typo in release name of the future Debian 12 release.
* Makefile: Actually install xen-resize-guest tool. (Thanks to
  Debian's Lintian tool reporting that there is a man-page without
  binary installed!)
* Distinguish between those Debian releases using `$dist/updates` for
  security updates and those who use `$dist-security`. Thanks to Paul
  Wise for the bug report. (Closes Debian bug report #972749.)
* Fix support for `lvm_thin`. Thanks to Andreas Sundstrom for the bug
  report and patch! (Closes Debian bug report #942244.)
* Mount `/proc` and `/dev` before calling update-grub. Thanks to
  Brandon Bradley for the bug report and patch. (Closes Debian bug
  report #815021.)
* Fix storage commandline options not overriding `xen-tools.conf`
  settings also in `xen-update-image` and `xen-delete-image`. (GH #57;
  patch by Volker Janzen @frootmig)

Distribution Releases Changes
-----------------------------

* Support for
  + Ubuntu 19.10 Eoan Ermine (EoL)
  + Ubuntu 20.04 Focal Fossa (LTS)
  + Ubuntu 20.10 Groovy Gorilla
* Preliminary support for
  + Debian 13 Trixie
  + Ubuntu 21.04 Hirsute Hippo
* Declare the following releases as EoL:
  + Ubuntu 17.10 Artful Aardvark (Was missing in previous release
    despite mentioned in this file.)
  + Ubuntu 18.10 Cosmic Cuttlefish
  + Ubuntu 19.04 Disco Dingo
  + Debian 7 Wheezy
  + Debian 8 Jessie
* Start all Debian releases since Stretch (9) with pygrub by default.

Other Changes
-------------

* Support running tests verbosely with Make target "test-verbose".
* Drop "dont-test" flag from bullseye.
* partitions/sample-server: Change options=sync to
  options=defaults. (GL MR !1; patch by Wolfgang Karall)


xen-tools 4.8 (released 9 Feb 2019)
===================================

New Features
------------

* Support for ZFS volumes (by Marc Bigler, GH #50)
* Support for LVM thin provisioning (by Nico Boehr, GH #47)
* Support for really random MAC addresses upon every `xen-create-image`
  invocation by using the new option `--randommac`. (by Pietro Stäheli,
  closes Debian bug report #855703)
* `distributions.conf` now supports arbitrary keyring files in
   `/usr/share/keyrings/`. (Needed for some EoL Ubuntu releases.)
* Support for netplan.io network configuration as used in recent
  Ubuntu releases. (Hook by Arno and Peter, GH #51)

Bug Fixes
---------

* Minor documentation fixes.
* Eliminate progress reporting which is useless in logs. (Yuri Sakhno,
  GH #42)
* Drop `pygrub` path detection from `xm.tmpl`, Xen prefers a path-less
  `bootloader='pygrub'`.

Distribution Releases Changes
-----------------------------

* Support for
  + Ubuntu 17.10 Artful Aardvark
  + Ubuntu 18.04 Bionic Beaver (LTS) (GH #51)
  + Ubuntu 18.10 Cosmic Cuttlefish
* Preliminary support for Ubuntu 19.04 Disco Dingo
* Knows about code name for Debian 12 (Bookworm).
* Considers Ubuntu Yakkety, Zesty and Artful being EoL.
* Set Ubuntu fallback suite to the latest LTS, i.e. 18.04 Bionic.

Other Changes
-------------

* Change all occurrences of `httpredir.debian.org` to
  `deb.debian.org` except those for the `debian-archive`. The latter
  now point to `archive.debian.org` directly.
* Many improvements for the `release-testing` script.
* Only run `xen-toolstack` helper script if both, `xm` and `xl` are
  present. Avoids warning about deprecated helper script.


xen-tools 4.7 (released 23 Jan 2017)
====================================

New Features
------------

New keywords in distributions.conf: default-keyring, dont-test

* Support situations where distributions (e.g. Squeeze) might be end
  of life, but its archive signing key is still not removed from the
  default keyring. (As of this writing, that's the case for Debian 6
  Squeeze on Debian 8 Jessie.)

Bug Fixes
---------

* Fixes reported error code in case of subcommand failure (Reported
  and fixed by Yuri Sakhno, thanks!)
* Fixes inconsistent/non-functional handling of --nopygrub parameter.
  Thanks Daniel Reichelt for the bug report and patch! (Closes
  Debian bug report #842609)
* Fixes possible missing gateway in generated /etc/network/interfaces.
  Thanks Santiago Vila for the bug report and patch! (Closes Debian
  bug report #764625)
* Fixes typo found by Lintian.
* Work around LVM related race condition when using --force with LVM:
  If an "lvremove" is immediately followed by an "lvcreate" for an LV
  with the same name, "mkswap" (and maybe other commands) occasionally
  fail with "Device or resource busy". Work around it by using sync
  and sleep.

Distribution Releases Changes
-----------------------------

* Support for Ubuntu 16.10 Yakkety Yak.
* Preliminary support for Ubuntu 17.04 Zesty Zapus.
* Knows about code names for Debian 10 (Buster) and 11 (Bullseye).
* Considers Debian Squeeze, Ubuntu Vivid and Wily being EoL.
* Knows about Ubuntu's "devel" alias.

Other Changes
-------------

* Risen default values for RAM sizes in /etc/xen-tools/xen-tools.cfg
  to cope with risen resource consumption and availability. (Closes
  Debian bug report #849867)
* Default file system is now ext4 (instead of ext3).

Test Suite
----------

* release-testing:
  + Mitigate race conditions with immediately re-used LVs:
    - Use per-test-unique host names.
    - Delete potential old images by testing xen-delete-image before
      calling xen-create-image. Add sync and sleep calls inbetween
      those two commands, too.
  + Use "set -e" instead of "|| break".
  + Declare testability in distributions.conf instead of hardcoding
    it. Mark buster and bullseye as not testable, too, for now.


xen-tools 4.6.2 (released 23 Dec 2015)
======================================

Bug Fixes
---------

* Make t/hooks-inittab.t using its own copy of the generic
  /etc/inittab for testing instead of using the system one's. (GH#36,
  should fix autopkgtest on systems with modified /etc/inittab)
* Fix unescaped braces (deprecated since Perl 5.22) in
  t/plugin-checks.t.

Other changes
-------------

* Support for using pygrub from /usr/local/bin/pygrub.
* Typo fixes.


xen-tools 4.6.1 (released 24 Oct 2015)
======================================

Distribution Releases Changes
-----------------------------

* Preliminary support for Ubuntu 16.04 LTS Xenial Xerus.

Bug Fixes
---------

* Fix Perl warning in t/hook-inittab.t if /etc/inittab isn't present.

Other Changes
-------------

* Declare GitHub as primary hosting.
* Integrate BUGS.markdown into README.markdown, move remaining
  contents of KNOWN_BUGS.markdown to the GitHub issue tracker.
* Minor README improvements.
* Neither use $#array in boolean context nor @array = undef anymore.


xen-tools 4.6 (released 20 Jul 2015)
====================================

New Features and Major Changes
------------------------------

* Drop all occurrences of apt's `--force-yes` parameter. It only
  forces the installation of untrusted packages and that's
  unwanted. (Closes Debian bug report #776487)
* Support passing commandline options with `--debootstrap-cmd`.
* Use MD5 as default hash method again, to be able to properly set
  passwords in older releases. Does not affect passwords changed later
  inside the DomU.
* Split off hardcoded release code names list and default mirrors in
  `xen-create-image` into separate configuration file which is parsed
  before the default settings or command-line options are set.
* Report all SSH fingerprints of the created DomU, not only RSA ones.
* Support VLANs with Open vSwitch (GH-2). Thanks to Félix Barbeira for
  the patch.


New Options
-----------

* `--keyring` (xen-create-image, xt-install-image)
* `--vlan`  (xen-create-image)

Distribution Releases Changes
-----------------------------

* Debian 9 Stretch (preliminary support)
* Ubuntu 15.10 Wily Werewolf (preliminary support; not yet supported by
  debootstrap, see Debian bug report #787117)
* Ubuntu 10.04 Lucid Lynx is now EoL.
* Ubuntu 14.10 Utopic Unicorn is now EoL.

Improvements
------------

* Make test suite support as-installed-testing.
* Multiple release workflow improvements (target `release` in
  `Makefile`).
* Supports `unstable`, `oldstable` and `oldoldstable` as distribution
  names, too. (`oldoldstable` is not yet supported by debootstrap, see
  Debian feature request #792734 in debootstrap.)

Bug Fixes
---------

* Fix usage of nonexistent variable in `removeDebianPackage` (Closes
  Debian bug report #774936) Thanks Lukas Schwaighofer!
* Allows `#` within configuration file comments. (Closes Debian bug
  report #783060; thanks Jean-Michel Nirgal Vourgère for the bug
  report and patch!)
* Use `-o APT::Install-Recommends=false` instead of
  `--no-install-recommends` for backwards compatibility with older APT
  versions which don't know either (but accept any `Foo=Bar` parameter
  to `-o`). Allows one to install earlier Debian releases (e.g. Etch)
  with the default configuration again.
* Pass `--yes` to `lvcreate` only if LVM version is 2.02.99 or
  higher. Fixes regression introduced with 4.5 by the fix for Debian
  bug report #754517.

Other Changes
-------------

* Change all occurrences of `http.debian.net` to
  `httpredir.debian.org`.
* Installs bash completion into `/usr/share/bash-completion/` (fixes
  lintian warning `package-install-into-obsolete-dir`)
* Testsuite: Optimize and clean up modules.sh.
* Split up test suite in functionality/compatibility tests (`t`) and
  author/release tests (`xt`).
* New example script helpful for release testing.


xen-tools 4.5 (released 25 Oct 2014)
====================================

New Features and Major Changes
------------------------------

* Apply patch by Adrian C. (anrxc) to allow to override hooks in
  `/usr/share/xen-tools/*.d/` with hooks in `/etc/xen-tools/hooks.d/`.

Distribution Releases Changes
-----------------------------

* Ubuntu 14.10 Utopic Unicorn.
* Ubuntu 15.04 Vivid Vervet (preliminary support)
* Mark Ubuntu 13.10 Saucy Salamander as EoL

Improvements
------------

* Use `686-pae` kernels instead of `686` kernels on Debian Wheezy and
  later. Thanks to Daniel Lintott! (Closes Debian bug report #742778)
* Pass `-y` option ("assume yes") to `yum` (Closes Debian bug report
  #735675) Thanks Lionel FÉLICITÉ!

Bug Fixes
---------

* Fix always empty gateway on Debian DomUs (Thanks Joan! LP: #1328794)
* Fix `lvcreate` awaiting user input when creating swap LV (Closes
  Debian bug report #754517) Thanks Eric Engstrom!
* Fix missing quoting in shell function `assert` in `hooks/common.sh`.
* Fix initial configuration summary in cases where `pygrub` is used.
* Fix corner cases where not the latest kernel would have been
  checked.
* `--password` overrides `--genpass`. (Closes Debian bug report
  #764143) Based on patch by Santiago Vila.
* Fix unaligned maxmem output of xen-create-image. (Closes Debian bug
  report #764126; Patch by Santiago Vila)
* Fix copy & paste errors in comments in typos in `roles/puppet`
  (Closes Debian bug report #764134; Patch by Santiago Vila)
* Fix typos in POD of `xen-create-image` (Closes Debian bug report
  #764153; Patch by Santiago Vila)

Other Changes
-------------

* Drop all xend related sanity checks, they cause more havoc nowadays
  than they help. Thanks Ian Campbell! (Closes Debian bug report
  #732456)
* pygrub detection: Prefer `/usr/lib/xen-default` over `/usr/lib/xen-x.y`.
* Add password length sanity check with fallback to default length.
* Raise default password length from 8 to 23.
* Flush output after each line in `runCommand()`.
* `Makefile`: Clean up coverage data in multiple targets.


xen-tools 4.4 (released 11 Dec 2013)
====================================

Listing includes changes of according beta releases.

New Features and Major Changes
------------------------------

* Preliminary support for `xl` toolstack
* Ships `/etc/initramfs-tools/conf.d/xen-tools` for generating Dom0
  initrds also suitable for DomU usage. Trigger `update-initramfs`.
* Installs a legacy `grub` in all `pygrub` based Debian/Ubuntu DomUs
  to be able to update the `menu.list` automatically.
* `hooks/common.sh`: `installDebianPackage` no more installs
  recommends, use `installDebianPackageAndRecommends` for that from
  now on.
* `hooks/common.sh`: Rename `installCentOS4Package` to
  `installRPMPackage`.  Add `installCentOS4Package` wrapper for
  backward compatibility.
* Better documents and checks requirements for the `--apt_proxy`
  value. (See #623443 for the corresponding apt issue.) Requires now
  `Data::Validate::URI`.
* Uses now `Data::Validate::Domain` and `Data::Validate::IP` for IP
  addresses and hostname checks.

Newly Supported Distribution Releases
-------------------------------------

* Debian 8 Jessie
* Ubuntu 13.04 Raring
* Ubuntu 13.10 Saucy (preliminary support; debootstrap doesn't have
  support for Saucy at the time of writing)

Improvements
------------

* Also recognize "M" and "G" instead of "MB" and "GB" as size unit for
  `--memory`. Also document the recognized units. (Closes Debian bug
  report #691320)
* `xen-list-images` now also outputs the file name of the config file.
* `xen-list-images` and `xen-delete-image` now understand `--extension`.
* Makefile accepts `DESTDIR=…`
* Move examples from debian/examples to examples.
* Adds default mount options for ext4, identical to ext2/ext3.
* By default install `linux-image-virtual` instead of
  `linux-image-server` on Ubuntu Intrepid and newer (Hopefully closes:
  #640099, LP #839492)
* Makes some options (like `--pygrub`) negatable.
* Rework "minimal" role to be less based on personal preferences:
  * No more installs sudo, vim, syslog-ng, etc.
  * Fixes usage together with pygrub.

Bug Fixes
---------

* Fix symbolic link hooks/centos-6/15-setup-arch (Closes Debian bug
  report #690299)
* Execute END block not on --version/--help/--manual (Closes Debian
  bug #684346)
* Move code for `--boot` feature to `END` block. Fixes missing SSH
  fingerprint display if `--boot` was used. (Closes Debian bug report
  #679183)
* Correctly handle aborts in `END` block. (Closes Debian bug report
  #704882)
* Fixes `--extension=` with empty parameter.
* Sarge amd64 case handle properly
* `xt-install-image`: Don't bail out if only `cdebootstrap` is
  installed but not `debootstrap` (Thanks Elmar Heeb!)
* Fix filesystem tools installation in `91-install-fs-tools` (which
  was broken since 4.3~rc1-1) by merging `91-install-fs-tools back`
  into `90-make-fstab`. (Closes Debian bug report #715340) Also
  supports RPM-based distributions now.
* Fixes creation of `ARRAY(0x#).log` named log files.

Other Changes
-------------

* Code deduplication to unify the `xen-*-image` scripts
* Moves `/usr/lib/xen-tools/` to `/usr/share/xen-tools/`
* Use `http.debian.net` as default Debian mirror if no mirror is given
  and `xt-guess-suite-and-mirror` is not used.
* Default DomUs to use the noop scheduler (Closes Debian bug report
  #693131)
* Fixes export of environment variables. Previously they could contain
  dashes and then were only accessible from within Perl, but not from
  within Bash.
* Uses `Test::NoTabs` instead of its own test for that.
* Removes unused Perl modules `Xen::Tools` and `Xen::Tools::Log` from
  source code. Also removes the according tests from the test
  suite. No more needs `Moose`.


xen-tools 4.3.1 (released 30-Jun-2012)
======================================

Bugfix Release only


xen-tools 4.3 (released 26-Jun-2012)
====================================

Listing includes changes of according beta releases.

New Features and Major Changes
------------------------------

* Massive code deduplication in hooks directory

New Options
-----------

* `--dontformat` (xen-create-image)
* `--finalrole`  (xen-create-image)
* `--apt_proxy`  (xen-create-image)

Newly Supported Distribution Releases
-------------------------------------

* Ubuntu 11.10 Oneiric
* Ubuntu 12.04 Precise
* Ubuntu 12.10 Quantal
* CentOS 6

Bug Fixes
---------

* Fix several testuite failures depending on the build host's
  installation.

Other Changes
-------------

* Remove most Mercurial traces


xen-tools 4.2.1 (released 17 Mar 2011)
======================================

Bugfix Release only


xen-tools 4.2 (released 05 Oct 2010)
====================================

First final release of the new Xen-Tools Team.

Supports Ubuntu up to 11.04 (Natty) and Debian up to 7.0 (Wheezy).


New Options
-----------

    --debootstrap-cmd (xen-create-image and xt-install-image)

New Features and Major Changes
------------------------------

* Uses `hvc0` and `xvda` devices by default
* Also supports `cdebootstrap`
* Preliminary btrfs support.
* Uses GeoIP for Debian mirrors: Default Debian mirror is now
  `cdn.debian.net`, see https://wiki.debian.org/DebianGeoMirror for
  details.
* New helper program `xt-guess-suite-and-mirror`, used to find the
  default mirror and suite.
