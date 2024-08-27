# fonts

ifndef FONTFORGE
ifneq (,$(call pathsearch,fontforge))
FONTFORGE = fontforge
endif
endif

ifndef MKEOT
ifneq (,$(call pathsearch,mkeot))
MKEOT = mkeot
endif
endif

ifndef PYFTSUBSET
ifneq (,$(call pathsearch,pyftsubset))
PYFTSUBSET = pyftsubset
else
ifneq (,$(call pathsearch,fonttools))
PYFTSUBSET = fonttools subset
endif
endif
endif


FONTS_DIRS = $(addprefix $(DESTDIR)/fonts/,$(call uniq,$(call dirname,$(FONTS),/.)))

# fonts directory requirements
$(FONTS_DIRS): | $(DESTDIR)/fonts/.

.NOTINTERMEDIATE: $(foreach f,$(FONTS_FORMATS),$(DESTDIR)/fonts/%.$(f))
.NOTINTERMEDIATE: $(foreach s,$(FONTS_SUBSETS),$(foreach f,$(FONTS_FORMATS),$(DESTDIR)/fonts/%_$(s).$(f)))


define FONTS_GEN_FONTFACE_CSS
FONTS_DIR=/fonts \
FONT_PREFIX=$* \
FONT_FAMILY=$(*D) \
FONT_NAME=$(*F) \
FONT_STYLE=$(patsubst $(*D)-%,%,$(*F)) \
FORMATS='$(FONTS_FORMATS)' \
$(if $(1),FONT_SUBSET=$(1)) \
$(if $(1),RANGE='$(shell sh $(ETCDIR)/font-subset.sh $(1))') \
$(YGPP) $(ETCDIR)/fontface.tmpl.in
endef

$(DESTDIR)/fonts/%.css: $(foreach s,$(FONTS_SUBSETS),$(foreach f,$(FONTS_FORMATS),$(DESTDIR)/fonts/%_$(s).$(f))) | $(FONTS_DIRS)
	{ $(foreach s,$(FONTS_SUBSETS),$(call FONTS_GEN_FONTFACE_CSS,$(s));) } >$@


################################################################################
# EOT conversion

ifndef MKEOT
ifneq (,$(filter eot,$(FONTS_FORMATS)))
	$(warning mkeot is not installed, font conversion to EOT not available.)
endif
endif

ifdef MKEOT
ifneq (,$(SITE_DOMAIN))
define EOT_CONVERT
	$(MKEOT) $(1) http://$(SITE_DOMAIN) https://$(SITE_DOMAIN) >$(2)
endef
else
define EOT_CONVERT
	$(warn SITE_DOMAIN is not set. The generated EOT fonts may not work under some circumstances.)
	$(MKEOT) $(1) >$(2)
endef
endif
else
define EOT_CONVERT
	$(error Cannot generate EOT font, mkeot command is not available)
endef
endif

$(DESTDIR)/fonts/%.eot: $(ASSETSDIR)/fonts/%.otf $(MAKEFILE) | $(FONTS_DIRS)
	$(call EOT_CONVERT,$<,$@)
$(DESTDIR)/fonts/%.eot: $(ASSETSDIR)/fonts/%.ttf $(MAKEFILE) | $(FONTS_DIRS)
	$(call EOT_CONVERT,$<,$@)

# subsets
$(DESTDIR)/fonts/%.eot: $(DESTDIR)/fonts/%.ttf $(MAKEFILE) | $(FONTS_DIRS)
	$(call EOT_CONVERT,$<,$@)


################################################################################
# SVG fonts

ifndef FONTFORGE
ifneq (,$(filter svg,$(FONTS_FORMATS)))
	$(warning FontForge is not installed, font conversion to SVG not available.)
endif
endif

ifdef FONTFORGE
define SVG_FONT_CONVERT
	$(FONTFORGE) -quiet -lang=ff -c 'Open($$1);Generate($$2)' $(1) $(2)
endef
else
define SVG_FONT_CONVERT
	$(error Cannot generate SVG font, FontForge is not installed)
endef
endif

$(DESTDIR)/fonts/%.svg: $(ASSETSDIR)/fonts/%.ttf | $(FONTS_DIRS)
	$(call SVG_FONT_CONVERT,$<,$@)

# subsets
$(DESTDIR)/fonts/%.svg: $(DESTDIR)/fonts/%.ttf | $(FONTS_DIRS)
	$(call SVG_FONT_CONVERT,$<,$@)


################################################################################
# fonts (subsetting)

FONTS_ALL_SUBSETS = latin latin-ext cyrillic cyrillic-ext greek greek-ext vietnamese

PYFTSUBSET_OPTS_ALL = --name-languages='*' --layout-features='*'
PYFTSUBSET_OPTS_woff2 = $(PYFTSUBSET_OPTS_ALL) --flavor=woff2
PYFTSUBSET_OPTS_woff = $(PYFTSUBSET_OPTS_ALL) --flavor=woff
PYFTSUBSET_OPTS_ttf = $(PYFTSUBSET_OPTS_ALL) --legacy-kern --name-legacy --recommended-glyphs
PYFTSUBSET_OPTS_otf = $(PYFTSUBSET_OPTS_ALL) --legacy-kern --name-legacy --recommended-glyphs

ifdef PYFTSUBSET
define FONT_MK_SUBSET
	$(PYFTSUBSET) $(2) $(4) --unicodes='$(shell sh $(ETCDIR)/font-subset.sh $(1))' --output-file=$(3)
endef
else
define FONT_MK_SUBSET
	$(error Cannot generate font subset, Python fonttools is not available)
endef
endif

$(foreach f,ttf otf woff woff2,$(foreach subset,$(FONTS_ALL_SUBSETS),$(eval $$(DESTDIR)/fonts/%_$(subset).$(f): $$(ASSETSDIR)/fonts/%.$(f) | $$(FONTS_DIRS) ; $$(call FONT_MK_SUBSET,$(subset),$$<,$$@,$$(PYFTSUBSET_OPTS_$(f))))))


################################################################################

ALL_FONTS = $(foreach font,$(FONTS),$(foreach s,$(FONTS_SUBSETS),$(foreach f,$(FONTS_FORMATS),$(DESTDIR)/fonts/$(font)_$(s).$(f))))

DIRS += fonts
HTDOCS += $(ALL_FONTS)
