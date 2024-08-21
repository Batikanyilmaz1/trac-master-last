<?php
	require("./library.php");

	$ldapUser = $_SESSION['username'];		// Active Directory kullanıcı adı
	$ldapPassword = $_SESSION['password'];	// Active Directory kullanıcı şifresi
	$filter = "sAMAccountName=" . resolve_account_name($_GET['mail']);

	$traveler_info = get_ldap_information($ldapUser, $ldapPassword, $filter);

	if($traveler_info) {
?>
{"Rows":[{
	"status":"1",
	"name":"<?php echo $traveler_info['name']; ?>",
	"surname":"<?php echo $traveler_info['surname']; ?>",
	"mail":"<?php echo $traveler_info['mail']; ?>",
	"positionname":"<?php echo $traveler_info['position']; ?>",
	"departmentname":"<?php echo $traveler_info['department']; ?>",
	"locationname":"<?php echo $traveler_info['location']; ?>"
}],"TableName":"Table","Columns":{
	"0":"status",
	"1":"name",
	"2":"surname",
	"3":"mail",
	"4":"positionname",
	"5":"departmentname",
	"6":"locationname"
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
?>