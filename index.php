<?php
	require("./library.php");
//	header("Location: ./login.php");
?>
<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=750">

    <title>Ulaşım ve Konaklama - Rezervasyon</title>

    <link rel="stylesheet" type="text/css" href="./css/main.css" />
    <link rel="stylesheet" type="text/css" href="./css/jquery-ui-1.13.3.css" />
    <link rel="stylesheet" type="text/css" href="./css/easy-loading.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="./css/custom_reservation.css" /> <!-- Link to your custom CSS -->

    <script src="./js/jquery-3.7.1.js"></script>
    <script src="./js/jquery-ui-1.13.3.js"></script>

    <script src="./js/jquery.inputmask.min.js"></script>
    <script src="./js/inputmask.binding.js"></script>



    <link rel="stylesheet" type="text/css" href="css/component.css" />
    <script src="js/modernizr.custom.js"></script>

    <script type="text/javascript">

        $(document).ready(function() {

            $('input[type="button"]').on('mouseover', function(event) {
                let div = $(event.target).parent().parent().children('div[id*="div_menu_arrow"]');
                if(div.attr('class') == 'menu_arrow_pasive') {
                    div.show();
                }
            });

            $('input[type="button"]').on('mouseleave', function(event) {
                let div = $(event.target).parent().parent().children('div[id*="div_menu_arrow"]');
                if(div.attr('class') == 'menu_arrow_pasive') {
                    div.hide();
                }
            });

        });

        function load_page(item, iframe, url) {
            if(iframe != '' && url != '') {
                iframe = $('#' + iframe);
                $('#inp_active_frame').val(iframe.attr('id'));

                $('input[type="button"]').attr('style', 'width: 100%;');
                $('div[id*="div_menu_arrow"]').attr('class', 'menu_arrow_pasive');
                $('div[id*="div_menu_arrow"]').hide();

                item.attr('style', 'width: 100%; outline: solid 3px rgba(255, 255, 255, 0.712);');
                item.parent().parent().children('div[id*="div_menu_arrow"]').attr('class', 'menu_arrow_active');
                item.parent().parent().children('div[id*="div_menu_arrow"]').show();
            } else {
                iframe = $('#' + $('#inp_active_frame').val());
            }

            $.each($('iframe[id*="iframe_page"]'),
                function() {
                    if(this.contentWindow.scrollX > 0) {
                        $(this).data('scrollLeft', this.contentWindow.scrollX);
                    }
                    if(this.contentWindow.scrollY > 0) {
                        $(this).data('scrollTop', this.contentWindow.scrollY);
                    }
                }
            );

            $('div[id*="div_frame"]').hide();
            iframe.parent().show();

            if(iframe.attr('src') == '') {
                iframe.attr('src', url);
            } else {
                let scrollLeft = iframe.data('scrollLeft') || 0;
                let scrollTop = iframe.data('scrollTop') || 0;

                iframe[0].contentWindow.scrollTo(scrollLeft, scrollTop);
            }
        }

    </script>
</head>


<body>
    
    <input type="hidden" id="inp_active_frame" value="" />
     <!-- Header-->
<nav class="navbar navbar-default navbar-fixed-top navbar-custom">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center;">
        <!-- Menu Button on the Left -->
        <div id="st-trigger-effects" class="column">
            <button data-effect="st-effect-1" class="touchable-opacity" style="background: none; border: none; padding: 0;">
                <img src="./images/menu.png" alt="Menu" class="btn_menu" style="height: 30px;"/>
            </button>
        </div>

        <!-- System Name and Logo on the Right -->
        <div style="display: flex; align-items: center;">
            <h1 style="margin: 0; font-size: 18px; font-weight: 400; color: #ffffff; margin-right: 20px;">Ulaşım ve Konaklama - Rezervasyon Sistemi</h1>
            <img src="./images/logo.png" alt="Logo" style="height: 50px;" />
        </div>
    </div>
</nav>
    


    
    <div id="st-container" class="st-container">
    <div id="frame_container">
        <nav class="st-menu st-effect-1" id="menu-1">
            <div class="menu_sidebar">
            
                <div>
                <div>
                    <input type="button" class="btn_blue" value="Yeni Talep Oluştur" onClick="load_page($(this), 'iframe_page1', './request_entry_form.php');" />
                    <div id="div_menu_arrow1" class="menu_arrow_pasive">⮞</div>
                </div>
                <div>
                    <input type="button" class="btn_blue" value="Taleplerim" onClick="load_page($(this), 'iframe_page2', './request_list.php?list_type=1');" />
                    <div id="div_menu_arrow2" class="menu_arrow_pasive">⮞</div>
                </div>
                <div>
                    <input type="button" class="btn_blue" value="Rezervasyonlarım" onClick="load_page($(this), 'iframe_page3', './reservation_list.php?list_type=1');" />
                    <div id="div_menu_arrow3" class="menu_arrow_pasive">⮞</div>
                </div>
                <?php	if($_SESSION['executive_person']) { ?>
                <div>
                    <input type="button" class="btn_aquamarine" value="Yeni Rezervasyon Oluştur" onClick="load_page($(this), 'iframe_page4', './reservation_entry_form.php');" />
                    <div id="div_menu_arrow4" class="menu_arrow_pasive">⮞</div>
                </div>
                <?php	} ?>
                <?php	if($_SESSION['authorize_person']) { ?>
                <div>
                    <input type="button" class="btn_aquamarine" value="Onay Bekleyen Talepler" onClick="load_page($(this), 'iframe_page5', './request_list.php?list_type=2&status=11');" />
                    <div id="div_menu_arrow5" class="menu_arrow_pasive">⮞</div>
                </div>
                <div>
                    <input type="button" class="btn_aquamarine" value="Rezervasyon Bekleyen Talepler" onClick="load_page($(this), 'iframe_page6', './request_list.php?list_type=2&status=13');" />
                    <div id="div_menu_arrow6" class="menu_arrow_pasive">⮞</div>
                </div>
                <div>
                    <input type="button" class="btn_aquamarine" value="Talepler" onClick="load_page($(this), 'iframe_page7', './request_list.php?list_type=2');" />
                    <div id="div_menu_arrow7" class="menu_arrow_pasive">⮞</div>
                </div>
                <div>
                    <input type="button" class="btn_aquamarine" value="Rezervasyonlar" onClick="load_page($(this), 'iframe_page8', './reservation_list.php?list_type=2');" />
                    <div id="div_menu_arrow8" class="menu_arrow_pasive">⮞</div>
                </div>
                <?php	} ?>
            </div>
                <div>
                    <input type="button" class="btn_cikis" value="Çıkış" onClick="load_page($(this), 'iframe_page9', './login.php');" />
                    <div id="div_menu_arrow9" class="menu_arrow_pasive">⮞</div>
                </div>
            </div>
            

        </nav>
    

    <div id="div_frame1" class="menu_frame">
        <iframe id="iframe_page1" src=""></iframe>
    </div>
    <div id="div_frame2" class="menu_frame">
        <iframe id="iframe_page2" src=""></iframe>
    </div>
    <div id="div_frame3" class="menu_frame">
        <iframe id="iframe_page3" src=""></iframe>
    </div>
    <div id="div_frame4" class="menu_frame">
        <iframe id="iframe_page4" src=""></iframe>
    </div>
    <div id="div_frame5" class="menu_frame">
        <iframe id="iframe_page5" src=""></iframe>
    </div>
    <div id="div_frame6" class="menu_frame">
        <iframe id="iframe_page6" src=""></iframe>
    </div>
    <div id="div_frame7" class="menu_frame">
        <iframe id="iframe_page7" src=""></iframe>
    </div>
    <div id="div_frame8" class="menu_frame">
        <iframe id="iframe_page8" src=""></iframe>
    </div>
    <div id="div_frame9" class="menu_frame">
        <iframe id="iframe_page9" src=""></iframe>
    </div>
    </div>
    </div>

    <script src="js/classie.js"></script>
    <script src="js/sidebarEffects.js"></script>


    <!-- Footer -->
    <footer
            class="text-center text-lg-start text-white bottom-tab-custom"
            style="background-color: #929fba"
            >
      <!-- Grid container -->
      <div class="container p-4 pb-0">
        <!-- Section: Links -->
        <section class="">
          <!--Grid row-->
          <div class="row">
            <!-- Grid column -->
            <div class="col-md-3 col-lg-3 col-xl-3 mx-auto mt-3">
              <h6 class="text-uppercase mb-4 font-weight-bold">
                Company name
              </h6>
              <p>
                Here you can use rows and columns to organize your footer
                content. Lorem ipsum dolor sit amet, consectetur adipisicing
                elit.
              </p>
            </div>
            <!-- Grid column -->
  
      
  
            <hr class="w-100 clearfix d-md-none" />
  
            <!-- Grid column -->
            <hr class="w-100 clearfix d-md-none" />
  
            <!-- Grid column -->
            <div class="col-md-4 col-lg-3 col-xl-3 mx-auto mt-3">
              <h6 class="text-uppercase mb-4 font-weight-bold">Contact</h6>
              <p><i class="fas fa-home mr-3"></i> New York, NY 10012, US</p>
              <p><i class="fas fa-envelope mr-3"></i> info@gmail.com</p>
              <p><i class="fas fa-phone mr-3"></i> + 01 234 567 88</p>
              <p><i class="fas fa-print mr-3"></i> + 01 234 567 89</p>
            </div>
            <!-- Grid column -->
  
            <!-- Grid column -->
            <!-- Follow us section -->
                <!-- Follow us section -->
<div class="col-md-3 col-lg-2 col-xl-2 mx-auto mt-3">
  <h6 class="text-uppercase mb-4 fw-bold text-center">Follow us</h6>
  <div class="d-flex justify-content-center">
    <!-- Facebook -->
    <a class="btn btn-primary btn-floating m-1 d-flex justify-content-center align-items-center" style="background-color: #3b5998; border-radius: 50%; width: 40px; height: 40px;" href="#!" role="button">
      <i class="fab fa-facebook-f"></i>
    </a>

    <!-- Twitter -->
    <a class="btn btn-primary btn-floating m-1 d-flex justify-content-center align-items-center" style="background-color: #55acee; border-radius: 50%; width: 40px; height: 40px;" href="#!" role="button">
      <i class="fab fa-twitter"></i>
    </a>

    <!-- Google -->
    <a class="btn btn-primary btn-floating m-1 d-flex justify-content-center align-items-center" style="background-color: #dd4b39; border-radius: 50%; width: 40px; height: 40px;" href="#!" role="button">
      <i class="fab fa-google"></i>
    </a>

    <!-- Instagram -->
    <a class="btn btn-primary btn-floating m-1 d-flex justify-content-center align-items-center" style="background-color: #ac2bac; border-radius: 50%; width: 40px; height: 40px;" href="#!" role="button">
      <i class="fab fa-instagram"></i>
    </a>

    <!-- Linkedin -->
    <a class="btn btn-primary btn-floating m-1 d-flex justify-content-center align-items-center" style="background-color: #0082ca; border-radius: 50%; width: 40px; height: 40px;" href="#!" role="button">
      <i class="fab fa-linkedin-in"></i>
    </a>

  </div>
</div>

  
          </div>
          <!--Grid row-->
        </section>
        <!-- Section: Links -->
      </div>
      <!-- Grid container -->
  
      <!-- Copyright -->
      <div
           class="text-center p-3"
           style="background-color: rgba(0, 0, 0, 0.2)"
           >
        © 2024 Copyright:
        <a class="text-white" href=""
           >MLPCare.com</a
          >
      </div>
      <!-- Copyright -->
    </footer>
    <!-- Footer -->

</body>
</html>