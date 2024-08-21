<?php
	require("./library.php");

	$reservationid = $_GET['reservation_id'];
    $list_type = $_GET['list_type'] ?? '3';

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT R.ID, R.CREATION_TIME, CONCAT(U.NAME, ' ', U.SURNAME) AS USER, R.REQUEST_ID,
										GET_ROUTE_NAME(REQ.ROUTE_ID) AS ROUTE, REQ.TRANSPORTATION, REQ.ACCOMMODATION,
										GET_TRANSPORTATION_MODE_NAME(R.DEPARTURE_TRANSPORTATION_MODE_ID) AS DEPARTURE_TRANSPORTATION_MODE,
										R.DEPARTURE_PORT, R.DEPARTURE_DATE, R.DEPARTURE_COMPANY, R.DEPARTURE_PNR_CODE, R.DEPARTURE_TICKET_NUMBER,
										R.DEPARTURE_TICKET_PRICE, R.DEPARTURE_CAR_LICENSE_PLATE,
										GET_TRANSPORTATION_MODE_NAME(R.RETURN_TRANSPORTATION_MODE_ID) AS RETURN_TRANSPORTATION_MODE,
										R.RETURN_PORT, R.RETURN_DATE, R.RETURN_COMPANY, R.RETURN_PNR_CODE, R.RETURN_TICKET_NUMBER,
										R.RETURN_TICKET_PRICE, R.RETURN_CAR_LICENSE_PLATE,
										R.`CHECK-IN_DATE`, R.`CHECK-OUT_DATE`, R.HOTEL_NAME,
										R.STATUS_ID, GET_STATUS_NAME(R.STATUS_ID) AS STATUS
								 FROM RESERVATION R
								 JOIN REQUEST REQ ON REQ.ID = R.REQUEST_ID
								 JOIN USER U ON U.ID = R.CREATOR_USER_ID
								 JOIN REQUEST_APPROVER_DETAIL RAD ON RAD.REQUEST_ID = REQ.ID
								 WHERE R.ID = :reservationid ");

		$stmt->bindParam(':reservationid', $reservationid, PDO::PARAM_INT);
		$stmt->execute();
		$reservation = $stmt->fetch(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

        if($reservation) {
            $i = 1;

            include("./reservation_design.php");
        } else {
            echo '<div style="height: 30px;">Kayıt bulunamadı!</div>';
        }

		$conn = null;
	}
?>