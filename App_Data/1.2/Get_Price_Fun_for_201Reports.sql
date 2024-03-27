CREATE FUNCTION [dbo].[GetPrice] (@ItemID INT, @ParentID DECIMAL(18, 0))  
RETURNS MONEY  
AS  
BEGIN  
 --DECLARE @ItemID INT = 1, @PriceListID INT = 1, @ParentID DECIMAL(18, 0)=2000010000100000  
 DECLARE @Price MONEY = 0  
  
 IF (EXISTS (SELECT M.Price FROM MID1 M WHERE M.ItemID = @ItemID AND M.ParentID = @ParentID))  
 BEGIN  
  SELECT @Price = ISNULL(M.Price, 0)  
  FROM OMID O  
  INNER JOIN MID1 M ON O.InwardID = M.InwardID AND O.ParentID = M.ParentID  
  WHERE M.ItemID = @ItemID AND O.ParentID = @ParentID  
  ORDER BY O.DATE DESC  
 END  
 RETURN @Price  
END  