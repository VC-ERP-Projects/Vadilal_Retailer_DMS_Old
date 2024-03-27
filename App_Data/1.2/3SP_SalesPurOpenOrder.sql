
GO
/****** Object:  StoredProcedure [dbo].[SaleItem]    Script Date: 05/04/2016 14:52:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaleItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SaleItem]
GO
/****** Object:  StoredProcedure [dbo].[PurchaseItem]    Script Date: 05/04/2016 14:52:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PurchaseItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PurchaseItem]
GO
/****** Object:  StoredProcedure [dbo].[LoadOrders]    Script Date: 05/04/2016 14:52:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadOrders]
GO
/****** Object:  StoredProcedure [dbo].[LoadOrders]    Script Date: 05/04/2016 14:52:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LoadOrders](@PageIndex INT ,@PageSize INT ,@ParentID DECIMAL(18, 0) ,@InvNo INT ,@OrderType INT ,@SDATE DATE ,@EDATE DATE ,@VehicleNo INT,@Company INT,@CustomerID DECIMAL(18, 0))    
AS    
BEGIN    
--DECLARE @PageIndex INT = 1    
--DECLARE @PageSize INT = 50    
--DECLARE @ParentID DECIMAL(18, 0) = 2000010000100000    
--DECLARE @InvNo INT = 0   
--DECLARE @OrderType INT = 13    
--DECLARE @SDATE DATE = ''20160301''    
--DECLARE @EDATE DATE = ''20170301''    
--DEclare @VehicleNo INT=0  
--DECLARE @Company INT =0 
--DEclare @CustomerID DECIMAL(18, 0) = 3000330000100001 
  
IF(@Company=1)  
begin    
SELECT A.*    
FROM (    
 SELECT ROW_NUMBER() OVER (    
   ORDER BY O.SaleID    
   ) AS RowNum, O.InvoiceNumber,O.SaleID,O.BillRefNo, C.ParentID,V.VehicleNumber, C.CustomerName, O.DATE, O.Total, O.SubTotal, O.Tax, O.Scheme, O.Paid, O.Pending    
 FROM OPOS O    
 INNER JOIN OCRD C ON C.CustomerID = O.CustomeriD    
 LEFT JOIN OVCL V ON V.VehicleID = O.VehicleID AND V.ParentID = O.ParentID   
 WHERE O.ParentID = @ParentID AND (@InvNo = '''' OR O.SaleID = @InvNo)     
 AND O.OrderType = @OrderType     
 AND (@InvNo != '''' OR CONVERT(DATE, O.DATE) >= @SDATE AND CONVERT(DATE, O.DATE) <= @EDATE)   and (@VehicleNo=0 or V.VehicleID=@VehicleNo)   
 ) A    
WHERE A.RowNum BETWEEN ((@PageIndex - 1) * @PageSize + 1) AND (@PageIndex * @PageSize)    
ORDER BY A.SaleID    
  
SELECT COunt(1)  
 FROM OPOS O    
 INNER JOIN OCRD C ON C.CustomerID = O.CustomeriD    
 LEFT JOIN OVCL V ON V.VehicleID = O.VehicleID AND V.ParentID = O.ParentID   
 WHERE O.ParentID = @ParentID AND (@InvNo = '''' OR O.SaleID = @InvNo)     
 AND O.OrderType = @OrderType     
 AND (@InvNo != '''' OR CONVERT(DATE, O.DATE) >= @SDATE AND CONVERT(DATE, O.DATE) <= @EDATE)   and (@VehicleNo=0 or V.VehicleID=@VehicleNo)   
  
END  
else  
begin    
 SELECT A.*    
 FROM (    
  SELECT ROW_NUMBER() OVER (    
    ORDER BY O.SaleID    
    ) AS RowNum, O.InvoiceNumber,O.SaleID,O.BillRefNo, C.ParentID,V.VehicleNumber, C.CustomerName, O.DATE, O.Total, O.SubTotal, O.Tax, O.Scheme, O.Paid, O.Pending    
  FROM OPOS O    
  INNER JOIN OCRD C ON C.CustomerID = O.CustomeriD    
  LEFT JOIN OVCL V ON V.VehicleID = O.VehicleID AND V.ParentID = O.ParentID    
  WHERE O.ParentID = @ParentID AND (@InvNo = '''' OR O.SaleID = @InvNo)  and (@CustomerID = 0 OR O.CustomerID = @CustomerID) 
  AND O.OrderType = @OrderType     
  AND (@InvNo != '''' OR CONVERT(DATE, O.DATE) >= @SDATE AND CONVERT(DATE, O.DATE) <= @EDATE) and (@VehicleNo=0 or V.VehicleID=@VehicleNo)    
  ) A    
 WHERE A.RowNum BETWEEN ((@PageIndex - 1) * @PageSize + 1) AND (@PageIndex * @PageSize)    
 ORDER BY A.SaleID    
  
  
 select COUNT(1)  
  FROM OPOS O    
  INNER JOIN OCRD C ON C.CustomerID = O.CustomeriD    
  LEFT JOIN OVCL V ON V.VehicleID = O.VehicleID AND V.ParentID = O.ParentID    
  WHERE O.ParentID = @ParentID AND (@InvNo = '''' OR O.SaleID = @InvNo)     
  AND O.OrderType = @OrderType     
  AND (@InvNo != '''' OR CONVERT(DATE, O.DATE) >= @SDATE AND CONVERT(DATE, O.DATE) <= @EDATE) and (@VehicleNo=0 or V.VehicleID=@VehicleNo)  ;  
 END  
end  ' 
END
GO
/****** Object:  StoredProcedure [dbo].[PurchaseItem]    Script Date: 05/04/2016 14:52:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PurchaseItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'  
CREATE PROCEDURE [dbo].[PurchaseItem] (@ParentID NUMERIC(18, 0), @PriceID INT, @InwardID INT, @ItemID INT, @TemplateID INT, @WhsID INT)  
AS  
BEGIN  
 --DECLARE @ParentID NUMERIC(18, 0) = 2000010000100000  
 --DECLARE @PriceID INT = 1  
 --DECLARE @SaleID INT = 0  
 --DECLARE @ItemID INT = 0  
 --DECLARE @TemplateID INT = 1  
 --DECLARE @WhsID INT = 1  
 --DEclare @InwardID INT=1  
  
 IF (@InwardID > 0)  
 BEGIN  
  SELECT T.ItemID, T.ItemCode, T.ItemName, ISNULL(M.TotalPacket, 0) AvailQty, S.UnitID, (Select UnitName from OUNT A where A.UnitID=S.UnitID ) as Unitname,S.RecieptQty as DispatchQty ,S.MapQty as Quantity, S.Price as UnitPrice,S.PriceTax AS Tax, S.TaxID,S
.RANKNO  
  FROM OMID O  
  LEFT JOIN MID1 S ON O.InwardID = S.InwardID AND O.ParentID = S.ParentID  
  LEFT JOIN OITM T ON T.ItemID = S.ItemID    
  LEFT JOIN ITM2 M ON T.ItemID = M.ItemID AND M.ParentID = S.ParentID AND M.WhsID = @WhsID   
  WHERE S.ParentID = @ParentID and O.InwardID=@InwardID  
 END  
 ELSE IF (@TemplateID > 0)  
 BEGIN  
  SELECT O.ItemID, O.ItemCode, O.ItemName, ISNULL(M.TotalPacket, 0) AvailQty,0.00 as DispatchQty ,P.UnitID, U.Unitname, I.Quantity, P.UnitPrice, Convert(NUMERIC(18, 4), (P.UnitPrice * T.Percentage) / 100) AS Tax, T.TaxID,0.00 as RANKNO  
  FROM OITM O  
  LEFT JOIN SITM S ON O.ItemID = S.ItemID  
  LEFT JOIN ITM1 I ON O.ItemID = I.ItemID  
  LEFT JOIN IPL1 P ON O.ItemID = P.ItemID AND I.UnitID = P.UnitID  
  LEFT JOIN OTAX T ON P.TaxID = T.TaxID  
  LEFT JOIN OUNT U ON U.UnitID = P.UnitID  
  LEFT JOIN ITM2 M ON O.ItemID = M.ItemID AND M.ParentID = S.ParentID AND M.WhsID = @WhsID  
  WHERE S.ParentID = @ParentID AND I.UnitType IN (1, 3) AND P.PriceListID = @PriceID AND S.TemplateID = @TemplateID   
  ORDER BY S.Priority  
 END  
 ELSE  
 BEGIN  
  SELECT O.ItemID, O.ItemCode, O.ItemName, ISNULL(M.TotalPacket, 0) AvailQty, P.UnitID, 0.00 as DispatchQty ,U.Unitname, I.Quantity, P.UnitPrice, Convert(NUMERIC(18, 4), (P.UnitPrice * T.Percentage) / 100) AS Tax, T.TaxID, 0.00 as RANKNO  
  FROM OITM O  
  LEFT JOIN ITM1 I ON O.ItemID = I.ItemID  
  LEFT JOIN IPL1 P ON O.ItemID = P.ItemID AND I.UnitID = P.UnitID  
  LEFT JOIN OTAX T ON P.TaxID = T.TaxID  
  LEFT JOIN OUNT U ON U.UnitID = P.UnitID  
  LEFT JOIN ITM2 M ON O.ItemID = M.ItemID AND M.ParentID = @ParentID AND M.WhsID = @WhsID  
  WHERE I.UnitType IN (1, 3) AND P.PriceListID = @PriceID AND P.PriceListID = @PriceID AND O.ItemID = @ItemID  
 END  
END  ' 
END
GO
/****** Object:  StoredProcedure [dbo].[SaleItem]    Script Date: 05/04/2016 14:52:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaleItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[SaleItem] (@ParentID NUMERIC(18, 0), @PriceID INT, @SaleID INT, @ItemID INT, @TemplateID INT, @WhsID INT)
AS
BEGIN
	--DECLARE @ParentID NUMERIC(18, 0) = 2000010000100000
	--DECLARE @PriceID INT = 7
	--DECLARE @SaleID INT = 0
	--DECLARE @ItemID INT = 970
	--DECLARE @TemplateID INT = 0
	--DECLARE @WhsID INT = 1

	IF (@SaleID > 0)
	BEGIN
		SELECT T.ItemID, T.ItemCode, T.ItemName, ISNULL(M.TotalPacket, 0) AvailQty,S.DispatchQty as ''DispatchQty'' , S.UnitID, (Select UnitName from OUNT A where A.UnitID=S.UnitID ) as Unitname, s.MapQty as Quantity, S.UnitPrice,  S.PriceTax AS Tax, S.TaxID,S.TotalQty
		FROM OPOS O
		LEFT JOIN POS1 S ON O.SaleID = S.SaleID AND O.ParentID = S.ParentID
		LEFT JOIN OITM T ON T.ItemID = S.ItemID		
		LEFT JOIN ITM2 M ON S.ItemID = M.ItemID AND M.ParentID = O.ParentID AND M.WhsID = @WhsID 
		WHERE S.ParentID = @ParentID   and  O.SaleID=@SaleID AND s.IsDeleted = 0 --AND P.PriceListID = @PriceID 	
	END
	ELSE IF (@TemplateID > 0)
	BEGIN
		SELECT O.ItemID, O.ItemCode, O.ItemName, ISNULL(M.TotalPacket, 0) AvailQty, 0.00 as DispatchQty,  P.UnitID, U.Unitname, I.Quantity, P.UnitPrice, Convert(NUMERIC(18, 2), (P.UnitPrice * T.Percentage) / 100) AS Tax, T.TaxID,0.00  as TotalQty
		FROM OITM O
		LEFT JOIN SITM S ON O.ItemID = S.ItemID
		LEFT JOIN ITM1 I ON O.ItemID = I.ItemID
		LEFT JOIN IPL1 P ON O.ItemID = P.ItemID AND I.UnitID = P.UnitID
		LEFT JOIN OTAX T ON P.TaxID = T.TaxID
		LEFT JOIN OUNT U ON U.UnitID = P.UnitID
		LEFT JOIN ITM2 M ON O.ItemID = M.ItemID AND M.ParentID = S.ParentID AND M.WhsID = @WhsID
		WHERE S.ParentID = @ParentID AND I.UnitType IN (1, 3) AND P.PriceListID = @PriceID AND S.TemplateID = @TemplateID 
		ORDER BY S.Priority
	END
	ELSE
	BEGIN
		SELECT O.ItemID, O.ItemCode, O.ItemName, ISNULL(M.TotalPacket, 0) AvailQty, 0.00 as DispatchQty, P.UnitID, U.Unitname, I.Quantity, P.UnitPrice, Convert(NUMERIC(18, 2), (P.UnitPrice * T.Percentage) / 100) AS Tax, T.TaxID,0.00  as TotalQty
		FROM OITM O
		LEFT JOIN ITM1 I ON O.ItemID = I.ItemID
		LEFT JOIN IPL1 P ON O.ItemID = P.ItemID AND I.UnitID = P.UnitID
		LEFT JOIN OTAX T ON P.TaxID = T.TaxID
		LEFT JOIN OUNT U ON U.UnitID = P.UnitID
		LEFT JOIN ITM2 M ON O.ItemID = M.ItemID AND M.ParentID = @ParentID AND M.WhsID = @WhsID
		WHERE I.UnitType IN (1, 3) AND P.PriceListID = @PriceID AND P.PriceListID = @PriceID AND O.ItemID = @ItemID
	END
END
' 
END
GO
