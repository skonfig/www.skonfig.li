# pages

define PAGE_VARIANTS
$(addprefix $(1).,$(LANGS))
endef

ALL_PAGES = $(foreach p,$(addprefix $(DESTDIR)/,$(PAGES)),$(p) $(call PAGE_VARIANTS,$(p)))
PAGES_DIRS = $(filter-out $(DESTDIR)/. $(ALL_DIRS),$(call uniq,$(call dirname,$(ALL_PAGES),/.)))

$(DESTDIR)/%.html: $(call PAGE_VARIANTS,$(DESTDIR)/%.html)
ifneq (,$(LINK_LANG))
	$(if $(if $(wildcard $@),$(filter-out $(@F).$(LINK_LANG),$(notdir $(realpath $@))),1),ln -f -s $(@F).$(LINK_LANG) $@)
endif


HTDOCS += $(PAGES_DIRS)
HTDOCS += $(ALL_PAGES)
