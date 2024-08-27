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
<link rel="stylesheet" type="text/css" href="./css/main.css" /> <!--new -->
	<div id="div_form_page<?php echo $index; ?>" align="center">
		<div hidden>
			<input type="hidden" id="inp_user_uuid" name="inp_user_uuid" value="<?php echo $user_uuid; ?>" />
			<input type="hidden" id="inp_request_uuid" name="inp_request_uuid" value="<?php echo $request_uuid; ?>" />
			<input type="hidden" id="inp_request_approver_detail_uuid" name="inp_request_approver_detail_uuid" value="<?php echo $request_approver_detail_uuid; ?>" />
		</div>
		<div align="left" style="height: 116px;">
			<div id="div_lbl<?php echo $index; ?>" class="lbl_norm2" alert="lbl_alrt2">Açıklama:</div>
			<div><textarea id="txt_explanation<?php echo $index; ?>" name="txt_explanation" label="div_lbl<?php echo $index; ?>" area="area6" action="go" class="inp" style="height: 88px;" placeholder="İptal nedenini yazınız"></textarea></div>
		</div>
		<div align="right">
			<div style="display: flex; width: 195px;">
				<div>
					<input type="button" id="btn_close<?php echo $index; ?>" index="<?php echo $index; ?>" class="btn_red" value="Geri ⮝" onClick="close_manager_process($(this));" />
				</div>
				<div style="width: 15px;"></div>
				<div>
					<input type="button" id="btn_ok<?php echo $index; ?>" index="<?php echo $index; ?>" requestid="<?php echo $requestid; ?>" area="area6" action="warn" class="btn_green" value="Tamam ✔" onClick="cancel_request($(this));" />
				</div>
			</div>
		</div>
	</div>
	<div id="div_completion_page<?php echo $index; ?>" align="center" hidden>
		<div style="height: 5px;"></div>
		<div style="border: solid 1px rgb(0, 0, 0); border-radius: 2px; background-color: #0d78ae97;">
			<div style="height: 20px;"></div>
			<div><img src="images/ok.png" width="50" /></div>
			<div style="height: 20px;"></div>
			<div>Ulaşım ve Konaklama Talebi iptal edildi.</div>
			<div style="height: 30px;"></div>
		</div>
	</div>