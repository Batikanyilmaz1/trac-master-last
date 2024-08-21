<?php
	require("./library.php");

	$conn = get_mysql_connection();

	if($conn) {
		$sql = ' SELECT T.NAME, T.SURNAME, T.BIRTH_DATE, T.IDENTITY_NO, T.PASSPORT_NO, T.PHONE, T.EMAIL,
						P.ID AS P_ID, P.NAME AS P_NAME, D.ID AS D_ID, D.NAME AS D_NAME, L.ID AS L_ID, L.NAME AS L_NAME
				 FROM TRAVELER T
				 LEFT JOIN POSITION P ON P.ID = T.POSITION_ID
				 LEFT JOIN DEPARTMENT D ON D.ID = T.DEPARTMENT_ID
				 LEFT JOIN LOCATION L ON L.ID = T.LOCATION_ID
				 WHERE ';

		$type = $_GET['type'] ?? '';

		if($type == 'name') {
			$name = $_GET['name'] ?? '';
			$surname = $_GET['surname'] ?? '';
			$birthdate = date('Y-m-d', strtotime($_GET['birthdate'] ?? '')); ;
			$stmt = $conn->prepare($sql . 'T.NAME = :name AND T.SURNAME = :surname AND T.BIRTH_DATE = :birthdate');
			$stmt->bindParam(':name', $name, PDO::PARAM_STR);
			$stmt->bindParam(':surname', $surname, PDO::PARAM_STR);
			$stmt->bindParam(':birthdate', $birthdate, PDO::PARAM_STR);
		} else if($type == 'identityno') {
			$identityno = $_GET['identityno'] ?? '';
			$stmt = $conn->prepare($sql . 'T.IDENTITY_NO = :identityno');
			$stmt->bindParam(':identityno', $identityno, PDO::PARAM_INT);
		} else if($type == 'passportno') {
			$passportno = $_GET['passportno'] ?? '';
			$stmt = $conn->prepare($sql . 'T.PASSPORT_NO = :passportno');
			$stmt->bindParam(':passportno', $passportno, PDO::PARAM_INT);
		} else if($type == 'phone') {
			$phone = $_GET['phone'] ?? '';
			$stmt = $conn->prepare($sql . 'T.PHONE = :phone');
			$stmt->bindParam(':phone', $phone, PDO::PARAM_STR);
		} else if($type == 'mail') {
			$mail = $_GET['mail'] ?? '';
			$stmt = $conn->prepare($sql . 'T.EMAIL = :mail');
			$stmt->bindParam(':mail', $mail, PDO::PARAM_STR);
		}

		$stmt->execute();

		$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

		$stmt->closeCursor();
		$conn = null;

		$row = $rows['0'] ?? '';

		if($row) {
?>
{"Rows":[{
	"status":"1",
	"name":"<?php echo $row['NAME']; ?>",
	"surname":"<?php echo $row['SURNAME']; ?>",
	"birthdate":"<?php echo $row['BIRTH_DATE']; ?>",
	"identityno":"<?php echo $row['IDENTITY_NO']; ?>",
	"passportno":"<?php echo $row['PASSPORT_NO']; ?>",
	"phone":"<?php echo $row['PHONE']; ?>",
	"mail":"<?php echo $row['EMAIL']; ?>",
	"positionid":"<?php echo $row['P_ID']; ?>",
	"positionname":"<?php echo $row['P_NAME']; ?>",
	"departmentid":"<?php echo $row['D_ID']; ?>",
	"departmentname":"<?php echo $row['D_NAME']; ?>",
	"locationid":"<?php echo $row['L_ID']; ?>",
	"locationname":"<?php echo $row['L_NAME']; ?>"
}],"TableName":"Table","Columns":{
	"0":"status",
	"1":"name",
	"2":"surname",
	"3":"birthdate",
	"4":"identityno",
	"5":"passportno",
	"6":"phone",	
	"7":"mail",
	"8":"positionid",
	"9":"positionname",
	"10":"departmentid",
	"11":"departmentname",
	"12":"locationid",
	"13":"locationname"
}}
<?php
		} else {
?>
{"Rows":[{
	"status":"0"
}],"TableName":"Table","Columns":{
	"0":"status"
}}
<?php
		}
	}
?>