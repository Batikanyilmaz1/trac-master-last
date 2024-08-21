function validation() {
    let username = document.getElementById("username").value;
    let pass = document.getElementById("password").value;
    if (username != "" && pass != "") {
        document.getElementById("btn_login").disabled = false;
    } else {
        document.getElementById("btn_login").disabled = true;
    }
}