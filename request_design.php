<link rel="stylesheet" type="text/css" href="./css/main.css" /> <!--new -->

<?php   $mail_view = $_GET['mail_view'] ?? '0'; ?>
<?php	if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { ?>
    <div id="div_row_frame_<?php echo $i; ?>" class="row<?php echo ($i % 2) + 1; ?>">
        <div style="height: 10px;"></div>
        <div id="div_request_top_<?php echo $i; ?>" style="height: 20px;"<?php if($list_type != '0' && $mail_view == '0') { echo ' hidden'; } ?>></div>
<?php	} ?>
        <div onClick="slide_request($('#div_request_top_<?php echo $i; ?>'), $('#div_request_<?php echo $i; ?>'));">
            <div class="row_title" style="display: flex;">
                <div align="left">
                    <div class="databox1" style="width: 1px;">
                        <div class="databox_label1" ></div>
                        <div class="databox_value1"></div>
                    </div>
                </div>
<?php	if($list_type != '0') { ?>
                <div align="left" style="width: <?php if($list_type == '3') { echo '33'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Talep Numarası:</div>
                        <div class="databox_value1"><?php echo $request['ID']; ?></div>
                    </div>
                </div>
<?php	} ?>
                <div align="left" style="width: <?php if($list_type == '0') { echo '50'; } else if($list_type == '3') { echo '33'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Talep Tarihi:</div>
                        <div class="databox_value1"><?php echo date('d.m.Y H:i:s', strtotime($request['CREATION_TIME'])); ?></div>
                    </div>
                </div>
<?php	if($list_type == '1' || $list_type == '2') { ?>
<?php		if($list_type == '2') { ?>
                <div align="left" style="width: 20%;">
                    <div class="databox1">
                        <div class="databox_label1">Talep Sahibi:</div>
                        <div class="databox_value1"><?php echo $request['USER']; ?></div>
                    </div>
                </div>
<?php		} ?>
                <div align="left" style="width: 20%;">
                    <div class="databox1">
                        <div class="databox_label1">Talep Durumu:</div>
                        <div class="databox_value1"><?php echo $request['STATUS']; ?></div>
                    </div>
                </div>
<?php		if($list_type == '1') { ?>
                <div align="left" style="width: 20%;">
                    <div class="databox1">
                        <div class="databox_label1">Yetkili Kişi:</div>
                        <div class="databox_value1"><?php echo $request['AUTHORIZED_USER']; ?></div>
                    </div>
                </div>
<?php		} ?>
<?php	} ?>
                <div align="left" style="width: <?php if($list_type == '0') { echo '50'; } else if($list_type == '3') { echo '34'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Seyahat Rotası:</div>
                        <div class="databox_value1"><?php echo $request['ROUTE']; ?></div>
                    </div>
                </div>
            </div>
            <div style="height: 10px;"></div>
        </div>
        <div id="div_request_<?php echo $i; ?>"<?php if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { echo ' hidden'; } ?>>
            <div class="subheading">Seyahat Edecekler</div>
            <div style="height: 10px;"></div>
            <div align="left" style="overflow: auto;">
                <table class="a_trv_tbl">
                    <thead>
                        <tr class="trv_thead">
                            <th class="a_trv_cell_th"></th>
                            <th class="a_trv_cell_th">Adı</th>
                            <th class="a_trv_cell_th">Soyadı</th>
                            <th class="a_trv_cell_th">Doğum Tarihi</th>
                            <th class="a_trv_cell_th">Telefon No</th>
                            <th class="a_trv_cell_th">Mail Adresi</th>
                        </tr>
                    </thead>
                    <tbody>
<?php	foreach($travelers as $traveler) { ?>
                        <tr class="trv_tbody">
                            <td class="a_trv_cell_tb"><?php echo $traveler['TYPE']; ?></td>
                            <td class="a_trv_cell_tb"><?php echo $traveler['NAME']; ?></td>
                            <td class="a_trv_cell_tb"><?php echo $traveler['SURNAME']; ?></td>
                            <td class="a_trv_cell_tb"><?php echo date('d.m.Y', strtotime($traveler['BIRTH_DATE'])); ?></td>
                            <td class="a_trv_cell_tb"><?php echo $traveler['PHONE']; ?></td>
                            <td class="a_trv_cell_tb"><?php echo $traveler['EMAIL']; ?></td>
                        </tr>
<?php	} ?>
                    </tbody>
                </table>
            </div>
            <div style="height: 10px;"></div>
            <div class="subheading">Seyahat Bilgileri</div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div align="left" style="width: 49%;">
                    <div style="height: 20px; padding-left: 5px; padding-top: 4px; border: solid 2px #0d78ae97; border-bottom: none; background-color: #0d78ae97; color: #000000; font-weight: bold;">Nereden</div>
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php	if($request['FROM_COUNTRY'] && $request['ROUTE_ID'] == 2) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Ülke:</div>
                        <div class="databox_value2"><?php echo $request['FROM_COUNTRY']; ?></div>
                    </div>
<?php	} ?>
<?php	if($request['FROM_CITY']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Şehir:</div>
                        <div class="databox_value2"><?php echo $request['FROM_CITY']; ?></div>
                    </div>
<?php	} ?>
<?php	if($request['FROM_LOCATION']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Lokasyon:</div>
                        <div class="databox_value2"><?php echo $request['FROM_LOCATION']; ?></div>
                    </div>
<?php	} ?>
                </div>
                <div style="width: 2%;"></div>
                <div align="left" style="width: 49%;">
                    <div style="height: 20px; padding-left: 5px; padding-top: 4px; border: solid 2px #196a2c98; border-bottom: none; background-color: #196a2c98; color: #000000; font-weight: bold;">Nereye</div>
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php	if($request['TO_COUNTRY'] && $request['ROUTE_ID'] == 2) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Ülke:</div>
                        <div class="databox_value2"><?php echo $request['TO_COUNTRY']; ?></div>
                    </div>
<?php	} ?>
<?php	if($request['TO_CITY']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Şehir:</div>
                        <div class="databox_value2"><?php echo $request['TO_CITY']; ?></div>
                    </div>
<?php	} ?>
<?php	if($request['TO_LOCATION']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Lokasyon:</div>
                        <div class="databox_value2"><?php echo $request['TO_LOCATION']; ?></div>
                    </div>
<?php	} ?>
                </div>
            </div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div align="left" style="width: 49%;">
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php	if($request['REASON']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Seyahat Nedeni:</div>
                        <div class="databox_value2"><?php echo $request['REASON']; ?></div>
                    </div>
<?php	} ?>
                </div>
            </div>
<?php	if($request['TRANSPORTATION']) { ?>
            <div style="height: 10px;"></div>
            <div class="subheading">Ulaşım Bilgileri</div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div align="left" style="width: 49%;">
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php		if($request['DEPARTURE_DATE']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Gidiş Tarihi:</div>
                        <div class="databox_value2"><?php echo date('d.m.Y', strtotime($request['DEPARTURE_DATE'])); ?></div>
                    </div>
<?php		} ?>
<?php		if($request['RETURN_DATE']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Dönüş Tarihi:</div>
                        <div class="databox_value2"><?php echo date('d.m.Y', strtotime($request['RETURN_DATE'])); ?></div>
                    </div>
<?php		} ?>
                </div>
                <div style="width: 2%;"></div>
                <div align="left" style="width: 49%;">
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
                    <div class="databox2">
<?php		if($request['TRANSPORTATION_MODE']) { ?>
                        <div class="databox_label2">Ulaşım Yöntemi:</div>
                        <div class="databox_value2"><?php echo $request['TRANSPORTATION_MODE']; ?></div>
                    </div>
<?php		} ?>
<?php		if($request['TRANSPORTATION_DETAIL']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Ulaşım Detayları:</div>
                        <div class="databox_value2"><?php echo $request['TRANSPORTATION_DETAIL']; ?></div>
                    </div>
<?php		} ?>
                </div>
            </div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div align="left" style="width: 49%;">
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php		if($request['TRANSFER_NEED_SITUATION']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Transfer İhtiyacı:</div>
                        <div class="databox_value2"><?php echo $request['TRANSFER_NEED_SITUATION']; ?></div>
                    </div>
<?php		} ?>
<?php		if($request['TRANSFER_NEED_DETAIL']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Transfer Detayı:</div>
                        <div class="databox_value2"><?php echo $request['TRANSFER_NEED_DETAIL']; ?></div>
                    </div>
<?php		} ?>
                </div>
            </div>
<?php	} ?>
<?php	if($request['ACCOMMODATION']) { ?>
            <div style="height: 10px;"></div>
            <div class="subheading">Konaklama Bilgileri</div>
            <div style="height: 10px;"></div>
            <div style="display: flex;">
                <div align="left" style="width: 49%;">
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
<?php		if($request['CHECK-IN_DATE']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Başlangıç Tarihi:</div>
                        <div class="databox_value2"><?php echo date('d.m.Y', strtotime($request['CHECK-IN_DATE'])); ?></div>
                    </div>
<?php		} ?>
<?php		if($request['CHECK-OUT_DATE']) { ?>
                    <div class="databox2">
                        <div class="databox_label2">Bitiş Tarihi:</div>
                        <div class="databox_value2"><?php echo date('d.m.Y', strtotime($request['CHECK-OUT_DATE'])); ?></div>
                    </div>
<?php		} ?>
                </div>
                <div style="width: 2%;"></div>
                <div align="left" style="width: 49%;">
<?php		if($request['ACCOMMODATION_DETAIL']) { ?>
                    <div class="databox2" style="height: 1px;">
                        <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                        <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                    </div>
                    <div class="databox2">
                        <div class="databox_label2">Konaklama Detayları:</div>
                        <div class="databox_value2"><?php echo $request['ACCOMMODATION_DETAIL']; ?></div>
                    </div>
<?php		} ?>
                </div>
            </div>
<?php	} ?>
<?php	if(($list_type == '1' && $request['STATUS_ID'] == '14') || ($list_type == '2' && ($request['STATUS_ID'] == '11' || $request['STATUS_ID'] == '13' || $request['STATUS_ID'] == '14'))) { ?>
            <div style="height: 10px;"></div>
<?php		if($request['STATUS_ID'] == '11' || ($request['STATUS_ID'] == '14' && $mail_view == '0')) { ?>
            <div class="subheading" style="height: 2px;"></div>
            <div style="height: 10px;"></div>
<?php		} ?>
            <form id="form<?php echo $i; ?>" method="post" enctype="multipart/form-data" index="<?php echo $i; ?>">
                <div id="div_approval_buttons_<?php echo $i; ?>" align="center">
                    <div style="display: flex; width: 100%;">
                        <div style="width: 50%;">
                            <div style="display: flex; justify-content: flex-start;">
<?php		if($request['STATUS_ID'] == '14' && $mail_view == '0') { ?>
                                <div>
                                    <input type="button" id="btn_reservation_detail" index="<?php echo $i; ?>" reservationid="<?php echo $request['RESERVATION_ID']; ?>" class="btn" style="width: 220px;" value="Rezervasyon Detaylarını Göster  &#128065;" onClick="toggle_reservation_detail($(this));" />
                                </div>
<?php		} ?>
                            </div>
                        </div>
                        <div style="width: 50%;">
                            <div align="right" style="width: 100%;">
                            <div style="display: flex; justify-content: flex-end;">
<?php		if($list_type == '2') { ?>
<?php			if($request['STATUS_ID'] == '11') { ?>
<?php				if($mail_view == '0') { ?>
                                <div>
                                    <input type="button" id="btn_reject" index="<?php echo $i; ?>" requestid="<?php echo $request['ID']; ?>" class="btn_red" value="Ret  ✖" onclick="open_manager_process($(this), '<?php echo $_SESSION['user_uuid'] . '-' . $request['REQ_UUID'] . '-' . $request['RAD_UUID']; ?>', 'reject');" />
                                </div>
                                <div style="width: 15px;"></div>
                                <div>
                                    <input type="button" id="btn_revise" index="<?php echo $i; ?>" requestid="<?php echo $request['ID']; ?>" class="btn_yellow" value="Revize  ✎" onclick="open_manager_process($(this), '<?php echo $_SESSION['user_uuid'] . '-' . $request['REQ_UUID'] . '-' . $request['RAD_UUID']; ?>', 'revise');" />
                                </div>
                                <div style="width: 15px;"></div>
                                <div>
                                    <input type="button" id="btn_approve" index="<?php echo $i; ?>" requestid="<?php echo $request['ID']; ?>" class="btn_green" value="Onay  ✔" onclick="open_manager_process($(this), '<?php echo $_SESSION['user_uuid'] . '-' . $request['REQ_UUID'] . '-' . $request['RAD_UUID']; ?>', 'approve');" />
                                </div>
<?php				} else if($mail_view == '1') { ?>
                                <div style="width: 105px;"></div>
                                <div>
                                    <a href="<?php echo $reject_link; ?>" target="_blank"><input type="button" id="btn_reject" class="btn_red" value="Ret  ✖" /></a>
                                </div>
                                <div style="width: 15px;"></div>
                                <div>
                                    <a href="<?php echo $revise_link; ?>" target="_blank"><input type="button" id="btn_revise" class="btn_yellow" value="Revize  ✎" /></a>
                                </div>
                                <div style="width: 15px;"></div>
                                <div>
                                    <a href="<?php echo $approve_link; ?>" target="_blank"><input type="button" id="btn_approve" class="btn_green" value="Onay  ✔" /></a>
                                </div>
<?php				} ?>
<?php			} else if($request['STATUS_ID'] == '13') { ?>
                                <div>
                                    <input type="button" id="btn_cancel" index="<?php echo $i; ?>" requestid="<?php echo $request['ID']; ?>" class="btn_red" style="width: 150px;" value="Talebi İptal Et  ✖" onclick="open_manager_process($(this), '<?php echo $_SESSION['user_uuid'] . '-' . $request['REQ_UUID'] . '-' . $request['RAD_UUID']; ?>', 'cancel');" />
                                </div>
                                <div style="width: 15px;"></div>
                                <div>
                                    <input type="button" id="btn_reservation" class="btn_blue" style="width: 150px;" value="Rezervasyon Oluştur  ✚" onclick="parent.load_page($(this), 'iframe_page', './reservation_entry_form.php?request_id=<?php echo $request['ID']; ?>');" />
                                </div>
<?php			} ?>
<?php		} ?>
                            </div></div>
                        </div>
                    </div>
                </div>
<?php		if($mail_view == '0') { ?>
                <div id="div_reservation_detail_<?php echo $i; ?>" style="border: solid 1px green; padding: 20px; margin-top: 10px; margin-bottom: 30px;" hidden></div>
                <div id="div_manager_process_<?php echo $i; ?>" style="height: 150px;" hidden></div>
<?php		} ?>
            </form>
<?php	} else if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { ?>
            <div style="height: 30px;"></div>
<?php	} ?>
        </div>
<?php	if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { ?>
    </div>
<?php	} ?>
