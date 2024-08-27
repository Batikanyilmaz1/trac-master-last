<?php
	require("./library.php");

	$link = $_GET['link'] ?? false;
	$index = $_GET['index'] ?? '';
    $requestid = $_GET['requestid'] ?? '';

	if(strlen($link) == 110) {
		$user_uuid = substr($link, 0, 36);
		$request_uuid = substr($link, 37, 36);
		$request_approver_detail_uuid = substr($link, 74, 36);
	} else {
		header('Location: login.php');
		exit;
	}
?>
	<div id="div_form_page<?php echo $index; ?>" align="center">
		<div hidden>
			<input type="hidden" id="inp_user_uuid" name="inp_user_uuid" value="<?php echo $user_uuid; ?>" />
			<input type="hidden" id="inp_request_uuid" name="inp_request_uuid" value="<?php echo $request_uuid; ?>" />
			<input type="hidden" id="inp_request_approver_detail_uuid" name="inp_request_approver_detail_uuid" value="<?php echo $request_approver_detail_uuid; ?>" />
		</div>
		<div align="center" style="height: 116px;">
			<div style="height: 5px;"></div>
			<div style="height: 103px; border: solid 1px rgb(0, 0, 0); border-radius: 2px; background-color: #0d78ae97;">
				<div style="height: 43px;"></div>
				<div style="height: 17px; font-weight: bold; font-size: larger; color: black;">"<?php echo $requestid; ?>" numaralı talebi onaylıyor musunuz?</div>
				<div style="height: 43px;"></div>
			</div>
		</div>
		<div align="right">
			<div style="display: flex; width: 195px;">
				<div>
					<input type="button" id="btn_close<?php echo $index; ?>" index="<?php echo $index; ?>" class="btn_red" value="Geri ⮝" onClick="close_manager_process($(this));" />
				</div>
				<div style="width: 15px;"></div>
				<div>
					<input type="button" id="btn_ok<?php echo $index; ?>" index="<?php echo $index; ?>" requestid="<?php echo $requestid; ?>" class="btn_green" value="Tamam ✔" onClick="approve_request($(this));" />
				</div>
			</div>
		</div>
	</div>

	</div>