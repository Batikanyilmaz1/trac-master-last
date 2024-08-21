<?php
	require("./library.php");

	$conn = get_mysql_connection();

	if($conn) {
		$reservation = $_SESSION['reservation'];
		$transportation_info = $reservation['transportation_info'];
		$departure = $transportation_info['departure'];
		$return = $transportation_info['return'];
		$accommodation_info = $reservation['accommodation_info'];

		// Prosedürü çağır (Reservation ekle)
		$stmt = $conn->prepare("CALL ADD_RESERVATION(:uuid, :userid, :requestid, :departuretransportationmodeid, :departureport, :departuredate, :departurecompany, :departurepnrcode,
													 :departureticketnumber, :departureticketprice, :departurecarlicenseplate, :returntransportationmodeid, :returnport, :returndate,
													 :returncompany, :returnpnrcode, :returnticketnumber, :returnticketprice, :returncarlicenseplate, :checkindate, :checkoutdate,
													 :hotelname, @oReservationId)");

		$stmt->bindParam(':uuid', $reservation['uuid'], PDO::PARAM_STR);
		$stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
		$stmt->bindParam(':requestid', $reservation['requestid'], PDO::PARAM_INT);
		$stmt->bindParam(':departuretransportationmodeid', $departure['transportation_modeid'], PDO::PARAM_INT);
		$stmt->bindParam(':departureport', $departure['port'], PDO::PARAM_STR);
		$stmt->bindParam(':departuredate', $departure['date'], PDO::PARAM_STR);
		$stmt->bindParam(':departurecompany', $departure['company'], PDO::PARAM_STR);
		$stmt->bindParam(':departurepnrcode', $departure['pnr_code'], PDO::PARAM_STR);
		$stmt->bindParam(':departureticketnumber', $departure['ticket_number'], PDO::PARAM_STR);
		$stmt->bindParam(':departureticketprice', $departure['ticket_price'], PDO::PARAM_STR);
		$stmt->bindParam(':departurecarlicenseplate', $departure['car_license_plate'], PDO::PARAM_STR);
		$stmt->bindParam(':returntransportationmodeid', $return['transportation_modeid'], PDO::PARAM_INT);
		$stmt->bindParam(':returnport', $return['port'], PDO::PARAM_STR);
		$stmt->bindParam(':returndate', $return['date'], PDO::PARAM_STR);
		$stmt->bindParam(':returncompany', $return['company'], PDO::PARAM_STR);
		$stmt->bindParam(':returnpnrcode', $return['pnr_code'], PDO::PARAM_STR);
		$stmt->bindParam(':returnticketnumber', $return['ticket_number'], PDO::PARAM_STR);
		$stmt->bindParam(':returnticketprice', $return['ticket_price'], PDO::PARAM_STR);
		$stmt->bindParam(':returncarlicenseplate', $return['car_license_plate'], PDO::PARAM_STR);
		$stmt->bindParam(':checkindate', $accommodation_info['check-in_date'], PDO::PARAM_STR);
		$stmt->bindParam(':checkoutdate', $accommodation_info['check-out_date'], PDO::PARAM_STR);
		$stmt->bindParam(':hotelname', $accommodation_info['hotel_name'], PDO::PARAM_STR);
		$stmt->execute();
		$stmt->closeCursor();

		// OUT parametresini al (oReservationId)
		$stmt = $conn->query("SELECT @oReservationId AS reservationid");
		$row = $stmt->fetch(PDO::FETCH_ASSOC);
		$stmt->closeCursor();

		$reservationid = $row['reservationid'];
		$conn = null;
	}

	if($reservationid) {
?>
{"Rows":[{
	"status":"1",
	"reservationid":"<?php echo $reservationid; ?>"
}],"TableName":"Table",
"Columns":{
	"0":"status",
	"1":"reservationid"
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