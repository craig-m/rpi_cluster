<?php
/*
	name: inc_mysql.php
  desc: connect to locsl MySQL DB
*/

namespace vboxphpcms;

// require:
defined('vboxphp_can_include') || die("No");

// require:
defined('vboxphpcms_php_include') || die("No");

$servername = "localhost";
$username = "vphpcms";
$password = "vboxtestnotused12";

// Create connection
$conn = mysqli_connect($servername, $username, $password);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

?>
