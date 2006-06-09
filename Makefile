#
#  Utility makefile for people working with xen-tools
#
# Steve
# --
# http://www.steve.org.uk/
#
# $Id: Makefile,v 1.48 2006-06-09 09:27:33 steve Exp $


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = /tmp
VERSION     = 1.6
BASE        = xen-tools


#
#  Installation prefix
#
prefix=


nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean         = Remove bogus files."
	@echo " commit        = Commit changes, after running check."
	@echo " diff          = Run a 'cvs diff'."
	@echo " install       = Install the software"
	@echo " manpages      = Make manpages beneath man/"
	@echo " manpages-html = Make HTML manpages beneath man/"
	@echo " release       = Make a release tarball"
	@echo " uninstall     = Remove the software"
	@echo " update        = Update from the CVS repository."
	@echo " "



changelog:
	-if [ -x /usr/bin/cvs2cl ] ; then cvs2cl; fi
	-rm ChangeLog.bak


clean:
	@find . -name '.*~' -exec rm \{\} \;
	@find . -name '.#*' -exec rm \{\} \;
	@find . -name '*~' -exec rm \{\} \;
	@find . -name '*.bak' -exec rm \{\} \;
	@find . -name '*.tmp' -exec rm \{\} \;
	@find . -name 'tags' -exec rm \{\} \;
	@find . -name '*.8.gz' -exec rm \{\} \;
	@find man -name '*.html' -exec rm \{\} \;
	@if [ -e build-stamp ]; then rm -f build-stamp ; fi
	@if [ -e configure-stamp ]; then rm -f configure-stamp ; fi
	@if [ -d debian/xen-tools ]; then rm -rf ./debian/xen-tools; fi

commit: test
	cvs -z3 commit


diff:
	cvs diff --unified 2>/dev/null


install: manpages
	mkdir -p ${prefix}/usr/bin
	cp xen-create-image ${prefix}/usr/bin
	cp xen-delete-image ${prefix}/usr/bin
	cp xen-duplicate-image ${prefix}/usr/bin
	cp xen-list-images ${prefix}/usr/bin
	cp xen-update-image ${prefix}/usr/bin
	chmod 755 ${prefix}/usr/bin/xen-create-image
	chmod 755 ${prefix}/usr/bin/xen-delete-image
	chmod 755 ${prefix}/usr/bin/xen-duplicate-image
	chmod 755 ${prefix}/usr/bin/xen-list-images
	chmod 755 ${prefix}/usr/bin/xen-update-image
	-mkdir -p ${prefix}/etc/xen-tools
	-mkdir -p ${prefix}/etc/xen-tools/hook.d/
	-mkdir -p ${prefix}/etc/xen-tools/skel/
	-mkdir -p ${prefix}/etc/xen-tools/role.d/
	cp etc/hook.d/[0-9]* ${prefix}/etc/xen-tools/hook.d/
	cp etc/role.d/builder ${prefix}/etc/xen-tools/role.d/
	cp etc/role.d/gdm ${prefix}/etc/xen-tools/role.d/
	cp etc/role.d/minimal ${prefix}/etc/xen-tools/role.d/
	cp etc/role.d/xdm ${prefix}/etc/xen-tools/role.d/
	chmod 755 ${prefix}/etc/xen-tools/role.d/*
	chmod 755 ${prefix}/etc/xen-tools/hook.d/[0-9]*
	-mkdir -p ${prefix}/usr/share/man/man8/
	cp man/*.8.gz ${prefix}/usr/share/man/man8/
	cp etc/xen-tools.conf ${prefix}/etc/xen-tools/
	-mkdir -p ${prefix}/etc/bash_completion.d
	cp misc/xen-tools ${prefix}/etc/bash_completion.d/
	cp misc/xm ${prefix}/etc/bash_completion.d/


manpages:
	for i in xen-*; do pod2man --release=${VERSION} --official --section=8 $$i man/$$i.8; done
	for i in man/*.8; do gzip --force -9 $$i; done


manpages-html:
	for i in xen-*; do pod2html $$i > man/$$i.html; done


release: update-version clean changelog
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name "CVS" -print | xargs rm -rf
	cd $(DIST_PREFIX) && tar --exclude=bin --exclude=debian --exclude=.cvsignore -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign $(BASE)-$(VERSION).tar.gz


test:
	@perl -MTest::Harness -e '$$Test::Harness::verbose=0; runtests @ARGV;' tests/*.t


test-verbose:
	@perl -MTest::Harness -e '$$Test::Harness::verbose=1; runtests @ARGV;' tests/*.t


uninstall:
	rm -f ${prefix}/usr/bin/xen-create-image
	rm -f ${prefix}/usr/bin/xen-delete-image
	rm -f ${prefix}/usr/bin/xen-duplicate-image
	rm -f ${prefix}/usr/bin/xen-list-images
	rm -f ${prefix}/usr/bin/xen-update-image
	rm -f ${prefix}/etc/xen-tools/xen-tools.conf
	-rmdir ${prefix}/etc/xen-tools/xen-create-image.d/
	-rmdir ${prefix}/etc/xen-tools/
	-rm -f ${prefix}/etc/bash_completion.d/xen-tools
	-rm -f ${prefix}/etc/bash_completion.d/xm
	rm -f ${prefix}/usr/share/man/man8/xen-create-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-delete-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-duplicate-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-list-images.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-update-image.8.gz


update: 
	cvs -z3 update -A -d 2>/dev/null


update-version:
	perl -pi.bak -e "s/RELEASE = '[0-9]\.[0-9]';/RELEASE = '${VERSION}';/g" xen-*
