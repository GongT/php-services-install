#!/usr/bin/env bash

function chdir-reset() {
	cd "${FN_DIR}/.."
}
function chdir-target() {
	export ROOT="${TARGET_ROOT}/${NAME}"
	ensure-chdir "${ROOT}"
}

function ensure-dir() {
	if ! [ -d "$1" ]; then
		mkdir -p "$1"
	fi
}
function ensure-parent-dir() {
	ensure-dir "$(dirname "$1")"
}
function ensure-chdir() {
	ensure-dir "$1"
	cd "$1"
}

function log_error() {
	echo -ne "\e[38;5;9m" >&2
	echo -n "$@" >&2
	echo -e "\e[0m" >&2
}
function die() {
	log_error "$@"
	exit 1
}

function get-target-path() {
	local TO="$1"
	echo "${TARGET_ROOT}/${NAME}/${TO}"
}
function get-staff() {
	local FROM="$1"
	realpath "${FN_DIR}/../staff/${NAME}/${FROM}"
}
function copy-staff() {
	local FROM=$(get-staff "$1")
	local TO=$(get-target-path "$2")
	ensure-parent-dir "${TO}"
	cp -r "${FROM}" "${TO}"
}
function cat-staff() {
	local FROM=$(get-staff "$1")
	cat "${FROM}"
}
function save-staff() {
	local TO=$(get-target-path "$1")
	ensure-parent-dir "${TO}"
	cat > "${TO}"
}
