# ygpp generated pages/files

# call MK_YGPP,lang-suffix
define MK_YGPP
$(if $(1),PAGE_LANG=$(call shquot,$(1)),) \
FILEBASE=$(call shquot,$(patsubst %.$(1),%,$(notdir $@))) \
URL=$(call shquot,$(patsubst $(DESTDIR)%,%,$@)) \
URL_CANONICAL=$(call shquot,$(patsubst %.$(1),%,$(patsubst $(DESTDIR)%,%,$@))) \
PAGE_BASE=$(call shquot,$(patsubst %/,../,$(patsubst $(DESTDIR)/%,%,$(dir $@)))) \
$(YGPP) -- -D $<.d $< >$@
endef

$(DESTDIR)/%: %.in $(CONFIG_MK) | $(ALL_DIRS)
	$(call MK_YGPP)

# for all pages, use {page}.html.{lang}.in if it exists, or a
# generic {page}.html.in otherwise
$(foreach p,$(PAGES),$(foreach l,$(LANGS),$(eval $(DESTDIR)/$(p).$(l): $(or $(wildcard $(p).$(l).in),$(p).in) $(CONFIG_MK) | $(call dirname,$(DESTDIR)/$(p),/.) ; $$(call MK_YGPP,$(l)))))


# ygpp dependencies
# NOTE: touch is for .d files to be read correctly

%.in:
	@touch $@

YGPP_DEP_FILES := $(shell find . -name '*.in.d' -print)

-include $(YGPP_DEP_FILES)


# clean

ygpp-clean:
# FIXME: this does not detect .d files for files generated from a .in of a different name (htaccess.in)
	$(if $(YGPP_DEP_FILES),$(RM) $(YGPP_DEP_FILES))
#	$(let l,$(wildcard $(addsuffix .in.d,$(foreach p,$(PAGES),$(p) $(call PAGE_VARIANTS,$(p))) $(FILES))),$(if $(l),$(RM) $(l)))
#	-$(RM) $(foreach p,$(PAGES),$(p).in.d $(foreach l,$(LANGS),$(wildcard $(p).$(l).in.d)))
#	-$(RM) $(foreach f,$(FILES),$(f).in.d)

CLEAN_TARGETS += ygpp-clean
