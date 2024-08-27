# sitemap.xml

ifneq (,$(and $(SITEMAP),$(filter $(SITEMAP),$(FILES))))
GEN_SITEMAP = 1
else
override undefine GEN_SITEMAP
endif

ifdef GEN_SITEMAP

export SITEMAP

$(DESTDIR)/$(SITEMAP): $(ALL_PAGES) $(ETCDIR)/mksitemap.sh | $(ALL_DIRS)
ifeq (,$(SITE_URL))
	$(error SITE_URL is not defined)
endif
	HTDOCS=$(DESTDIR) $(ETCDIR)/mksitemap.sh >$@


HTDOCS += $(DESTDIR)/$(SITEMAP)

endif
