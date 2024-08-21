<?php
	require("./library.php");

	$list_type = $_GET['list_type'] ?? '1';
	$status = $_GET['status'] ?? '0';
?>
<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=750">

    <title>Ulaşım ve Konaklama - Talep Listesi</title>

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

            $(window).on('resize', function(event) {
                $('#div_main_area').css('margin-left', ($(window).width() - $('#div_main_area').width()) / 2);
            });

            set_status();
        });

        function gototop() {
            $('html, body').animate({ scrollTop: 1 }, 'slow');
        }

        function toggle(direction) {
            if(direction == 'expand') {
                $('div[id*="div_request_"]').slideDown('slow');
            } else if(direction == 'collapse') {
                $('div[id*="div_request_"]').slideUp('slow');
            }
            gototop();
        }

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

        function set_status(status_id = $('#sel_status').val(), start_date = $('#inp_start_date').val(), end_date = $('#inp_end_date').val()) {
            if(status_id != '') {
                $('#div_requests').load('./get_request_list.php?list_type=' + <?php echo $list_type; ?> + '&status_id=' + status_id + '&start_date=' + start_date + '&end_date=' + end_date);
            }
        }

        function slide_request(item1, item2) {
            item1.slideToggle('slow');
            item2.slideToggle('slow');
            $('html, body').animate({ scrollTop: item2.parent().offset().top }, 'slow');
        }

        function toggle_reservation_detail(item) {
            var index = item.attr('index');

            if(item.attr('value').indexOf('Göster') > -1) {
                item.attr('value', item.attr('value').replace('Göster', 'Gizle'));
                item.attr('class', 'btn_aquamarine');
                if($('#div_reservation_detail_' + index).html() == '') {
                    $('#div_reservation_detail_' + index).load('./get_reservation.php?reservation_id=' + item.attr('reservationid'),
                        function(response, status, xhr) {
                            if (status == "success") {
                                $('#div_reservation_detail_' + index).slideToggle('slow');
                            } else {
                                console.log("An error occurred: " + xhr.status + " " + xhr.statusText);
                            }
                        }
                    );
                } else {
                    $('#div_reservation_detail_' + index).slideToggle('slow');
                }
            } else if(item.attr('value').indexOf('Gizle') > -1) {
                item.attr('value', item.attr('value').replace('Gizle', 'Göster'));
                item.attr('class', 'btn_blue');
                $('#div_reservation_detail_' + index).slideToggle('slow');
            }

            $('html, body').animate({ scrollTop: $('#div_row_frame_' + index).offset().top }, 'slow');
        }

        function open_manager_process(item, link, process) {
            var item1 = $('#div_approval_buttons_' + item.attr('index'));
            var item2 = $('#div_manager_process_' + item.attr('index'));
            var requestid = item.attr('requestid');

            item2.load('./decide_request.php?link=' + link + '&process=' + process + '&way=internal&index=' + item.attr('index') + '&requestid=' + requestid);
            item1.slideUp('slow');
            item2.slideDown('slow');
            $('html, body').animate({ scrollTop: item1.parent().parent().parent().offset().top }, 'slow');
        }

        function close_manager_process(item) {
            var item1 = $('#div_approval_buttons_' + item.attr('index'));
            var item2 = $('#div_manager_process_' + item.attr('index'));

            item1.slideDown('slow');
            item2.slideUp('slow');
            $('html, body').animate({ scrollTop: item1.parent().parent().parent().offset().top }, 'slow');
        }

        function approve_request(item) {
            if(check_form(item)) {
                var index = item.attr('index');
                var form = item.closest('form');
                var formData = form.serialize();

                $.getJSON('./approve_request.php?' + formData,
                    function(data) {
                        if(data.Rows) {
                            var rowData = data.Rows[0];
                            if(rowData.status == '1') {
                                toggle_visibility([$('#div_completion_page' + index)], [$('#div_form_page' + index)]);
                            } else {
                                alert('İşlem sırasında bir hata oluştu!\nKayıt daha önce işleme alınmış olabilir.');
                            }
                        }
                    }
                );
            }
        }

        function reject_request(item) {
            if(check_form(item)) {
                var requestid = item.attr('requestid');

                if(confirm('"' + requestid + '" numaralı talep reddedilecek.\nDevam etmek istiyor musunuz?')) {
                    var index = item.attr('index');
                    var form = item.closest('form');
                    var formData = form.serialize();

                    $.getJSON('./reject_request.php?' + formData,
                        function(data) {
                            if(data.Rows) {
                                var rowData = data.Rows[0];
                                if(rowData.status == '1') {
                                    toggle_visibility([$('#div_completion_page' + index)], [$('#div_form_page' + index)]);
                                } else {
                                    alert('İşlem sırasında bir hata oluştu!\nKayıt daha önce işleme alınmış olabilir.');
                                }
                            }
                        }
                    );
                }
            }
        }

        function revise_request(item) {
            if(check_form(item)) {
                var requestid = item.attr('requestid');

                if(confirm('"' + requestid + '" numaralı talep için revizyon istenecek.\nDevam etmek istiyor musunuz?')) {
                    var index = item.attr('index');
                    var form = item.closest('form');
                    var formData = form.serialize();

                    $.getJSON('./revise_request.php?' + formData,
                        function(data) {
                            if(data.Rows) {
                                var rowData = data.Rows[0];
                                if(rowData.status == '1') {
                                    toggle_visibility([$('#div_completion_page' + index)], [$('#div_form_page' + index)]);
                                } else {
                                    alert('İşlem sırasında bir hata oluştu!\nKayıt daha önce işleme alınmış olabilir.');
                                }
                            }
                        }
                    );
                }
            }
        }

        function cancel_request(item) {
            if(check_form(item)) {
                var requestid = item.attr('requestid');

                if(confirm('"' + requestid + '" numaralı talep iptal edilecek.\nDevam etmek istiyor musunuz?')) {
                    var index = item.attr('index');
                    var form = item.closest('form');
                    var formData = form.serialize();

                    $.getJSON('./cancel_request.php?' + formData,
                        function(data) {
                            if(data.Rows) {
                                var rowData = data.Rows[0];
                                if(rowData.status == '1') {
                                    toggle_visibility([$('#div_completion_page' + index)], [$('#div_form_page' + index)]);

                                    setTimeout(function() {
                                        $('#div_request_top_' + index).slideUp('slow');
                                        $('#div_request_' + index).slideUp('slow',
                                            function() {
                                                alert('"' + requestid + '" numaralı talep iptal edildi.');
                                                $('#div_row_frame_' + index).hide();
                                            }
                                        );

                                        $('html, body').animate({ scrollTop: $('#div_row_frame_' + index).offset().top }, 'slow');
                                    }, 1000);
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
    <div style="position: fixed; display: flex; justify-content: right; width: 490px; height: 30px; top: 17px; left: 50vw;">
        <div style="width: 30px;">
            <div id="div_up_slider1" class="remote_button_up" title="Sayfa Başına Git" onClick="gototop();"></div>
            <div id="div_up_slider2" class="remote_button_expand" title="Genişlet" onClick="toggle('expand');"></div>
            <div id="div_up_slider3" class="remote_button_collapse" title="Daralt" onClick="toggle('collapse');"></div>
        </div>
    </div>
    <div id="div_main_area" hidden>
        <div id="div_main_frame" class="main_frame">
            <div style="height: 40px;"></div>
            <div class="heading">ULAŞIM ve KONAKLAMA TALEP LİSTESİ</div>
            <div style="height: 15px;"></div>
            <div style="display: flex;">
                <div align="left" style="width:50%;">
                    <div style="display: flex; width: 90%; height: 38px;">
                        <div style="width: 35%;">
                            <div id="div_lbl0" class="lbl_norm1" alert="lbl_alrt1">Başlangıç:</div>
                        </div>
                        <div style="width: 65%;">
                            <input type="date" id="inp_start_date" name="inp_start_date" class="inp" value="<?php echo date('Y-m-d', mktime(0, 0, 0, date('m'), date('d') - 6, date('Y')));; ?>" onChange="set_status();" />
                        </div>
                    </div>
                    <div style="display: flex; width: 90%; height: 38px;">
                        <div style="width: 35%;">
                            <div id="div_lbl0" class="lbl_norm1" alert="lbl_alrt1">Bitiş:</div>
                        </div>
                        <div style="width: 65%;">
                            <input type="date" id="inp_end_date" name="inp_end_date" class="inp" value="<?php echo date('Y-m-d', mktime(0, 0, 0, date('m'), date('d'), date('Y')));; ?>" onChange="set_status();" />
                        </div>
                    </div>
                </div>
                <div align="right" style="width:50%;">
                    <div style="display: flex; width: 90%; height: 38px;">
                        <div style="width: 35%;">
                            <div align="left" id="div_lbl0" class="lbl_norm1" alert="lbl_alrt1">Talep Durumu:</div>
                        </div>
                        <div style="width: 65%;">
                            <select id="sel_status" name="sel_status" label="div_lbl0" area="area1" action="go" class="inp" onChange="set_status();">
                                <option value="">-- Seçiniz --</option>
                                <option value="0" <?php if($status == '0') { echo 'selected'; } ?>>Tümü</option>
                                <option value="11" <?php if($status == '11') { echo 'selected'; } ?>>Onay Bekliyor</option>
                                <option value="12" <?php if($status == '12') { echo 'selected'; } ?>>Onaylandı</option>
                                <option value="13" <?php if($status == '13') { echo 'selected'; } ?>>Rezervasyon Bekliyor</option>
                                <option value="14" <?php if($status == '14') { echo 'selected'; } ?>>Rezervasyon Yapıldı</option>
                                <option value="15" <?php if($status == '15') { echo 'selected'; } ?>>Revize Talep Edildi</option>
                                <option value="16" <?php if($status == '16') { echo 'selected'; } ?>>Reddedildi</option>
                                <option value="17" <?php if($status == '17') { echo 'selected'; } ?>>İptal Edildi</option>
                            </select>
                        </div>
                    </div>
                    <div style="display: flex; width: 90%; height: 38px;">
                        <div style="width: 49%;"><input type="button" class="inp" value="Genişlet" onClick="toggle('expand');" /></div>
                        <div style="width: 2%;"></div>
                        <div style="width: 49%;"><input type="button" class="inp" value="Daralt" onClick="toggle('collapse');" /></div>
                    </div>
                </div>
            </div>
            <div style="height: 15px;"></div>
        </div>
        <div style="height: 5px;"></div>
        <div id="div_requests"></div>
    </div>
</body>
<script type="text/javascript">
    window.onload = function() {
        $('#div_main_area').css('margin-left', ($(window).width() - $('#div_main_area').width()) / 2);
        $('#div_main_area').show();
    };
</script>
</html>