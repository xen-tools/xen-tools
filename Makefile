#
#  Utility makefile for people working with xen-tools.
#
#  The targets are intended to be useful for people who are using
# the source repository - but it also contains other useful targets.
#
# Steve
# --
# http://www.steve.org.uk/
#

#
#  Only used to build distribution tarballs.
#
TMP        ?= /tmp
DIST_PREFIX = ${TMP}
VERSION     = 4.4~dev
DEBVERSION  = $(shell echo $(VERSION)|sed 's/\(rc\|pre\|beta\|alpha\)/~\1/')
BASE        = xen-tools
VCS         = git

#
#  Installation prefix, useful for the Debian package.
#
prefix=


nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean         = Remove bogus files."
	@echo " commit        = Commit changes, after running check."
	@echo " diff          = See local changes."
	@echo " install       = Install the software"
	@echo " manpages      = Make manpages beneath man/"
	@echo " release       = Make a release tarball"
	@echo " uninstall     = Remove the software"
	@echo " update        = Update from the source repository."
	@echo " "


#
#  Extract the revision history and make a ChangeLog file
# with those details.
#
changelog:
	$(VCS) log -v > ChangeLog


#
#  Delete all temporary files, recursively.
#
clean:
	@find . \
		-path ./.git -prune -o \
		\( \
			-name '*~' -o \
			-name '.#*' -o \
			-name '*.bak' -o \
			-name '*.tmp' -o \
			-name 'tags' -o \
			-name '*.8.gz' -o \
			-name '*.tdy' \
		\) -exec rm "{}" +
	@if [ -d man ]; then rm -rf man ; fi
	@if [ -e build-stamp ]; then rm -f build-stamp ; fi
	@if [ -e configure-stamp ]; then rm -f configure-stamp ; fi
	@if [ -d debian/xen-tools ]; then rm -rf ./debian/xen-tools; fi
	@if [ -e $(BASE)-$(VERSION).tar.gz ]; then rm $(BASE)-$(VERSION).tar.gz ; fi
	@if [ -e $(BASE)-$(VERSION).tar.gz.asc ]; then rm $(BASE)-$(VERSION).tar.gz.asc ; fi
	cd t; $(MAKE) clean


#
#  If the testsuite runs correctly then commit any pending changes.
#
commit: test
	$(VCS) commit


#
#  Show what has been changed in the local copy vs. the remote repository.
#
diff:
	$(VCS) diff 2>/dev/null


#
#  Fix hooks and configuration files permissions
#
fixup-perms:
	for i in hooks/*/*-*; do chmod 755 $$i; done
	chmod 755 hooks/common.sh
	chmod 644 etc/xen-tools.conf
	chmod 644 etc/xm.tmpl
	chmod 644 etc/xm-nfs.tmpl
	chmod 644 misc/xen-tools misc/README

#
#  Install files to /etc/
#
install-etc:
	-mkdir -p ${prefix}/etc/xen-tools
	-if [ -d ${prefix}/etc/xen-tools/hook.d ]; then mv ${prefix}/etc/xen-tools/hook.d/  ${prefix}/etc/xen-tools/hook.d.obsolete ; fi
	-mkdir -p ${prefix}/etc/xen-tools/skel/
	-mkdir -p ${prefix}/etc/xen-tools/role.d/
	-mkdir -p ${prefix}/etc/xen-tools/partitions.d/
	cp etc/xen-tools.conf ${prefix}/etc/xen-tools/
	cp etc/xm.tmpl        ${prefix}/etc/xen-tools/
	cp etc/xm-nfs.tmpl    ${prefix}/etc/xen-tools/
	cp partitions/*-*     ${prefix}/etc/xen-tools/partitions.d/
	-mkdir -p             ${prefix}/etc/bash_completion.d
	cp misc/xen-tools     ${prefix}/etc/bash_completion.d/


#
#  Install binary files.
#
install-bin:
	mkdir -p ${prefix}/usr/bin
	cp bin/xen-create-image     ${prefix}/usr/bin
	cp bin/xen-create-nfs       ${prefix}/usr/bin
	cp bin/xt-customize-image   ${prefix}/usr/bin
	cp bin/xt-install-image     ${prefix}/usr/bin
	cp bin/xt-create-xen-config ${prefix}/usr/bin
	cp bin/xen-delete-image     ${prefix}/usr/bin
	cp bin/xen-list-images      ${prefix}/usr/bin
	cp bin/xen-update-image     ${prefix}/usr/bin
	cp bin/xt-guess-suite-and-mirror ${prefix}/usr/bin
	chmod 755 ${prefix}/usr/bin/xen-create-image
	chmod 755 ${prefix}/usr/bin/xen-create-nfs
	chmod 755 ${prefix}/usr/bin/xt-customize-image
	chmod 755 ${prefix}/usr/bin/xt-install-image
	chmod 755 ${prefix}/usr/bin/xt-create-xen-config
	chmod 755 ${prefix}/usr/bin/xen-delete-image
	chmod 755 ${prefix}/usr/bin/xen-list-images
	chmod 755 ${prefix}/usr/bin/xen-update-image
	chmod 755 ${prefix}/usr/bin/xt-guess-suite-and-mirror



#
#  Install hooks
#
install-hooks:
	for i in roles/* ; do if [ -f $$i ]; then cp $$i ${prefix}/etc/xen-tools/role.d; fi ; done
	for i in ${prefix}/usr/lib/xen-tools/*.d; do if [ -L "$$i" ]; then rm -vf "$$i"; fi; done
	mkdir -p ${prefix}/usr/lib/xen-tools/centos-4.d/
	mkdir -p ${prefix}/usr/lib/xen-tools/centos-5.d/
	mkdir -p ${prefix}/usr/lib/xen-tools/centos-6.d/
	mkdir -p ${prefix}/usr/lib/xen-tools/fedora-core-6.d/
	cp -R hooks/centos-4/*-* ${prefix}/usr/lib/xen-tools/centos-4.d
	cp -R hooks/centos-5/*-* ${prefix}/usr/lib/xen-tools/centos-5.d
	cp -R hooks/centos-6/*-* ${prefix}/usr/lib/xen-tools/centos-6.d
	cp -R hooks/fedora-core-6/*-* ${prefix}/usr/lib/xen-tools/fedora-core-6.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-4.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-5.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-7.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-8.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-9.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-10.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-11.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-12.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-13.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-14.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-15.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-16.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s fedora-core-6.d fedora-core-17.d
	mkdir -p ${prefix}/usr/lib/xen-tools/debian.d/
	cp -R hooks/debian/*-* ${prefix}/usr/lib/xen-tools/debian.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d sarge.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d etch.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d lenny.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d squeeze.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d wheezy.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d jessie.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d sid.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d testing.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s debian.d stable.d
	mkdir -p ${prefix}/usr/lib/xen-tools/gentoo.d/
	cp -R hooks/gentoo/*-* ${prefix}/usr/lib/xen-tools/gentoo.d
	mkdir -p ${prefix}/usr/lib/xen-tools/dapper.d/
	cp -R hooks/dapper/*-* ${prefix}/usr/lib/xen-tools/dapper.d/
	mkdir -p ${prefix}/usr/lib/xen-tools/edgy.d/
	cp -R hooks/edgy/*-* ${prefix}/usr/lib/xen-tools/edgy.d/
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s edgy.d feisty.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s edgy.d gutsy.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s edgy.d hardy.d
	mkdir -p ${prefix}/usr/lib/xen-tools/intrepid.d/
	cp -R hooks/intrepid/*-* ${prefix}/usr/lib/xen-tools/intrepid.d/
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s intrepid.d jaunty.d
	mkdir -p ${prefix}/usr/lib/xen-tools/karmic.d/
	cp -R hooks/karmic/*-* ${prefix}/usr/lib/xen-tools/karmic.d/
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d lucid.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d maverick.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d natty.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d oneiric.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d precise.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d quantal.d
	-cd ${prefix}/usr/lib/xen-tools/ && ln -s karmic.d raring.d
	cp hooks/common.sh ${prefix}/usr/lib/xen-tools
	cp -r hooks/common ${prefix}/usr/lib/xen-tools


#
#  Install our library files
#
install-libraries:
	-mkdir -p ${prefix}/usr/share/perl5/Xen/Tools
	cp ./lib/Xen/*.pm ${prefix}/usr/share/perl5/Xen
	cp ./lib/Xen/Tools/*.pm ${prefix}/usr/share/perl5/Xen/Tools

#
#  Generate and install manpages.
#
install-manpages: manpages
	-mkdir -p ${prefix}/usr/share/man/man8/
	cp man/*.8.gz ${prefix}/usr/share/man/man8/


#
#  Install everything.
#
install: fixup-perms install-bin install-etc install-hooks install-libraries install-manpages


#
#  Build our manpages via the `pod2man` command.
#
manpages:
	-mkdir -p man
	cd bin; for i in *-*[!y]; do pod2man --release=${VERSION} --official --section=8 $$i ../man/$$i.8; done
	for i in man/*.8; do gzip --force -9 $$i; done


#
#  Make a new release tarball, and make a GPG signature.
#
release: tidy fixup-perms update-version update-modules clean changelog
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/debian
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/.git*
	cd $(DIST_PREFIX) && tar -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz ..
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign ../$(BASE)-$(VERSION).tar.gz

#
#  Make a new orig.tar.gz for the Debian package
#
orig-tar-gz: release
	cp -p ../$(BASE)-$(VERSION).tar.gz ../$(BASE)_$(DEBVERSION).orig.tar.gz
	cp -p ../$(BASE)-$(VERSION).tar.gz.asc ../$(BASE)_$(DEBVERSION).orig.tar.gz.asc


#
#  Run the test suite.
#
test: update-modules
	prove --shuffle t/


#
#  Run the test suite verbosely.
#
test-verbose:
	prove --shuffle --verbose t/



#
#  Run our main script(s) through perltidy
#
tidy:
	if [ -x /usr/bin/perltidy ]; then \
	for i in bin/*-*[^~]; do \
		echo "tidying $$i"; \
		perltidy  $$i \
	; done \
	; fi

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
	rm -f ${prefix}/usr/bin/xen-create-nfs
	rm -f ${prefix}/usr/bin/xt-guess-suite-and-mirror
	rm -f ${prefix}/etc/xen-tools/xen-tools.conf
	rm -f ${prefix}/etc/xen-tools/xm.tmpl
	-rm -rf ${prefix}/etc/xen-tools/skel
	-rmdir ${prefix}/etc/xen-tools/
	-rm -f ${prefix}/etc/bash_completion.d/xen-tools
	rm -rf ${prefix}/usr/lib/xen-tools
	rm -f ${prefix}/usr/share/man/man8/xen-create-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-delete-image.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-list-images.8.gz
	rm -f ${prefix}/usr/share/man/man8/xen-update-image.8.gz


#
#  Update the local copy from the remote repository.
#
#  NOTE: Removes empty local directories.
#
update:
	$(VCS) pull --update 2>/dev/null


#
#  Update the module test - this is designed to automatically write test
# cases to ensure that all required modules are available.
#
update-modules:
	@cd t && make modules


#
#  Update the release number of each script we have from the variable
# at the top of this file.  Steve-Specific?
#
update-version:
	perl -pi.bak -e "s/RELEASE = '[0-9]\.[0-9][^']*';/RELEASE = '${VERSION}';/g" bin/*-*[!~]
