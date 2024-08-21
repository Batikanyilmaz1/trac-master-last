<?php   $mail_view = $_GET['mail_view'] ?? '0'; ?>
<?php	if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { ?>
    <div id="div_row_frame_<?php echo $i; ?>" class="row<?php echo ($i % 2) + 1; ?>">
        <div style="height: 10px;"></div>
        <div id="div_reservation_top_<?php echo $i; ?>" style="height: 20px;"<?php if($list_type != '0' && $mail_view == '0') { echo ' hidden'; } ?>></div>
<?php	} ?>
        <div onClick="slide_reservation('<?php echo $i; ?>');">
            <div class="row_title" style="display: flex;">
                <div align="left">
                    <div class="databox1" style="width: 1px;">
                        <div class="databox_label1" style="border-left: solid 1px red; border-right: none;"></div>
                        <div class="databox_value1" style="border-left: solid 1px green; border-right: none;"></div>
                    </div>
                </div>
<?php	if($list_type != '0') { ?>
                <div align="left" style="width: <?php if($list_type == '3') { echo '33'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Rezervasyon Numarası:</div>
                        <div class="databox_value1"><?php echo $reservation['ID']; ?></div>
                    </div>
                </div>
<?php	} ?>
                <div align="left" style="width: <?php if($list_type == '0') { echo '50'; } else if($list_type == '3') { echo '33'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Rezervasyon Tarihi:</div>
                        <div class="databox_value1"><?php echo date('d.m.Y H:i:s', strtotime($reservation['CREATION_TIME'])); ?></div>
                    </div>
                </div>
<?php	if($list_type == '1' || $list_type == '2') { ?>
                <div align="left" style="width: 20%;">
                    <div class="databox1">
                        <div class="databox_label1">Rezervasyon Durumu:</div>
                        <div class="databox_value1"><?php echo $reservation['STATUS']; ?></div>
                    </div>
                </div>
                <div align="left" style="width: 20%;">
                    <div class="databox1">
                        <div class="databox_label1">Talep Sahibi:</div>
                        <div class="databox_value1"><?php echo $reservation['USER']; ?></div>
                    </div>
                </div>
<?php	} ?>
                <div align="left" style="width: <?php if($list_type == '0') { echo '50'; } else if($list_type == '3') { echo '34'; } else { echo '20'; } ?>%;">
                    <div class="databox1">
                        <div class="databox_label1">Seyahat Rotası:</div>
                        <div class="databox_value1"><?php echo $reservation['ROUTE']; ?></div>
                    </div>
                </div>
            </div>
            <div style="height: 10px;"></div>
        </div>
        <div id="div_reservation_<?php echo $i; ?>"<?php if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { echo ' hidden'; } ?>>
<?php	if($reservation['TRANSPORTATION']) { ?>
            <div id="div_transportation">
                <div class="subheading">Ulaşım Bilgileri</div>
                <div style="height: 10px;"></div>
                <div style="display: flex;">
                    <div align="center" style="width: 49%;">
                        <div align="left" class="lbl_norm2" style="height: 17px; padding-left: 5px; padding-top: 2px; border: solid 2px #196a2c98; background-color: #196a2c98; color: rgb(0, 0, 0); font-weight: bold;">Gidiş</div>
                    </div>
                    <div style="width: 2%;"></div>
                    <div align="center" style="width: 49%;">
                        <div align="left" class="lbl_norm2" style="height: 17px; padding-left: 5px; padding-top: 2px; border: solid 2px red; background-color: #F88284; color: black; font-weight: bold;">Dönüş</div>
                    </div>
                </div>
                <div style="display: flex;">
                    <div align="center" style="width: 49%;">
                        <div style="height: 100%; border: solid 1px green;">
                            <div style="height: 12px;"></div>
                            <div align="left" style="width: 90%;">
                                <div class="databox2" style="height: 1px;">
                                    <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                    <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                </div>
<?php		if($reservation['DEPARTURE_TRANSPORTATION_MODE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Ulaşım Yöntemi:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_TRANSPORTATION_MODE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_PORT']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Kalkış Yeri:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_PORT']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_COMPANY']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Seyahat Firması:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_COMPANY']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_PNR_CODE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">PNR Kodu:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_PNR_CODE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_TICKET_NUMBER']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Bilet Numarası:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_TICKET_NUMBER']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_TICKET_PRICE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Fiyat Bilgisi:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_TICKET_PRICE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_CAR_LICENSE_PLATE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Araç Plakası:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_CAR_LICENSE_PLATE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['DEPARTURE_DATE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Gidiş Tarihi:</div>
                                    <div class="databox_value2"><?php echo $reservation['DEPARTURE_DATE'] ? date('d.m.Y H:i', strtotime($reservation['DEPARTURE_DATE'])) : ''; ?></div>
                                </div>
<?php		} ?>
                            </div>
                            <div style="height: 12px;"></div>
                        </div>
                    </div>
                    <div style="width: 2%;"></div>
                    <div align="center" style="width: 49%;">
                        <div style="height: 100%; border: solid 1px red;">
                            <div style="height: 12px;"></div>
                            <div align="left" style="width: 90%;">
                                <div class="databox2" style="height: 1px;">
                                    <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                    <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                </div>
<?php		if($reservation['RETURN_TRANSPORTATION_MODE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Ulaşım Yöntemi:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_TRANSPORTATION_MODE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_PORT']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Kalkış Yeri:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_PORT']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_COMPANY']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Seyahat Firması:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_COMPANY']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_PNR_CODE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">PNR Kodu:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_PNR_CODE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_TICKET_NUMBER']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Bilet Numarası:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_TICKET_NUMBER']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_TICKET_PRICE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Fiyat Bilgisi:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_TICKET_PRICE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_CAR_LICENSE_PLATE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Araç Plakası:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_CAR_LICENSE_PLATE']; ?></div>
                                </div>
<?php		} ?>
<?php		if($reservation['RETURN_DATE']) { ?>
                                <div class="databox2">
                                    <div class="databox_label2">Dönüş Tarihi:</div>
                                    <div class="databox_value2"><?php echo $reservation['RETURN_DATE'] ? date('d.m.Y H:i', strtotime($reservation['RETURN_DATE'])) : ''; ?></div>
                                </div>
<?php		} ?>
                            </div>
                            <div style="height: 12px;"></div>
                        </div>
                    </div>
                </div>
            </div>
<?php	} ?>
<?php	if($reservation['ACCOMMODATION']) { ?>
            <div id="div_accommodation">
                <div style="height: 10px;"></div>
                <div align="left" class="blue_line">Konaklama Bilgileri</div>
                <div style="height: 10px;"></div>
                <div align="left" class="lbl_norm2" style="height: 17px; padding-left: 5px; padding-top: 2px; border: solid 2px #0d78ae97; background-color: #0d78ae97; color: black; font-weight: bold;">Otel</div>
                <div style="display: flex; border: dotted 2px #0d78ae97;">
                    <div align="center" style="width: 49%;">
                        <div style="height: 12px;"></div>
                        <div align="left" style="width: 90%;">
                            <div class="databox2" style="height: 1px;">
                                <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                            </div>
                            <div class="databox2">
                                <div class="databox_label2">Giriş Tarihi:</div>
                                <div class="databox_value2"><?php echo $reservation['CHECK-IN_DATE'] ? date('d.m.Y H:i', strtotime($reservation['CHECK-IN_DATE'])) : ''; ?></div>
                            </div>
                            <div class="databox2">
                                <div class="databox_label2">Adı:</div>
                                <div class="databox_value2"><?php echo $reservation['HOTEL_NAME']; ?></div>
                            </div>
                        </div>
                        <div style="height: 12px;"></div>
                    </div>
                    <div style="width: 2%;"></div>
                    <div align="center" style="width: 49%;">
                        <div style="height: 12px;"></div>
                        <div align="left" style="width: 90%;">
                            <div class="databox2" style="height: 1px;">
                                <div class="databox_label2" style="border-left: none; border-right: none; padding: 0px;"></div>
                                <div class="databox_value2" style="border-left: none; border-right: none; padding: 0px;"></div>
                            </div>
                            <div class="databox2">
                                <div class="databox_label2">Çıkış Tarihi:</div>
                                <div class="databox_value2"><?php echo $reservation['CHECK-OUT_DATE'] ? date('d.m.Y H:i', strtotime($reservation['CHECK-OUT_DATE'])) : ''; ?></div>
                            </div>
                        </div>
                        <div style="height: 12px;"></div>
                    </div>
                </div>
            </div>
<?php	} ?>
<?php	if($list_type == '1' || $list_type == '2') { ?>
            <div style="height: 10px;"></div>
            <div class="subheading" style="height: 2px;"></div>
            <div style="height: 10px;"></div>
            <form id="form<?php echo $i; ?>" method="post" enctype="multipart/form-data" index="<?php echo $i; ?>">
                <div id="div_approval_buttons_<?php echo $i; ?>" align="center">
                    <div style="display: flex; width: 100%;">
                        <div style="width: 50%;">
                            <div style="display: flex; justify-content: flex-start;">
                                <div>
                                    <input type="button" id="btn_request_detail" index="<?php echo $i; ?>" requestid="<?php echo $reservation['REQUEST_ID']; ?>" class="btn_blue" style="width: 190px;" value="Talep Detaylarını Göster  &#128065;" onClick="toggle_request_detail($(this));" />
                                </div>
                            </div>
                        </div>
<?php		if($list_type == '2' && $reservation['STATUS_ID'] == '21') { ?>
                        <div style="width: 50%;">
                            <div style="display: flex; justify-content: flex-end;">
                                <div>
                                    <input type="button" id="btn_cancel" index="<?php echo $i; ?>" reservationid="<?php echo $reservation['ID']; ?>" class="btn_red" style="width: 190px;" value="Rezervasyonu İptal Et  ✖" onclick="open_manager_process($(this));" />
                                </div>
                            </div>
                        </div>
<?php		} ?>
                    </div>
                </div>
<?php		if($mail_view == '0') { ?>
                <div id="div_request_detail_<?php echo $i; ?>" style="border: solid 1px green; padding: 20px; margin-top: 10px; margin-bottom: 30px;" hidden></div>
                <div id="div_manager_process_<?php echo $i; ?>" style="height: 150px;" hidden></div>
<?php		} ?>
            </form>
<?php	} else if($mail_view == '1') { ?>
            <div style="height: 30px;"></div>
<?php	} ?>
        </div>
<?php	if(($list_type == '1' || $list_type == '2') && $mail_view == '0') { ?>
    </div>
<?php	} ?>
