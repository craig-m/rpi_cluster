<?php
/*
	name: html_footer.php
  desc: html footer
*/

namespace vboxphpcms;

// require:
defined('vboxphp_can_include') || die("No");

// require:
defined('vboxphpcms_php_include') || die("No");
?>
<!-- footer -->
<hr>

<footer class="container">
  <?php footer_info(); ?>
</footer>

<script src="js/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
<script src="js/popper.min.js" integrity="sha384-vFJXuSJphROIrBnz7yo7oB41mKfc8JzQZiCq4NCceLEaO4IHwicKwpJf9c9IpFgh" crossorigin="anonymous"></script>
<script src="/node_modules/bootstrap/dist/js/bootstrap.min.js" integrity="sha384-alpBpkh1PFOepccYVYDB4do5UnbKysX5WZXm3XxPqe5iKTfUKjNkCk9SaVuEZflJ" crossorigin="anonymous"></script>

</body>
</html>
