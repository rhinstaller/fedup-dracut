VERSION=0.9.0
INSTALL=install -p
SED=sed
LIBEXECDIR=/usr/libexec
DRACUTMODDIR=/usr/lib/dracut/modules.d

dracut_DIR = $(DRACUTMODDIR)/90system-upgrade
dracut_SCRIPTS = 90system-upgrade/module-setup.sh \
		 90system-upgrade/upgrade-init.sh \
		 90system-upgrade/upgrade-pre-pivot.sh \
		 90system-upgrade/upgrade-pre.sh \
		 90system-upgrade/upgrade.sh \
		 90system-upgrade/upgrade-post.sh \
		 90system-upgrade/initrd-system-upgrade-generator
dracut_DATA = 90system-upgrade/README.txt \
	      90system-upgrade/upgrade.target \
	      90system-upgrade/upgrade-pre.service \
	      90system-upgrade/upgrade.service \
	      90system-upgrade/upgrade-post.service \
	      90system-upgrade/system-upgrade-shell.service

fedora_DIR = $(DRACUTMODDIR)/85system-upgrade-fedora
fedora_BIN = system-upgrade-fedora
fedora_SCRIPTS = 85system-upgrade-fedora/module-setup.sh \
		 85system-upgrade-fedora/keep-initramfs.sh \
		 85system-upgrade-fedora/do-upgrade.sh \
		 85system-upgrade-fedora/upgrade-cleanup.sh \
		 85system-upgrade-fedora/save-journal.sh

THEMENAME=fedup
THEMESDIR=$(shell pkg-config ply-splash-graphics --variable=themesdir)
plymouth_DIR = $(THEMESDIR)$(THEMENAME)
plymouth_DATA = plymouth/*.png
plymouth_THEME = plymouth/fedup.plymouth

GENFILES = 85system-upgrade-fedora/module-setup.sh fedup-dracut.spec

SCRIPTS = $(dracut_SCRIPTS) $(fedora_SCRIPTS)
DATA = $(dracut_DATA) $(plymouth_DATA) $(plymouth_THEME)
BIN = $(fedora_BIN)

all: $(SCRIPTS) $(DATA) $(BIN)

PACKAGES=glib-2.0 rpm ply-boot-client

$(BIN): %: %.c
	$(CC) $(shell pkg-config $(PACKAGES) --cflags --libs) $(CFLAGS) $< -o $@

$(GENFILES): %: %.in
	$(SED) -e 's,@LIBEXECDIR@,$(LIBEXECDIR),g' \
	       -e 's,@VERSION@,$(VERSION),g' \
	       $< > $@

clean:
	rm -f $(BIN) $(GENFILES) $(ARCHIVE) upgrade.img
	rm -rf rpm

install: $(BIN) $(SCRIPTS) $(DATA)
	$(INSTALL) -d $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) $(BIN) $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) -d $(DESTDIR)$(dracut_DIR)
	$(INSTALL) $(dracut_SCRIPTS) $(DESTDIR)$(dracut_DIR)
	$(INSTALL) -m644 $(dracut_DATA) $(DESTDIR)$(dracut_DIR)
	$(INSTALL) -d $(DESTDIR)$(fedora_DIR)
	$(INSTALL) $(fedora_SCRIPTS) $(DESTDIR)$(fedora_DIR)
	$(INSTALL) -d $(DESTDIR)$(plymouth_DIR)
	$(INSTALL) -m644 $(plymouth_DATA) $(DESTDIR)$(plymouth_DIR)
	$(INSTALL) -m644 $(plymouth_THEME) \
			 $(DESTDIR)$(plymouth_DIR)/$(THEMENAME).plymouth

ARCHIVE = fedup-dracut-$(VERSION).tar.xz
archive: $(ARCHIVE)
$(ARCHIVE):
	git archive --format=tar --prefix=fedup-dracut-$(VERSION)/ HEAD \
	  | xz -c > $@ || rm $@

rpm: $(ARCHIVE) fedup-dracut.spec
	mkdir -p rpm/build
	rpmbuild -ba fedup-dracut.spec \
		 --define '_specdir $(PWD)' \
		 --define '_sourcedir $(PWD)' \
		 --define '_specdir $(PWD)' \
		 --define '_srcrpmdir $(PWD)/rpm' \
		 --define '_rpmdir $(PWD)/rpm' \
		 --define '_builddir $(PWD)/rpm/build'

repo: makefeduprepo
	mkdir repo
	./makefeduprepo repo || rm -rf repo

upgrade.img:
	PLYMOUTH_THEME_NAME=$(THEMENAME) \
	dracut --conf /dev/null --confdir /var/empty --add "system-upgrade" \
		--no-hostonly --nolvmconf --nomdadmconf --force --verbose \
		upgrade.img



.PHONY: all clean archive install
