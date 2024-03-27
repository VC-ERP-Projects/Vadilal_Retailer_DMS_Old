ALTER PROCEDURE [dbo].[GetClaimDetail] (@ParentID AS DECIMAL(18, 0), @FromDate AS DATETIME, @ToDate AS DATETIME, @CustType AS INT)
AS
--DECLARE @ParentID AS DECIMAL(18, 0) = 2000010000100000, @FromDate AS DATETIME = '20160602', @ToDate AS DATETIME = '20161114', @CustType AS INT = 1
BEGIN
	IF (@CustType = 1)
	BEGIN
		SELECT T0.ParentID, '' AS ClaimDate, T0.SchemeType, T0.CustomerID, T1.CustomerCode AS DistributorCode, T1.CustomerName AS DistributorName, T2.CustomerCode AS DealerCode, T2.CustomerName AS DealerName, SUM(T0.TotalQty) AS TotalQty, SUM(T0.SchemeAmount) AS SchemeAmount, T0.SchemeID, '' AS ItemName, '0' AS ItemID
		FROM OCLM T0
		INNER JOIN OCRD T1 ON T1.CustomerID = T0.ParentID
		INNER JOIN OCRD T2 ON T2.CustomerID = T0.CustomerID
		WHERE CONVERT(DATE, T0.DATE) >= @FromDate AND CONVERT(DATE, T0.DATE) <= @ToDate AND T0.STATUS = 1 AND (T0.SAPDocNo = '' OR T0.SAPDocNo IS NULL) AND T0.SchemeType = 'M' AND (@ParentID = '0' OR T0.ParentID = @ParentID)
		GROUP BY T0.ParentID, T0.SchemeType, T0.CustomerID, T0.SchemeID, T0.ItemID, T1.CustomerCode, T1.CustomerName, T2.CustomerCode, T2.CustomerName
		
		UNION ALL
		
		SELECT T0.ParentID, '' AS ClaimDate, T0.SchemeType, T0.CustomerID, '' AS DistributorCode, '' AS DistributorName, '' AS DealerCode, '' AS DealerName, SUM(T0.TotalQty) AS TotalQty, SUM(T0.SchemeAmount) AS SchemeAmount, T0.SchemeID, T1.ItemName AS ItemName, T1.ItemID AS ItemID
		FROM OCLM T0
		INNER JOIN OITM T1 ON T1.ItemID = T0.ItemID
		WHERE CONVERT(DATE, T0.DATE) >= @FromDate AND CONVERT(DATE, T0.DATE) <= @ToDate AND T0.STATUS = 1 AND (T0.SAPDocNo = '' OR T0.SAPDocNo IS NULL) AND T0.SchemeType = 'Q' AND (@ParentID = '0' OR T0.ParentID = @ParentID)
		GROUP BY T0.ParentID, T0.SchemeType, T0.CustomerID, T0.SchemeID, T1.ItemID, T1.ItemName
	END
	ELSE
	BEGIN
		SELECT M.ParentID, M.DistributorCode, M.DistributorName, M.CustomerID, M.DealerCode, M.DealerName, M.ClaimDate, M.SchemeType, M.SchemeID, M.ItemID, M.ItemName, M.TotalQty, M.SchemeAmount
		FROM (
			---------MASTER SCHEME
			SELECT A.ParentID, A.DistributorCode, A.DistributorName, A.CustomerID, A.DealerCode, A.DealerName, A.ClaimDate, 'M' AS SchemeType, A.SchemeID, ISNULL(A.ItemID, '') AS 'ItemID', '' AS 'ItemName', '0' AS 'TotalQty', SUM(A.CompanyDisc) AS 'SchemeAmount'
			FROM (
				SELECT T0.ParentID, T3.CustomerCode AS 'DistributorCode', T3.CustomerName AS 'DistributorName', T0.CustomerID, T5.CustomerCode AS 'DealerCode', T5.CustomerName AS 'DealerName', T4.SchemeID, convert(VARCHAR, T0.[Date], 103) AS 'ClaimDate', IsNull((
							SELECT (
									(
										SUM(IsNull(TA.SubTotal, 0)) * CASE WHEN ISNULL(T0.ContraTax, '0') = '0' THEN '0' ELSE ISNULL((
														SELECT items
														FROM dbo.Split(T0.ContraTax, ',')
														WHERE tempid = 2
														), 0) END
										) / 100
									)
							FROM POS1 TA
							WHERE TA.SaleID = T0.SaleID AND TA.ParentID = T0.ParentID AND TA.AddOn = 0
							), 0) AS 'CompanyDisc', (
						SELECT TOP 1 ReasonID
						FROM ORSN
						WHERE ReasonID = T4.ReasonID AND [TYPE] = 'S'
						) AS 'ItemID'
				FROM OPOS T0
				LEFT JOIN OCRD T3 ON T3.CustomerID = T0.ParentID
				LEFT JOIN OCRD T5 ON T5.CustomerID = T0.CustomerID
				LEFT JOIN OSCM T4 ON T4.SchemeID IN (
						SELECT items
						FROM dbo.Split_New(T0.SchemeID, ',')
						)
				WHERE T0.ParentID = @ParentID AND CONVERT(DATE, DATE) >= @FromDate AND CONVERT(DATE, DATE) <= @ToDate AND T0.ContraTax IS NOT NULL AND T4.ApplicableMode = 'M'
				GROUP BY T0.CustomerID, T0.[Date], T0.ParentID, T3.CustomerCode, T5.CustomerCode, T5.CustomerName, T3.CustomerName, T0.SaleID, T0.ContraTax, T4.EndDate, T4.SchemeName, T4.SchemeID, T4.ReasonID
				) A
			GROUP BY A.ParentID, A.ClaimDate, A.SchemeID, A.CustomerID, A.DistributorCode, A.DealerCode, A.ItemID, A.DistributorName, A.DealerName
			
			UNION ALL
			
			--------- QPS SCHEME
			SELECT A.ParentID, A.DistributorCode, A.DistributorName, '0' AS 'CustomerID', '0' AS 'DealerCode', '' AS 'DealerName', A.ClaimDate, 'Q' AS SchemeType, A.SchemeID, A.ItemID, A.ItemName, SUM(A.TotalQty) AS 'TotalQty', SUM(A.SchemeValue) AS 'SchemeAmount'
			FROM (
				SELECT T0.ParentID, T3.CustomerCode AS 'DistributorCode', T3.CustomerName AS 'DistributorName', CONVERT(VARCHAR, T0.[Date], 103) AS 'ClaimDate', T1.SchemeID, T1.ItemID, T5.ItemName AS 'ItemName', ISNULL(SUM(T1.TotalQty), 0) AS 'TotalQty', ISNULL(SUM((T1.UnitPrice + T1.PriceTax) * T1.TotalQty), 0) AS 'SchemeValue'
				FROM OPOS T0
				LEFT JOIN POS1 T1 ON T0.SaleID = T1.SaleID AND T0.ParentID = T1.ParentID
				LEFT JOIN OCRD T3 ON T3.CustomerID = T0.ParentID
				LEFT JOIN OSCM T4 ON T4.SchemeID = T1.SchemeID
				LEFT JOIN OITM T5 ON t5.ItemID = T1.ItemID
				WHERE T0.ParentID = @ParentID AND CONVERT(DATE, T0.[Date]) >= @FromDate AND CONVERT(DATE, T0.[Date]) <= @ToDate AND T1.IsDeleted = 0 AND T1.SchemeID IS NOT NULL AND T4.ApplicableMode = 'S'
				GROUP BY T0.ParentID, T3.CustomerCode, T3.CustomerName, T0.[Date], T1.SchemeID, T1.ItemID, T5.ItemName
				) A
			GROUP BY A.ParentID, A.DistributorCode, A.DistributorName, A.ClaimDate, A.SchemeID, A.ItemID, A.ItemName
			) M
		ORDER BY M.SchemeType, M.ClaimDate
	END
END
GO

CREATE PROCEDURE [dbo].[TotalSalesMonthWise] @ParentID AS NVARCHAR(MAX), @Type AS NVARCHAR(1), @ItemGroupID AS NVARCHAR(10), @Year AS NVARCHAR(4)
AS
BEGIN
	DECLARE @Query AS NVARCHAR(MAX)
	DECLARE @Cols AS NVARCHAR(MAX)
	DECLARE @IsNullCols AS NVARCHAR(MAX)
	DECLARE @GrandTotalCol NVARCHAR(MAX)
	DECLARE @GrandTotalRow NVARCHAR(MAX)

	--SET @ParentID='1000010000000000' 
	--SET @Type = '1'
	--SET @ItemGroupID = '0'
	--SET @Year = '2016'
	SELECT @Cols = (
			SELECT 'January' + ',' + 'February' + ',' + 'March' + ',' + 'April' + ',' + 'May' + ',' + 'June' + ',' + 'July' + ',' + 'August' + ',' + 'September' + ',' + 'October' + ',' + 'November' + ',' + 'December'
			)

	SELECT @IsNullCols = STUFF((
				SELECT ',' + ('IsNull([' + 'January' + '],0)') + ' as [' + 'January' + ']' + ',' + ('IsNull([' + 'February' + '],0)') + ' as [' + 'February' + ']' + ',' + ('IsNull([' + 'March' + '],0)') + ' as [' + 'March' + ']' + ',' + ('IsNull([' + 'April' + '],0)') + ' as [' + 'April' + ']' + ',' + ('IsNull([' + 'May' + '],0)') + ' as [' + 'May' + ']' + ',' + ('IsNull([' + 'June' + '],0)') + ' as [' + 'June' + ']' + ',' + ('IsNull([' + 'July' + '],0)') + ' as [' + 'July' + ']' + ',' + ('IsNull([' + 'August' + '],0)') + ' as [' + 'August' + ']' + ',' + ('IsNull([' + 'September' + '],0)') + ' as [' + 'September' + ']' + ',' + ('IsNull([' + 'October' + '],0)') + ' as [' + 'October' + ']' + ',' + ('IsNull([' + 'November' + '],0)') + ' as [' + 'November' + ']' + ',' + ('IsNull([' + 'December' + '],0)') + ' as [' + 'December' + ']'
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	SELECT @GrandTotalCol = STUFF((
				SELECT '+' + 'ISNULL(' + QUOTENAME('January') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('February') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('March') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('April') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('May') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('June') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('July') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('August') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('September') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('October') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('November') + ',0)' + '+' + 'ISNULL(' + QUOTENAME('December') + ',0)'
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	SELECT @GrandTotalRow = STUFF((
				SELECT ',' + 'ISNULL(SUM(' + QUOTENAME('January') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('February') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('March') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('April') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('May') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('June') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('July') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('August') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('September') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('October') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('November') + '),0)' + ',' + 'ISNULL(SUM(' + QUOTENAME('December') + '),0)'
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	SET @query = N'with Info as(SELECT CustomerCode,CustomerName,' + @IsNullCols + ',' + @GrandTotalCol + ' as TOTAL from   
(
  SelecT B.CustomerCode,B.CustomerName,DATENAME(M,A.[Date]) as ''SaleMonth'',SUM(A.Total) as ''Total'' 
  From OPOS A Left Outer Join OCRD B on A.CustomerID = B.CustomerID
  Group by B.CustomerCode,B.CustomerName,DATENAME(M,A.[Date])
) X  
PIVOT
(
  SUM(Total)
  FOR SaleMonth
  IN (' + @Cols + ')
) P)

Select * from Info
UNION All
Select ''TOTAL'' As CustomerCode,''Amount'' as CustomerName,' + @GrandTotalRow + ',ISNULL(SUM([TOTAL]),0) From Info'

	--print @Query
	EXEC sp_executesql @Query
END
GO

ALTER PROCEDURE [dbo].[SchemeReport] @Type VARCHAR(255), @RegionID VARCHAR(255), @PlantID VARCHAR(255), @CustomerID VARCHAR(255), @Active VARCHAR(255)
AS
BEGIN
	SELECT ISNULL(T4.CustomerCode, '') AS 'DIST. CODE', ISNULL(T4.CustomerName, '') AS 'DIST. NAME', ISNULL(T3.CustomerCode, '') AS 'DEALER CODE', ISNULL(T3.CustomerName, '') AS 'DEALER NAME', T0.SchemeCode, T0.SchemeName, CONVERT(NUMERIC(18, 2), T2.CompanyDisc) AS 'COMP DISCOUNT(%)', Convert(NUMERIC(18, 2), T2.DistributorDisc) AS 'DISTR DISCOUNT(%)', T2.HigherLimit AS 'EXPECTED SALE', Convert(VARCHAR, T0.StartDate, 103) AS 'STARTDATE', Convert(VARCHAR, T0.EndDate, 103) AS 'ENDDATE'
	FROM OSCM T0
	LEFT JOIN SCM1 T1 ON T1.SchemeID = T0.SchemeID
	LEFT JOIN SCM4 T2 ON T2.SchemeID = T0.SchemeID
	LEFT JOIN OCRD T3 ON T3.CustomerID = T1.CustomerID AND T3.[Type] = 3
	INNER JOIN OCRD T4 ON T4.CustomerID = T3.ParentID
	WHERE (T0.ApplicableMode = @Type) AND (@RegionID = '0' OR T1.RegionID = @RegionID) AND (@PlantID = 0 OR T1.PlantID = @PlantID) AND T0.Active = @Active AND (
			@CustomerID = '0' OR (
				SELECT CustomerID
				FROM SCM1
				WHERE CustomerID = @CustomerID AND SchemeID = T0.SchemeID
				) = @CustomerID
			)
END
GO

ALTER PROCEDURE [dbo].[CheckSCM3] (@ItemID AS INT, @SchemeID AS INT)
AS
BEGIN
	DECLARE @ItemGroupID AS INT
	DECLARE @ItemSubGroupID AS INT
	DECLARE @SCM2ItemID AS INT
	DECLARE @CTSCM2EX AS INT
	DECLARE @DivisionID AS INT

	--Declare
	--@ItemID as int = 150,
	--@SchemeID as int = 2
	SET @ItemSubGroupID = IsNull((
				SELECT SubGroupID
				FROM OITM
				WHERE ItemID = @ItemID
				), 0)
	SET @ItemGroupID = IsNull((
				SELECT GroupID
				FROM OITM
				WHERE ItemID = @ItemID
				), 0)
	SET @SCM2ItemID = IsNull((
				SELECT Count(ItemID)
				FROM SCM3
				WHERE ItemID = @ItemID AND IsInclude = 0 AND SchemeID = @SchemeID
				), 0)
	SET @CTSCM2EX = IsNull((
				SELECT Count(SCM3ID)
				FROM SCM3
				WHERE IsInclude = 1 AND SchemeID = @SchemeID
				), 0)
	SET @DivisionID = IsNull((
				SELECT TOP (1) DivisionlID
				FROM OGITM
				WHERE ItemID = @ItemID
				), 0)

	IF (@CTSCM2EX > 0)
	BEGIN
		IF IsNull((
					SELECT COUNT(T0.ItemID)
					FROM SCM3 T0
					WHERE T0.ItemID = @ItemID AND T0.IsInclude = 1 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 1 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.ItemSubGroupID)
					FROM SCM3 T0
					WHERE T0.ItemSubGroupID = @ItemSubGroupID AND T0.IsInclude = 1 AND @SCM2ItemID = 0 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 1 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.ItemGroupID)
					FROM SCM3 T0
					WHERE T0.ItemGroupID = @ItemGroupID AND T0.IsInclude = 1 AND @SCM2ItemID = 0 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 1 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.DivisionID)
					FROM SCM3 T0
					WHERE T0.DivisionID = @DivisionID AND T0.IsInclude = 1 AND T0.SchemeID = @SchemeID
					), 0) > 0
		BEGIN
			SELECT 1 AS 'STATUS'
		END
		ELSE
		BEGIN
			SELECT 0 AS 'STATUS'
		END
	END
	ELSE
	BEGIN
		IF IsNull((
					SELECT COUNT(T0.ItemID)
					FROM SCM3 T0
					WHERE T0.ItemID = @ItemID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 0 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.ItemSubGroupID)
					FROM SCM3 T0
					WHERE T0.ItemSubGroupID = @ItemSubGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 0 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.ItemGroupID)
					FROM SCM3 T0
					WHERE T0.ItemGroupID = @ItemGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (@DivisionID = '0' OR T0.DivisionID = @DivisionID)
					), 0) > 0
		BEGIN
			SELECT 0 AS 'STATUS'
		END
		ELSE IF IsNull((
					SELECT COUNT(T0.DivisionID)
					FROM SCM3 T0
					WHERE T0.DivisionID = @DivisionID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID
					), 0) > 0
		BEGIN
			SELECT 0 AS 'STATUS'
		END
		ELSE
		BEGIN
			SELECT 1 AS 'STATUS'
		END
	END
END
GO

ALTER PROCEDURE [dbo].[CheckSCM1] (@CustID DECIMAL(18, 0), @SchemeID INT)
AS
--DECLARE @CustID DECIMAL(18, 0) = 3000330000100001, @SchemeID INT = 8
BEGIN
	DECLARE @Value BIT = 0
	DECLARE @StateID INT
	DECLARE @PlantID INT
	DECLARE @Type INT
	DECLARE @ParentID DECIMAL(18, 0)

	SELECT @Type = Type, @ParentID = ParentID
	FROM OCRD
	WHERE CustomerID = @CustID

	SELECT TOP 1 @PlantID = PlantID
	FROM OGCRD
	WHERE CustomerID = @CustID

	SELECT @StateID = StateID
	FROM OPLT
	WHERE PlantID = @PlantID

	PRINT @StateID
	PRINT @PlantID
	PRINT @Type
	PRINT @ParentID
	PRINT @CustID

	IF (
			SELECT count(*)
			FROM SCM1
			WHERE SCHemeid = @SchemeID
			) = 0
		SET @Value = 1
	ELSE IF EXISTS (
			SELECT *
			FROM SCM1
			WHERE SchemeID = @SchemeID AND CustomerID = @CustID AND Type = @Type
			)
		SET @Value = 1
	ELSE IF EXISTS (
			SELECT *
			FROM SCM1
			WHERE SchemeID = @SchemeID AND CustomerID = @ParentID AND Type = (@Type - 1)
			)
		SET @Value = 1
	ELSE IF EXISTS (
			SELECT *
			FROM SCM1
			WHERE SchemeID = @SchemeID AND PlantID = @PlantID
			)
		SET @Value = 1
	ELSE IF EXISTS (
			SELECT *
			FROM SCM1
			WHERE SchemeID = @SchemeID AND RegionID = @StateID
			)
		SET @Value = 1
	ELSE
		SET @Value = 0

	SELECT @Value
END
GO

CREATE PROCEDURE [dbo].[GetTopItems] (@DivisionID INT, @ParentID DECIMAL(18, 0), @WhsID INT)
AS
BEGIN
	--DECLARE @DivisionID INT = 3
	--DECLARE @ParentID DECIMAL(18, 0) = 2000010000100000
	--DECLARE @WhsID INT = 1

	SELECT DISTINCT T2.PriceListID, T0.ItemID
	INTO #TEMP
	FROM PLT1 T0
	INNER JOIN OGITM T1 ON T1.ItemID = T0.ItemID AND T1.PlantID = T0.PlantID
	INNER JOIN OGCRD T2 ON T2.PlantID = T1.PlantID AND T2.DivisionlID = T1.DivisionlID
	WHERE T0.Active = 1 AND T1.DivisionlID = @DivisionID AND T2.CustomerID = @ParentID

	SELECT O.ItemID, O.ItemCode, O.ItemName, ISNULL(M.TotalPacket, 0) AvailQty, P.UnitID, 0.00 AS DispatchQty, U.Unitname, I.Quantity, P.UnitPrice, Convert(NUMERIC(18, 4), (P.UnitPrice * T.Percentage) / 100) AS Tax, T.TaxID, Convert(NVARCHAR(100), 0.00) AS RANKNO
	FROM #TEMP A
	INNER JOIN OITM O ON A.ItemID = O.ItemID
	LEFT JOIN ITM1 I ON O.ItemID = I.ItemID
	LEFT JOIN IPL1 P ON O.ItemID = P.ItemID AND I.UnitID = P.UnitID
	LEFT JOIN OTAX T ON P.TaxID = T.TaxID
	LEFT JOIN OUNT U ON U.UnitID = P.UnitID
	LEFT JOIN ITM2 M ON O.ItemID = M.ItemID AND M.ParentID = @ParentID AND M.WhsID = @WhsID
	WHERE I.UnitType IN (1, 3) AND P.PriceListID = A.PriceListID AND O.ItemID = A.ItemID

	DROP TABLE #temp
END
GO