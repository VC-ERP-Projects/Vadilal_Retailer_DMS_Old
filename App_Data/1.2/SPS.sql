CREATE PROC LoadOrders(@PageIndex INT = 1,@PageSize INT = 50,@ParentID DECIMAL(18, 0) = 2000010000100000,@InvNo NVARCHAR(50) = '',@OrderType INT = 13,@SDATE DATE = '20160301',@EDATE DATE = '20170301')
AS
BEGIN
--DECLARE @PageIndex INT = 1
--DECLARE @PageSize INT = 50
--DECLARE @ParentID DECIMAL(18, 0) = 2000010000100000
--DECLARE @InvNo NVARCHAR(50) = ''
--DECLARE @OrderType INT = 13
--DECLARE @SDATE DATE = '20160301'
--DECLARE @EDATE DATE = '20170301'

SELECT A.*
FROM (
	SELECT ROW_NUMBER() OVER (
			ORDER BY O.InvoiceNumber
			) AS RowNum, O.InvoiceNumber, O.BillRefNo, V.VehicleNumber, C.CustomerName, O.DATE, O.Total, O.SubTotal, O.Tax, O.Scheme, O.Paid, O.Pending
	FROM OPOS O
	INNER JOIN OCRD C ON C.CustomerID = O.CustomeriD
	LEFT JOIN OVCL V ON V.VehicleID = O.VehicleID AND V.ParentID = O.ParentID
	WHERE O.ParentID = 2000010000100000 AND (@InvNo = '' OR O.InvoiceNUmber = @InvNo) 
	AND O.OrderType = @OrderType 
	AND (@InvNo != '' OR CONVERT(DATE, O.DATE) >= @SDATE AND CONVERT(DATE, O.DATE) <= @EDATE)
	) A
WHERE A.RowNum BETWEEN ((@PageIndex - 1) * @PageSize + 1) AND (@PageIndex * @PageSize)
ORDER BY A.InvoiceNumber
END