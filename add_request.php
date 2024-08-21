<?php
	require("./library.php");

	if(authorized_person_id($_SESSION['userid'], $_GET['inp_route'])) {
		$travel['travel_routeid'] = $_GET['inp_route'];
		$travel['travel_route'] = $_GET['inp_route_name'];
		$travel['travel_reasonid'] = $_GET['sel_travel_reason'];
		$travel['travel_reason'] = $_GET['inp_travel_reason'];
		$travel['from_countryid'] = set_null($_GET['sel_from_country'] ?? '');
		$travel['from_country'] = $_GET['inp_from_country'];
		$travel['from_locationid'] = set_null($_GET['sel_from_location'] ?? '');
		$travel['from_location'] = $_GET['inp_from_location'];
		$travel['from_cityid'] = set_null($_GET['sel_from_city'] ?? '');
		$travel['from_city'] = set_null($_GET['inp_from_city'] ?? '');
		$travel['to_countryid'] = set_null($_GET['sel_to_country'] ?? '');
		$travel['to_country'] = $_GET['inp_to_country'];
		$travel['to_locationid'] = set_null($_GET['sel_to_location'] ?? '');
		$travel['to_location'] = $_GET['inp_to_location'];
		$travel['to_cityid'] = set_null($_GET['sel_to_city'] ?? '');
		$travel['to_city'] = set_null($_GET['inp_to_city'] ?? '');

		switch($_GET['rb_trac']) {
			case 1:
				$transportation_on_off = true;
				$accommodation_on_off = true;
				break;
			case 2:
				$transportation_on_off = true;
				$accommodation_on_off = false;
				break;
			case 3:
				$transportation_on_off = false;
				$accommodation_on_off = true;
				break;
		}

		if($transportation_on_off) {
			$transportation['departure_date'] = set_null($_GET['inp_departure_date'] ?? '');
			$transportation['return_date'] = set_null($_GET['inp_return_date'] ?? '');
			$transportation['transfer_need_situation'] = set_null($_GET['inp_transfer_need_situation'] ?? '');
			$transportation['transfer_need_situation_name'] = set_null($_GET['inp_transfer_need_situation_name'] ?? '');
			$transportation['transfer_need_detail'] = $transportation['transfer_need_situation'] ? set_null($_GET['inp_transfer_need_detail'] ?? '') : null;
			$transportation['transportation_modeid'] = set_null($_GET['sel_transportation_mode'] ?? '');
			$transportation['transportation_mode'] = set_null($_GET['inp_transportation_mode'] ?? '');
			$transportation['transportation_detail'] = set_null($_GET['txt_transportation_detail'] ?? '');
		} else {
			$transportation['departure_date'] = null;
			$transportation['return_date'] = null;
			$transportation['transfer_need_situation'] = null;
			$transportation['transfer_need_situation_name'] = null;
			$transportation['transfer_need_detail'] = null;
			$transportation['transportation_modeid'] = null;
			$transportation['transportation_mode'] = null;
			$transportation['transportation_detail'] = null;
		}

		if($accommodation_on_off) {
			$accommodation['check-in_date'] = set_null($_GET['inp_check-in_date'] ?? '');
			$accommodation['check-out_date'] = set_null($_GET['inp_check-out_date'] ?? '');
			$accommodation['accommodation_detail'] = set_null($_GET['txt_accommodation_detail'] ?? '');
		} else {
			$accommodation['check-in_date'] = null;
			$accommodation['check-out_date'] = null;
			$accommodation['accommodation_detail'] = null;
		}

		$_SESSION['request']['travel_info'] = $travel;
		$_SESSION['request']['transportation_on_off'] = $transportation_on_off;
		$_SESSION['request']['transportation_info'] = $transportation;
		$_SESSION['request']['accommodation_on_off'] = $accommodation_on_off;
		$_SESSION['request']['accommodation_info'] = $accommodation;

		$request['ID'] = '';
		$request['CREATION_TIME'] = $_SESSION['request']['request_date'];
		$request['USER'] = '';
		$request['STATUS'] = '';
		$request['ROUTE'] = $_SESSION['request']['travel_info']['travel_route'];
		$request['FROM_COUNTRY'] = $_SESSION['request']['travel_info']['from_country'];
		$request['FROM_CITY'] = $_SESSION['request']['travel_info']['from_city'];
		$request['FROM_LOCATION'] = $_SESSION['request']['travel_info']['from_location'];
		$request['TO_COUNTRY'] = $_SESSION['request']['travel_info']['to_country'];
		$request['TO_CITY'] = $_SESSION['request']['travel_info']['to_city'];
		$request['TO_LOCATION'] = $_SESSION['request']['travel_info']['to_location'];
		$request['REASON'] = $_SESSION['request']['travel_info']['travel_reason'];
		$request['TRANSPORTATION'] = $_SESSION['request']['transportation_on_off'];
		$request['DEPARTURE_DATE'] = $_SESSION['request']['transportation_info']['departure_date'];
		$request['RETURN_DATE'] = $_SESSION['request']['transportation_info']['return_date'];
		$request['TRANSPORTATION_MODE'] = $_SESSION['request']['transportation_info']['transportation_mode'];
		$request['TRANSPORTATION_DETAIL'] = $_SESSION['request']['transportation_info']['transportation_detail'];
		$request['TRANSFER_NEED_SITUATION'] = $_SESSION['request']['transportation_info']['transfer_need_situation_name'];
		$request['TRANSFER_NEED_DETAIL'] = $_SESSION['request']['transportation_info']['transfer_need_detail'];
		$request['ACCOMMODATION'] = $_SESSION['request']['accommodation_on_off'];
		$request['CHECK-IN_DATE'] = $_SESSION['request']['accommodation_info']['check-in_date'];
		$request['CHECK-OUT_DATE'] = $_SESSION['request']['accommodation_info']['check-out_date'];
		$request['ACCOMMODATION_DETAIL'] = $_SESSION['request']['accommodation_info']['accommodation_detail'];

		foreach($_SESSION['request']['traveler_list'] as $traveler_data) {
			$traveler['TYPE'] = $traveler_data['typename'];
			$traveler['NAME'] = $traveler_data['name'];
			$traveler['SURNAME'] = $traveler_data['surname'];
			$traveler['BIRTH_DATE'] = $traveler_data['birthdate'];
			$traveler['PHONE'] = $traveler_data['phone'];
			$traveler['EMAIL'] = $traveler_data['mail'];
			$travelers[] = $traveler;
		}

		$_SESSION['display']['request'] = $request;
		$_SESSION['display']['travelers'] = $travelers;

		$status = '1';
		$message = 'Kayıt oluşturuldu.';
	} else {
		$status = '0';
		$message = 'Talebi onaylayacak herhangi bir yetkili tanımlanmamış.';
	}
?>
{"Rows":[{
	"status":"<?php echo $status; ?>",
	"message":"<?php echo $message; ?>"
}],"TableName":"Table",
"Columns":{
	"0":"status",
	"1":"message"
}}