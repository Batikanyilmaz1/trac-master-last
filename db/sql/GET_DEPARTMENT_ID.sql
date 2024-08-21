CREATE DEFINER=`root`@`localhost` FUNCTION `GET_DEPARTMENT_ID`(`pDepartmentName` VARCHAR(100), `pAdd` BOOL) RETURNS int
    DETERMINISTIC
BEGIN
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
END