CREATE DEFINER=`root`@`localhost` PROCEDURE `ADD_REQUEST`(IN `pUserId` INT, IN `pRouteId` INT, IN `ReasonId` INT, IN `pFromCountryId` INT, IN `pFromLocationId` INT, IN `pFromCityId` INT,
                                                          IN `pFromCityName` VARCHAR(50), IN `pToCountryId` INT, IN `pToLocationId` INT, IN `pToCityId` INT, IN `pToCityName` VARCHAR(50),
                                                          IN `ptransportation` BOOLEAN, IN `pDepartureDate` DATE, IN `pReturnDate` DATE, IN `pTransferNeedSituation` INT,
                                                          IN `pTransferNeedDetail` TEXT, IN `pTransportationModeId` INT, IN `pTransportationDetail` TEXT, IN `pAccommodation` BOOLEAN,
                                                          IN `pCheckInDate` DATE, IN `pCheckOutDate` DATE, IN `pAccommodationDetail` TEXT, OUT `oRequestId` INT)
BEGIN
  INSERT INTO `REQUEST`
  (`CUSER_ID`, `ROUTE_ID`, `REASON_ID`, `FROM_COUNTRY_ID`, `FROM_LOCATION_ID`, `FROM_CITY_ID`, `FROM_CITY_NAME`, `TO_COUNTRY_ID`, `TO_LOCATION_ID`, `TO_CITY_ID`, `TO_CITY_NAME`,
   `TRANSPORTATION`, `DEPARTURE_DATE`, `RETURN_DATE`, `TRANSFER_NEED_SITUATION`, `TRANSFER_NEED_DETAIL`, `TRANSPORTATION_MODE_ID`, `TRANSPORTATION_DETAIL`, `ACCOMMODATION`,
   `CHECK-IN_DATE`, `CHECK-OUT_DATE`, `ACCOMMODATION_DETAIL`)
  VALUES
  (`pUserId`, `pRouteId`, `ReasonId`, `pFromCountryId`, `pFromLocationId`, `pFromCityId`, `pFromCityName`, `pToCountryId`, `pToLocationId`, `pToCityId`, `pToCityName`,
   `ptransportation`, `pDepartureDate`, `pReturnDate`, `pTransferNeedSituation`, `pTransferNeedDetail`, `pTransportationModeId`, `pTransportationDetail`,
   `pAccommodation`, `pCheckInDate`, `pCheckOutDate`, `pAccommodationDetail`);
  
  SELECT LAST_INSERT_ID() INTO `oRequestId`;
END