-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: localhost
-- Üretim Zamanı: 06 Ağu 2024, 00:53:52
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

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_GUEST` (IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pBirthDate` DATE, IN `pIdentityNo` BIGINT, IN `pPassportNo` BIGINT, IN `pPhone` VARCHAR(20), IN `pMail` VARCHAR(100), OUT `oGuestId` INT)   BEGIN
  DECLARE `vtGuestId` INT DEFAULT 0;
  DECLARE `vtIdentityNo`, `vtPassportNo` BIGINT DEFAULT 0;
  DECLARE `vtPhone` VARCHAR(20) DEFAULT '';
  DECLARE `vtMail` VARCHAR(100) DEFAULT '';
  
  SELECT `ID`, `IDENTIFICATION_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`
    INTO `vtGuestId`, `vtIdentityNo`, `vtPassportNo`, `vtPhone`, `vtMail`
  FROM `GUEST`
  WHERE `NAME` = `pName`
    AND `SURNAME` = `pSurname`
    AND `BIRTH_DATE` = `pBirthDate`;
  
  IF `vtGuestId` > 0 THEN
    IF `vtIdentityNo` != `pIdentityNo` || `vtPassportNo` != `pPassportNo` || `vtPhone` != `pPhone` || `vtMail` != `pMail` THEN
      
      UPDATE `GUEST`
      SET `IDENTIFICATION_NO` = `pIdentityNo`, `PASSPORT_NO` = `pPassportNo`, `PHONE` = `pPhone`, `EMAIL` = `pMail`
      WHERE `ID` = `vtGuestId`;
    END IF;
    
    SET `oGuestId` = `vtGuestId`;
  ELSE
    INSERT INTO `GUEST`
    (`NAME`, `SURNAME`, `BIRTH_DATE`, `IDENTIFICATION_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`)
    VALUES
    (`pName`, `pSurname`, `pBirthDate`, `pIdentityNo`, `pPassportNo`, `pPhone`, `pMail`);
    
    SELECT LAST_INSERT_ID() INTO `oGuestId`;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_REQUEST` (IN `pUUID` VARCHAR(36), IN `pUserId` INT, IN `pRouteId` INT, IN `pReasonId` INT, IN `pFromCountryId` INT, IN `pFromLocationId` INT, IN `pFromCityId` INT, IN `pFromCityName` VARCHAR(50), IN `pToCountryId` INT, IN `pToLocationId` INT, IN `pToCityId` INT, IN `pToCityName` VARCHAR(50), IN `pTransportation` BOOLEAN, IN `pDepartureDate` DATE, IN `pReturnDate` DATE, IN `pTransferNeedSituation` INT, IN `pTransferNeedDetail` TEXT, IN `pTransportationModeId` INT, IN `pTransportationDetail` TEXT, IN `pAccommodation` BOOLEAN, IN `pCheckInDate` DATE, IN `pCheckOutDate` DATE, IN `pAccommodationDetail` TEXT, OUT `oRequestId` INT)   BEGIN
  INSERT INTO `REQUEST`
  (`UUID`, `CREATOR_USER_ID`, `ROUTE_ID`, `REASON_ID`, `FROM_COUNTRY_ID`, `FROM_LOCATION_ID`, `FROM_CITY_ID`, `FROM_CITY_NAME`, `TO_COUNTRY_ID`, `TO_LOCATION_ID`, `TO_CITY_ID`, `TO_CITY_NAME`,
   `TRANSPORTATION`, `DEPARTURE_DATE`, `RETURN_DATE`, `TRANSFER_NEED_SITUATION`, `TRANSFER_NEED_DETAIL`, `TRANSPORTATION_MODE_ID`, `TRANSPORTATION_DETAIL`, `ACCOMMODATION`,
   `CHECK-IN_DATE`, `CHECK-OUT_DATE`, `ACCOMMODATION_DETAIL`)
  VALUES
  (`pUUID`, `pUserId`, `pRouteId`, `pReasonId`, `pFromCountryId`, `pFromLocationId`, `pFromCityId`, `pFromCityName`, `pToCountryId`, `pToLocationId`, `pToCityId`, `pToCityName`,
   `pTransportation`, `pDepartureDate`, `pReturnDate`, `pTransferNeedSituation`, `pTransferNeedDetail`, `pTransportationModeId`, `pTransportationDetail`, `pAccommodation`,
   `pCheckInDate`, `pCheckOutDate`, `pAccommodationDetail`);
  
  SELECT LAST_INSERT_ID() INTO `oRequestId`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_REQUEST_APPROVER_DETAIL` (IN `pRequestUUID` VARCHAR(36), IN `pRequestApproverDetailUUID` VARCHAR(36), IN `pNewUUID` VARCHAR(36), IN `pUserId` INT, OUT `oRequestApproverDetailId` INT)   BEGIN
  DECLARE `vRequestApproverDetailId`, `vAuthorizedPersonId`, `vRequestId`, `vRouteId`, `vNextAuthorizedPersonId`, `vExecutivePerson` INT DEFAULT 0;
  
  SELECT `ID`, `ROUTE_ID` INTO `vRequestId`, `vRouteId`
  FROM `REQUEST`
  WHERE `UUID` = `pRequestUUID`;
  
  IF `pRequestApproverDetailUUID` != '' THEN
    SELECT `ID`, `AUTHORIZED_PERSON_ID` INTO `vRequestApproverDetailId`, `vAuthorizedPersonId`
    FROM `REQUEST_APPROVER_DETAIL`
    WHERE `UUID` = `pRequestApproverDetailUUID`
      AND `REQUEST_ID` = `vRequestId`;
  ELSE
    SET `vAuthorizedPersonId` = `pUserId`;
    SET `vRequestApproverDetailId` = 0;
  END IF;
  
  SELECT GET_AUTHORIZED_PERSON_ID(`vAuthorizedPersonId`, `vRouteId`) INTO `vNextAuthorizedPersonId`;
  
  IF `vNextAuthorizedPersonId` > 0 THEN
    UPDATE `REQUEST_APPROVER_DETAIL`
    SET `ACTIVE` = 0
    WHERE `REQUEST_ID` = `vRequestId`;
    
    INSERT INTO `REQUEST_APPROVER_DETAIL`
    (`UUID`, `CREATOR_USER_ID`, `REQUEST_ID`, `AUTHORIZED_PERSON_ID`)
    VALUES
    (`pNewUUID`, `pUserId`, `vRequestId`, `vNextAuthorizedPersonId`);
    
    SELECT LAST_INSERT_ID() INTO `oRequestApproverDetailId`;
  ELSE
    SET `oRequestApproverDetailId` = `vRequestApproverDetailId`;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_REQUEST_DETAIL` (IN `pRequestId` INT, IN `pTravelerId` INT, OUT `oRequestDetailId` INT)   BEGIN
  INSERT INTO `REQUEST_DETAIL`
  (`REQUEST_ID`, `TRAVELER_ID`)
  VALUES
  (`pRequestId`, `pTravelerId`);
  
  SELECT LAST_INSERT_ID() INTO `oRequestDetailId`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_RESERVATION` (IN `pUUID` VARCHAR(36), IN `pUserId` INT, IN `pRequestId` INT, IN `pDepartureTransportationModeId` INT, IN `pDeparturePort` VARCHAR(150), IN `pDepartureDate` DATETIME, IN `pDepartureCompany` VARCHAR(150), IN `pDeparturePnrCode` VARCHAR(20), IN `pDepartureTicketNumber` VARCHAR(20), IN `pDepartureTicketPrice` VARCHAR(20), IN `pDepartureCarLicensePlate` VARCHAR(50), IN `pReturnTransportationModeId` INT, IN `pReturnPort` VARCHAR(150), IN `pReturnDate` DATETIME, IN `pReturnCompany` VARCHAR(150), IN `pReturnPnrCode` VARCHAR(20), IN `pReturnTicketNumber` VARCHAR(20), IN `pReturnTicketPrice` VARCHAR(20), IN `pReturnCarLicensePlate` VARCHAR(50), IN `pCheckInDate` DATETIME, IN `pCheckOutDate` DATETIME, IN `pHotelName` VARCHAR(150), OUT `oReservationId` INT)   BEGIN
  INSERT INTO `RESERVATION`
  (`UUID`, `CREATOR_USER_ID`, `REQUEST_ID`, `DEPARTURE_TRANSPORTATION_MODE_ID`, `DEPARTURE_PORT`, `DEPARTURE_DATE`, `DEPARTURE_COMPANY`, `DEPARTURE_PNR_CODE`, `DEPARTURE_TICKET_NUMBER`,
   `DEPARTURE_TICKET_PRICE`, `DEPARTURE_CAR_LICENSE_PLATE`, `RETURN_TRANSPORTATION_MODE_ID`, `RETURN_PORT`, `RETURN_DATE`, `RETURN_COMPANY`, `RETURN_PNR_CODE`, `RETURN_TICKET_NUMBER`,
   `RETURN_TICKET_PRICE`, `RETURN_CAR_LICENSE_PLATE`, `CHECK-IN_DATE`, `CHECK-OUT_DATE`, `HOTEL_NAME`)
  VALUES
  (`pUUID`, `pUserId`, `pRequestId`, `pDepartureTransportationModeId`, `pDeparturePort`, `pDepartureDate`, `pDepartureCompany`, `pDeparturePnrCode`, `pDepartureTicketNumber`,
   `pDepartureTicketPrice`, `pDepartureCarLicensePlate`, `pReturnTransportationModeId`, `pReturnPort`, `pReturnDate`, `pReturnCompany`, `pReturnPnrCode`, `pReturnTicketNumber`,
   `pReturnTicketPrice`, `pReturnCarLicensePlate`, `pCheckInDate`, `pCheckOutDate`, `pHotelName`);
  
  SELECT LAST_INSERT_ID() INTO `oReservationId`;
  
  UPDATE `REQUEST_APPROVER_DETAIL`
  SET `MODIFIED_TIME` = NOW(), `MODIFIED_USER_ID` = `pUserId`, `STATUS_ID` = 14
  WHERE `REQUEST_ID` = `pRequestId`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_STAFF` (IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pBirthDate` DATE, IN `pIdentityNo` BIGINT, IN `pPassportNo` BIGINT, IN `pPhone` VARCHAR(20), IN `pMail` VARCHAR(100), IN `pPositionName` VARCHAR(100), IN `pPositionId` INT, IN `pDepartmentName` VARCHAR(100), IN `pDepartmentId` INT, IN `pLocationName` VARCHAR(100), IN `pLocationId` INT, OUT `oStaffId` INT)   BEGIN
  DECLARE `vPositionId`, `vDepartmentId`, `vLocationId`, `vtStaffId`, `vtPositionId`, `vtDepartmentId`, `vtLocationId` INT DEFAULT 0;
  DECLARE `vtIdentityNo`, `vtPassportNo` BIGINT DEFAULT 0;
  DECLARE `vUserId`, `vtUserId` INT DEFAULT NULL;
  DECLARE `vtPhone` VARCHAR(20) DEFAULT '';
  DECLARE `vtMail` VARCHAR(100) DEFAULT '';
  
  SET `vPositionId` = IFNULL(`pPositionId`, 0);
  SET `vDepartmentId` = IFNULL(`pDepartmentId`, 0);
  SET `vLocationId` = IFNULL(`pLocationId`, 0);
  
  IF `vPositionId` = 0 THEN
    SELECT GET_POSITION_ID(`pPositionName`, 1) INTO `vPositionId`;
  END IF;
  
  IF `vDepartmentId` = 0 THEN
    SELECT GET_DEPARTMENT_ID(`pDepartmentName`, 1) INTO `vDepartmentId`;
  END IF;
  
  IF `vLocationId` = 0 THEN
    SELECT GET_LOCATION_ID(`pLocationName`, 1) INTO `vLocationId`;
  END IF;
  
  SELECT `ID` INTO `vUserId`
  FROM `USER`
  WHERE `NAME` = `pName`
    AND `SURNAME` = `pSurname`
	AND `EMAIL` = `pMail`;
  
  SELECT `ID`, `USER_ID`, `IDENTIFICATION_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`
    INTO `vtStaffId`, `vtUserId`, `vtIdentityNo`, `vtPassportNo`, `vtPhone`, `vtMail`, `vtPositionId`, `vtDepartmentId`, `vtLocationId`
  FROM `STAFF`
  WHERE `NAME` = `pName`
    AND `SURNAME` = `pSurname`
    AND `BIRTH_DATE` = `pBirthDate`;
  
  IF `vtStaffId` > 0 THEN
    IF IFNULL(`vtUserId`, 0) != IFNULL(`vUserId`, 0) || `vtIdentityNo` != `pIdentityNo` || `vtPassportNo` != `pPassportNo` ||
      `vtPhone` != `pPhone` || `vtMail` != `pMail` || `vtPositionId` != `vPositionId` || `vtDepartmentId` != `vDepartmentId` || `vtLocationId` != `vLocationId` THEN
      
      UPDATE `STAFF`
      SET `USER_ID` = `vUserId`, `IDENTIFICATION_NO` = `pIdentityNo`, `PASSPORT_NO` = `pPassportNo`,
          `PHONE` = `pPhone`, `EMAIL` = `pMail`, `POSITION_ID` = `vPositionId`, `DEPARTMENT_ID` = `vDepartmentId`, `LOCATION_ID` = `vLocationId`
      WHERE `ID` = `vtStaffId`;
    END IF;
    
    SET `oStaffId` = `vtStaffId`;
  ELSE
    INSERT INTO `STAFF`
    (`USER_ID`, `NAME`, `SURNAME`, `BIRTH_DATE`, `IDENTIFICATION_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`)
    VALUES
    (`vUserId`, `pName`, `pSurname`, `pBirthDate`, `pIdentityNo`, `pPassportNo`, `pPhone`, `pMail`, `vPositionId`, `vDepartmentId`, `vLocationId`);
    
    SELECT LAST_INSERT_ID() INTO `oStaffId`;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_TRAVELER` (IN `pUserId` INT, IN `pTypeId` INT, IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pBirthDate` DATE, IN `pIdentityNo` BIGINT, IN `pPassportNo` BIGINT, IN `pPhone` VARCHAR(20), IN `pMail` VARCHAR(100), IN `pPositionName` VARCHAR(100), IN `pPositionId` INT, IN `pDepartmentName` VARCHAR(100), IN `pDepartmentId` INT, IN `pLocationName` VARCHAR(100), IN `pLocationId` INT, OUT `oTravelerId` INT)   BEGIN
  DECLARE `vPositionId`, `vDepartmentId`, `vLocationId`, `vtTravelerId`, `vtTypeId`, `vtPositionId`, `vtDepartmentId`, `vtLocationId` INT DEFAULT 0;
  DECLARE `vtIdentityNo`, `vtPassportNo` BIGINT DEFAULT 0;
  DECLARE `vUserId`, `vtUserId` INT DEFAULT NULL;
  DECLARE `vtPhone` VARCHAR(20) DEFAULT '';
  DECLARE `vtMail` VARCHAR(100) DEFAULT '';
  
  IF `pTypeId` = 1 THEN
    SET `vPositionId` = IFNULL(`pPositionId`, 0);
    SET `vDepartmentId` = IFNULL(`pDepartmentId`, 0);
    SET `vLocationId` = IFNULL(`pLocationId`, 0);
    
    IF `vPositionId` = 0 THEN
      SELECT GET_POSITION_ID(`pPositionName`, 1) INTO `vPositionId`;
    END IF;
    
    IF `vDepartmentId` = 0 THEN
      SELECT GET_DEPARTMENT_ID(`pDepartmentName`, 1) INTO `vDepartmentId`;
    END IF;
    
    IF `vLocationId` = 0 THEN
      SELECT GET_LOCATION_ID(`pLocationName`, 1) INTO `vLocationId`;
    END IF;
    
    SELECT `ID` INTO `vUserId`
    FROM `USER`
    WHERE `NAME` = `pName`
      AND `SURNAME` = `pSurname`
	  AND `EMAIL` = `pMail`;
      
  ELSEIF `pTypeId` = 2 THEN
    SET `vUserId` = NULL;
    SET `vPositionId` = NULL;
    SET `vDepartmentId` = NULL;
    SET `vLocationId` = NULL;
  END IF;
  
  SELECT `ID`, `TYPE_ID`, `IDENTITY_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `USER_ID`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`
    INTO `vtTravelerId`, `vtTypeId`, `vtIdentityNo`, `vtPassportNo`, `vtPhone`, `vtMail`, `vtUserId`, `vtPositionId`, `vtDepartmentId`, `vtLocationId`
  FROM `TRAVELER`
  WHERE `NAME` = `pName`
    AND `SURNAME` = `pSurname`
    AND `BIRTH_DATE` = `pBirthDate`;
  
  IF `vtTravelerId` > 0 THEN
    IF IFNULL(`vtUserId`, 0) != IFNULL(`vUserId`, 0) || `vtTypeId` != `pTypeId` || `vtIdentityNo` != `pIdentityNo` || `vtPassportNo` != `pPassportNo` ||
      `vtPhone` != `pPhone` || `vtMail` != `pMail` || `vtPositionId` != `vPositionId` || `vtDepartmentId` != `vDepartmentId` || `vtLocationId` != `vLocationId` THEN
      
      UPDATE `TRAVELER`
      SET `TYPE_ID` = `pTypeId`, `IDENTITY_NO` = `pIdentityNo`, `PASSPORT_NO` = `pPassportNo`, `PHONE` = `pPhone`, `EMAIL` = `pMail`,
          `USER_ID` = `vUserId`, `POSITION_ID` = `vPositionId`, `DEPARTMENT_ID` = `vDepartmentId`, `LOCATION_ID` = `vLocationId`
      WHERE `ID` = `vtTravelerId`;
    END IF;
    
    SET `oTravelerId` = `vtTravelerId`;
  ELSE
    INSERT INTO `TRAVELER`
    (`CREATOR_USER_ID`, `TYPE_ID`, `NAME`, `SURNAME`, `BIRTH_DATE`, `IDENTITY_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `USER_ID`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`)
    VALUES
    (`pUserId`, `pTypeId`, `pName`, `pSurname`, `pBirthDate`, `pIdentityNo`, `pPassportNo`, `pPhone`, `pMail`, `vUserId`, `vPositionId`, `vDepartmentId`, `vLocationId`);
    
    SELECT LAST_INSERT_ID() INTO `oTravelerId`;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `HANDLE_USER_LOGIN` (IN `pUUID` VARCHAR(36), IN `pUsername` VARCHAR(50), IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pMail` VARCHAR(100), IN `pPositionName` VARCHAR(100), IN `pDepartmentName` VARCHAR(100), IN `pLocationName` VARCHAR(100), OUT `oUserId` INT, OUT `oUUID` VARCHAR(36), OUT `oAuthorizePerson` INT, OUT `oExecutivePerson` INT)   BEGIN
  DECLARE `vPositionId`, `vDepartmentId`, `vLocationId`, `vtUserId`, `vtPositionId`, `vtDepartmentId`, `vtLocationId` INT DEFAULT 0;
  DECLARE `vtUUID` VARCHAR(36) DEFAULT '';
  DECLARE `vtName`, `vtSurname` Varchar(50) DEFAULT '';
  DECLARE `vtMail` VARCHAR(100) DEFAULT '';
  
  SELECT GET_POSITION_ID(`pPositionName`, 1) INTO `vPositionId`;
  SELECT GET_DEPARTMENT_ID(`pDepartmentName`, 1) INTO `vDepartmentId`;
  SELECT GET_LOCATION_ID(`pLocationName`, 1) INTO `vLocationId`;
  
  SELECT `ID`, `UUID`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`, `AUTHORIZE_PERSON`, `EXECUTIVE_PERSON`
	INTO `vtUserId`, `vtUUID`, `vtName`, `vtSurname`, `vtMail`, `vtPositionId`, `vtDepartmentId`, `vtLocationId`, `oAuthorizePerson`, `oExecutivePerson`
  FROM `USER`
  WHERE `USERNAME` = `pUsername`;
  
  IF `vtUserId` > 0 THEN
    IF `vtName` != `pName` || `vtSurname` != `pSurname` || `vtMail` != `pMail` || `vtPositionId` != `vPositionId` || `vtDepartmentId` != `vDepartmentId` || `vtLocationId` != `vLocationId` THEN
      UPDATE `USER`
      SET `NAME` = `pName`, `SURNAME` = `pSurname`, `EMAIL` = `pMail`,
          `POSITION_ID` = `vPositionId`, `DEPARTMENT_ID` = `vDepartmentId`, `LOCATION_ID` = `vLocationId`
      WHERE `ID` = `vtUserId`;
    END IF;
    
    SET `oUserId` = `vtUserId`;
    SET `oUUID` = `vtUUID`;

	IF `oAuthorizePerson` = 0 THEN
      SET `oAuthorizePerson` = CHECK_AUTHORIZE_PERSON(`vtUserId`);
    END IF;

    IF `oExecutivePerson` = 0 THEN
      SET `oExecutivePerson` = CHECK_EXECUTIVE_PERSON(`vtUserId`);
	END IF;
  ELSE
    INSERT INTO `USER`
    (`UUID`, `USERNAME`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`)
    VALUES
    (`pUUID`, `pUsername`, `pName`, `pSurname`, `pMail`, `vPositionId`, `vDepartmentId`, `vLocationId`);
    
    SELECT LAST_INSERT_ID() INTO `oUserId`;
    SET `oUUID` = `pUUID`;
    SET `oAuthorizePerson` = 0;
    SET `oExecutivePerson` = 0;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LOG_LOGIN_ACTIVITY` (IN `pUserId` INT, OUT `oResult` BOOL)   BEGIN
  DECLARE `vRowCount` INT DEFAULT 0;
  
  INSERT INTO `LOG_LOGIN_RECORD`
  (`USER_ID`)
  VALUES
  (`pUserId`);
  
  SELECT ROW_COUNT() INTO `vRowCount`;
  
  IF `vRowCount` > 0 THEN
    SET `oResult` = '1';
  ELSE
    SET `oResult` = '0';
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_REQUEST_APPROVER_DETAIL` (IN `pRequestUUID` VARCHAR(36), IN `pRequestApproverDetailUUID` VARCHAR(36), IN `pUserId` INT, IN `pStatusId` INT, IN `pExplanation` VARCHAR(1000), OUT `oUpdatedRowCount` INT, OUT `oContinue` INT)   BEGIN
  DECLARE `vRequestApproverDetailId`, `vAuthorizedPersonId`, `vExecutivePerson`, `vStatusId`, `vIsDeputy` INT DEFAULT 0;
  
  SELECT RAD.`ID`, RAD.`AUTHORIZED_PERSON_ID` INTO `vRequestApproverDetailId`, `vAuthorizedPersonId`
  FROM `REQUEST` R
  JOIN `REQUEST_APPROVER_DETAIL` RAD ON RAD.`REQUEST_ID` = R.`ID`
  WHERE R.`UUID` = `pRequestUUID`
    AND RAD.`UUID` = `pRequestApproverDetailUUID`;
  
  IF `vRequestApproverDetailId` > 0 THEN
    IF `pStatusId` = '12' THEN
      SELECT `EXECUTIVE_PERSON` INTO `vExecutivePerson`
      FROM `USER`
      WHERE `ID` = `vAuthorizedPersonId`;
      
      IF `vExecutivePerson` = 1 THEN
        IF `pUserId` <> `vAuthorizedPersonId` THEN
          SELECT COUNT(*) INTO `vIsDeputy`
          FROM `AUTHORIZED_PERSON_GROUP`
          WHERE `AUTHORIZED_PERSON_ID` = `vAuthorizedPersonId`
            AND `USER_ID` = `pUserId`;
          
          IF `vIsDeputy` > 0 THEN
            SET `vStatusId` = 13;
            SET `oContinue` = 0;
	      ELSE
            SET `vStatusId` = `pStatusId`;
            SET `oContinue` = 1;
		  END IF;
        ELSE
          SET `vStatusId` = 13;
          SET `oContinue` = 0;
	    END IF;
	  ELSE
        SET `vStatusId` = `pStatusId`;
        SET `oContinue` = 1;
      END IF;
    ELSE
      SET `vStatusId` = `pStatusId`;
      SET `oContinue` = 0;
	END IF;
    
    UPDATE `REQUEST_APPROVER_DETAIL`
    SET `MODIFIED_TIME` = NOW(), `MODIFIED_USER_ID` = `pUserId`, `STATUS_ID` = `vStatusId`, `EXPLANATION` = `pExplanation`
    WHERE `ID` = `vRequestApproverDetailId`;
    
    SET `oUpdatedRowCount` = ROW_COUNT();
  ELSE
    SET `oUpdatedRowCount` = 0;
    SET `oContinue` = 0;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_RESERVATION` (IN `pReservationId` INT, IN `pUserId` INT, IN `pStatusId` INT, IN `pExplanation` VARCHAR(1000), OUT `oUpdatedRowCount` INT)   BEGIN
  DECLARE `vExecutivePerson`, `vIsDeputy` INT DEFAULT 0;
  
  SELECT `EXECUTIVE_PERSON` INTO `vExecutivePerson`
  FROM `USER`
  WHERE `ID` = `pUserId`;
  
  IF `vExecutivePerson` = 0 THEN
    SELECT COUNT(*) INTO `vIsDeputy`
    FROM `AUTHORIZED_PERSON_GROUP` APG
    JOIN `USER` U ON U.`ID` = APG.`AUTHORIZED_PERSON_ID`
    WHERE APG.`USER_ID` = `pUserId`
      AND U.`EXECUTIVE_PERSON` = 1;
	
    IF `vIsDeputy` > 0 THEN
      SET `vExecutivePerson` = 1;
	END IF;
  END IF;
  
  IF `vExecutivePerson` = 1 THEN
    UPDATE `RESERVATION`
    SET `MODIFIED_TIME` = NOW(), `MODIFIED_USER_ID` = `pUserId`, `STATUS_ID` = `pStatusId`, `EXPLANATION` = `pExplanation`
    WHERE `ID` = `pReservationId`;
    
    SET `oUpdatedRowCount` = ROW_COUNT();
  ELSE
    SET `oUpdatedRowCount` = 0;
  END IF;
END$$

--
-- İşlevler
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CHECK_AUTHORIZE_PERSON` (`pUserId` INT) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vAuthorizePerson`, `vAuthorizePersonCount` INT DEFAULT 0;
  
  SELECT `AUTHORIZE_PERSON` INTO `vAuthorizePerson`
  FROM `USER`
  WHERE `ID` = `pUserId`;
  
  IF `vAuthorizePerson` = 0 THEN
	SELECT COUNT(*) INTO `vAuthorizePersonCount`
    FROM `AUTHORIZED_PERSON_GROUP` APG
    JOIN `USER` U ON U.`ID` = APG.`AUTHORIZED_PERSON_ID`
    WHERE APG.`USER_ID` = `pUserId`
      AND U.`AUTHORIZE_PERSON` = 1;
	
    IF `vAuthorizePersonCount` >= 1 THEN
      SET `vAuthorizePerson` = 1;
	END IF;
  END IF;
  
  RETURN `vAuthorizePerson`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CHECK_EXECUTIVE_PERSON` (`pUserId` INT) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vExecutivePerson`, `vExecutivePersonCount` INT DEFAULT 0;
  
  SELECT `EXECUTIVE_PERSON` INTO `vExecutivePerson`
  FROM `USER`
  WHERE `ID` = `pUserId`;
  
  IF `vExecutivePerson` = 0 THEN
	SELECT COUNT(*) INTO `vExecutivePersonCount`
    FROM `AUTHORIZED_PERSON_GROUP` APG
    JOIN `USER` U ON U.`ID` = APG.`AUTHORIZED_PERSON_ID`
    WHERE APG.`USER_ID` = `pUserId`
      AND U.`EXECUTIVE_PERSON` = 1;
	
    IF `vExecutivePersonCount` >= 1 THEN
      SET `vExecutivePerson` = 1;
	END IF;
  END IF;
  
  RETURN `vExecutivePerson`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_AUTHORIZED_PERSON_ID` (`pUserId` INT, `pRouteId` INT) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vAuthorizedPersonId`, `vPositionId`, `vDepartmentId`, `vLocationId` INT DEFAULT 0;
  
  SELECT `AUTHORIZED_PERSON_ID` INTO `vAuthorizedPersonId`
  FROM `AUTHORIZED_PERSON_RELATION`
  WHERE `USER_ID` = `pUserId`
    AND (`ROUTE_ID` = `pRouteId` OR `ROUTE_ID` IS NULL);
  
  IF `vAuthorizedPersonId` = 0 THEN
    SELECT `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID` INTO `vPositionId`, `vDepartmentId`, `vLocationId`
    FROM `USER`
    WHERE `ID` = `pUserId`;
    
    SELECT `AUTHORIZED_PERSON_ID` INTO `vAuthorizedPersonId`
    FROM `AUTHORIZED_PERSON_RELATION`
    WHERE `POSITION_ID` = `vPositionId`
      AND `LOCATION_ID` = `vLocationId`
      AND (`ROUTE_ID` = `pRouteId` OR `ROUTE_ID` IS NULL);
    
    IF `vAuthorizedPersonId` = 0 THEN
      SELECT `AUTHORIZED_PERSON_ID` INTO `vAuthorizedPersonId`
      FROM `AUTHORIZED_PERSON_RELATION`
      WHERE `DEPARTMENT_ID` = `vDepartmentId`
        AND `LOCATION_ID` = `vLocationId`
        AND (`ROUTE_ID` = `pRouteId` OR `ROUTE_ID` IS NULL);
      
      IF `vAuthorizedPersonId` = 0 THEN
        SELECT `AUTHORIZED_PERSON_ID` INTO `vAuthorizedPersonId`
        FROM `AUTHORIZED_PERSON_RELATION`
        WHERE `LOCATION_ID` = `vLocationId`
        AND (`ROUTE_ID` = `pRouteId` OR `ROUTE_ID` IS NULL);
      END IF;
    END IF;
  END IF;
  
  RETURN `vAuthorizedPersonId`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_CITY_NAME` (`pCityId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vCityName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vCityName`
  FROM `CITY`
  WHERE `ID` = `pCityId`;

  RETURN `vCityName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_COUNTRY_NAME` (`pCountryId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vCountryName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vCountryName`
  FROM `COUNTRY`
  WHERE `ID` = `pCountryId`;

  RETURN `vCountryName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_COUNTY_NAME` (`pCountyId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vCountyName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vCountyName`
  FROM `COUNTY`
  WHERE `ID` = `pCountyId`;

  RETURN `vCountyName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_DEPARTMENT_ID` (`pDepartmentName` VARCHAR(100), `pAdd` BOOL) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vDepartmentId` INT DEFAULT 0;

  SELECT ID INTO `vDepartmentId`
  FROM `DEPARTMENT`
  WHERE `NAME` = `pDepartmentName`;

  IF `pAdd` AND `vDepartmentId` = 0 THEN
    INSERT INTO `DEPARTMENT`
    (`NAME`)
    VALUES
    (`pDepartmentName`);
    
    SELECT ID INTO `vDepartmentId`
    FROM `DEPARTMENT`
    WHERE `NAME` = `pDepartmentName`;
  END IF;

  RETURN `vDepartmentId`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_DEPARTMENT_NAME` (`pDepartmentId` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vDepartmentName` VARCHAR(100) DEFAULT '';

  SELECT NAME INTO `vDepartmentName`
  FROM `DEPARTMENT`
  WHERE `ID` = `pDepartmentId`;

  RETURN `vDepartmentName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_HOSPITAL_GROUP_NAME` (`pHospitalGroupId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vHospitalGroupName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vHospitalGroupName`
  FROM `HOSPITAL_GROUP`
  WHERE `ID` = `pHospitalGroupId`;

  RETURN `vHospitalGroupName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_IS_THIS_AUTHORIZE_PERSON` (`pUserId` INT) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vAuthorizePerson` INT DEFAULT 0;
  
  SELECT COUNT(*) INTO `vAuthorizePerson`
  FROM `AUTHORIZED_PERSON_GROUP` APG
  JOIN `USER` U ON U.`ID` = APG.`AUTHORIZED_PERSON_ID`
  WHERE APG.`USER_ID` = `pUserId`
    AND U.`AUTHORIZE_PERSON` = 1;
  
  IF `vAuthorizePerson` > 0 THEN
    SET `vAuthorizePerson` = 1;
  END IF;
  
  RETURN `vAuthorizePerson`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_IS_THIS_EXECUTIVE_PERSON` (`pUserId` INT) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vExecutivePerson` INT DEFAULT 0;
  
  SELECT COUNT(*) INTO `vExecutivePerson`
  FROM `AUTHORIZED_PERSON_GROUP` APG
  JOIN `USER` U ON U.`ID` = APG.`AUTHORIZED_PERSON_ID`
  WHERE APG.`USER_ID` = `pUserId`
    AND U.`EXECUTIVE_PERSON` = 1;
  
  IF `vExecutivePerson` > 0 THEN
    SET `vExecutivePerson` = 1;
  END IF;
  
  RETURN `vExecutivePerson`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_LOCATION_ID` (`pLocationName` VARCHAR(100), `pAdd` BOOL) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vLocationId` INT DEFAULT 0;

  SELECT ID INTO `vLocationId`
  FROM `LOCATION`
  WHERE `NAME` = `pLocationName`;

  IF `pAdd` AND `vLocationId` = 0 THEN
    INSERT INTO `LOCATION`
    (`NAME`)
    VALUES
    (`pLocationName`);
    
    SELECT ID INTO `vLocationId`
    FROM `LOCATION`
    WHERE `NAME` = `pLocationName`;
  END IF;

  RETURN `vLocationId`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_LOCATION_NAME` (`pLocationId` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vLocationName` VARCHAR(100) DEFAULT '';

  SELECT NAME INTO `vLocationName`
  FROM `LOCATION`
  WHERE `ID` = `pLocationId`;

  RETURN `vLocationName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_POSITION_ID` (`pPositionName` VARCHAR(100), `pAdd` BOOL) RETURNS INT DETERMINISTIC BEGIN
  DECLARE `vPositionId` INT DEFAULT 0;

  SELECT ID INTO `vPositionId`
  FROM `POSITION`
  WHERE `NAME` = `pPositionName`;

  IF `pAdd` AND `vPositionId` = 0 THEN
    INSERT INTO `POSITION`
    (`NAME`)
    VALUES
    (`pPositionName`);
    
    SELECT ID INTO `vPositionId`
    FROM `POSITION`
    WHERE `NAME` = `pPositionName`;
  END IF;

  RETURN `vPositionId`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_POSITION_NAME` (`pPositionId` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vPositionName` VARCHAR(100) DEFAULT '';

  SELECT NAME INTO `vPositionName`
  FROM `POSITION`
  WHERE `ID` = `pPositionId`;

  RETURN `vPositionName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_REASON_NAME` (`pReasonId` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vReasonName` VARCHAR(100) DEFAULT '';

  SELECT NAME INTO `vReasonName`
  FROM `REASON`
  WHERE `ID` = `pReasonId`;

  RETURN `vReasonName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_ROUTE_NAME` (`pRouteId` INT) RETURNS VARCHAR(10) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vRouteName` VARCHAR(10) DEFAULT '';

  SELECT NAME INTO `vRouteName`
  FROM `ROUTE`
  WHERE `ID` = `pRouteId`;

  RETURN `vRouteName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_STATUS_NAME` (`pStatusId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vStatusName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vStatusName`
  FROM `STATUS`
  WHERE `ID` = `pStatusId`;

  RETURN `vStatusName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_TRANSPORTATION_COMPANY_NAME` (`pTransportationCompanyId` INT) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vTransportationCompanyName` VARCHAR(100) DEFAULT '';

  SELECT NAME INTO `vTransportationCompanyName`
  FROM `TRANSPORTATION_COMPANY`
  WHERE `ID` = `pTransportationCompanyId`;

  RETURN `vTransportationCompanyName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_TRANSPORTATION_MODE_NAME` (`pTransportationModeId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vTransportationModeName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vTransportationModeName`
  FROM `TRANSPORTATION_MODE`
  WHERE `ID` = `pTransportationModeId`;

  RETURN `vTransportationModeName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_TRAVELER_TYPE_NAME` (`pTravelerTypeId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vTravelerTypeName` VARCHAR(50) DEFAULT '';

  SELECT NAME INTO `vTravelerTypeName`
  FROM `TRAVELER_TYPE`
  WHERE `ID` = `pTravelerTypeId`;

  RETURN `vTravelerTypeName`;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GET_USERNAME` (`pUserId` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_turkish_ci DETERMINISTIC BEGIN
  DECLARE `vUserName` VARCHAR(50) DEFAULT '';

  SELECT USERNAME INTO `vUserName`
  FROM `USER`
  WHERE `ID` = `pUserId`;

  RETURN `vUserName`;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `authorized_person_group`
--

CREATE TABLE `authorized_person_group` (
  `ID` int NOT NULL,
  `AUTHORIZED_PERSON_ID` int NOT NULL,
  `USER_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `authorized_person_group`
--

INSERT INTO `authorized_person_group` (`ID`, `AUTHORIZED_PERSON_ID`, `USER_ID`) VALUES
(1, 1240, 1244),
(3, 1244, 1240),
(2, 1244, 1241);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `authorized_person_relation`
--

CREATE TABLE `authorized_person_relation` (
  `ID` int NOT NULL,
  `USER_ID` int DEFAULT NULL,
  `POSITION_ID` int DEFAULT NULL,
  `DEPARTMENT_ID` int DEFAULT NULL,
  `LOCATION_ID` int DEFAULT NULL,
  `ROUTE_ID` int DEFAULT NULL,
  `AUTHORIZED_PERSON_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `authorized_person_relation`
--

INSERT INTO `authorized_person_relation` (`ID`, `USER_ID`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`, `ROUTE_ID`, `AUTHORIZED_PERSON_ID`) VALUES
(1, 1240, NULL, NULL, NULL, NULL, 1244),
(2, 1241, NULL, NULL, NULL, 1, 1240),
(3, 1241, NULL, NULL, NULL, 2, 1244),
(4, 1244, NULL, NULL, NULL, NULL, 1240);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `city`
--

CREATE TABLE `city` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `COUNTRY_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `city`
--

INSERT INTO `city` (`ID`, `NAME`, `COUNTRY_ID`) VALUES
(1, 'ADANA', 220),
(2, 'ADIYAMAN', 220),
(3, 'AFYONKARAHİSAR', 220),
(4, 'AĞRI', 220),
(5, 'AMASYA', 220),
(6, 'ANKARA', 220),
(7, 'ANTALYA', 220),
(8, 'ARTVİN', 220),
(9, 'AYDIN', 220),
(10, 'BALIKESİR', 220),
(11, 'BİLECİK', 220),
(12, 'BİNGÖL', 220),
(13, 'BİTLİS', 220),
(14, 'BOLU', 220),
(15, 'BURDUR', 220),
(16, 'BURSA', 220),
(17, 'ÇANAKKALE', 220),
(18, 'ÇANKIRI', 220),
(19, 'ÇORUM', 220),
(20, 'DENİZLİ', 220),
(21, 'DİYARBAKIR', 220),
(22, 'EDİRNE', 220),
(23, 'ELAZIĞ', 220),
(24, 'ERZİNCAN', 220),
(25, 'ERZURUM', 220),
(26, 'ESKİŞEHİR', 220),
(27, 'GAZİANTEP', 220),
(28, 'GİRESUN', 220),
(29, 'GÜMÜŞHANE', 220),
(30, 'HAKKARİ', 220),
(31, 'HATAY', 220),
(32, 'ISPARTA', 220),
(33, 'MERSİN', 220),
(34, 'İSTANBUL', 220),
(35, 'İZMİR', 220),
(36, 'KARS', 220),
(37, 'KASTAMONU', 220),
(38, 'KAYSERİ', 220),
(39, 'KIRKLARELİ', 220),
(40, 'KIRŞEHİR', 220),
(41, 'KOCAELİ', 220),
(42, 'KONYA', 220),
(43, 'KÜTAHYA', 220),
(44, 'MALATYA', 220),
(45, 'MANİSA', 220),
(46, 'KAHRAMANMARAŞ', 220),
(47, 'MARDİN', 220),
(48, 'MUĞLA', 220),
(49, 'MUŞ', 220),
(50, 'NEVŞEHİR', 220),
(51, 'NİĞDE', 220),
(52, 'ORDU', 220),
(53, 'RİZE', 220),
(54, 'SAKARYA', 220),
(55, 'SAMSUN', 220),
(56, 'SİİRT', 220),
(57, 'SİNOP', 220),
(58, 'SİVAS', 220),
(59, 'TEKİRDAĞ', 220),
(60, 'TOKAT', 220),
(61, 'TRABZON', 220),
(62, 'TUNCELİ', 220),
(63, 'ŞANLIURFA', 220),
(64, 'UŞAK', 220),
(65, 'VAN', 220),
(66, 'YOZGAT', 220),
(67, 'ZONGULDAK', 220),
(68, 'AKSARAY', 220),
(69, 'BAYBURT', 220),
(70, 'KARAMAN', 220),
(71, 'KIRIKKALE', 220),
(72, 'BATMAN', 220),
(73, 'ŞIRNAK', 220),
(74, 'BARTIN', 220),
(75, 'ARDAHAN', 220),
(76, 'IĞDIR', 220),
(77, 'YALOVA', 220),
(78, 'KARABÜK', 220),
(79, 'KİLİS', 220),
(80, 'OSMANİYE', 220),
(81, 'DÜZCE', 220),
(901, 'BAKÜ', 14),
(902, 'BUDAPEŞTE', 137);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `country`
--

CREATE TABLE `country` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `country`
--

INSERT INTO `country` (`ID`, `NAME`) VALUES
(1, 'AFGANİSTAN'),
(2, 'ALMANYA'),
(3, 'AMERİKA BİRLEŞİK DEVLETLERİ'),
(4, 'AMERİKAN SAMOA'),
(5, 'ANDORRA'),
(6, 'ANGOLA'),
(7, 'ANGUİLLA, İNGİLTERE'),
(8, 'ANTİGUA VE BARBUDA'),
(9, 'ARJANTİN'),
(10, 'ARNAVUTLUK'),
(11, 'ARUBA, HOLLANDA'),
(12, 'AVUSTRALYA'),
(13, 'AVUSTURYA'),
(14, 'AZERBAYCAN'),
(15, 'BAHAMA ADALARI'),
(16, 'BAHREYN'),
(17, 'BANGLADEŞ'),
(18, 'BARBADOS'),
(19, 'BELÇİKA'),
(20, 'BELİZE'),
(21, 'BENİN'),
(22, 'BERMUDA, İNGİLTERE'),
(23, 'BEYAZ RUSYA'),
(24, 'BHUTAN'),
(25, 'BİRLEŞİK ARAP EMİRLİKLERİ'),
(26, 'BİRMANYA (MYANMAR)'),
(27, 'BOLİVYA'),
(28, 'BOSNA HERSEK'),
(29, 'BOTSWANA'),
(30, 'BREZİLYA'),
(31, 'BRUNEİ'),
(32, 'BULGARİSTAN'),
(33, 'BURKİNA FASO'),
(34, 'BURUNDİ'),
(35, 'CAPE VERDE'),
(36, 'CAYMAN ADALARI, İNGİLTERE'),
(37, 'CEZAYİR'),
(38, 'CHRİSTMAS ADASI, AVUSTURALYA'),
(39, 'CİBUTİ'),
(40, 'ÇAD'),
(41, 'ÇEK CUMHURİYETİ'),
(42, 'ÇİN'),
(43, 'DANİMARKA'),
(44, 'DOĞU TİMOR'),
(45, 'DOMİNİK CUMHURİYETİ'),
(46, 'DOMİNİKA'),
(48, 'EKVATOR'),
(47, 'EKVATOR GİNESİ'),
(49, 'EL SALVADOR'),
(50, 'ENDONEZYA'),
(51, 'ERİTRE'),
(52, 'ERMENİSTAN'),
(53, 'ESTONYA'),
(54, 'ETİYOPYA'),
(55, 'FAS'),
(56, 'FİJİ'),
(57, 'FİLDİŞİ SAHİLİ'),
(58, 'FİLİPİNLER'),
(59, 'FİLİSTİN'),
(60, 'FİNLANDİYA'),
(61, 'FOLKLAND ADALARI, İNGİLTERE'),
(62, 'FRANSA'),
(63, 'FRANSIZ GUYANASI'),
(64, 'FRANSIZ GÜNEY EYALETLERİ (KERGUELEN ADALARI)'),
(65, 'FRANSIZ POLİNEZYASI'),
(66, 'GABON'),
(67, 'GALLER'),
(68, 'GAMBİYA'),
(69, 'GANA'),
(70, 'GAZA STRİP'),
(71, 'GİBRALTAR, İNGİLTERE'),
(72, 'GİNE'),
(73, 'GİNE-BİSSAU'),
(74, 'GRENADA'),
(75, 'GRÖNLAND'),
(76, 'GUADALUP, FRANSA'),
(77, 'GUAM, AMERİKA'),
(78, 'GUATEMALA'),
(79, 'GUYANA'),
(80, 'GÜNEY AFRİKA'),
(81, 'GÜNEY GEORGİA VE GÜNEY SANDVİÇ ADALARI, İNGİLTERE'),
(82, 'GÜNEY KIBRIS RUM YÖNETİMİ'),
(83, 'GÜNEY KORE'),
(84, 'GÜRCİSTAN'),
(85, 'HAİTİ'),
(86, 'HAVAİ ADALARI'),
(87, 'HIRVATİSTAN'),
(88, 'HİNDİSTAN'),
(90, 'HOLLANDA'),
(89, 'HOLLANDA ANTİLLERİ'),
(91, 'HONDURAS'),
(92, 'IRAK'),
(93, 'İNGİLTERE'),
(94, 'İRAN'),
(95, 'İRLANDA'),
(96, 'İSKOÇYA'),
(97, 'İSPANYA'),
(98, 'İSRAİL'),
(99, 'İSVEÇ'),
(100, 'İSVİÇRE'),
(101, 'İTALYA'),
(102, 'İZLANDA'),
(103, 'JAMAİKA'),
(104, 'JAPONYA'),
(105, 'JOHNSTON ATOLL, AMERİKA'),
(106, 'K.K.T.C.'),
(107, 'KAMBOÇYA'),
(108, 'KAMERUN'),
(109, 'KANADA'),
(110, 'KANARYA ADALARI'),
(111, 'KARADAĞ'),
(112, 'KATAR'),
(113, 'KAZAKİSTAN'),
(114, 'KENYA'),
(115, 'KIRGIZİSTAN'),
(116, 'KİRİBATİ'),
(117, 'KOLOMBİYA'),
(118, 'KOMORLAR'),
(120, 'KONGO'),
(119, 'KONGO DEMOKRATİK CUMHURİYETİ'),
(121, 'KOSOVA'),
(122, 'KOSTA RİKA'),
(123, 'KUVEYT'),
(124, 'KUZEY İRLANDA'),
(125, 'KUZEY KORE'),
(126, 'KUZEY MARYANA ADALARI'),
(127, 'KÜBA'),
(128, 'LAOS'),
(129, 'LESOTHO'),
(130, 'LETONYA'),
(131, 'LİBERYA'),
(132, 'LİBYA'),
(133, 'LİECHTENSTEİN'),
(134, 'LİTVANYA'),
(135, 'LÜBNAN'),
(136, 'LÜKSEMBURG'),
(137, 'MACARİSTAN'),
(138, 'MADAGASKAR'),
(139, 'MAKAU (MAKAO)'),
(140, 'MAKEDONYA'),
(141, 'MALAVİ'),
(142, 'MALDİV ADALARI'),
(143, 'MALEZYA'),
(144, 'MALİ'),
(145, 'MALTA'),
(146, 'MARŞAL ADALARI'),
(147, 'MARTİNİK, FRANSA'),
(148, 'MAURİTİUS'),
(149, 'MAYOTTE, FRANSA'),
(150, 'MEKSİKA'),
(151, 'MISIR'),
(152, 'MİDWAY ADALARI, AMERİKA'),
(153, 'MİKRONEZYA'),
(154, 'MOĞOLİSTAN'),
(155, 'MOLDAVYA'),
(156, 'MONAKO'),
(157, 'MONTSERRAT'),
(158, 'MORİTANYA'),
(159, 'MOZAMBİK'),
(160, 'NAMİBİA'),
(161, 'NAURU'),
(162, 'NEPAL'),
(163, 'NİJER'),
(164, 'NİJERYA'),
(165, 'NİKARAGUA'),
(166, 'NİUE, YENİ ZELANDA'),
(167, 'NORVE'),
(168, 'ORTA AFRİKA CUMHURİYETİ'),
(169, 'ÖZBEKİSTAN'),
(170, 'PAKİSTAN'),
(171, 'PALAU ADALARI'),
(172, 'PALMYRA ATOLL, AMERİKA'),
(173, 'PANAMA'),
(174, 'PAPUA YENİ GİNE'),
(175, 'PARAGUAY'),
(176, 'PERU'),
(177, 'POLONYA'),
(178, 'PORTEKİZ'),
(179, 'PORTO RİKO, AMERİKA'),
(180, 'REUNİON, FRANSA'),
(181, 'ROMANYA'),
(182, 'RUANDA'),
(183, 'RUSYA FEDERASYONU'),
(184, 'SAİNT HELENA, İNGİLTERE'),
(185, 'SAİNT MARTİN, FRANSA'),
(186, 'SAİNT PİERRE VE MİQUELON, FRANSA'),
(187, 'SAMOA'),
(188, 'SAN MARİNO'),
(189, 'SANTA KİTTS VE NEVİS'),
(190, 'SANTA LUCİA'),
(191, 'SANTA VİNCENT VE GRENADİNLER'),
(192, 'SAO TOME VE PRİNCİPE'),
(193, 'SENEGAL'),
(194, 'SEYŞELLER'),
(195, 'SIRBİSTAN'),
(196, 'SİERRA LEONE'),
(197, 'SİNGAPUR'),
(198, 'SLOVAKYA'),
(199, 'SLOVENYA'),
(200, 'SOLOMON ADALARI'),
(201, 'SOMALİ'),
(202, 'SRİ LANKA'),
(203, 'SUDAN'),
(204, 'SURİNAM'),
(205, 'SURİYE'),
(206, 'SUUDİ ARABİSTAN'),
(207, 'SVALBARD, NORVEÇ'),
(208, 'SVAZİLAND'),
(209, 'ŞİLİ'),
(210, 'TACİKİSTAN'),
(211, 'TANZANYA'),
(212, 'TAYLAND'),
(213, 'TAYVAN'),
(214, 'TOGO'),
(215, 'TONGA'),
(216, 'TRİNİDAD VE TOBAGO'),
(217, 'TUNUS'),
(218, 'TURKS VE CAICOS ADALARI, İNGİLTERE'),
(219, 'TUVALU'),
(220, 'TÜRKİYE'),
(221, 'TÜRKMENİSTAN'),
(222, 'UGANDA'),
(223, 'UKRAYNA'),
(224, 'UMMAN'),
(225, 'URUGUAY'),
(226, 'ÜRDÜN'),
(227, 'VALLIS VE FUTUNA, FRANSA'),
(228, 'VANUATU'),
(229, 'VENEZUELA'),
(230, 'VİETNAM'),
(231, 'VİRGİN ADALARI, AMERİKA'),
(232, 'VİRGİN ADALARI, İNGİLTERE'),
(233, 'WAKE ADALARI, AMERİKA'),
(234, 'YEMEN'),
(235, 'YENİ KALEDONYA, FRANSA'),
(236, 'YENİ ZELANDA'),
(237, 'YUNANİSTAN'),
(238, 'ZAMBİYA'),
(239, 'ZİMBABVE');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `county`
--

CREATE TABLE `county` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `CITY_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `county`
--

INSERT INTO `county` (`ID`, `NAME`, `CITY_ID`) VALUES
(1101, 'ABANA', 37),
(1102, 'ACIPAYAM', 20),
(1103, 'ADALAR', 34),
(1104, 'SEYHAN', 1),
(1105, 'ADIYAMAN MERKEZ', 2),
(1106, 'ADİLCEVAZ', 13),
(1107, 'AFŞİN', 46),
(1108, 'AFYON MERKEZ', 3),
(1109, 'AĞLASUN', 15),
(1110, 'AĞIN', 23),
(1111, 'AĞRI MERKEZ', 4),
(1112, 'AHLAT', 13),
(1113, 'AKÇAABAT', 61),
(1114, 'AKÇADAĞ', 44),
(1115, 'AKÇAKALE', 63),
(1116, 'AKÇAKOCA', 81),
(1117, 'AKDAĞMADENİ', 66),
(1118, 'AKHİSAR', 45),
(1119, 'AKKUŞ', 52),
(1120, 'AKSARAY MERKEZ', 68),
(1121, 'AKSEKİ', 7),
(1122, 'AKŞEHİR', 42),
(1123, 'AKYAZI', 54),
(1124, 'ALACA', 19),
(1125, 'ALAÇAM', 55),
(1126, 'ALANYA', 7),
(1127, 'ALAŞEHİR', 45),
(1128, 'ALİAĞA', 35),
(1129, 'ALMUS', 60),
(1130, 'ALTINDAĞ', 6),
(1131, 'ALTINÖZÜ', 31),
(1132, 'ALTINTAŞ', 43),
(1133, 'ALUCRA', 28),
(1134, 'AMASYA MERKEZ', 5),
(1135, 'ANAMUR', 33),
(1136, 'ANDIRIN', 46),
(1137, 'ANKARA', 6),
(1138, 'ANTALYA MERKEZ', 7),
(1139, 'ARABAN', 27),
(1140, 'ARAÇ', 37),
(1141, 'ARAKLI', 61),
(1142, 'ARALIK', 76),
(1143, 'ARAPGİR', 44),
(1144, 'ARDAHAN MERKEZ', 75),
(1145, 'ARDANUÇ', 8),
(1146, 'ARDEŞEN', 53),
(1147, 'ARHAVİ', 8),
(1148, 'ARGUVAN', 44),
(1149, 'ARPAÇAY', 36),
(1150, 'ARSİN', 61),
(1151, 'ARTOVA', 60),
(1152, 'ARTVİN MERKEZ', 8),
(1153, 'AŞKALE', 25),
(1154, 'ATABEY', 32),
(1155, 'AVANOS', 50),
(1156, 'AYANCIK', 57),
(1157, 'AYAŞ', 6),
(1158, 'AYBASTI', 52),
(1159, 'AYDIN MERKEZ', 9),
(1160, 'AYVACIK', 17),
(1161, 'AYVALIK', 10),
(1162, 'AZDAVAY', 37),
(1163, 'BABAESKİ', 39),
(1164, 'BAFRA', 55),
(1165, 'BAHÇE', 80),
(1166, 'BAKIRKÖY', 34),
(1167, 'BALÂ', 6),
(1168, 'BALIKESİR MERKEZ', 10),
(1169, 'BALYA', 10),
(1170, 'BANAZ', 64),
(1171, 'BANDIRMA', 10),
(1172, 'BARTIN MERKEZ', 74),
(1173, 'BASKİL', 23),
(1174, 'BATMAN MERKEZ', 72),
(1175, 'BAŞKALE', 65),
(1176, 'BAYBURT MERKEZ', 69),
(1177, 'BAYAT', 19),
(1178, 'BAYINDIR', 35),
(1179, 'BAYKAN', 56),
(1180, 'BAYRAMİÇ', 17),
(1181, 'BERGAMA', 35),
(1182, 'BESNİ', 2),
(1183, 'BEŞİKTAŞ', 34),
(1184, 'BEŞİRİ', 72),
(1185, 'BEYKOZ', 34),
(1186, 'BEYOĞLU', 34),
(1187, 'BEYPAZARI', 6),
(1188, 'BEYŞEHİR', 42),
(1189, 'BEYTÜŞŞEBAP', 73),
(1190, 'BİGA', 17),
(1191, 'BİGADİÇ', 10),
(1192, 'BİLECİK MERKEZ', 11),
(1193, 'BİNGÖL MERKEZ', 12),
(1194, 'BİRECİK', 63),
(1195, 'BİSMİL', 21),
(1196, 'BİTLİS MERKEZ', 13),
(1197, 'BODRUM', 48),
(1198, 'BOĞAZLIYAN', 66),
(1199, 'BOLU MERKEZ', 14),
(1200, 'BOLVADİN', 3),
(1201, 'BOR', 51),
(1202, 'BORÇKA', 8),
(1203, 'BORNOVA', 35),
(1204, 'BOYABAT', 57),
(1205, 'BOZCAADA', 17),
(1206, 'BOZDOĞAN', 9),
(1207, 'BOZKIR', 42),
(1208, 'BOZKURT', 37),
(1209, 'BOZOVA', 63),
(1210, 'BOZÜYÜK', 11),
(1211, 'BUCAK', 15),
(1212, 'BULANCAK', 28),
(1213, 'BULANIK', 49),
(1214, 'BULDAN', 20),
(1215, 'BURDUR MERKEZ', 15),
(1216, 'BURHANİYE', 10),
(1217, 'BURSA MERKEZ', 16),
(1218, 'BÜNYAN', 38),
(1219, 'CEYHAN', 1),
(1220, 'CEYLANPINAR', 63),
(1221, 'CİDE', 37),
(1222, 'CİHANBEYLİ', 42),
(1223, 'CİZRE', 73),
(1224, 'ÇAL', 20),
(1225, 'ÇAMARDI', 51),
(1226, 'ÇAMELİ', 20),
(1227, 'ÇAMLIDERE', 6),
(1228, 'ÇAMLIHEMŞİN', 53),
(1229, 'ÇAN', 17),
(1230, 'ÇANAKKALE MERKEZ', 17),
(1231, 'ÇANKAYA', 6),
(1232, 'ÇANKIRI MERKEZ', 18),
(1233, 'ÇARDAK', 20),
(1234, 'ÇARŞAMBA', 55),
(1235, 'ÇAT', 25),
(1236, 'ÇATAK', 65),
(1237, 'ÇATALCA', 34),
(1238, 'ÇATALZEYTİN', 37),
(1239, 'ÇAY', 3),
(1240, 'ÇAYCUMA', 67),
(1241, 'ÇAYELİ', 53),
(1242, 'ÇAYIRALAN', 66),
(1243, 'ÇAYIRLI', 24),
(1244, 'ÇAYKARA', 61),
(1245, 'ÇEKEREK', 66),
(1246, 'ÇELİKHAN', 2),
(1247, 'ÇEMİŞGEZEK', 62),
(1248, 'ÇERKEŞ', 18),
(1249, 'ÇERMİK', 21),
(1250, 'ÇERKEZKÖY', 59),
(1251, 'ÇEŞME', 35),
(1252, 'ÇILDIR', 75),
(1253, 'ÇINAR', 21),
(1254, 'ÇİÇEKDAĞI', 40),
(1255, 'ÇİFTELER', 26),
(1256, 'ÇİNE', 9),
(1257, 'ÇİVRİL', 20),
(1258, 'ÇORLU', 59),
(1259, 'ÇORUM MERKEZ', 19),
(1260, 'ÇUBUK', 6),
(1261, 'ÇUKURCA', 30),
(1262, 'ÇUMRA', 42),
(1263, 'ÇÜNGÜŞ', 21),
(1264, 'DADAY', 37),
(1265, 'DARENDE', 44),
(1266, 'DATÇA', 48),
(1267, 'DAZKIRI', 3),
(1268, 'DELİCE', 71),
(1269, 'DEMİRCİ', 45),
(1270, 'DEMİRKÖY', 39),
(1271, 'DENİZLİ MERKEZ', 20),
(1272, 'DERELİ', 28),
(1273, 'DERİK', 47),
(1274, 'DERİNKUYU', 50),
(1275, 'DEVELİ', 38),
(1276, 'DEVREK', 67),
(1277, 'DEVREKÂNİ', 37),
(1278, 'DİCLE', 21),
(1279, 'DİGOR', 36),
(1280, 'DİKİLİ', 35),
(1281, 'DİNAR', 3),
(1282, 'DİVRİĞİ', 58),
(1283, 'DİYADİN', 4),
(1284, 'DİYARBAKIR MERKEZ', 21),
(1285, 'DOĞANHİSAR', 42),
(1286, 'DOĞANŞEHİR', 44),
(1287, 'DOĞUBAYAZIT', 4),
(1288, 'DOMANİÇ', 43),
(1289, 'DÖRTYOL', 31),
(1290, 'DURAĞAN', 57),
(1291, 'DURSUNBEY', 10),
(1292, 'DÜZCE MERKEZ', 81),
(1293, 'ECEABAT', 17),
(1294, 'EDREMİT', 10),
(1295, 'EDİRNE MERKEZ', 22),
(1296, 'EFLÂNİ', 78),
(1297, 'EĞİRDİR', 32),
(1298, 'ELAZIĞ MERKEZ', 23),
(1299, 'ELBİSTAN', 46),
(1300, 'ELDİVAN', 18),
(1301, 'ELEŞKİRT', 4),
(1302, 'ELMADAĞ', 6),
(1303, 'ELMALI', 7),
(1304, 'EMET', 43),
(1305, 'EMİNÖNÜ', 34),
(1306, 'EMİRDAĞ', 3),
(1307, 'ENEZ', 22),
(1308, 'ERBAA', 60),
(1309, 'ERCİŞ', 65),
(1310, 'ERDEK', 10),
(1311, 'ERDEMLİ', 33),
(1312, 'EREĞLİ', 42),
(1313, 'EREĞLİ', 67),
(1314, 'ERFELEK', 57),
(1315, 'ERGANİ', 21),
(1316, 'ERMENEK', 70),
(1317, 'ERUH', 56),
(1318, 'ERZİNCAN MERKEZ', 24),
(1319, 'ERZURUM MERKEZ', 25),
(1320, 'ESPİYE', 28),
(1321, 'ESKİPAZAR', 78),
(1322, 'ESKİŞEHİR MERKEZ', 26),
(1323, 'EŞME', 64),
(1324, 'EYNESİL', 28),
(1325, 'EYÜP', 34),
(1326, 'EZİNE', 17),
(1327, 'FATİH', 34),
(1328, 'FATSA', 52),
(1329, 'FEKE', 1),
(1330, 'FELAHİYE', 38),
(1331, 'FETHİYE', 48),
(1332, 'FINDIKLI', 53),
(1333, 'FİNİKE', 7),
(1334, 'FOÇA', 35),
(1335, 'GAZİANTEP MERKEZ', 27),
(1336, 'GAZİOSMANPAŞA', 34),
(1337, 'GAZİPAŞA', 7),
(1338, 'GEBZE', 41),
(1339, 'GEDİZ', 43),
(1340, 'GELİBOLU', 17),
(1341, 'GELENDOST', 32),
(1342, 'GEMEREK', 58),
(1343, 'GEMLİK', 16),
(1344, 'GENÇ', 12),
(1345, 'GERCÜŞ', 72),
(1346, 'GEREDE', 14),
(1347, 'GERGER', 2),
(1348, 'GERMENCİK', 9),
(1349, 'GERZE', 57),
(1350, 'GEVAŞ', 65),
(1351, 'GEYVE', 54),
(1352, 'GİRESUN MERKEZ', 28),
(1353, 'GÖKSUN', 46),
(1354, 'GÖLBAŞI', 2),
(1355, 'GÖLCÜK', 41),
(1356, 'GÖLE', 75),
(1357, 'GÖLHİSAR', 15),
(1358, 'GÖLKÖY', 52),
(1359, 'GÖLPAZARI', 11),
(1360, 'GÖNEN', 10),
(1361, 'GÖRELE', 28),
(1362, 'GÖRDES', 45),
(1363, 'GÖYNÜCEK', 5),
(1364, 'GÖYNÜK', 14),
(1365, 'GÜDÜL', 6),
(1366, 'GÜLNAR', 33),
(1367, 'GÜLŞEHİR', 50),
(1368, 'GÜMÜŞHACIKÖY', 5),
(1369, 'GÜMÜŞHANE MERKEZ', 29),
(1370, 'GÜNDOĞMUŞ', 7),
(1371, 'GÜNEY', 20),
(1372, 'GÜRPINAR', 65),
(1373, 'GÜRÜN', 58),
(1374, 'HACIBEKTAŞ', 50),
(1375, 'HADIM', 42),
(1376, 'HAFİK', 58),
(1377, 'HAKKARİ MERKEZ', 30),
(1378, 'HALFETİ', 63),
(1379, 'HAMUR', 4),
(1380, 'HANAK', 75),
(1381, 'HANİ', 21),
(1382, 'HASSA', 31),
(1383, 'HATAY MERKEZ', 31),
(1384, 'HAVRAN', 10),
(1385, 'HAVSA', 22),
(1386, 'HAVZA', 55),
(1387, 'HAYMANA', 6),
(1388, 'HAYRABOLU', 59),
(1389, 'HAZRO', 21),
(1390, 'HEKİMHAN', 44),
(1391, 'HENDEK', 54),
(1392, 'HINIS', 25),
(1393, 'HİLVAN', 63),
(1394, 'HİZAN', 13),
(1395, 'HOPA', 8),
(1396, 'HORASAN', 25),
(1397, 'HOZAT', 62),
(1398, 'IĞDIR MERKEZ', 76),
(1399, 'ILGAZ', 18),
(1400, 'ILGIN', 42),
(1401, 'ISPARTA MERKEZ', 32),
(1402, 'İÇEL MERKEZ', 33),
(1403, 'İDİL', 73),
(1404, 'İHSANİYE', 3),
(1405, 'İKİZDERE', 53),
(1406, 'İLİÇ', 24),
(1407, 'İMRANLI', 58),
(1408, 'GÖKÇEADA (İMROZ)', 17),
(1409, 'İNCESU', 38),
(1410, 'İNEBOLU', 37),
(1411, 'İNEGÖL', 16),
(1412, 'İPSALA', 22),
(1413, 'İSKENDERUN', 31),
(1414, 'İSKİLİP', 19),
(1415, 'İSLAHİYE', 27),
(1416, 'İSPİR', 25),
(1417, 'İSTANBUL MERKEZ', 34),
(1418, 'İVRİNDİ', 10),
(1419, 'İZMİR MERKEZ', 35),
(1420, 'İZNİK', 16),
(1421, 'KADIKÖY', 34),
(1422, 'KADINHANI', 42),
(1423, 'KADİRLİ', 80),
(1424, 'KAĞIZMAN', 36),
(1425, 'KAHTA', 2),
(1426, 'KALE', 20),
(1427, 'KALECİK', 6),
(1428, 'KALKANDERE', 53),
(1429, 'KAMAN', 40),
(1430, 'KANDIRA', 41),
(1431, 'KANGAL', 58),
(1432, 'KARABURUN', 35),
(1433, 'KARABÜK MERKEZ', 78),
(1434, 'KARACABEY', 16),
(1435, 'KARACASU', 9),
(1436, 'KARAHALLI', 64),
(1437, 'KARAİSALI', 1),
(1438, 'KARAKOÇAN', 23),
(1439, 'KARAMAN MERKEZ', 70),
(1440, 'KARAMÜRSEL', 41),
(1441, 'KARAPINAR', 42),
(1442, 'KARASU', 54),
(1443, 'KARATAŞ', 1),
(1444, 'KARAYAZI', 25),
(1445, 'KARGI', 19),
(1446, 'KARLIOVA', 12),
(1447, 'KARS MERKEZ', 36),
(1448, 'KARŞIYAKA', 35),
(1449, 'KARTAL', 34),
(1450, 'KASTAMONU MERKEZ', 37),
(1451, 'KAŞ', 7),
(1452, 'KAVAK', 55),
(1453, 'KAYNARCA', 54),
(1454, 'KAYSERİ MERKEZ', 38),
(1455, 'KEBAN', 23),
(1456, 'KEÇİBORLU', 32),
(1457, 'KELES', 16),
(1458, 'KELKİT', 29),
(1459, 'KEMAH', 24),
(1460, 'KEMALİYE', 24),
(1461, 'KEMALPAŞA', 35),
(1462, 'KEPSUT', 10),
(1463, 'KESKİN', 71),
(1464, 'KEŞAN', 22),
(1465, 'KEŞAP', 28),
(1466, 'KIBRISCIK', 14),
(1467, 'KINIK', 35),
(1468, 'KIRIKHAN', 31),
(1469, 'KIRIKKALE MERKEZ', 71),
(1470, 'KIRKAĞAÇ', 45),
(1471, 'KIRKLARELİ MERKEZ', 39),
(1472, 'KIRŞEHİR MERKEZ', 40),
(1473, 'KIZILCAHAMAM', 6),
(1474, 'KIZILTEPE', 47),
(1475, 'KİĞI', 12),
(1476, 'KİLİS MERKEZ', 79),
(1477, 'KİRAZ', 35),
(1478, 'KOCAELİ MERKEZ (İZMİT)', 41),
(1479, 'KOÇARLI', 9),
(1480, 'KOFÇAZ', 39),
(1481, 'KONYA MERKEZ', 42),
(1482, 'KORGAN', 52),
(1483, 'KORKUTELİ', 7),
(1484, 'KOYULHİSAR', 58),
(1485, 'KOZAKLI', 50),
(1486, 'KOZAN', 1),
(1487, 'KOZLUK', 72),
(1488, 'KÖYCEĞİZ', 48),
(1489, 'KULA', 45),
(1490, 'KULP', 21),
(1491, 'KULU', 42),
(1492, 'KUMLUCA', 7),
(1493, 'KUMRU', 52),
(1494, 'KURŞUNLU', 18),
(1495, 'KURTALAN', 56),
(1496, 'KURUCAŞİLE', 74),
(1497, 'KUŞADASI', 9),
(1498, 'KUYUCAK', 9),
(1499, 'KÜRE', 37),
(1500, 'KÜTAHYA MERKEZ', 43),
(1501, 'LADİK', 55),
(1502, 'LALAPAŞA', 22),
(1503, 'LAPSEKİ', 17),
(1504, 'LİCE', 21),
(1505, 'LÜLEBURGAZ', 39),
(1506, 'MADEN', 23),
(1507, 'MAÇKA', 61),
(1508, 'MAHMUDİYE', 26),
(1509, 'MALATYA MERKEZ', 44),
(1510, 'MALAZGİRT', 49),
(1511, 'MALKARA', 59),
(1512, 'MANAVGAT', 7),
(1513, 'MANİSA MERKEZ', 45),
(1514, 'MANYAS', 10),
(1515, 'KAHRAMANMARAŞ MERKEZ', 46),
(1516, 'MARDİN MERKEZ', 47),
(1517, 'MARMARİS', 48),
(1518, 'MAZGİRT', 62),
(1519, 'MAZIDAĞI', 47),
(1520, 'MECİTÖZÜ', 19),
(1521, 'MENEMEN', 35),
(1522, 'MENGEN', 14),
(1523, 'MERİÇ', 22),
(1524, 'MERZİFON', 5),
(1525, 'MESUDİYE', 52),
(1526, 'MİDYAT', 47),
(1527, 'MİHALIÇÇIK', 26),
(1528, 'MİLAS', 48),
(1529, 'MUCUR', 40),
(1530, 'MUDANYA', 16),
(1531, 'MUDURNU', 14),
(1532, 'MUĞLA MERKEZ', 48),
(1533, 'MURADİYE', 65),
(1534, 'MUŞ MERKEZ', 49),
(1535, 'MUSTAFAKEMALPAŞA', 16),
(1536, 'MUT', 33),
(1537, 'MUTKİ', 13),
(1538, 'MURATLI', 59),
(1539, 'NALLIHAN', 6),
(1540, 'NARMAN', 25),
(1541, 'NAZIMİYE', 62),
(1542, 'NAZİLLİ', 9),
(1543, 'NEVŞEHİR MERKEZ', 50),
(1544, 'NİĞDE MERKEZ', 51),
(1545, 'NİKSAR', 60),
(1546, 'NİZİP', 27),
(1547, 'NUSAYBİN', 47),
(1548, 'OF', 61),
(1549, 'OĞUZELİ', 27),
(1550, 'OLTU', 25),
(1551, 'OLUR', 25),
(1552, 'ORDU MERKEZ', 52),
(1553, 'ORHANELİ', 16),
(1554, 'ORHANGAZİ', 16),
(1555, 'ORTA', 18),
(1556, 'ORTAKÖY', 19),
(1557, 'ORTAKÖY', 68),
(1558, 'OSMANCIK', 19),
(1559, 'OSMANELİ', 11),
(1560, 'OSMANİYE MERKEZ', 80),
(1561, 'OVACIK', 78),
(1562, 'OVACIK', 62),
(1563, 'ÖDEMİŞ', 35),
(1564, 'ÖMERLİ', 47),
(1565, 'ÖZALP', 65),
(1566, 'PALU', 23),
(1567, 'PASİNLER', 25),
(1568, 'PATNOS', 4),
(1569, 'PAZAR', 53),
(1570, 'PAZARCIK', 46),
(1571, 'PAZARYERİ', 11),
(1572, 'PEHLİVANKÖY', 39),
(1573, 'PERŞEMBE', 52),
(1574, 'PERTEK', 62),
(1575, 'PERVARİ', 56),
(1576, 'PINARBAŞI', 38),
(1577, 'PINARHİSAR', 39),
(1578, 'POLATLI', 6),
(1579, 'POSOF', 75),
(1580, 'POZANTI', 1),
(1581, 'PÜLÜMÜR', 62),
(1582, 'PÜTÜRGE', 44),
(1583, 'REFAHİYE', 24),
(1584, 'REŞADİYE', 60),
(1585, 'REYHANLI', 31),
(1586, 'RİZE MERKEZ', 53),
(1587, 'SAFRANBOLU', 78),
(1588, 'SAİMBEYLİ', 1),
(1589, 'SAKARYA MERKEZ (ADAPAZARI)', 54),
(1590, 'SALİHLİ', 45),
(1591, 'SAMANDAĞ', 31),
(1592, 'SAMSAT', 2),
(1593, 'SAMSUN MERKEZ', 55),
(1594, 'SANDIKLI', 3),
(1595, 'SAPANCA', 54),
(1596, 'SARAY', 59),
(1597, 'SARAYKÖY', 20),
(1598, 'SARAYÖNÜ', 42),
(1599, 'SARICAKAYA', 26),
(1600, 'SARIGÖL', 45),
(1601, 'SARIKAMIŞ', 36),
(1602, 'SARIKAYA', 66),
(1603, 'SARIOĞLAN', 38),
(1604, 'SARIYER', 34),
(1605, 'SARIZ', 38),
(1606, 'SARUHANLI', 45),
(1607, 'SASON', 72),
(1608, 'SAVAŞTEPE', 10),
(1609, 'SAVUR', 47),
(1610, 'SEBEN', 14),
(1611, 'SEFERİHİSAR', 35),
(1612, 'SELÇUK', 35),
(1613, 'SELENDİ', 45),
(1614, 'SELİM', 36),
(1615, 'SENİRKENT', 32),
(1616, 'SERİK', 7),
(1617, 'SEYDİŞEHİR', 42),
(1618, 'SEYİTGAZİ', 26),
(1619, 'SINDIRGI', 10),
(1620, 'SİİRT MERKEZ', 56),
(1621, 'SİLİFKE', 33),
(1622, 'SİLİVRİ', 34),
(1623, 'SİLOPİ', 73),
(1624, 'SİLVAN', 21),
(1625, 'SİMAV', 43),
(1626, 'SİNCANLI', 3),
(1627, 'SİNOP MERKEZ', 57),
(1628, 'SİVAS MERKEZ', 58),
(1629, 'SİVASLI', 64),
(1630, 'SİVEREK', 63),
(1631, 'SİVRİCE', 23),
(1632, 'SİVRİHİSAR', 26),
(1633, 'SOLHAN', 12),
(1634, 'SOMA', 45),
(1635, 'SORGUN', 66),
(1636, 'SÖĞÜT', 11),
(1637, 'SÖKE', 9),
(1638, 'SULAKYURT', 71),
(1639, 'SULTANDAĞI', 3),
(1640, 'SULTANHİSAR', 9),
(1641, 'SULUOVA', 5),
(1642, 'SUNGURLU', 19),
(1643, 'SURUÇ', 63),
(1644, 'SUSURLUK', 10),
(1645, 'SUSUZ', 36),
(1646, 'SUŞEHRİ', 58),
(1647, 'SÜRMENE', 61),
(1648, 'SÜTÇÜLER', 32),
(1649, 'ŞABANÖZÜ', 18),
(1650, 'ŞARKIŞLA', 58),
(1651, 'ŞARKİKARAAĞAÇ', 32),
(1652, 'ŞARKÖY', 59),
(1653, 'ŞAVŞAT', 8),
(1654, 'ŞEBİNKARAHİSAR', 28),
(1655, 'ŞEFAATLİ', 66),
(1656, 'ŞEMDİNLİ', 30),
(1657, 'ŞENKAYA', 25),
(1658, 'ŞEREFLİKOÇHİSAR', 6),
(1659, 'ŞİLE', 34),
(1660, 'ŞİRAN', 29),
(1661, 'ŞIRNAK MERKEZ', 73),
(1662, 'ŞİRVAN', 56),
(1663, 'ŞİŞLİ', 34),
(1664, 'ŞUHUT', 3),
(1665, 'TARSUS', 33),
(1666, 'TAŞKÖPRÜ', 37),
(1667, 'TAŞLIÇAY', 4),
(1668, 'TAŞOVA', 5),
(1669, 'TATVAN', 13),
(1670, 'TAVAS', 20),
(1671, 'TAVŞANLI', 43),
(1672, 'TEFENNİ', 15),
(1673, 'TEKİRDAĞ MERKEZ', 59),
(1674, 'TEKMAN', 25),
(1675, 'TERCAN', 24),
(1676, 'TERME', 55),
(1677, 'TİRE', 35),
(1678, 'TİREBOLU', 28),
(1679, 'TOKAT MERKEZ', 60),
(1680, 'TOMARZA', 38),
(1681, 'TONYA', 61),
(1682, 'TORBALI', 35),
(1683, 'TORTUM', 25),
(1684, 'TORUL', 29),
(1685, 'TOSYA', 37),
(1686, 'TRABZON MERKEZ', 61),
(1687, 'TUFANBEYLİ', 1),
(1688, 'TUNCELİ MERKEZ', 62),
(1689, 'TURGUTLU', 45),
(1690, 'TURHAL', 60),
(1691, 'TUTAK', 4),
(1692, 'TUZLUCA', 76),
(1693, 'TÜRKELİ', 57),
(1694, 'TÜRKOĞLU', 46),
(1695, 'ULA', 48),
(1696, 'ULUBEY', 52),
(1697, 'ULUBEY', 64),
(1698, 'ULUDERE', 73),
(1699, 'ULUBORLU', 32),
(1700, 'ULUKIŞLA', 51),
(1701, 'ULUS', 74),
(1702, 'ŞANLIURFA MERKEZ', 63),
(1703, 'URLA', 35),
(1704, 'UŞAK MERKEZ', 64),
(1705, 'UZUNKÖPRÜ', 22),
(1706, 'ÜNYE', 52),
(1707, 'ÜRGÜP', 50),
(1708, 'ÜSKÜDAR', 34),
(1709, 'VAKFIKEBİR', 61),
(1710, 'VAN MERKEZ', 65),
(1711, 'VARTO', 49),
(1712, 'VEZİRKÖPRÜ', 55),
(1713, 'VİRANŞEHİR', 63),
(1714, 'VİZE', 39),
(1715, 'YAHYALI', 38),
(1716, 'YALOVA MERKEZ', 77),
(1717, 'YALVAÇ', 32),
(1718, 'YAPRAKLI', 18),
(1719, 'YATAĞAN', 48),
(1720, 'YAVUZELİ', 27),
(1721, 'YAYLADAĞI', 31),
(1722, 'YENİCE', 17),
(1723, 'YENİMAHALLE', 6),
(1724, 'YENİPAZAR', 9),
(1725, 'YENİŞEHİR', 16),
(1726, 'YERKÖY', 66),
(1727, 'YEŞİLHİSAR', 38),
(1728, 'YEŞİLOVA', 15),
(1729, 'YEŞİLYURT', 44),
(1730, 'YIĞILCA', 81),
(1731, 'YILDIZELİ', 58),
(1732, 'YOMRA', 61),
(1733, 'YOZGAT MERKEZ', 66),
(1734, 'YUMURTALIK', 1),
(1735, 'YUNAK', 42),
(1736, 'YUSUFELİ', 8),
(1737, 'YÜKSEKOVA', 30),
(1738, 'ZARA', 58),
(1739, 'ZEYTİNBURNU', 34),
(1740, 'ZİLE', 60),
(1741, 'ZONGULDAK MERKEZ', 67),
(1742, 'DALAMAN', 48),
(1743, 'DÜZİÇİ', 80),
(1744, 'GÖLBAŞI', 6),
(1745, 'KEÇİÖREN', 6),
(1746, 'MAMAK', 6),
(1747, 'SİNCAN', 6),
(1748, 'YÜREĞİR', 1),
(1749, 'ACIGÖL', 50),
(1750, 'ADAKLI', 12),
(1751, 'AHMETLİ', 45),
(1752, 'AKKIŞLA', 38),
(1753, 'AKÖREN', 42),
(1754, 'AKPINAR', 40),
(1755, 'AKSU', 32),
(1756, 'AKYAKA', 36),
(1757, 'ALADAĞ', 1),
(1758, 'ALAPLI', 67),
(1759, 'ALPU', 26),
(1760, 'ALTINEKİN', 42),
(1761, 'AMASRA', 74),
(1762, 'ARICAK', 23),
(1763, 'ASARCIK', 55),
(1764, 'ASLANAPA', 43),
(1765, 'ATKARACALAR', 18),
(1766, 'AYDINCIK', 33),
(1767, 'AYDINTEPE', 69),
(1768, 'AYRANCI', 70),
(1769, 'BABADAĞ', 20),
(1770, 'BAHÇESARAY', 65),
(1771, 'BAŞMAKÇI', 3),
(1772, 'BATTALGAZİ', 44),
(1773, 'BAYAT', 3),
(1774, 'BEKİLLİ', 20),
(1775, 'BEŞİKDÜZÜ', 61),
(1776, 'BEYDAĞ', 35),
(1777, 'BEYLİKOVA', 26),
(1778, 'BOĞAZKALE', 19),
(1779, 'BOZYAZI', 33),
(1780, 'BUCA', 35),
(1781, 'BUHARKENT', 9),
(1782, 'BÜYÜKÇEKMECE', 34),
(1783, 'BÜYÜKORHAN', 16),
(1784, 'CUMAYERİ', 81),
(1785, 'ÇAĞLIYANCERİT', 46),
(1786, 'ÇALDIRAN', 65),
(1787, 'DARGEÇİT', 47),
(1788, 'DEMİRÖZÜ', 69),
(1789, 'DEREBUCAK', 42),
(1790, 'DUMLUPINAR', 43),
(1791, 'EĞİL', 21),
(1792, 'ERZİN', 31),
(1793, 'GÖLMARMARA', 45),
(1794, 'GÖLYAKA', 81),
(1795, 'GÜLYALI', 52),
(1796, 'GÜNEYSU', 53),
(1797, 'GÜRGENTEPE', 52),
(1798, 'GÜROYMAK', 13),
(1799, 'HARMANCIK', 16),
(1800, 'HARRAN', 63),
(1801, 'HASKÖY', 49),
(1802, 'HİSARCIK', 43),
(1803, 'HONAZ', 20),
(1804, 'HÜYÜK', 42),
(1805, 'İHSANGAZİ', 37),
(1806, 'İMAMOĞLU', 1),
(1807, 'İNCİRLİOVA', 9),
(1808, 'İNÖNÜ', 26),
(1809, 'İSCEHİSAR', 3),
(1810, 'KAĞITHANE', 34),
(1811, 'KALE', 7),
(1812, 'KARAÇOBAN', 25),
(1813, 'KARAMANLI', 15),
(1814, 'KARATAY', 42),
(1815, 'KAZAN', 6),
(1816, 'KEMER', 15),
(1817, 'KIZILIRMAK', 18),
(1818, 'KOCAALİ', 54),
(1819, 'KONAK', 35),
(1820, 'KOVANCILAR', 23),
(1821, 'KÖRFEZ', 41),
(1822, 'KÖSE', 29),
(1823, 'KÜÇÜKÇEKMECE', 34),
(1824, 'MARMARA', 10),
(1825, 'MARMARAEREĞLİSİ', 59),
(1826, 'MENDERES', 35),
(1827, 'MERAM', 42),
(1828, 'MURGUL', 8),
(1829, 'NİLÜFER', 16),
(1830, 'ONDOKUZMAYIS', 55),
(1831, 'ORTACA', 48),
(1832, 'OSMANGAZİ', 16),
(1833, 'PAMUKOVA', 54),
(1834, 'PAZAR', 60),
(1835, 'PENDİK', 34),
(1836, 'PINARBAŞI', 37),
(1837, 'PİRAZİZ', 28),
(1838, 'SALIPAZARI', 55),
(1839, 'SELÇUKLU', 42),
(1840, 'SERİNHİSAR', 20),
(1841, 'ŞAHİNBEY', 27),
(1842, 'ŞALPAZARI', 61),
(1843, 'ŞAPHANE', 43),
(1844, 'ŞEHİTKAMİL', 27),
(1845, 'ŞENPAZAR', 37),
(1846, 'TALAS', 38),
(1847, 'TARAKLI', 54),
(1848, 'TAŞKENT', 42),
(1849, 'TEKKEKÖY', 55),
(1850, 'UĞURLUDAĞ', 19),
(1851, 'UZUNDERE', 25),
(1852, 'ÜMRANİYE', 34),
(1853, 'ÜZÜMLÜ', 24),
(1854, 'YAĞLIDERE', 28),
(1855, 'YAYLADERE', 12),
(1856, 'YENİCE', 78),
(1857, 'YENİPAZAR', 11),
(1858, 'YEŞİLYURT', 60),
(1859, 'YILDIRIM', 16),
(1860, 'AĞAÇÖREN', 68),
(1861, 'GÜZELYURT', 68),
(1862, 'KÂZIMKARABEKİR', 70),
(1863, 'KOCASİNAN', 38),
(1864, 'MELİKGAZİ', 38),
(1865, 'PAZARYOLU', 25),
(1866, 'SARIYAHŞİ', 68),
(1867, 'AĞLI', 37),
(1868, 'AHIRLI', 42),
(1869, 'AKÇAKENT', 40),
(1870, 'AKINCILAR', 58),
(1871, 'AKKÖY', 20),
(1872, 'AKYURT', 6),
(1873, 'ALACAKAYA', 23),
(1874, 'ALTINYAYLA', 15),
(1875, 'ALTINYAYLA', 58),
(1876, 'ALTUNHİSAR', 51),
(1877, 'AYDINCIK', 66),
(1878, 'AYDINLAR', 56),
(1879, 'AYVACIK', 55),
(1880, 'BAHŞİLİ', 71),
(1881, 'BAKLAN', 20),
(1882, 'BALIŞEYH', 71),
(1883, 'BAŞÇİFTLİK', 60),
(1884, 'BAŞYAYLA', 70),
(1885, 'BAYRAMÖREN', 18),
(1886, 'BAYRAMPAŞA', 34),
(1887, 'BELEN', 31),
(1888, 'BEYAĞAÇ', 20),
(1889, 'BOZKURT', 20),
(1890, 'BOZTEPE', 40),
(1891, 'ÇAMAŞ', 52),
(1892, 'ÇAMLIYAYLA', 33),
(1893, 'ÇAMOLUK', 28),
(1894, 'ÇANAKÇI', 28),
(1895, 'ÇANDIR', 66),
(1896, 'ÇARŞIBAŞI', 61),
(1897, 'ÇATALPINAR', 52),
(1898, 'ÇAVDARHİSAR', 43),
(1899, 'ÇAVDIR', 15),
(1900, 'ÇAYBAŞI', 52),
(1901, 'ÇELEBİ', 71),
(1902, 'ÇELTİK', 42),
(1903, 'ÇELTİKÇİ', 15),
(1904, 'ÇİFTLİK', 51),
(1905, 'ÇİLİMLİ', 81),
(1906, 'ÇOBANLAR', 3),
(1907, 'DERBENT', 42),
(1908, 'DEREPAZARI', 53),
(1909, 'DERNEKPAZARI', 61),
(1910, 'DİKMEN', 57),
(1911, 'DODURGA', 19),
(1912, 'DOĞANKENT', 28),
(1913, 'DOĞANŞAR', 58),
(1914, 'DOĞANYOL', 44),
(1915, 'DOĞANYURT', 37),
(1916, 'DÖRTDİVAN', 14),
(1917, 'DÜZKÖY', 61),
(1918, 'EDREMİT', 65),
(1919, 'EKİNÖZÜ', 46),
(1920, 'EMİRGAZİ', 42),
(1921, 'ESKİL', 68),
(1922, 'ETİMESGUT', 6),
(1923, 'EVCİLER', 3),
(1924, 'EVREN', 6),
(1925, 'FERİZLİ', 54),
(1926, 'GÖKÇEBEY', 67),
(1927, 'GÖLOVA', 58),
(1928, 'GÖMEÇ', 10),
(1929, 'GÖNEN', 32),
(1930, 'GÜCE', 28),
(1931, 'GÜÇLÜKONAK', 73),
(1932, 'GÜLAĞAÇ', 68),
(1933, 'GÜNEYSINIR', 42),
(1934, 'GÜNYÜZÜ', 26),
(1935, 'GÜRSU', 16),
(1936, 'HACILAR', 38),
(1937, 'HALKAPINAR', 42),
(1938, 'HAMAMÖZÜ', 5),
(1939, 'HAN', 26),
(1940, 'HANÖNÜ', 37),
(1941, 'HASANKEYF', 72),
(1942, 'HAYRAT', 61),
(1943, 'HEMŞİN', 53),
(1944, 'HOCALAR', 3),
(1945, 'ILICA', 25),
(1946, 'İBRADI', 7),
(1947, 'İKİZCE', 52),
(1948, 'İNHİSAR', 11),
(1949, 'İYİDERE', 53),
(1950, 'KABADÜZ', 52),
(1951, 'KABATAŞ', 52),
(1952, 'KADIŞEHRİ', 66),
(1953, 'KALE', 44),
(1954, 'KARAKEÇİLİ', 71),
(1955, 'KARAPÜRÇEK', 54),
(1956, 'KARKAMIŞ', 27),
(1957, 'KARPUZLU', 9),
(1958, 'KAVAKLIDERE', 48),
(1959, 'KEMER', 7),
(1960, 'KESTEL', 16),
(1961, 'KIZILÖREN', 3),
(1962, 'KOCAKÖY', 21),
(1963, 'KORGUN', 18),
(1964, 'KORKUT', 49),
(1965, 'KÖPRÜBAŞI', 45),
(1966, 'KÖPRÜBAŞI', 61),
(1967, 'KÖPRÜKÖY', 25),
(1968, 'KÖŞK', 9),
(1969, 'KULUNCAK', 44),
(1970, 'KUMLU', 31),
(1971, 'KÜRTÜN', 29),
(1972, 'LAÇİN', 19),
(1973, 'MİHALGAZİ', 26),
(1974, 'NURDAĞI', 27),
(1975, 'NURHAK', 46),
(1976, 'OĞUZLAR', 19),
(1977, 'OTLUKBELİ', 24),
(1978, 'ÖZVATAN', 38),
(1979, 'PAZARLAR', 43),
(1980, 'SARAY', 65),
(1981, 'SARAYDÜZÜ', 57),
(1982, 'SARAYKENT', 66),
(1983, 'SARIVELİLER', 70),
(1984, 'SEYDİLER', 37),
(1985, 'SİNCİK', 2),
(1986, 'SÖĞÜTLÜ', 54),
(1987, 'SULUSARAY', 60),
(1988, 'SÜLOĞLU', 22),
(1989, 'TUT', 2),
(1990, 'TUZLUKÇU', 42),
(1991, 'ULAŞ', 58),
(1992, 'YAHŞİHAN', 71),
(1993, 'YAKAKENT', 55),
(1994, 'YALIHÜYÜK', 42),
(1995, 'YAZIHAN', 44),
(1996, 'YEDİSU', 12),
(1997, 'YENİÇAĞA', 14),
(1998, 'YENİFAKILI', 66),
(2000, 'DİDİM (YENİHİSAR)', 9),
(2001, 'YENİŞARBADEMLİ', 32),
(2002, 'YEŞİLLİ', 47),
(2003, 'AVCILAR', 34),
(2004, 'BAĞCILAR', 34),
(2005, 'BAHÇELİEVLER', 34),
(2006, 'BALÇOVA', 35),
(2007, 'ÇİĞLİ', 35),
(2008, 'DAMAL', 75),
(2009, 'GAZİEMİR', 35),
(2010, 'GÜNGÖREN', 34),
(2011, 'KARAKOYUNLU', 76),
(2012, 'MALTEPE', 34),
(2013, 'NARLIDERE', 35),
(2014, 'SULTANBEYLİ', 34),
(2015, 'TUZLA', 34),
(2016, 'ESENLER', 34),
(2017, 'GÜMÜŞOVA', 81),
(2018, 'GÜZELBAHÇE', 35),
(2019, 'ALTINOVA', 77),
(2020, 'ARMUTLU', 77),
(2021, 'ÇINARCIK', 77),
(2022, 'ÇİFTLİKKÖY', 77),
(2023, 'ELBEYLİ', 79),
(2024, 'MUSABEYLİ', 79),
(2025, 'POLATELİ', 79),
(2026, 'TERMAL', 77),
(2027, 'HASANBEYLİ', 80),
(2028, 'SUMBAS', 80),
(2029, 'TOPRAKKALE', 80),
(2030, 'DERİNCE', 41),
(2031, 'KAYNAŞLI', 81),
(2032, 'SARIÇAM', 1),
(2033, 'ÇUKUROVA', 1),
(2034, 'PURSAKLAR', 6),
(2035, 'AKSU/ANTALYA', 7),
(2036, 'DÖŞEMEALTI', 7),
(2037, 'KEPEZ', 7),
(2038, 'KONYAALTI', 7),
(2039, 'MURATPAŞA', 7),
(2040, 'BAĞLAR', 21),
(2041, 'KAYAPINAR', 21),
(2042, 'SUR', 21),
(2043, 'YENİŞEHİR/DİYARBAKIR', 21),
(2044, 'PALANDÖKEN', 25),
(2045, 'YAKUTİYE', 25),
(2046, 'ODUNPAZARI', 26),
(2047, 'TEPEBAŞI', 26),
(2048, 'ARNAVUTKÖY', 34),
(2049, 'ATAŞEHİR', 34),
(2050, 'BAŞAKŞEHİR', 34),
(2051, 'BEYLİKDÜZÜ', 34),
(2052, 'ÇEKMEKÖY', 34),
(2053, 'ESENYURT', 34),
(2054, 'SANCAKTEPE', 34),
(2055, 'SULTANGAZİ', 34),
(2056, 'BAYRAKLI', 35),
(2057, 'KARABAĞLAR', 35),
(2058, 'BAŞİSKELE', 41),
(2059, 'ÇAYIROVA', 41),
(2060, 'DARICA', 41),
(2061, 'DİLOVASI', 41),
(2062, 'İZMİT', 41),
(2063, 'KARTEPE', 41),
(2064, 'AKDENİZ', 33),
(2065, 'MEZİTLİ', 33),
(2066, 'TOROSLAR', 33),
(2067, 'YENİŞEHİR/MERSİN', 33),
(2068, 'ADAPAZARI', 54),
(2069, 'ARİFİYE', 54),
(2070, 'ERENLER', 54),
(2071, 'SERDİVAN', 54),
(2072, 'ATAKUM', 55),
(2073, 'CANİK', 55),
(2074, 'İLKADIM', 55),
(9001, 'BAKÜ', 901),
(9002, 'BUDAPEŞTE', 902);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `department`
--

CREATE TABLE `department` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `department`
--

INSERT INTO `department` (`ID`, `NAME`) VALUES
(1, 'Anlaşmalı Kurumlar Direktörlüğü'),
(2, 'Bilgi Sistemleri Koordinatörlüğü'),
(3, 'Bilgi Sistemleri Müdürlüğü'),
(4, 'Biyomedikal Müdürlüğü'),
(5, 'Dijital Dönüşüm Koordinatörlüğü'),
(6, 'Hasta Bakım Hizmetleri Direktörlüğü'),
(7, 'Hekimlik Hizmetleri Direktörlüğü'),
(8, 'Hukuk Müşavirliği'),
(9, 'İdari İşler Direktörlüğü'),
(10, 'İnsan Kaynakları Koordinatörlüğü'),
(11, 'Kalite ve Risk Yönetimi Direktörlüğü'),
(12, 'Kurumsal Faturalama Direktörlüğü'),
(13, 'Kurumsal Operasyonlar Grup Koordinatörlüğü'),
(14, 'Kurumsal Tanıtım ve Marka Yönetimi Koordinatörlüğü'),
(15, 'Laboratuvar Direktörlüğü'),
(16, 'Mali İşler Koordinatörlüğü'),
(17, 'Misafir Hizmetleri'),
(18, 'MLPCARE ARGE'),
(19, 'Organizasyon Koordinasyon'),
(20, 'Otelcilik Hizmetleri Müdürlüğü'),
(21, 'Resmi İşlemler ve Ruhsatlandırma Direktörlüğü'),
(22, 'Strateji ve Performans Grup Koordinatörlüğü'),
(23, 'Tedarik Zinciri Direktörlüğü'),
(24, 'Teknik Hizmetler Müdürlüğü'),
(25, 'Uluslararası Hasta Merkezi Direktörlüğü'),
(26, 'Üst Yönetim'),
(27, 'Verimlilik ve İş Zekası Direktörlüğü'),
(28, 'Yatırımcı İlişkileri ve Strateji Direktörlüğü'),
(29, 'Yönetim Kurulu'),
(30, 'Yurtdışı Operasyon Direktörlüğü');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `hospital_group`
--

CREATE TABLE `hospital_group` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `hospital_group`
--

INSERT INTO `hospital_group` (`ID`, `NAME`) VALUES
(1, 'LIV'),
(2, 'MP'),
(3, 'VM MP');

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

--
-- Tablo döküm verisi `location`
--

INSERT INTO `location` (`ID`, `NAME`, `HOSPITAL_GROUP_ID`, `COUNTY_ID`) VALUES
(1, 'Genel Merkez', NULL, 1325),
(2, 'Liv Hospital Ankara', 1, 1231),
(3, 'Liv Hospital Gaziantep', 1, 1844),
(4, 'Liv Hospital Samsun', 1, 2074),
(5, 'Liv Hospital Ulus', 1, 1183),
(6, 'Liv Hospital Vadistanbul', 1, 1604),
(7, 'Liv Bona Dea Hospital', 1, 9001),
(8, 'Liv Duna Medical Center', 1, 9002),
(9, 'İstinye Üniversite Hastanesi Liv Hospital Bahçeşehir', 1, 2053),
(10, 'Medical Park Adana', 2, 1104),
(11, 'Medical Park Ankara', 2, 1723),
(12, 'Medical Park Antalya', 2, 2039),
(13, 'Medical Park Bahçelievler', 2, 2005),
(14, 'Medical Park Çanakkale', 2, 1230),
(15, 'Medical Park Gebze', 2, 1338),
(16, 'Medical Park Göztepe', 2, 1421),
(17, 'Medical Park Karadeniz', 2, 1686),
(18, 'Medical Park Ordu', 2, 1552),
(19, 'Medical Park Seyhan', 2, 1104),
(20, 'Medical Park Tokat', 2, 1679),
(21, 'Medical Park Yıldızlı', 2, 1113),
(22, 'İstinye Üniversite Hastanesi Medical Park Gaziosmanpaşa', 2, 1336),
(23, 'VM Medical Park Ankara', 3, 1745),
(24, 'VM Medical Park Bursa', 3, 1832),
(25, 'VM Medical Park Kocaeli', 3, 2058),
(26, 'VM Medical Park Maltepe', 3, 2012),
(27, 'VM Medical Park Mersin', 3, 2065),
(28, 'VM Medical Park Pendik', 3, 1835),
(29, 'VM Medical Park Samsun', 3, 2072),
(30, 'İAÜ VM Medical Park Florya', 3, 1823),
(31, 'MLPCare ARGE', NULL, 1325),
(32, 'Dijital Dönüşüm Ofisi', NULL, 1604),
(33, 'Vadi Ofis', NULL, 1604),
(35, 'Merkez', NULL, 1325);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `log_login_record`
--

CREATE TABLE `log_login_record` (
  `ID` int NOT NULL,
  `USER_ID` int NOT NULL,
  `LOGIN_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `log_login_record`
--

INSERT INTO `log_login_record` (`ID`, `USER_ID`, `LOGIN_TIME`) VALUES
(1, 1240, '2024-02-17 16:26:44'),
(2, 1240, '2024-02-17 16:29:11'),
(3, 1240, '2024-02-17 16:33:01'),
(4, 1240, '2024-02-17 16:42:49'),
(5, 1240, '2024-02-17 17:21:11'),
(6, 1240, '2024-02-19 14:40:27'),
(7, 1240, '2024-02-19 14:47:31'),
(8, 1240, '2024-02-20 12:25:37'),
(9, 1240, '2024-02-21 03:43:29'),
(10, 1240, '2024-02-21 03:45:37'),
(11, 1241, '2024-02-21 15:38:43'),
(12, 1240, '2024-02-24 14:26:04'),
(13, 1240, '2024-02-24 20:38:44'),
(14, 1240, '2024-02-25 01:25:02'),
(15, 1240, '2024-03-05 11:22:30'),
(16, 1240, '2024-03-05 11:23:29'),
(17, 1240, '2024-03-05 11:23:34'),
(18, 1240, '2024-03-05 11:23:35'),
(19, 1240, '2024-03-05 11:23:35'),
(20, 1240, '2024-03-05 11:23:36'),
(21, 1240, '2024-03-05 11:23:36'),
(22, 1240, '2024-03-05 11:23:36'),
(23, 1240, '2024-03-05 11:24:21'),
(24, 1240, '2024-03-05 11:26:04'),
(25, 1240, '2024-03-05 11:26:10'),
(26, 1240, '2024-03-05 11:26:11'),
(27, 1240, '2024-03-05 11:26:11'),
(28, 1240, '2024-03-05 11:26:11'),
(29, 1240, '2024-03-05 11:26:11'),
(30, 1240, '2024-03-05 11:26:11'),
(31, 1240, '2024-03-05 11:26:12'),
(32, 1240, '2024-03-05 11:26:12'),
(33, 1240, '2024-03-05 11:26:12'),
(34, 1240, '2024-03-05 11:26:12'),
(35, 1240, '2024-03-05 11:26:13'),
(36, 1240, '2024-03-05 11:26:13'),
(37, 1240, '2024-03-05 11:26:13'),
(38, 1240, '2024-03-05 11:26:42'),
(39, 1240, '2024-03-05 11:26:47'),
(40, 1240, '2024-03-05 11:28:21'),
(41, 1240, '2024-03-05 11:31:18'),
(42, 1240, '2024-03-05 11:31:24'),
(43, 1240, '2024-03-05 11:32:20'),
(44, 1240, '2024-03-05 11:34:22'),
(45, 1242, '2024-03-05 11:38:19'),
(46, 1240, '2024-03-05 13:55:49'),
(47, 1240, '2024-03-05 13:56:06'),
(48, 1241, '2024-03-06 11:23:54'),
(49, 1241, '2024-03-06 11:23:54'),
(50, 1241, '2024-03-06 11:24:02'),
(51, 1240, '2024-03-15 11:41:18'),
(52, 1240, '2024-03-19 09:57:29'),
(53, 1240, '2024-03-21 01:34:32'),
(54, 1240, '2024-03-26 09:32:23'),
(55, 1240, '2024-03-26 13:30:22'),
(56, 1240, '2024-03-27 11:02:35'),
(57, 1240, '2024-03-27 11:38:42'),
(58, 1240, '2024-03-27 12:01:46'),
(59, 1240, '2024-03-27 12:05:21'),
(60, 1240, '2024-03-27 12:17:00'),
(61, 1240, '2024-03-27 13:48:13'),
(62, 1240, '2024-03-27 13:55:36'),
(63, 1240, '2024-03-27 13:55:44'),
(64, 1240, '2024-03-27 14:04:16'),
(65, 1240, '2024-03-27 14:17:46'),
(66, 1240, '2024-03-27 14:29:33'),
(67, 1240, '2024-03-27 14:29:34'),
(68, 1240, '2024-03-27 14:29:38'),
(69, 1240, '2024-03-28 11:39:05'),
(70, 1240, '2024-03-28 12:49:40'),
(71, 1240, '2024-03-28 12:49:48'),
(72, 1240, '2024-03-28 12:49:53'),
(73, 1240, '2024-03-28 12:51:16'),
(74, 1240, '2024-03-28 12:52:09'),
(75, 1240, '2024-03-28 13:00:15'),
(76, 1240, '2024-03-28 13:00:23'),
(77, 1240, '2024-03-28 13:01:22'),
(78, 1240, '2024-03-28 13:02:09'),
(79, 1240, '2024-03-28 13:03:58'),
(80, 1240, '2024-03-28 14:53:15'),
(81, 1240, '2024-04-01 11:49:40'),
(82, 1240, '2024-04-02 13:18:06'),
(83, 1240, '2024-04-02 13:38:59'),
(84, 1241, '2024-04-02 14:04:32'),
(85, 1240, '2024-04-18 11:53:46'),
(86, 1240, '2024-04-18 11:53:52'),
(87, 1240, '2024-04-18 11:53:55'),
(88, 1240, '2024-04-18 11:54:11'),
(89, 1240, '2024-04-18 15:48:04'),
(90, 1240, '2024-04-18 15:48:06'),
(91, 1240, '2024-04-18 15:50:56'),
(92, 1240, '2024-04-18 15:51:37'),
(93, 1240, '2024-04-24 14:43:24'),
(94, 1240, '2024-04-24 14:43:31'),
(95, 1240, '2024-04-24 14:45:41'),
(96, 1240, '2024-04-26 10:51:54'),
(97, 1243, '2024-04-29 10:38:28'),
(98, 1243, '2024-04-29 10:38:32'),
(99, 1243, '2024-04-29 13:30:01'),
(100, 1243, '2024-04-29 13:30:09'),
(101, 1240, '2024-04-29 15:19:33'),
(102, 1240, '2024-04-29 15:20:19'),
(103, 1240, '2024-04-29 16:23:07'),
(104, 1240, '2024-04-29 16:23:52'),
(105, 1240, '2024-04-29 16:27:01'),
(106, 1240, '2024-04-29 16:27:45'),
(107, 1240, '2024-04-29 16:28:01'),
(108, 1240, '2024-04-29 16:28:45'),
(109, 1240, '2024-04-29 16:30:28'),
(110, 1240, '2024-04-29 16:37:49'),
(111, 1240, '2024-04-29 16:38:59'),
(112, 1240, '2024-04-29 16:39:34'),
(113, 1240, '2024-04-29 16:39:55'),
(114, 1240, '2024-04-29 16:42:47'),
(115, 1240, '2024-04-29 16:43:26'),
(116, 1240, '2024-04-29 16:44:24'),
(117, 1240, '2024-04-29 16:45:32'),
(118, 1240, '2024-04-29 16:45:56'),
(119, 1240, '2024-04-29 16:46:11'),
(120, 1240, '2024-04-29 16:47:07'),
(121, 1240, '2024-04-29 16:47:16'),
(122, 1240, '2024-04-29 16:47:38'),
(123, 1240, '2024-04-29 16:47:48'),
(124, 1240, '2024-04-29 16:48:46'),
(125, 1240, '2024-04-29 16:49:10'),
(126, 1240, '2024-04-29 16:49:32'),
(127, 1240, '2024-04-29 16:49:51'),
(128, 1240, '2024-04-29 16:50:09'),
(129, 1240, '2024-04-29 16:51:11'),
(130, 1240, '2024-04-29 16:51:33'),
(131, 1240, '2024-04-29 16:53:00'),
(132, 1240, '2024-04-29 16:56:03'),
(133, 1240, '2024-04-29 16:56:49'),
(134, 1240, '2024-04-29 16:57:01'),
(135, 1240, '2024-04-29 16:57:23'),
(136, 1240, '2024-04-29 16:58:37'),
(137, 1240, '2024-04-29 16:58:47'),
(138, 1240, '2024-04-30 10:07:47'),
(139, 1240, '2024-04-30 10:07:47'),
(140, 1240, '2024-04-30 17:22:40'),
(141, 1240, '2024-04-30 18:00:49'),
(142, 1240, '2024-04-30 18:01:02'),
(143, 1240, '2024-04-30 18:02:30'),
(144, 1240, '2024-04-30 18:14:14'),
(145, 1240, '2024-04-30 18:14:15'),
(146, 1240, '2024-04-30 18:14:17'),
(147, 1240, '2024-05-02 01:17:01'),
(148, 1240, '2024-05-02 01:17:13'),
(149, 1240, '2024-05-02 06:57:34'),
(150, 1240, '2024-05-02 09:16:15'),
(151, 1240, '2024-05-02 10:31:39'),
(152, 1240, '2024-05-02 12:07:20'),
(153, 1240, '2024-05-02 12:07:20'),
(154, 1240, '2024-05-02 12:07:23'),
(155, 1240, '2024-05-02 12:07:23'),
(156, 1240, '2024-05-02 12:07:25'),
(157, 1240, '2024-05-02 12:07:26'),
(158, 1240, '2024-05-02 12:07:27'),
(159, 1240, '2024-05-02 12:07:28'),
(160, 1240, '2024-05-02 12:07:28'),
(161, 1240, '2024-05-02 12:09:35'),
(162, 1240, '2024-05-03 05:12:35'),
(163, 1240, '2024-05-03 05:12:35'),
(164, 1240, '2024-05-03 14:14:56'),
(165, 1240, '2024-05-03 18:32:46'),
(166, 1240, '2024-05-03 18:32:49'),
(167, 1240, '2024-05-06 11:29:05'),
(168, 1240, '2024-05-13 11:52:34'),
(169, 1240, '2024-05-13 11:53:17'),
(170, 1240, '2024-05-13 11:54:02'),
(171, 1240, '2024-05-13 12:24:20'),
(172, 1240, '2024-05-13 12:24:20'),
(173, 1240, '2024-05-13 12:24:20'),
(174, 1240, '2024-05-13 12:24:20'),
(175, 1240, '2024-05-13 12:24:20'),
(176, 1240, '2024-05-13 12:24:20'),
(177, 1240, '2024-05-13 12:24:21'),
(178, 1240, '2024-05-13 12:24:21'),
(179, 1240, '2024-05-13 12:24:21'),
(180, 1240, '2024-05-13 12:24:21'),
(181, 1240, '2024-05-13 12:24:21'),
(182, 1240, '2024-05-13 12:24:21'),
(183, 1240, '2024-05-13 12:24:21'),
(184, 1240, '2024-05-13 12:25:03'),
(185, 1240, '2024-05-13 12:31:27'),
(186, 1240, '2024-05-13 12:48:00'),
(187, 1240, '2024-05-13 12:48:21'),
(188, 1240, '2024-05-13 12:50:35'),
(189, 1240, '2024-05-13 12:51:28'),
(190, 1240, '2024-05-13 13:01:03'),
(191, 1240, '2024-05-13 13:01:16'),
(192, 1240, '2024-05-13 13:02:07'),
(193, 1240, '2024-05-13 13:02:09'),
(194, 1240, '2024-05-13 13:02:30'),
(195, 1240, '2024-05-13 13:23:26'),
(196, 1240, '2024-05-13 13:23:26'),
(197, 1240, '2024-05-13 13:23:31'),
(198, 1240, '2024-05-13 13:23:35'),
(199, 1240, '2024-05-13 13:24:46'),
(200, 1240, '2024-05-13 13:35:04'),
(201, 1240, '2024-05-13 13:35:51'),
(202, 1240, '2024-05-13 13:36:42'),
(203, 1240, '2024-05-13 13:37:59'),
(204, 1240, '2024-05-13 13:38:50'),
(205, 1240, '2024-05-13 13:49:07'),
(206, 1240, '2024-05-13 13:49:55'),
(207, 1240, '2024-05-13 13:50:15'),
(208, 1240, '2024-05-13 13:50:38'),
(209, 1240, '2024-05-13 13:51:27'),
(210, 1240, '2024-05-13 13:51:45'),
(211, 1240, '2024-05-19 16:38:52'),
(212, 1240, '2024-05-19 16:38:54'),
(213, 1240, '2024-05-19 22:54:46'),
(214, 1240, '2024-05-19 22:57:50'),
(215, 1240, '2024-05-19 22:58:00'),
(216, 1240, '2024-05-19 23:01:55'),
(217, 1240, '2024-05-19 23:04:05'),
(218, 1240, '2024-05-30 16:17:58'),
(219, 1240, '2024-05-30 16:18:01'),
(220, 1240, '2024-05-30 20:35:10'),
(221, 1240, '2024-05-30 20:40:11'),
(222, 1240, '2024-05-30 20:41:00'),
(223, 1240, '2024-05-30 22:43:14'),
(224, 1240, '2024-05-30 22:43:20'),
(225, 1240, '2024-06-03 15:35:29'),
(226, 1240, '2024-06-03 16:45:50'),
(227, 1240, '2024-06-03 16:45:52'),
(228, 1240, '2024-06-05 15:28:49'),
(229, 1240, '2024-06-12 15:43:44'),
(230, 1240, '2024-06-12 15:43:51'),
(231, 1240, '2024-06-12 15:43:54'),
(232, 1240, '2024-06-12 15:44:20'),
(233, 1240, '2024-06-12 15:44:21'),
(234, 1240, '2024-06-12 15:44:21'),
(235, 1240, '2024-06-12 15:44:21'),
(236, 1240, '2024-06-12 15:44:21'),
(237, 1240, '2024-06-12 15:44:22'),
(238, 1240, '2024-06-12 15:44:22'),
(239, 1240, '2024-06-12 15:47:59'),
(240, 1240, '2024-06-12 15:50:25'),
(241, 1240, '2024-06-12 16:09:50'),
(242, 1240, '2024-06-12 16:12:06'),
(243, 1240, '2024-06-12 16:12:48'),
(244, 1240, '2024-06-12 16:15:28'),
(245, 1240, '2024-06-12 16:16:32'),
(246, 1240, '2024-06-12 16:16:51'),
(247, 1240, '2024-06-12 16:17:45'),
(248, 1240, '2024-06-12 16:18:27'),
(249, 1240, '2024-06-12 16:20:44'),
(250, 1240, '2024-06-13 03:21:42'),
(251, 1240, '2024-06-13 03:22:42'),
(252, 1240, '2024-06-13 03:23:36'),
(253, 1240, '2024-06-13 03:25:06'),
(254, 1240, '2024-06-26 16:13:31'),
(255, 1240, '2024-06-26 16:23:58'),
(256, 1240, '2024-06-27 09:47:35'),
(257, 1240, '2024-06-27 10:28:44'),
(258, 1240, '2024-06-28 19:06:09'),
(259, 1240, '2024-07-01 00:48:52'),
(260, 1240, '2024-07-02 12:09:32'),
(261, 1240, '2024-07-02 12:29:58'),
(262, 1240, '2024-07-02 13:30:55'),
(263, 1240, '2024-07-02 13:31:13'),
(264, 1240, '2024-07-02 13:31:26'),
(265, 1240, '2024-07-02 13:52:43'),
(266, 1240, '2024-07-02 13:55:53'),
(267, 1240, '2024-07-02 14:01:14'),
(268, 1240, '2024-07-02 14:01:47'),
(269, 1240, '2024-07-02 14:02:10'),
(270, 1240, '2024-07-02 14:02:33'),
(271, 1240, '2024-07-02 14:02:57'),
(272, 1240, '2024-07-02 15:11:03'),
(273, 1240, '2024-07-02 15:12:16'),
(274, 1240, '2024-07-02 15:13:52'),
(275, 1240, '2024-07-02 15:17:38'),
(276, 1240, '2024-07-02 15:20:14'),
(277, 1240, '2024-07-02 15:23:43'),
(278, 1240, '2024-07-02 15:25:04'),
(279, 1240, '2024-07-03 05:26:19'),
(280, 1240, '2024-07-03 05:28:42'),
(281, 1240, '2024-07-03 11:58:01'),
(282, 1241, '2024-07-03 15:08:51'),
(283, 1240, '2024-07-03 15:46:24'),
(284, 1240, '2024-07-08 09:41:53'),
(285, 1241, '2024-07-08 11:50:23'),
(286, 1240, '2024-07-08 12:22:33'),
(287, 1240, '2024-07-08 12:23:02'),
(288, 1240, '2024-07-08 12:27:48'),
(289, 1240, '2024-07-08 12:42:11'),
(290, 1240, '2024-07-08 12:42:33'),
(291, 1240, '2024-07-08 12:42:57'),
(292, 1240, '2024-07-08 12:43:06'),
(293, 1240, '2024-07-08 12:43:15'),
(294, 1240, '2024-07-08 12:43:22'),
(295, 1240, '2024-07-08 12:43:37'),
(296, 1240, '2024-07-08 12:46:04'),
(297, 1240, '2024-07-08 12:46:51'),
(298, 1240, '2024-07-08 13:02:28'),
(299, 1240, '2024-07-08 13:05:53'),
(300, 1240, '2024-07-08 13:10:15'),
(301, 1240, '2024-07-08 13:18:15'),
(302, 1240, '2024-07-08 13:23:24'),
(303, 1240, '2024-07-08 16:38:19'),
(304, 1240, '2024-07-08 16:38:52'),
(305, 1240, '2024-07-08 16:39:23'),
(306, 1240, '2024-07-09 09:46:52'),
(307, 1240, '2024-07-09 09:49:04'),
(308, 1240, '2024-07-09 10:33:02'),
(309, 1240, '2024-07-09 10:33:27'),
(310, 1240, '2024-07-09 10:42:37'),
(311, 1240, '2024-07-09 10:43:26'),
(312, 1240, '2024-07-09 10:51:55'),
(313, 1240, '2024-07-09 10:52:40'),
(314, 1240, '2024-07-09 10:54:16'),
(315, 1240, '2024-07-09 10:54:46'),
(316, 1240, '2024-07-09 10:56:22'),
(317, 1240, '2024-07-09 10:56:54'),
(318, 1240, '2024-07-09 10:57:19'),
(319, 1240, '2024-07-09 10:57:37'),
(320, 1240, '2024-07-09 10:57:49'),
(321, 1240, '2024-07-09 10:58:09'),
(322, 1240, '2024-07-09 11:22:42'),
(323, 1240, '2024-07-09 11:37:51'),
(324, 1240, '2024-07-09 11:59:33'),
(325, 1240, '2024-07-09 12:25:17'),
(326, 1240, '2024-07-09 13:24:39'),
(327, 1240, '2024-07-09 14:02:18'),
(328, 1240, '2024-07-09 15:52:43'),
(329, 1240, '2024-07-09 16:03:22'),
(330, 1240, '2024-07-11 11:19:18'),
(331, 1240, '2024-07-11 11:27:11'),
(332, 1240, '2024-07-11 12:29:57'),
(333, 1240, '2024-07-11 16:46:10'),
(334, 1240, '2024-07-11 17:07:25'),
(335, 1240, '2024-07-12 09:41:21'),
(336, 1240, '2024-07-12 09:43:20'),
(337, 1240, '2024-07-12 09:43:32'),
(338, 1240, '2024-07-12 09:50:25'),
(339, 1240, '2024-07-12 10:02:13'),
(340, 1240, '2024-07-12 10:24:42'),
(341, 1240, '2024-07-12 10:27:55'),
(342, 1240, '2024-07-12 10:30:48'),
(343, 1240, '2024-07-12 11:50:43'),
(344, 1240, '2024-07-12 11:53:03'),
(345, 1240, '2024-07-12 11:53:19'),
(346, 1240, '2024-07-12 11:55:38'),
(347, 1240, '2024-07-12 12:07:19'),
(348, 1240, '2024-07-12 12:11:37'),
(349, 1240, '2024-07-24 10:41:53'),
(350, 1240, '2024-07-24 10:46:32'),
(351, 1240, '2024-07-24 10:47:06'),
(352, 1240, '2024-07-24 11:01:47'),
(353, 1240, '2024-07-24 15:39:40'),
(354, 1240, '2024-07-24 15:44:55'),
(355, 1240, '2024-07-24 15:49:03'),
(356, 1240, '2024-07-24 15:49:43'),
(357, 1240, '2024-07-24 16:20:05'),
(358, 1240, '2024-07-24 16:28:00'),
(359, 1240, '2024-07-26 16:46:48'),
(360, 1240, '2024-07-26 23:35:42'),
(361, 1240, '2024-07-26 23:35:50'),
(362, 1240, '2024-07-29 12:11:22'),
(363, 1240, '2024-07-29 12:12:28'),
(364, 1240, '2024-07-29 12:27:33'),
(365, 1240, '2024-07-29 12:56:14'),
(366, 1240, '2024-07-29 12:58:29'),
(367, 1240, '2024-08-05 21:12:38');

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `pending_request`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `pending_request` (
`ID` int
,`NAME` varchar(115)
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `position`
--

CREATE TABLE `position` (
  `ID` int NOT NULL,
  `NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `position`
--

INSERT INTO `position` (`ID`, `NAME`) VALUES
(1, 'Anlaşmalı Kurumlar Direktörü'),
(2, 'Bilgi Sistemleri Müdür Yardımcısı'),
(3, 'Bilgi Sistemleri Müdürü'),
(4, 'Bilgi Sistemleri Sorumlusu'),
(5, 'Bilgi Sistemleri Uzmanı'),
(6, 'Bilgi Sistemleri ve Dijital Dönüşüm Koordinatörü'),
(7, 'Biyomedikal Direktörü'),
(8, 'Biyomedikal Müdür Yardımcısı'),
(9, 'Biyomedikal Müdürü'),
(10, 'Biyomedikal Planlama Müdürü'),
(11, 'Biyomedikal Sorumlusu'),
(12, 'Biyomedikal Uzmanı'),
(13, 'Bölge Koordinatörü'),
(80, 'Deneme'),
(14, 'Dijital Dönüşüm Direktörü'),
(15, 'Elektrik Teknisyeni'),
(16, 'Genel Müdür'),
(17, 'Genel Müdür Yardımcısı'),
(18, 'Hasta Bakım Hizmetleri Direktörü'),
(19, 'Hazine ve Finans Direktörü'),
(20, 'Hekimlik Hizmetleri Direktörü'),
(21, 'Hukuk Müşaviri'),
(22, 'İç Denetim Direktörü'),
(23, 'İdari İşler Bütçe Sorumlusu'),
(24, 'İdari İşler Direktör Yardımcısı'),
(25, 'İdari İşler Direktörü'),
(26, 'İdari İşler Müdür Yardımcısı'),
(27, 'İnsan Kaynakları Direktörü'),
(28, 'İnsan Kaynakları Koordinatörü'),
(29, 'İş Analizi Müdür Yardımcısı'),
(30, 'İş Analizi Uzman Yardımcısı'),
(31, 'İş Analizi Uzmanı'),
(32, 'İş Sağlığı ve Güvenliği Uzmanı'),
(33, 'Kalite ve Risk Yönetimi Direktörü'),
(34, 'Kurumsal Faturalama Direktörü'),
(35, 'Kurumsal Operasyonlar Grup Koordinatörü'),
(36, 'Kurumsal Tanıtım ve Misafir Deneyimi Direktörü'),
(37, 'Laboratuvar Direktör Yardımcısı'),
(38, 'Mali İşler Koordinatörü'),
(39, 'Mali İşlerden Sorumlu Genel Müdür Yardımcısı'),
(40, 'Mali İşlerden Sorumlu Vekil Genel Müdür Yardımcısı'),
(41, 'Misafir Hizmetleri Direktörü'),
(42, 'Operasyon ve Destek Süreçleri Müdür Yardımcısı'),
(43, 'Operasyon ve Destek Süreçleri Müdürü'),
(44, 'Operasyon ve Destek Süreçleri Sorumlusu'),
(45, 'Otelcilik ve Destek Hizmetleri Müdür Yardımcısı'),
(46, 'Otelcilik ve Destek Hizmetleri Müdürü'),
(47, 'Otelcilik ve Destek Hizmetleri Sorumlusu'),
(48, 'Otelcilik ve Destek Hizmetleri Uzmanı'),
(49, 'Proje Yönetimi Direktör Yardımcısı'),
(50, 'Proje Yönetimi Sorumlusu'),
(51, 'Resmi İşlemler ve Ruhsatlandırma Direktörü'),
(52, 'Satınalma Müdür Yardımcısı'),
(53, 'Stajyer'),
(54, 'Strateji ve Performans Grup Koordinatörü'),
(55, 'Süreç Analiz Uzman Yardımcısı'),
(56, 'Süreç Analizi Direktörü'),
(85, 'Süreç Analizi Müdür Yardımcısı'),
(57, 'Süreç Analizi Müdürü'),
(58, 'Süreçlerden Sorumlu Genel Müdür Yardımcısı'),
(59, 'Süreçlerden Sorumlu Vekil Genel Müdür Yardımcısı'),
(60, 'Tedarik Zinciri Direktörü'),
(61, 'Tedarik Zinciri Non-Medikal Direktörü'),
(62, 'Tedarik Zinciri Non-Medikal Teknik Hizmet Sorumlusu'),
(63, 'Tedarik Zinciri Non-Medikal Uzmanı'),
(64, 'Teknik Hizmetler Direktörü'),
(65, 'Teknik Hizmetler Müdür Yardımcısı'),
(66, 'Teknik Hizmetler Müdürü'),
(67, 'Teknik Hizmetler Sorumlusu'),
(68, 'Uluslararası Hasta Merkezi Gider Yönetimi Müdürü'),
(69, 'Uluslararası Hasta Merkezi Operasyon Kontrol Direktör Yardımcısı'),
(70, 'Uluslararası Tanıtım ve İş Geliştirme Direktörü'),
(71, 'Uygulama Geliştirme Sorumlusu'),
(72, 'Vekil Genel Müdür'),
(81, 'Veri Analitiği Müdür Yardımcısı'),
(73, 'Veri Analitiği Uzmanı'),
(74, 'Veri Analiz Uzmanı'),
(75, 'Veri Analizi Müdürü'),
(76, 'Verimlilik ve İş Zekası Direktörü'),
(77, 'Yatırımcı İlişkileri ve Strateji Direktörü'),
(78, 'Yönetim Kurulu Başkanı'),
(79, 'Yurtdışı Operasyon Direktörü');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `reason`
--

CREATE TABLE `reason` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `reason`
--

INSERT INTO `reason` (`ID`, `NAME`) VALUES
(1, 'Açılış/Devir Süreci'),
(2, 'Denetim'),
(3, 'Eğitim'),
(4, 'İş Geliştirme'),
(5, 'Kongre/Konferans/Seminer'),
(6, 'OPD'),
(7, 'Oryantasyon Eğitimi'),
(8, 'Pazarlama Faaliyeti'),
(9, 'Saha Ziyareti '),
(10, 'Uluslararası İş Geliştirme'),
(11, 'Uluslararası Temsil Ağırlama'),
(12, 'Yerinde Hizmet');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `request`
--

CREATE TABLE `request` (
  `ID` int NOT NULL,
  `UUID` varchar(36) COLLATE utf8mb4_turkish_ci NOT NULL,
  `CREATION_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CREATOR_USER_ID` int NOT NULL,
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
  `TRANSFER_NEED_SITUATION` tinyint DEFAULT NULL,
  `TRANSFER_NEED_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `TRANSPORTATION_MODE_ID` int DEFAULT NULL,
  `TRANSPORTATION_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
  `ACCOMMODATION` tinyint(1) DEFAULT NULL,
  `CHECK-IN_DATE` date DEFAULT NULL,
  `CHECK-OUT_DATE` date DEFAULT NULL,
  `ACCOMMODATION_DETAIL` text CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `request`
--

INSERT INTO `request` (`ID`, `UUID`, `CREATION_TIME`, `CREATOR_USER_ID`, `ROUTE_ID`, `REASON_ID`, `FROM_COUNTRY_ID`, `FROM_LOCATION_ID`, `FROM_CITY_ID`, `FROM_CITY_NAME`, `TO_COUNTRY_ID`, `TO_LOCATION_ID`, `TO_CITY_ID`, `TO_CITY_NAME`, `TRANSPORTATION`, `DEPARTURE_DATE`, `RETURN_DATE`, `TRANSFER_NEED_SITUATION`, `TRANSFER_NEED_DETAIL`, `TRANSPORTATION_MODE_ID`, `TRANSPORTATION_DETAIL`, `ACCOMMODATION`, `CHECK-IN_DATE`, `CHECK-OUT_DATE`, `ACCOMMODATION_DETAIL`) VALUES
(37, '53d58532-15b8-1f7d-2943-32a156f96fd7', '2024-02-21 11:32:11', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(38, '3436d56e-27fe-31c9-1485-5d61aec35aaa', '2024-02-21 11:35:12', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(39, '275f00ae-2910-15a7-294e-60bd0a545b23', '2024-02-21 11:36:28', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(40, '4603e83b-1ea6-1567-3339-4c37dd45dd04', '2024-02-21 11:46:34', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(41, '52f38e3b-357c-1a6f-2672-367ef9c4a4ff', '2024-02-21 11:48:48', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(42, '37b31597-2aab-3455-16ef-62651fe44746', '2024-02-21 11:50:42', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(43, '3b72265e-2545-318d-16c5-6e3557975ab4', '2024-02-21 11:51:30', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(44, '28b95032-2ab6-2411-1d6d-2593fbb7d509', '2024-02-21 13:17:55', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(45, '371582ff-2f10-1010-1821-5dbbdba43e63', '2024-02-21 13:18:05', 1240, 2, 9, 2, NULL, NULL, 'MÜNİH', 93, NULL, NULL, 'LONDRA', 1, '2024-03-17', '2024-03-24', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-24', 'Konaklama Detayları'),
(46, '3fd76f82-347d-229e-10be-2eb4ec035e29', '2024-03-05 11:51:27', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-17', 2, NULL, 5, 'Detay', 1, '2024-03-15', NULL, NULL),
(47, '408c75ae-1b81-1f23-22c4-61d9f07d00f7', '2024-03-05 11:55:37', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, 2, NULL, 5, 'Detay', 1, '2024-03-15', NULL, NULL),
(48, '29cfceff-2a90-2435-1dda-27e8835c8fb0', '2024-03-05 13:18:02', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, NULL, NULL, 5, 'Detay', 0, NULL, NULL, NULL),
(49, '2d370f0d-248a-20ef-1d54-3381a6b0b0dd', '2024-03-05 13:18:13', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, NULL, NULL, 5, 'Detay', 0, NULL, NULL, NULL),
(50, '46d67965-2762-286e-2979-656d7dc22a94', '2024-03-05 13:21:57', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, 1, 'qwerty', 5, 'Detay', 0, NULL, NULL, NULL),
(51, '458838f0-209e-30a7-19a0-2b6415ae67a3', '2024-03-05 13:22:35', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, NULL, 'qwerty', 5, 'Detay', 0, NULL, NULL, NULL),
(52, '2dbd81a2-1d4d-1c3a-1b26-3a30da7a6bc7', '2024-03-05 13:25:31', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, '2024-03-15', NULL, NULL, 'qwerty', 5, 'Detay', 1, '2024-03-15', NULL, 'potry'),
(53, '31e84275-210a-129b-2b3c-7c66c9bd494d', '2024-03-05 13:26:04', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, NULL, 'qwerty', 5, 'Detay', 1, '2024-03-15', NULL, 'potry'),
(54, '52836284-169a-1fca-28fb-2f41e5be9084', '2024-03-05 13:26:29', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', NULL, NULL, 'qwerty', 5, 'Detay', 0, '2024-03-15', NULL, 'potry'),
(55, '363a6253-2553-3072-1482-638d17541bff', '2024-03-05 13:31:47', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-20', 2, 'qwerty', 5, 'Detay', 1, '2024-03-15', '2024-03-20', 'potry'),
(56, '35672930-1910-351d-2a1a-2ec1585e7fc4', '2024-03-05 13:38:46', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-20', 2, NULL, 5, 'Detay', 1, '2024-03-15', '2024-03-20', 'potry'),
(57, '4a874218-24c7-1a7a-102d-50a45b35102b', '2024-03-05 13:39:15', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-20', 1, 'qwerty', 5, 'Detay', 1, '2024-03-15', '2024-03-20', 'potry'),
(58, '3f6bd606-3604-238b-1112-2caa645db6df', '2024-03-05 13:47:54', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-20', 1, 'qwerty', 5, 'Detay', 1, '2024-03-15', '2024-03-20', 'potry'),
(59, '3fb802f3-1af0-2b98-1531-7eebcb8e4730', '2024-03-05 13:48:10', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-15', '2024-03-20', 1, 'qwerty', 5, 'Detay', 0, NULL, NULL, NULL),
(60, '26ec5dcc-2321-119a-2722-646e5129a4a7', '2024-03-05 13:48:15', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 1, NULL, 1, '2024-03-15', '2024-03-20', 'potry'),
(61, '21433144-2829-13b7-2656-5502f989c706', '2024-03-05 14:01:02', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-03-17', '2024-03-25', 1, 'Var', 5, 'Ulaşım Detayları', 1, '2024-03-17', '2024-03-25', 'Konaklama Detayları'),
(66, '4f58420f-28b7-1e27-1398-5762b2985a80', '2024-03-13 10:13:04', 1240, 1, 7, 220, NULL, 6, 'ANKARA', 220, NULL, 5, 'AMASYA', 1, '2024-03-21', '2024-03-28', 1, 'Araç', 3, 'Ulaşım Detayları', 1, '2024-03-21', '2024-04-28', 'Konaklama Detayları'),
(67, '5851f39d-1c69-24ee-2d74-3690464694c3', '2024-03-13 10:19:20', 1240, 1, 4, 220, NULL, 10, 'BALIKESİR', 220, NULL, 59, 'TEKİRDAĞ', 1, '2024-04-15', '2024-04-25', 1, 'Var', 2, 'Ulaşım Detayları', 1, '2024-04-15', '2024-04-25', 'Konaklama Detayları'),
(69, '368e0302-2b56-2782-23ad-413b1e767da4', '2024-03-13 15:53:29', 1240, 1, 9, 220, NULL, 7, 'ANTALYA', 220, NULL, 9, 'AYDIN', 1, '2024-04-25', NULL, 2, NULL, 3, NULL, 1, '2024-04-25', NULL, NULL),
(70, '259d9954-25b6-200e-1a67-7e158be11b40', '2024-03-28 15:07:35', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 1, NULL, 1, '2024-04-23', NULL, NULL),
(71, '36375abb-2aeb-1a22-3069-7d7ff4f7b4a5', '2024-03-28 15:08:01', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-04-23', NULL, NULL),
(72, '44d3cacb-2ec6-12e0-1e0a-79eadb1d5ad1', '2024-03-28 15:11:50', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-04-30', NULL, NULL),
(73, '2079ece3-326e-2769-1c65-69c21e95cd7a', '2024-03-28 15:16:38', 1240, 1, 8, 220, 6, 34, 'İSTANBUL', 220, 4, 55, 'SAMSUN', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-04-15', '2024-04-20', NULL),
(74, '2d4e6f2d-1212-2eaf-243c-7ea8cdf95844', '2024-03-28 15:22:31', 1240, 1, 4, 220, 1, 34, 'İSTANBUL', 220, 4, 55, 'SAMSUN', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-05-01', NULL, NULL),
(75, '27b23655-289f-156e-294d-61be4f8d3639', '2024-03-28 15:32:46', 1240, 1, 3, 220, 2, 6, 'ANKARA', 220, 16, 34, 'İSTANBUL', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-07-15', NULL, NULL),
(76, '20c25d43-1014-1d98-2b1c-485bea3a6ba7', '2024-03-28 15:47:22', 1240, 1, 12, 220, 13, 34, 'İSTANBUL', 220, 18, 52, 'ORDU', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-04-24', NULL, NULL),
(77, '4a82946d-150a-1d01-24f7-7b227b5b1cea', '2024-03-28 15:53:20', 1240, 1, 7, 220, 5, 34, 'İSTANBUL', 220, 24, 16, 'BURSA', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-05-10', NULL, NULL),
(78, '41a80b79-2957-289a-27dd-595e3f0df2f2', '2024-03-28 15:57:19', 1240, 1, 2, 220, 3, 27, 'GAZİANTEP', 220, 27, 33, 'MERSİN', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-05-11', NULL, NULL),
(79, '4af31733-31d3-163f-21bb-290e8f98cd4f', '2024-03-28 16:02:56', 1240, 1, 7, 220, 14, 17, 'ÇANAKKALE', 220, 25, 41, 'KOCAELİ', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-05-17', NULL, NULL),
(80, '585f22b4-1f5b-33ed-2170-52b2f82b0f0b', '2024-03-28 16:33:38', 1240, 1, 2, 220, 2, 6, 'ANKARA', 220, 28, 34, 'İSTANBUL', 0, NULL, NULL, NULL, NULL, 2, NULL, 1, '2024-06-12', NULL, NULL),
(81, '43ff6f0b-1ebc-1505-325f-480bcf7cc89c', '2024-03-28 16:37:32', 1240, 1, 9, 220, 19, 1, 'ADANA', 220, 20, 60, 'TOKAT', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-10', NULL, NULL),
(82, '2d125e36-2bfc-32e3-12ba-4bc0eb532343', '2024-03-28 16:39:28', 1240, 1, 12, 220, 9, 34, 'İSTANBUL', 220, 22, 34, 'İSTANBUL', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-06-02', NULL, NULL),
(83, '332aef0f-21f6-137f-2c18-7e3ff08dbbce', '2024-04-02 12:13:45', 1240, 1, 9, 220, 28, 34, 'İSTANBUL', 220, 3, 27, 'GAZİANTEP', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-15', NULL, NULL),
(84, '1f3761c7-163c-2e62-1f78-5ec285c0e691', '2024-04-02 13:39:34', 1240, 1, 9, 220, 10, 1, 'ADANA', 220, 20, 60, 'TOKAT', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-17', NULL, NULL),
(85, '206180d6-20ba-289c-307e-3aab917fb2bf', '2024-04-03 16:03:09', 1240, 1, 12, 220, 16, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-11', NULL, NULL),
(86, '2673f9f8-2a3d-3047-3651-3fa41d1a6f5d', '2024-04-03 16:10:38', 1240, 1, 9, 220, 9, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-12', NULL, NULL),
(87, '4151fa75-1344-19d0-205b-69d0a36979e7', '2024-04-03 16:15:11', 1240, 1, 9, 220, 9, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-12', NULL, NULL),
(88, '3e3afd7f-201e-2eb9-1645-77df7f2ff8c3', '2024-04-03 16:17:55', 1240, 1, 9, 220, 9, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-12', NULL, NULL),
(89, '55639f3c-3017-175f-25b6-3fa43723536d', '2024-04-03 16:18:19', 1240, 1, 9, 220, 9, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-04-12', NULL, NULL),
(90, '1fa360cd-325c-272f-1c01-681b7d799c2b', '2024-04-24 16:29:52', 1240, 2, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 0, NULL, NULL, NULL, NULL, 4, NULL, 1, '2024-05-01', NULL, NULL),
(95, '887c5bd0-6585-41c3-9d29-35c462073faf', '2024-04-25 11:34:47', 1240, 1, 7, 220, 11, 6, 'ANKARA', 220, 32, 34, 'İSTANBUL', 0, NULL, NULL, NULL, NULL, 5, NULL, 1, '2024-05-10', NULL, NULL),
(96, '4d84c935-c702-4e18-92ef-0fdc64596eb0', '2024-04-29 10:55:53', 1243, 1, 3, 220, 3, 27, 'GAZİANTEP', 220, 15, 41, 'KOCAELİ', 1, '2024-05-01', '2024-05-02', 2, NULL, 3, NULL, 1, '2024-04-30', '2024-05-10', NULL),
(97, '428f8813-6d2d-4a6f-a891-6a7477a8918f', '2024-04-30 17:47:04', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-05-17', '2024-05-25', 2, NULL, 3, NULL, 1, '2024-05-17', '2024-05-25', NULL),
(98, '417f41c0-eb79-4e56-9001-9e54573379f9', '2024-04-30 18:22:28', 1240, 2, 2, 220, NULL, 37, 'KASTAMONU', 2, NULL, 34, 'LONDRA', 1, '2024-05-02', '2024-05-03', 2, NULL, 3, NULL, 0, NULL, NULL, NULL),
(99, '099d147c-e7fc-4b42-aacd-ef5b960c4663', '2024-05-02 01:28:41', 1240, 2, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-05-17', '2024-05-25', 1, 'Var', 3, 'Ulaşım Detayları', 1, '2024-05-17', '2024-05-25', 'Konaklama Detayları'),
(101, 'e251d1c8-2ecd-4d98-8cf2-c2abb01f4ae2', '2024-05-02 12:00:55', 1240, 1, 2, 220, 6, 34, 'İSTANBUL', 220, 13, 34, 'İSTANBUL', 1, '2024-05-03', NULL, 1, 'birşeyler', 3, NULL, 1, '2024-05-03', NULL, 'Konaklama detay'),
(102, 'f4893cc7-7ed0-49ce-89e8-d1522b6b63eb', '2024-05-02 12:08:15', 1240, 1, 4, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-05-17', '2024-05-25', 2, NULL, 2, NULL, 1, '2024-05-17', '2024-05-25', NULL),
(103, '9b20e9a1-d7ba-461c-b307-6b37f20837d6', '2024-05-29 11:55:32', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-05-30', '2024-06-07', 2, NULL, 3, 'Aceleye geldi', 1, '2024-05-30', '2024-06-07', NULL),
(104, '3aecc5a0-2bdb-488d-8aeb-1dfd0df9155b', '2024-05-29 12:00:11', 1240, 1, 9, 220, NULL, 3, 'AFYONKARAHİSAR', 220, NULL, 11, 'BİLECİK', 1, '2024-07-17', '2024-07-25', 2, NULL, 4, NULL, 1, '2024-07-17', '2024-07-25', NULL),
(105, 'bbfbff20-f5d3-4942-b72f-beff1105cfcc', '2024-05-29 12:03:50', 1240, 1, 12, 220, NULL, 41, 'KOCAELİ', 220, NULL, 59, 'TEKİRDAĞ', 1, '2024-08-10', '2024-08-20', 2, NULL, 1, NULL, 1, '2024-08-10', '2024-08-20', NULL),
(106, 'cb8a781d-29a0-436d-a8ab-5968f0c4b156', '2024-05-30 16:00:35', 1240, 1, 9, 220, 2, 6, 'ANKARA', 220, 4, 55, 'SAMSUN', 1, '2024-06-17', '2024-06-22', 2, NULL, 2, NULL, 1, '2024-06-17', '2024-06-22', NULL),
(107, 'fc40d734-43b1-48e7-8c78-b81e7efca9a4', '2024-05-31 11:03:59', 1240, 1, 9, 220, 1, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-06-15', '2024-06-20', 2, NULL, 2, NULL, 1, '2024-06-15', '2024-06-20', NULL),
(108, '3228472a-5251-4951-8b9d-10f681120e28', '2024-06-05 14:05:37', 1240, 1, 7, 220, 1, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-06-17', '2024-06-28', 2, NULL, 2, NULL, 1, '2024-06-17', '2024-06-28', NULL),
(109, '3ac913a9-3673-48eb-b6ff-0bb47ef06206', '2024-06-05 14:07:53', 1240, 1, 9, 220, 13, 34, 'İSTANBUL', 220, 29, 55, 'SAMSUN', 1, '2024-06-22', '2024-06-30', 2, NULL, 3, NULL, 1, '2024-06-22', '2024-06-30', NULL),
(110, '53f92b36-805b-48de-96b6-b46e1c27c475', '2024-06-05 14:11:49', 1240, 1, 8, 220, 1, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-07-17', '2024-07-27', 2, NULL, 4, NULL, 1, '2024-07-17', '2024-07-27', NULL),
(111, '7732d067-9d26-490a-a151-2e40e2f706bd', '2024-06-05 14:46:33', 1240, 1, 4, 220, 9, 34, 'İSTANBUL', 220, 30, 34, 'İSTANBUL', 1, '2024-06-14', '2024-06-17', 2, NULL, 5, NULL, 1, '2024-06-14', '2024-06-17', NULL),
(112, '4eb38db1-ce8d-484d-ac4a-d1c4e2c8b902', '2024-06-05 15:00:14', 1240, 1, 9, 220, NULL, 10, 'BALIKESİR', 220, NULL, 59, 'TEKİRDAĞ', 1, '2024-06-11', '2024-06-15', 2, NULL, 4, NULL, 0, NULL, NULL, NULL),
(113, '0545d25f-f7b2-4033-92e5-7e1fcfc2a7d7', '2024-06-13 11:58:07', 1240, 1, 9, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-06-18', '2024-06-25', 2, NULL, 3, NULL, 1, '2024-06-18', '2024-06-25', NULL),
(114, '6b4a1f6e-1c37-4a2e-b1af-6b4fd55fc0f2', '2024-06-14 15:35:51', 1240, 1, 9, 220, 9, 34, 'İSTANBUL', 220, 22, 34, 'İSTANBUL', 1, '2024-06-18', '2024-06-22', 2, NULL, 3, NULL, 1, '2024-06-18', '2024-06-22', NULL),
(117, 'f9d01782-234f-434d-9e78-2b5d7dae94ab', '2024-06-14 15:40:01', 1240, 1, 7, 220, 4, 55, 'SAMSUN', 220, 14, 17, 'ÇANAKKALE', 1, '2024-06-25', '2024-06-30', 2, NULL, 4, NULL, 1, '2024-06-25', '2024-06-30', NULL),
(118, '11365585-a458-4d44-aaf2-506e98610c38', '2024-06-14 15:49:58', 1240, 2, 8, 239, NULL, NULL, 'HARARE', 203, NULL, NULL, 'HARTUM', 1, '2024-07-01', '2024-08-01', 1, 'Araç lazım', 3, 'Transit', 1, '2024-07-01', '2024-08-01', '5 Yıldız'),
(119, '6018e481-baab-4047-ab5f-f601b9d2b0ba', '2024-06-14 16:28:02', 1240, 1, 5, 220, 2, 6, 'ANKARA', 220, 5, 34, 'İSTANBUL', 1, '2024-07-02', '2024-07-14', 2, NULL, 3, NULL, 1, '2024-07-02', '2024-07-14', NULL),
(120, 'd6db37a2-dbca-4db6-a797-87fcb275d812', '2024-07-02 12:39:07', 1240, 1, 3, 220, 5, 34, 'İSTANBUL', 220, 4, 55, 'SAMSUN', 1, '2024-07-15', '2024-07-25', 2, NULL, 3, NULL, 0, NULL, NULL, NULL),
(121, 'b8b5f2a4-c77e-4155-b5b1-26909c33cb6a', '2024-07-03 12:01:56', 1240, 1, 9, 220, 1, 34, 'İSTANBUL', 220, 4, 55, 'SAMSUN', 1, '2024-07-07', '2024-07-17', 2, NULL, 4, NULL, 1, '2024-07-07', '2024-07-17', NULL),
(122, '4621f11f-0e36-48e3-bba8-735d8fe99dea', '2024-07-03 12:10:18', 1240, 1, 4, 220, 24, 16, 'BURSA', 220, 18, 52, 'ORDU', 1, '2024-07-14', '2024-07-20', 2, NULL, 2, NULL, 1, '2024-07-14', '2024-07-20', NULL),
(123, 'd6ef099e-6a17-4adb-a1cb-c1f2c8e2943b', '2024-07-03 14:10:23', 1240, 1, 3, 220, 32, 34, 'İSTANBUL', 220, 18, 52, 'ORDU', 1, '2024-07-05', '2024-07-25', 2, NULL, 2, 'Çok acil eğitim ihtiyacı oluştu', 1, '2024-07-05', '2024-07-25', NULL),
(124, 'd26388d8-b95e-420f-b59a-3ac72e3d3224', '2024-07-03 15:19:06', 1241, 2, 3, 220, 16, 34, 'İSTANBUL', 12, NULL, 34, 'AA', 1, '2024-07-04', '2024-08-10', 2, NULL, 3, 'DETAY', 0, NULL, NULL, NULL),
(125, '27913b32-4dc2-416e-8254-3fe860597f15', '2024-07-03 15:39:38', 1241, 1, 3, 220, 1, 34, 'İSTANBUL', 220, 20, 60, 'TOKAT', 1, '2024-07-04', '2024-08-02', 2, NULL, 3, 'cam kenqrı olsun.', 0, NULL, NULL, NULL),
(146, 'fd55bcae-d829-4968-a455-5eb291d76113', '2024-07-08 10:15:34', 1240, 1, 12, 220, 4, 55, 'SAMSUN', 220, 14, 17, 'ÇANAKKALE', 1, '2024-08-17', '2024-08-25', 2, NULL, 2, NULL, 1, '2024-08-17', '2024-08-25', NULL),
(147, '30cfc931-785b-42c3-aaaf-3fe5ebe2084d', '2024-07-08 15:39:30', 1240, 1, 5, 220, 3, 27, 'GAZİANTEP', 220, 12, 7, 'ANTALYA', 1, '2024-07-17', '2024-07-22', 2, NULL, 4, NULL, 1, '2024-07-17', '2024-07-22', NULL),
(148, '21bd553d-4af3-4b72-9d45-354e7a108191', '2024-07-09 13:22:40', 1240, 1, 9, 220, 6, 34, 'İSTANBUL', 220, 16, 34, 'İSTANBUL', 1, '2024-12-19', '2024-12-25', 2, NULL, 3, NULL, 1, '2024-12-19', '2024-12-25', NULL),
(149, '48c79571-e650-4002-8bc2-ede772d93e36', '2024-07-27 02:27:45', 1240, 1, 9, 220, 13, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-08-17', '2024-08-26', 2, NULL, 3, NULL, 1, '2024-08-17', '2024-08-26', NULL),
(150, 'cc5f7054-99a2-4e52-968c-cc2ab021d0ee', '2024-07-27 02:37:01', 1240, 1, 12, 220, 1, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-08-11', '2024-08-14', 2, NULL, 5, NULL, 1, '2024-08-11', '2024-08-14', NULL),
(151, '686778ca-d07a-4a78-a910-e53156c1eea3', '2024-07-27 02:40:58', 1240, 1, 7, 220, 2, 6, 'ANKARA', 220, 16, 34, 'İSTANBUL', 1, '2024-08-07', '2024-08-16', 2, NULL, 4, NULL, 1, '2024-08-07', '2024-08-16', NULL),
(152, '6df190d6-4bae-4b11-b104-3a8b6bb68a8e', '2024-07-27 02:48:04', 1240, 1, 8, 220, 6, 34, 'İSTANBUL', 220, 19, 1, 'ADANA', 1, '2024-08-12', '2024-08-15', 2, NULL, 3, NULL, 1, '2024-08-12', '2024-08-15', NULL),
(153, '2cf00166-3c52-4127-9bf6-436ea3743bd1', '2024-07-27 02:51:35', 1240, 1, 3, 220, 3, 27, 'GAZİANTEP', 220, 4, 55, 'SAMSUN', 1, '2024-08-21', '2024-08-27', 2, NULL, 3, NULL, 1, '2024-08-21', '2024-08-27', NULL),
(154, '05414ad9-9b11-4a68-8e30-2d965f06cbb3', '2024-07-27 02:58:46', 1240, 1, 2, 220, 5, 34, 'İSTANBUL', 220, 20, 60, 'TOKAT', 1, '2024-08-13', '2024-08-18', 2, NULL, 4, NULL, 1, '2024-08-13', '2024-08-18', NULL),
(155, '8015afd2-0195-48f9-a4bd-c51dec5c01e2', '2024-07-27 03:04:12', 1240, 1, 4, 220, 12, 7, 'ANTALYA', 220, 4, 55, 'SAMSUN', 1, '2024-08-14', '2024-08-20', 2, NULL, 3, NULL, 1, '2024-08-14', '2024-08-20', NULL),
(156, 'aeeca392-5c84-4c8f-9e83-b7d311a796e9', '2024-07-27 03:06:08', 1240, 1, 8, 220, 24, 16, 'BURSA', 220, 25, 41, 'KOCAELİ', 1, '2024-07-30', '2024-08-02', 2, NULL, 5, 'Plansız gelişme oldu', 1, '2024-07-30', '2024-08-02', NULL),
(157, '6bcbae63-f45c-4234-bc2e-66b3a8b3d42d', '2024-07-27 03:08:29', 1240, 1, 5, 220, 28, 34, 'İSTANBUL', 220, 24, 16, 'BURSA', 1, '2024-08-05', '2024-08-11', 2, NULL, 4, NULL, 1, '2024-08-05', '2024-08-11', NULL),
(158, '2e2268fc-d61f-4f42-81e7-69a0534e35ad', '2024-07-27 23:47:06', 1240, 1, 3, 220, 30, 34, 'İSTANBUL', 220, 24, 16, 'BURSA', 1, '2024-08-08', '2024-08-12', 2, NULL, 3, NULL, 1, '2024-08-08', '2024-08-12', NULL),
(159, '14dc5d34-5a13-4319-a335-a84f9924cf58', '2024-07-28 00:05:04', 1240, 1, 9, 220, 4, 55, 'SAMSUN', 220, 2, 6, 'ANKARA', 1, '2024-08-10', '2024-08-14', 2, NULL, 3, NULL, 1, '2024-08-10', '2024-08-14', NULL),
(160, '631fb5df-3be1-4024-9a32-d70f15de10cb', '2024-07-28 00:17:21', 1240, 1, 2, 220, 6, 34, 'İSTANBUL', 220, 27, 33, 'MERSİN', 1, '2024-08-15', '2024-08-20', 2, NULL, 3, NULL, 1, '2024-08-15', '2024-08-20', NULL),
(161, '3b71c8c5-281b-46a8-9e7f-996f92e4de67', '2024-07-28 00:26:16', 1240, 1, 4, 220, 14, 17, 'ÇANAKKALE', 220, 24, 16, 'BURSA', 1, '2024-08-17', '2024-08-21', 2, NULL, 5, NULL, 1, '2024-08-17', '2024-08-21', NULL),
(162, '07656556-ddfe-452a-aa02-f561524870ea', '2024-07-28 00:41:02', 1240, 1, 4, 220, 1, 34, 'İSTANBUL', 220, 6, 34, 'İSTANBUL', 1, '2024-08-09', '2024-08-11', 2, NULL, 5, NULL, 1, '2024-08-09', '2024-08-11', NULL),
(163, 'e5d57489-4625-4ae3-9ec2-89d1cee8b800', '2024-07-28 01:45:04', 1240, 1, 7, 220, 11, 6, 'ANKARA', 220, 16, 34, 'İSTANBUL', 1, '2024-08-22', '2024-08-27', 2, NULL, 3, NULL, 1, '2024-08-22', '2024-08-27', NULL),
(164, '6f64375a-36c9-4639-8ced-c177755135f4', '2024-07-29 12:09:10', 1240, 1, 5, 220, 16, 34, 'İSTANBUL', 220, 12, 7, 'ANTALYA', 1, '2024-08-11', '2024-08-14', 2, NULL, 3, NULL, 1, '2024-08-11', '2024-08-14', NULL),
(165, '9c0eb806-4248-41b4-a12a-da511331534c', '2024-07-29 12:20:13', 1240, 1, 4, 220, 3, 27, 'GAZİANTEP', 220, 4, 55, 'SAMSUN', 1, '2024-08-12', '2024-08-18', 2, NULL, 3, NULL, 1, '2024-08-12', '2024-08-18', NULL),
(166, 'd861bc3f-0209-42ea-998f-18844d76f15b', '2024-07-29 12:33:01', 1240, 1, 5, 220, 25, 41, 'KOCAELİ', 220, 24, 16, 'BURSA', 1, '2024-08-16', '2024-08-20', 2, NULL, 5, NULL, 1, '2024-08-16', '2024-08-20', NULL),
(167, 'd4c47d09-15c1-45cb-af6d-2e22f8d555ea', '2024-07-29 12:39:25', 1240, 1, 7, 220, 1, 34, 'İSTANBUL', 220, 18, 52, 'ORDU', 1, '2024-08-14', '2024-08-22', 2, NULL, 2, NULL, 1, '2024-08-14', '2024-08-22', NULL),
(168, '537a2581-fb76-4d2a-ad74-bfce9c2ca7d1', '2024-07-29 12:43:56', 1240, 1, 3, 220, 5, 34, 'İSTANBUL', 220, 3, 27, 'GAZİANTEP', 1, '2024-08-21', '2024-08-28', 2, NULL, 3, NULL, 1, '2024-08-21', '2024-08-28', NULL),
(169, '76b5c0fb-f964-4867-a534-562e7b447493', '2024-07-29 12:47:05', 1240, 1, 7, 220, 32, 34, 'İSTANBUL', 220, 14, 17, 'ÇANAKKALE', 1, '2024-08-17', '2024-08-24', 2, NULL, 2, NULL, 1, '2024-08-17', '2024-08-24', NULL),
(170, '27a941df-9f8c-4d78-b659-81a38e902feb', '2024-07-29 12:53:01', 1240, 1, 12, 220, 32, 34, 'İSTANBUL', 220, 29, 55, 'SAMSUN', 1, '2024-08-16', '2024-08-23', 2, NULL, 3, NULL, 1, '2024-08-16', '2024-08-23', NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `request_approver_detail`
--

CREATE TABLE `request_approver_detail` (
  `ID` int NOT NULL,
  `UUID` varchar(36) COLLATE utf8mb4_turkish_ci NOT NULL,
  `CREATION_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CREATOR_USER_ID` int NOT NULL,
  `REQUEST_ID` int NOT NULL,
  `ACTIVE` tinyint(1) NOT NULL DEFAULT '1',
  `AUTHORIZED_PERSON_ID` int NOT NULL,
  `MODIFIED_TIME` datetime DEFAULT NULL,
  `MODIFIED_USER_ID` int DEFAULT NULL,
  `STATUS_ID` int NOT NULL DEFAULT '11',
  `EXPLANATION` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `request_approver_detail`
--

INSERT INTO `request_approver_detail` (`ID`, `UUID`, `CREATION_TIME`, `CREATOR_USER_ID`, `REQUEST_ID`, `ACTIVE`, `AUTHORIZED_PERSON_ID`, `MODIFIED_TIME`, `MODIFIED_USER_ID`, `STATUS_ID`, `EXPLANATION`) VALUES
(1, '168a45a0-2cc8-48df-9c6e-d9989abd8550', '2024-04-24 16:29:52', 1240, 90, 1, 1240, NULL, NULL, 11, NULL),
(2, 'b078061e-af32-4d8e-b7cd-9fd14f2483d1', '2024-04-25 11:34:47', 1240, 95, 1, 1240, NULL, NULL, 11, NULL),
(3, '983583b1-1b99-4c3f-9bab-394f0ab48ab2', '2024-04-29 10:55:53', 1240, 96, 1, 1243, NULL, NULL, 11, NULL),
(8, 'cc389060-8c74-4be4-af56-32c9372987ae', '2024-04-29 16:58:37', 1240, 95, 1, 1240, NULL, NULL, 11, NULL),
(9, '12acc490-9d03-44cd-90b9-8cada04e10e3', '2024-04-30 17:47:04', 1240, 97, 1, 1240, '2024-07-12 12:03:20', NULL, 14, NULL),
(10, 'a8f0e64f-ecca-4aec-b305-ffb52104ddea', '2024-04-30 18:22:28', 1240, 98, 1, 1240, NULL, NULL, 11, NULL),
(11, '18819fda-d4a4-431a-9f0d-782e2151cc27', '2024-05-02 01:28:41', 1240, 99, 1, 1240, NULL, NULL, 11, NULL),
(12, '351ed574-e1d7-4608-ba51-d89bdd7d39f8', '2024-05-02 12:00:55', 1240, 101, 1, 1240, NULL, NULL, 11, NULL),
(13, '5e35843e-9e62-4265-9826-308f7115ec59', '2024-05-02 12:08:15', 1240, 102, 1, 1240, NULL, NULL, 11, NULL),
(14, '2508e0c8-afe6-4d22-8d18-268b0c3e3441', '2024-05-29 11:55:32', 1240, 103, 1, 1241, NULL, NULL, 11, NULL),
(15, 'dd15c3af-cc99-4059-a702-b0ee5f923a1a', '2024-05-29 12:00:11', 1240, 104, 1, 1241, NULL, NULL, 11, NULL),
(16, 'b1c1a152-a7cb-4b36-9b48-964c747483ce', '2024-05-29 12:03:50', 1240, 105, 1, 1241, NULL, NULL, 11, NULL),
(17, '9182e52c-e0ab-42c8-897f-ad0280d8d5f9', '2024-05-30 16:00:35', 1240, 106, 1, 1241, NULL, NULL, 11, NULL),
(18, 'e8dde792-6711-4db7-b184-647ca3a5c409', '2024-05-31 11:03:59', 1240, 107, 1, 1240, '2024-07-12 12:03:20', NULL, 14, NULL),
(19, 'f0bdc56f-4b09-44fe-8b37-e64781aaa0b3', '2024-06-05 14:05:37', 1240, 108, 1, 1240, NULL, NULL, 11, NULL),
(20, '82a51f15-1af2-439b-83e2-8dd1c4da656c', '2024-06-05 14:07:53', 1240, 109, 1, 1240, NULL, NULL, 11, NULL),
(21, 'ea2beae4-1cd1-4dd3-aea0-6eeab8098bf5', '2024-06-05 14:11:49', 1240, 110, 1, 1240, NULL, NULL, 11, NULL),
(22, '7f0de049-96ef-4491-bc78-84221cdb716f', '2024-06-05 14:46:33', 1240, 111, 1, 1240, NULL, NULL, 11, NULL),
(23, '302b44ed-3e6f-4685-ace5-d4171b73817b', '2024-06-05 15:00:14', 1240, 112, 1, 1240, NULL, NULL, 11, NULL),
(24, 'fa597bc4-7b68-46af-b556-73083c096eb0', '2024-06-05 15:28:49', 1240, 112, 0, 1240, NULL, NULL, 12, NULL),
(25, 'ec6dd980-9299-4868-bce0-309a1b339d03', '2024-06-13 11:58:07', 1240, 113, 1, 1240, NULL, NULL, 11, NULL),
(26, 'afe6d50a-517d-497d-93de-d6ed5464a6e2', '2024-06-14 15:35:51', 1240, 114, 1, 1240, NULL, NULL, 11, NULL),
(27, '2eedc0a4-92ab-429b-bf42-5ffa92d05204', '2024-06-14 15:40:01', 1240, 117, 1, 1240, NULL, NULL, 11, NULL),
(28, '3bfc1713-6660-40aa-898d-07375e84c190', '2024-06-14 15:49:58', 1240, 118, 1, 1240, NULL, NULL, 11, NULL),
(29, 'cf632bac-cbec-4a9b-99d5-1229a23084f1', '2024-06-14 16:28:02', 1240, 119, 1, 1240, NULL, NULL, 11, NULL),
(30, 'eec890df-3906-487d-87f8-e2cfefe0cf5b', '2024-07-02 12:39:07', 1240, 120, 1, 1240, '2024-07-12 12:03:20', 1240, 14, NULL),
(32, '82c53c0b-9cd8-4678-9430-56d37a6738dd', '2024-07-03 12:01:56', 1240, 121, 1, 1240, '2024-07-24 15:49:43', 1240, 17, 'canım öyle istiyor'),
(33, '940b881c-75c7-4aab-b1eb-3ee5dcc8fa27', '2024-07-03 12:10:18', 1240, 122, 1, 1240, NULL, 1240, 11, NULL),
(34, '7d0ae714-2aab-4cf5-b61f-2416c98b1655', '2024-07-03 14:10:23', 1240, 123, 1, 1240, '2024-07-24 15:39:40', 1240, 11, ''),
(35, '81c758b7-1b6b-4fff-808e-45005b63df1f', '2024-07-03 15:19:06', 1241, 124, 1, 1244, '2024-07-24 10:46:32', 1240, 11, ''),
(36, '295b8465-8506-4691-be1d-de4211f93538', '2024-07-03 15:39:38', 1241, 125, 0, 1240, '2024-07-03 15:46:24', 1240, 11, NULL),
(37, '2b302db7-8f33-40a4-b834-fe84060f43dd', '2024-07-03 15:46:24', 1240, 125, 1, 1240, '2024-07-24 10:41:53', 1240, 11, ''),
(41, '3f3fedf7-c8fe-43c3-95e5-dfaf91377c36', '2024-07-08 10:15:34', 1240, 146, 1, 1244, NULL, 1240, 11, NULL),
(43, 'e392905f-9318-44e2-962b-a2b35c604bc9', '2024-07-08 15:39:30', 1240, 147, 1, 1244, NULL, 1240, 11, NULL),
(44, '203950c1-3b16-4375-9791-421395320765', '2024-07-09 13:22:40', 1240, 148, 1, 1244, '2024-07-12 12:03:20', 1240, 14, NULL),
(45, 'e6255f03-fd78-416f-bdc8-985f561307d1', '2024-07-27 02:27:45', 1240, 149, 1, 1244, NULL, NULL, 11, NULL),
(46, '7d409040-a6c9-4530-8f94-f43733a4fdb3', '2024-07-27 02:37:01', 1240, 150, 1, 1244, NULL, NULL, 11, NULL),
(47, '2cc3ffaa-9cc4-4877-9606-0cb8ab18616c', '2024-07-27 02:40:59', 1240, 151, 1, 1244, NULL, NULL, 11, NULL),
(48, '862d3f42-f207-4c79-aef0-82bd60fc0ae4', '2024-07-27 02:48:04', 1240, 152, 1, 1244, NULL, NULL, 11, NULL),
(49, 'ca724be4-7d94-47c5-abee-9b787d8803d7', '2024-07-27 02:51:35', 1240, 153, 1, 1244, NULL, NULL, 11, NULL),
(50, '365d6400-9cc2-44cd-9252-1d4194f7bff5', '2024-07-27 02:58:46', 1240, 154, 1, 1244, NULL, NULL, 11, NULL),
(51, 'e77f6416-9b87-4b50-ab51-e8da562dc991', '2024-07-27 03:04:12', 1240, 155, 1, 1244, NULL, NULL, 11, NULL),
(52, '1f5b29db-651e-481d-a9c6-11023754b3ac', '2024-07-27 03:06:08', 1240, 156, 1, 1244, NULL, NULL, 11, NULL),
(53, '039ecca5-67fe-4d4a-a35a-80de034868df', '2024-07-27 03:08:29', 1240, 157, 1, 1244, NULL, NULL, 11, NULL),
(54, '60786aff-554d-49f1-98a7-d3a1f1c3536a', '2024-07-27 23:47:06', 1240, 158, 1, 1244, NULL, NULL, 11, NULL),
(55, '3e24ad4e-d5c0-4230-ba2f-66e763bb2f1f', '2024-07-28 00:05:04', 1240, 159, 1, 1244, NULL, NULL, 11, NULL),
(56, '04fc1e22-bba6-4343-b670-5fadd004b748', '2024-07-28 00:17:22', 1240, 160, 1, 1244, NULL, NULL, 11, NULL),
(57, '1b06196b-037a-4c7d-be27-1583d38f9062', '2024-07-28 00:26:16', 1240, 161, 1, 1244, NULL, NULL, 11, NULL),
(58, '24a79325-cc6b-4577-b017-504911187d27', '2024-07-28 00:41:02', 1240, 162, 1, 1244, NULL, NULL, 11, NULL),
(59, '8109b529-83d1-4bab-9e14-27ab99ecd585', '2024-07-28 01:45:04', 1240, 163, 1, 1244, NULL, NULL, 11, NULL),
(60, 'd5f57876-38af-435f-8c58-749214e33e7a', '2024-07-29 12:09:10', 1240, 164, 1, 1244, '2024-07-29 12:12:28', 1240, 16, 'qwerty'),
(61, 'be0a0511-1fe5-49f7-981b-fd7235b94b9e', '2024-07-29 12:20:13', 1240, 165, 1, 1244, '2024-07-29 15:08:54', 1240, 14, 'NULL'),
(62, '70d9019a-d974-4f67-9977-af2b2e654c89', '2024-07-29 12:33:01', 1240, 166, 1, 1244, NULL, NULL, 11, NULL),
(63, 'edaa449c-f82e-4ab1-9bd6-a64aadd28ee5', '2024-07-29 12:39:25', 1240, 167, 1, 1244, NULL, NULL, 11, NULL),
(64, '86938bcd-e36d-44ca-b184-d3105cec779a', '2024-07-29 12:43:56', 1240, 168, 1, 1244, NULL, NULL, 11, NULL),
(65, 'acefb5d1-85a3-4dba-9edc-d73e5a689113', '2024-07-29 12:47:05', 1240, 169, 1, 1244, NULL, NULL, 11, NULL),
(66, '00b25a64-3d56-4404-8279-cc6707083fa9', '2024-07-29 12:53:01', 1240, 170, 1, 1244, '2024-07-29 15:06:41', 1240, 14, 'NULL');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `request_detail`
--

CREATE TABLE `request_detail` (
  `ID` int NOT NULL,
  `REQUEST_ID` int NOT NULL,
  `TRAVELER_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `request_detail`
--

INSERT INTO `request_detail` (`ID`, `REQUEST_ID`, `TRAVELER_ID`) VALUES
(4, 37, 3),
(5, 40, 3),
(6, 40, 6),
(7, 40, 7),
(8, 40, 8),
(9, 41, 3),
(10, 41, 6),
(11, 41, 7),
(12, 41, 8),
(13, 42, 3),
(14, 42, 6),
(15, 42, 7),
(16, 42, 8),
(17, 43, 3),
(18, 43, 6),
(19, 43, 7),
(20, 43, 8),
(21, 44, 3),
(22, 44, 6),
(23, 44, 7),
(24, 44, 8),
(25, 45, 3),
(26, 45, 6),
(27, 45, 7),
(28, 45, 8),
(29, 46, 7),
(30, 46, 3),
(31, 47, 7),
(32, 47, 3),
(33, 48, 7),
(34, 48, 3),
(35, 49, 7),
(36, 49, 3),
(37, 50, 7),
(38, 50, 3),
(39, 51, 7),
(40, 51, 3),
(41, 52, 7),
(42, 52, 3),
(43, 53, 7),
(44, 53, 3),
(45, 54, 7),
(46, 54, 3),
(47, 55, 7),
(48, 55, 3),
(49, 56, 7),
(50, 56, 3),
(51, 57, 7),
(52, 57, 3),
(53, 58, 7),
(54, 58, 3),
(55, 59, 7),
(56, 59, 3),
(57, 60, 7),
(58, 60, 3),
(59, 61, 3),
(60, 66, 3),
(61, 67, 3),
(63, 69, 3),
(64, 70, 3),
(65, 71, 3),
(66, 72, 3),
(67, 73, 3),
(68, 73, 6),
(69, 74, 3),
(70, 75, 3),
(71, 76, 3),
(72, 77, 3),
(73, 78, 3),
(74, 79, 3),
(75, 80, 3),
(76, 81, 3),
(77, 82, 3),
(78, 83, 3),
(79, 84, 3),
(80, 85, 3),
(81, 86, 3),
(82, 87, 3),
(83, 88, 3),
(84, 89, 3),
(85, 90, 3),
(88, 95, 3),
(89, 95, 6),
(90, 96, 10),
(91, 97, 6),
(92, 97, 3),
(93, 98, 3),
(94, 99, 3),
(95, 101, 3),
(96, 101, 6),
(97, 102, 3),
(98, 103, 3),
(99, 104, 3),
(100, 105, 3),
(101, 106, 3),
(102, 107, 3),
(103, 108, 3),
(104, 109, 3),
(105, 110, 3),
(106, 111, 3),
(107, 112, 3),
(108, 113, 3),
(109, 114, 3),
(110, 117, 3),
(111, 118, 3),
(112, 118, 6),
(113, 119, 3),
(114, 120, 3),
(115, 120, 6),
(116, 120, 7),
(117, 121, 3),
(118, 121, 6),
(119, 122, 6),
(120, 122, 3),
(121, 123, 3),
(122, 123, 7),
(123, 124, 7),
(124, 125, 7),
(135, 146, 3),
(136, 147, 3),
(137, 148, 3),
(138, 148, 6),
(139, 149, 3),
(140, 150, 3),
(141, 151, 3),
(142, 152, 3),
(143, 153, 3),
(144, 154, 3),
(145, 155, 3),
(146, 156, 3),
(147, 157, 3),
(148, 158, 3),
(149, 159, 3),
(150, 160, 3),
(151, 161, 3),
(152, 162, 3),
(153, 163, 3),
(154, 164, 3),
(155, 165, 3),
(156, 166, 3),
(157, 167, 3),
(158, 168, 3),
(159, 168, 6),
(160, 169, 3),
(161, 169, 7),
(162, 170, 6),
(163, 170, 7);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `reservation`
--

CREATE TABLE `reservation` (
  `ID` int NOT NULL,
  `UUID` varchar(36) COLLATE utf8mb4_turkish_ci NOT NULL,
  `CREATION_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CREATOR_USER_ID` int NOT NULL,
  `REQUEST_ID` int NOT NULL,
  `DEPARTURE_TRANSPORTATION_MODE_ID` int DEFAULT NULL,
  `DEPARTURE_PORT` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `DEPARTURE_DATE` datetime DEFAULT NULL,
  `DEPARTURE_COMPANY` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `DEPARTURE_PNR_CODE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `DEPARTURE_TICKET_NUMBER` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `DEPARTURE_TICKET_PRICE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `DEPARTURE_CAR_LICENSE_PLATE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_TRANSPORTATION_MODE_ID` int DEFAULT NULL,
  `RETURN_PORT` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_DATE` datetime DEFAULT NULL,
  `RETURN_COMPANY` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_PNR_CODE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_TICKET_NUMBER` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_TICKET_PRICE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `RETURN_CAR_LICENSE_PLATE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `CHECK-IN_DATE` datetime DEFAULT NULL,
  `CHECK-OUT_DATE` datetime DEFAULT NULL,
  `HOTEL_NAME` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `STATUS_ID` int NOT NULL DEFAULT '21',
  `MODIFIED_TIME` datetime DEFAULT NULL,
  `MODIFIED_USER_ID` int DEFAULT NULL,
  `EXPLANATION` varchar(1000) COLLATE utf8mb4_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `reservation`
--

INSERT INTO `reservation` (`ID`, `UUID`, `CREATION_TIME`, `CREATOR_USER_ID`, `REQUEST_ID`, `DEPARTURE_TRANSPORTATION_MODE_ID`, `DEPARTURE_PORT`, `DEPARTURE_DATE`, `DEPARTURE_COMPANY`, `DEPARTURE_PNR_CODE`, `DEPARTURE_TICKET_NUMBER`, `DEPARTURE_TICKET_PRICE`, `DEPARTURE_CAR_LICENSE_PLATE`, `RETURN_TRANSPORTATION_MODE_ID`, `RETURN_PORT`, `RETURN_DATE`, `RETURN_COMPANY`, `RETURN_PNR_CODE`, `RETURN_TICKET_NUMBER`, `RETURN_TICKET_PRICE`, `RETURN_CAR_LICENSE_PLATE`, `CHECK-IN_DATE`, `CHECK-OUT_DATE`, `HOTEL_NAME`, `STATUS_ID`, `MODIFIED_TIME`, `MODIFIED_USER_ID`, `EXPLANATION`) VALUES
(1, '690b774f-5f0c-460a-ba41-e9a3c8498f1d', '2024-06-03 17:07:11', 1240, 107, 3, 'Sabiha Gökçen', '2024-06-17 06:30:00', 'Anadolu Jet', 'ABC123', '987456321', '1.200 ₺', NULL, 5, 'Ulus', '2024-06-27 14:00:00', NULL, NULL, NULL, NULL, '77 AG 077', '2024-06-17 06:30:00', '2024-06-27 14:00:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(2, '2929954c-edb5-47bd-bee2-e723bf992ea8', '2024-06-07 16:39:35', 1240, 107, 3, 'Sabiha Gökçen', '2024-06-17 13:20:00', 'American Airlines', 'ABC85496321', '987456321', '1.200 ₺', NULL, 4, 'Ulus', '2024-06-23 16:00:00', 'Metro Turizm', NULL, NULL, NULL, NULL, '2024-06-17 13:20:00', '2024-06-23 16:00:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(3, '037a0464-683a-422a-aa82-a6878cb7d6f2', '2024-06-11 15:24:44', 1240, 107, 3, 'Sabiha Gökçen', '2024-06-17 13:45:00', 'Delta Air Lines', 'SAW234861093', '987456321', '1.200 ₺', NULL, 4, 'Ulus', '2024-06-22 15:30:00', 'Metro Turizm', NULL, NULL, NULL, NULL, '2024-06-17 13:45:00', '2024-06-22 15:30:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(4, '024539a3-390d-4cbc-b7b6-5c37ad8e7ac9', '2024-07-02 12:25:44', 1240, 97, 4, 'Sabiha Gökçen', '2024-05-17 00:00:00', 'Pamukkale Turizm', NULL, NULL, NULL, NULL, 2, 'Ulus', '2024-05-25 00:00:00', NULL, NULL, NULL, NULL, NULL, '2024-05-17 00:00:00', '2024-05-25 00:00:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(5, 'de94a83b-6727-4134-99b4-ed278d9675d9', '2024-07-03 05:46:03', 1240, 120, 3, 'Sabiha Gökçen', '2024-07-15 00:00:00', 'Türk Hava Yolları', 'SAW234861093', '987456321', '1.200 ₺', NULL, 3, 'Ulus', '2024-07-25 00:00:00', 'Sun Express', 'DEF654', '983476147', '1.350 ₺', NULL, NULL, NULL, NULL, 22, '2024-07-26 11:25:08', 1240, 'Öyle gerekiyor.'),
(6, '29b9a12d-cde7-42e2-8117-6346d6042615', '2024-07-09 13:32:23', 1240, 148, 3, 'Sabiha Gökçen', '2024-12-19 00:00:00', 'EasyJet', 'SAW234861093', '987456321', '1.200 ₺', NULL, 5, 'Ulus', '2024-12-25 00:00:00', NULL, NULL, NULL, NULL, '77 AG 077', '2024-12-19 00:00:00', '2024-12-25 00:00:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(10, '58aacfe4-70b1-4979-b78f-9e402bd111c6', '2024-07-29 15:06:41', 1240, 170, 3, 'Sabiha Gökçen', '2024-08-16 00:00:00', 'Corendon Airlines', 'SAW234861093', '987456321', '1.200 ₺', NULL, 3, 'Ulus', '2024-08-23 00:00:00', 'Corendon Airlines', 'DEF654', '983476147', '1.350 ₺', NULL, '2024-08-16 00:00:00', '2024-08-23 00:00:00', 'Palladium Otel', 21, NULL, NULL, NULL),
(11, '2caa54c1-7415-4f7e-ba38-a29ff9c5734a', '2024-07-29 15:08:54', 1240, 165, 4, 'Sabiha Gökçen', '2024-08-12 00:00:00', 'Metro Turizm', 'SAW234861093', '987456321', '1.200 ₺', NULL, 4, 'Ulus', '2024-08-18 00:00:00', 'Pamukkale Turizm', 'DEF654', '983476147', NULL, NULL, '2024-08-12 00:00:00', '2024-08-18 00:00:00', 'Park Otel', 21, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `route`
--

CREATE TABLE `route` (
  `ID` int NOT NULL,
  `NAME` varchar(10) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `route`
--

INSERT INTO `route` (`ID`, `NAME`) VALUES
(2, 'Yurt Dışı'),
(1, 'Yurt İçi');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `status`
--

CREATE TABLE `status` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `status`
--

INSERT INTO `status` (`ID`, `NAME`) VALUES
(11, 'Onay Bekliyor'),
(12, 'Onaylandı'),
(13, 'Rezervasyon Bekliyor'),
(14, 'Rezervasyon Yapıldı'),
(15, 'Revize Talep Edildi'),
(16, 'Reddedildi'),
(17, 'İptal Edildi'),
(21, 'Aktif'),
(22, 'İptal Edildi');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `transportation_company`
--

CREATE TABLE `transportation_company` (
  `ID` int NOT NULL,
  `NAME` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `TRANSPORTATION_MODE_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `transportation_company`
--

INSERT INTO `transportation_company` (`ID`, `NAME`, `TRANSPORTATION_MODE_ID`) VALUES
(1, 'American Airlines', 3),
(2, 'Anadolu Jet', 3),
(3, 'Corendon Airlines', 3),
(4, 'Delta Air Lines', 3),
(5, 'EasyJet', 3),
(6, 'Onur Air', 3),
(7, 'Pegasus', 3),
(8, 'Southwest Airlines', 3),
(9, 'Sun Express', 3),
(10, 'Türk Hava Yolları', 3),
(11, 'United Airlines', 3),
(12, 'Metro Turizm', 4),
(13, 'Pamukkale Turizm', 4);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `transportation_mode`
--

CREATE TABLE `transportation_mode` (
  `ID` int NOT NULL,
  `NAME` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `transportation_mode`
--

INSERT INTO `transportation_mode` (`ID`, `NAME`) VALUES
(1, 'Demiryolu'),
(2, 'Denizyolu'),
(3, 'Havayolu'),
(4, 'Karayolu (Otobüs)'),
(5, 'Karayolu (Otomobil)');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `traveler`
--

CREATE TABLE `traveler` (
  `ID` int NOT NULL,
  `CREATION_TIME` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CREATOR_USER_ID` int NOT NULL,
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

--
-- Tablo döküm verisi `traveler`
--

INSERT INTO `traveler` (`ID`, `CREATION_TIME`, `CREATOR_USER_ID`, `TYPE_ID`, `NAME`, `SURNAME`, `BIRTH_DATE`, `IDENTITY_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `USER_ID`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`) VALUES
(3, '2024-06-13 10:27:02', 1240, 1, 'AHMET', 'NİZAM', '1977-12-17', 31390290894, 7894561230, '0(533) 462 89 69', 'ahmet.nizam1@mlpcare.com', 1240, 81, 5, 33),
(6, '2024-06-13 10:27:02', 1240, 1, 'CEMAL', 'AYBEK', '1974-05-01', 31438289200, 9874563210, '0(555) 657 15 71', 'cemal.aybek@mlpcare.com', 1244, 85, 5, 33),
(7, '2024-06-13 10:27:02', 1240, 1, 'SERAY', 'ÇİÇEK', '2000-04-24', 44044799988, 1478523690, '0(536) 214 21 72', 'seray.cicek@mlpcare.com', 1241, 55, 5, 33),
(8, '2024-06-13 10:27:02', 1240, 2, 'BETÜL', 'NİZAM', '1981-02-02', 53965335144, 3698521470, '0(545) 560 65 77', 'betulnizam@gmail.com', NULL, NULL, NULL, NULL),
(10, '2024-06-13 10:27:02', 1243, 1, 'OSMAN', 'AKÇAYOGLU', '1983-05-06', 21958814716, NULL, '0(532) 414 97 50', 'osman.akcayoglu@mlpcare.com', 1243, 57, 5, 35);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `traveler_type`
--

CREATE TABLE `traveler_type` (
  `ID` int NOT NULL,
  `NAME` varchar(10) COLLATE utf8mb4_turkish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `traveler_type`
--

INSERT INTO `traveler_type` (`ID`, `NAME`) VALUES
(2, 'Misafir'),
(1, 'Personel');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `user`
--

CREATE TABLE `user` (
  `ID` int NOT NULL,
  `UUID` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `USERNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `SURNAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `EMAIL` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci NOT NULL,
  `POSITION_ID` int DEFAULT NULL,
  `DEPARTMENT_ID` int DEFAULT NULL,
  `LOCATION_ID` int DEFAULT NULL,
  `AUTHORIZE_PERSON` tinyint(1) NOT NULL DEFAULT '0',
  `EXECUTIVE_PERSON` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `user`
--

INSERT INTO `user` (`ID`, `UUID`, `USERNAME`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`, `AUTHORIZE_PERSON`, `EXECUTIVE_PERSON`) VALUES
(1240, 'a45a357e-717c-4223-9060-1082a49b713e', 'ahmet.nizam1', 'AHMET', 'NİZAM', 'ahmet.nizam1@mlpcare.com', 81, 5, 33, 1, 1),
(1241, 'b1d57b39-d902-4f16-b55d-7c111ce47012', 'seray.cicek', 'SERAY', 'ÇİÇEK', 'seray.cicek@mlpcare.com', 55, 5, 33, 0, 0),
(1242, 'e36bb123-93dd-42b7-88c3-6b7fb5a2e123', 'utku.yurtcu', 'UTKU', 'YURTCU', 'utku.yurtcu@mlpcare.com', 73, 5, 33, 0, 0),
(1243, '88be4b8e-2094-42c6-abeb-adee0719f982', 'osman.akcayoglu', 'OSMAN', 'AKÇAYOGLU', 'osman.akcayoglu@mlpcare.com', 57, 5, 35, 0, 0),
(1244, 'c57b0f0f-556a-4f82-bd18-eebca3d091fe', 'cemal.aybek', 'CEMAL', 'AYBEK', 'cemal.aybek@mlpcare.com', 85, 5, 33, 1, 1);

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
  `LOCATION_ID` int DEFAULT NULL,
  `AUTHORIZED_PERSON` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Tablo döküm verisi `user_backup`
--

INSERT INTO `user_backup` (`ID`, `USERNAME`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`, `AUTHORIZED_PERSON`) VALUES
(10, 'abdullah.canturk', 'ABDULLAH', 'CANTÜRK', 'abdullah.canturk@medicalpark.com.tr', 16, 26, 21, 0),
(11, 'abdullah.kars', 'ABDULLAH', 'KARS', 'abdullah.kars@isu.edu.tr', 39, 26, 22, 0),
(12, 'abdurrahman.yildirim', 'ABDURRAHMAN', 'YILDIRIM', 'abdurrahman.yildirim@medicalpark.com.tr', 3, 3, 29, 0),
(13, 'adem.bayram', 'ADEM', 'BAYRAM', 'adem.bayram@medicalpark.com.tr', 66, 24, 21, 0),
(14, 'adem.demir', 'ADEM', 'DEMİR', 'adem.demir@livhospital.com.tr', 9, 4, 6, 0),
(15, 'ahmet.hakan', 'AHMET', 'HAKAN', 'ahmet.hakan@mlpcare.com', 39, 26, 7, 0),
(16, 'ahmet.turan', 'AHMET', 'TURAN', 'ahmet.turan@medicalpark.com.tr', 46, 20, 27, 0),
(17, 'ahmet.usta', 'AHMET', 'USTA', 'ahmet.usta@mlpcare.com', 76, 27, 1, 0),
(18, 'ahmet.yazici', 'AHMET', 'YAZICI', 'ahmet.yazici@iauh.com.tr', 2, 3, 30, 0),
(19, 'akan.kilic', 'AKAN', 'KILIÇ', 'akan.kilic@medicalpark.com.tr', 46, 20, 15, 0),
(20, 'akif.acikel', 'AKİF', 'AÇIKEL', 'akif.acikel@medicalpark.com.tr', 32, 26, 20, 0),
(21, 'akif.benk', 'MEHMET AKİF', 'BENK', 'akif.benk@livhospital.com.tr', 16, 26, 6, 0),
(22, 'akif.kirbas', 'AKİF', 'KIRBAŞ', 'akif.kirbas@medicalpark.com.tr', 16, 26, 29, 0),
(23, 'akif.pasaoglu', 'MEHMET AKİF', 'PAŞAOĞLU', 'akif.pasaoglu@mlpcare.com', 42, 18, 31, 0),
(24, 'akin.sahin', 'AKIN', 'ŞAHİN', 'akin.sahin@isu.edu.tr', 9, 4, 22, 0),
(25, 'albs', 'ADEM', 'ELBAŞI', 'albs@mlpcare.com', 35, 13, 1, 0),
(26, 'aliosman.epcacan', 'ALİ OSMAN', 'EPÇAÇAN', 'aliosman.epcacan@medicalpark.com.tr', 2, 3, 12, 0),
(27, 'alper.begen', 'ALPER', 'BEĞEN', 'alper.begen@medicalpark.com.tr', 16, 26, 27, 0),
(28, 'alper.canitez', 'ALPER', 'CANITEZ', 'alper.canitez@mlpcare.com', 31, 2, 1, 0),
(29, 'anil.sarier', 'ANIL', 'SARIER', 'anil.sarier@medicalpark.com.tr', 4, 3, 10, 0),
(30, 'asiye.yilmaz', 'ASİYE', 'YILMAZ', 'asiye.yilmaz@medicalpark.com.tr', 46, 20, 25, 0),
(31, 'aysun.cakir', 'AYSUN', 'ÇAKIR ÖZÇELİK', 'aysun.cakir@livhospital.com.tr', 58, NULL, NULL, 0),
(32, 'aytac.tuna', 'AYTAÇ', 'TUNA', 'aytac.tuna@medicalpark.com.tr', 9, 4, 25, 0),
(33, 'bayram.davutoglu', 'BAYRAM', 'DAVUTOĞLU', 'bayram.davutoglu@medicalpark.com.tr', 46, 20, 18, 0),
(34, 'berna.ozmen', 'BERNA', 'ÖZMEN', 'berna.ozmen@mlpcare.com', 53, 3, 31, 0),
(35, 'besir.avsar', 'BEŞİR', 'AVŞAR', 'besir.avsar@medicalpark.com.tr', 8, 4, 10, 0),
(36, 'betul.ozturk', 'BETÜL', 'ÖZTÜRK KÜÇÜKARSLAN', 'betul.ozturk@medicalpark.com.tr', 39, 26, 11, 0),
(37, 'birol.kahveci', 'BİROL', 'KAHVECİ', 'birol.kahveci@medicalpark.com.tr', 58, 26, 25, 0),
(38, 'birsen.cinar', 'BİRSEN', 'ÇINAR ARSLAN', 'birsen.cinar@iauh.com.tr', 46, 20, 30, 0),
(39, 'buket.gulyokus', 'BUKET', 'GÜLYOKUŞ', 'buket.gulyokus@medicalpark.com.tr', 46, 20, 29, 0),
(40, 'burak.akca', 'BURAK', 'AKCA', 'burak.akca@livhospital.com.tr', 4, 3, 2, 0),
(41, 'burak.coskun2', 'BURAK', 'COŞKUN', 'burak.coskun2@medicalpark.com.tr', 45, 20, 16, 0),
(42, 'burcin.budakoglu', 'BURÇİN', 'BUDAKOĞLU', 'burcin.budakoglu@medicalpark.com.tr', 16, 26, 11, 0),
(43, 'burcu.aytek', 'BURCU', 'AYTEK', 'burcu.aytek@livhospital.com.tr', 46, 20, 2, 0),
(44, 'burcu.kaya1', 'BURCU', 'KAYA', 'burcu.kaya1@mlpcare.com', 61, 23, 1, 0),
(45, 'burcu.ozturk', 'BURCU', 'ÖZTÜRK', 'burcu.ozturk@mlpcare.com', 38, 16, 1, 0),
(46, 'cagatay.dikmen', 'ÇAĞATAY', 'DİKMEN', 'cagatay.dikmen@isu.edu.tr', 2, 3, 9, 0),
(47, 'cagri.kosker', 'ALİ ÇAĞRI', 'KÖŞKER', 'cagri.kosker@medicalpark.com.tr', 3, 3, 27, 0),
(48, 'cagri.kuzgun', 'FERİT ÇAĞRI', 'KUZGUN', 'cagri.kuzgun@medicalpark.com.tr', 58, 26, 24, 0),
(49, 'can.gulerer1', 'CAN BURAK', 'GÜLERER', 'can.gulerer1@medicalpark.com.tr', 66, 24, 23, 0),
(50, 'canan.dede', 'CANAN', 'DEDE', 'canan.dede@mlpcare.com', 62, 23, 1, 0),
(51, 'canan.ertoy', 'CANAN', 'ERTOY ÇULCU', 'canan.ertoy@mlpcare.com', 50, 18, 31, 0),
(52, 'canberk.come', 'CANBERK', 'ÇÖME', 'canberk.come@livhospital.com.tr', 66, 24, 2, 0),
(53, 'cazibe.yucel', 'CAZİBE EBRU', 'YÜCEL', 'cazibe.yucel@mlpcare.com', 21, 8, 1, 0),
(54, 'cemal.caparusagi', 'CEMAL', 'ÇAPARUŞAĞI', 'cemal.caparusagi@livhospital.com.tr', 16, 26, 3, 0),
(55, 'cigdem.alkiraz', 'ÇİĞDEM', 'ALKİRAZ', 'cigdem.alkiraz@medicalpark.com.tr', 17, 26, 20, 0),
(56, 'cigdem.hancerkiran', 'ÇİĞDEM', 'HANÇERKIRAN', 'cigdem.hancerkiran@livhospital.com.tr', 45, 20, 3, 0),
(57, 'cigdem.pekgulec', 'ÇİĞDEM', 'PEKGÜLEÇ', 'cigdem.pekgulec@mlpcare.com', 25, 9, 1, 0),
(58, 'cihat.genc', 'CİHAT', 'GENÇ', 'cihat.genc@livhospital.com.tr', 4, 3, 4, 0),
(59, 'cuneyt.uysal', 'CÜNEYT', 'UYSAL', 'cuneyt.uysal@livhospital.com.tr', 65, 24, 4, 0),
(60, 'deniz.ercan', 'DENİZ', 'ERCAN', 'deniz.ercan@medicalpark.com.tr', 4, 3, 19, 0),
(61, 'deniz.tarhan', 'DENİZ', 'TARHAN', 'deniz.tarhan@iauh.com.tr', 66, 24, 30, 0),
(62, 'deniz.yucel', 'DENİZ CAN', 'YÜCEL', 'deniz.yucel@mlpcare.com', 77, 28, 1, 0),
(63, 'derya.malkoc', 'DERYA', 'MALKOÇ', 'derya.malkoc@isu.edu.tr', 46, 20, 9, 0),
(64, 'dursun.bas', 'DURSUN', 'BAŞ', 'dursun.bas@medicalpark.com.tr', 48, 20, 20, 0),
(65, 'dursun.bulut', 'DURSUN', 'BULUT', 'dursun.bulut@medicalpark.com.tr', 16, 26, 20, 0),
(66, 'duygu.ferah', 'DUYGU', 'FERAH', 'duygu.ferah@medicalpark.com.tr', 47, 20, 24, 0),
(67, 'elif.yildirim1', 'ELİF', 'YILDIRIM', 'elif.yildirim1@mlpcare.com', 30, 2, 1, 0),
(68, 'elif.yildiz', 'ELİF', 'KARADAŞ', 'elif.yildiz@medicalpark.com.tr', 46, 20, 11, 0),
(69, 'embiya.aydin', 'EMBİYA', 'AYDIN', 'embiya.aydin@medicalpark.com.tr', 8, 4, 21, 0),
(70, 'emin.eskici', 'EMİN UĞUR', 'ESKİCİ', 'emin.eskici@medicalpark.com.tr', 66, 24, 12, 0),
(71, 'emrah.ipek', 'EMRAH', 'İPEK', 'emrah.ipek@medicalpark.com.tr', 65, 24, 11, 0),
(72, 'enes.gokyar', 'ENES', 'GÖKYAR', 'enes.gokyar@medicalpark.com.tr', 66, 24, 15, 0),
(73, 'enis.atali', 'ENİS', 'ATALI', 'enis.atali@livhospital.com.tr', 3, 3, 6, 0),
(74, 'enver.bilgici', 'ENVER', 'BİLGİCİ', 'enver.bilgici@mlpcare.com', 64, 24, 1, 0),
(75, 'ercan.kablan', 'ERCAN', 'KABLAN', 'ercan.kablan@medicalpark.com.tr', 3, 3, 26, 0),
(76, 'erdem.mugaloglu', 'ERDEM ERHAN', 'MUĞALOĞLU', 'erdem.mugaloglu@isu.edu.tr', 46, 20, 22, 0),
(77, 'erdem.yuce', 'ERDEM', 'YÜCE', 'erdem.yuce@medicalpark.com.tr', 66, 24, 18, 0),
(78, 'eren.tatli', 'EREN', 'TATLI', 'eren.tatli@medicalpark.com.tr', 3, 3, 23, 0),
(79, 'erhan.ciplakligil', 'ERHAN', 'ÇIPLAKLIGİL', 'erhan.ciplakligil@medicalpark.com.tr', 16, 26, 26, 0),
(80, 'erkan.erdem', 'ERKAN', 'ERDEM', 'erkan.erdem@medicalpark.com.tr', 16, 26, 14, 0),
(81, 'erman.sert', 'ERMAN', 'SERT', 'erman.sert@livhospital.com.tr', 65, 24, 3, 0),
(82, 'ersan.bickioglu', 'ERSAN', 'BİÇKİOĞLU', 'ersan.bickioglu@mlpcare.com', 14, 5, 1, 0),
(83, 'esin.yalcin', 'ESİN ZEYNEP', 'YALÇIN', 'esin.yalcin@medicalpark.com.tr', 59, 26, 23, 0),
(84, 'esra.molla', 'ESRA', 'MOLLA', 'esra.molla@medicalpark.com.tr', 72, 26, 24, 0),
(85, 'evren.gunes', 'EVREN', 'GÜNEŞ', 'evren.gunes@medicalpark.com.tr', 3, 3, 11, 0),
(86, 'faik.sonmez2', 'FAİK', 'SÖNMEZ', 'faik.sonmez2@medicalpark.com.tr', 9, 4, 16, 0),
(87, 'fatih.akpinar', 'FATİH', 'AKPINAR', 'fatih.akpinar@isu.edu.tr', 16, 26, 9, 0),
(88, 'fatma.durust', 'FATMA', 'TAN DÜRÜST', 'fatma.durust@medicalpark.com.tr', 58, 26, 29, 0),
(89, 'fatma.sahin', 'FATMA', 'ŞAHİN', 'fatma.sahin@medicalpark.com.tr', 58, 26, 28, 0),
(90, 'fazilet.turan', 'FAZİLET', 'TURAN', 'fazilet.turan@iauh.com.tr', 40, 26, 30, 0),
(91, 'ferhat.celik', 'FERHAT', 'ÇELİK', 'ferhat.celik@medicalpark.com.tr', 67, 24, 10, 0),
(92, 'ferhat.ercetin', 'FERHAT', 'ERÇETİN', 'ferhat.ercetin@mlpcare.com', 3, 3, 7, 0),
(93, 'filiz.gunaydin', 'FİLİZ', 'GÜNAYDIN', 'filiz.gunaydin@medicalpark.com.tr', 39, 26, 21, 0),
(94, 'funda.yildirtan', 'FUNDA', 'YILDIRTAN', 'funda.yildirtan@mlpcare.com', 26, 9, 1, 0),
(95, 'giyasettin.bulbul', 'GIYASETTİN', 'BÜLBÜL', 'giyasettin.bulbul@medicalpark.com.tr', 66, NULL, NULL, 0),
(96, 'gokce.atesoglu', 'GÖKÇE', 'ATEŞOĞLU', 'gokce.atesoglu@medicalpark.com.tr', 45, 20, 14, 0),
(97, 'gokhan.altuntas', 'GÖKHAN', 'ALTUNTAŞ', 'gokhan.altuntas@medicalpark.com.tr', 58, 26, 26, 0),
(98, 'gonul.sevi', 'GÖNÜL', 'SEVİ', 'gonul.sevi@mlpcare.com', 51, 21, 1, 0),
(99, 'gulcan.kisaboy', 'GÜLCAN', 'YAZĞAN', 'gulcan.kisaboy@medicalpark.com.tr', 17, 26, 14, 0),
(100, 'gurkan.caglioglu', 'GÜRKAN', 'CAĞLIOĞLU', 'gurkan.caglioglu@mlpcare.com', 6, 18, 31, 0),
(101, 'hakan.ercan', 'HAKAN', 'ERCAN', 'hakan.ercan@mlpcare.com', 22, 13, 1, 0),
(102, 'haki.haseken', 'HAKİ', 'HASEKEN', 'haki.haseken@medicalpark.com.tr', 58, 26, 17, 0),
(103, 'halilibrahim.calis', 'HALİL İBRAHİM', 'ÇALIŞ', 'halilibrahim.calis@medicalpark.com.tr', 16, 26, 18, 0),
(104, 'hamit.ozturk', 'HAMİT', 'ÖZTÜRK', 'hamit.ozturk@medicalpark.com.tr', 16, 26, 19, 0),
(105, 'hatice.bulut', 'HATİCE', 'BULUT', 'hatice.bulut@livhospital.com.tr', 58, 26, 4, 0),
(106, 'haydar.aydin', 'HAYDAR', 'AYDIN', 'haydar.aydin@medicalpark.com.tr', 39, 26, 12, 0),
(107, 'hikmet.cavus', 'HİKMET', 'ÇAVUŞ', 'hikmet.cavus@mlpcare.com', 54, 22, 1, 0),
(108, 'hulusi.surmeli', 'HULUSİ EMRE', 'SÜRMELİ', 'hulusi.surmeli@mlpcare.com', 49, 18, 31, 0),
(109, 'hulya.kutoglu', 'HÜLYA NURCAN', 'KUTOĞLU', 'hulya.kutoglu@medicalpark.com.tr', 58, 26, 21, 0),
(110, 'huseyin.colak', 'HÜSEYİN', 'ÇOLAK', 'huseyin.colak@livhospital.com.tr', 8, 4, 4, 0),
(111, 'huseyin.demirci', 'HÜSEYİN', 'DEMİRCİ', 'huseyin.demirci@livhospital.com.tr', 8, 4, 5, 0),
(112, 'huseyin.guzel', 'HÜSEYİN', 'GÜZEL', 'huseyin.guzel@isu.edu.tr', 9, 4, 9, 0),
(113, 'idil.celik', 'İDİL', 'ÇELİK', 'idil.celik@mlpcare.com', 53, NULL, NULL, 0),
(114, 'idris.ozcelik', 'İDRİS', 'ÖZÇELİK', 'idris.ozcelik@mlpcare.com', 36, 14, 1, 0),
(115, 'ilhan.tandogan', 'İLHAN', 'TANDOĞAN', 'ilhan.tandogan@isu.edu.tr', 39, 26, 9, 0),
(116, 'irem.karagoz', 'İREM', 'SAYLAM KARAGÖZ', 'irem.karagoz@medicalpark.com.tr', 2, 3, 28, 0),
(117, 'ismail.akdemir', 'İSMAİL', 'AKDEMİR', 'ismail.akdemir@medicalpark.com.tr', 13, 26, 13, 0),
(118, 'izzet.yildiz', 'İZZET CAN', 'YILDIZ', 'izzet.yildiz@mlpcare.com', 71, 2, 1, 0),
(119, 'kenan.celik', 'KENAN', 'ÇELİK', 'kenan.celik@medicalpark.com.tr', 9, 4, 29, 0),
(120, 'kenan.ozkilic', 'KENAN', 'ÖZKILIÇ', 'kenan.ozkilic@medicalpark.com.tr', 9, 4, 13, 0),
(121, 'kubra.dulger', 'KÜBRA', 'DÜLGER CANSIZ', 'kubra.dulger@medicalpark.com.tr', 9, 4, 28, 0),
(122, 'kubranur.sencan', 'KÜBRA NUR', 'ŞENCAN', 'kubranur.sencan@mlpcare.com', 63, 23, 1, 0),
(123, 'levent.helvali', 'LEVENT', 'HELVALI', 'levent.helvali@medicalpark.com.tr', 9, 4, 20, 0),
(124, 'mahmut.sahin', 'MAHMUT', 'ŞAHİN', 'mahmut.sahin@medicalpark.com.tr', 16, 26, 25, 0),
(125, 'mehmet.amanet', 'MEHMET YASİN', 'AMANET', 'mehmet.amanet@mlpcare.com', 29, 2, 1, 0),
(126, 'mehmet.cifci', 'MEHMET', 'ÇİFÇİ', 'mehmet.cifci@livhospital.com.tr', 2, 3, 3, 0),
(127, 'mehmet.gormez', 'MEHMET', 'GÖRMEZ', 'mehmet.gormez@medicalpark.com.tr', 65, 24, 13, 0),
(128, 'mehmet.gun', 'MEHMET', 'GÜN', 'mehmet.gun@mlpcare.com', 39, 26, 16, 0),
(129, 'mehmet.par', 'MEHMET', 'ERCAN PAR', 'mehmet.par@livhospital.com.tr', 8, 4, 3, 0),
(130, 'mehmetali.ozgan', 'MEHMET ALİ', 'ÖZGAN', 'mehmetali.ozgan@medicalpark.com.tr', 2, 3, 14, 0),
(131, 'mehmetulvi.guney', 'MEHMET ULVİ', 'GÜNEY', 'mehmetulvi.guney@medicalpark.com.tr', 58, 26, 18, 0),
(132, 'melis.indirkas', 'MELİS', 'İNDİRKAŞ', 'melis.indirkas@mlpcare.com', 70, 25, 1, 0),
(133, 'meltem.demir', 'MELTEM', 'DEMİR', 'meltem.demir@medicalpark.com.tr', 72, 26, 12, 0),
(134, 'meral.soylemez', 'MERAL', 'SÖYLEMEZ', 'meral.soylemez@livhospital.com.tr', 58, 26, 6, 0),
(135, 'mert.kargin', 'MERT GÖKBERK', 'KARĞIN', 'mert.kargin@mlpcare.com', 23, 9, 1, 0),
(136, 'mert.sertcelik', 'MERT', 'SERTÇELİK', 'mert.sertcelik@mlpcare.com', 31, 2, 1, 0),
(137, 'merter.kesenli', 'MERTER', 'KESENLİ', 'merter.kesenli@livhospital.com.tr', 46, 20, 6, 0),
(138, 'mikayil.salimov', 'MİKAYIL', 'SELİMOV', 'mikayil.salimov@livhospital.com', 9, 4, 7, 0),
(139, 'miracozcan.caglar2', 'ÖZCAN', 'ÇAĞLAR', 'miracozcan.caglar2@medicalpark.com.tr', 45, 20, 17, 0),
(140, 'muhammet.sahin1', 'MUHAMMET FATİH', 'ŞAHİN', 'muhammet.sahin1@medicalpark.com.tr', 65, 24, 25, 0),
(141, 'muhammet.serit', 'MUHAMMET', 'ŞERİT', 'muhammet.serit@medicalpark.com.tr', 4, 3, 17, 0),
(142, 'muharrem.aslantas', 'MUHARREM', 'ASLANTAŞ', 'muharrem.aslantas@medicalpark.com.tr', 66, 24, 26, 0),
(143, 'muharrem.usta', 'MUHARREM', 'USTA', 'muharrem.usta@mlpcare.com', 78, 29, 1, 0),
(144, 'murat.akarslan', 'MURAT', 'AKARSLAN', 'murat.akarslan@mlpcare.com', 44, 18, 31, 0),
(145, 'murat.balta', 'MURAT', 'BALTA', 'murat.balta@medicalpark.com.tr', 46, 20, 26, 0),
(146, 'murat.birdogan', 'MURAT', 'BİRDOĞAN', 'murat.birdogan@medicalpark.com.tr', 46, 20, 12, 0),
(147, 'murat.pekmezoglu', 'MURAT', 'PEKMEZOĞLU', 'murat.pekmezoglu@mlpcare.com', 79, 30, 1, 0),
(148, 'murat.pesci', 'MURAT', 'PESCİ', 'murat.pesci@medicalpark.com.tr', 9, 4, 15, 0),
(149, 'mursel.oral', 'MURSEL', 'ORAL', 'mursel.oral@medicalpark.com.tr', 66, 24, 29, 0),
(150, 'mustafa.adanur', 'MUSTAFA', 'ADANUR', 'mustafa.adanur@medicalpark.com.tr', 2, 3, 21, 0),
(151, 'mustafa.armagan', 'MUSTAFA', 'ARMAĞAN', 'mustafa.armagan@livhospital.com.tr', 2, 3, 5, 0),
(152, 'mustafa.demirtas', 'MUSTAFA', 'DEMİRTAŞ', 'mustafa.demirtas@medicalpark.com.tr', 9, 4, 11, 0),
(153, 'mustafa.isik', 'MUSTAFA', 'IŞIK', 'mustafa.isik@mlpcare.com', 60, 23, 1, 0),
(154, 'mustafa.kayhan', 'MUSTAFA', 'KAYHAN', 'mustafa.kayhan@livhospital.com.tr', 66, 24, 6, 0),
(155, 'mustafa.metin', 'MUSTAFA', 'METİN', 'mustafa.metin@medicalpark.com.tr', 66, 24, 24, 0),
(156, 'mustafa.sen', 'MUSTAFA', 'ŞEN', 'mustafa.sen@livhospital.com.tr', 16, 26, 4, 0),
(157, 'mustafa.yilmaz', 'MUSTAFA', 'YILMAZ', 'mustafa.yilmaz@mlpcare.com', 29, 18, 31, 0),
(158, 'naci.yilmaz', 'NACİ', 'YILMAZ', 'naci.yilmaz@medicalpark.com.tr', 39, 26, 25, 0),
(159, 'nazlihan.alkan', 'NAZLIHAN', 'ALKAN', 'nazlihan.alkan@livhospital.com.tr', 16, 26, 2, 0),
(160, 'nihal.kara', 'NİHAL', 'KARA', 'nihal.kara@medicalpark.com.tr', 59, 26, 19, 0),
(161, 'nihal.unluturk', 'NİHAL', 'ÜNLÜTÜRK', 'nihal.unluturk@mlpcare.com', 33, 11, 1, 0),
(162, 'nihat.donmez', 'NİHAT', 'DÖNMEZ', 'nihat.donmez@medicalpark.com.tr', 66, 24, 14, 0),
(163, 'nihat.tasdemir', 'NİHAT', 'TAŞDEMİR', 'nihat.tasdemir@medicalpark.com.tr', 16, 26, 15, 0),
(164, 'niyazi.odabasioglu', 'NİYAZİ', 'ODABAŞIOĞLU', 'niyazi.odabasioglu@mlpcare.com', 7, 4, 1, 0),
(165, 'nur.sagiroglu', 'NUR', 'SAĞIROĞLU DEMİR', 'nur.sagiroglu@isu.edu.tr', 72, 26, 30, 0),
(166, 'nuray.cakmak', 'NURAY', 'ÇAKMAK', 'nuray.cakmak@mlpcare.com', 18, 6, 1, 0),
(167, 'omer.guney', 'ÖMER', 'GÜNEY', 'omer.guney@medicalpark.com.tr', 4, 3, 18, 0),
(168, 'omur.lok', 'ÖMÜR', 'LÖK', 'omur.lok@mlpcare.com', 19, 16, 1, 0),
(169, 'onur.demirkol', 'ONUR', 'DEMİRKOL', 'onur.demirkol@iauh.com.tr', 58, 26, 30, 0),
(170, 'orhangazi.barotcu', 'ORHAN GAZİ', 'BAROTCU', 'orhangazi.barotcu@medicalpark.com.tr', 66, 24, 17, 0),
(171, 'osman.akcayoglu', 'OSMAN', 'AKÇAYOGLU', 'osman.akcayoglu@mlpcare.com', 57, 5, 1, 0),
(172, 'ozgun.gungor', 'ÖZGÜN', 'GÜNGÖR', 'ozgun.gungor@livhospital.com.tr', 16, 26, 5, 0),
(173, 'ozgurkaan.yeler', 'ÖZGÜR KAAN', 'YELER', 'ozgurkaan.yeler@livhospital.com.tr', 39, 26, 6, 0),
(174, 'ozkan.ozarslan', 'KADRİ ÖZKAN', 'ÖZARSLAN', 'ozkan.ozarslan@mlpcare.com', 69, 16, 1, 0),
(175, 'ozlem.aydin', 'ÖZLEM', 'AYDIN SUCU', 'ozlem.aydin@mlpcare.com', 1, 1, 1, 0),
(176, 'ozlem.kutay', 'ÖZLEM', 'KUTAY ARAS', 'ozlem.kutay@medicalpark.com.tr', 59, 26, 15, 0),
(177, 'ozlem.oztel', 'ÖZLEM', 'ÖZTEL', 'ozlem.oztel@mlpcare.com', 34, 12, 1, 0),
(178, 'recep.sahin', 'RECEP MUHİTTİN', 'ŞAHİN', 'recep.sahin@medicalpark.com.tr', 12, 4, 19, 0),
(179, 'sabri.gencay', 'SABRİ', 'GENÇAY', 'sabri.gencay@medicalpark.com.tr', 9, 4, 17, 0),
(180, 'sadiye.arda', 'SADİYE', 'ARDA', 'sadiye.arda@isu.edu.tr', 58, 26, 22, 0),
(181, 'safak.akin', 'ŞAFAK', 'AKIN', 'safak.akin@medicalpark.com.tr', 66, 24, 28, 0),
(182, 'salih.yilmaz', 'SALİH CAN', 'YILMAZ', 'salih.yilmaz@livhospital.com.tr', 66, 24, 5, 0),
(183, 'seda.kuru', 'SEDA', 'KURU', 'seda.kuru@livhospital.com.tr', 17, 26, 2, 0),
(184, 'sedat.gurer', 'SEDAT', 'GÜRER', 'sedat.gurer@medicalpark.com.tr', 3, 3, 25, 0),
(185, 'sedat.kurtar', 'AHMET SEDAT', 'KURTAR', 'sedat.kurtar@medicalpark.com.tr', 16, 26, 10, 0),
(186, 'sedat.yilmaz', 'SEDAT', 'YILMAZ', 'sedat.yilmaz@medicalpark.com.tr', 48, 20, 19, 0),
(187, 'seden.ozkan', 'SEDEN', 'ÖZKAN', 'seden.ozkan@medicalpark.com.tr', 58, 26, 27, 0),
(188, 'selahattin.calik', 'SELAHATTİN', 'ÇALIK', 'selahattin.calik@medicalpark.com.tr', 2, 3, 24, 0),
(189, 'semra.basaran', 'SEMRA', 'BAŞARAN', 'semra.basaran@livhospital.com', 58, 19, 1, 0),
(190, 'sena.sahin', 'HANİFE SENA', 'ŞAHİN', 'sena.sahin@mlpcare.com', 30, 2, 1, 0),
(191, 'serafettin.demiray', 'ŞERAFETTİN', 'DEMİRAY', 'serafettin.demiray@mlpcare.com', 28, 10, 1, 0),
(192, 'seray.cicek', 'SERAY', 'ÇİÇEK', 'seray.cicek@mlpcare.com', 55, 5, 32, 0),
(193, 'sercan.durman', 'SERCAN', 'DURMAN', 'sercan.durman@mlpcare.com', 75, 5, 1, 0),
(194, 'sercan.eskimutlu', 'SERCAN', 'ESKİMUTLU', 'sercan.eskimutlu@medicalpark.com.tr', 15, 24, 19, 0),
(195, 'sercan.ozmen', 'SERCAN', 'ÖZMEN', 'sercan.ozmen@iauh.com.tr', 9, 4, 30, 0),
(196, 'serdal.serin', 'SERDAL', 'SERİN', 'serdal.serin@medicalpark.com.tr', 16, 26, 16, 0),
(197, 'serdar.saribas', 'SERDAR', 'SARIBAŞ', 'serdar.saribas@isu.edu.tr', 58, 26, 9, 0),
(198, 'serhan.yildirim', 'SERHAN KAMİL', 'YILDIRIM', 'serhan.yildirim@mlpcare.com', 68, 25, 1, 0),
(199, 'serif.koksal', 'ŞERİF', 'KÖKSAL', 'serif.koksal@mlpcare.com', 20, 7, 1, 0),
(200, 'serkan.tuncer', 'SERKAN', 'TUNCER', 'serkan.tuncer@mlpcare.com', 27, 10, 1, 0),
(201, 'sertac.akgun', 'SERTAÇ', 'AKGÜN', 'sertac.akgun@mlpcare.com', 52, 23, 1, 0),
(202, 'sevinc.ebrinc', 'SEVİNÇ', 'EBRİNÇ', 'sevinc.ebrinc@medicalpark.com.tr', 72, 26, 23, 0),
(203, 'sevinc.qafarova', 'SEVİNC', 'QAFAROVA', 'sevinc.qafarova@livhospital.com', 46, 20, 7, 0),
(204, 'sezer.deniz', 'SEZER', 'DENİZ', 'sezer.deniz@medicalpark.com.tr', 46, 20, 13, 0),
(205, 'sibel.inci', 'SİBEL', 'İNCİ', 'sibel.inci@medicalpark.com.tr', 8, 4, 24, 0),
(206, 'sinan.ayranci', 'SİNAN', 'AYRANCI', 'sinan.ayranci@mlpcare.com', 10, 4, 1, 0),
(207, 'sinan.iskender', 'SİNAN', 'İSKENDER', 'sinan.iskender@medicalpark.com.tr', 8, 4, 26, 0),
(208, 'sinem.ozer', 'SİNEM', 'ÖZER', 'sinem.ozer@mlpcare.com', 62, 23, 1, 0),
(209, 'sirin.yuksel', 'ŞİRİN', 'YÜKSEL', 'sirin.yuksel@mlpcare.com', 37, 15, 1, 0),
(210, 'soner.ozdemır', 'SONER', 'ÖZDEMİR', 'soner.ozdemır@livhospital.com.tr', 11, 4, 2, 0),
(211, 'sonertayfun.sirahane', 'SONER TAYFUN', 'ŞIRAHANE', 'sonertayfun.sirahane@medicalpark.com.tr', 9, 4, 27, 0),
(212, 'suna.beyaz', 'SUNA', 'ÖNDER', 'suna.beyaz@medicalpark.com.tr', 58, 26, 13, 0),
(213, 'taha.salan', 'TAHA', 'SALAN', 'taha.salan@medicalpark.com.tr', 2, 3, 15, 0),
(214, 'taner.ozbek', 'TANER', 'ÖZBEK', 'taner.ozbek@mlpcare.com', 16, 19, 1, 0),
(215, 'taner.ozcan', 'TANER', 'ÖZCAN', 'taner.ozcan@mlpcare.com', 56, 5, 32, 0),
(216, 'tarik.buyukoral', 'TARIK', 'BÜYÜKORAL', 'tarik.buyukoral@isu.edu.tr', 66, 24, 22, 0),
(217, 'tayfun.kazanci', 'TAYFUN', 'KAZANCI', 'tayfun.kazanci@medicalpark.com.tr', 46, 20, 21, 0),
(218, 'tolga.karaca', 'TOLGA', 'KARACA', 'tolga.karaca@livhospital.com.tr', 58, 26, 3, 0),
(219, 'tugba.altin', 'TUĞBA', 'ALTIN', 'tugba.altin@medicalpark.com.tr', 16, 26, 17, 0),
(220, 'tugba.cavus1', 'TUĞBA', 'ÇAVUŞ', 'tugba.cavus1@mlpcare.com', 73, 5, 1, 0),
(221, 'tulay.aydin', 'TÜLAY', 'AYDIN', 'tulay.aydin@mlpcare.com', 41, 17, 1, 0),
(222, 'tuncay.ertem', 'TUNCAY', 'ERTEM', 'tuncay.ertem@medicalpark.com.tr', 5, 3, 20, 0),
(223, 'tuncay.kalyon', 'TUNCAY', 'KALYON', 'tuncay.kalyon@isu.edu.tr', 3, 3, 22, 0),
(224, 'turan.saka', 'TURAN', 'SAKA', 'turan.saka@medicalpark.com.tr', 17, 26, 17, 0),
(225, 'ugur.dundar', 'UĞUR', 'DÜNDAR', 'ugur.dundar@medicalpark.com.tr', 16, 26, 28, 0),
(226, 'ugur.kirez', 'UĞUR', 'KİREZ', 'ugur.kirez@medicalpark.com.tr', 58, 26, 12, 0),
(227, 'ugur.mirza', 'UĞUR', 'MİRZA', 'ugur.mirza@medicalpark.com.tr', 39, 26, 27, 0),
(228, 'utku.yurtcu', 'UTKU', 'YURTCU', 'utku.yurtcu@mlpcare.com', 74, NULL, NULL, 0),
(229, 'veysel.demir', 'VEYSEL', 'DEMİR', 'veysel.demir@mlpcare.com', 43, 18, 31, 0),
(230, 'volkan.akgumus', 'VOLKAN', 'AKGÜMÜŞ', 'volkan.akgumus@medicalpark.com.tr', 46, 20, 28, 0),
(231, 'yasemin.halefoglu', 'YASEMİN', 'HALEFOĞLU', 'yasemin.halefoglu@medicalpark.com.tr', 58, 26, 10, 0),
(232, 'yasemin.yilmaz3', 'YASEMİN', 'YILMAZ KARS', 'yasemin.yilmaz3@medicalpark.com.tr', 39, 26, 13, 0),
(233, 'yasin.sahin', 'YASİN', 'ŞAHİN', 'yasin.sahin@medicalpark.com.tr', 39, 26, 28, 0),
(234, 'yasinzafer.calisir', 'YASİN ZAFER', 'ÇALIŞIR', 'yasinzafer.calisir@medicalpark.com.tr', 9, 4, 12, 0),
(235, 'yeliz.yavuz', 'YELİZ', 'YAVUZ', 'yeliz.yavuz@mlpcare.com', 59, 26, 16, 0),
(236, 'yenal.aydin', 'YENAL', 'AYDIN', 'yenal.aydin@medicalpark.com.tr', 66, 24, 16, 0),
(237, 'yunus.colak', 'YUNUS', 'ÇOLAK', 'yunus.colak@livhospital.com.tr', 24, 9, 1, 0),
(238, 'yunusemre.gorentas', 'YUNUS EMRE', 'GÖRENTAŞ', 'yunusemre.gorentas@isu.edu.tr', 66, 24, 9, 0),
(239, 'yusuf.meraba', 'YUSUF', 'MERABA', 'yusuf.meraba@medicalpark.com.tr', 9, 4, 18, 0),
(240, 'zehra.soylu', 'ZEHRA', 'SOYLU İNAN', 'zehra.soylu@medicalpark.com.tr', 46, 20, 23, 0),
(241, 'zekeriya.oguz', 'ZEKERİYA', 'OĞUZ', 'zekeriya.oguz@medicalpark.com.tr', 8, 4, 23, 0),
(242, 'zuhal.akin', 'ZÜHAL', 'AKIN', 'zuhal.akin@medicalpark.com.tr', 46, 20, 10, 0),
(243, 'zuhal.celebioglu', 'ZUHAL', 'ÇELEBİOĞLU', 'zuhal.celebioglu@isu.edu.tr', 16, 26, 22, 0),
(244, 'zuhrebihter.gokceker', 'ZÜHRE BİHTER', 'GARAGON', 'zuhrebihter.gokceker@medicalpark.com.tr', 11, 4, 14, 0);

-- --------------------------------------------------------

--
-- Görünüm yapısı `pending_request`
--
DROP TABLE IF EXISTS `pending_request`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pending_request`  AS SELECT `r`.`ID` AS `ID`, concat(`r`.`ID`,' - ',`u`.`NAME`,' ',`u`.`SURNAME`) AS `NAME` FROM ((`request` `r` join `request_approver_detail` `rad` on((`rad`.`REQUEST_ID` = `r`.`ID`))) join `user` `u` on((`u`.`ID` = `r`.`CREATOR_USER_ID`))) WHERE ((`rad`.`ACTIVE` = 1) AND (`rad`.`STATUS_ID` = 13)) ORDER BY `r`.`ID` ASC ;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `authorized_person_group`
--
ALTER TABLE `authorized_person_group`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `AUTHORIZED_PERSON_ID_USER_ID` (`AUTHORIZED_PERSON_ID`,`USER_ID`) USING BTREE,
  ADD KEY `FK_AUTHORIZED_PERSON_GROUP_USER_ID` (`USER_ID`),
  ADD KEY `FK_AUTHORIZED_PERSON_GROUP_AUTHORIZED_PERSON_ID` (`AUTHORIZED_PERSON_ID`);

--
-- Tablo için indeksler `authorized_person_relation`
--
ALTER TABLE `authorized_person_relation`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `USER_ID` (`USER_ID`,`AUTHORIZED_PERSON_ID`) USING BTREE,
  ADD UNIQUE KEY `POSITION_ID` (`POSITION_ID`,`LOCATION_ID`,`AUTHORIZED_PERSON_ID`) USING BTREE,
  ADD UNIQUE KEY `DEPARTMENT_ID` (`DEPARTMENT_ID`,`LOCATION_ID`,`AUTHORIZED_PERSON_ID`) USING BTREE,
  ADD KEY `FK_AUTHORIZED_PERSON_RELATION_LOCATION_ID` (`LOCATION_ID`),
  ADD KEY `FK_AUTHORIZED_PERSON_RELATION_AUTHORIZED_PERSON_ID` (`AUTHORIZED_PERSON_ID`),
  ADD KEY `FK_AUTHORIZED_PERSON_RELATION_ROUTE_ID` (`ROUTE_ID`);

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
  ADD KEY `FK_LOC_HOSPITAL_GROUP_ID` (`HOSPITAL_GROUP_ID`),
  ADD KEY `FK_LOC_COUNTY_ID` (`COUNTY_ID`);

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
  ADD UNIQUE KEY `UUID` (`UUID`),
  ADD KEY `FK_REQUEST_ROUTE_ID` (`ROUTE_ID`),
  ADD KEY `FK_REQUEST_FROM_COUNTRY_ID` (`FROM_COUNTRY_ID`),
  ADD KEY `FK_REQUEST_FROM_LOCATION_ID` (`FROM_LOCATION_ID`),
  ADD KEY `FK_REQUEST_FROM_CITY_ID` (`FROM_CITY_ID`),
  ADD KEY `FK_REQUEST_TO_COUNTRY_ID` (`TO_COUNTRY_ID`),
  ADD KEY `FK_REQUEST_TO_LOCATION_ID` (`TO_LOCATION_ID`),
  ADD KEY `FK_REQUEST_TO_CITY_ID` (`TO_CITY_ID`),
  ADD KEY `FK_REQUEST_REASON_ID` (`REASON_ID`),
  ADD KEY `FK_REQUEST_TO_TRANSPORTATION_MODE_ID` (`TRANSPORTATION_MODE_ID`),
  ADD KEY `FK_REQUEST_CREATOR_USER_ID` (`CREATOR_USER_ID`);

--
-- Tablo için indeksler `request_approver_detail`
--
ALTER TABLE `request_approver_detail`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `UUID` (`UUID`),
  ADD KEY `FK_REQUEST_APPROVER_DETAIL_REQUEST_ID` (`REQUEST_ID`),
  ADD KEY `FK_REQUEST_APPROVER_DETAIL_AUTHORIZED_PERSON_ID` (`AUTHORIZED_PERSON_ID`),
  ADD KEY `FK_REQUEST_APPROVER_DETAIL_STATUS_ID` (`STATUS_ID`),
  ADD KEY `FK_REQUEST_APPROVER_DETAIL_CREATOR_USER_ID` (`CREATOR_USER_ID`),
  ADD KEY `FK_REQUEST_APPROVER_DETAIL_MODIFIED_USER_ID` (`MODIFIED_USER_ID`) USING BTREE;

--
-- Tablo için indeksler `request_detail`
--
ALTER TABLE `request_detail`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_REQUEST_DETAIL_REQUEST_ID` (`REQUEST_ID`),
  ADD KEY `FK_REQUEST_DETAIL_TRAVELER_ID` (`TRAVELER_ID`);

--
-- Tablo için indeksler `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_RESERVATION_REQUEST_ID` (`REQUEST_ID`),
  ADD KEY `FK_RESERVATION_DEPARTURE_TRANSPORTATION_MODE_ID` (`DEPARTURE_TRANSPORTATION_MODE_ID`),
  ADD KEY `FK_RESERVATION_RETURN_TRANSPORTATION_MODE_ID` (`RETURN_TRANSPORTATION_MODE_ID`),
  ADD KEY `FK_RESERVATION_CREATOR_USER_ID` (`CREATOR_USER_ID`),
  ADD KEY `FK_RESERVATION_STATUS_ID` (`STATUS_ID`),
  ADD KEY `FK_RESERVATION_MODIFIED_USER_ID` (`MODIFIED_USER_ID`);

--
-- Tablo için indeksler `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`NAME`) USING BTREE;

--
-- Tablo için indeksler `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `NAME` (`ID`,`NAME`) USING BTREE;

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
  ADD KEY `FK_TRAVELER_LOCATION_ID` (`LOCATION_ID`),
  ADD KEY `FK_TRAVELER_CREATOR_USER_ID` (`CREATOR_USER_ID`);

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
  ADD KEY `FK_USER_POS_ID` (`POSITION_ID`),
  ADD KEY `AUTHORIZED_PERSON` (`AUTHORIZE_PERSON`);

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
-- Tablo için AUTO_INCREMENT değeri `authorized_person_group`
--
ALTER TABLE `authorized_person_group`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `authorized_person_relation`
--
ALTER TABLE `authorized_person_relation`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `city`
--
ALTER TABLE `city`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9003;

--
-- Tablo için AUTO_INCREMENT değeri `country`
--
ALTER TABLE `country`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1004;

--
-- Tablo için AUTO_INCREMENT değeri `county`
--
ALTER TABLE `county`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9003;

--
-- Tablo için AUTO_INCREMENT değeri `department`
--
ALTER TABLE `department`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- Tablo için AUTO_INCREMENT değeri `hospital_group`
--
ALTER TABLE `hospital_group`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `location`
--
ALTER TABLE `location`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Tablo için AUTO_INCREMENT değeri `log_login_record`
--
ALTER TABLE `log_login_record`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=368;

--
-- Tablo için AUTO_INCREMENT değeri `position`
--
ALTER TABLE `position`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- Tablo için AUTO_INCREMENT değeri `reason`
--
ALTER TABLE `reason`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Tablo için AUTO_INCREMENT değeri `request`
--
ALTER TABLE `request`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=171;

--
-- Tablo için AUTO_INCREMENT değeri `request_approver_detail`
--
ALTER TABLE `request_approver_detail`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- Tablo için AUTO_INCREMENT değeri `request_detail`
--
ALTER TABLE `request_detail`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164;

--
-- Tablo için AUTO_INCREMENT değeri `reservation`
--
ALTER TABLE `reservation`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Tablo için AUTO_INCREMENT değeri `route`
--
ALTER TABLE `route`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `status`
--
ALTER TABLE `status`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- Tablo için AUTO_INCREMENT değeri `transportation_company`
--
ALTER TABLE `transportation_company`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Tablo için AUTO_INCREMENT değeri `transportation_mode`
--
ALTER TABLE `transportation_mode`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Tablo için AUTO_INCREMENT değeri `traveler`
--
ALTER TABLE `traveler`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Tablo için AUTO_INCREMENT değeri `traveler_type`
--
ALTER TABLE `traveler_type`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `user`
--
ALTER TABLE `user`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1245;

--
-- Tablo için AUTO_INCREMENT değeri `user_backup`
--
ALTER TABLE `user_backup`
  MODIFY `ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1236;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `authorized_person_group`
--
ALTER TABLE `authorized_person_group`
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_GROUP_AUTHORIZED_PERSON_ID` FOREIGN KEY (`AUTHORIZED_PERSON_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_GROUP_USER_ID` FOREIGN KEY (`USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `authorized_person_relation`
--
ALTER TABLE `authorized_person_relation`
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_AUTHORIZED_PERSON_ID` FOREIGN KEY (`AUTHORIZED_PERSON_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_DEPARTMENT_ID` FOREIGN KEY (`DEPARTMENT_ID`) REFERENCES `department` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_LOCATION_ID` FOREIGN KEY (`LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_POSITION_ID` FOREIGN KEY (`POSITION_ID`) REFERENCES `position` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_ROUTE_ID` FOREIGN KEY (`ROUTE_ID`) REFERENCES `route` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_AUTHORIZED_PERSON_RELATION_USER_ID` FOREIGN KEY (`USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

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
  ADD CONSTRAINT `FK_LOC_COUNTY_ID` FOREIGN KEY (`COUNTY_ID`) REFERENCES `county` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
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
  ADD CONSTRAINT `FK_REQUEST_CREATOR_USER_ID` FOREIGN KEY (`CREATOR_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_FROM_CITY_ID` FOREIGN KEY (`FROM_CITY_ID`) REFERENCES `city` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_FROM_COUNTRY_ID` FOREIGN KEY (`FROM_COUNTRY_ID`) REFERENCES `country` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_FROM_LOCATION_ID` FOREIGN KEY (`FROM_LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_REASON_ID` FOREIGN KEY (`REASON_ID`) REFERENCES `reason` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_ROUTE_ID` FOREIGN KEY (`ROUTE_ID`) REFERENCES `route` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_CITY_ID` FOREIGN KEY (`TO_CITY_ID`) REFERENCES `city` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_COUNTRY_ID` FOREIGN KEY (`TO_COUNTRY_ID`) REFERENCES `country` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_LOCATION_ID` FOREIGN KEY (`TO_LOCATION_ID`) REFERENCES `location` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_TO_TRANSPORTATION_MODE_ID` FOREIGN KEY (`TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `request_approver_detail`
--
ALTER TABLE `request_approver_detail`
  ADD CONSTRAINT `FK_REQUEST_APPROVER_DETAIL_AUTHORIZED_PERSON_ID` FOREIGN KEY (`AUTHORIZED_PERSON_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_APPROVER_DETAIL_CREATOR_USER_ID` FOREIGN KEY (`CREATOR_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_APPROVER_DETAIL_MODIFIED_USER_ID` FOREIGN KEY (`MODIFIED_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_APPROVER_DETAIL_REQUEST_ID` FOREIGN KEY (`REQUEST_ID`) REFERENCES `request` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_APPROVER_DETAIL_STATUS_ID` FOREIGN KEY (`STATUS_ID`) REFERENCES `status` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `request_detail`
--
ALTER TABLE `request_detail`
  ADD CONSTRAINT `FK_REQUEST_DETAIL_REQUEST_ID` FOREIGN KEY (`REQUEST_ID`) REFERENCES `request` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_REQUEST_DETAIL_TRAVELER_ID` FOREIGN KEY (`TRAVELER_ID`) REFERENCES `traveler` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `FK_RESERVATION_CREATOR_USER_ID` FOREIGN KEY (`CREATOR_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_RESERVATION_DEPARTURE_TRANSPORTATION_MODE_ID` FOREIGN KEY (`DEPARTURE_TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_RESERVATION_MODIFIED_USER_ID` FOREIGN KEY (`MODIFIED_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_RESERVATION_REQUEST_ID` FOREIGN KEY (`REQUEST_ID`) REFERENCES `request` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_RESERVATION_RETURN_TRANSPORTATION_MODE_ID` FOREIGN KEY (`RETURN_TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_RESERVATION_STATUS_ID` FOREIGN KEY (`STATUS_ID`) REFERENCES `status` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `transportation_company`
--
ALTER TABLE `transportation_company`
  ADD CONSTRAINT `FK_TR_COM_TRANSPORTATION_MODE_ID` FOREIGN KEY (`TRANSPORTATION_MODE_ID`) REFERENCES `transportation_mode` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Tablo kısıtlamaları `traveler`
--
ALTER TABLE `traveler`
  ADD CONSTRAINT `FK_TRAVELER_CREATOR_USER_ID` FOREIGN KEY (`CREATOR_USER_ID`) REFERENCES `user` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
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
