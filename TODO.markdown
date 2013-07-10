TODO
====

See KNOWN_BUGS.markdown for real bugs.

Bugs to fix and features to add for 5.0
---------------------------------------

* `xen-create-image` man page overhaul:

  * ambiguous option list with regards to parameters
  * Set Fail in more situations where the script has clearly failed
    i.e.: lvm exists

* Test and support more file system types.

  Actually this should be pretty simple now that the parameters are
  stored in the configuration hash.

* Setup locales in the hooks?

  Currently no locales are set and this causes several domU errors
  which appear in the domU's logs.

* Documentation overhaul

  Better explain what roles /should be/ used for, and that roles
  are examples, and shouldn't cover every single scenario. They
  are also easy to write.

* Think again about disk_device checks :

  Newer Xen provides `xvda`, older provided `sda`. The current check for
  valid values of `disk_device` (used for root device in DomU `/etc/fstab`)
  does only allow those values.

  This forbids any deployment of LVM/RAID _inside_ DomU, which cannot
  be created by xen-tools anyway. So the current check is fine with the
  current possibilities of xen-tools, but could become a limitation.
  * Is it possible/wanted to "query" xend for default device names?
  * Is it possible to create `/dev/mapper` devices with xend conf?
  * Can we just avoid to ask for this value and not specify the device
    in `/etc/fstab` (and use `/dev/root`, `/dev/by-uuid`, or anything?)

* `xen-create-image --dist=…` / sources.list generation should be more fine-grained

  xen-tools should offer the possibility to enable/disable
  security/volatile/backports as well as
  contrib/non-free/universe/restricted/multiverse for each of them not
  only based on defaults plus the Dom0's sources.list

  One idea is to allow parameters like

    --dist="lenny:main,contrib,non-free;security;volatile:main"

  and maybe (if the default will be to include security) to also
  allow

    --dist="lenny;no-security"

  The second idea (by Mathieu Parent) is to have an
  `/etc/xen-tools/sources.list.d/` which then contains files like
  `lenny.list`, `lenny-server.list`, `karmic.list`, etc. which
  defaults to `$dist.list`, but can be also select with
  `--sources-list=lenny-server` (which looks for
  `./lenny-server.list`, `./lenny-server`,
  `/etc/xen-tools/sources.list.d/lenny-server.list` and
  `/etc/xen-tools/sources.list.d/lenny-server` in that order).

  Third variant is to use `/etc/xen-tools/sources.lists/` instead of
  `/etc/xen-tools/sources.list.d/` because that directory is no
  runparts-like directory.

* LVM snapshot support as an install source.

* Generic grub support

  This will generate a much nicer `menu.lst` as a side effect, as its
  currently generated once at install, and is never updated. Installing
  a full grub into the domU should update the `menu.lst` every time a
  new kernel is installed and will also use the domU distro's `menu.lst`
  conform.

* pv-grub support

  This is a ways away and will probably start with a `xen-pv-grub`
  package.

* Move the hooks directory to `/etc/xen-tools/` to officially allow
  added and modified hooks.

* Clean up the hooks directory

  We still have a link farm for hooks and a meta link farm for distro
  releases created on `make install`. It probably would be better if
  we would just have one directory per distro (like with debian) but
  without the need to created symlinks on `make install`.

  Currently CentOS's `25-setup-kernel` creates an fstab and
  `90-make-fstab` does again. It works, but that cries for debugging
  hell.

  `centos-5/25-setup-kernel` and `centos-6/25-setup-kernel` still
  differ and I'm not sure if that's necessary respectively what's the
  common denominator.

  `80-install-kernel` is not yet merged into one hook script.

  Common oneliners for code deduplication in the hooks/ directory:

    $ find -L . -not -xtype l -not -type d -not -path '*/common/*' | sort -t / -k3
    $ fdupes -r1 . | sort -t / -k3
    $ find . -type f | sim_text -ipTt 50 | tac | column -t

* Create users, add ssh pubkeys to `.ssh/authorized_keys`

  Still have to think of a good way of doing this. It would be nice
  To specify a directory of public keys, parsing the hostnames
  parsing the usernames from the ssh comment line.

  Potential ideas are to add options to add a given file as
  `authorized_keys` (e.g. a users public key) or to just add the Dom0's
  `/root/.ssh/authorized_keys` as the DomU's one.

* Generate ECDSA host keys where possible. (Likely depends on the
  to-be-installed SSH version.)

* More generic roles

  Deploy a web server or setup ssmtp directly via flag when setting up
  the machine. Open to suggestions, should just be some general use-cases
  that are fairly common.

* Sections for the xen-tools.conf file

  Currently it's really annoying when you are trying to create VMs
  on multiple subnets. It would be nice to specify with a flag what
  "type" of configuration you want, and a set of options specific to
  that flag could be parsed from xen-tools.conf

* Refactor the code for less variants of calling `cp`, `rm`, `mv`, etc.

  E.g. always use either `cp()` from `File::Copy` or `/bin/cp`, but
  not both. To allow verbose copying, I (Axel) would prefer `/bin/cp`
  over `cp();`.

* Parse numerical parameters transparently for the user

  The user shouldn't have to know whether he should specify size as
  `<size>G` or `<size>Gb` or `<size>`. This should be parsed without
  user interaction and rely on a common format.

* `xen-update-image` should mount `/dev/pts` before running apt-get

* `xen-update-image` should have options for using …

   * aptitude instead of apt-get
   * dist-upgrade instead of upgrade

* Support `cpu_weight` and other features from
  http://wiki.xensource.com/xenwiki/CreditScheduler

* Make used Xen toolstack configurable, i.e. via --xen-toolstack=xl

* Unify --debug and --dumpconfig. Likely make --debug exit
  gracefully. Document --debug if --dumpconfig is removed.

* Use `Perl::Critic`

* Refactor the different Ubuntu hooks directories so that only one
  ubuntu hooks directory is left.

  Then also refactor TLS disabling so that it works on all
  distributions the same. Currently Debian is a special case and
  Ubuntu half a special case.

* Remove from the (unused) Xen::Tools what's already in the used
  Xen::Tools::Common.

* Add test for `--size` constraints (upper- and lowercase letters,
  with and without `B`, etc.)

  * Needs a `--dry-run` or `--check-constraints` option in
    `xen-create-image` first. Which probably both would be a good
    idea.

* Replace several occurences of backticks with runCommand. (Mostly
  mount commands in `xen-update-image`. The calls to uname or
  lsb_release should be fine.)

Stuff from Steve's TODO list / Generic TODOs
--------------------------------------------

* Write more test cases.

* `xen-delete-image` should unallocate any used IP addresses.

* `installGentooPackage` in `hooks/common.sh` is a stub and does
  nothing yet.

Axel's Break-Backwards-Compatibility Wishlist
---------------------------------------------

* Make empty extension the default

  This would ease tab completion and CLI parameter reusage with "xm
  create" and friends.

* Check if we can reduce `MAKEDEV` invocations in
  `hooks/common/55-create-dev`

  `MAKEDEV std` is called in any case. First comment says "Early
  termination if we have a couple of common devices present should
  speed up installs which use `--copy`/`--tar`" and then "We still
  need to make sure the basic devices are present" and calls `MAKEDEV`
  more often than otherwise.

  Additionally the `55-create-dev` for CentOS/Fedora just created
  `console`, `zero` and `null`. `zero` and `null` are part of `MAKEDEV
  std`, perhaps can we reduce it to that. `console` is part of
  `MAKEDEV generic`.

  Additionally the devices `hda`, `sda` and `tty1` may not necessary
  in any case, but instead `hvc0` should be created for sure in many
  cases. Nothing cares about `$serial_device` there either.

  Current `MAKEDEV` implementation support more than one device as
  parameter. That could reduce the `MAKEDEV` calls from currently six
  to two.

* Uncouple generating auto start symlinks from `--boot`.

  Maybe add some `--autostart` or such.

* MAC addresses should no more depend on the distribution.

* Let the admin switch between MAC addresses based on XenSource's OUI,
  its organisation's own OUI or locally administrated MAC addresses.
  See also http://wiki.xen.org/wiki/Xen_Networking#MAC_addresses

* More radical Code Deduplication

  `bin/x*` currently still contain similar code like e.g. in the
  function parseCommandLineArguments. This should be cleaned up, too,
  but may need a bigger redesign.
