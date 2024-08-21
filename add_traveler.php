<?php
	require("./library.php");

	$status = '1';

	if(isset($_SESSION['request']['traveler_list'])) {
		if(isset($_SESSION['request']['traveler_list'][$_GET['inp_uuid']])) {
			$status = '2';
		} else {
			foreach($_SESSION['request']['traveler_list'] as $uuid => $traveler) {
				if($_GET['inp_uuid'] != $uuid && $_GET['inp_identityno'] != '' && $_GET['inp_identityno'] == $traveler['identityno']) {
					$status = '0';
					goto record_found;
				}
				if($_GET['inp_uuid'] != $uuid && $_GET['inp_passportno'] != '' && $_GET['inp_passportno'] == $traveler['passportno']) {
					$status = '0';
					goto record_found;
				}
			}
		}
	}

	unset($traveler);

	$uuid = $_GET['inp_uuid'];
	$requester_type = $_GET['sel_requester_type'];

	if($requester_type < 3) {
		$traveler_type = 1;
		$traveler_type_name = 'Personel';
	} else if($requester_type == 3) {
		$traveler_type = 2;
		$traveler_type_name = 'Misafir';
	}

	$traveler['typeid'] = $traveler_type;
	$traveler['typename'] = $traveler_type_name;
	$traveler['name'] = $_GET['inp_name'];
	$traveler['surname'] = $_GET['inp_surname'];
	$traveler['birthdate'] = $_GET['inp_birthdate'];
	$traveler['identityno'] = set_null($_GET['inp_identityno'] ?? '');
	$traveler['passportno'] = set_null($_GET['inp_passportno'] ?? '');
	$traveler['phone'] = $_GET['inp_phone'];
	$traveler['mail'] = $_GET['inp_mail'];
	$traveler['position'] = set_null($_GET['inp_position'] ?? '');
	$traveler['positionid'] = set_null($_GET['sel_position'] ?? '');
	$traveler['department'] = set_null($_GET['inp_department'] ?? '');
	$traveler['departmentid'] = set_null($_GET['sel_department'] ?? '');
	$traveler['location'] = set_null($_GET['inp_location'] ?? '');
	$traveler['locationid'] = set_null($_GET['sel_location'] ?? '');

	$_SESSION['request']['uuid'] = '';
	$_SESSION['request']['request_date'] = date('d.m.Y H:i:s');
	$_SESSION['request']['approver']['uuid'] = '';
	$_SESSION['request']['traveler_list'][$uuid] = $traveler;

record_found:
?>
{"Rows":[{
	"status":"<?php echo $status; ?>",
	"name":"<?php echo $traveler['name']; ?>",
	"surname":"<?php echo $traveler['surname']; ?>",
	"birthdate":"<?php echo date('d.m.Y', strtotime($traveler['birthdate'])); ?>",
	"identityno":"<?php echo $traveler['identityno']; ?>",
	"passportno":"<?php echo $traveler['passportno']; ?>",
	"phone":"<?php echo $traveler['phone']; ?>",
	"mail":"<?php echo $traveler['mail']; ?>",
	"position":"<?php echo $traveler['position']; ?>",
	"positionid":"<?php echo $traveler['positionid']; ?>",
	"department":"<?php echo $traveler['department']; ?>",
	"departmentid":"<?php echo $traveler['departmentid']; ?>",
	"location":"<?php echo $traveler['location']; ?>",
	"locationid":"<?php echo $traveler['locationid']; ?>"
}],"TableName":"Table",
"Columns":{
	"0":"status",
	"1":"name",
	"2":"surname",
	"3":"birthdate",
	"4":"identityno",
	"5":"passportno",
	"6":"phone",
	"7":"mail",
	"8":"position",
	"9":"positionid",
	"10":"department",
	"11":"departmentid",
	"12":"location",
	"13":"locationid"
}}