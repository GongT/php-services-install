<?php
$server = [];

require "jenv.config.php";

function continue_input() {
	$curr_url = (isset($_SERVER['HTTPS']) ? "https" : "http") . '://' . $_SERVER['HTTP_HOST'];
	$curr_url .= '?' . http_build_query(['continue' => 'yes']);
	
	return '<a href="' . $curr_url . '">continue</a>';
}

function account_url($path) {
	$account_url = (JENV_ACCOUNTS_HTTPS ? "https" : "http") . '://accounts.' . JENV_BASE_DOMAIN;
	$redirect    = $account_url . $path . '?';
	$curr_url    = (isset($_SERVER['HTTPS']) ? "https" : "http") . '://' . $_SERVER['HTTP_HOST'];
	$redirect    .= http_build_query(['redirect' => $curr_url]);
	
	return $redirect;
}

function goto_login() {
	header('Location: ' . account_url('/login'), true, 302);
	exit(0);
}

function linkTo($uri, $title) {
	return '<a href="' . account_url($uri) . '">' . $title . '</a>';
}

/* user login */
function try_login() {
	$account_url = (JENV_ACCOUNTS_HTTPS ? "https" : "http") . '://accounts.' . JENV_BASE_DOMAIN;
	
	if (isset($_SESSION['continue'])) {
		return false;
	}
	if (isset($_GET['continue'])) {
		$_SESSION['continue'] = true;
		
		return false;
	}
	if (isset($_GET['token'])) {
		$token = $_GET['token'];
		
		try {
			$curl = curl_init($account_url . '/api/get_current_user?' . http_build_query(['token' => $token]));
			curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
			$data = curl_exec($curl);
			$obj  = json_decode($data, true);
		} catch (Exception $e) {
			die('login server down now.');
		}
		if (!isset($obj['status']) || $obj['status'] !== 0) {
			die('failed: ' . $obj['message'] . '.<br/>' . linkTo('/login', 'retry') . '.<br/>' . continue_input());
		}
		if ($obj['user']['email'] !== 'admin@' . JENV_BASE_DOMAIN) {
			die('no permission.<br/>' . linkTo('/login/logout', 'logout') . '.<br/>' . continue_input());
		}
		
		$_SESSION['uid'] = $token;
	}
	if (isset($_SESSION['uid'])) {
		return true;
	}
	
	goto_login();
	
	return false;
}

if (session_status() !== PHP_SESSION_ACTIVE) {
	session_start();
}
if (try_login()) {
	$server['auth_type'] = 'config';
	$server['user']      = 'root';
	$server['password']  = JENV_CONIG_SUPER_PASSWORD;
}
session_write_close();

/* user login */

$server['verbose']           = 'config-server';
$server['host']              = JENV_CONIG_SERVER;
$server['port']              = JENV_CONIG_PORT;
$server['socket']            = '';
$server['DisableIS']         = true;
$server['pmadb']             = 'phpmyadmin';
$server['controluser']       = 'phpmyadmin';
$server['controlpass']       = 'phpmyadmin';
$server['bookmarktable']     = 'pma__bookmark';
$server['relation']          = 'pma__relation';
$server['userconfig']        = 'pma__userconfig';
$server['users']             = 'pma__users';
$server['usergroups']        = 'pma__usergroups';
$server['navigationhiding']  = 'pma__navigationhiding';
$server['table_info']        = 'pma__table_info';
$server['column_info']       = 'pma__column_info';
$server['history']           = 'pma__history';
$server['recent']            = 'pma__recent';
$server['favorite']          = 'pma__favorite';
$server['table_uiprefs']     = 'pma__table_uiprefs';
$server['tracking']          = 'pma__tracking';
$server['table_coords']      = 'pma__table_coords';
$server['pdf_pages']         = 'pma__pdf_pages';
$server['savedsearches']     = 'pma__savedsearches';
$server['central_columns']   = 'pma__central_columns';
$server['designer_settings'] = 'pma__designer_settings';
$server['export_templates']  = 'pma__export_templates';

if (!isset($cfg['Servers'])) {
	$cfg['Servers'] = [];
}
$servers = array_values($cfg['Servers']);
array_unshift($servers, null, $server);
unset($servers[0]);
$cfg['Servers'] = $servers;

$cfg['ZipDump']                           = false;
$cfg['BZipDump']                          = false;
$cfg['LoginCookieRecall']                 = false;
$cfg['PmaNoRelation_DisableWarning']      = true;
$cfg['LoginCookieValidityDisableWarning'] = true;
$cfg['UserprefsDeveloperTab']             = true;
$cfg['OBGzip']                            = 0;
$cfg['PersistentConnections']             = true;
$cfg['ProxyUrl']                          = JENV_PROXY_SERVER_NAME;
$cfg['QueryHistoryDB']                    = true;
$cfg['RetainQueryBox']                    = true;
$cfg['NavigationTreeDefaultTabTable2']    = 'browse';
$cfg['DefaultLang']                       = 'zh_CN';
$cfg['ServerDefault']                     = 1;

$cfg['AllowArbitraryServer'] = true;
$cfg['blowfish_secret']      = 'fvskl,gnw5%htbjn,789y$iufk&98tg^%&8764tdmf*&&x154^yhgy$s';
$cfg['UploadDir']            = __DIR__;
$cfg['SaveDir']              = __DIR__;
