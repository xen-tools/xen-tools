KNOWN BUGS in xen-tools
=======================

Bugs to fix before next release
-------------------------------

* Older versions of LVM don't understand `--yes` while newer versions
  require it. The fix for the latter
  ([Debian bug report 754517](https://bugs.debian.org/754517))
  introduced a regression with older LVM versions, e.g. on Debian 7
  Wheezy. There's likely an LVM version check and an according switch
  necessary.

Bugs to fix rather soon
-----------------------

* `xen-delete-image` doesn't remove all logical volumes if `--partitions` is used.

   See the link below for details how to reproduce. Reproducable at
   least with `--lvm`. Thanks to Antoine Benkemoun for reporting.

   [Bug Report](http://xen-tools.org/pipermail/xen-tools-discuss/2010-May/000757.html)

* partitions were mounted in config file order, not in mountpoint order.
  That implies that if you specified :

    /boot
    /

  in that order, `/` was mounted _over_ `/boot`, and you would not
  _see_ `/boot`.  Xen-Tools would then install `boot` on your `/`
  partition, and your boot device was just empty and unbootable.

  Workaround for 4.2 is to write your partition file such as mounts overlap
  correctly when mounted in specified order.

  Current (unreleased) fix is to sort by mountpoint length.

  Fix would be to reproduce what mount does with mount `-a`.
