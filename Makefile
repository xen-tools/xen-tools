#
#  Utility makefile for people working with xen-tools, this contains
# a lot of targets useful for people working on the code from the 
# CVS repository - but it also contains other useful targets.
#
# Steve
# --
# http://www.steve.org.uk/
#
# $Id: Makefile,v 1.81 2006-09-22 17:13:36 steve Exp $


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = /tmp
VERSION     = 2.6
BASE        = xen-tools


#
#  Installation prefix, useful for the Debian package.
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
	@echo " release       = Make a release tarball"
	@echo " uninstall     = Remove the software"
	@echo " update        = Update from the CVS repository."
	@echo " "


#
#  Extract the CVS revision history and make a ChangeLog file
# with those details.
#
changelog:
	-if [ -x /usr/bin/cvs2cl ] ; then cvs2cl; fi
	-rm ChangeLog.bak


#
#  Delete all temporary files, recursively.
#
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


#
#  If the testsuite runs correctly then commit any pending changes.
#
commit: test
	cvs -z3 commit


#
#  Show what has been changed in the local copy vs. the CVS repository.
#
diff:
	cvs diff --unified 2>/dev/null


#
#  Install files to /etc/
#
install-etc:
	-mkdir -p ${prefix}/etc/xen-tools
	-if [ -d ${prefix}/etc/xen-tools/hook.d ]; then mv ${prefix}/etc/xen-tools/hook.d/  ${prefix}/etc/xen-tools/hook.d.obsolete ; fi
	-mkdir -p ${prefix}/etc/xen-tools/skel/
	-mkdir -p ${prefix}/etc/xen-tools/role.d/
	cp etc/xen-tools.conf ${prefix}/etc/xen-tools/
	cp etc/xm.tmpl        ${prefix}/etc/xen-tools/
	-mkdir -p             ${prefix}/etc/bash_completion.d
	cp misc/xen-tools     ${prefix}/etc/bash_completion.d/
	cp misc/xm            ${prefix}/etc/bash_completion.d/


#
#  Install binary files.
#
install-bin:
	mkdir -p ${prefix}/usr/bin
	cp bin/xen-create-image     ${prefix}/usr/bin
	cp bin/xt-customize-image   ${prefix}/usr/bin
	cp bin/xt-install-image     ${prefix}/usr/bin
	cp bin/xt-create-xen-config ${prefix}/usr/bin
	cp bin/xen-delete-image     ${prefix}/usr/bin
	cp bin/xen-list-images      ${prefix}/usr/bin
	cp bin/xen-update-image     ${prefix}/usr/bin
	chmod 755 ${prefix}/usr/bin/xen-create-image
	chmod 755 ${prefix}/usr/bin/xt-customize-image
	chmod 755 ${prefix}/usr/bin/xt-install-image
	chmod 755 ${prefix}/usr/bin/xt-create-xen-config
	chmod 755 ${prefix}/usr/bin/xen-delete-image
	chmod 755 ${prefix}/usr/bin/xen-list-images
	chmod 755 ${prefix}/usr/bin/xen-update-image


#
#  Install hooks
#
install-hooks:
	for i in roles/* ; do if [ -f $$i ]; then cp $$i ${prefix}/etc/xen-tools/role.d; fi ; done
	mkdir -p ${prefix}/usr/lib/xen-tools/centos4.d/
	cp -R hooks/centos4/*-* ${prefix}/usr/lib/xen-tools/centos4.d
	mkdir -p ${prefix}/usr/lib/xen-tools/debian.d/
	cp -R hooks/debian/*-* ${prefix}/usr/lib/xen-tools/debian.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d sarge.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d etch.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d sid.d
	mkdir -p ${prefix}/usr/lib/xen-tools/fedora.d/
	cp -R hooks/fedora/*-* ${prefix}/usr/lib/xen-tools/fedora.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora.d stentz.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s ubuntu.d dapper.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s ubuntu.d edgy.d
	mkdir -p ${prefix}/usr/lib/xen-tools/gentoo.d/
	cp -R hooks/gentoo/*-* ${prefix}/usr/lib/xen-tools/gentoo.d
	mkdir -p ${prefix}/usr/lib/xen-tools/ubuntu.d/
	cp -R hooks/ubuntu/*-* ${prefix}/usr/lib/xen-tools/ubuntu.d
	cp hooks/common.sh ${prefix}/usr/lib/xen-tools
	@-find ${prefix}/usr/lib/xen-tools -name 'CVS' -exec rm -rf \{\} \;


#
#  Generate and install manpages.
#
install-manpages: manpages
	-mkdir -p ${prefix}/usr/share/man/man8/
	cp man/*.8.gz ${prefix}/usr/share/man/man8/


#
#  Install everything.
#
install: install-bin install-etc install-hooks install-manpages


#
#  Build our manpages via the `pod2man` command.
#
manpages:
	cd bin; for i in *-*; do pod2man --release=${VERSION} --official --section=8 $$i ../man/$$i.8; done
	for i in man/*.8; do gzip --force -9 $$i; done


#
#  Make a new release tarball, and make a GPG signature.
#
release: test update-version update-modules clean changelog
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name "CVS" -print | xargs rm -rf
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/debian
	cd $(DIST_PREFIX) && tar --exclude=.cvsignore -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign $(BASE)-$(VERSION).tar.gz


#
#  Run the test suite.
#
test:
	prove --shuffle tests/


#
#  Run the test suite verbosely.
#
test-verbose:
	prove --shuffle --verbose tests/



#
#  Uninstall the software, completely.
#
uninstall:
	rm -f ${prefix}/usr/bin/xen-create-image
	rm -f ${prefix}/usr/bin/xen-delete-image
	rm -f ${prefix}/usr/bin/xen-list-images
	rm -f ${prefix}/usr/bin/xen-update-image
	rm -f ${prefix}/usr/bin/xt-customize-image
	rm -f ${prefix}/usr/bin/xt-install-image
	rm -f ${prefix}/usr/bin/xt-create-xen-config
	rm -f ${prefix}/etc/xen-tools/xen-tools.conf
	rm -f ${prefix}/etc/xen-tools/xm.tmpl
	-rm -rf ${prefix}/etc/xen-tools/skel
	-rmdir ${prefix}/etc/xen-tools/
	-rm -f ${prefix}/etc/bash_completion.d/xen-tools
	-rm -f ${prefix}/etc/bash_completion.d/xm
	rm -rf ${prefix}/usr/lib/xen-tools
	rm -f ${prefix}/usr/share/man/man8/xen-create-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-delete-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-list-images.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-update-image.8.gz


#
#  Update the local copy from the CVS repository.
#
#  NOTE: Removes empty local directories.
#
update: 
	cvs -z3 update -A -P -d 2>/dev/null


#
#  Update the module test - this is designed to automatically write test
# cases to ensure that all required modules are available.
#
update-modules:
	cd tests && make modules


#
#  Update the release number of each script we have from the variable
# at the top of this file.  Steve-Specific?
#
update-version:
	perl -pi.bak -e "s/RELEASE = '[0-9]\.[0-9]';/RELEASE = '${VERSION}';/g" bin/*-*
