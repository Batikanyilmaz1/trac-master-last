<?php
	require("./library.php");

	$userid = $_SESSION['userid'];
	$list_type = $_GET['list_type'];
	$statusid = $_GET['status_id'];
	$start_date = $_GET['start_date'];
	$end_date = $_GET['end_date'];

	if($statusid == '') {
		$statusid = 0;
	}
	if($start_date == '') {
		$start_date = '2024-01-01';
	}
	if($end_date == '') {
		$end_date = date('Y-m-d', mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')));
	}

	$conn = get_mysql_connection();

	if($conn) {
		if($list_type == '1') {
			$param1 = "REQ.CREATOR_USER_ID = :userid";
			$param2 = "AND RAD.ACTIVE = '1'";
		} else if($list_type == '2') {
			$param1 = "(CHECK_EXECUTIVE_PERSON(:userid) = 1 OR
						RAD.AUTHORIZED_PERSON_ID = :userid OR
						RAD.AUTHORIZED_PERSON_ID IN ( SELECT AUTHORIZED_PERSON_ID
													  FROM AUTHORIZED_PERSON_GROUP
													  WHERE USER_ID = :userid ))";
			$param2 = "AND RAD.ACTIVE = '1'";
		}

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
								 WHERE
								   $param1
								   AND (R.STATUS_ID = :statusid OR 0 = :statusid)
								   AND DATE_FORMAT(R.CREATION_TIME, '%Y-%m-%d') BETWEEN :start_date AND :end_date
								   $param2 ");

		$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		$stmt->bindParam(':statusid', $statusid, PDO::PARAM_INT);
		$stmt->bindParam(':start_date', $start_date, PDO::PARAM_STR);
		$stmt->bindParam(':end_date', $end_date, PDO::PARAM_STR);
		$stmt->execute();
		$reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

		$i = 1;

		foreach($reservations as $reservation) {

			include("./reservation_design.php");

            $i++;
		}
		$conn = null;
	}
?>