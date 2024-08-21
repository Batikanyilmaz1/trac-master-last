<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=750">

    <title>Html Mail Formatı ve Alıcı Listesi Test Ekranı</title>

    <link rel="stylesheet" type="text/css" href="./css/main.css" />
    <link rel="stylesheet" type="text/css" href="./css/jquery-ui-1.13.3.css" />
    <link rel="stylesheet" type="text/css" href="./css/easy-loading.css" />

    <script src="./js/jquery-3.7.1.js"></script>
    <script src="./js/jquery-ui-1.13.3.js"></script>

    <script src="./js/jquery.inputmask.min.js"></script>
    <script src="./js/inputmask.binding.js"></script>

    <script type="text/javascript">

        function set_mail_type() {
            if($('#sel_mail_type').val() == '1') {
                $('#div_request').show();
                $('#div_reservation').hide();
            } else if($('#sel_mail_type').val() == '2') {
                $('#div_request').hide();
                $('#div_reservation').show();
            }
        }

        function check_form() {
            if($('#sel_mail_type').val() == '1' && $('#inp_request_id').val() == '') {
                alert('Talep Numarasını Giriniz');
                $('#inp_request_id').focus();
                return false;
            } else if($('#sel_mail_type').val() == '2' && $('#inp_reservation_id').val() == '') {
                alert('Rezervasyon Numarasını Giriniz');
                $('#inp_reservation_id').focus();
                return false;
            } else {
                return true;
            }
        }

        function get_recipient_list() {
            if(!check_form()) {
                return false;
            }

            if($('#sel_mail_type').val() == '1') {
                var filePath = './get_mail_recipient_list.php?type=1&request_id=' + $('#inp_request_id').val();
            } else if($('#sel_mail_type').val() == '2') {
                var filePath = './get_mail_recipient_list.php?type=2&reservation_id=' + $('#inp_reservation_id').val();
            }

            $('#div_recipient_list_container').hide();
            $('#div_recipient_list').html('');

            $.getJSON(filePath,
                function(data) {
                    if(data.Rows.length > 0) {
                        for(var i = 0; i < data.Rows.length; i++) {
                            var rowData = data.Rows[i];
                            $('#div_recipient_list').html($('#div_recipient_list').html() + '<b>' + (i + 1) + '. ' + rowData.name + ' : </b> ' + rowData.mail + '<br />');
                        }
                    } else {
                        $('#div_recipient_list').html('Kayıt bulunamadı!');
                    }
                }
            ).done(
                function() {
                    $('#div_recipient_list_container').slideDown('slow');
                }
            );
        }

        function get_mail_content() {
            if(!check_form()) {
                return false;
            }

            if($('#sel_mail_type').val() == '1') {
                var filePath = './request_view.php?list_type=2&mail_view=1&request_id=' + $('#inp_request_id').val();
            } else if($('#sel_mail_type').val() == '2') {
                var filePath = './reservation_view.php?list_type=3&mail_view=1&reservation_id=' + $('#inp_reservation_id').val();
            }

            $.ajax({
                url: filePath, // HTML almak istediğiniz sayfanın URL'si
                method: 'GET',
                dataType: 'html',
                success: function(data) {
                    // HTML içeriği burada 'data' değişkeninde
                    var outerHTML = data;
                    console.log(outerHTML);
                    $('#div_mail_content_container').hide();
                    $('#div_mail_content').html(outerHTML);
                    $('#div_mail_content_container').slideDown('slow');
                },
                error: function(xhr, status, error) {
                    console.log('Bir hata oluştu.');
                    console.log(error);
                }
            });
        }

    </script>
</head>
<body style="margin-left: 20px;">
    <div id="div_main_area">
        <div id="div_main_frame" class="main_frame">
            <div style="height: 20px;"></div>
            <div class="heading">HTML MAIL FORMATI ve ALICI LİSTESİ TEST EKRANI</div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div class="lbl_norm1" style="width: 70px;">Mail Tipi:</div>
                <div>
                    <select id="sel_mail_type" class="inp" style="width: 120px;" onChange="set_mail_type();">
                        <option value="">-- Seçiniz --</option>
                        <option value="1">Talep</option>
                        <option value="2">Rezervasyon</option>
                    </select>
                </div>
                <div style="width: 50px;"></div>
                <div id="div_request" hidden>
                    <div style="display: flex;">
                        <div class="lbl_norm1" style="width: 110px;">Talep Numarası:</div>
                        <div>
                            <input type="text" id="inp_request_id" class="inp" style="width: 90px;" />
                        </div>
                        <div style="width: 15px;"></div>
                        <div>
                            <input type="button" class="btn_blue" value="Alıcı Listesi" onClick="get_recipient_list();" />
                        </div>
                        <div style="width: 15px;"></div>
                        <div>
                            <input type="button" class="btn_blue" value="Mail İçeriği" onClick="get_mail_content();" />
                        </div>
                    </div>
                </div>
                <div id="div_reservation" hidden>
                    <div style="display: flex;">
                        <div class="lbl_norm1" style="width: 155px;">Rezervasyon Numarası:</div>
                        <div>
                            <input type="text" id="inp_reservation_id" class="inp" style="width: 90px;" />
                        </div>
                        <div style="width: 15px;"></div>
                        <div>
                            <input type="button" class="btn_blue" value="Alıcı Listesi" onClick="get_recipient_list();" />
                        </div>
                        <div style="width: 15px;"></div>
                        <div>
                            <input type="button" class="btn_blue" value="Mail İçeriği" onClick="get_mail_content();" />
                        </div>
                    </div>
                </div>
            </div>
            <div style="height: 20px;"></div>
        </div>
    </div>
    <div id="div_recipient_list_container" hidden>
        <div style="height: 15px;"></div>
        <div class="main_frame" style="width: 710px;">
            <div style="height: 20px;"></div>
            <div id="div_recipient_list"></div>
            <div style="height: 20px;"></div>
        </div>
    </div>
    <div id="div_mail_content_container" hidden>
        <div id="div_mail_content"></div>
    </div>
</body>
</html>