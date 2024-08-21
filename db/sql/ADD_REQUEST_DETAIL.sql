CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_REQUEST_DETAIL`(IN `pRequestId` INT, IN `pTravelerId` INT, OUT `oRequestDetailId` INT)
BEGIN
  INSERT INTO `REQUEST_DETAIL`
  (`REQUEST_ID`, `TRAVELER_ID`)
  VALUES
  (`pRequestId`, `pTravelerId`);
  
  SELECT LAST_INSERT_ID() INTO `oRequestDetailId`;
END