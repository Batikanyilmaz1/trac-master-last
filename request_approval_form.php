<?php
	require("./library.php");

	$request = $_SESSION['display']['request'];
	$travelers = $_SESSION['display']['travelers'];
	$list_type = '0';
	$i = 0;
?>
    <div id="div_preview_page">
<?php
    include("./request_design.php");
?>

<link rel="stylesheet" type="text/css" href="./css/main.css" /> <!--new -->
        <div class="subheading" style="height: 12px;"></div>
        <div style="height: 10px;"></div>
        <div id="div_save_buttons" align="right">
            <div style="display: flex; width: 300px;">
                <div>
                    <input type="button" id="btn_cancel" class="btn_red" value="İptal ✖" onClick="cancel_request();" />
                </div>
                <div style="width: 15px;"></div>
                <div>
                    <input type="button" id="btn_edit" class="btn_yellow" value="Düzenle ✎" onClick="toggle_visibility([$('#div_form_page')], [$('#div_approve_page')]);" />
                </div>
                <div style="width: 15px;"></div>
                <div>
                    <input type="button" id="btn_approve" class="btn_green" value="Onayla ✔" onClick="save_request();" />
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
            <div>Ulaşım ve Konaklama Talebi oluşturuldu.</div>
            <div style="height: 20px;"></div>
            <div style="display: flex; width: 90px;">
                <div>
                    <input type="button" id="btn_ok" class="btn_green" value="Tamam ✔" onClick="window.open('./request_entry_form.php', '_self');" />
                </div>
            </div>
        </div>
        <div style="height: 40px;"></div>
    </div>
