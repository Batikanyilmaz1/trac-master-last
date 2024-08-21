<?php
	session_start();
	session_unset();
?>
<!doctype HTML 4.01 Transitional>
<html xmlns="http://www.w3.org/2001/XMLSchema">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Ulaşım ve Konaklama - Giriş</title>

    <link rel="stylesheet" href="css/login.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="./css/jquery-ui-1.13.3.css" />
    <link rel="stylesheet" type="text/css" href="./css/easy-loading.css" />

    <script src="./js/jquery-3.7.1.js"></script>
    <script src="./js/jquery-ui-1.13.3.js"></script>
    <script src="js/index.js"></script>
    <script src="./js/jquery.inputmask.min.js"></script>
    <script src="./js/inputmask.binding.js"></script>

    <script type="text/javascript">
        function login() {
            if($('#username').val() == '') {
                $('#username').attr('placeholder', 'Lütfen doldurunuz');
                $('#username').focus();
            } else if($('#password').val() == '') {
                $('#password').attr('placeholder', 'Lütfen doldurunuz');
                $('#password').focus();
            } else {
                var username = $('#username').val();
                var password = $('#password').val();

                $.getJSON('./win_auth.php?username=' + encodeURIComponent(username) + '&password=' + encodeURIComponent(password),
                    function(data) {
                        if(data.Rows) {
                            var rowData = data.Rows[0];
                            if(rowData.err_code == "0") {
                                window.location.assign('./index.php');
                            } else {
                                $('#check_auth').html(rowData.msg);
                                $('#div_error_msg').show();
                            }
                        }
                    }
                );
            }
        }

    </script>
</head>

<body>
    <section>
        
        <header>
            <div class="header-content">
                <h1>Ulasım ve Konaklama Otomasyonu</h1>
            </div>
        </header>
        <div class="box">

            <div class="form">
                <img src="images/_user.jpg" class="user" alt="">
                <h2>Hoş Geldiniz!</h2>
                <form class="" action="index.html" method="post" enctype="multipart/form-data">
                    <!-- {% csrf_token %} -->
                    <div class="inputBx">
                        <input type="text" name="username" placeholder="Username" id="username" oninput="validation()" required autofocus>
                        <img src="images/user.png" alt="">
                    </div>
                    <div class="inputBx">
                        <input type="password" name="password" id="password" placeholder="Password" oninput="validation()" required>
                        <img src="images/lock.png" alt="">
                    </div>
                    <label class="remeber"><input type="checkbox"> Beni Hatırla</label>
                    <div class="inputBx">
                        <input type="submit" name="submit" value="Giriş" id="btn_login" onClick="login();" disabled>
                    </div>
                </form>
                <p> <a href="#">Şifremi Unuttum</a>!</p>
                <p> Hesabın mı yok? <a href="#">Hemen Kayıt Ol!</a></p>

            </div>

        </div>
    </section>

</body>
</html>