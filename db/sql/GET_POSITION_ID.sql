CREATE DEFINER=`root`@`localhost` FUNCTION `GET_POSITION_ID`(`pPositionName` VARCHAR(100), `pAdd` BOOL) RETURNS int
    DETERMINISTIC
BEGIN
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
END