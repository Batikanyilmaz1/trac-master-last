CREATE DEFINER=`root`@`localhost` PROCEDURE `HANDLE_USER_LOGIN`(IN `pUsername` VARCHAR(50), IN `pName` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pMail` VARCHAR(100),
                                                                IN `pPositionName` VARCHAR(100), IN `pDepartmentName` VARCHAR(100), IN `pLocationName` VARCHAR(100), OUT `oUserId` INT)
BEGIN
  DECLARE `vPositionId`, `vDepartmentId`, `vLocationId`, `vtUserId`, `vtPositionId`, `vtDepartmentId`, `vtLocationId` INT DEFAULT 0;
  DECLARE `vtName`, `vtSurname` Varchar(50) DEFAULT '';
  DECLARE `vtMail` VARCHAR(100) DEFAULT '';
  
  SELECT GET_POSITION_ID(`pPositionName`, 1) INTO `vPositionId`;
  SELECT GET_DEPARTMENT_ID(`pDepartmentName`, 1) INTO `vDepartmentId`;
  SELECT GET_LOCATION_ID(`pLocationName`, 1) INTO `vLocationId`;
  
  SELECT `ID`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`
	INTO `vtUserId`, `vtName`, `vtSurname`, `vtMail`, `vtPositionId`, `vtDepartmentId`, `vtLocationId`
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
  ELSE
    INSERT INTO `USER`
    (`USERNAME`, `NAME`, `SURNAME`, `EMAIL`, `POSITION_ID`, `DEPARTMENT_ID`, `LOCATION_ID`)
    VALUES
    (`pUsername`, `pName`, `pSurname`, `pMail`, `vPositionId`, `vDepartmentId`, `vLocationId`);
    
    SELECT LAST_INSERT_ID() INTO `oUserId`;
  END IF;
END