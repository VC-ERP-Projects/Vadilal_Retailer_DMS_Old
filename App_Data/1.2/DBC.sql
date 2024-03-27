ALTER TABLE MID1 ADD RANKNO nvarchar(10)
GO
ALTER TABLE RET1 ADD [Desc] nvarchar(max)
GO
ALTER TABLE OCFG ADD SAPLINK NVARCHAR(MAX)
GO
ALTER TABLE OCFG ADD SAPRLINK NVARCHAR(MAX)
GO
ALTER TABLE RET1 ADD RANKNO nvarchar(10)
GO
ALTER TABLE SCM4 ADD UnitID INT NULL
GO
ALTER TABLE OMID DROP COLUMN Longitude 
GO
ALTER TABLE OMID DROP COLUMN Latitude 
GO
ALTER TABLE OPOS DROP COLUMN Longitude 
GO
ALTER TABLE OMID ADD Attachment nvarchar(50)
GO
ALTER TABLE OPOS DROP COLUMN Latitude 
GO
Alter TABLE ret1 add TaxID int null
GO
ALTER table ocfg add InvoicePrintSize Nvarchar(2) null default(A4)

GO

ALTER PROCEDURE [dbo].[GetPrice] (@ItemID INT, @UnitID INT, @PriceListID INT)
AS
--DECLARE @ItemID INT=60
--DECLARE  @UnitID INT=3
--DECLARE  @PriceListID INT =3
BEGIN
	SELECT T0.ItemID, T0.ItemName, T2.UnitPrice,T3.TaxID, T2.DiscountAmt,T2.SellPrice,T3.Percentage as PerTax, Isnull(Convert(DECIMAL(18, 4), T2.SellPrice * T3.Percentage / 100, 0), 0) AS 'Tax', Isnull((T2.SellPrice + Isnull(Convert(DECIMAL(18, 4), T2.SellPrice * T3.Percentage / 100, 0), 0)),0) AS 'TaxSellPrice'
	FROM OITM T0
	Left Outer JOIN ITM1 T1 ON T0.ItemID = T1.ItemID 
	Left Outer JOIN IPL1 T2 ON T2.UnitID = T1.UnitID AND T2.ItemID = T1.ItemID
	Left Outer JOIN OTAX T3 ON T3.TaxID = T2.TaxID
	
	WHERE T0.ItemID = @ItemID AND T2.PriceListID = @PriceListID
	AND T1.UnitID= @UnitID AND T1.Active = 1
	
END
GO
ALTER  FUNCTION [dbo].[Split](@String varchar(MAX), @Delimiter char(1))        
returns @temptable TABLE (items varchar(MAX),tempid int)        
as        
begin        
    declare @idx int        
    declare @slice varchar(MAX)        
       
    select @idx = 1        
        if len(@String)<1 or @String is null  return        
     declare @cnt int = 0
    while @idx!= 0        
    begin        
        set @idx = charindex(@Delimiter,@String)        
        if @idx!=0        
            set @slice = left(@String,@idx - 1)        
        else        
            set @slice = @String        
           
        if(len(@slice)>0)
        begin  
			set @cnt = @cnt+1
            insert into @temptable(Items,tempid) values(@slice,@cnt)        
            end
  
        set @String = right(@String,len(@String) - @idx)        
        if len(@String) = 0 break        
    end    
return        
end

GO
ALTER TABLE dbo.SCM4 ADD CONSTRAINT
	FK_SCM4_OUNT FOREIGN KEY
	(
	UnitID
	) REFERENCES dbo.OUNT
	(
	UnitID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO


