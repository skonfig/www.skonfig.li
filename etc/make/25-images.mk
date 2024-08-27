# images

ifndef GM_CONVERT
ifneq (,$(call pathsearch,gm))
GM_CONVERT = gm convert
endif
endif
ifndef IM_CONVERT
ifneq (,$(call pathsearch,magick))
IM_CONVERT = magick
else
ifneq (,$(call pathsearch,convert))
IM_CONVERT = convert
endif
endif
endif

ifndef CONVERT
CONVERT = $(if $(GM_CONVERT),$(GM_CONVERT),$(IM_CONVERT))
endif

ifndef INKSCAPE
ifneq (,$(call pathsearch,inkscape))
INKSCAPE = inkscape
endif
endif

ifndef JPEGTRAN
ifneq (,$(call pathsearch,jpegtran))
JPEGTRAN = jpegtran
endif
endif

ifndef CJXL
ifneq (,$(call pathsearch,cjxl))
CJXL = cjxl
endif
endif

ifndef CWEBP
ifneq (,$(call pathsearch,cwebp))
CWEBP = cwebp
endif
endif


JPEG_QUALITY ?= 90
JXL_QUALITY ?= $(JPEG_QUALITY)
WEBP_QUALITY ?= $(JPEG_QUALITY)
FAVICON_ICO_SIZES ?= 64,32,16

# TODO: make extendable
JPEGTRANFLAGS = -progressive -optimize -copy icc
CJXLFLAGS = -p --lossless_jpeg=0 -q $(JXL_QUALITY) -e 9 --brotli_effort=11
CWEBPFLAGS = -quiet -mt -preset photo -noalpha -metadata icc -m 6 -q $(WEBP_QUALITY)


$(DESTDIR)/favicon.ico: $(ASSETSDIR)/img/favicon.svg | $(DESTDIR)/.
ifdef IM_CONVERT
# "enforce" ImageMagick because GraphicsMagick does not support ICO
	$(IM_CONVERT) -density 300 -define icon:auto-resize=$(FAVICON_ICO_SIZES) -background none $< $@
else
	$(error Cannot generate favicon.ico, ImageMagick is not available)
endif


$(DESTDIR)/touch-icon.%.png: $(ASSETSDIR)/img/favicon.svg | $(DESTDIR)/.
ifdef INKSCAPE
	$(INKSCAPE) -o $@ -w $* -h $* $<
else
	$(error Rendering SVG not possible. Inkscape is not available)
endif

$(DESTDIR)/apple-touch-icon.%.png: $(ASSETSDIR)/img/favicon.svg | $(DESTDIR)/.
ifdef INKSCAPE
	$(INKSCAPE) -o $@ -w $* -h $* $<
else
	$(error Rendering SVG not possible. Inkscape is not available)
endif


# converted images

$(DESTDIR)/img/%.jxl: $(ASSETSDIR)/img/%.jpg | $(DESTDIR)/img/. $(ALL_DIRS)
	$(CJXL) $< $@ $(CJXLFLAGS)

$(DESTDIR)/img/%.webp: $(ASSETSDIR)/img/%.jpg | $(DESTDIR)/img/. $(ALL_DIRS)
	$(CWEBP) $(CWEBPFLAGS) $< -o $@

$(DESTDIR)/img/%.gif: $(ASSETSDIR)/img/%.svg | $(DESTDIR)/img/. $(ALL_DIRS)
	$(CONVERT) $< $@


ALL_IMAGES = $(addprefix $(DESTDIR)/img/,$(IMAGES))

DIRS += img
HTDOCS += $(ALL_IMAGES)
