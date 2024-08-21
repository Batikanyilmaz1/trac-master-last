<?php
	if(session_status() != PHP_SESSION_ACTIVE) {
		session_start();
	}

	//if(basename(__FILE__) != 'win_auth.php' && !isset($_SESSION['username'])) {
	if(!isset($_SESSION['username'])) {
		header('Location: login.php');
		exit;
	}
?>