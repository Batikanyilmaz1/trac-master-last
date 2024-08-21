<?php
	require("./library.php");

	$user_info = $_SESSION['user_info'];
	$name = $user_info['name'];
	$surname = $user_info['surname'];
	$mail = $user_info['mail'];
	$position = $user_info['position'];
	$department = $user_info['department'];
	$location = $user_info['location'];
?>
{"Rows":[{
	"name":"<?php echo $name; ?>",
	"surname":"<?php echo $surname; ?>",
	"mail":"<?php echo $mail; ?>",
	"position":"<?php echo $position; ?>",
	"department":"<?php echo $department; ?>",
	"location":"<?php echo $location; ?>"
}],"TableName":"Table","Columns":{
	"0":"name",
	"1":"surname",
	"2":"mail",
	"3":"position",
	"4":"department",
	"5":"location"
}}