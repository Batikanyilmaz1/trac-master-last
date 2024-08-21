<?php
	require("./library.php");

	$transportation_mode_id = $_GET['transportation_mode_id'] ?? '0';

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT TC.ID, TC.NAME
								 FROM TRANSPORTATION_COMPANY TC
								 WHERE TC.TRANSPORTATION_MODE_ID = :transportation_mode_id
								 ORDER BY TC.NAME ");

		$stmt->bindParam(':transportation_mode_id', $transportation_mode_id, PDO::PARAM_INT);
		$stmt->execute();
		$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
{
	"TableName":"Table",
	"Columns":{"0":"name"},
	"Rows":[
<?php
		$comma = "";
		foreach($rows as $row) {
			echo $comma;
?>
		{"name":"<?php echo trim($row['NAME']); ?>"}
<?php
			$comma = ",";
		}
		$stmt->closeCursor();
		$conn = null;
?>
	]
}
<?php
	}
?>