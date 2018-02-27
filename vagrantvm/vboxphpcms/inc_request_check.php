<?php
/*
	name: inc_request_check.php
  desc: check for type of PHP request
*/

namespace vboxphpcms;

// require:
defined('vboxphp_can_include') || die("No");

//------------------------------------------------------------------------------

// PHP Run type? Exec via CLI (php -q index.php), or http client  (wget, curl)?
$phpexectype = php_sapi_name();

// enable Debug for CLI
if (!isset($_SERVER['REMOTE_ADDR']) && $phpexectype == "cli") {

  // debug mode ON
	$debug_mode_enabled = "True";

  // options from command line
	$rpicmscli = getopt("u:tp:");

  // php errors on
	ini_set('display_errors', 'On');
	error_reporting(E_ALL | E_STRICT);

} else {

	// check running via Apache
	if ( $phpexectype == "apache2handler" ) {

		// check request type - http GET only
		$getmethod = $_SERVER['REQUEST_METHOD'];
		switch ($getmethod) {
			case 'GET':
		    $request_kind = "good";
		    break;
			case 'POST':
			   die("No. No POST.");
			   break;
			case 'PUT':
		    die("No. No PUT.");
		    break;
		  case 'HEAD':
		    die("No. No HEAD.");
		    break;
		  case 'DELETE':
		    die("No. No DEL.");
		    break;
		  case 'OPTIONS':
		    die("No. No OPT.");
		    break;
		  default:
		    die("No. Default.");
		    break;
		}

		// debug mode OFF
		$debug_mode_enabled = "False";

	} else {

  	// BAD request
		die("No. Wrong.");

  }

}

?>
