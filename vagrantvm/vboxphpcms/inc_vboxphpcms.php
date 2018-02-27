<?php
/*
	name: inc_vboxphpcms.php
  desc: any php classes, functions etc needed. Not web accessible.
*/

namespace vboxphpcms;

// require:
defined('vboxphp_can_include') || die("No");

// set:
define("vboxphpcms_php_include", "yesok");

//------------------------------------------------------------------------------

// function - included in other functions
function debug_vbfunc($the_function_name){
	echo "<debug>called_function: " . $the_function_name . " </debug>\n";
}

//------------------------------------------------------------------------------

// Return client info
function client_info(){

	// project debug mode?
  global $debug_mode_enabled;
  if ( $debug_mode_enabled == "True" ) { debug_vbfunc(__FUNCTION__); }

  // override missing defaults for cli
  $phpexectype = php_sapi_name();
  if ( $phpexectype == "cli" ) {
    $_SERVER['REMOTE_ADDR']="debug";
    $_SERVER['SERVER_ADDR']="debug";
    $_SERVER['HTTP_USER_AGENT']="debug";
    $_SERVER['HTTP_HOST']="debug";
    $_SERVER['REMOTE_PORT']="debug";
    $_SERVER['SERVER_PORT']="debug";
  }

  // return output
  echo "<p><b>http_host + script_name: </b>" . $_SERVER['HTTP_HOST'] . $_SERVER['SCRIPT_NAME'] . "</p>";
  echo "<p><b>Client: </b>" . $_SERVER['REMOTE_ADDR'] . ":" . $_SERVER['REMOTE_PORT'] . " <b>Server: </b>" . $_SERVER['SERVER_ADDR'] . ":" . $_SERVER['SERVER_PORT'] . "</p>";
  echo "<p><b>User agent: </b>" . $_SERVER['HTTP_USER_AGENT'] . "</p>";
}

//------------------------------------------------------------------------------

// Return footer info
function footer_info(){

	// project debug mode?
  global $debug_mode_enabled;
  if ( $debug_mode_enabled == "True" ) { debug_vbfunc(__FUNCTION__); }

  // override missing defaults for cli
  $phpexectype = php_sapi_name();
  if ( $phpexectype == "cli" ) {
    $_SERVER['SERVER_SIGNATURE']="debug";
  }

  // return output
  echo "<p> <i>b3rry.clust0r INC</i> &spades; </p>";
  echo "<p> <i>" . $_SERVER['SERVER_SIGNATURE'] . "</i></p>";
}

//------------------------------------------------------------------------------

?>
