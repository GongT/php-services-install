#!/usr/bin/env bash

set -e

TARGET_ROOT=

export FN_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
source "${FN_DIR}/base-config.sh"
source "${FN_DIR}/support.sh"

chdir-reset

eval "$(jenv env| grep -i domain)"

ensure-chdir "${TARGET_ROOT}"

export TEMP="${TARGET_ROOT}/.tmp"
export TMP="${TARGET_ROOT}/.tmp"
ensure-dir "${TEMP}"

source "${FN_DIR}/fetch-remote.sh"
source "${FN_DIR}/nginx-config.sh"

NAME=
SUB_DOMAIN=
REMOTE_URL=
REMOTE_TYPE=
CONFIG_ACTION=

function set-name() {
	NAME=$1
}
function set-domain() {
	SUB_DOMAIN=$1
}
function set-domain-base() {
	BASE_DOMAIN_NAME=$1
}
function set-remote() {
	REMOTE_TYPE=$1
	REMOTE_URL=$2
}
function set-config-action() {
	CONFIG_ACTION=$1
}
function emit() {
	set -e
	if [ -z "${NAME}" ]; then
		die "no NAME set in install script."
	fi
	
	echo "installing: ${NAME}"
	
	if [ -z "${SUB_DOMAIN}" ]; then
		SUB_DOMAIN="${NAME}"
	fi
	
	export DOMAIN="${SUB_DOMAIN}.${BASE_DOMAIN_NAME}"
	chdir-target
	
	if [ -n "${REMOTE_URL}" ]; then
		echo "  remote: ${REMOTE_TYPE}: ${REMOTE_URL}"
		fetch-remote "${REMOTE_TYPE}" "${REMOTE_URL}"
	fi
	
	if [ -n "${CONFIG_ACTION}" ]; then
		echo "  configure:"
		eval "${CONFIG_ACTION}"
	fi
	
	echo "  reload nginx:"
	create-nginx-config "${NAME}" "${DOMAIN}"
}

