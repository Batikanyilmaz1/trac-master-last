CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_TRAVELER`(IN `pTypeId` INT, IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pBirthDate` DATE, IN `pIdentityNo` BIGINT,
                                                           IN `pPassportNo` BIGINT, IN `pPhone` VARCHAR(20), IN `pMail` VARCHAR(100), IN `pPositionName` VARCHAR(100), IN `pPositionId` INT,
                                                           IN `pDepartmentName` VARCHAR(100), IN `pDepartmentId` INT, IN `pLocationName` VARCHAR(100), IN `pLocationId` INT, OUT `oTravelerId` INT)
BEGIN
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
    (`TYPE_ID`, `NAME`, `SURNAME`, `BIRTH_DATE`, `IDENTITY_NO`, `PASSPORT_NO`, `PHONE`, `EMAIL`, `USER_ID`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`)
    VALUES
    (`pTypeId`, `pName`, `pSurname`, `pBirthDate`, `pIdentityNo`, `pPassportNo`, `pPhone`, `pMail`, `vUserId`, `vPositionId`, `vDepartmentId`, `vLocationId`);
    
    SELECT LAST_INSERT_ID() INTO `oTravelerId`;
  END IF;
END