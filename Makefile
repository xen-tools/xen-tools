#
#  Utility makefile for people working with xen-tools
#
# Steve
# --
# http://www.steve.org.uk/
#
# $Id: Makefile,v 1.10 2005-12-19 18:08:45 steve Exp $


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = /tmp
VERSION     = 0.2
BASE        = xen-tools




nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean     - Remove bogus files."
	@echo " commit    - Commit changes, after running check."
	@echo " diff      - Run a 'cvs diff'."
	@echo " install   - Install the software"
	@echo " release   - Make a release tarball"
	@echo " uninstall - Remove the software"
	@echo " update    - Update from the CVS repository."
	@echo " "


.PHONY:
	@true

clean:
	@find . -name '.*~' -exec rm \{\} \;
	@find . -name '.#*' -exec rm \{\} \;
	@find . -name '*~' -exec rm \{\} \;
	@find . -name '*.bak' -exec rm \{\} \;
	@find . -name 'tags' -exec rm \{\} \;


commit: test
	cvs -z3 commit


diff:
	cvs diff --unified 2>/dev/null


install:
	cp xen-create-image /usr/bin
	cp xen-delete-image /usr/bin
	cp xen-duplicate-image /usr/bin
	cp xen-list-images /usr/bin
	cp xen-update-image /usr/bin
	chmod 755 /usr/bin/xen-create-image
	chmod 755 /usr/bin/xen-delete-image
	chmod 755 /usr/bin/xen-duplicate-image
	chmod 755 /usr/bin/xen-list-images
	chmod 755 /usr/bin/xen-update-image
	-mkdir /etc/xen-tools
	cp etc/xen-tools.conf /etc/xen-tools


release: clean
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name "CVS" -print | xargs rm -rf
	cd $(DIST_PREFIX) && tar -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)


test:
	@perl -MTest::Harness -e '$$Test::Harness::verbose=0; runtests @ARGV;' tests/*.t


test-verbose:
	@perl -MTest::Harness -e '$$Test::Harness::verbose=1; runtests @ARGV;' tests/*.t


uninstall:
	rm /usr/bin/xen-create-image
	rm /usr/bin/xen-delete-image
	rm /usr/bin/xen-duplicate-image
	rm /usr/bin/xen-list-images
	rm /usr/bin/xen-update-image
	rm /etc/xen-tools/xen-tools.conf
	-rmdir /etc/xen-tools/

update: 
	cvs -z3 update -A -d 2>/dev/null
