# rules for $(DESTDIR) sub directories

ALL_DIRS = $(patsubst %,$(DESTDIR)/%/.,$(DIRS))

$(DESTDIR)/.:
	mkdir $(DESTDIR)

$(DESTDIR)/%/.:
	mkdir $(patsubst %/.,%,$@)

# directory dependencies
$(foreach d,$(addprefix $(DESTDIR)/,$(DIRS)),$(eval $(d)/.: | $(call dirname,$(d),/.)))

HTDOCS += $(DESTDIR)/. $(ALL_DIRS)
