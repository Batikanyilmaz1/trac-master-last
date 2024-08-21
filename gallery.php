<?php
	for($i = 1; $i < 19; $i++) {
		$img = 'https://between-legs.com/content/galleries/' . $_GET['set'] . '/' . $_GET['gallery'] . $_GET['set'] . '/full/' . sprintf("%'.03d\n", $i) . '.jpg';
		echo '<a href="' . $img . '" target="_blank"><img src="' . $img . '" width="300" /></a>';
	}
?>