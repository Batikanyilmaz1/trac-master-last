<?php
	require("./library.php");

	$user_uuid = $_GET['inp_user_uuid'] ?? '';
	$request_uuid = $_GET['inp_request_uuid'] ?? '';
	$request_approver_detail_uuid = $_GET['inp_request_approver_detail_uuid'] ?? '';
	$explanation = $_GET['txt_explanation'] ?? '';

	$status_id = 16;

	if($request_uuid && $request_approver_detail_uuid && $explanation) {
		$conn = get_mysql_connection();

		if($conn) {
			// Prosedürü çağır (User Id bul)
			$stmt = $conn->prepare("SELECT ID
									FROM USER
									WHERE UUID = :uuid");

			$stmt->bindParam(':uuid', $user_uuid, PDO::PARAM_STR);
			$stmt->execute();
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$userid = $row['ID'] ?? 0;

			if($userid) {
				// Prosedürü çağır (Authorized Person Id bul)
				$stmt = $conn->prepare("SELECT RAD.AUTHORIZED_PERSON_ID
										FROM REQUEST R
										JOIN REQUEST_APPROVER_DETAIL RAD ON RAD.REQUEST_ID = R.ID
										WHERE R.UUID = :request_uuid
										  AND RAD.UUID = :request_approver_detail_uuid");

				$stmt->bindParam(':request_uuid', $request_uuid, PDO::PARAM_STR);
				$stmt->bindParam(':request_approver_detail_uuid', $request_approver_detail_uuid, PDO::PARAM_STR);
				$stmt->execute();
				$row = $stmt->fetch(PDO::FETCH_ASSOC);
				$stmt->closeCursor();

				$authorized_person_id = $row['AUTHORIZED_PERSON_ID'] ?? 0;

				if($authorized_person_id) {
					// Prosedürü çağır (User giriş kaydı yap)
					$stmt = $conn->prepare("CALL LOG_LOGIN_ACTIVITY(:userid, @oResult)");
					$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
					$stmt->execute();
					$stmt->closeCursor();

					// OUT parametresini al (oResult)
					$stmt = $conn->query("SELECT @oResult AS result");
					$row = $stmt->fetch(PDO::FETCH_ASSOC);
					$stmt->closeCursor();

					$result = $row['result'];

					if($result) {
						// Prosedürü çağır (Request_Approver_Detail güncelle)
						$stmt = $conn->prepare("CALL UPDATE_REQUEST_APPROVER_DETAIL(:request_uuid, :request_approver_detail_uuid, :userid, :status_id, :explanation,
												@oUpdatedRowCount, @oContinue)");

						$stmt->bindParam(':request_uuid', $request_uuid, PDO::PARAM_STR);
						$stmt->bindParam(':request_approver_detail_uuid', $request_approver_detail_uuid, PDO::PARAM_STR);
						$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
						$stmt->bindParam(':status_id', $status_id, PDO::PARAM_INT);
						$stmt->bindParam(':explanation', $explanation, PDO::PARAM_STR);
						$stmt->execute();
						$stmt->closeCursor();

						// OUT parametresini al (oRequestApproverDetailId)
						$stmt = $conn->query("SELECT @oUpdatedRowCount AS updatedrowcount, @oContinue AS iscontinue");
						$row = $stmt->fetch(PDO::FETCH_ASSOC);
						$stmt->closeCursor();

						$updatedrowcount = $row['updatedrowcount'];
					}
				}
			}
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