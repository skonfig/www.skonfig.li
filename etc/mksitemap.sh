#!/bin/sh
# https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap

# include canonical URLs only, thus a problem when using the htdocs directory for generation...

set -e

changefreq='daily'

: ${HTDOCS:=public}

test -d "${HTDOCS}" || {
	printf 'Could not find htdocs directory: %s\n' "${HTDOCS-}" >&2
	exit 1
}

scandir() {
	for p in *
	do
		if test -d "${p}"
		then
			# recurse
			(cd "${p}" && scandir "${1-}${1:+/}${p##*/}")
		else
			case ${p}
			in
				# FIXME: what when no links?
				(*.html|*.htm)
					# TODO: <lastmod />, <priority />
					printf '	<url><loc>%s</loc><changefreq>%s</changefreq></url>\n' \
						"${SITE_URL:?}${1-}/${p}" "${changefreq:-daily}"
					;;
			esac
		fi
	done
}

# output
printf '<?xml version="1.0" encoding="UTF-8"?>\n'
printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">\n'
(cd "${HTDOCS}" && scandir)
printf '</urlset>\n'
