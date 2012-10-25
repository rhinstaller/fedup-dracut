VERSION=0.7
INSTALL=install -p -D
SED=sed
LIBEXECDIR=/usr/libexec
DRACUTMODDIR=/usr/lib/dracut/modules.d

SCRIPTS = 90system-upgrade/module-setup.sh \
	  90system-upgrade/upgrade-init.sh \
	  90system-upgrade/upgrade-pre-pivot.sh \
	  90system-upgrade/upgrade-pre.sh \
	  90system-upgrade/upgrade.sh \
	  90system-upgrade/upgrade-post.sh \
	  85system-upgrade-fedora/module-setup.sh \
	  85system-upgrade-fedora/keep-initramfs.sh \
	  85system-upgrade-fedora/do-upgrade.sh \
	  85system-upgrade-fedora/save-journal.sh

DATA = 90system-upgrade/README.txt \
       90system-upgrade/upgrade.target \
       90system-upgrade/upgrade-pre.service \
       90system-upgrade/upgrade.service \
       90system-upgrade/upgrade-post.service \
       90system-upgrade/upgrade-debug-shell.service

BIN = system-upgrade-fedora

GENFILES = 85system-upgrade-fedora/module-setup.sh

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
	$(INSTALL) $(BIN) $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) $(SCRIPTS) $(DESTDIR)$(DRACUTMODDIR)
	$(INSTALL) -m644 $(DATA) $(DESTDIR)$(DRACUTMODDIR)

ARCHIVE = fedup-dracut-$(VERSION).tar.xz
archive: $(ARCHIVE)
$(ARCHIVE):
	git archive --format=tar --prefix=fedup-dracut-$(VERSION)/ HEAD \
	  | xz -c > $@ || rm $@

.PHONY: all clean archive install
