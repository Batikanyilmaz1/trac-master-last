<?php
	require("./library.php");

	$location_id = $_GET['location_id'];

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT CTY.ID, CTY.NAME
								 FROM CITY CTY
								 JOIN COUNTY CNT ON CNT.CITY_ID = CTY.ID
								 JOIN LOCATION LOC ON LOC.COUNTY_ID = CNT.ID
								 WHERE LOC.ID = :location_id ");

		$stmt->bindParam(':location_id', $location_id, PDO::PARAM_INT);
		$stmt->execute();
		$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
{"Rows":[
<?php
		$comma = "";
		foreach($rows as $row) {
			echo $comma;
?>
{"id":"<?php echo $row['ID']; ?>","name":"<?php echo trim($row['NAME']); ?>"}
<?php
			$comma = ",";
		}
		$stmt->closeCursor();
		$conn = null;
?>
],"TableName":"Table","Columns":{"0":"id","1":"name"}}
<?php
	}
?>