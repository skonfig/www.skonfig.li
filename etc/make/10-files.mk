# files
ALL_FILES = $(addprefix $(DESTDIR)/,$(FILES))
# and the directories for files
FILES_DIRS = $(filter-out $(DESTDIR)/. $(ALL_DIRS),$(call uniq,$(call dirname,$(ALL_FILES),/.)))

$(DESTDIR)/%: % | $(DESTDIR)/. $(ALL_DIRS) $(FILES_DIRS)
	cp $< $@

$(DESTDIR)/%: $(ASSETSDIR)/% | $(DESTDIR)/. $(ALL_DIRS) $(FILES_DIRS)
	cp $< $@


HTDOCS += $(FILES_DIRS)
HTDOCS += $(ALL_FILES)
