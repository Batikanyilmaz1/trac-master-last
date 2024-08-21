<?php
    $index = $_GET['index'] ?? '';
    $reservationid = $_GET['reservationid'] ?? '';

	if($index != '') {
		$index = 'index=' . $index;
	}

    if($reservationid != '') {
        $reservationid = '&reservationid=' . $reservationid;
    }

	if($index && $reservationid) {
		header('Location: cancel_reservation_internal_form.php?' . $index . $reservationid);
		exit;
	}
?>