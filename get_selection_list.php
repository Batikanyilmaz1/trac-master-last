<?php
	require("./library.php");

	$table_name = $_GET['table_name'];
	$field_name = (($_GET['field_name'] ?? '') !== '') ? $_GET['field_name'] : "NAME";
	$where = (($_GET['where'] ?? '') !== '') ? $_GET['where'] : "1";
	$order = (($_GET['order'] ?? '') !== '') ? $_GET['order'] : $field_name;

	$conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT ID, $field_name AS NAME
								 FROM $table_name 
								 WHERE $where
								 ORDER BY $order ");

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