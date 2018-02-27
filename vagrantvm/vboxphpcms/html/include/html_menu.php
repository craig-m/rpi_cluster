<?php
/*
	name: html_menu.php
  desc: Vboxphpcms navigation items
*/

// require:
defined('vboxphp_can_include') || die("No");

?>
<!-- menu -->
<nav class="navbar navbar-expand-md navbar-dark fixed-top bg-dark">
  <a class="navbar-brand" href="index.php">home</a>

  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>

  <div class="collapse navbar-collapse" id="navbarsExampleDefault">
      <ul class="navbar-nav mr-auto">
        <li class="nav-item <?php if ($page=="about") { echo 'active'; } ?>">
          <a class="nav-link" href="index.php?p=about">about</a>
        </li>
        <li class="nav-item <?php if ($page=="doc") { echo 'active'; } ?>">
          <a class="nav-link" href="index.php?p=doc">setup_doc</a>
        </li>
        <li class="nav-item <?php if ($page=="vagrant") { echo 'active'; } ?>">
          <a class="nav-link" href="index.php?p=vagrant">vagrant</a>
        </li>
        <li class="nav-item <?php if ($page=="logs") { echo 'active'; } ?>">
          <a class="nav-link" href="index.php?p=logs">logs</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" target="_blank" href="/pub/">/pub/</a>
        </li>
      </ul>
      <!--
      <form class="form-inline my-2 my-lg-0">
        <input class="form-control mr-sm-2" type="text" placeholder="Search" aria-label="Search">
        <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
      </form>
      -->
  </div>
</nav>
