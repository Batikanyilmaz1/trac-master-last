<?php
	function gen_uuid() {
		return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
			// 32 bits for "time_low"
			mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),

			// 16 bits for "time_mid"
			mt_rand( 0, 0xffff ),

			// 16 bits for "time_hi_and_version",
			// four most significant bits holds version number 4
			mt_rand( 0, 0x0fff ) | 0x4000,

			// 16 bits, 8 bits for "clk_seq_hi_res",
			// 8 bits for "clk_seq_low",
			// two most significant bits holds zero and one for variant DCE1.1
			mt_rand( 0, 0x3fff ) | 0x8000,

			// 48 bits for "node"
			mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
		);
	}

	function set_null($variable) {
		if(empty($variable) || $variable == '' || $variable == 0) {
			return null;
		} else {
			return $variable;
		}
	}

	function translate_turkish_char($input) {
		$trans = array(
			'ı' => 'i', 'ğ' => 'g', 'ü' => 'u', 'ş' => 's', 'ö' => 'o', 'ç' => 'c',
			'İ' => 'I', 'Ğ' => 'G', 'Ü' => 'U', 'Ş' => 'S', 'Ö' => 'O', 'Ç' => 'C'
		);

		return strtr($input, $trans);
	}

	function resolve_account_name($email) {
		$email = str_replace('@mlpcare.com', '', $email);
		$email = str_replace('@medicalpark.com.tr', '', $email);
		$email = str_replace('@livhospital.com.tr', '', $email);
		$email = str_replace('@iauh.com.tr', '', $email);
		$email = str_replace('@isu.edu.tr', '', $email);

		return $email;
	}

	function resolve_name_surname($displayname, $surname) {
		$surname = preg_replace('/\d/', '', $surname);
		$pos = iconv_strrpos(strtoupper(translate_turkish_char($displayname)), strtoupper(translate_turkish_char($surname)));
		if($pos > 0) {
			$fullname['name'] = Transliterator::create('tr-upper')->transliterate(trim(mb_substr($displayname, 0, $pos)));
			$fullname['surname'] = Transliterator::create('tr-upper')->transliterate(mb_substr($displayname, $pos, mb_strlen($displayname) - $pos));
			//$fullname['surname'] = Transliterator::create('tr-upper')->transliterate(mb_substr($displayname, $pos, mb_strlen($surname)));
		} else {
			$fullname['name'] = Transliterator::create('tr-upper')->transliterate($displayname);
			$fullname['surname'] = Transliterator::create('tr-upper')->transliterate($surname);
		}

		return $fullname;
	}

	function get_user_info_from_ad($ldapConn, $filter) {
		global $_PARAM;

		$result = ldap_search($ldapConn, $_PARAM['ldapBase'], $filter, $_PARAM['ldapAttributes']); // or exit("LDAP sunucusunda arama yapılamıyor.");

		if($result) {
			$entries = ldap_get_entries($ldapConn, $result);

			if($entries['count'] > 0) {
				if($entries['count'] > 1) {
					for($i = 0; $i < $entries['count']; $i++) {
						if(array_key_exists('sn', $entries[$i])) {
							$entries = $entries[$i];
							break;
						}
					}
				} else {
					$entries = $entries[0];
				}

				if(array_key_exists('displayname', $entries)) {
					$displayname = $entries['displayname'][0];
				}

				if(array_key_exists('sn', $entries)) {
					$surname = $entries['sn'][0];
				}

				if(array_key_exists('mail', $entries)) {
					$email = strtolower($entries['mail'][0]);
				}

				if(array_key_exists('title', $entries)) {
					$position = str_replace('.', '', $entries['title'][0]);
				}

				if(array_key_exists('department', $entries)) {
					$department = $entries['department'][0];
				}

				if(array_key_exists('physicaldeliveryofficename', $entries)) {
					$location = $entries['physicaldeliveryofficename'][0];
				}

				if(array_key_exists('manager', $entries)) {
					// echo "<b>manager</b>\r";
					$filter = "CN=" . substr($entries['manager'][0], 3, strpos($entries['manager'][0], ',') - 3);
					$manager_info = get_user_info_from_ad($ldapConn, $filter);
				}

				$fullname = resolve_name_surname($displayname, $surname);

				return array('displayname' => $displayname ?? '', 'sn' => $surname ?? '', 'name' => $fullname['name'] ?? '', 'surname' => $fullname['surname'] ?? '', 'mail' => $email ?? '', 'position' => $position ?? '', 'department' => $department ?? '', 'location' => $location ?? '', 'manager' => $manager_info ?? '');
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	function get_ldap_information($ldapUser, $ldapPassword, $filter) {
		global $_PARAM;

		// LDAP bağlantısını oluştur
		$ldapConn = ldap_connect($_PARAM['ldapHost'], $_PARAM['ldapPort']);

		if($ldapConn) {
			// echo("LDAP bağlantısı başarılı.\r");

			// LDAP bağlantısını yapılandır
			ldap_set_option($ldapConn, LDAP_OPT_PROTOCOL_VERSION, 3);
			ldap_set_option($ldapConn, LDAP_OPT_REFERRALS, 0);

			// Kullanıcı doğrulama
			$ldapBind = ldap_bind($ldapConn, $_PARAM['ldapDomainName'] . '\\' . $ldapUser, $ldapPassword);

			$user_info = get_user_info_from_ad($ldapConn, $filter);

			// LDAP bağlantısını kapat
			ldap_close($ldapConn);

			if($user_info) {
				// Kullanıcı doğrulama başarılı
				return $user_info;
			} else {
				// Kullanıcı doğrulama başarısız
				return false;
			}
		} else {
			// echo("LDAP bağlantısı başarısız.\r");
			return false;
		}
	}

	function handle_user_login($username, $user_info) {

		$conn = get_mysql_connection();

		if($conn) {
			$uuid = gen_uuid();

			// Prosedürü çağır (User kontrol et / yoksa ekle)
			$stmt = $conn->prepare("CALL HANDLE_USER_LOGIN(:uuid, :username, :name, :surname, :mail, :position, :department, :location, @oUserId, @oUUID, @oAuthorizePerson, @oExecutivePerson)");
			$stmt->bindParam(':uuid', $uuid, PDO::PARAM_STR);
			$stmt->bindParam(':username', $username, PDO::PARAM_STR);
			$stmt->bindParam(':name', $user_info['name'], PDO::PARAM_STR);
			$stmt->bindParam(':surname', $user_info['surname'], PDO::PARAM_STR);
			$stmt->bindParam(':mail', $user_info['mail'], PDO::PARAM_STR);
			$stmt->bindParam(':position', $user_info['position'], PDO::PARAM_STR);
			$stmt->bindParam(':department', $user_info['department'], PDO::PARAM_STR);
			$stmt->bindParam(':location', $user_info['location'], PDO::PARAM_STR);
			$stmt->execute();
			$stmt->closeCursor();

			// OUT parametresini al (oUserId)
			$stmt = $conn->query("SELECT @oUserId AS userid, @oUUID AS user_uuid, @oAuthorizePerson AS authorize_person, @oExecutivePerson AS executive_person");
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$_SESSION['userid'] = $row['userid'];
			$_SESSION['user_uuid'] = $row['user_uuid'];
			$_SESSION['authorize_person'] = $row['authorize_person'];
			$_SESSION['executive_person'] = $row['executive_person'];
			
			// Prosedürü çağır (User giriş kaydı yap)
			$stmt = $conn->prepare("CALL LOG_LOGIN_ACTIVITY(:userid, @oResult)");
			$stmt->bindParam(':userid', $_SESSION['userid'], PDO::PARAM_INT);
			$stmt->execute();
			$stmt->closeCursor();

			// OUT parametresini al (oResult)
			$stmt = $conn->query("SELECT @oResult AS result");
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$result = $row['result'];

			$conn = null;

			if($result) {
				return true;
			} else {
				return false;
			}
		} else {		
			return false;
		}
	}

	function authorized_person_id($userid, $routeid) {

		$conn = get_mysql_connection();

		if($conn) {
			// Fonksiyonu çağır (Authorized Person ara)
			$stmt = $conn->prepare("SELECT GET_AUTHORIZED_PERSON_ID(:userid, :routeid) AS AuthorizedPersonId;");
			$stmt->bindParam(':userid', $userid, PDO::PARAM_INT);
			$stmt->bindParam(':routeid', $routeid, PDO::PARAM_INT);
			$stmt->execute();
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$stmt->closeCursor();

			$authorized_person_id = $row['AuthorizedPersonId'];

			if($authorized_person_id == 0) {
				// Sorgu çalıştır (Authorized Person bilgilerini al)
				$stmt = $conn->prepare("SELECT ID AS id, EMAIL AS mail
										FROM USER
										WHERE AUTHORIZE_PERSON = 1");
				$stmt->execute();
				$row = $stmt->fetchAll(PDO::FETCH_ASSOC);
				$row_count = $stmt->rowCount();
				$stmt->closeCursor();

				$manager = $_SESSION['user_info'];

				do {
					$manager_mail = $manager['mail'];
					for($i = 0; $i < $row_count; $i++) {
						if($row[$i]['mail'] == $manager_mail) {
							$authorized_person_id = $row[$i]['id'];
							if($row[$i]['mail'] != $_SESSION['user_info']['mail']) {
								break;
							}
						}
					}
					if($authorized_person_id > 0) {
						break;
					}
					$manager = $manager['manager'];
				} while($manager != '');
			}

			if($authorized_person_id > 0) {
				// Sorgu çalıştır (Authorized Person bilgilerini al)
				$stmt = $conn->prepare("SELECT UUID, NAME, SURNAME, EMAIL
										FROM USER
										WHERE ID = :authorized_person_id");
				$stmt->bindParam(':authorized_person_id', $authorized_person_id, PDO::PARAM_INT);
				$stmt->execute();
				$row = $stmt->fetch(PDO::FETCH_ASSOC);
				$stmt->closeCursor();

				$_SESSION['approval_authority_id'] = $authorized_person_id;
				$_SESSION['approval_authority_uuid'] = $row['UUID'];
				$_SESSION['approval_authority_name'] = $row['NAME'] . ' ' . $row['SURNAME'];
				$_SESSION['approval_authority_mail'] = $row['EMAIL'];
			}

			$conn = null;

			return $authorized_person_id;
		} else {		
			return 0;
		}
	}
?>