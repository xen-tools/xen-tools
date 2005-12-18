#
#  Utility makefile for people working with Yawns.
#


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = /tmp
VERSION     = `date +%d-%m-%y`
BASE        = xen-tools




nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean     - Remove bogus files."
	@echo " commit    - Commit changes, after running check."
	@echo " diff      - Run a 'cvs diff'."
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


update: 
	cvs -z3 update -A -d 2>/dev/null
