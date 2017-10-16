#!/usr/bin/env bash

function fetch-remote() {
	local REMOTE_TYPE="$1"
	local REMOTE_URL="$2"
	
	local FILE_NAME=$(basename "${REMOTE_URL}")
	if [ -e "${TEMP}/${FILE_NAME}" ]; then
		echo "    skip download: target file exists"
		echo "        -> ${TEMP}/${FILE_NAME}"
		return
	fi
	
	local FILE_PATH=$(download "${REMOTE_URL}")
	
	case "${REMOTE_TYPE}" in
	zip|tar)
		echo "  extract file at ${ROOT}"
		rm -fr "${ROOT}/.extract"
		ensure-chdir "${ROOT}/.extract"
		
		if [ "${REMOTE_TYPE}" = "zip" ]; then
			unzip -qo "${FILE_PATH}"
		elif [ "${REMOTE_TYPE}" = "tar" ]; then
			tar x --overwrite -f "${FILE_PATH}"
		fi
		
		if [ $(ls | wc -l) -eq 1 ]; then
			cp -fr ./*/. ..
		else
			cp -fr . ..
		fi
		cd "${ROOT}"
		rm -fr "${ROOT}/.extract"
	;;
	*)
		die "failed: unknown remote type: ${REMOTE_TYPE}"
	esac
}



function download() {
	local FILE_NAME=$(basename "${1}")
	wget -c "$1" -O "${TEMP}/${FILE_NAME}" --progress=bar:force:noscroll >&2
	echo "${TEMP}/${FILE_NAME}"
}
