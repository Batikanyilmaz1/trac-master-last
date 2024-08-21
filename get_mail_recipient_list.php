<?php
	require("./library.php");

    $type = $_GET['type'] ?? '1';
    $requestid = $_GET['request_id'] ?? 0;
    $reservationid = $_GET['reservation_id'] ?? 0;

	$conn = get_mysql_connection();

	if($conn) {
        if($type == '1') {

            // Prosedürü çağır (Yönetici bul)
            $stmt = $conn->prepare("SELECT GET_AUTHORIZED_PERSON_ID(CREATOR_USER_ID, ROUTE_ID) AS AUTHORIZED_PERSON_ID
                                    FROM REQUEST
                                    WHERE ID = :requestid");
            $stmt->bindParam(':requestid', $requestid, PDO::PARAM_INT);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $authorized_personid = $row['AUTHORIZED_PERSON_ID'];

            $stmt = $conn->prepare("SELECT '' AS uuid, CONCAT(U.NAME, ' ', U.SURNAME) AS name, U.EMAIL AS mail
                                    FROM USER U
                                    WHERE U.ID = :authorized_personid

                                    UNION

                                    SELECT '' AS uuid, CONCAT(U.NAME, ' ', U.SURNAME) AS name, U.EMAIL AS mail
                                    FROM USER U
                                    JOIN AUTHORIZED_PERSON_GROUP APG ON APG.USER_ID = U.ID
                                    WHERE APG.AUTHORIZED_PERSON_ID = :authorized_personid");
            $stmt->bindParam(':authorized_personid', $authorized_personid, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
        } else if($type == '2') {
            // Prosedürü çağır (User ve Traveler bul)
            $stmt = $conn->prepare("SELECT '' AS uuid, CONCAT(U.NAME, ' ', U.SURNAME) AS name, U.EMAIL AS mail
                                    FROM USER U
                                    JOIN REQUEST REQ ON REQ.CREATOR_USER_ID = U.ID
                                    JOIN RESERVATION RES ON RES.REQUEST_ID = REQ.ID
                                    WHERE RES.ID = :reservationid

                                    UNION

                                    SELECT '' AS uuid, CONCAT(T.NAME, ' ', T.SURNAME) AS name, T.EMAIL AS mail
                                    FROM TRAVELER T
                                    JOIN REQUEST_DETAIL RD ON RD.TRAVELER_ID = T.ID
                                    JOIN REQUEST REQ ON REQ.ID = RD.REQUEST_ID
                                    JOIN RESERVATION RES ON RES.REQUEST_ID = REQ.ID
                                    WHERE RES.ID = :reservationid");
            $stmt->bindParam(':reservationid', $reservationid, PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
        }

		foreach($rows as $row) {
			$mail_recipient_list[] = $row;
		}

		$conn = null;
	}

	$_SESSION['mail_recipient_list'] = $mail_recipient_list;
?>
{
    "TableName":"Table",
    "Columns":{"0":"uuid","1":"name","2":"mail"},
    "Rows":[
<?php
    $comma = "";
	foreach($mail_recipient_list as $mail_recipient) {
        echo $comma;
?>
        {"uuid":"<?php echo $mail_recipient['uuid']; ?>","name":"<?php echo $mail_recipient['name']; ?>","mail":"<?php echo $mail_recipient['mail']; ?>"}
<?php
        $comma = ",";
	}
?>
    ]
}