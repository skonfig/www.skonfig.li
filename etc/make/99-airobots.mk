ifndef BLOCK_AI_ROBOTS
# default: do not block AI robots. Users can enable it by changing the variable
#          in config.mk.
BLOCK_AI_ROBOTS = false
endif
# NOTE: export so that the variable can be used in YGPP templates, e.g. in
#       robots.txt or .htaccess
export BLOCK_AI_ROBOTS

ifndef AI_ROBOTS_REFRESH_DAYS
AI_ROBOTS_REFRESH_DAYS = 7
endif


# ai.robots.txt

AI_ROBOTS_TXT_URL = https://github.com/ai-robots-txt/ai.robots.txt/raw/refs/heads/main/robots.txt

ifneq (,$(shell find ai.robots.txt -mtime +$(AI_ROBOTS_REFRESH_DAYS) 2>/dev/null))
.PHONY: ai.robots.txt
ai.robots.txt::
	$(info $@ is older than $(AI_ROBOTS_REFRESH_DAYS) days. Updating it...)
endif

# NOTE: the MAKEFILE prerequisite is important. Without it ai.robots.txt will
#       be re-generated every time due to :: rules
# (cf. https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html)
ai.robots.txt:: $(lastword $(MAKEFILE_LIST))
	printf '%s\n' >$@ \
		'# Please so not scan this page for contents to train AIs on.' \
		'# Thank you.' \
		''
	$(call download_stdout,$(AI_ROBOTS_TXT_URL)) >>$@


# ai.robots.htaccess

AI_ROBOTS_HTACCESS_URL = https://github.com/ai-robots-txt/ai.robots.txt/raw/refs/heads/main/.htaccess

ifneq (,$(shell find ai.robots.htaccess -mtime +$(AI_ROBOTS_REFRESH_DAYS) 2>/dev/null))
.PHONY: ai.robots.htaccess
ai.robots.htaccess::
	$(info $@ is older than $(AI_ROBOTS_REFRESH_DAYS) days. Updating it...)
endif

# NOTE: the MAKEFILE prerequisite is important. Without it ai.robots.txt will
#       be re-generated every time due to :: rules
# (cf. https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html)
ai.robots.htaccess:: $(lastword $(MAKEFILE_LIST))
	printf '%s\n' >$@ \
		'<IfModule mod_rewrite.c>' \
		'	# block AI training robots' \
		''
	$(call download_stdout,$(AI_ROBOTS_HTACCESS_URL)) \
	| sed -e 's/^/	/' -e 's/%/\\&/g' >>$@
	printf '%s\n' >>$@ '</IfModule>'


# clean

airobots-clean:
	-$(RM) ai.robots.txt ai.robots.htaccess

CLEAN_TARGETS += airobots-clean
