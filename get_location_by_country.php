<?php
	require("./library.php");

	$country_id = $_GET['country_id'];

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT LOC.ID, LOC.NAME
								 FROM COUNTRY CTR
								 JOIN CITY CTY ON CTY.COUNTRY_ID = CTR.ID
								 JOIN COUNTY CNT ON CNT.CITY_ID = CTY.ID
								 JOIN LOCATION LOC ON LOC.COUNTY_ID = CNT.ID
								 WHERE CTR.ID = :country_id ");

		$stmt->bindParam(':country_id', $country_id, PDO::PARAM_INT);
		$stmt->execute();
		$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
{"Rows":[
<?php
		$comma = "";
		foreach ($rows as $row) {
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