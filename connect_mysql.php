<?php
    require("params.php");

	function get_mysql_connection() {
        global $_PARAM;

		$servername = $_PARAM['dbServerName'];
		$database = $_PARAM['dbName'];
		$username = $_PARAM['dbUsername'];
		$password = $_PARAM['dbPassword'];

		try {
			$connection = new PDO("mysql:host=$servername;dbname=$database;charset=utf8", $username, $password);

			// set the PDO error mode to exception
			$connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

			//echo "Connected successfully<br/><br/>";
			return $connection;
		} catch(PDOException $e) {
			return false;
			//echo "Connection failed: " . $e->getMessage();
		}
	}
?>