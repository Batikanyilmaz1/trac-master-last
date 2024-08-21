<?php
	require("./library.php");

	$reservationid = $_GET['inp_reservation_id'] ?? '';
	$explanation = $_GET['txt_explanation'] ?? '';

	$status_id = 22;

	if($reservationid && $explanation) {
		$conn = get_mysql_connection();

		if($conn) {
            // Prosedürü çağır (Request_Approver_Detail güncelle)
            $stmt = $conn->prepare("CALL UPDATE_RESERVATION(:reservationid, :userid, :status_id, :explanation, @oUpdatedRowCount)");

            $stmt->bindParam(':reservationid', $reservationid, PDO::PARAM_INT);
            $stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
            $stmt->bindParam(':status_id', $status_id, PDO::PARAM_INT);
            $stmt->bindParam(':explanation', $explanation, PDO::PARAM_STR);
            $stmt->execute();
            $stmt->closeCursor();

            // OUT parametresini al (oRequestApproverDetailId)
            $stmt = $conn->query("SELECT @oUpdatedRowCount AS updatedrowcount");
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $updatedrowcount = $row['updatedrowcount'];

			$conn = null;
		}
	}

	if($updatedrowcount) {
?>
{"Rows":[{
	"status":"1"
}],"TableName":"Table",
"Columns":{
	"0":"status"
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