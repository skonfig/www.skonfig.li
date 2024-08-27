MAKEFILE := $(lastword $(MAKEFILE_LIST))

SITEMAP = sitemap.xml

# website content lists
LANGS = de en

DIRS = \
	.well-known

FONTS = 

# NOTE: enabling more than one subset may cause browser compatibility issues
FONTS_SUBSETS = latin

# NOTE: order currently matters because it defines the URL in the CSS file
FONTS_FORMATS = \
	eot \
	woff2 \
	woff \
	ttf \
	svg

IMAGES = 

PAGES = \
	index.html

FILES = \
	$(SITEMAP)

.DEFAULT: default
.PHONY: default all
default: htdocs
all: htdocs dist.tar.gz


include etc/homepage.mk

.PHONY: open view
open view: htdocs
ifneq (,$(BROWSER))
# user-specified browser
	$(BROWSER) $(call shquot,$(abspath public/index.html))
else
ifneq (,$(pathsearch x-www-browser))
# Debian
	x-www-browser $(call shquot,$(abspath public/index.html))
else
# fall-back to OS open command
ifneq (,$(pathsearch open))
# Mac (open)
	open $(call shquot,$(abspath public/index.html))
else
# *nix (xdg-open)
	xdg-open $(call shquot,$(abspath public/index.html))
endif
endif
endif


# custom files

$(DESTDIR)/.htaccess: htaccess.in | $(DESTDIR)/.
	$(MK_YGPP)

# custom dependencies
$(DESTDIR)/css/style.css: $(foreach font,$(FONTS),$(DESTDIR)/fonts/$(font).css)

ifdef GEN_SITEMAP
# NOTE: robots.txt needs sitemap, because it links to it
$(DESTDIR)/robots.txt: $(CONFIG_MK) $(MAKEFILE) | $(DESTDIR)/$(SITEMAP)
endif

