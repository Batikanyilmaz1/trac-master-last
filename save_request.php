<?php
	require("./library.php");

	$conn = get_mysql_connection();

	if($conn) {
		$_SESSION['request']['uuid'] = gen_uuid();
		$travel_info = $_SESSION['request']['travel_info'];
		$transportation_on_off = $_SESSION['request']['transportation_on_off'];
		$transportation_info = $_SESSION['request']['transportation_info'];
		$accommodation_on_off = $_SESSION['request']['accommodation_on_off'];
		$accommodation_info = $_SESSION['request']['accommodation_info'];

		// Prosedürü çağır (Request ekle)
		$stmt = $conn->prepare("CALL ADD_REQUEST(:uuid, :userid, :routeid, :reasonid, :fcountryid, :flocationid, :fcityid, :fcityname, :tcountryid, :tlocationid, :tcityid, :tcityname, 
												 :transportation, :departuredate, :returndate, :transferneedsituation, :transferneeddetail, :transportationmodeid, :transportatindetail,
												 :accommodation, :checkindate, :checkoutdate, :accommodationdetail, @oRequestId)");

		$stmt->bindParam(':uuid', $_SESSION['request']['uuid'], PDO::PARAM_STR);
		$stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
		$stmt->bindParam(':routeid', $travel_info['travel_routeid'], PDO::PARAM_INT);
		$stmt->bindParam(':reasonid', $travel_info['travel_reasonid'], PDO::PARAM_INT);
		$stmt->bindParam(':fcountryid', $travel_info['from_countryid'], PDO::PARAM_INT);
		$stmt->bindParam(':flocationid', $travel_info['from_locationid'], PDO::PARAM_INT);
		$stmt->bindParam(':fcityid', $travel_info['from_cityid'], PDO::PARAM_INT);
		$stmt->bindParam(':fcityname', $travel_info['from_city'], PDO::PARAM_STR);
		$stmt->bindParam(':tcountryid', $travel_info['to_countryid'], PDO::PARAM_INT);
		$stmt->bindParam(':tlocationid', $travel_info['to_locationid'], PDO::PARAM_INT);
		$stmt->bindParam(':tcityid', $travel_info['to_cityid'], PDO::PARAM_INT);
		$stmt->bindParam(':tcityname', $travel_info['to_city'], PDO::PARAM_STR);
		$stmt->bindParam(':transportation', $transportation_on_off, PDO::PARAM_BOOL);
		$stmt->bindParam(':departuredate', $transportation_info['departure_date'], PDO::PARAM_STR);
		$stmt->bindParam(':returndate', $transportation_info['return_date'], PDO::PARAM_STR);
		$stmt->bindParam(':transferneedsituation', $transportation_info['transfer_need_situation'], PDO::PARAM_INT);
		$stmt->bindParam(':transferneeddetail', $transportation_info['transfer_need_detail'], PDO::PARAM_STR);
		$stmt->bindParam(':transportationmodeid', $transportation_info['transportation_modeid'], PDO::PARAM_INT);
		$stmt->bindParam(':transportatindetail', $transportation_info['transportation_detail'], PDO::PARAM_STR);
		$stmt->bindParam(':accommodation', $accommodation_on_off, PDO::PARAM_BOOL);
		$stmt->bindParam(':checkindate', $accommodation_info['check-in_date'], PDO::PARAM_STR);
		$stmt->bindParam(':checkoutdate', $accommodation_info['check-out_date'], PDO::PARAM_STR);
		$stmt->bindParam(':accommodationdetail', $accommodation_info['accommodation_detail'], PDO::PARAM_STR);
		$stmt->execute();
		$stmt->closeCursor();

		// OUT parametresini al (oRequestId)
		$stmt = $conn->query("SELECT @oRequestId AS requestid");
		$row = $stmt->fetch(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

		$requestid = $row['requestid'];

		foreach($_SESSION['request']['traveler_list'] as $traveler) {
			// Prosedürü çağır (Traveler kontrol et / yoksa ekle)
			$stmt = $conn->prepare("CALL ADD_TRAVELER(:userid, :typeid, :name, :surname, :birthdate, :identityno, :passportno, :phone, :mail,
													  :position, :positionid, :department, :departmentid, :location, :locationid, @oTravelerId)");

			$stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
			$stmt->bindParam(':typeid', $traveler['typeid'], PDO::PARAM_INT);
			$stmt->bindParam(':name', $traveler['name'], PDO::PARAM_STR);
			$stmt->bindParam(':surname', $traveler['surname'], PDO::PARAM_STR);
			$stmt->bindParam(':birthdate', $traveler['birthdate'], PDO::PARAM_STR);
			$stmt->bindParam(':identityno', $traveler['identityno'], PDO::PARAM_INT);
			$stmt->bindParam(':passportno', $traveler['passportno'], PDO::PARAM_INT);
			$stmt->bindParam(':phone', $traveler['phone'], PDO::PARAM_STR);
			$stmt->bindParam(':mail', $traveler['mail'], PDO::PARAM_STR);
			$stmt->bindParam(':position', $traveler['position'], PDO::PARAM_STR);
			$stmt->bindParam(':positionid', $traveler['positionid'], PDO::PARAM_INT);
			$stmt->bindParam(':department', $traveler['department'], PDO::PARAM_STR);
			$stmt->bindParam(':departmentid', $traveler['departmentid'], PDO::PARAM_INT);
			$stmt->bindParam(':location', $traveler['location'], PDO::PARAM_STR);
			$stmt->bindParam(':locationid', $traveler['locationid'], PDO::PARAM_INT);
			$stmt->execute();
			$stmt->closeCursor();

			// OUT parametresini al (oTravelerId)
			$stmt = $conn->query("SELECT @oTravelerId AS travelerid");
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$travelerid = $row['travelerid'];

			// Prosedürü çağır (Request_Detail ekle)
			$stmt = $conn->prepare("CALL ADD_REQUEST_DETAIL(:requestid, :travelerid, @oRequestDetailId)");
			$stmt->bindParam(':requestid', $requestid, PDO::PARAM_INT);
			$stmt->bindParam(':travelerid', $travelerid, PDO::PARAM_INT);
			$stmt->execute();
			$stmt->closeCursor();

			// OUT parametresini al (oRequestDetailId)
			$stmt = $conn->query("SELECT @oRequestDetailId AS requestdetailid");
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$requestdetailid = $row['requestdetailid'];
		}

		if($requestid && $requestdetailid) {
			$request_approver_detail_uuid = '';
			$new_uuid = gen_uuid();
			$_SESSION['request']['approver']['uuid'] = $new_uuid;

			// Prosedürü çağır (Request_Approver_Detail ekle)
			$stmt = $conn->prepare("CALL ADD_REQUEST_APPROVER_DETAIL(:request_uuid, :request_approver_detail_uuid, :new_uuid, :userid, @oRequestApproverDetailId)");
			$stmt->bindParam(':request_uuid', $_SESSION['request']['uuid'], PDO::PARAM_STR);
			$stmt->bindParam(':request_approver_detail_uuid', $request_approver_detail_uuid, PDO::PARAM_STR);
			$stmt->bindParam(':new_uuid', $new_uuid, PDO::PARAM_STR);
			$stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
			$stmt->execute();
			$stmt->closeCursor();

			// OUT parametresini al (oRequestApproverDetailId)
			$stmt = $conn->query("SELECT @oRequestApproverDetailId AS requestapproverdetailid");
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$requestapproverdetailid = $row['requestapproverdetailid'];
		}
		$conn = null;
	}

	if($requestid && $requestdetailid && $requestapproverdetailid) {
?>
{"Rows":[{
	"status":"1",
	"requestid":"<?php echo $requestid; ?>"
}],"TableName":"Table",
"Columns":{
	"0":"status",
	"1":"requestid"
}}
<?php
	} else {
?>
{"Rows":[{
	"status":"0"
}],"TableName":"Table",
"Columns":{
	"0":"status"
}}
<?php
	}
?>