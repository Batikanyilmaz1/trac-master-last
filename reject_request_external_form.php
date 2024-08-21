<?php
	require("./library.php");

	$link = $_GET['link'] ?? false;

	if(strlen($link) == 110) {
		$user_uuid = substr($link, 0, 36);
		$request_uuid = substr($link, 37, 36);
		$request_approver_detail_uuid = substr($link, 74, 36);
	} else {
		header('Location: login.php');
		exit;
	}

    $conn = get_mysql_connection();

	if($conn) {
		$stmt = $conn->prepare(" SELECT ID
								 FROM REQUEST
								 WHERE UUID = :request_uuid ");

		$stmt->bindParam(':request_uuid', $request_uuid, PDO::PARAM_STR);
		$stmt->execute();
		$request = $stmt->fetch(PDO::FETCH_ASSOC);
		$stmt->closeCursor();
		$conn = null;

        $requestid = $request['ID'];
    }
?>
<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=750">

    <title>Ulaşım ve Konaklama - Talep Ret Formu</title>

    <link rel="stylesheet" type="text/css" href="./css/main.css" />
    <link rel="stylesheet" type="text/css" href="./css/jquery-ui-1.13.3.css" />
    <link rel="stylesheet" type="text/css" href="./css/easy-loading.css" />

    <script src="./js/jquery-3.7.1.js"></script>
    <script src="./js/jquery-ui-1.13.3.js"></script>

    <script src="./js/jquery.inputmask.min.js"></script>
    <script src="./js/inputmask.binding.js"></script>

    <script type="text/javascript">

        var xmlFile = './xml/alert.xml';
        var xmlDoc = '';

        $.ajax({
            type: "GET",
            url: xmlFile,
            dataType: "xml",
            success: function(xmlText) {
                xmlDoc = $(xmlText);
            },
            error: function(xhr, status, error) {
                alert("XML dosyası okunamadı: " + error);
            }
        });

        $(document).ready(function() {

            $(window).on('resize', function() {
                $('#div_main_area').css('margin-left', ($(window).width() - $('#div_main_area').width()) / 2);
            });
        });

        function toggle_visibility(visible_items, unvisible_items) {
            $.each(unvisible_items, function() { $(this).hide(); });
            $.each(visible_items, function() { $(this).show(); });
        }

        function reset_alerts() {
            $('[class=lbl_alrt1]').attr('class', 'lbl_norm1');
            $('[class=lbl_alrt2]').attr('class', 'lbl_norm2');
        }

        function visibility(item) {
            if(item.is(':visible')) {
                if(item.parent().prop('tagName') != 'HTML') {
                    return visibility(item.parent());
                } else {
                    return true;
                }
            } else {
                return false;
            }
        }

        function check_form(item) {
            reset_alerts();

            var result = true;
            var index = (item.attr('index') !== undefined) ? item.attr('index') : '';
            var area = item.attr('area');
            var action = item.attr('action');
            var xmlNodes = $.merge(xmlDoc.find('input[id="' + item.attr('id') + '"]'), xmlDoc.find(area).children());

            xmlNodes.each(
                function() {
                    if(visibility($('#' + $(this).attr('id') + index))) {
                        if(eval($(this).children('condition').text().replace($(this).attr('id'), $(this).attr('id') + index))) {
                            var label_item = $('#' + $('#' + $(this).attr('id') + index).attr('label'));
                            var label_text = label_item.html().substring(0, label_item.html().indexOf(':'));
                            var alert_text = $(this).children('alert').text().replace('""', '"' + label_text + '"');
                            if(action == 'warn') {
                                alert(alert_text);
                                label_item.attr('class', label_item.attr('alert'));
                            } else if($(this).children('forced_alert').text() == '1') {
                                alert(alert_text);
                            }
                            if($(this).attr('id') != item.attr('id')) {
                                $('#' + $(this).attr('id') + index).focus();
                            }
                            result = false;
                            return result;
                        }
                    }
                }
            );
            if(result) {
                $('#' + $(xmlDoc.find(area)).attr('focus') + index).focus();
            }
            return result;
        }

        function reject_request(item) {
            if(check_form(item)) {
                var requestid = item.attr('requestid');

                if(confirm('"' + requestid + '" numaralı talep reddedilecek.\nDevam etmek istiyor musunuz?')) {
                    var formData = $('#form1').serialize();

                    $.getJSON('./reject_request.php?' + formData,
                        function(data) {
                            if(data.Rows) {
                                var rowData = data.Rows[0];
                                if(rowData.status == '1') {
                                    toggle_visibility([$('#div_completion_page')], [$('#div_form_page')]);
                                } else {
                                    alert('İşlem sırasında bir hata oluştu!\nKayıt daha önce işleme alınmış olabilir.');
                                }
                            }
                        }
                    );
                }
            }
        }

    </script>
</head>
<body>
    <div id="div_main_area">
        <div id="div_main_frame" class="main_frame">
            <div style="height: 40px;"></div>
            <div class="heading">ULAŞIM ve KONAKLAMA TALEBİ RET FORMU</div>
            <div style="height: 40px;"></div>
            <div id="div_form_page" align="center">
                <form id="form1" method="post" enctype="multipart/form-data" action="">
                    <div hidden>
                        <input type="hidden" id="inp_user_uuid" name="inp_user_uuid" value="<?php echo $user_uuid; ?>" />
                        <input type="hidden" id="inp_request_uuid" name="inp_request_uuid" value="<?php echo $request_uuid; ?>" />
                        <input type="hidden" id="inp_request_approver_detail_uuid" name="inp_request_approver_detail_uuid" value="<?php echo $request_approver_detail_uuid; ?>" />
                    </div>
                    <div align="left" style="height: 116px;">
                        <div id="div_lbl" class="lbl_norm2" alert="lbl_alrt2">Açıklama:</div>
                        <div><textarea id="txt_explanation" name="txt_explanation" label="div_lbl" area="area5" action="go" class="inp" style="height: 88px;" placeholder="Ret nedenini yazınız"></textarea></div>
                    </div>
                    <div align="right">
                        <div style="display: flex; width: 195px;">
                            <div>
                                <input type="button" id="btn_close" class="btn_red" value="İptal ✖" onClick="window.close();" />
                            </div>
                            <div style="width: 15px;"></div>
                            <div>
                                <input type="button" id="btn_ok" requestid="<?php echo $requestid; ?>" area="area5" action="warn" class="btn_green" value="Tamam ✔" onClick="reject_request($(this));" />
                            </div>
                        </div>
                    </div>
                </form>		
            </div>
            <div id="div_completion_page" align="center" hidden>
                <div><img src="images/ok.png" width="50" /></div>
                <div style="height: 20px;"></div>
                <div>Ulaşım ve Konaklama Talebi reddedildi.</div>
                <div style="height: 20px;"></div>
                <div align="center">
                    <div style="display: flex; width: 90px;">
                        <div>
                            <input type="button" id="btn_close" class="btn" value="Kapat ☒" onClick="window.close();" />
                        </div>
                    </div>
                </div>
            </div>
            <div style="height: 40px;"></div>
        </div>
    </div>
</body>
<script type="text/javascript">
    window.onload = function() {
        $('#div_main_area').css('margin-left', ($(window).width() - $('#div_main_area').width()) / 2);
        $('#div_main_area').show();
    };
</script>
</html>