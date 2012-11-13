VERSION=0.7
INSTALL=install -p
SED=sed
LIBEXECDIR=/usr/libexec
DRACUTMODDIR=/usr/lib/dracut/modules.d

dracut_DIR = $(DRACUTMODDIR)/90system-upgrade
dracut_SCRIPTS = 90system-upgrade/module-setup.sh \
	         90system-upgrade/initrd-switch-root.sh \
		 90system-upgrade/upgrade-init.sh \
		 90system-upgrade/upgrade-pre-pivot.sh \
		 90system-upgrade/upgrade-pre.sh \
		 90system-upgrade/upgrade.sh \
		 90system-upgrade/upgrade-post.sh
dracut_DATA = 90system-upgrade/README.txt \
	      90system-upgrade/dracut-pre-pivot.service \
	      90system-upgrade/upgrade-setup-root.target \
	      90system-upgrade/upgrade-setup-root.service \
	      90system-upgrade/upgrade.target \
	      90system-upgrade/upgrade-pre.service \
	      90system-upgrade/upgrade.service \
	      90system-upgrade/upgrade-post.service \
	      90system-upgrade/upgrade-debug-shell.service

fedora_DIR = $(DRACUTMODDIR)/85system-upgrade-fedora
fedora_BIN = system-upgrade-fedora
fedora_SCRIPTS = 85system-upgrade-fedora/module-setup.sh \
		 85system-upgrade-fedora/do-upgrade.sh \
		 85system-upgrade-fedora/save-journal.sh

THEMENAME=fedup
THEMESDIR=$(shell pkg-config ply-splash-graphics --variable=themesdir)
plymouth_DIR = $(THEMESDIR)$(THEMENAME)
plymouth_DATA = plymouth/*.png
plymouth_THEME = plymouth/fedup.plymouth

GENFILES = 85system-upgrade-fedora/module-setup.sh

SCRIPTS = $(dracut_SCRIPTS) $(fedora_SCRIPTS)
DATA = $(dracut_DATA) $(plymouth_DATA) $(plymouth_THEME)
BIN = $(fedora_BIN)

all: $(SCRIPTS) $(DATA) $(BIN)

PACKAGES=glib-2.0 rpm
# TODO: use ply-boot-client
#PACKAGES+=ply-boot-client
#CFLAGS+=-DUSE_PLYMOUTH_LIBS

$(BIN): %: %.c
	$(CC) $(shell pkg-config $(PACKAGES) --cflags --libs) $(CFLAGS) $< -o $@

$(GENFILES): %: %.in
	$(SED) 's,@LIBEXECDIR@,$(LIBEXECDIR),g' $< > $@

clean:
	rm -f $(BIN) $(GENFILES) $(ARCHIVE)

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

.PHONY: all clean archive install
