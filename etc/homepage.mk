# functions

# call bool,value
define bool
$(shell printf '\#ifbool B\n1\n\#endif\n' | B='$(1)' $(YGPP) -)
endef

# call dirname,path,suffix
define dirname
$(patsubst %/,%$(2),$(dir $(patsubst %/.,%,$(1))))
endef

# call pathsearch,command-name
define pathsearch
$(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH)))))
endef
#pathsearch = $(shell command -v $(1))

# call shquot,string
define shquot
'$(subst ','\'',$(1))'
endef

# call uniq,words
define uniq
$(if $(1),$(firstword $(1)) $(call uniq,$(filter-out $(firstword $(1)),$(1))))
endef


# variables

HOMEPAGE_BASE := $(call dirname,$(lastword $(MAKEFILE_LIST)))

ETCDIR = etc
ASSETSDIR = assets
DESTDIR = public

YGPP = $(ETCDIR)/ygpp

# config
DRAFT = false
GEN_SITEMAP = false
DEBUG = false

HTDOCS =

# load config.mk
ifneq (,$(wildcard config.mk))
CONFIG_MK = config.mk
-include $(CONFIG_MK)
endif

# exports

export DRAFT
export LANGS
export PUBLIC

ifdef SITE_DOMAIN
export SITE_DOMAIN

ifeq (,$(SITE_URL))
SITE_URL = http://$(SITE_DOMAIN)
export SITE_URL
endif

endif

ifndef LINK_LANG
ifneq (,$(LANGS))
LINK_LANG = $(firstword $(LANGS))
endif
endif


-include $(wildcard $(HOMEPAGE_BASE)/make/*.mk)


htdocs: $(HTDOCS)

dist.tar.gz: htdocs
	(cd $(DESTDIR) && tar czf $(abspath $@) .)

.PHONY: watch
watch: htdocs
	+@command -v fswatch >/dev/null || { \
		echo 'Missing fswatch, auto re-build is not supported without it.' >&2; \
		false; \
	}
	@while \
		echo 'Waiting for changes...' ; \
		fl=$$(fswatch -1 -e '#' -e '~$$' -e '/\.git$$' -e '/\.git/' -e '^$(DESTDIR)/' -m poll_monitor -0 --format='%p ' -r .); \
	do \
		echo $$fl; \
		$(MAKE) --no-print-directory htdocs; \
	done


.PHONY: clean
clean: $(CLEAN_TARGETS)
	$(RM) -R $(DESTDIR)
