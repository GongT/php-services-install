const JsonEnv = require(process.env.JENV_FILE_NAME);

console.log('<?php');
define('JENV_CONIG_SERVER', JsonEnv.database.mysql.hostname);
define('JENV_CONIG_SUPER_PASSWORD', JsonEnv.database.mysql.superPassword);
define('JENV_CONIG_PORT', 3306);
define('JENV_ACCOUNTS_HTTPS', !!JsonEnv.services.accounts.SSL);
define('JENV_PROXY_SERVER_NAME', proxy(JsonEnv.gfw.proxy || ''));
define('JENV_BASE_DOMAIN', JsonEnv.baseDomainName);

function proxy(url) {
	return require('url').parse(url).host;
}

function define(name, value) {
	console.log('define(%s, %s, true);', s(name), s(value));
}

function s(value) {
	if (typeof value === 'string') {
		return JSON.stringify(value);
	} else if (typeof value === 'number') {
		return value.toString();
	} else if (typeof value === 'boolean') {
		return value? 'true' : 'false';
	} else {
		throw new Error(`invalid value: (${typeof value}) ${value}`);
	}
}
