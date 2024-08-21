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
			$param1 = "R.CREATOR_USER_ID = :userid";
			$param2 = "AND RAD.ACTIVE = '1'";
		} else if($list_type == '2') {
			$param1 = "(CHECK_EXECUTIVE_PERSON(:userid) = 1 OR
						RAD.AUTHORIZED_PERSON_ID = :userid OR
						RAD.AUTHORIZED_PERSON_ID IN ( SELECT AUTHORIZED_PERSON_ID
													  FROM AUTHORIZED_PERSON_GROUP
													  WHERE USER_ID = :userid ))";
			$param2 = "AND RAD.ACTIVE = '1'";
		}

		$stmt = $conn->prepare(" SELECT R.ID, R.CREATION_TIME, CONCAT(U1.NAME, ' ', U1.SURNAME) AS USER, GET_ROUTE_NAME(R.ROUTE_ID) AS ROUTE, GET_REASON_NAME(R.REASON_ID) AS REASON,
										GET_COUNTRY_NAME(R.FROM_COUNTRY_ID) AS FROM_COUNTRY, GET_LOCATION_NAME(R.FROM_LOCATION_ID) AS FROM_LOCATION,
										CASE WHEN COALESCE(R.FROM_CITY_ID, 0) = 0 THEN R.FROM_CITY_NAME ELSE GET_CITY_NAME(R.FROM_CITY_ID) END AS FROM_CITY,
										GET_COUNTRY_NAME(R.TO_COUNTRY_ID) AS TO_COUNTRY, GET_LOCATION_NAME(R.TO_LOCATION_ID) AS TO_LOCATION,
										CASE WHEN COALESCE(R.TO_CITY_ID, 0) = 0 THEN R.TO_CITY_NAME ELSE GET_CITY_NAME(R.TO_CITY_ID) END AS TO_CITY,
										R.TRANSPORTATION, R.DEPARTURE_DATE, R.RETURN_DATE, R.TRANSFER_NEED_DETAIL,
										CASE WHEN R.TRANSFER_NEED_SITUATION = 1 THEN 'Var' ELSE 'Yok' END AS TRANSFER_NEED_SITUATION,
										GET_TRANSPORTATION_MODE_NAME(R.TRANSPORTATION_MODE_ID) AS TRANSPORTATION_MODE, R.TRANSPORTATION_DETAIL,
										R.ACCOMMODATION, R.`CHECK-IN_DATE`, R.`CHECK-OUT_DATE`, R.ACCOMMODATION_DETAIL,
										RAD.STATUS_ID, GET_STATUS_NAME(RAD.STATUS_ID) AS STATUS, CONCAT(U2.NAME, ' ', U2.SURNAME) AS AUTHORIZED_USER,
										R.UUID AS REQ_UUID, RAD.UUID AS RAD_UUID, RES.ID AS RESERVATION_ID
								 FROM REQUEST R
								 JOIN USER U1 ON U1.ID = R.CREATOR_USER_ID
								 JOIN REQUEST_APPROVER_DETAIL RAD ON RAD.REQUEST_ID = R.ID
								 JOIN USER U2 ON U2.ID = RAD.AUTHORIZED_PERSON_ID
                                 LEFT JOIN RESERVATION RES ON RES.REQUEST_ID = R.ID
								 WHERE
								   $param1
								   AND (RAD.STATUS_ID = :statusid OR 0 = :statusid)
								   AND DATE_FORMAT(R.CREATION_TIME, '%Y-%m-%d') BETWEEN :start_date AND :end_date
								   $param2 ");

		$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
		$stmt->bindParam(':statusid', $statusid, PDO::PARAM_INT);
		$stmt->bindParam(':start_date', $start_date, PDO::PARAM_STR);
		$stmt->bindParam(':end_date', $end_date, PDO::PARAM_STR);
		$stmt->execute();
		$requests = $stmt->fetchAll(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

		$i = 1;

		foreach($requests as $request) {
			$stmt = $conn->prepare(" SELECT GET_TRAVELER_TYPE_NAME(T.TYPE_ID) AS TYPE, T.NAME, T.SURNAME, T.BIRTH_DATE, T.PHONE, T.EMAIL
									 FROM TRAVELER T
									 JOIN REQUEST_DETAIL RD ON RD.TRAVELER_ID = T.ID
									 WHERE RD.REQUEST_ID = :request_id ");

			$stmt->bindParam(':request_id', $request['ID'], PDO::PARAM_INT);
			$stmt->execute();
			$travelers = $stmt->fetchAll(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			include("./request_design.php");

            $i++;
		}
		$conn = null;
	}
?>