<?php

namespace vboxphpcms;

// require:
defined('vboxphp_can_include') || die("No");

// require:
defined('vboxphpcms_php_include') || die("No");
?>

<main role="main">

<!-- Main jumbotron for a primary marketing message or call to action -->
<div class="container jumbotron">
    <h1>BerryCluster AdminVM</h1>
    <p> </p>
    <?php
      // client info function
      client_info();
      // uptime
      echo "<p><b>uptime: </b>";
      system("uptime");
      echo "</p>";
    ?>
</div>
<!-- end jumbotron -->

</main>
