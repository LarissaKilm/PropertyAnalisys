--Given suburb and city, display median rental value
--  and value changes of the property within 1 km radius
USE [PropertyAnalysisDW];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE stpRentalValueChanges1kmRadius @City   NVARCHAR(30) = ' ', 
                                               @Suburb NVARCHAR(30) = ' '
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @geoKey INT;
        DECLARE @message VARCHAR(50)= 'No Matching City and/or Suburb found';
        DECLARE @RADIUS INT= 1;
        DECLARE @LAT VARCHAR(30)= '';
        DECLARE @LONG VARCHAR(30)= '';
        DECLARE @GEO1 GEOGRAPHY= NULL;
        --getting GeographyKey returned by function 
        SET @geoKey =
        (
            SELECT GeographyKey
            FROM [dbo].[Fact_SuburbRentalMedian]
            WHERE City = @City
                  AND Suburb = @Suburb
        );
        IF(@geoKey IS NOT NULL)
            BEGIN 
                --SELECT @message1;
                SET @LAT =
                (
                    SELECT Lat
                    FROM [dbo].[DimGeography]
                    WHERE [dbo].[DimGeography].GeographyKey = @geoKey
                );
                SET @LONG =
                (
                    SELECT Long
                    FROM [dbo].[DimGeography]
                    WHERE [dbo].[DimGeography].GeographyKey = @geoKey
                );
                SET @geo1 = geography ::Point(@LAT, @LONG, 4326);
                SELECT [dbo].[Fact_SuburbRentalMedian].RentMedianValue, 
                       [dbo].[Fact_SuburbRentalMedian].City, 
                       [dbo].[Fact_SuburbRentalMedian].Suburb, 
                       LEFT(CONVERT(VARCHAR, (@geo1.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000), 5) + ' Km' AS DISTANCE
                FROM [dbo].[Fact_SuburbRentalMedian]
                     JOIN [dbo].[DimGeography] ON [dbo].[Fact_SuburbRentalMedian].GeographyKey = [dbo].[DimGeography].GeographyKey
                WHERE(@geo1.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000 < @RADIUS
                ORDER BY DISTANCE ASC;
        END;
            ELSE --IF (@geoKey is null) 
            BEGIN
                SET @geoKey = 0;
                SELECT @message;
        END;
    END;
GO
EXECUTE [dbo].[stpRentalValueChanges1kmRadius] 'Sydney', 'St Leonards';

--*********************************************************************
--TASK 16 Given suburb and city, display local public transport within 1km radius - update data sets
USE [PropertyAnalysisDW];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE stpGetPublicTransport @city   NVARCHAR(30) = ' ', 
                                      @suburb NVARCHAR(30) = ' '
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @geo GEOGRAPHY= NULL;
        DECLARE @geokey INT= 0;
        DECLARE @message VARCHAR(50)= 'No Matching City and/or Suburb found';
        DECLARE @radius INT= 0;
        DECLARE @Lat NVARCHAR(15)= '';
        DECLARE @Long NVARCHAR(15)= '';
        DECLARE @message1 VARCHAR(50)= 'Public Transpost near ' + @city + ' ' + @suburb;
        SET @radius = 1;
        SET @geoKey =
        (
            SELECT GeographyKey
            FROM [dbo].[DimGeography]
            WHERE City = @city
                  AND Suburb = @suburb
        );
        IF(@geoKey IS NOT NULL)
            BEGIN
                SET @Lat =
                (
                    SELECT Lat
                    FROM [dbo].[DimGeography]
                    WHERE GeographyKey = @geoKey
                );
                SET @Long =
                (
                    SELECT Long
                    FROM [dbo].[DimGeography]
                    WHERE GeographyKey = @geoKey
                );
                SET @geo = geography ::Point(@Lat, @Long, 4326);
                SELECT [StopName], 
                       [Mode], 
                       LEFT(CONVERT(VARCHAR, (@geo.STDistance(geography::Point(ISNULL(Lat, 0), ISNULL(Long, 0), 4326))) / 1000), 5) + ' Km' AS DISTANCE
                FROM [dbo].[DimTransport]
                WHERE(@geo.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000 < @RADIUS
                ORDER BY DISTANCE ASC;
        END;
            ELSE
            SELECT @message;
    END;
GO
-------------
EXECUTE [dbo].[stpGetPublicTransport] 'Sydney',  'St Leonards';

--*********************************************************************
--Given suburb and city, display local schools within 1km radius
USE [PropertyAnalysisDW];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE stpGetPublicSchools @city   NVARCHAR(30) = ' ', 
                                    @suburb NVARCHAR(30) = ' '
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @geo1 GEOGRAPHY= NULL;
        DECLARE @RADIUS INT= 0;
        DECLARE @Lat NVARCHAR(15)= '';
        DECLARE @Long NVARCHAR(15)= '';
        DECLARE @geoKeyExist INT= 0;
        DECLARE @message VARCHAR(50)= 'No Matching City and/or Suburb found';
        SET @RADIUS = 1;
        SET @City = @city;
        SET @Suburb = @suburb;
        SET @geoKeyExist =
        (
            SELECT GeographyKey
            FROM [dbo].[DimGeography]
            WHERE City = @City
                  AND Suburb = @Suburb
        );
        IF(@geoKeyExist IS NOT NULL)
            BEGIN
                SET @Lat =
                (
                    SELECT Lat
                    FROM [dbo].[DimGeography]
                    WHERE City = @City
                          AND Suburb = @Suburb
                );
                SET @Long =
                (
                    SELECT Long
                    FROM [dbo].[DimGeography]
                    WHERE City = @City
                          AND Suburb = @Suburb
                );
                SET @geo1 = geography ::Point(@LAT, @LONG, 4326);
                SELECT TOP 10 SchoolKey, 
                              SchoolName, 
                              [SchoolType], 
                              LEFT(CONVERT(VARCHAR, (@geo1.STDistance(geography::Point(ISNULL(Lat, 0), ISNULL(Long, 0), 4326))) / 1000), 5) + ' Km' AS DISTANCE
                FROM [dbo].[DimAuLocalSchool]
                WHERE(@geo1.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000 < @RADIUS
                ORDER BY DISTANCE ASC;
        END;
            ELSE --IF (@geoKey is null) 
            BEGIN
                SELECT @message;
        END;
    END;
GO
--------
EXECUTE [dbo].[stpGetPublicSchools] 'Sydney', 'St Leonards';
--*********************************************************************
--Given suburb and city, display crime rate within 1 km radius
USE [PropertyAnalysisDW];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE GetCrimeRate @city   NVARCHAR(30) = '', 
                             @suburb NVARCHAR(30) = ' '
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @geo GEOGRAPHY= NULL;
        DECLARE @radius INT= 0;
        DECLARE @Lat NVARCHAR(15)= '';
        DECLARE @Long NVARCHAR(15)= '';
        DECLARE @crimeRate FLOAT= 0;
        DECLARE @geoKey INT= 0;
        DECLARE @message VARCHAR(50)= 'No Matching City and/or Suburb found';
        SET @radius = 1;
        SET @geoKey =
        (
            SELECT GeographyKey
            FROM [dbo].[DimGeography]
            WHERE City = @City
                  AND Suburb = @Suburb
        );
        IF(@geoKey IS NOT NULL)
            BEGIN
                SET @Lat =
                (
                    SELECT Lat
                    FROM [dbo].[DimGeography]
                    WHERE GeographyKey = @geoKey
                );
                SET @Long =
                (
                    SELECT Long
                    FROM [dbo].[DimGeography]
                    WHERE GeographyKey = @geoKey
                );
                SET @geo = geography ::Point(@LAT, @LONG, 4326);
                SET @crimeRate =
                (
                    SELECT CrimeRate
                    FROM [dbo].[Fact_SuburbPopulation]
                    WHERE GeographyKey = @geoKey
                );
                SELECT g.City, 
                       g.Suburb, 
                       fsp.[CrimeRate], 
                       LEFT(CONVERT(VARCHAR, (@geo.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000), 5) + ' Km' AS DISTANCE
                FROM [dbo].[Fact_SuburbPopulation] AS fsp
                     JOIN [dbo].[DimGeography] AS g ON fsp.GeographyKey = g.GeographyKey
                WHERE(@geo.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000 < @radius
                ORDER BY DISTANCE ASC;
        END;
            ELSE --IF (@geoKey is null) 
            BEGIN
                SELECT @message;
        END;
    END;
GO
--------
EXECUTE [dbo].[GetCrimeRate] 'Sydney', 'St Leonards';

--*********************************************************************
--Given suburb and city, display property value of the area 
--in Column chart and line chart of 1 year, 5 years and 10 years value

USE [PropertyAnalysisDW];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE PropertyValueChange1yr5yr10yr @city   NVARCHAR(30) = ' ', 
                                              @suburb NVARCHAR(30) = ' '
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @geo GEOGRAPHY= NULL;
        DECLARE @radius INT= 0;
        DECLARE @Lat NVARCHAR(15)= '';
        DECLARE @Long NVARCHAR(15)= '';
        DECLARE @geoKey INT= 0;
        DECLARE @message VARCHAR(50)= 'No Matching City and/or Suburb found';
        SET @radius = 1;
        SET @geoKey =
        (
            SELECT GeographyKey
            FROM [dbo].[DimGeography]
            WHERE City = @City
                  AND Suburb = @Suburb
        );
        IF(@geoKey IS NOT NULL)
            BEGIN
                SET @Lat =
                (
                    SELECT Lat
                    FROM [dbo].[DimGeography]
                    WHERE City = @city
                          AND Suburb = @suburb
                );
                SET @Long =
                (
                    SELECT Long
                    FROM [dbo].[DimGeography]
                    WHERE City = @city
                          AND Suburb = @suburb
                );
                SET @geo = geography ::Point(@LAT, @LONG, 4326);
                SELECT replace(CONVERT(VARCHAR, CAST(FLOOR(((pv.[MedianValue] * 0.03) * 1 + pv.MedianValue)) AS MONEY), 1), '.00', '') AS ValueIn1Year, 
                       replace(CONVERT(VARCHAR, CAST(FLOOR(((pv.MedianValue * 0.03) * 5 + pv.MedianValue)) AS MONEY), 1), '.00', '') AS ValueIn5Year, 
                       replace(CONVERT(VARCHAR, CAST(FLOOR(((pv.MedianValue * 0.03) * 10 + pv.MedianValue)) AS MONEY), 1), '.00', '') AS ValueIn10Year, 
                       pv.City, 
                       pv.Suburb, 
                       LEFT(CONVERT(VARCHAR, (@geo.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000), 5) + ' Km' AS DISTANCE
                FROM [dbo].[PropertyMedianValue] AS pv
                     JOIN [dbo].[DimGeography] AS g ON pv.GeographyKey = g.GeographyKey
                WHERE(@geo.STDistance(geography::Point(ISNULL(LAT, 0), ISNULL(LONG, 0), 4326))) / 1000 < @radius
                AND pv.Dates = 2017
                ORDER BY DISTANCE;
        END;
            ELSE --IF (@geoKey is null) 
            BEGIN
                SELECT @message;
        END;
    END;
GO
----------------------------------
EXECUTE [dbo].[PropertyValueChange1yr5yr10yr]  'Sydney',  'St Leonards';
