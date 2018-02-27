<?php
/*
	name: html_header.php
  desc: html head
*/

// require:
defined('vboxphp_can_include') || die("No");

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>R-Pi Cluster Admin/Dev VM</title>
  <!-- Required meta tags -->
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="/node_modules/bootstrap/dist/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb" crossorigin="anonymous">
  <!-- CSS theme -->
  <link rel="stylesheet" href="/css/my.css">
  <!-- https://highlightjs.org -->
  <link rel="stylesheet" href="/css/highlightjs.min.css">
  <script src="/js/highlight.min.js"></script>
  <script>hljs.initHighlightingOnLoad();</script>
  <!-- misc meta tags -->
  <meta name="application-name" content="vboxphpcms">
  <meta name="description" content="VagrantVM web interface">
  <meta name="author" content="crgm">
  <!-- generte generator tag -->
  <?php
  // running in Debug mode?
  if ( $debug_mode_enabled == "True" ) {
    echo "<meta name='generator' content='vboxphpcms debug mode'>\n";
  } else {
    echo "<meta name='generator' content='vboxphpcms normal mode'>\n";
  }
  ?>
</head>
<body>
