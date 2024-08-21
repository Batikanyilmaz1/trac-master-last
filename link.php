<?php
	$gallery = $_GET['gallery'] ?? 100;
	$set = $_GET['set'] ?? 70;

	for($i = $gallery; $i < $gallery + 10; $i++) {
		for($j = $set; $j < $set + 10; $j++) {
			$img = 'https://between-legs.com/content/galleries/' . $j . '/' . $i . $j . '/full/001.jpg';
			echo '<a href="./gallery.php?gallery=' . $i . '&set=' . $j . '" target="_blank"><img src="' . $img . '" width="300" /></a>';
		}
	}
?>