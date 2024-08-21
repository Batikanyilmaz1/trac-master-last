-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost
-- Üretim Zamanı: 27 Şub 2024, 15:16:17
-- Sunucu sürümü: 8.2.0
-- PHP Sürümü: 8.2.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `transportation_accommodation`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `city`
--

CREATE TABLE `city` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `COUNTRY_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `country`
--

CREATE TABLE `country` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `county`
--

CREATE TABLE `county` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `CITY_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `department`
--

CREATE TABLE `department` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hospital_group`
--

CREATE TABLE `hospital_group` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `location`
--

CREATE TABLE `location` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `HOSPITAL_GROUP_ID` int DEFAULT NULL,
  `COUNTY_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `log_login_record`
--

CREATE TABLE `log_login_record` (
  `ID` int NOT NULL,
  `USER_ID` int NOT NULL,
  `LOGIN_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `position`
--

CREATE TABLE `position` (
  `ID` int NOT NULL,
  `NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `reason`
--

CREATE TABLE `reason` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `request`
--

CREATE TABLE `request` (
  `ID` int NOT NULL,
  `CTIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CUSER_ID` int NOT NULL,
  `ROUTE_ID` int NOT NULL,
  `REASON_ID` int NOT NULL,
  `FROM_COUNTRY_ID` int DEFAULT NULL,
  `FROM_LOCATION_ID` int DEFAULT NULL,
  `FROM_CITY_ID` int DEFAULT NULL,
  `FROM_CITY_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `TO_COUNTRY_ID` int DEFAULT NULL,
  `TO_LOCATION_ID` int DEFAULT NULL,
  `TO_CITY_ID` int DEFAULT NULL,
  `TO_CITY_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `TRANSPORTATION` tinyint(1) DEFAULT NULL,
  `DEPARTURE_DATE` date DEFAULT NULL,
  `RETURN_DATE` date DEFAULT NULL,
  `TRANSFER_NEED_SITUATION` int DEFAULT NULL,
  `TRANSFER_NEED_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `TRANSPORTATION_MODE_ID` int DEFAULT NULL,
  `TRANSPORTATION_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `ACCOMMODATION` tinyint(1) DEFAULT NULL,
  `CHECK-IN_DATE` date DEFAULT NULL,
  `CHECK-OUT_DATE` date DEFAULT NULL,
  `ACCOMMODATION_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `request_detail`
--

CREATE TABLE `request_detail` (
  `ID` int NOT NULL,
  `REQUEST_ID` int NOT NULL,
  `TRAVELER_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `route`
--

CREATE TABLE `route` (
  `ID` int NOT NULL,
  `NAME` varchar(10) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `transportation_company`
--

CREATE TABLE `transportation_company` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `TRANSPORTATION_MODE_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `transportation_mode`
--

CREATE TABLE `transportation_mode` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `traveler`
--

CREATE TABLE `traveler` (
  `ID` int NOT NULL,
  `CTIME` datetime DEFAULT NULL,
  `CUSER_ID` int DEFAULT NULL,
  `MTIME` datetime DEFAULT NULL,
  `MUSER_ID` int DEFAULT NULL,
  `TYPE_ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `SURNAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `BIRTH_DATE` date NOT NULL,
  `IDENTITY_NO` bigint DEFAULT NULL,
  `PASSPORT_NO` bigint DEFAULT NULL,
  `PHONE` varchar(20) COLLATE utf8mb4_turkish_ci NOT NULL,
  `EMAIL` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `USER_ID` int DEFAULT NULL,
  `POSITION_ID` int DEFAULT NULL,
  `DEPARTMENT_ID` int DEFAULT NULL,
  `LOCATION_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `traveler_type`
--

CREATE TABLE `traveler_type` (
  `ID` int NOT NULL,
  `NAME` varchar(10) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `user`
--

CREATE TABLE `user` (
  `ID` int NOT NULL,
  `USERNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `SURNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `EMAIL` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `POSITION_ID` int DEFAULT NULL,
  `DEPARTMENT_ID` int DEFAULT NULL,
  `LOCATION_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `user_backup`
--

CREATE TABLE `user_backup` (
  `ID` int NOT NULL,
  `USERNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `SURNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `EMAIL` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `POSITION_ID` int DEFAULT NULL,
  `DEPARTMENT_ID` int DEFAULT NULL,
  `LOCATION_ID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `city`
--
ALTER TABLE `city`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`) USING BTREE,
  ADD KEY `FK_CITY_COUNTRY_ID` (`COUNTRY_ID`);

--
-- Tablo için indeksler `country`
--
ALTER TABLE `country`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `county`
--
ALTER TABLE `county`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `NAME` (`NAME`) USING BTREE,
  ADD KEY `FK_COUNTY_CITY_ID` (`CITY_ID`);

--
-- Tablo için indeksler `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `hospital_group`
--
ALTER TABLE `hospital_group`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`),
  ADD KEY `FK_LOC_COUNTY_ID` (`COUNTY_ID`),
  ADD KEY `FK_LOC_HOSPITAL_GROUP_ID` (`HOSPITAL_GROUP_ID`);

--
-- Tablo için indeksler `log_login_record`
--
ALTER TABLE `log_login_record`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_LLR_USER_ID` (`USER_ID`);

--
-- Tablo için indeksler `position`
--
ALTER TABLE `position`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `reason`
--
ALTER TABLE `reason`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `request`
--
ALTER TABLE `request`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_REQUEST_ROUTE_ID` (`ROUTE_ID`),
  ADD KEY `FK_REQUEST_USER_ID` (`CUSER_ID`),
  ADD KEY `FK_REQUEST_FROM_COUNTRY_ID` (`FROM_COUNTRY_ID`),
  ADD KEY `FK_REQUEST_FROM_LOCATION_ID` (`FROM_LOCATION_ID`),
  ADD KEY `FK_REQUEST_FROM_CITY_ID` (`FROM_CITY_ID`),
  ADD KEY `FK_REQUEST_TO_COUNTRY_ID` (`TO_COUNTRY_ID`),
  ADD KEY `FK_REQUEST_TO_LOCATION_ID` (`TO_LOCATION_ID`),
  ADD KEY `FK_REQUEST_TO_CITY_ID` (`TO_CITY_ID`),
  ADD KEY `FK_REQUEST_REASON_ID` (`REASON_ID`),
  ADD KEY `FK_REQUEST_TO_TRANSPORTATION_MODE_ID` (`TRANSPORTATION_MODE_ID`);

--
-- Tablo için indeksler `request_detail`
--
ALTER TABLE `request_detail`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_REQUEST_DETAIL_REQUEST_ID` (`REQUEST_ID`),
  ADD KEY `FK_REQUEST_DETAIL_TRAVELER_ID` (`TRAVELER_ID`);

--
-- Tablo için indeksler `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`) USING BTREE;

--
-- Tablo için indeksler `transportation_company`
--
ALTER TABLE `transportation_company`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`),
  ADD KEY `FK_TR_COM_TRANSPORTATION_MODE_ID` (`TRANSPORTATION_MODE_ID`);

--
-- Tablo için indeksler `transportation_mode`
--
ALTER TABLE `transportation_mode`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `traveler`
--
ALTER TABLE `traveler`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_TRAVELER_TYPE_ID` (`TYPE_ID`),
  ADD KEY `FK_TRAVELER_USER_ID` (`USER_ID`),
  ADD KEY `FK_TRAVELER_POSITION_ID` (`POSITION_ID`),
  ADD KEY `FK_TRAVELER_DEPARTMENT_ID` (`DEPARTMENT_ID`),
  ADD KEY `FK_TRAVELER_LOCATION_ID` (`LOCATION_ID`);

--
-- Tablo için indeksler `traveler_type`
--
ALTER TABLE `traveler_type`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`);

--
-- Tablo için indeksler `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `USERNAME` (`USERNAME`),
  ADD UNIQUE KEY `EMAIL` (`EMAIL`),
  ADD KEY `FK_USER_DEP_ID` (`DEPARTMENT_ID`),
  ADD KEY `FK_USER_LOC_ID` (`LOCATION_ID`),
  ADD KEY `FK_USER_POS_ID` (`POSITION_ID`);

--
-- Tablo için indeksler `user_backup`
--
ALTER TABLE `user_backup`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `USERNAME` (`USERNAME`),
  ADD UNIQUE KEY `EMAIL` (`EMAIL`),
  ADD KEY `FK_USER_DEP_IDX` (`DEPARTMENT_ID`),
  ADD KEY `FK_USER_LOC_IDX` (`LOCATION_ID`),
  ADD KEY `FK_USER_POS_IDX` (`POSITION_ID`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `city`
--
ALTER TABLE `city`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `country`
--
ALTER TABLE `country`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `county`
--
ALTER TABLE `county`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `department`
--
ALTER TABLE `department`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `hospital_group`
--
ALTER TABLE `hospital_group`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `location`
--
ALTER TABLE `location`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `log_login_record`
--
ALTER TABLE `log_login_record`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `position`
--
ALTER TABLE `position`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `reason`
--
ALTER TABLE `reason`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `request`
--
ALTER TABLE `request`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `request_detail`
--
ALTER TABLE `request_detail`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `route`
--
ALTER TABLE `route`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `transportation_company`
--
ALTER TABLE `transportation_company`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `transportation_mode`
--
ALTER TABLE `transportation_mode`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `traveler`
--
ALTER TABLE `traveler`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `traveler_type`
--
ALTER TABLE `traveler_type`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `user`
--
ALTER TABLE `user`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `user_backup`
--
ALTER TABLE `user_backup`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `city`
--
ALTER TABLE `city`
  ADD CONSTRAINT `FK_CITY_COUNTRY_ID` FOREIGN KEY (`COUNTRY_ID`) REFERENCES `country` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `county`
--
ALTER TABLE `county`
  ADD CONSTRAINT `FK_COUNTY_CITY_ID` FOREIGN KEY (`CITY_ID`) REFERENCES `city` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `location`
--
ALTER TABLE `location`
  ADD CONSTRAINT `FK_LOC_HOSPITAL_GROUP_ID` FOREIGN KEY (`HOSPITAL_GROUP_ID`) REFERENCES `hospital_group` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `log_login_record`
--
ALTER TABLE `log_login_record`
  ADD CONSTRAINT `FK_LLR_USER_ID` FOREIGN KEY (`USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `request`
--
ALTER TABLE `request`
  ADD CONSTRAINT `FK_REQUEST_FROM_CITY_ID` FOREIGN KEY (`FROM_CITY_ID`) REFERENCES `city` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_FROM_COUNTRY_ID` FOREIGN KEY (`FROM_COUNTRY_ID`) REFERENCES `country` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_FROM_LOCATION_ID` FOREIGN KEY (`FROM_LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_REASON_ID` FOREIGN KEY (`REASON_ID`) REFERENCES `reason` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_ROUTE_ID` FOREIGN KEY (`ROUTE_ID`) REFERENCES `route` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_CITY_ID` FOREIGN KEY (`TO_CITY_ID`) REFERENCES `city` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_COUNTRY_ID` FOREIGN KEY (`TO_COUNTRY_ID`) REFERENCES `country` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_LOCATION_ID` FOREIGN KEY (`TO_LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_TRANSPORTATION_MODE_ID` FOREIGN KEY (`TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_USER_ID` FOREIGN KEY (`CUSER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `request_detail`
--
ALTER TABLE `request_detail`
  ADD CONSTRAINT `FK_REQUEST_DETAIL_REQUEST_ID` FOREIGN KEY (`REQUEST_ID`) REFERENCES `request` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_DETAIL_TRAVELER_ID` FOREIGN KEY (`TRAVELER_ID`) REFERENCES `traveler` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `transportation_company`
--
ALTER TABLE `transportation_company`
  ADD CONSTRAINT `FK_TR_COM_TRANSPORTATION_MODE_ID` FOREIGN KEY (`TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `traveler`
--
ALTER TABLE `traveler`
  ADD CONSTRAINT `FK_TRAVELER_DEPARTMENT_ID` FOREIGN KEY (`DEPARTMENT_ID`) REFERENCES `department` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_TRAVELER_LOCATION_ID` FOREIGN KEY (`LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_TRAVELER_POSITION_ID` FOREIGN KEY (`POSITION_ID`) REFERENCES `position` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_TRAVELER_TYPE_ID` FOREIGN KEY (`TYPE_ID`) REFERENCES `traveler_type` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_TRAVELER_USER_ID` FOREIGN KEY (`USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `FK_USER_DEP_ID` FOREIGN KEY (`DEPARTMENT_ID`) REFERENCES `department` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_USER_LOC_ID` FOREIGN KEY (`LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_USER_POS_ID` FOREIGN KEY (`POSITION_ID`) REFERENCES `position` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `user_backup`
--
ALTER TABLE `user_backup`
  ADD CONSTRAINT `FK_USER_DEP_IDX` FOREIGN KEY (`DEPARTMENT_ID`) REFERENCES `department` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_USER_LOC_IDX` FOREIGN KEY (`LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_USER_POS_IDX` FOREIGN KEY (`POSITION_ID`) REFERENCES `position` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
