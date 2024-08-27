#!/bin/sh
set -e

all_engines='indexnow bing naver seznam.cz yandex'

command -v curl >/dev/null 2>&1 || {
	echo 'curl: command not found' >&2
	exit 1
}

jsonquot() {
	# TODO: check RFC 8259 for more details
	sed \
		-e ':a' -e '$!N' -e '$!b a' \
		-e 's/\\/\\\\/g' \
		-e 's/\n/\\n/g' \
		-e 's//\\b/g' \
		-e 's//\\r/g' \
		-e 's//\\f/g' \
		-e 's/	/\\t/g' \
		-e 's/["/]/\\&/g' \
		-e 's/.*/"&"/' <<-EOF | tr -d '\n'
	$*
	EOF
}

usage() {
	printf '%s: [-e SEARCH_ENGINE]... [-H HOST] -k KEY_URLPATH URL...\n' >&2
}

dryrun=false

while getopts 'e:H:hk:n' _opt
do
	case ${_opt}
	in
		(e)
			case ${OPTARG}/${engines-}
			in
				(*/'*')
					# already all engines enabled
					;;
				('*'/*)
					engines='*'
					;;
				(*/*)
					if expr "${OPTARG}" : '[a-z.]\{1,\}$' >/dev/null
					then
						engines=${engines-}${engines:+ }"${OPTARG}"
					else
						printf 'error: invalid search engine name: %s\n' "${OPTARG}" >&2
						exit 1
					fi
					;;
			esac
			;;
		(H)
			host=${OPTARG}
			;;
		(k)
			keypath=${OPTARG}
			;;
		(n)
			dryrun=true
			;;
		(h)
			usage
			exit 0
			;;
		('?')  # others
			usage
			exit 2
			;;
	esac
done
unset -v OPTARG _opt
shift $((OPTIND-1))

# post processing options
case ${engines}
in
	('')
		printf 'error: no search engines given.\n' >&2
		printf '       Pass at least one of the following values or "*" to -e:\n' >&2
		printf '       %s\n' "${all_engines}" >&2
		exit 1
		;;
	('*')
		engines=${all_engines}
		;;
esac
case ${host-}
in
	('')
		# extract host from first URL
		case $1
		in
			(*://*)
				host=${1#*://}
				proto=${1%%${host}}
				host=${host%%/*}
				;;
			(*)
				proto='http://'
				host=${1%%/*}
				;;
		esac
		;;
esac
case ${keypath-}
in
	('')
		echo 'error: no key URL path given.' >&2
		exit 1
		;;
	(*)
		keyurl="${proto:?}${host:?}${keypath:?}"
		;;
esac

case $#
in
	(0)
		# no URLs
		exit
		;;
esac

# fetch key
key=$(curl -f -s -L -X GET "${keyurl:?}") \
&& test -n "${key}" || {
	echo 'fetching key failed' >&2
	exit 1
}

for engine in ${engines}
do
	case ${engine}
	in
		(indexnow)
			indexnow_url='https://api.indexnow.org/indexnow' ;;
		(bing)
			indexnow_url='https://www.bing.com/indexnow' ;;
		(naver)
			indexnow_url='https://searchadvisor.naver.com/indexnow' ;;
		(seznam.cz)
			indexnow_url='https://search.seznam.cz/indexnow' ;;
		(yandex)
			indexnow_url='https://yandex.com/indexnow' ;;
		(*)
			echo 'error: invalid search engine: %s\n' "${engine}" >&2
			continue
			;;
	esac

	if ${dryrun?}
	then
		printf 'Would submit URLs to %s...\n' "${engine}"
		continue
	fi

	printf 'Submitting URLs to %s...\n' "${engine}"
	{
		printf '{'
		printf '"host":%s' "$(jsonquot "${host}")"
		printf ',"key":%s' "$(jsonquot "${key}")"
		printf ',"keyLocation":%s' "$(jsonquot "${keyurl}")"
		printf ',"urlList":['
		(
			jsonquot "$1"
			shift
			for _url
			do
				printf ','
				jsonquot "${_url}"
			done
		)
		printf ']'
		printf '}'
	} \
	| curl -f -o- -w '\n' -d @- -H 'Content-Type: application/json; charset=utf-8' -X POST "${indexnow_url:?}" \
	|| : $((fails+=1))
done

exit $((fails))
