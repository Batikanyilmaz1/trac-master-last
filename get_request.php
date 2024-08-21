<?php
	require("./library.php");

	$requestid =  $_GET['request_id'];
    $list_type = $_GET['list_type'] ?? '3';

    $operation_url = $_PARAM['webServerURL'] . '/trac/decide_request.php?link=user_uuid-request_uuid-request_approver_detail_uuid';
	$approve_link = $operation_url . '&process=approve';
	$revise_link = $operation_url . '&process=revise';
	$reject_link = $operation_url . '&process=reject';

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT R.ID, R.CREATION_TIME, CONCAT(U.NAME, ' ', U.SURNAME) AS USER, GET_ROUTE_NAME(R.ROUTE_ID) AS ROUTE, GET_REASON_NAME(R.REASON_ID) AS REASON,
										GET_COUNTRY_NAME(R.FROM_COUNTRY_ID) AS FROM_COUNTRY, GET_LOCATION_NAME(R.FROM_LOCATION_ID) AS FROM_LOCATION,
										CASE COALESCE(R.FROM_CITY_ID, 0) WHEN 0 THEN R.FROM_CITY_NAME ELSE GET_CITY_NAME(R.FROM_CITY_ID) END AS FROM_CITY,
										GET_COUNTRY_NAME(R.TO_COUNTRY_ID) AS TO_COUNTRY, GET_LOCATION_NAME(R.TO_LOCATION_ID) AS TO_LOCATION,
										CASE COALESCE(R.TO_CITY_ID, 0) WHEN 0 THEN R.TO_CITY_NAME ELSE GET_CITY_NAME(R.TO_CITY_ID) END AS TO_CITY,
										R.TRANSPORTATION, R.DEPARTURE_DATE, R.RETURN_DATE, R.TRANSFER_NEED_DETAIL,
										CASE R.TRANSFER_NEED_SITUATION WHEN 1 THEN 'Var' ELSE 'Yok' END AS TRANSFER_NEED_SITUATION,
										GET_TRANSPORTATION_MODE_NAME(R.TRANSPORTATION_MODE_ID) AS TRANSPORTATION_MODE, R.TRANSPORTATION_DETAIL,
										R.ACCOMMODATION, R.`CHECK-IN_DATE`, R.`CHECK-OUT_DATE`, R.ACCOMMODATION_DETAIL,
										RAD.STATUS_ID, GET_STATUS_NAME(RAD.STATUS_ID) AS STATUS
								 FROM REQUEST R
								 JOIN USER U ON U.ID = R.CREATOR_USER_ID
								 JOIN REQUEST_APPROVER_DETAIL RAD ON RAD.REQUEST_ID = R.ID
								 WHERE R.ID = :requestid
								   AND RAD.ACTIVE = 1 ");

		$stmt->bindParam(':requestid', $requestid, PDO::PARAM_INT);
		$stmt->execute();
		$request = $stmt->fetch(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

        if($request) {
            $stmt = $conn->prepare(" SELECT GET_TRAVELER_TYPE_NAME(T.TYPE_ID) AS TYPE, T.NAME, T.SURNAME, T.BIRTH_DATE, T.PHONE, T.EMAIL
                                     FROM TRAVELER T
                                     JOIN REQUEST_DETAIL RD ON RD.TRAVELER_ID = T.ID
                                     WHERE RD.REQUEST_ID = :requestid ");

            $stmt->bindParam(':requestid', $request['ID'], PDO::PARAM_INT);
            $stmt->execute();
            $travelers = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $i = 0;

            include("./request_design.php");
        } else {
            echo '<div style="height: 30px;">Kayıt bulunamadı!</div>';
        }

		$conn = null;
	}
?>