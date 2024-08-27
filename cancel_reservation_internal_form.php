,<?php
	require("./library.php");

	$index = $_GET['index'] ?? '';
    $reservationid = $_GET['reservationid'] ?? '';

	if(!$index || !$reservationid) {
		header('Location: login.php');
		exit;
	}
?>
	<div id="div_form_page<?php echo $index; ?>" align="center">
		<div hidden>
			<input type="hidden" id="inp_reservation_id" name="inp_reservation_id" value="<?php echo $reservationid; ?>" />
		</div>
		<div align="left" style="height: 116px;">
			<div id="div_lbl<?php echo $index; ?>" class="lbl_norm2" alert="lbl_alrt2">Açıklama:</div>
			<div><textarea id="txt_explanation<?php echo $index; ?>" name="txt_explanation" label="div_lbl<?php echo $index; ?>" area="area7" action="go" class="inp" style="height: 88px;" placeholder="İptal nedenini yazınız"></textarea></div>
		</div>
		<div align="right">
			<div style="display: flex; width: 195px;">
				<div>
					<input type="button" id="btn_close<?php echo $index; ?>" index="<?php echo $index; ?>" class="btn" value="Geri ⮝" onClick="close_manager_process($(this));" />
				</div>
				<div style="width: 15px;"></div>
				<div>
					<input type="button" id="btn_ok<?php echo $index; ?>" index="<?php echo $index; ?>" reservationid="<?php echo $reservationid; ?>" area="area7" action="warn" class="btn" value="Tamam ✔" onClick="cancel_reservation($(this));" />
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
			<div>Ulaşım ve Konaklama Rezervasyonu iptal edildi.</div>
			<div style="height: 30px;"></div>
		</div>
	</div>