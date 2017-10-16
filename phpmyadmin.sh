#!/usr/bin/env bash

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/functions/init.sh"

set-name phpmyadmin
set-domain pma
set-remote zip http://files.phpmyadmin.net/phpMyAdmin/4.7.4/phpMyAdmin-4.7.4-all-languages.zip
set-config-action CONFIG_PMA

function CONFIG_PMA() {
	set -e
	if [ ! -e config.inc.php ]; then
		copy-staff base.php config.inc.php
	fi
	sed -i '/^\?>$/d; /^require "config\/extra\.config\.php"\;$/d' config.inc.php
	echo 'require "config/extra.config.php";' >> config.inc.php
	
	copy-staff extra.php config/extra.config.php
	chdir-reset
	jenv node "$(get-staff filter.js)" | save-staff config/jenv.config.php
	
	chdir-target
	mkdir -p config/
	cp -f sql/* config/
}

emit
