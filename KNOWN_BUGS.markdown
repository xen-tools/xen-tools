KNOWN BUGS in xen-tools
=======================

Bugs to fix rather soon
-----------------------

* `xen-delete-image` doesn't remove all logical volumes if `--partitions` is used.

   See the link below for details how to reproduce. Reproducable at
   least with `--lvm`. Thanks to Antoine Benkemoun for reporting.

   [Bug Report](http://xen-tools.org/pipermail/xen-tools-discuss/2010-May/000757.html)
