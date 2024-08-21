<?php
	require("./library.php");

	$uuid = $_GET['uuid'] ?? '';

	if($uuid) {
		unset($_SESSION['request']['traveler_list'][$uuid]);
	} else {
		$_SESSION['request']['traveler_list'] = [];
	}
?>