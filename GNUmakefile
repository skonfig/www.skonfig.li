MAKEFILE := $(lastword $(MAKEFILE_LIST))

SITEMAP = sitemap.xml

# website content lists
LANGS = en

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

IMAGES = \
	black.gif \
	skonfig_logo.png

PAGES = \
	index.html \
	install.html \
	docs.html \
	docs/what-is-configuration-management.html \
	docs/getting-started.html \
	docs/my-first-type.html \
	docs/supported-os.html \
	reference.html \
	reference/base-explorers.html \
	reference/environment.html \
	reference/structure.html \
	source.html

FILES = \
	.htaccess \
	robots.txt \
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

$(DESTDIR)/.htaccess: htaccess.in $(CONFIG_MK) | $(DESTDIR)/.
	$(MK_YGPP)

$(DESTDIR)/img/black.gif: | $(DESTDIR)/img/.
	$(CONVERT) -size 1x1 xc:none -background '#000000' -flatten -depth 8 $@


ifneq (,$(call bool,$(BLOCK_AI_ROBOTS)))
# NOTE: robots.txt needs ai.robots.txt, because it includes it
$(DESTDIR)/robots.txt: ai.robots.txt
# NOTE: .htaccess needs ai.robots.htaccess, because it includes it
$(DESTDIR)/.htaccess: ai.robots.htaccess
endif

ifdef GEN_SITEMAP
# NOTE: robots.txt needs sitemap, because it links to it
$(DESTDIR)/robots.txt: | $(DESTDIR)/$(SITEMAP)
endif
