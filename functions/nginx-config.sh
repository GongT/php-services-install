#!/usr/bin/env bash

cd "${TEMP}"
docker inspect --type=container nginx > dump.json

echo '
const d = require("./dump.json")[0];
d.Mounts.some((e) => {
	if (e.Destination === "/data/config") {
		console.log(e.Source);
	}
});
' > detect.js

NGINX_DIR=$(node detect.js)

if [ ! -e "${NGINX_DIR}/nginx.conf" ]; then
	die "nginx config not found."
fi

echo "nginx dir is ${NGINX_DIR}"

function create-nginx-config() {
	local NGINX_CONFIG_FILE="${NGINX_DIR}/other-sites.d/${1}.conf"
	ensure-parent-dir "${NGINX_CONFIG_FILE}"
	
echo "
server {
	listen 80;
	listen 81;
	
	server_name ${DOMAIN};
	root /host${ROOT};
	index index.php;
	autoindex on;
	
	include allow_php.conf;
	
	try_files \$uri \"\${uri}index.php?\$query_string\";
	
	include other-config.d/global-body.conf;
}
" > "${NGINX_CONFIG_FILE}"

	docker exec nginx -t || die "nginx config failed."
	docker exec nginx -s reload
}
