<?php
/*
  name: index.php
  desc: vboxphpcms main entry point
*/

// env / vars ------------------------------------------------------------------

namespace vboxphpcms;

// look for this in all include files, die if not found.
define("vboxphp_can_include", "yesok");

// get pwd that index.php is in
$cmspath =  __DIR__;

// whitelisted pages
$pages_array = array(0 => 'home', 1 => 'logs', 2 => 'doc', 3 => 'about', 4 => 'status', 5 => 'about', 6 => 'nopage', 7 => 'vagrant');

// page request  ---------------------------------------------------------------

// check GET only request. If CLI request enable debug mode
include $cmspath . "/../inc_request_check.php";

// page request is
if(isset($_GET['p'])) {

  // A $_GET['p'] request
  $page = htmlspecialchars($_GET["p"]);

	// Check $page character length
	if( strlen( $page ) > 10) {
		die("No. Too big.");
	}

	// Check $page is only alphanumeric characters
	if (ctype_alnum($page)) {
		$page_default = "False";
	} else {
		die("No. Not alnum.");
	}

} else {

	// default request - $_GET['p'] is empty
  $page="home";
	$page_default = "True";

}

// vboxphpcms includes  --------------------------------------------------------

// check requested page is ok
if (in_array($page, $pages_array)) {

	// load vboxphpcms functions, classes etc
	include $cmspath . "/../inc_vboxphpcms.php";

	// load composer dependencies - https://getcomposer.org/
	require $cmspath . '/../vendor/autoload.php';

	// connect to DB
	include $cmspath . "/../inc_mysql.php";

	// start session
	session_start();

} else {

	// BAD:
  die("No. Not here.");

}

// Start HTML output -----------------------------------------------------------

// HTTP/1.1
header("Cache-Control: no-cache, must-revalidate");

// Date in the past
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");

// html header
include $cmspath . "/include/html_header.php";

// Menu
include $cmspath . "/include/html_menu.php";

// Page content to include
if (in_array($page, $pages_array)) {
  include $cmspath . "/pages/" . $page . ".php";
} else {
	die("No. Not here. B.");
}

// footer
include $cmspath . "/include/html_footer.php";

// /HTML -----------------------------------------------------------------------
?>
