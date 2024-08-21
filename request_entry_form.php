<?php
	require("./library.php");

	unset($_SESSION['request']);
?>
<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=750">

    <title>Ulaşım ve Konaklama - Başvuru Formu</title>

    <link rel="stylesheet" type="text/css" href="./css/main.css" />
    <link rel="stylesheet" type="text/css" href="./css/jquery-ui-1.13.3.css" />
    <link rel="stylesheet" type="text/css" href="./css/easy-loading.css" />

    <script src="./js/jquery-3.7.1.js"></script>
    <script src="./js/jquery-ui-1.13.3.js"></script>

    <script src="./js/jquery.inputmask.min.js"></script>
    <script src="./js/inputmask.binding.js"></script>

    <script type="text/javascript">

        var cssFile = './css/main.css';
        var cssDoc = '';
        var xmlFile = './xml/alert.xml';
        var xmlDoc = '';

        $.ajax({
            type: "GET",
            url: cssFile,
            dataType: "text",
            success: function(cssText) {
                cssDoc = cssText;
            },
            error: function(xhr, status, error) {
                alert("css dosyası okunamadı: " + error);
            }
        });

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

            $('#inp_identityno').inputmask("99999999999");
            $('#inp_phone').inputmask("9(999) 999 99 99");

            var now = new Date();
            var year = now.getFullYear();
            var month = ('0' + (now.getMonth() + 1)).slice(-2); // Aylar 0-11 arası olduğundan +1 eklenir
            var day = ('0' + now.getDate()).slice(-2);

            // Yerel saati ISO formatına uygun şekilde birleştirme
            var today = `${year}-${month}-${day}`;
            var nextyear = `${year + 1}-${month}-${day}`;

            $('input[type="date"][date-group="0"]').attr('min', '1900-01-01');
            $('input[type="date"][date-group="0"]').attr('max', today);
            $('input[type="date"][date-group="1"]').attr('min', today);
            $('input[type="date"][date-group="1"]').attr('max', nextyear);
            $('input[type="date"][date-group="2"]').attr('min', today);
            $('input[type="date"][date-group="2"]').attr('max', nextyear);

            $('input[type="date"]').on('keypress', function(event) {
                if($(event.target).val().length == 10) {
                    let item = $(event.target);
                    let date = new Date(item.val());
                    let year = date.getUTCFullYear();

                    if(year.toString().length == 4) {
                        event.preventDefault();
                    }
                }
            });

            $('input[type="date"]').on('change', function(event) {
                if($(event.target).val().length == 10) {
                    let invalid_date = 0;
                    let item = $(event.target);
                    let current = new Date();
                    let now = new Date(current.toISOString().substring(0, 10));
                    let date = new Date(item.val());
                    let year = date.getUTCFullYear();

                    if(year.toString().length == 4) {							
                        if(item.attr('date-type') == 'birth_date') {
                            if(date > now) {
                                alert(get_label(item) + ' Bugünden sonra olamaz.');
                                invalid_date = 1;
                            }
                        } else if(date < now) {
                            alert(get_label(item) + ' Bugünden önce olamaz.');
                            invalid_date = 1;
                        } else if(item.attr('date-type') == 'start_date') {
                            let end_item = $('input[date-group="' + item.attr('date-group') + '"][date-type="end_date"]');
                            let end_date = new Date(end_item.val());

                            if(date > end_date) {
                                alert(get_label(item) + ' ' + get_label(end_item) + 'nden sonra olamaz.');
                                invalid_date = 1;
                            }
                        } else if(item.attr('date-type') == 'end_date') {
                            let start_item = $('input[date-group="' + item.attr('date-group') + '"][date-type="start_date"]');
                            let start_date = new Date(start_item.val());

                            if(date < start_date) {
                                alert(get_label(item) + ' ' + get_label(start_item) + 'nden önce olamaz.');
                                invalid_date = 1;
                            }
                        }

                        if(!invalid_date && item.attr('date-group') == '2') {
                            let start_item = $('input[date-group="1"][date-type="start_date"]');
                            let start_date = new Date(start_item.val());
                            let end_item = $('input[date-group="1"][date-type="end_date"]');
                            let end_date = new Date(end_item.val());

                            if(date < start_date) {
                                alert(get_label(item) + ' ' + get_label(start_item) + 'nden önce olamaz.');
                                invalid_date = 1;
                            } else if(date > end_date) {
                                alert(get_label(item) + ' ' + get_label(end_item) + 'nden sonra olamaz.');
                                invalid_date = 1;
                            }
                        }

                        if(invalid_date) {
                            item.val('');
                            item.blur();
                            item.focus();
                        }

                        if(item.attr('date-group') == '1' && item.attr('date-type') == 'start_date') {
                            $('#inp_how_many_days_to_departure').val(Math.floor(Math.abs(date - now) / 86400000));
                        }
                    }

                    if(item.attr('date-group') == '1') {
                        $('input[date-group="2"][date-type="' + item.attr('date-type') + '"]').val(item.val());
                    }
                }
            });

            $(window).on('resize', function() {
                $('#div_main_area').css('margin-left', ($(window).width() - $('#div_main_area').width()) / 2);
            });

            $(document).on('mousedown', function(event) {
                rgfocus(event);
            });

            $(':input').on('focus', function(event) {
                rgfocus(event);
            });
/*
            $(':input').on('blur', function(event) {
                if(!$(event.target).attr('readonly')) {
                    console.log('2');
                    if(($(event.target).attr('id') == 'inp_name' || $(event.target).attr('id') == 'inp_surname' || $(event.target).attr('id') == 'inp_birthdate') &&
                        $('#inp_name').val() != '' && $('#inp_surname').val() != '' && $('#inp_birthdate').val() != '') {
                        get_traveler_info($(event.target), 'name', 'name=' + $('#inp_name').val() + '&surname=' + $('#inp_surname').val() + '&birthdate=' + $('#inp_birthdate').val());
                    } else if($(event.target).attr('id') == 'inp_identityno' && $(event.target).val() != '') {
                        console.log('3');
                        get_traveler_info($(event.target), 'identityno', 'identityno=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_passportno' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'passportno', 'passportno=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_phone' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'phone', 'phone=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_mail' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'mail', 'mail=' + $(event.target).val());
                    }
                }
            });
*/
            $(':input').on('keydown', function(event) {
                if(event.target.tagName.toLowerCase() != 'textarea' && $(event.target).attr('type').toLowerCase() != 'button' && (event.which == '13' || event.which == '9')) {
                    if(($(event.target).attr('id') == 'inp_name' || $(event.target).attr('id') == 'inp_surname' || $(event.target).attr('id') == 'inp_birthdate') &&
                        $('#inp_name').val() != '' && $('#inp_surname').val() != '' && $('#inp_birthdate').val() != '') {
                        get_traveler_info($(event.target), 'name', 'name=' + $('#inp_name').val() + '&surname=' + $('#inp_surname').val() + '&birthdate=' + $('#inp_birthdate').val());
                    } else if($(event.target).attr('id') == 'inp_identityno' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'identityno', 'identityno=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_passportno' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'passportno', 'passportno=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_phone' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'phone', 'phone=' + $(event.target).val());
                    } else if($(event.target).attr('id') == 'inp_mail' && $(event.target).val() != '') {
                        get_traveler_info($(event.target), 'mail', 'mail=' + $(event.target).val());
                    } else {
                        check_form($(event.target));
                    }
                }
            });

            $('select').on('change', function(event) {
                var item = $(event.target).attr('id').replace('sel', '');
                $('#inp' + item).val($('#sel' + item + ' option:selected').text());
            });

            $('#inp_name').on('input', function(event) {
                var value = $(this).val().replace(/ı/g, "I").replace(/i/g, "İ").toUpperCase();
                $(this).val(value);
            });

            $('#inp_surname').on('input', function(event) {
                var value = $(this).val().replace(/ı/g, "I").replace(/i/g, "İ").toUpperCase();
                $(this).val(value);
            });

            $('#inp_mail').on('input', function(event) {
                var value = $(this).val().replace(/ç/g, "c").replace(/Ç/g, "c")
                                         .replace(/ğ/g, "g").replace(/Ğ/g, "g")
                                         .replace(/İ/g, "i").replace(/ı/g, "i")
                                         .replace(/ö/g, "o").replace(/Ö/g, "o")
                                         .replace(/ş/g, "s").replace(/Ş/g, "s")
                                         .replace(/ü/g, "u").replace(/Ü/g, "u")
                                         .toLowerCase();
                $(this).val(value);
            });

            $('#inp_from_city').on('input', function(event) {
                var value = $(this).val().replace(/ı/g, "I").replace(/i/g, "İ").toUpperCase();
                $(this).val(value);
            });

            $('#inp_from_city').on('keyup', function(event) {
                set_reason();
            });

            $('#inp_to_city').on('input', function(event) {
                var value = $(this).val().replace(/ı/g, "I").replace(/i/g, "İ").toUpperCase();
                $(this).val(value);
            });

            $('#inp_to_city').on('keyup', function(event) {
                set_reason();
            });
/*
            $('#inp_birthdate').on('change', function(event) {
                if(validate_date($(this))) {
                    check_date($(this));
                }
            });

            $('#inp_departure_date').on('change', function(event) {
                if(validate_date($(this))) {
                    if(check_date($(this))) {
                        $('#inp_check-in_date').val($('#inp_departure_date').val());
                    }
                } else {
                    $('#inp_how_many_days_to_departure').val('');
                }
            });

            $('#inp_return_date').on('change', function(event) {
                if(validate_date($(this))) {
                    if(check_date($(this))) {
                        $('#inp_check-out_date').val($('#inp_return_date').val());
                    }
                }
            });

            $('#inp_check-in_date').on('change', function(event) {
                if(validate_date($(this))) {
                    check_date($(this));
                }
            });

            $('#inp_check-out_date').on('change', function(event) {
                if(validate_date($(this))) {
                    check_date($(this));
                }
            });
*/
//				fill_selection_list($('#sel_requester_type'), 'user', [], 'CONCAT(name, " ", surname)');
            fill_selection_list($('#sel_location'), 'location');
            fill_selection_list($('#sel_position'), 'position');
            fill_selection_list($('#sel_department'), 'department');
            fill_selection_list($('#sel_from_country'), 'country');
//				fill_selection_list($('#sel_from_location'), 'location');
            fill_selection_list($('#sel_from_city'), 'city', [], '', 'COUNTRY_ID = \'220\'');
            fill_selection_list($('#sel_travel_reason'), 'reason');
            fill_selection_list($('#sel_transportation_mode'), 'transportation_mode');
            $('#sel_requester_type').focus();
        });

        function get_label(item) {
            let label = $('#' + item.attr('label')).html();
            label = label.substring(0, label.indexOf(':'));
            return label;
        }
/*
        function validate_date(input_date) {
            let selected_date = new Date(input_date.val());
            let selected_year = selected_date.getUTCFullYear();

            if (selected_year >= 1000) {
                return true;
            } else {
                return false;
            }
        }

        function check_date(item) {
            var now = new Date().toISOString();
            now = now.substring(0, 10);
            now = new Date(now);

            if(item.attr('id') == 'inp_birthdate') {
                var birthdate = new Date($('#inp_birthdate').val());

                if(birthdate > now) {
                    return invalid_date($('#inp_birthdate'), 'Doğum Tarihi Bugünden sonra olamaz.');
                }
            } else if(item.attr('id') == 'inp_departure_date' || item.attr('id') == 'inp_return_date') {
                if($('#inp_departure_date').val() != '') {
                    var departure_date = new Date($('#inp_departure_date').val());
                }
                if($('#inp_return_date').val() != '') {
                    var return_date = new Date($('#inp_return_date').val());
                }

                if(item.attr('id') == 'inp_departure_date') {
                    if(departure_date < now) {
                        return invalid_date($('#inp_departure_date'), 'Gidiş Tarihi Bugünden önce olamaz.');
                    } else if($('#inp_return_date').val() != '' && departure_date > return_date) {
                        return invalid_date($('#inp_departure_date'), 'Gidiş Tarihi Dönüş Tarihinden sonra olamaz.');
                    } else {
                        $('#inp_how_many_days_to_departure').val(Math.floor(Math.abs(departure_date - now) / 86400000));
                    }
                } else if(item.attr('id') == 'inp_return_date') {
                    if(return_date < now) {
                        return invalid_date($('#inp_return_date'), 'Dönüş Tarihi Bugünden önce olamaz.');
                    } else if($('#inp_departure_date').val() != '' && return_date < departure_date) {
                        return invalid_date($('#inp_return_date'), 'Dönüş Tarihi Gidiş Tarihinden önce olamaz.');
                    }
                }
            } else if(item.attr('id') == 'inp_check-in_date' || item.attr('id') == 'inp_check-out_date') {
                if($('#inp_check-in_date').val() != '') {
                    var check_in_date = new Date($('#inp_check-in_date').val());
                }
                if($('#inp_check-out_date').val() != '') {
                    var check_out_date = new Date($('#inp_check-out_date').val());
                }

                if(item.attr('id') == 'inp_check-in_date') {
                    if(check_in_date < now) {
                        return invalid_date($('#inp_check-in_date'), 'Konaklama Başlangıç Tarihi Bugünden önce olamaz.');
                    } else if($('#inp_check-out_date').val() != '' && check_in_date > check_out_date) {
                        return invalid_date($('#inp_check-in_date'), 'Konaklama Başlangıç Tarihi Konaklama Bitiş Tarihinden sonra olamaz.');
                    }
                } else if(item.attr('id') == 'inp_check-out_date') {
                    if(check_out_date < now) {
                        return invalid_date($('#inp_check-out_date'), 'Konaklama Bitiş Tarihi Bugünden önce olamaz.');
                    } else if($('#inp_check-in_date').val() != '' && check_out_date < check_in_date) {
                        return invalid_date($('#inp_check-out_date'), 'Konaklama Bitiş Tarihi Konaklama Başlangıç Tarihinden önce olamaz.');
                    }
                }
            }
            return true;
        }

        function invalid_date(item, msg) {
            alert(msg);
            item.val('');
            item.blur();
            item.focus();
            return false;
        }
*/
        function isdescendant(parent, child) {
            let node = child.parentNode;
            while(node != null) {
                if(node == parent) {
                    return true;
                }
                node = node.parentNode;
            }
            return false;
        }

        function rgfocus(event) {
            $('[id^="div_radio_group"]').each(function() {
                if(this == event.target || isdescendant(this, event.target)) {
                    $(this).parent().attr('class', 'radio_frame_checked');
                } else {
                    $(this).parent().attr('class', 'radio_frame');
                }
            });
        }

        function generateUUID() {
            var d1 = new Date().getTime();//Timestamp
            var d2 = ((typeof performance !== 'undefined') && performance.now && (performance.now()*1000)) || 0; //Time in microseconds since page-load or 0 if unsupported
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random() * 16; //random number between 0 and 16
                if(d1 > 0){ //Use timestamp until depleted
                    r = (d1 + r)%16 | 0;
                    d1 = Math.floor(d1/16);
                } else { //Use microseconds since page-load if supported
                    r = (d2 + r)%16 | 0;
                    d2 = Math.floor(d2/16);
                }
                return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
            });
        }

        function identityno_checksum(id) {
            if((parseInt(id[0]) + parseInt(id[1]) + parseInt(id[2]) + parseInt(id[3]) + parseInt(id[4]) + parseInt(id[5]) + parseInt(id[6]) + parseInt(id[7]) + parseInt(id[8]) + parseInt(id[9])) % 10 != parseInt(id[10])) {
                return false;
            }
            if(((parseInt(id[0]) + parseInt(id[2]) + parseInt(id[4]) + parseInt(id[6]) + parseInt(id[8])) * 7 + (parseInt(id[1]) + parseInt(id[3]) + parseInt(id[5]) + parseInt(id[7])) * 9) % 10 != parseInt(id[9])) {
                return false;
            }
            if((parseInt(id[0]) + parseInt(id[2]) + parseInt(id[4]) + parseInt(id[6]) + parseInt(id[8])) * 8 % 10 != parseInt(id[10])) {
                return false;
            }
            return true;
        }

        function toggle_visibility(visible_items, unvisible_items) {
            $.each(unvisible_items, function() { $(this).hide(); });
            $.each(visible_items, function() { $(this).show(); });
        }

        function toggle_writability(writable_items, readonly_items) {
            $.each(writable_items, function() { $(this).attr('readonly', false); });
            $.each(readonly_items, function() { $(this).attr('readonly', true); });
        }

        function reset_values(items) {
            $.each(items, function() { $(this).val(''); });
        }

        function reset_personel_info() {
            reset_values([$('#inp_name'), $('#inp_surname'), $('#inp_birthdate'), $('#inp_identityno'), $('#inp_passportno'), $('#inp_phone'), $('#inp_mail')]);
            reset_values([$('#inp_location'), $('#inp_position'), $('#inp_department'), $('#sel_location'), $('#sel_position'), $('#sel_department')]);
        }

        function reset_writability_attribute() {
            toggle_writability([$('#inp_name'), $('#inp_surname'), $('#inp_birthdate'), $('#inp_identityno'), $('#inp_passportno'), $('#inp_phone'), $('#inp_mail')], []);
        }

        function reset_alerts() {
            $('[class=lbl_alrt1]').attr('class', 'lbl_norm1');
            $('[class=lbl_alrt2]').attr('class', 'lbl_norm2');
        }

        function get_list(list_table, options = [], field_name = '', where = '', order = '', selection = '') {
            return new Promise((resolve, reject) => {
                $.getJSON('./get_selection_list.php?table_name=' + list_table + '&field_name=' + field_name + '&where=' + where + '&order=' + order,
                    function(data) {
                        resolve(data);
                    }
                )
                .fail(
                    function(error) {
                        reject(error);
                    }
                )
            });
        }

        function fill_selection_list(sel_item, list_table, options = [], field_name = '', where = '', order = '', selection = '') {
            get_list(list_table, options, field_name, where, order, selection).then(data => {
                if(data.Rows) {
                    var content = '<option value="">-- Seçiniz --</option>';
                    $.each(options, function() { content += '<option value="' + this[0] + '">' + this[1] + '</option>'; });

                    for(var i = 0; i < data.Rows.length; i++) {
                        var rowData = data.Rows[i];

                        if(rowData.id == selection) {
                            var selected = ' selected';
                        } else {
                            var selected = '';
                        }

                        content += '<option value="' + rowData.id + '"' + selected + '>' + rowData.name + '</option>';
                    }
                    sel_item.html(content);
                }
            });
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
/*
        function check_form_data(item, section) {
            var result = true;
            var action = item.attr('action');
            var xmlNodes = $.merge(xmlDoc.find('input[id="' + item.attr('id') + '"]'), xmlDoc.find(section).children());

            xmlNodes.each(
                function() {
                    if(eval($(this).children('condition').text())) {
                        if(action == 'warn') {
                            alert($(this).children('alert').text());
                            var label_item = $('#' + $('#' + $(this).attr('id')).attr('label'));
                            label_item.attr('class', label_item.attr('alert'));
                        } else if($(this).children('forced_alert').text() == '1') {
                            alert($(this).children('alert').text());
                        }
                        $('#' + $(this).attr('id')).focus();
                        result = false;
                        return result;
                    }
                }
            );
            return result;
        }

        function check_form(item) {
            reset_alerts();

            var area = item.attr('area');

            if(area == 'area1') {
                if(check_form_data(item, 'section1')) {
                    $('#btn_add_traveler').focus();
                    return true;
                } else {
                    return false;
                }
            } else if(area == 'area2') {
                if($('#rb_route1').prop('checked')) {
                    if(!check_form_data(item, 'section2')) {
                        return false;
                    }
                } else if($('#rb_route2').prop('checked')) {
                    if(!check_form_data(item, 'section3')) {
                        return false;
                    }
                }
                if(!check_form_data(item, 'section4')) {
                    return false;
                }
                if(!check_form_data(item, 'section5')) {
                    return false;
                }
                if($('#rb_trac1').prop('checked') || $('#rb_trac2').prop('checked')) {
                    if(!check_form_data(item, 'section6')) {
                        return false;
                    }
                }
                if($('#rb_trac1').prop('checked') || $('#rb_trac3').prop('checked')) {
                    if(!check_form_data(item, 'section7')) {
                        return false;
                    }
                }
                $('#btn_add_request').focus();
                return true;
            }
        }
*/
        function get_traveler_info(item, search_type, params) {
            var postdata = 'type=' + search_type + '&' + params;
            $.getJSON('./get_traveler_info_from_db.php?' + postdata,
                function(data) {
                    if(data.Rows) {
                        var rowData = data.Rows[0];
                        if(rowData.status == 1) {
                            set_traveler_info(rowData);
                        } else if(search_type == 'mail') {
                            $.getJSON('./get_traveler_info_from_ad.php?' + postdata,
                                function(data) {
                                    if(data.Rows) {
                                        var rowData = data.Rows[0];
                                        if(rowData.status == 1) {
                                            set_traveler_info(rowData);
                                        } else {
                                            toggle_visibility([$('#sel_position').parent(), $('#sel_department').parent(), $('#sel_location').parent()], [$('#inp_position').parent(), $('#inp_department').parent(), $('#inp_location').parent()]);
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            ).done(
                function() {
                    check_form(item);
                }
            );
        }

        function set_traveler_info(data) {
            toggle_visibility([$('#inp_position').parent(), $('#inp_department').parent(), $('#inp_location').parent()], [$('#sel_position').parent(), $('#sel_department').parent(), $('#sel_location').parent()]);

            $('#inp_name').val(data.name ? data.name : '');
            $('#inp_surname').val(data.surname ? data.surname : '');
            $('#inp_birthdate').val(data.birthdate ? data.birthdate : '');
            $('#inp_identityno').val(data.identityno ? data.identityno : '');
            $('#inp_passportno').val(data.passportno ? data.passportno : '');
            $('#inp_phone').val(data.phone ? data.phone : '');
            $('#inp_mail').val(data.mail ? data.mail : '');
            $('#inp_position').val(data.positionname ? data.positionname : '');
            $('#inp_department').val(data.departmentname ? data.departmentname : '');
            $('#inp_location').val(data.locationname ? data.locationname : '');
            $('#sel_position').val(data.positionid ? data.positionid : '');
            $('#sel_department').val(data.departmentid ? data.departmentid : '');
            $('#sel_location').val(data.locationid ? data.locationid : '');
        }

        function set_requester_type(item) {
            reset_personel_info();
            reset_writability_attribute();

            if(item.val() == '') {
                toggle_visibility([], [$('#div_personal_info'), $('#div_staff_info'), $('#div_add_button')]);
                check_form(item);
            } else if(item.val() == '1') {
                toggle_visibility([$('#div_personal_info'), $('#div_staff_info'), $('#inp_position').parent(), $('#inp_department').parent(), $('#inp_location').parent(), $('#div_add_button')], [$('#sel_position').parent(), $('#sel_department').parent(), $('#sel_location').parent()]);
                toggle_writability([], [$('#inp_name'), $('#inp_surname'), $('#inp_mail')]);
                get_traveler_info(item, 'mail', 'mail=<?php echo $_SESSION['user_info']['mail']; ?>');
            } else if(item.val() == '2') {
                toggle_visibility([$('#div_personal_info'), $('#div_staff_info'), $('#inp_position').parent(), $('#inp_department').parent(), $('#inp_location').parent(), $('#div_add_button')], [$('#sel_position').parent(), $('#sel_department').parent(), $('#sel_location').parent()]);
                toggle_writability([$('#inp_name'), $('#inp_surname'), $('#inp_mail')], []);
                check_form(item);
            } else if(item.val() == '3') {
                toggle_visibility([$('#div_personal_info'), $('#div_add_button')], [$('#div_staff_info')]);
                toggle_writability([$('#inp_name'), $('#inp_surname'), $('#inp_mail')], []);
                check_form(item);
            }
        }

        function set_travel_route(item) {
            reset_values([$('#sel_from_country'), $('#sel_to_country'), $('#sel_from_location'), $('#sel_to_location'), $('#inp_from_city'), $('#inp_to_city'), $('#sel_from_city'), $('#sel_to_city')]);

            $('#sel_to_country').html($('#sel_from_country').html());
            $('#sel_to_city').html($('#sel_from_city').html());

            if(item.attr('id') == 'rb_route1') {
                $('#inp_route').val('1');
                $('#inp_route_name').val('Yurt İçi');
                $('#fnt_route').html('Yurt İçi');
                toggle_visibility([], [$('#div_passport')]);
                $('#th_trv_list_passport').hide();
                $('#div_lbl12').html('Nereden:');
                $('#div_lbl15').html('Nereye:');
                fill_location_list('220', $('#sel_from_location')).then(data => {
                    $('#sel_from_country').val('220');
                    $('#sel_to_country').val('220');
                    if($('#sel_from_location').children().length > 0) {
                        $('#sel_to_location').html($('#sel_from_location').html());
                        toggle_visibility([$('#div_from_location'), $('#div_to_location')], [$('#div_from_country'), $('#div_to_country'), $('#div_from_city'), $('#div_to_city')]);
                    } else {
                        toggle_visibility([$('#div_from_city'), $('#div_to_city')], [$('#div_from_country'), $('#div_to_country'), $('#div_from_location'), $('#div_to_location')]);
                    }
                });
            } else if(item.attr('id') == 'rb_route2') {
                $('#inp_route').val('2');
                $('#inp_route_name').val('Yurt Dışı');
                $('#fnt_route').html('Yurt Dışı');
                toggle_visibility([$('#div_passport')], []);
                $('#th_trv_list_passport').show();
                $('#div_lbl12').html('Lokasyon:');
                $('#div_lbl15').html('Lokasyon:');
                toggle_visibility([$('#div_from_country'), $('#div_to_country')], [$('#div_from_location'), $('#div_to_location'), $('#div_from_city'), $('#div_to_city')]);
            }
        }

        function add_traveler(item) {
            if(item.val() == 'Güncelle ⭮') {
                item.val('Ekle ✚');
                $('#sel_requester_type').prop('disabled', false);
            }

            if(!check_form(item)) {
                return false;
            }

            if($('#inp_uuid').val() == '') {
                $('#inp_uuid').val(generateUUID());
            }

            var content = '';
            var uuid = $('#inp_uuid').val();
            var formData = $('#form1').serialize();

            $.getJSON('./add_traveler.php?' + formData,
                function(data) {
                    if(data.Rows) {
                        var rowData = data.Rows[0];
                        if(rowData.status == '0') {
                            alert('Bu kişi listeye daha önce eklenmiş.');
                        } else if(rowData.status == '1') {
                            content =	'	<tr id="' + uuid + '-tr1" class="trv_tbody">' +
                                        '		<td id="' + uuid + '-request_owner" hidden>' + $('#sel_requester_type').val() + '</td>' +
                                        '		<td id="' + uuid + '-name" class="trv_cell_tb">' + rowData.name + '</td>' +
                                        '		<td id="' + uuid + '-surname" class="trv_cell_tb">' + rowData.surname + '</td>' +
                                        '		<td id="' + uuid + '-birthdate" class="trv_cell_tb">' + rowData.birthdate + '</td>' +
                                        '		<td id="' + uuid + '-identityno" class="trv_cell_tb">' + rowData.identityno + '</td>';

                            if($('#inp_route').val() == '2') {
                                content +=	'		<td id="' + uuid + '-passportno" class="trv_cell_tb">' + rowData.passportno + '</td>';
                            }

                            content +=	'		<td id="' + uuid + '-phone" class="trv_cell_tb">' + rowData.phone + '</td>' +
                                        '		<td id="' + uuid + '-mail" class="trv_cell_tb">' + rowData.mail + '</td>' +
                                        '		<td id="' + uuid + '-position" class="trv_cell_tb">' + rowData.position + '</td>' +
                                        '		<td id="' + uuid + '-positionid" hidden>' + rowData.positionid + '</td>' +
                                        '		<td id="' + uuid + '-department" class="trv_cell_tb">' + rowData.department + '</td>' +
                                        '		<td id="' + uuid + '-departmentid" hidden>' + rowData.departmentid + '</td>' +
                                        '		<td id="' + uuid + '-location" class="trv_cell_tb">' + rowData.location + '</td>' +
                                        '		<td id="' + uuid + '-locationid" hidden>' + rowData.locationid + '</td>' +
                                        '	</tr>';

                            $('#tb_traveler_list').append(content);

                            content =	'	<tr id="' + uuid + '-tr2" class="trv_tbody">' +
                                        '		<td class="trv_cell_th"><img src="./images/edit.png" class="trv_cell_img" title="Düzenle" onClick="edit_traveler(\'' + uuid + '\');" /></td>' +
                                        '		<td class="trv_cell_th"><img src="./images/delete.png" class="trv_cell_img" title="Sil" onClick="del_traveler(\'' + uuid + '\');" /></td>' +
                                        '	</tr>';

                            $('#tb_process_list').append(content);

                            $('#rb_route1').prop('disabled', true);
                            $('#rb_route2').prop('disabled', true);

                            $('#sel_requester_type').val('');
                            set_requester_type($('#sel_requester_type'));
                        } else if(rowData.status == '2') {
                            $('#' + uuid + '-name').html(rowData.name);
                            $('#' + uuid + '-surname').html(rowData.surname);
                            $('#' + uuid + '-birthdate').html(rowData.birthdate);
                            $('#' + uuid + '-identityno').html(rowData.identityno);
                            $('#' + uuid + '-passportno').html(rowData.passportno);
                            $('#' + uuid + '-phone').html(rowData.phone);
                            $('#' + uuid + '-mail').html(rowData.mail);
                            $('#' + uuid + '-position').html(rowData.position);
                            $('#' + uuid + '-positionid').html(rowData.positionid);
                            $('#' + uuid + '-department').html(rowData.department);
                            $('#' + uuid + '-departmentid').html(rowData.departmentid);
                            $('#' + uuid + '-location').html(rowData.location);
                            $('#' + uuid + '-locationid').html(rowData.locationid);

                            alert('"' + rowData.name + ' ' + rowData.surname + '" için bilgiler güncellendi.');

                            $('#sel_requester_type').prop('disabled', false);
                            $('#sel_requester_type').val('');
                            set_requester_type($('#sel_requester_type'));
                        }
                    }
                }
            ).done(
                function() {
                    toggle_visibility([$('#div_traveler_list')], []);
                    $('#inp_uuid').val('');
                    $('#btn_continue').focus();

                    return true;
                }
            );
        }

        function edit_traveler(uuid) {
            $('#sel_requester_type').val($('#' + uuid + '-request_owner').html());
            $('#sel_requester_type').prop('disabled', true);
            $('#div_traveler_type').show();
            set_requester_type($('#sel_requester_type'));

            $('#inp_uuid').val(uuid);
            $('#inp_name').val($('#' + uuid + '-name').html());
            $('#inp_surname').val($('#' + uuid + '-surname').html());
            var birthdate = $('#' + uuid + '-birthdate').html().split('.');
            $('#inp_birthdate').val(birthdate[2] + '-' + birthdate[1] + '-' + birthdate[0]);
            $('#inp_identityno').val($('#' + uuid + '-identityno').html());
            $('#inp_passportno').val($('#' + uuid + '-passportno').html());
            $('#inp_phone').val($('#' + uuid + '-phone').html());
            $('#inp_mail').val($('#' + uuid + '-mail').html());
            $('#inp_position').val($('#' + uuid + '-position').html());
            $('#sel_position').val($('#' + uuid + '-positionid').html());
            $('#inp_department').val($('#' + uuid + '-department').html());
            $('#sel_department').val($('#' + uuid + '-departmentid').html());
            $('#inp_location').val($('#' + uuid + '-location').html());
            $('#sel_location').val($('#' + uuid + '-locationid').html());

            $('#btn_add_traveler').val('Güncelle ⭮');
        }

        function del_traveler(uuid) {
            if(confirm('"' + $('#' + uuid + '-name').html() + ' ' + $('#' + uuid + '-surname').html() + '" yolcu listesinden çıkarılacak.\nDevam etmek istiyor musunuz?')) {
                if($('#tb_traveler_list').children().length == 1) {
                    $('#sel_requester_type').prop('disabled', false);
                    $('#rb_route1').prop('disabled', false);
                    $('#rb_route2').prop('disabled', false);
                }
                $('#' + uuid + '-tr1').remove();
                $('#' + uuid + '-tr2').remove();

                $.getJSON('./del_traveler.php?uuid=' + uuid);
            }
        }

        function set_travel_info(item) {
            if(item.val() == 'Devam ⮞') {
                item.val('Geri ⮝');
                toggle_visibility([$('#div_route'), $('#div_travel_info')], [$('#div_traveler_type'), $('#div_personal_info'), $('#div_staff_info'), $('#div_add_button')]);
                check_form(item);
            } else if(item.val() == 'Geri ⮝') {
                item.val('Devam ⮞');
                toggle_visibility([$('#div_traveler_type')], []);
            }
        }

        function fill_location_list(country_id, location_item) {
            return new Promise((resolve, reject) => {
                var content = '';
                $.getJSON('./get_location_by_country.php?country_id=' + country_id,
                    function(data) {
                        if(data.Rows.length > 0) {
                            content = '<option value="">-- Seçiniz --</option>';
                            content += '<option value="0">Diğer</option>';

                            for(var i = 0; i < data.Rows.length; i++) {
                                var rowData = data.Rows[i];
                                content += '<option value="' + rowData.id + '">' + rowData.name + '</option>';
                            }
                        }
                        location_item.html(content);
                        resolve(data);
                    }
                ).fail(function(error) { reject(error); })
            });
        }

        function set_country(ctrl_item, div_item1, location_item, div_item2, input_item, select_item) {
            reset_values([location_item, input_item, select_item]);
            input_item.prop('readonly', false);
            if(ctrl_item.val().length > 0) {
                fill_location_list(ctrl_item.val(), location_item).then(data => {
                    if(location_item.children().length > 0) {
                        toggle_visibility([div_item1], [div_item2]);
                    } else {
                        toggle_visibility([div_item2, input_item.parent()], [div_item1, select_item.parent()]);
                    }
                });
            } else {
                toggle_visibility([], [div_item1, div_item2]);
            }
        }

        function set_location(ctrl_item, country_item, div_item, input_item, select_item) {
            input_item.val('');
            select_item.val('');
            if(ctrl_item.val() == '') {
                div_item.hide();
            } else if(ctrl_item.val() == '0') {
                if($('#rb_route1').prop('checked') == true || country_item.val() == '220') {
                    toggle_visibility([div_item, select_item.parent()], [input_item.parent()]);
                } else {
                    toggle_visibility([div_item, input_item.parent()], [select_item.parent()]);
                    input_item.prop('readonly', false);
                }
            } else {
                $.getJSON('./get_city_by_location.php?location_id=' + ctrl_item.val(),
                    function(data) {
                        if(data.Rows) {
                            var rowData = data.Rows[0];
                            input_item.val(rowData.name);
                            select_item.val(rowData.id);
                        }
                    }
                ).done(
                    function() {
                        toggle_visibility([div_item, input_item.parent()], [select_item.parent()]);
                        input_item.prop('readonly', true);
                        set_reason();
                    }
                );
            }
        }

        function set_city() {
            set_reason();
        }

        function set_reason() {
            if( ($('#inp_from_city').val() != '' || ($('#sel_from_city').val() !== null ? $('#sel_from_city').val() : '' != '')) &&
                ($('#inp_to_city').val() != '' || ($('#sel_to_city').val() !== null ? $('#sel_to_city').val() : '' != '')) ) {
                $('#div_travel_reason').show();
            }
        }

        function set_transfer_need_situation(item) {
            if(item.attr('id') == 'rb_tns1') {
                $('#inp_transfer_need_situation').val('1');
                $('#inp_transfer_need_situation_name').val('Var');
                toggle_visibility([$('#div_nftd')], []);
            } else if(item.attr('id') == 'rb_tns2') {
                $('#inp_transfer_need_situation').val('2');
                $('#inp_transfer_need_situation_name').val('Yok');
                toggle_visibility([], [$('#div_nftd')]);
            }
        }

        function add_request(item) {
            if(check_form(item)) {
                var formData = $('#form1').serialize();

                $.getJSON('./add_request.php?' + formData,
                    function(data) {
                        if(data.Rows) {
                            var rowData = data.Rows[0];
                            if(rowData.status == '1') {
                                $('#div_form_page').hide();
                                $('#div_approve_page').load('./request_approval_form.php');
                                $('#div_approve_page').show();
                            } else {
                                alert(rowData.message);
                            }
                        } else {
                            alert('Talep oluşturulurken bir hata oluştu!');
                        }
                    }
                );
            } else {
                return false;
            }
        }

        function save_request() {
            $.getJSON('./save_request.php',
                function(data) {
                    if(data.Rows) {
                        var rowData = data.Rows[0];
                        if(rowData.status == '1') {
                            var requestid = rowData.requestid;
                            $.getJSON('./get_mail_recipient_list.php?type=1&request_id=' + requestid,
                                function(data) {
                                    if(data.Rows) {
                                        send_mail(requestid);
                                    } else {
                                        alert('Mail alıcı listesi oluşturulurken bir hata oluştu!');
                                    }
                                }
                            );
                        } else {
                            alert('Talep kaydedilirken bir hata oluştu!');
                        }
                    } else {
                        alert('Talep kaydedilirken bir hata oluştu!');
                    }
                }
            );
        }

        function send_mail(requestid) {
            $.ajax({
                url: './request_view.php?list_type=2&mail_view=1&request_id=' + requestid, // HTML almak istediğiniz sayfanın URL'si
                method: "GET",
                dataType: "html",
                success: function(htmlText) {
                    // HTML içeriği burada 'htmlText' değişkeninde

                    const doc = new DOMParser().parseFromString(htmlText, "text/html");

                    const link = doc.getElementsByTagName('link');
                    for(let i = link.length - 1; i >= 0; i--) {
                        link[i].remove();
                    }

                    htmlText = doc.documentElement.outerHTML.replace('.style {}', cssDoc);
                    console.log(htmlText);

                    $.ajax({
                        type: "POST",
                        url: "./send_mail.php",
                        data: { mailBody: htmlText },	// Gönderilecek veri
                        success: function(response) {
                            toggle_visibility([$('#div_completion_page')], [$('#div_preview_page')]);
                            console.log('Mail gönderimi başarılı.');
                            console.log('Sunucudan gelen yanıt:', response);
                        },
                        error: function(xhr, status, error) {
                            alert('Talep kaydedildi ancak mail gönderilirken bir hata oluştu!');
                            console.error('Talep kaydedildi ancak mail gönderilirken bir hata oluştu!', error);
                        }
                    });
                },
                error: function(xhr, status, error) {
                    console.log('Bir hata oluştu.');
                    console.log(error);
                }
            });
        }

        function cancel_request() {
            if(confirm('Talep iptal edilecek.\nDevam etmek istiyor musunuz?')) {
                window.open('./request_entry_form.php', '_self');
            }
        }

    </script>
</head>
<body>
    <div id="div_main_area" hidden>
        <div id="div_main_frame" class="main_frame">
            <div style="height: 40px;"></div>
            <div class="heading">ULAŞIM ve KONAKLAMA TALEP FORMU</div>
            <div style="height: 10px;"></div>
            <div id="div_form_page">
                <form id="form1" method="post" enctype="multipart/form-data" action="">
                    <div style="display: flex; height: 10px;">
                        <div align="left" style="width: 50%;">
                            <div id="div_route" hidden><b>Seyahat Rotası: </b><font id="fnt_route"></font></div>
                        </div>
                        <div align="right" style="width: 50%;">
                            <div id="div_request_date"><b>Talep Tarihi: </b><?php echo date("d.m.Y"); ?></div>
                        </div>
                    </div>
                    <div style="height: 10px;"></div>
                    <div align="left" class="gray_frame" style="height: 15px; background-color: #79c1e597;">&nbsp;Talep Sahibi Bilgileri</div>
                    <div class="gray_frame">
                        <div style="height: 10px;"></div>
                        <div style="display: flex;">
                            <div style="width: 3%;"></div>
                            <div style="width: 94%;">
                                <div id="div_traveler_type">
                                    <div style="display: flex;">
                                        <div align="left" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div id="div_request_owner">
                                                    <div style="display: flex; height: 38px;">
                                                        <div style="width: 35%; display: flex; justify-content: center;">
                                                            <div id="div_lbl0" class="lbl_norm1" alert="lbl_alrt1">Talep Sahibi:</div>
                                                        </div>
                                                        <div style="width: 65%; align-self: center;">
                                                            <input type="hidden" id="inp_requester_type" name="inp_sel_requester_type" />
                                                            <select id="sel_requester_type" name="sel_requester_type" label="div_lbl0" area="area1" action="go" class="inp" onChange="set_requester_type($(this));">
                                                                <option value="">-- Seçiniz --</option>
                                                                <option value="1">Kendim</option>
                                                                <option value="2">Personel</option>
                                                                <option value="3">Misafir</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div align="right" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div id="div_travel_route">
                                                    <div style="display: flex; height: 38px;" on>
                                                        <div style="width: 35%; display: flex; justify-content: center;">
                                                            <div id="div_lbl1" class="lbl_norm1" alert="lbl_alrt1">Seyahat Rotası:</div>
                                                        </div>
                                                        <div id="div_frame_route" class="radio_frame" style="width: 65%; align-self: center; margin-left: 1px;">
                                                            <div id="div_radio_group_route" class="radio_group">
                                                                <input type="hidden" id="inp_route" name="inp_route" value="" />
                                                                <input type="hidden" id="inp_route_name" name="inp_route_name" value="" />
                                                                <div style="width: 5px;"></div>
                                                                <div style="width: 24px;">
                                                                    <input type="radio" id="rb_route1" name="rb_route" label="div_lbl1" class="radio" area="area1" action="go" value="1" onChange="set_travel_route($(this));" />
                                                                </div>
                                                                <label for="rb_route1" style="margin-top: 2px;">Yurt İçi</label>
                                                                <div style="width: 20px;"></div>
                                                                <div style="width: 24px;">
                                                                    <input type="radio" id="rb_route2" name="rb_route" label="div_lbl1" class="radio" area="area1" action="go" value="2" onChange="set_travel_route($(this));" />
                                                                </div>
                                                                <label for="rb_route2" style="margin-top: 2px;">Yurt Dışı</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div id="div_personal_info" hidden>
                                    <div><input type="hidden" id="inp_uuid" name="inp_uuid" value="" /></div>
                                    <div id="div_blank_line1" class="gray_line"></div>
                                    <div style="display: flex;">
                                        <div align="left" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl2" class="lbl_norm1" alert="lbl_alrt1">Kimlik No:</div>
                                                    </div>
                                                    <div style="width: 65%; align-self: center;">
                                                        <input type="text" id="inp_identityno" name="inp_identityno" label="div_lbl2" area="area1" action="go" class="inp" />
                                                    </div>
                                                </div>
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl3" class="lbl_norm1" alert="lbl_alrt1">Adı Soyadı:</b></div>
                                                    </div>
                                                    <div style="display: flex; width: 65%;">
                                                        <input type="text" id="inp_name" name="inp_name" label="div_lbl3" area="area1" action="go" class="inp" style="width: 49%;" readonly />
                                                        <div style="width: 2%;"></div>
                                                        <input type="text" id="inp_surname" name="inp_surname" label="div_lbl3" area="area1" action="go" class="inp" style="width: 49%;" readonly />
                                                    </div>
                                                </div>
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl4" class="lbl_norm1" alert="lbl_alrt1">Doğum Tarihi:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <input type="date" date-group="0" date-type="birth_date" id="inp_birthdate" name="inp_birthdate" label="div_lbl4" area="area1" action="go" class="inp" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div align="right" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div id="div_passport" hidden>
                                                    <div style="display: flex; height: 38px;">
                                                        <div style="width: 35%;">
                                                            <div id="div_lbl5" class="lbl_norm1" alert="lbl_alrt1">Pasaport No:</div>
                                                        </div>
                                                        <div style="width: 65%;">
                                                            <input type="text" id="inp_passportno" name="inp_passportno" label="div_lbl5" area="area1" action="go" class="inp" />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl6" class="lbl_norm1" alert="lbl_alrt1">Telefon No:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <input type="text" id="inp_phone" name="inp_phone" label="div_lbl6" area="area1" action="go" class="inp" />
                                                    </div>
                                                </div>
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%">
                                                        <div id="div_lbl7" class="lbl_norm1" alert="lbl_alrt1">Mail Adresi:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <input type="text" id="inp_mail" name="inp_mail" label="div_lbl7" area="area1" action="go" class="inp" readonly />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div id="div_staff_info" hidden>
                                    <div id="div_blank_line2" class="gray_line"></div>
                                    <div style="display: flex;">
                                        <div align="left" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl8" class="lbl_norm1" alert="lbl_alrt1">Görevi / Ünvanı:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <div hidden><input type="text" id="inp_position" name="inp_position" label="div_lbl8" area="area1" action="go" class="inp" readonly /></div>
                                                        <div hidden><select id="sel_position" name="sel_position" label="div_lbl8" area="area1" action="go" class="inp"></select></div>
                                                    </div>
                                                </div>
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl9" class="lbl_norm1" alert="lbl_alrt1">Departmanı:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <div hidden><input type="text" id="inp_department" name="inp_department" label="div_lbl9" area="area1" action="go" class="inp" readonly /></div>
                                                        <div hidden><select id="sel_department" name="sel_department" label="div_lbl9" area="area1" action="go" class="inp"></select></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div align="right" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div style="display: flex; height: 38px;">
                                                    <div style="width: 35%;">
                                                        <div id="div_lbl10" class="lbl_norm1" alert="lbl_alrt1">Çalışma Şubesi:</div>
                                                    </div>
                                                    <div style="width: 65%;">
                                                        <div hidden><input type="text" id="inp_location" name="inp_location" label="div_lbl10" area="area1" action="go" class="inp" readonly /></div>
                                                        <div hidden><select id="sel_location" name="sel_location" label="div_lbl10" area="area1" action="go" class="inp"></select></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div id="div_add_button" hidden>
                                    <div id="div_blank_line3" class="gray_line"></div>
                                    <div style="display: flex;">
                                        <div align="left" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div id="div_add">
                                                    <div style="display: flex; height: 38px;">
                                                        <div style="width: 100%;">
                                                            <input type="button" id="btn_add_traveler" area="area1" action="warn" class="btn" value="Ekle ✚" onClick="add_traveler($(this));" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div id="div_traveler_list" hidden>
                                    <div align="left" style="height: 13px; border: solid 2px #B5D4EB; background-color: #B5D4EB; font-weight: bold;">&nbsp;Seyahat Edecekler</div>
                                    <div class="trv_lst">
                                        <div id="div_traveler_line_frame1" class="trv_lst_frm1">
                                            <table class="trv_tbl1">
                                                <thead>
                                                    <tr class="trv_thead">
                                                        <th hidden></th>
                                                        <th class="trv_cell_th">Adı</th>
                                                        <th class="trv_cell_th">Soyadı</th>
                                                        <th class="trv_cell_th">Doğum Tarihi</th>
                                                        <th class="trv_cell_th">Kimlik No</th>
                                                        <th id="th_trv_list_passport" class="trv_cell_th" hidden>Pasaport No</th>
                                                        <th class="trv_cell_th">Telefon No</th>
                                                        <th class="trv_cell_th">Mail Adresi</th>
                                                        <th class="trv_cell_th">Görevi / Ünvanı</th>
                                                        <th hidden></th>
                                                        <th class="trv_cell_th">Departmanı</th>
                                                        <th hidden></th>
                                                        <th class="trv_cell_th">Çalışma Şubesi</th>
                                                        <th hidden></th>
                                                    </tr>
                                                </thead>
                                                <tbody id="tb_traveler_list"></tbody>
                                            </table>
                                        </div>
                                        <div id="div_traveler_line_frame2" class="trv_lst_frm2">
                                            <table class="trv_tbl2">
                                                <thead>
                                                    <tr class="trv_thead">
                                                        <th colspan="2" class="trv_cell_th">İşlem</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="tb_process_list"></tbody>
                                            </table>
                                        </div>
                                    </div>
                                    <div style="height: 10px;"></div>
                                    <div style="display: flex;">
                                        <div align="left" style="width: 50%;">
                                            <div align="left" style="width: 97%;">
                                                <div id="div_continue">
                                                    <div style="display: flex; height: 38px;">
                                                        <div style="width: 100%;">
                                                            <input type="button" id="btn_continue" area="area2" action="go" class="btn" value="Devam ⮞" onClick="set_travel_info($(this));" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div style="width: 3%;"></div>
                        </div>
                        <div style="height: 10px;"></div>
                    </div>
                    <div style="height: 30px;"></div>
                    <div align="left" class="blue_line">Seyahat Bilgileri</div>
                    <div style="height: 20px;"></div>
                    <div id="div_travel_info" hidden>
                        <div style="display: flex;">
                            <div align="left" style="width: 50%;">
                                <div id="div_from_country" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl11" class="lbl_norm2" alert="lbl_alrt2">Nereden:</div>
                                    <div>
                                        <input type="hidden" id="inp_from_country" name="inp_from_country" />
                                        <select id="sel_from_country" name="sel_from_country" label="div_lbl11" area="area2" action="go" class="inp" onChange="set_country($(this), $('#div_from_location'), $('#sel_from_location'), $('#div_from_city'), $('#inp_from_city'), $('#sel_from_city'));"></select>
                                    </div>
                                </div>
                                <div id="div_from_location" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl12" class="lbl_norm2" alert="lbl_alrt2">Lokasyon:</div>
                                    <div>
                                        <input type="hidden" id="inp_from_location" name="inp_from_location" />
                                        <select id="sel_from_location" name="sel_from_location" label="div_lbl12" area="area2" action="go" class="inp" onChange="set_location($(this), $('#sel_from_country'), $('#div_from_city'), $('#inp_from_city'), $('#sel_from_city'));"></select>
                                    </div>
                                </div>
                                <div id="div_from_city" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl13" class="lbl_norm2" alert="lbl_alrt2">Şehir:</div>
                                    <div>
                                        <div hidden><input type="text" id="inp_from_city" name="inp_from_city" label="div_lbl13" area="area2" action="go" class="inp" /></div>
                                        <div hidden><select id="sel_from_city" name="sel_from_city" label="div_lbl13" area="area2" action="go" class="inp" onChange="set_city();"></select></div>
                                    </div>
                                </div>
                            </div>
                            <div align="right" style="width: 50%;">
                                <div id="div_to_country" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl14" class="lbl_norm2" alert="lbl_alrt2">Nereye:</div>
                                    <div>
                                        <input type="hidden" id="inp_to_country" name="inp_to_country" />
                                        <select id="sel_to_country" name="sel_to_country" label="div_lbl14" area="area2" action="go" class="inp" onChange="set_country($(this), $('#div_to_location'), $('#sel_to_location'), $('#div_to_city'), $('#inp_to_city'), $('#sel_to_city'));"></select>
                                    </div>
                                </div>
                                <div id="div_to_location" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl15" class="lbl_norm2" alert="lbl_alrt2">Lokasyon:</div>
                                    <div>
                                        <input type="hidden" id="inp_to_location" name="inp_to_location" />
                                        <select id="sel_to_location" name="sel_to_location" label="div_lbl15" area="area2" action="go" class="inp" onChange="set_location($(this), $('#sel_to_country'), $('#div_to_city'), $('#inp_to_city'), $('#sel_to_city'));"></select>
                                    </div>
                                </div>
                                <div id="div_to_city" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl16" class="lbl_norm2" alert="lbl_alrt2">Şehir:</div>
                                    <div>
                                        <div hidden><input type="text" id="inp_to_city" name="inp_to_city" label="div_lbl16" area="area2" action="go" class="inp" /></div>
                                        <div hidden><select id="sel_to_city" name="sel_to_city" label="div_lbl16" area="area2" action="go" class="inp" onChange="set_city();"></select></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div style="display: flex;">
                            <div align="left" style="width: 50%;">
                                <div id="div_travel_reason" align="left" style="width: 97%; height: 58px;" hidden>
                                    <div id="div_lbl17" class="lbl_norm2" alert="lbl_alrt2">Seyahat Nedeni:</div>
                                    <div>
                                        <input type="hidden" id="inp_travel_reason" name="inp_travel_reason" />
                                        <select id="sel_travel_reason" name="sel_travel_reason" label="div_lbl17" area="area2" action="go" class="inp" onChange="toggle_visibility([$('#div_transportation_accommodation')], []);"></select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div style="height: 20px;"></div>
                    <div id="div_lbl18" align="left" class="blue_line">Ulaşım ve Konaklama Bilgileri</div>
                    <div style="height: 10px;"></div>
                    <div id="div_transportation_accommodation" align="center" hidden>
                        <div id="div_frame_trac" class="radio_frame">
                            <div id="div_radio_group_trac" align="left" class="radio_group">
                                <div style="width: 5px;"></div>
                                <div style="width: 24px;">
                                    <input type="radio" id="rb_trac1" name="rb_trac" label="div_lbl18" class="radio" area="area2" action="go" value="1" onChange="toggle_visibility([$('#div_transportation'), $('#div_accommodation'), $('#div_save')], []);" />
                                </div>
                                <label for="rb_trac1" style="margin-top: 2px;">Ulaşım ve Konaklama Talebi</label>
                                <div style="width: 20px;"></div>
                                <div style="width: 24px;">
                                    <input type="radio" id="rb_trac2" name="rb_trac" label="div_lbl18" class="radio" area="area2" action="go" value="2" onChange="toggle_visibility([$('#div_transportation'), $('#div_save')], [$('#div_accommodation')]);" />
                                </div>
                                <label for="rb_trac2" style="margin-top: 2px;">Ulaşım Talebi</label>
                                <div style="width: 20px;"></div>
                                <div style="width: 24px;">
                                    <input type="radio" id="rb_trac3" name="rb_trac" label="div_lbl18" class="radio" area="area2" action="go" value="3" onChange="toggle_visibility([$('#div_accommodation'), $('#div_save')], [$('#div_transportation')]);" />
                                </div>
                                <label for="rb_trac3" style="margin-top: 2px;">Konaklama Talebi</label>
                                <div style="width: 20px;"></div>
                                <div><font style="color: red; font-weight: bold;">*</font></div>
                            </div>
                        </div>
                    </div>
                    <div style="height: 20px;"></div>
                    <div id="div_transportation" hidden>
                        <div align="left" class="blue_line">Ulaşım Bilgileri</div>
                        <div style="height: 20px;"></div>
                        <div style="display: flex;">
                            <div align="left" style="width: 50%;">
                                <div align="left" style="width: 97%;">
                                    <input type="hidden" id="inp_how_many_days_to_departure" name="inp_how_many_days_to_departure" />
                                    <div style="height: 58px;">
                                        <div id="div_lbl19" class="lbl_norm2" alert="lbl_alrt2">Gidiş Tarihi:</div>
                                        <div><input type="date" date-group="1" date-type="start_date" id="inp_departure_date" name="inp_departure_date" label="div_lbl19" area="area2" action="go" class="inp" /></div>
                                    </div>
                                    <div style="height: 58px;">
                                        <div id="div_lbl20" class="lbl_norm2" alert="lbl_alrt2">Dönüş Tarihi:</div>
                                        <div><input type="date" date-group="1" date-type="end_date" id="inp_return_date" name="inp_return_date" label="div_lbl20" area="area2" action="go" class="inp" /></div>
                                    </div>
                                    <div style="height: 58px;">
                                        <div id="div_lbl21" class="lbl_norm2" alert="lbl_alrt2">Transfer İhtiyaç Durumu:</div>
                                        <div id="div_frame_tns" class="radio_frame">
                                            <div id="div_radio_group_tns" class="radio_group">
                                                <input type="hidden" id="inp_transfer_need_situation" name="inp_transfer_need_situation" />
                                                <input type="hidden" id="inp_transfer_need_situation_name" name="inp_transfer_need_situation_name" />
                                                <div style="width: 5px;"></div>
                                                <div style="width: 24px;">
                                                    <input type="radio" id="rb_tns1" name="rb_tns" label="div_lbl21" class="radio" area="area2" action="go" value="1" onClick="set_transfer_need_situation($(this));" />
                                                </div>
                                                <label for="rb_tns1" style="margin-top: 2px;">Var</label>
                                                <div style="width: 20px;"></div>
                                                <div style="width: 24px;">
                                                    <input type="radio" id="rb_tns2" name="rb_tns" label="div_lbl21" class="radio" area="area2" action="go" value="2" onClick="set_transfer_need_situation($(this));" />
                                                </div>
                                                <label for="rb_tns2" style="margin-top: 2px;">Yok</label>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="div_nftd" style="height: 58px;" hidden>
                                        <div id="div_lbl22" class="lbl_norm2" alert="lbl_alrt2">Transfer İhtiyaç Detayı:</div>
                                        <div><input type="text" id="inp_transfer_need_detail" name="inp_transfer_need_detail" label="div_lbl22" area="area2" action="go" class="inp" /></div>
                                    </div>
                                </div>
                            </div>
                            <div align="right" style="width: 50%;">
                                <div align="left" style="width: 97%;">
                                    <div style="height: 58px;">
                                        <div id="div_lbl23" class="lbl_norm2" alert="lbl_alrt2">Ulaşım Yöntemi:</div>
                                        <div>
                                            <input type="hidden" id="inp_transportation_mode" name="inp_transportation_mode" />
                                            <select id="sel_transportation_mode" name="sel_transportation_mode" label="div_lbl23" area="area2" action="go" class="inp"></select>
                                        </div>
                                    </div>
                                    <div style="height: 116px;">
                                        <div id="div_lbl24" class="lbl_norm2" alert="lbl_alrt2">Ulaşım Detayları:</div>
                                        <div><textarea id="txt_transportation_detail" name="txt_transportation_detail" label="div_lbl24" area="area2" action="go" class="inp" style="height: 88px;"></textarea></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div style="height: 10px;"></div>
                    </div>
                    <div id="div_accommodation" hidden>
                        <div align="left" class="blue_line">Konaklama Bilgileri</div>
                        <div style="height: 20px;"></div>
                        <div style="display: flex;">
                            <div align="left" style="width: 50%;">
                                <div align="left" style="width: 97%;">
                                    <div style="height: 58px;">
                                        <div id="div_lbl25" class="lbl_norm2" alert="lbl_alrt2">Konaklama Başlangıç Tarihi:</div>
                                        <div><input type="date" date-group="2" date-type="start_date" id="inp_check-in_date" name="inp_check-in_date" label="div_lbl25" area="area2" action="go" class="inp" /></div>
                                    </div>
                                    <div style="height: 58px;">
                                        <div id="div_lbl26" class="lbl_norm2" alert="lbl_alrt2">Konaklama Bitiş Tarihi:</div>
                                        <div><input type="date" date-group="2" date-type="end_date" id="inp_check-out_date" name="inp_check-out_date" label="div_lbl26" area="area2" action="go" class="inp" /></div>
                                    </div>
                                </div>
                            </div>
                            <div align="right" style="width: 50%;">
                                <div align="left" style="width: 97%;">
                                    <div style="height: 110px;">
                                        <div id="div_lbl27" class="lbl_norm2" alert="lbl_alrt2">Konaklama Detayları:</div>
                                        <div><textarea id="txt_accommodation_detail" name="txt_accommodation_detail" label="div_lbl27" area="area2" action="go" class="inp" style="height: 88px;"></textarea></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div style="height: 10px;"></div>
                    </div>
                    <div id="div_save" hidden>
                        <div class="subheading" style="height: 2px;"></div>
                        <div style="height: 10px;"></div>
                        <div style="display: flex; height: 38px;">
                            <div align="right" style="width: 100%;">
                                <input type="button" id="btn_add_request" area="area2" action="warn" class="btn" value="Kaydet ⮟" onClick="add_request($(this));" />
                            </div>
                        </div>
                    </div>
                    <div style="height: 5px;"></div>
                </form>	
            </div>
            <div id="div_approve_page" hidden></div>
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