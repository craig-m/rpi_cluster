<?php
// require:
defined('vboxphp_can_include') || die("No");

// require:
defined('vboxphpcms_php_include') || die("No");
?>

<main role="main">

<div class="container">

<!-- generated by parsedown: -->
<?php
  $html = file_get_contents('/var/www/md/doc_readme.md');
  $Parsedown = new Parsedown();
  echo $Parsedown->text($html);
?>
<!-- /generated by parsedown -->

</div>

</main>