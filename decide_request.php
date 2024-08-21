<?php
    $process = $_GET['process'] ?? '';
	$way = $_GET['way'] ?? 'external';
	$link = $_GET['link'] ?? '';
	$index = $_GET['index'] ?? '';
    $requestid = $_GET['requestid'] ?? '';

	if($index != '') {
		$index = '&index=' . $index;
	}

    if($requestid != '') {
        $requestid = '&requestid=' . $requestid;
    }

	if($process && $link) {
		header('Location: ' . $process . '_request_' . $way . '_form.php?link=' . $link . $index . $requestid);
		exit;
	}
?>