CREATE DEFINER=`root`@`localhost` PROCEDURE `LOG_LOGIN_ACTIVITY`(IN `pUserId` INT, OUT `oResult` BOOL)
BEGIN
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
END