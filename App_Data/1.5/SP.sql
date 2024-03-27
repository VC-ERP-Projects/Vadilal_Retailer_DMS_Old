  
Create PROCEDURE [dbo].[ClaimStatus]   
(@FromDate as Date,  
@ToDate as Date,  
@ClaimStatus as int)      
AS  
--Declare       
  
    
--@FromDate Datetime = '20170401',      
--@ToDate Datetime = '20170430',      
     
--@ClaimStatus varchar(10) = '3'    
   
BEGIN  
select  distinct
(Select TA.CustomerCode From OCRD TA WHERE TA.CustomerID = T.ParentID) as 'DistributorCode',   
(Select TA.Name From OTLT TA WHERE TA.ParentID = T.ParentID) as 'DistributorName',  

   
Convert(Nvarchar,T.FromDate,103) as 'FromDate',  
Convert(Nvarchar,T.ToDate,103) as 'ToDate', isnull(T0.SAPErrMsg,'')  as 'ErrorMsg',
(CASE WHEN T0.SchemeType = 'M' Then 'Master'   
   WHEN T0.SchemeType = 'S' Then 'QPS'   
   WHEN T0.SchemeType = 'D' Then 'Machine'   
   WHEN T0.SchemeType = 'P' Then 'Parlour'  
 ELSE 'Other' END) as 'SchemeType'  
from OCLMP T Left Join  OCLM T0 on T.ParentClaimID = T0.ParentClaimID AND T.ParentID = T0.ParentID  
Where 
(@ClaimStatus = '0' OR T0.[Status] = @ClaimStatus)  
AND CONVERT(date,T.FromDate) >= @FromDate AND CONVERT(date,T.ToDate) <= @ToDate  
AND (T0.SAPErrMsg is not null OR T0.SAPErrMsg != '')
--group by T.ParentID,T.FromDate,T.ToDate

END  
GO


ALTER PROCEDURE [dbo].[GetAttendenceStatus] 
(@ParentID AS Varchar(255),
@EmpID AS Varchar(255),
@FromDate as Datetime,
@ToDate as Datetime)    
AS
--Declare     
--@ParentID Decimal(18,0) = '1000010000000000',    
--@EmpID Decimal(18,0) = 1,    
--@FromDate Datetime = '20170401',    
--@ToDate Datetime = '20170430'  

BEGIN
select 
(Select TA.EmpCode From OEMP TA WHERE TA.EmpID = @EmpID and TA.ParentID = @ParentID) as 'Employeecode', 
(Select TA.Name From OEMP TA WHERE TA.EmpID = @EmpID and TA.ParentID = @ParentID) as 'Employeename', 
Convert(date,T.InDate,103) as 'InDate', CONVERT(VARCHAR(8),T.InDate,108) AS 'InTime', 
Convert(date,T.OutDate,103) as 'OutDate',CONVERT(VARCHAR(8),T.OutDate,108) AS 'OutTime',T.EntryID as 'EntryID',
ISNULL(T.InCItyName,'') as 'InCityName', ISNULL(T.OutCItyName,'') as 'OUTCITYNAME',T.InCity as 'INCITYFLAG',T.OutCity as 'OUTCITYFLAG'

from OENT T 
Where T.ParentID = @ParentID and t.EmpID = @EmpID
AND CONVERT(date,T.InDate) >= @FromDate AND CONVERT(date,T.OutDate) <= @ToDate
END
GO


ALTER PROCEDURE [dbo].[GetAttendenceDetail] 
(@ParentID AS Varchar(255),
@EntryID AS Varchar(255))    
AS
--Declare     
--@ParentID Decimal(18,0) = '1000010000000000', 
--@EmpID varchar(255) = '3',   
--@EntryID varchar(255) = '2'

BEGIN
select 
T1.Lat as 'Latitude',T1.Long as 'Longitude',ISNULL(T4.CustomerName,'') as 'CustomerName',t1.CustID,
ISNULL(T2.RouteName,'') as 'RouteName',ISNULL(T3.MenuName,'') as 'Menu',T1.Ref1 as 'ref1',T1.Ref2 as 'ref2', T1.Ref3 as 'ref3'
from ENT1 T1 
left outer join ORUT T2 on T1.ParentID = T2.ParentID and T1.RouteID = T2.RouteID
left outer join OMNU T3 on T1.MenuID = T3.MenuID 
left outer join OCRD T4 on T1.CustID = T4.CustomerID 
Where T1.ParentID = @ParentID and t1.EntryID = @EntryID

END
GO

USE [VDMS]
GO
/****** Object:  StoredProcedure [dbo].[GetPerwiseFocusItem]    Script Date: 05/06/2017 15:59:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[GetPerwiseFocusItem]( @ParentID Decimal(18,0), 
@CustomerID Decimal(18,0), 
 @FromDate Datetime ,
 @ToDate Datetime, 
 @PlantID int ,
 @RegionID int, 
 @MinPer Money )
 as 


--Declare @ParentID Decimal(18,0) = 0
--Declare @CustomerID Decimal(18,0) = 0
--Declare @FromDate Datetime = '20170401'
--Declare @ToDate Datetime = '20170430'
--Declare @PlantID int = 0
--Declare @RegionID int = 0
--Declare @MinPer Money = 50

SELECT T0.CustomerCode,T0.CustomerName,T0.[Total Sale],T0.[Item Sale],T0.Percentage,T0.Place
From (
Select TC.CustomerCode,TC.CustomerName,SUM(TA.Total) as 'Total Sale',SUM(TB.Total) as 'Item Sale',((100 * SUM(TB.Total))/SUM(TA.Total)) as 'Percentage' , TH.CityName AS 'Place'
from OPOS TA 
LEFT JOIN POS1 TB on TA.SaleID = TB.SaleID AND TA.ParentID = TB.ParentID
LEFT JOIN OCRD TC on TC.CustomerID = TA.CustomerID
LEFT JOIN CRD1 TD on TD.CustomerID = TC.CustomerID AND TD.BranchID = (Select top 1 BranchID from CRD1 where CustomerID = TC.CustomerID AND IsDeleted = 0)
LEFT JOIN OCST TE on TE.StateID = TD.StateID
LEFT JOIN OGCRD TF on TF.CustomerID = TC.CustomerID 
LEFT JOIN PLT1 TG on TG.ItemID = TB.ItemID AND TG.ParentID = TA.ParentID AND TG.PlantID = TF.PlantID AND TG.Active = 1 
LEFT JOIN OCTY TH ON TH.CityID = TD.CityID
WHERE (@ParentID = '0' OR TA.ParentID = @ParentID) 
AND (@CustomerID = '0' OR TA.CustomerID = @CustomerID)
AND Convert(DATE,TA.Updateddate) >= @FromDate AND Convert(DATE,TA.Updateddate) <= @ToDate
AND (@PlantID = '0' OR TF.PlantID = @PlantID) 
AND (@RegionID = '0' OR TE.StateID = @RegionID)
GROUP BY TC.CustomerCode,TC.CustomerName,TH.CityName  ) T0
WHERE (@MinPer = 0 or T0.Percentage <= @MinPer) 
GO



ALTER PROCEDURE [dbo].[GetDateWiseSalePurQty] 
	( @FromDate AS DATE,@ToDate AS DATE)
AS
BEGIN
DECLARE @Query AS NVARCHAR(MAX)
DECLARE @Cols AS NVARCHAR(MAX)
DECLARE @IsNullCols AS NVARCHAR(MAX) 
DECLARE @GrandTotalCol	NVARCHAR (MAX)
DECLARE @GrandTotalRow	NVARCHAR(MAX)
 
SET @FromDate = '20170501'
SET @ToDate = '20170509'

SELECT @Cols = STUFF((
				SELECT DISTINCT * FROM(
				SELECT  DISTINCT ',' +  QUOTENAME( Convert(VARCHAR,(O.Date),103)) as Date1
				FROM OMID O
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4) 
				UNION ALL
				SELECT DISTINCT ',' +  QUOTENAME( Convert(VARCHAR,(T.Date),103)) as Date1
				FROM OPOS T
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType = 13) as x
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

					
SELECT @IsNullCols = STUFF((	
				SELECT DISTINCT * FROM(
				SELECT DISTINCT  ',' +  ('IsNull([' +  Convert(VARCHAR,(O.Date),103) + '],0)') + ' as ['+ Convert(VARCHAR,(O.Date),103) +']' AS DATE2
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  ',' +  ('IsNull([' +  Convert(VARCHAR,(T.Date),103) + '],0)') + ' as ['+ Convert(VARCHAR,(T.Date),103) +']' AS DATE2 
				FROM OPOS T
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
				
SET @GrandTotalCol = STUFF((
				SELECT DISTINCT * FROM(	
				SELECT DISTINCT  '+' +  'ISNULL(' + QUOTENAME(Convert(VARCHAR,(O.Date),103)) + ',0)' AS DATE3
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  '+' +  'ISNULL(' + QUOTENAME(Convert(VARCHAR,(T.Date),103)) + ',0)' AS DATE3
				FROM OPOS T 
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
 
SELECT @GrandTotalRow = STUFF((
				SELECT DISTINCT * FROM(	
				SELECT DISTINCT  ',' +  'ISNULL(SUM(' + QUOTENAME(Convert(VARCHAR,(O.Date),103)) + '),0)' AS DATE4
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  ',' +  'ISNULL(SUM(' + QUOTENAME(Convert(VARCHAR,(T.Date),103)) + '),0)' AS DATE4
				FROM OPOS T 
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @query = N'with Info as(SELECT CustName,QTY,'+ @IsNullCols +','+ @GrandTotalCol +' as TOTAL from   
(
		Select (T3.CustomerCode + '' - '' + T0.Name) as ''CustName'',''Purch. Qty'' As ''QTY''
		,Convert(VARCHAR,(T1.Date),103) as DATE,SUM(T6.TotalQty) as ''QUANTITY''
		FROM OTLT T0 LEFT OUTER JOIN OMID T1 on T0.ParentID = T1.ParentID
		LEFT OUTER JOIN MID1 T6 ON T1.InwardID = T6.InwardID and T1.ParentID = T6.ParentID
		Left Outer Join OCRD T3 on T3.CustomerID = T0.ParentID
		where Convert(date,T1.Date,103) >= '''+ Convert(VARCHAR(10),@FromDate,101)+''' 
		and Convert(date,T1.Date,103) <= '''+ Convert(VARCHAR(10),@ToDate,101)+'''
		AND T1.InwardType in (3,4)
		GROUP BY T3.CustomerCode,T0.Name,Convert(VARCHAR,(T1.Date),103)
		
		UNION ALL
		
		SELECT * FROM(
		Select (T3.CustomerCode + ''-'' + T0.Name) as ''CustName'', ''Sales Qty'' As ''QTY''
		,Convert(VARCHAR,(T1.Date),103) as DATE,SUM(T6.TotalQty) as ''QUANTITY''
		FROM OTLT T0 LEFT OUTER JOIN OPOS T1 on T0.ParentID = T1.ParentID
		LEFT OUTER JOIN POS1 T6 ON T1.SALEID = T6.SALEID and T1.ParentID = T6.ParentID
		Left Outer Join OCRD T3 on T3.CustomerID = T0.ParentID
		where Convert(date,T1.Date,103) >= '''+ Convert(VARCHAR(10),@FromDate,101)+''' 
		and Convert(date,T1.Date,103) <= '''+ Convert(VARCHAR(10),@ToDate,101)+'''
		AND T1.OrderType in (13)
		GROUP BY T3.CustomerCode,T0.Name,Convert(VARCHAR,(T1.Date),103)) TA
)Y
		PIVOT
		(
			SUM(QUANTITY)
			FOR DATE in (' +@Cols + ')
		) PIV)
		SELECT * FROM INFO order by CustName ;'
--print @Query
EXEC sp_executesql @Query

END
GO



ALTER PROCEDURE [dbo].[GetDateWiseSalePurAmt] 
	( @FromDate AS DATE,
	@ToDate AS DATE)
AS
BEGIN
DECLARE @Query AS NVARCHAR(MAX)
DECLARE @Cols AS NVARCHAR(MAX)
DECLARE @IsNullCols AS NVARCHAR(MAX) 
DECLARE @GrandTotalCol	NVARCHAR (MAX)
DECLARE @GrandTotalRow	NVARCHAR(MAX)

 
SET @FromDate = '20170501'
SET @ToDate = '20170503'

SELECT @Cols = STUFF((
				SELECT DISTINCT * FROM(
				SELECT  DISTINCT ',' +  QUOTENAME( Convert(VARCHAR,(O.Date),103)) as Date1
				FROM OMID O
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4) 
				UNION ALL
				SELECT DISTINCT ',' +  QUOTENAME( Convert(VARCHAR,(T.Date),103)) as Date1
				FROM OPOS T
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType = 13) as x
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

					
SELECT @IsNullCols = STUFF((	
				SELECT DISTINCT * FROM(
				SELECT DISTINCT  ',' +  ('IsNull([' +  Convert(VARCHAR,(O.Date),103) + '],0)') + ' as ['+ Convert(VARCHAR,(O.Date),103) +']' AS DATE2
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  ',' +  ('IsNull([' +  Convert(VARCHAR,(T.Date),103) + '],0)') + ' as ['+ Convert(VARCHAR,(T.Date),103) +']' AS DATE2 
				FROM OPOS T
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
				
SET @GrandTotalCol = STUFF((
				SELECT DISTINCT * FROM(	
				SELECT DISTINCT  '+' +  'ISNULL(' + QUOTENAME(Convert(VARCHAR,(O.Date),103)) + ',0)' AS DATE3
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  '+' +  'ISNULL(' + QUOTENAME(Convert(VARCHAR,(T.Date),103)) + ',0)' AS DATE3
				FROM OPOS T 
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
 
SELECT @GrandTotalRow = STUFF((
				SELECT DISTINCT * FROM(	
				SELECT DISTINCT  ',' +  'ISNULL(SUM(' + QUOTENAME(Convert(VARCHAR,(O.Date),103)) + '),0)' AS DATE4
				FROM OMID O 
				where Convert(Date,O.Date) >= @FromDate and Convert(Date,O.Date) <= @ToDate AND O.InwardType in (3,4)
				UNION ALL
				SELECT DISTINCT  ',' +  'ISNULL(SUM(' + QUOTENAME(Convert(VARCHAR,(T.Date),103)) + '),0)' AS DATE4
				FROM OPOS T 
				where Convert(Date,T.Date) >= @FromDate and Convert(Date,T.Date) <= @ToDate AND T.OrderType in (13)) AS X
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @query = N'with Info as(SELECT CustName,Amount,'+ @IsNullCols +','+ @GrandTotalCol +' as TOTAL from   
(
		Select (T3.CustomerCode + '' - '' + T0.Name) as ''CustName'',''Purch. Amt'' As ''Amount''
		,Convert(VARCHAR,(T1.Date),103) as DATE,SUM(T1.Total) as ''TotalAmount''
		FROM OTLT T0 LEFT OUTER JOIN OMID T1 on T0.ParentID = T1.ParentID
		Left Outer Join OCRD T3 on T3.CustomerID = T0.ParentID
		where Convert(date,T1.Date,103) >= '''+ Convert(VARCHAR(10),@FromDate,101)+''' 
		and Convert(date,T1.Date,103) <= '''+ Convert(VARCHAR(10),@ToDate,101)+'''
		AND T1.InwardType in (3,4)
		GROUP BY T3.CustomerCode,T0.Name,Convert(VARCHAR,(T1.Date),103)
		
		UNION ALL
		
		SELECT * FROM(
		Select (T3.CustomerCode + ''-'' + T0.Name) as ''CustName'', ''Sales Amt'' As ''Amount''
		,Convert(VARCHAR,(T1.Date),103) as DATE,SUM(T1.Total) as ''TotalAmount''
		FROM OTLT T0 LEFT OUTER JOIN OPOS T1 on T0.ParentID = T1.ParentID
		Left Outer Join OCRD T3 on T3.CustomerID = T0.ParentID
		where Convert(date,T1.Date,103) >= '''+ Convert(VARCHAR(10),@FromDate,101)+''' 
		and Convert(date,T1.Date,103) <= '''+ Convert(VARCHAR(10),@ToDate,101)+'''
		AND T1.OrderType in (13)
		GROUP BY T3.CustomerCode,T0.Name,Convert(VARCHAR,(T1.Date),103)) TA
	)Y
		PIVOT
		(
			SUM(TotalAmount)
			FOR DATE in (' +@Cols + ')
		) PIV)
		SELECT * FROM INFO order by CustName;'
--print @Query
EXEC sp_executesql @Query

END
GO

ALTER PROCEDURE [dbo].[AssetConflict](@DealerID as Decimal(18,0),@DistributorID as Decimal(18,0),@FromDate as Datetime, @ToDate as Datetime,@PlantID as int,@RegionID int)  
AS      
--Declare             
--@DealerID Decimal(18,0) = 0,            
--@DistributorID Decimal(18,0) = 0,            
--@FromDate Datetime = '20130501',            
--@ToDate Datetime = '20180520',            
--@PlantID int = 0,            
--@RegionID int = 30     
   
BEGIN      
CREATE TABLE #TEMP(CustomerID Decimal(18,0))     
    
IF(@DistributorID >0)                
BEGIN       
 INSERT INTO #TEMP SELECT CUSTOMERID FROM OCRD WHERE ParentID = @DistributorID    
END                
ELSE IF(@PlantID >0)                
BEGIN           
 INSERT INTO #TEMP SELECT DISTINCT A.CUSTOMERID FROM OCRD A LEFT JOIN OGCRD B on A.CustomerID = B.CustomerID WHERE B.PlantID = @PlantID AND A.[Type] = 3       
END                
ELSE IF(@RegionID > 0)                
BEGIN        
 INSERT INTO #TEMP SELECT DISTINCT A.CUSTOMERID FROM OCRD A LEFT JOIN CRD1 B on A.CustomerID = B.CustomerID WHERE B.StateID = @RegionID AND A.[Type] = 3  
END      
else if (@DealerID>0)      
BEGIN        
 INSERT INTO #TEMP select @DealerID    
END             
ELSE                
BEGIN                
 INSERT INTO #TEMP SELECT 0     
END      
    
select T5.CustomerCode as 'Dist Code',T5.CustomerName as 'Dist Name', T4.CustomerCode as 'Dealer Code', T4.CustomerName as 'Dealer Code',  
CONVERT(nvarchar,t1.Datetime,103) as 'Scan Date', T6.EmpCode,T6.Name as 'Emp Name', T7.RouteName,T1.Ref1 as 'Asset Code',T1.Ref2 as 'User Conflict',T1.Ref3 AS 'System Conflict'  
from ENT1 T1  
INNER join #TEMP T3 on T3.CustomerID = T1.CustID  
JOIN OEMP T6 ON T6.EmpID = T1.EmpID AND T6.ParentID = T1.ParentID  
JOIN ORUT T7 ON T7.RouteID = T1.RouteID AND T7.ParentID = T1.ParentID  
left outer join OCRD T4 on T4.CustomerID = T1.CustID       
left outer join OCRD T5 on T5.CustomerID = T4.ParentID    
WHERE Convert(date,T1.Datetime) >= @FromDate AND Convert(date,T1.Datetime) <= @ToDate AND T1.MenuID = 9110  
  
DROP TABLE #TEMP  
  
END 

Create PROCEDURE [dbo].[BarcodeConflict](@DealerID as Decimal(18,0),@DistributorID as Decimal(18,0),@FromDate as Datetime, @ToDate as Datetime,@PlantID as int,@RegionID int)  
AS      
--Declare             
--@DealerID Decimal(18,0) = 0,            
--@DistributorID Decimal(18,0) = 0,            
--@FromDate Datetime = '20130501',            
--@ToDate Datetime = '20180520',            
--@PlantID int = 0,            
--@RegionID int = 30     
   
BEGIN      
CREATE TABLE #TEMP(CustomerID Decimal(18,0))     
    
IF(@DistributorID >0)                
BEGIN       
 INSERT INTO #TEMP SELECT CUSTOMERID FROM OCRD WHERE ParentID = @DistributorID    
END                
ELSE IF(@PlantID >0)                
BEGIN           
 INSERT INTO #TEMP SELECT DISTINCT A.CUSTOMERID FROM OCRD A LEFT JOIN OGCRD B on A.CustomerID = B.CustomerID WHERE B.PlantID = @PlantID AND A.[Type] = 3       
END                
ELSE IF(@RegionID > 0)                
BEGIN        
 INSERT INTO #TEMP SELECT DISTINCT A.CUSTOMERID FROM OCRD A LEFT JOIN CRD1 B on A.CustomerID = B.CustomerID WHERE B.StateID = @RegionID AND A.[Type] = 3  
END      
else if (@DealerID>0)      
BEGIN        
 INSERT INTO #TEMP select @DealerID    
END             
ELSE                
BEGIN                
 INSERT INTO #TEMP SELECT 0     
END      
    
select T5.CustomerCode as 'Dist Code',T5.CustomerName as 'Dist Name', T4.CustomerCode as 'Dealer Code', T4.CustomerName as 'Dealer Name',  
CONVERT(nvarchar,t1.Datetime,103) as 'Scan Date', T6.EmpCode,T6.Name as 'Emp Name', T7.RouteName,T1.Ref1 as 'BarCode',T1.Ref2 as 'User Conflict',T1.Ref3 AS 'System Conflict'  
from ENT1 T1  
INNER join #TEMP T3 on T3.CustomerID = T1.CustID  
JOIN OEMP T6 ON T6.EmpID = T1.EmpID AND T6.ParentID = T1.ParentID  
JOIN ORUT T7 ON T7.RouteID = T1.RouteID AND T7.ParentID = T1.ParentID  
left outer join OCRD T4 on T4.CustomerID = T1.CustID       
left outer join OCRD T5 on T5.CustomerID = T4.ParentID    
WHERE Convert(date,T1.Datetime) >= @FromDate AND Convert(date,T1.Datetime) <= @ToDate AND T1.MenuID = 9105  
  
DROP TABLE #TEMP  
  
END 