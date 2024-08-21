CREATE DEFINER=`root`@`localhost` FUNCTION `GET_LOCATION_ID`(`pLocationName` VARCHAR(100), `pAdd` BOOL) RETURNS int
    DETERMINISTIC
BEGIN
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
END