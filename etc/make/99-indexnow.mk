# IndexNow

ifneq (,$(INDEXNOW_KEYFILE))

ifndef INDEXNOW_ENGINES
INDEXNOW_ENGINES = '*'
endif
ifndef INDEXNOW_PINGFILE
INDEXNOW_PINGFILE = $(ETCDIR)/indexnow.lastping
endif

$(DESTDIR)$(INDEXNOW_KEYFILE): | $(call dirname,$(DESTDIR)$(INDEXNOW_KEYFILE),/.)
	LC_ALL=C tr -cd 'a-f0-9' </dev/urandom | dd bs=1 count=64 2>/dev/null >$@

HTDOCS += $(DESTDIR)$(INDEXNOW_KEYFILE)


$(INDEXNOW_PINGFILE): $(addprefix $(DESTDIR)/,$(PAGES)) | $(DESTDIR)$(INDEXNOW_KEYFILE)
	$(ETCDIR)/indexnow.sh $(addprefix -e ,$(INDEXNOW_ENGINES)) -k $(INDEXNOW_KEYFILE) $(patsubst $(DESTDIR)%,$(SITE_URL)%,$?)
	date -u '+%Y-%m-%dT%H:%M:%SZ' >$@

endif

.PHONY: indexnow
indexnow: $(INDEXNOW_PINGFILE)
ifeq (,$(INDEXNOW_KEYFILE))
	$(error indexnow target not available because IndexNow has not been configured)
endif


# clean

ifneq (,$(INDEXNOW_PINGFILE))

indexnow-clean:
	$(RM) $(INDEXNOW_PINGFILE)

CLEAN_TARGETS += indexnow-clean

endif
