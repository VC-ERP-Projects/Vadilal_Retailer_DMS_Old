
/****** Object:  StoredProcedure [dbo].[BarcodeConflict]    Script Date: 06/15/2017 10:31:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BarcodeConflict]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BarcodeConflict]
GO
/****** Object:  StoredProcedure [dbo].[SFA_OffBitRouteRequest]    Script Date: 06/15/2017 10:31:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SFA_OffBitRouteRequest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SFA_OffBitRouteRequest]
GO
/****** Object:  StoredProcedure [dbo].[SalesRegister]    Script Date: 06/15/2017 10:31:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SalesRegister]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SalesRegister]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseRegister]    Script Date: 06/15/2017 10:31:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PurchaseRegister]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PurchaseRegister]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseRegister]    Script Date: 06/15/2017 10:31:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PurchaseRegister]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[PurchaseRegister] (@ParentID NVARCHAR(MAX), @FromDate DATE, @ToDate DATE, @DivisionWise BIT, @InwardType NVARCHAR(10))            
AS            
BEGIN            
 DECLARE @Query AS NVARCHAR(MAX)            
 DECLARE @Cols AS NVARCHAR(MAX)            
 DECLARE @IsNullCols AS NVARCHAR(MAX)            
 DECLARE @GrandTotalCol NVARCHAR(MAX)            
            
 --Declare                                  
 --@ParentID Nvarchar(MAX) = ''2000010000100000''                      ,            
 --@FromDate DATE = ''20170401'',                                  
 --@ToDate DATE = ''20170508'',            
 --@DivisionWise bit = 0,            
 --@InwardType Nvarchar(10) = ''3,4''
           
 --SELECT items as Distributor INTO #TEMP_DISTIBUTOR FROM dbo.Split(@ParentID,'','')                        
 --SELECT items as Dealer INTO #TEMP_DEALER FROM dbo.Split(@CustomerID,'','')               
 --drop table #TEMP_DISTIBUTOR          
 --drop table #TEMP_DEALER          
           
 --------------- Dynemic Tax Type                    
 SELECT @Cols = STUFF((            
    SELECT '','' + QUOTENAME(T.[TYPE])            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 SELECT @IsNullCols = STUFF((            
    SELECT '','' + (''IsNull(['' + T.[TYPE] + ''],0)'') + '' as ['' + T.[TYPE] + '']''            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 SELECT @GrandTotalCol = STUFF((            
    SELECT ''+'' + ''ISNULL('' + QUOTENAME(T.[TYPE]) + '',0)''            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 IF (@DivisionWise = 1)            
 BEGIN            
  SET @query = N''with Info as(SELECT ROW_Number() OVER (ORDER by ReceiveDate) as ''''No'''',[Inv. No],convert(NVARCHAR,ReceiveDate, 103) as ''''ReceiptDate'''',InvoiceDate,    
  [Vendor Name],''''CAR'''' as ''''UOM'''',Material,Quantity,[Value of Goods],Discount,[Total Value],[% PER],'' + @IsNullCols + '','' + @GrandTotalCol + '' as ''''Total VAT'''',            
  [Total Value] + '' + @GrandTotalCol +             
   '' as ''''Total Amount''''            
  from (                    
  SELECT  (CASE WHEN (A.BillNumber is null OR A.BillNumber = '''''''') then ISNULL(A.InvoiceNumber,'''''''') ELSE ISNULL(A.BillNumber,'''''''') END) as ''''Inv. No'''',            
  A.ReceiveDate,    
  (CASE WHEN A.InvoiceDate is not null THEN convert(NVARCHAR, A.InvoiceDate, 103) ELSE convert(NVARCHAR, A.BillDate, 103) END) as ''''InvoiceDate'''',            
  C.VendorCode as ''''Vendor Code'''', C.VendorName as ''''Vendor Name'''',M.DivisionName as ''''Material'''',ISNULL(SUM(B.TotalQty),0) AS ''''Quantity'''',            
  --C.VATNumber as ''''R.C. No'''',C.CSTNumber as ''''HSN Code'''',             
  ISNULL(SUM(B.SubTotal), 0) AS ''''Value of Goods'''',            
  0  AS ''''Discount'''',(ISNULL(SUM(B.SubTotal),0) - 0) as ''''Total Value'''',              
  M.TaxPercnt as ''''% PER'''',M.TaxType,ISNULL(SUM(M.BifurcateTaxValue),0) as ''''BifurcateTaxValue'''',ISNULL(SUM(B.Tax),0) as ''''Total VAT'''',            
  ISNULL(SUM(B.Total), 0) AS ''''Total Amount''''            
            
  FROM (            
  SELECT T0.InwardID,T0.ParentID,            
  T1.MID1ID, T1.ItemID,            
  (SELECT TOP 1 DIVISIONNAME FROM OGITM A LEFT JOIN ODIV B ON A.DIVISIONLID  = B.DIVISIONLID  WHERE ITEMID = T1.ITEMID) as ''''DivisionName'''',            
  Convert(Nvarchar,ISNULL(T2.Percentage,0)) + ''''%'''' as ''''TaxPercnt'''',            
  ISNULL(T4.[Type],''''VAT'''') as ''''TaxType'''',            
  --ISNULL(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),0) as ''''BifurcateTaxValue''''            
  ISNULL(ROUND(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),2),0) as ''''BifurcateTaxValue''''                
            
            
  FROM OMID T0              
  LEFT JOIN MID1 T1 ON T0.InwardID = T1.InwardID AND T0.ParentID = T1.ParentID              
  LEFT JOIN OTAX T2 ON T2.TaxID = T1.TaxID            
  LEFT JOIN TAX1 T3 ON T3.TaxID = T2.TaxID            
  LEFT JOIN TAX2 T4 ON T4.Code = T3.Code             
            
  WHERE (''''''             
   + @Parentid + '''''' = ''''0'''' OR T0.ParentID =   '''''' + @Parentid + '''''' )             
  AND CONVERT(DATE, T0.ReceiveDate) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, T0.ReceiveDate) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''             
  AND T0.InwardType in (SELECT items from dbo.Split_new('''''' + @InwardType + '''''','''',''''))            
            
  ) M            
  LEFT JOIN OMID A on A.InwardID = M.InwardID AND M.ParentId = M.ParentID             
  LEFT JOIN MID1 B on A.InwardID = B.InwardID AND A.ParentId = B.ParentID AND B.ItemID = M.ItemID AND M.MID1ID = B.MID1ID             
  LEFT JOIN OVND C ON C.ParentID = A.VendorParentID             
            
   WHERE ('''''' + @Parentid + ''''''   = ''''0'''' OR A.ParentID =   '''''' + @Parentid + '''''' )             
  AND CONVERT(DATE, A.ReceiveDate) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, A.ReceiveDate) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''             
  AND A.InwardType in (SELECT items from dbo.Split_new('''''' + @InwardType + '''''','''',''''))          
            
  GROUP BY A.InvoiceNumber,A.BillNumber ,A.ReceiveDate,A.InvoiceDate,A.BillDate,C.VendorCode, C.VendorName,M.DivisionName ,M.TaxPercnt,M.TaxType            
            
  --ORDER BY A.InvoiceNumber                    
            
) X                      
PIVOT                    
(                    
  SUM(BifurcateTaxValue)                    
  FOR TaxType                    
  IN ('' + @Cols + '')                    
) P)                    
            
Select * from Info                     
ORDER BY No''            
 END            
 ELSE            
 BEGIN            
  SET @query = N''with Info as(SELECT ROW_Number() OVER (ORDER by ReceiveDate) as ''''No'''',[Inv. No],convert(NVARCHAR,ReceiveDate, 103) as ''''ReceiptDate'''',InvoiceDate,                     
  [Vendor Name],''''CAR'''' as ''''UOM'''',Quantity,[Value of Goods],Discount,[Total Value],[% PER],'' + @IsNullCols + '','' + @GrandTotalCol + '' as ''''Total VAT'''',            
  [Total Value] + '' + @GrandTotalCol +             
   '' as ''''Total Amount''''            
  from (                    
  SELECT  (CASE WHEN (A.BillNumber is null OR A.BillNumber = '''''''') then ISNULL(A.InvoiceNumber,'''''''') ELSE ISNULL(A.BillNumber,'''''''') END) as ''''Inv. No'''',            
  A.ReceiveDate,    
  (CASE WHEN A.InvoiceDate is not null THEN convert(NVARCHAR, A.InvoiceDate, 103) ELSE convert(NVARCHAR, A.BillDate, 103) END) as ''''InvoiceDate'''',         
  C.VendorCode as ''''Vendor Code'''', C.VendorName as ''''Vendor Name'''',ISNULL(SUM(B.TotalQty),0) AS ''''Quantity'''',            
  --C.VATNumber as ''''R.C. No'''',C.CSTNumber as ''''HSN Code'''',             
  ISNULL(SUM(B.SubTotal), 0) AS ''''Value of Goods'''',            
  0  AS ''''Discount'''',(ISNULL(SUM(B.SubTotal),0) - 0) as ''''Total Value'''',              
   M.TaxPercnt as ''''% PER'''',M.TaxType,ISNULL(SUM(M.BifurcateTaxValue),0) as ''''BifurcateTaxValue'''',ISNULL(SUM(B.Tax),0) as ''''Total VAT'''',            
   ISNULL(SUM(B.Total), 0) AS ''''Total Amount''''            
            
  FROM (            
  SELECT T0.InwardID,T0.ParentID,            
  T1.MID1ID, T1.ItemID,            
  Convert(Nvarchar,ISNULL(T2.Percentage,0)) + ''''%'''' as ''''TaxPercnt'''',            
  T4.[Type] as ''''TaxType'''',            
  --ISNULL(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),0) as ''''BifurcateTaxValue''''            
  ISNULL(ROUND(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),2),0) as ''''BifurcateTaxValue''''                
            
            
  FROM OMID T0              
  LEFT JOIN MID1 T1 ON T0.InwardID = T1.InwardID AND T0.ParentID = T1.ParentID              
  LEFT JOIN OTAX T2 ON T2.TaxID = T1.TaxID            
  LEFT JOIN TAX1 T3 ON T3.TaxID = T2.TaxID            
  LEFT JOIN TAX2 T4 ON T4.Code = T3.Code             
            
  WHERE (''''''             
   + @Parentid + '''''' = ''''0'''' OR T0.ParentID =   '''''' + @Parentid + '''''' )             
  AND CONVERT(DATE, T0.ReceiveDate) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, T0.ReceiveDate) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''             
  AND T0.InwardType in (SELECT items from dbo.Split_new('''''' + @InwardType + '''''','''',''''))             
            
  ) M            
  LEFT JOIN OMID A on A.InwardID = M.InwardID AND M.ParentId = M.ParentID             
  LEFT JOIN MID1 B on A.InwardID = B.InwardID AND A.ParentId = B.ParentID AND B.ItemID = M.ItemID AND M.MID1ID = B.MID1ID             
  LEFT JOIN OVND C ON C.ParentID = A.VendorParentID             
            
  WHERE ('''''' + @Parentid + ''''''  = ''''0'''' OR A.ParentID =   '''''' + @Parentid + '''''' )             
  AND CONVERT(DATE, A.ReceiveDate) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, A.ReceiveDate) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''             
  AND A.InwardType in (SELECT items from dbo.Split_new('''''' + @InwardType + '''''','''',''''))          
            
  GROUP BY A.InvoiceNumber,A.BillNumber ,A.ReceiveDate,A.InvoiceDate,A.BillDate,C.VendorCode, C.VendorName,M.TaxType, M.TaxPercnt            
  --ORDER BY A.InvoiceNumber               
            
) X                      
PIVOT              (                    
  SUM(BifurcateTaxValue)                   
  FOR TaxType                    
  IN ('' + @Cols + '')                    
) P)                    
            
Select * from Info                     
ORDER BY No''            
 END            
            
 --PRINT @Query            
            
 EXEC sp_executesql @Query            
  --DROP TABLE #TEMP_DEALER                      
  --DROP TABLE #TEMP_DISTIBUTOR                    
END ' 
END
GO
/****** Object:  StoredProcedure [dbo].[SalesRegister]    Script Date: 06/15/2017 10:31:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SalesRegister]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[SalesRegister] (@ParentID NVARCHAR(MAX), @CustomerID NVARCHAR(MAX), @FromDate DATE, @ToDate DATE, @DivisionWise BIT, @InvoiceType NVARCHAR(10))            
AS            
BEGIN            
 DECLARE @Query AS NVARCHAR(MAX)            
 DECLARE @Cols AS NVARCHAR(MAX)            
 DECLARE @IsNullCols AS NVARCHAR(MAX)            
 DECLARE @GrandTotalCol NVARCHAR(MAX)            
            
 --Declare                                      
 --@ParentID Nvarchar(MAX) = 2000010000100000 ,                                      
 --@FromDate DATE = ''20170428'',                                      
 --@ToDate DATE = ''20170503'',                
 --@CustomerID Nvarchar(MAX) = 0,                
 --@DivisionWise bit = 0,                
 --@InvoiceType Nvarchar(10) = 0           
          
 --------------- Dynemic Tax Type                
 SELECT @Cols = STUFF((            
    SELECT '','' + QUOTENAME(T.[TYPE])            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 SELECT @IsNullCols = STUFF((            
    SELECT '','' + (''IsNull(['' + T.[TYPE] + ''],0)'') + '' as ['' + T.[TYPE] + '']''            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 SELECT @GrandTotalCol = STUFF((            
    SELECT ''+'' + ''ISNULL('' + QUOTENAME(T.[TYPE]) + '',0)''            
    FROM TAX2 T            
    FOR XML PATH(''''), TYPE            
    ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')            
            
 IF (@DivisionWise = 1)            
 BEGIN            
  SET @query = N''with Info as(SELECT ROW_Number() OVER (ORDER by [Date]) as ''''No'''',[Inv. Type],[Inv. No],convert(VARCHAR, [Date], 103) as ''''Date'''',                 
  [Customer Code],[Customer Name],''''CAR'''' as ''''UOM'''',Material,Quantity,[R.C. No],[HSN Code],[Value of Goods],Discount,[Total Value],[% VAT],'' + @IsNullCols + '','' + @GrandTotalCol + '' as ''''Total VAT'''',                
  [Total Value] + '' + @GrandTotalCol +  '' as ''''Total Amount''''     
  from (                
  SELECT  MA.InvoiceType as ''''Inv. Type'''',MA.InvoiceNumber as ''''Inv. No'''',MA.[Date],                
  MA.CustomerCode as ''''Customer Code'''',MA.CustomerName as ''''Customer Name'''',MA.DivisionName as ''''Material'''',MA.Quantity,                
  MA.VATNumber as ''''R.C. No'''',MA.CSTNumber as ''''HSN Code'''',                
  ISNULL(MA.SubTotal,0) as ''''Value of Goods'''',                
  --(CASE WHEN Row  = 1 Then MA.Discount ELSE 0 END) as ''''Discount'''',        
  MA.Discount as ''''Discount'''',            
  --(CASE WHEN Row  = 1 Then MA.SubTotal - MA.Discount ELSE MA.SubTotal END) as ''''Total Value'''',      
  MA.SubTotal - MA.Discount as ''''Total Value'''',      
  MA.TaxPercnt as ''''% VAT'''',MA.TaxType,MA.BifurcateTaxValue,MA.TotalTax as ''''Total VAT'''',            
  MA.Total AS ''''Total Amount''''                
            
 From (            
   SELECT Dense_Rank() OVER(PARTITION BY A.InvoiceNumber ORDER BY ISNULL(SUM(B.Tax),0) Desc) AS ''''Row'''',            
   M.InvoiceType ,A.InvoiceNumber ,A.[Date] as ''''Date'''',                
   C.CustomerCode , C.CustomerName ,M.DivisionName,ISNULL(SUM(B.TotalQty),0) AS ''''Quantity'''',                
   C.VATNumber,C.CSTNumber,                
   ISNULL(SUM(B.TotalQty * B.UnitPrice), 0)  AS ''''SubTotal'''',                
   --(CASE WHEN EXISTS(Select * from POS3 P Where P.ParentID = A.ParentID AND P.SaleID = A.SaleID AND EffectOnBill = 1) THEN            
   --(Select ISNULL(SUM(Amount),0) from POS3 Q Where Q.ParentID = A.ParentID AND Q.SaleID = A.SaleID AND Q.EffectOnBill = 1)              
   --ELSE            
   --(ISNULL(A.Discount,0) + (Select ISNULL(SUM(((R.UnitPrice * R.TotalQty) * R.ItemScheme)/100),0) from POS1 R Where R.ParentID = A.ParentID AND R.SaleID = A.SaleID AND R.ItemScheme > 0 AND R.Isdeleted = 0))            
   --END)            
   --AS ''''Discount'''',        
   SUM((((B.TotalQty * B.UnitPrice) * B.ItemScheme)/100) + (((B.TotalQty * B.UnitPrice - (((B.TotalQty * B.UnitPrice) * B.ItemScheme)/100))*B.SCheme)/100)) AS ''''Discount'''',             
   --(Select ISNULL(SUM(Amount),0) from POS3 P Where P.ParentID = A.ParentID AND P.SaleID = A.SaleID AND EffectOnBill = 1)  AS ''''Discount'''',        
   M.TaxPercnt ,M.TaxType,ISNULL(SUM(M.BifurcateTaxValue),0) as ''''BifurcateTaxValue'''',ISNULL(SUM(B.Tax),0) as ''''TotalTax'''',            
   ISNULL(SUM(B.Total), 0) AS ''''Total''''                
   FROM (                 
       SELECT T0.SaleID,T0.ParentID,(CASE WHEN T0.ProcessID = 1 THEN ''''Tax'''' WHEN T0.ProcessID = 2 THEN ''''Retail'''' ELSE ''''Other'''' END) AS ''''InvoiceType'''',                 
       T1.POS1ID, T1.ItemID,                
       (SELECT TOP 1 DIVISIONNAME FROM OGITM A LEFT JOIN ODIV B ON A.DIVISIONLID  = B.DIVISIONLID  WHERE ITEMID = T1.ITEMID) as ''''DivisionName'''',                
       Convert(Nvarchar,ISNULL(T2.Percentage,0)) + ''''%'''' as ''''TaxPercnt'''',                
       ISNULL(T4.[Type],''''VAT'''') as ''''TaxType'''',     
       (CASE WHEN T1.TAX > 0 THEN                
       ISNULL(ROUND(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),2),0) ELSE 0 END) as ''''BifurcateTaxValue''''                
            
       FROM OPOS T0                  
       LEFT JOIN POS1 T1 ON T0.SaleID = T1.SaleID AND T0.ParentID = T1.ParentID                  
       LEFT JOIN OTAX T2 ON T2.TaxID = T1.TaxID                
       LEFT JOIN TAX1 T3 ON T3.TaxID = T2.TaxID                
       LEFT JOIN TAX2 T4 ON T4.Code = T3.Code                 
            
       WHERE (''''''+ @Parentid + '''''' = ''''0'''' OR T0.ParentID = '''''' + @Parentid + '''''')                 
       AND ('''''' + @CustomerID + '''''' = ''''0'''' OR T0.CustomerID = '''''' + @CustomerID + '''''')                 
       AND CONVERT(DATE, T0.DATE) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, T0.DATE) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''                 
       AND ('''''' + @InvoiceType + '''''' = ''''0'''' OR T0.ProcessID = '''''' + @InvoiceType + '''''')                 
       AND T1.IsDeleted = 0 AND T0.OrderType IN (1, 12, 13)                       
   ) M                
   LEFT JOIN OPOS A on A.SaleID = M.SaleID AND M.ParentId = M.ParentID                 
   LEFT JOIN POS1 B on A.SaleID = B.SaleID AND A.ParentId = B.ParentID AND B.ItemID = M.ItemID AND M.POS1ID = B.POS1ID AND B.IsDeleted = 0                
   LEFT JOIN OCRD C ON C.CustomerID = A.CustomerID                 
            
   WHERE ('''''' + @Parentid + '''''' = ''''0'''' OR A.ParentID = '''''' + @Parentid + '''''')                 
   AND ('''''' + @CustomerID + '''''' = ''''0'''' OR A.CustomerID = '''''' + @CustomerID + '''''')                
   AND CONVERT(DATE, A.DATE) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) +             
   '''''' AND CONVERT(DATE, A.DATE) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''                 
   AND ('''''' + @InvoiceType + '''''' = ''''0'''' OR A.ProcessID = '''''' + @InvoiceType + '''''')                 
   AND B.IsDeleted = 0 AND A.OrderType IN (1, 12, 13)                    
            
   Group by M.InvoiceType,A.InvoiceNumber,A.[Date],C.CustomerCode, C.CustomerName,M.DivisionName,C.VATNumber,C.CSTNumber,A.ParentID,A.SaleID,M.TaxPercnt,M.TaxType    
       
 ) MA            
            
) X                  
PIVOT                
(                
  SUM(BifurcateTaxValue)                
  FOR TaxType                
  IN ('' + @Cols + '')                
) P)                
            
Select * from Info                 
ORDER BY No''            
 END            
 ELSE            
 BEGIN            
  SET @query = N''with Info as(SELECT ROW_Number() OVER (ORDER by [Date]) as ''''No'''',[Inv. Type],[Inv. No],convert(VARCHAR,[Date], 103) as ''''Date'''',
  [Customer Code],[Customer Name],''''CAR'''' as ''''UOM'''',Quantity,[R.C. No],[HSN Code],[Value of Goods],Discount,[Total Value],              
  '' + @IsNullCols + '','' + @GrandTotalCol + '' as ''''Total VAT'''',                
  [Total Value] + '' + @GrandTotalCol + '' as ''''Total Amount''''     
  from (                
            
   SELECT  MA.InvoiceType as ''''Inv. Type'''',MA.InvoiceNumber as ''''Inv. No'''',MA.[Date],                
  MA.CustomerCode as ''''Customer Code'''',MA.CustomerName as ''''Customer Name'''',MA.Quantity,                
  MA.VATNumber as ''''R.C. No'''',MA.CSTNumber as ''''HSN Code'''',                
  ISNULL(MA.SubTotal,0) as ''''Value of Goods'''',                   
  --(CASE WHEN Row  = 1 Then MA.Discount ELSE 0 END) as ''''Discount'''',              
  MA.Discount as ''''Discount'''',    
  --(CASE WHEN Row  = 1 Then MA.SubTotal - MA.Discount ELSE MA.SubTotal END) as ''''Total Value'''',      
  MA.SubTotal - MA.Discount as ''''Total Value'''',               
  MA.TaxType,MA.BifurcateTaxValue,MA.TotalTax as ''''Total VAT'''',            
  MA.Total AS ''''Total Amount''''                
            
 From (            
   SELECT Dense_Rank() OVER(PARTITION BY A.InvoiceNumber ORDER BY ISNULL(SUM(B.Tax),0) Desc) AS ''''Row'''',            
   M.InvoiceType,A.InvoiceNumber ,A.[Date] as ''''Date'''',                
   C.CustomerCode, C.CustomerName,ISNULL(SUM(B.TotalQty),0) AS ''''Quantity'''',                
   C.VATNumber,C.CSTNumber,                
   ISNULL(SUM(B.TotalQty * B.UnitPrice), 0)  AS ''''SubTotal'''',           
   -- (CASE WHEN EXISTS(Select * from POS3 P Where P.ParentID = A.ParentID AND P.SaleID = A.SaleID AND EffectOnBill = 1) THEN            
   --(Select ISNULL(SUM(Amount),0) from POS3 Q Where Q.ParentID = A.ParentID AND Q.SaleID = A.SaleID AND Q.EffectOnBill = 1)              
   --ELSE            
   --(ISNULL(A.Discount,0) + (Select ISNULL(SUM(((R.UnitPrice * R.TotalQty) * R.ItemScheme)/100),0) from POS1 R Where R.ParentID = A.ParentID AND R.SaleID = A.SaleID AND R.ItemScheme > 0 AND R.Isdeleted = 0))            
   --END)            
   --AS ''''Discount'''',     
   SUM((((B.TotalQty * B.UnitPrice) * B.ItemScheme)/100) + (((B.TotalQty * B.UnitPrice - (((B.TotalQty * B.UnitPrice) * B.ItemScheme)/100))*B.SCheme)/100)) AS ''''Discount'''',             
   --(Select ISNULL(SUM(Amount),0) from POS3 P Where P.ParentID = A.ParentID AND P.SaleID = A.SaleID AND EffectOnBill = 1)  AS ''''Discount'''',              
   M.TaxType,ISNULL(SUM(M.BifurcateTaxValue),0) as ''''BifurcateTaxValue'''',ISNULL(SUM(B.Tax),0) as ''''TotalTax'''',            
   ISNULL(SUM(B.Total), 0) AS ''''Total''''                
   FROM (                
        SELECT T0.SaleID,T0.ParentID,(CASE WHEN T0.ProcessID = 1 THEN ''''Tax'''' WHEN T0.ProcessID = 2 THEN ''''Retail'''' ELSE ''''Other'''' END) AS ''''InvoiceType'''',                 
        T1.POS1ID, T1.ItemID,                
        Convert(Nvarchar,ISNULL(T2.Percentage,0)) + ''''%'''' as ''''TaxPercnt'''',                
        T4.[Type] as ''''TaxType'''',    
        (CASE WHEN T1.TAX > 0 THEN                
        ISNULL(ROUND(((IsNull(T1.SubTotal, 0)) * IsNull(T3.Percentage, 0) / 100),2),0) ELSE 0 END) as ''''BifurcateTaxValue''''                
            
        FROM OPOS T0                  
        LEFT JOIN POS1 T1 ON T0.SaleID = T1.SaleID AND T0.ParentID = T1.ParentID                  
        LEFT JOIN OTAX T2 ON T2.TaxID = T1.TaxID                
        LEFT JOIN TAX1 T3 ON T3.TaxID = T2.TaxID                
        LEFT JOIN TAX2 T4 ON T4.Code = T3.Code                 
            
        WHERE (''''''+ @Parentid + '''''' = ''''0'''' OR T0.ParentID = '''''' + @Parentid + '''''')                 
        AND ('''''' + @CustomerID + '''''' = ''''0'''' OR T0.CustomerID = '''''' + @CustomerID + '''''')                 
        AND CONVERT(DATE, T0.DATE) >= '''''' + CONVERT(VARCHAR(10), @FromDate, 101) + '''''' AND CONVERT(DATE, T0.DATE) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''                 
        AND ('''''' + @InvoiceType + '''''' = ''''0'''' OR T0.ProcessID = '''''' + @InvoiceType + '''''')                 
        AND T1.IsDeleted = 0 AND T0.OrderType IN (1, 12, 13)               
    ) M                
    LEFT JOIN OPOS A on A.SaleID = M.SaleID AND M.ParentId = M.ParentID                 
    LEFT JOIN POS1 B on A.SaleID = B.SaleID AND A.ParentId = B.ParentID AND B.ItemID = M.ItemID AND M.POS1ID = B.POS1ID AND B.IsDeleted = 0                
    LEFT JOIN OCRD C ON C.CustomerID = A.CustomerID                 
            
    WHERE ('''''' + @Parentid + '''''' = ''''0'''' OR A.ParentID = '''''' + @Parentid + '''''')                 
    AND ('''''' + @CustomerID + '''''' = ''''0'''' OR A.CustomerID = '''''' + @CustomerID + '''''')                
    AND CONVERT(DATE, A.DATE) >= '''''' + CONVERT(VARCHAR(10), @FromDate,             
    101) + '''''' AND CONVERT(DATE, A.DATE) <= '''''' + CONVERT(VARCHAR(10), @ToDate, 101) + ''''''                 
    AND ('''''' + @InvoiceType + '''''' = ''''0'''' OR A.ProcessID = '''''' + @InvoiceType + '''''')                 
    AND B.IsDeleted = 0 AND A.OrderType IN (1, 12, 13)                   
            
    GROUP BY A.InvoiceNumber,M.InvoiceType,A.[Date],C.CustomerCode, C.CustomerName,C.VATNumber,M.TaxType,C.CSTNumber,A.ParentID,A.SaleID             
 ) MA                    
            
) X                  
PIVOT                
(                
  SUM(BifurcateTaxValue)                
  FOR TaxType                
  IN ('' + @Cols + '')                
) P)                
            
Select * from Info                 
ORDER BY No''            
 END            
            
 --print @Query                
 EXEC sp_executesql @Query            
END ' 
END
GO
/****** Object:  StoredProcedure [dbo].[SFA_OffBitRouteRequest]    Script Date: 06/15/2017 10:31:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SFA_OffBitRouteRequest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[SFA_OffBitRouteRequest] (@ParentID Decimal(18,0),@EmpID INT, @Date Date)
AS
BEGIN
--Declare @ParentID Decimal(18,0) = 1000010000000000
--Declare @EmpID INT = 2
--Declare @Date Date = ''20170614''

	select  T0.OffBitID as ''Code'',T0.ParentID, T1.Name as ''RequesterName'',T2.RouteCode,T2.RouteName,T0.DateTime, T0.Status from RUT2 T0
	JOIN OEMP T1 ON T1.EmpID = T0.EmpID AND T1.ParentID = T0.ParentID
	JOIN ORUT T2 ON T2.RouteID = T0.RouteID AND T2.ParentID = T0.ParentID
	Where T0.ParentID = @ParentID AND T0.ManagerID = @EmpID AND CONVERT(Date,T0.Datetime) = CONVERT(Date,@Date)
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[BarcodeConflict]    Script Date: 06/15/2017 10:31:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BarcodeConflict]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[BarcodeConflict](@DealerID as Decimal(18,0),@DistributorID as Decimal(18,0),@FromDate as Datetime, @ToDate as Datetime,@PlantID as int,@RegionID int)    
AS        
--Declare               
--@DealerID Decimal(18,0) = 0,              
--@DistributorID Decimal(18,0) = 0,              
--@FromDate Datetime = ''20130501'',              
--@ToDate Datetime = ''20180520'',              
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
      
select T5.CustomerCode as ''Dist Code'',T5.CustomerName as ''Dist Name'', T4.CustomerCode as ''Dealer Code'', T4.CustomerName as ''Dealer Name'',    
CONVERT(nvarchar,t1.Datetime,103) as ''Scan Date'', T6.EmpCode,T6.Name as ''Emp Name'', T7.RouteName,T1.Ref1 as ''BarCode'',T1.Ref2 as ''User Conflict'',T1.Ref3 AS ''System Conflict''    
from ENT1 T1    
INNER join #TEMP T3 on T3.CustomerID = T1.CustID    
JOIN OEMP T6 ON T6.EmpID = T1.EmpID AND T6.ParentID = T1.ParentID    
JOIN ORUT T7 ON T7.RouteID = T1.RouteID AND T7.ParentID = T1.ParentID    
left outer join OCRD T4 on T4.CustomerID = T1.CustID         
left outer join OCRD T5 on T5.CustomerID = T4.ParentID      
WHERE Convert(date,T1.Datetime) >= @FromDate AND Convert(date,T1.Datetime) <= @ToDate AND T1.MenuID = 9105    
    
DROP TABLE #TEMP    
    
END ' 
END
GO
