<?php
	require("./library.php");

	$requestid =  $_GET['request_id'] ?? '';
	$status = 0;

	if($requestid) {
		$conn = get_mysql_connection();

		if($conn) {
			$stmt = $conn->prepare(" SELECT R.TRANSPORTATION, R.TRANSPORTATION_MODE_ID, R.DEPARTURE_DATE, R.RETURN_DATE,
											R.ACCOMMODATION, R.`CHECK-IN_DATE`, R.`CHECK-OUT_DATE`
									 FROM REQUEST R
									 WHERE R.ID = :requestid ");

			$stmt->bindParam(':requestid', $requestid, PDO::PARAM_INT);
			$stmt->execute();
			$requests = $stmt->fetchAll(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$conn = null;

			if(count($requests)) {
				$request = $requests[0];
				$status = 1;
			}
		}
	}

	if($status) {
?>
{"Rows":[{
	"status":"1",
	"transportation":"<?php echo $request['TRANSPORTATION']; ?>",
	"transportationmodeid":"<?php echo $request['TRANSPORTATION_MODE_ID']; ?>",
	"departuredate":"<?php echo $request['DEPARTURE_DATE']; ?>",
	"returndate":"<?php echo $request['RETURN_DATE']; ?>",
	"accommodation":"<?php echo $request['ACCOMMODATION']; ?>",
	"checkindate":"<?php echo $request['CHECK-IN_DATE']; ?>",
	"checkoutdate":"<?php echo $request['CHECK-OUT_DATE']; ?>"
}],"TableName":"Table",
"Columns":{
	"0":"status",
	"1":"transportation",
	"2":"transportationmodeid",
	"3":"departuredate",
	"4":"returndate",
	"5":"accommodation",
	"6":"checkindate",
	"7":"checkoutdate"
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