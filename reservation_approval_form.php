<?php
	require("./library.php");

	$reservation = $_SESSION['display']['reservation'];
	$list_type = '0';
	$i = 0;
?>
    <div id="div_preview_page">
<?php
    include("./reservation_design.php");
?>
        <div class="subheading" style="height: 12px;"></div>
        <div style="height: 10px;"></div>
        <div id="div_save_buttons" align="right">
            <div style="display: flex; width: 300px;">
                <div>
                    <input type="button" id="btn_cancel" class="btn" value="İptal ✖" onClick="cancel_reservation();" />
                </div>
                <div style="width: 15px;"></div>
                <div>
                    <input type="button" id="btn_edit" class="btn" value="Düzenle ✎" onClick="toggle_visibility([$('#div_form_page')], [$('#div_approve_page')]);" />
                </div>
                <div style="width: 15px;"></div>
                <div>
                    <input type="button" id="btn_approve" class="btn" value="Onayla ✔" onClick="save_reservation();" />
                </div>
            </div>
        </div>
        <div style="height: 22px;"></div>
    </div>
    <div id="div_completion_page" hidden>
        <div align="center">
            <div style="height: 20px;"></div>
            <div><img src="images/ok.png" width="50" /></div>
            <div style="height: 20px;"></div>
            <div>Ulaşım ve Konaklama Rezervasyonu oluşturuldu.</div>
            <div style="height: 20px;"></div>
            <div style="display: flex; width: 90px;">
                <div>
                    <input type="button" id="btn_ok" class="btn" value="Tamam ✔" onClick="window.open('./reservation_entry_form.php', '_self');" />
                </div>
            </div>
        </div>
        <div style="height: 40px;"></div>
    </div>
