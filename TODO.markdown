TODO
====

Most things which used to be in here were moved to
[xen-tools' issue tracker at GitHub](https://github.com/xen-tools/xen-tools/issues).

Bugs to fix and features to add for 5.0
---------------------------------------

* Fix xdm and gdm roles wrt. to uptodate package names.

* Test and support more file system types.

  Actually this should be pretty simple now that the parameters are
  stored in the configuration hash.

* Setup locales in the hooks?

  Currently no locales are set and this causes several domU errors
  which appear in the domU's logs.

* Generic grub support

  This will generate a much nicer `menu.lst` as a side effect, as its
  currently generated once at install, and is never updated. Installing
  a full grub into the domU should update the `menu.lst` every time a
  new kernel is installed and will also use the domU distro's `menu.lst`
  conform.

* More generic roles

  Deploy a web server or setup ssmtp directly via flag when setting up
  the machine. Open to suggestions, should just be some general use-cases
  that are fairly common.

* Sections for the xen-tools.conf file

  Currently it's really annoying when you are trying to create VMs
  on multiple subnets. It would be nice to specify with a flag what
  "type" of configuration you want, and a set of options specific to
  that flag could be parsed from xen-tools.conf

* Parse numerical parameters transparently for the user

  The user shouldn't have to know whether he should specify size as
  `<size>G` or `<size>Gb` or `<size>`. This should be parsed without
  user interaction and rely on a common format.

* Make used Xen toolstack configurable, i.e. via --xen-toolstack=xl

* Add test for `--size` constraints (upper- and lowercase letters,
  with and without `B`, etc.)

  * Needs a `--dry-run` or `--check-constraints` option in
    `xen-create-image` first. Which probably both would be a good
    idea.

* Maybe check for `vsyscall=emulate` in `GRUB_CMDLINE_LINUX_DEFAULT`
  in `/etc/default/grub` if trying to install an affected Linux
  distribution.

Stuff from Steve's TODO list / Generic TODOs
--------------------------------------------

* Write more test cases.

* `xen-delete-image` should unallocate any used IP addresses.
