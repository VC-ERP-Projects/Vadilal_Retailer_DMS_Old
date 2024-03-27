--GO
--Alter table SCM1 ADD CreatedDate datetime
--GO
--Alter table SCM1 ADD Active bit default(1) not null
--GO
--Update b set b.CreatedDate = a.CreatedDate from OSCM a JOIN SCM1 b  ON a.SchemeID = b.SchemeID where A.ApplicableMode = 'M'
--GO

/****** Object:  ForeignKey [FK_OCLM_OCLMP]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCLMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OCLMP]
GO
/****** Object:  ForeignKey [FK_OCLM_OCRD]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OCRD]
GO
/****** Object:  ForeignKey [FK_OCLM_OSCM]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OSCM]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OSCM]
GO
/****** Object:  StoredProcedure [dbo].[SaleReturnItem]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaleReturnItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SaleReturnItem]
GO
/****** Object:  StoredProcedure [dbo].[CheckSCM3]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM3]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CheckSCM3]
GO
/****** Object:  UserDefinedFunction [dbo].[CheckSCM3fn]    Script Date: 12/07/2016 18:04:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM3fn]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[CheckSCM3fn]
GO
/****** Object:  StoredProcedure [dbo].[CheckSCM1]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM1]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CheckSCM1]
GO
/****** Object:  Table [dbo].[OCLM]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCLMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OCLMP]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OCRD]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OSCM]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [FK_OCLM_OSCM]
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_OCLM_TotalQty]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [DF_OCLM_TotalQty]
END
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_OCLM_SchemeAmount]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[OCLM] DROP CONSTRAINT [DF_OCLM_SchemeAmount]
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLM]') AND type in (N'U'))
DROP TABLE [dbo].[OCLM]
GO
/****** Object:  Table [dbo].[OCLMP]    Script Date: 12/07/2016 18:04:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLMP]') AND type in (N'U'))
DROP TABLE [dbo].[OCLMP]
GO
/****** Object:  Table [dbo].[OCLMP]    Script Date: 12/07/2016 18:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLMP]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OCLMP](
	[ParentClaimID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[Date] [datetime] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
 CONSTRAINT [PK_OCLMP] PRIMARY KEY CLUSTERED 
(
	[ParentClaimID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[OCLM]    Script Date: 12/07/2016 18:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLM]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OCLM](
	[ClaimID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[ParentClaimID] [int] NOT NULL,
	[Status] [nvarchar](10) NOT NULL,
	[CustomerID] [numeric](18, 0) NOT NULL,
	[SchemeType] [nvarchar](10) NOT NULL,
	[SchemeID] [int] NOT NULL,
	[ItemID] [int] NULL,
	[ReasonID] [int] NULL,
	[TotalQty] [decimal](18, 3) NOT NULL CONSTRAINT [DF_OCLM_TotalQty]  DEFAULT ((0)),
	[SchemeAmount] [money] NOT NULL CONSTRAINT [DF_OCLM_SchemeAmount]  DEFAULT ((0)),
	[DocType] [nvarchar](50) NULL,
	[SAPDocNo] [nvarchar](max) NULL,
	[SAPErrMsg] [nvarchar](max) NULL,
	[Flag] [nvarchar](50) NULL,
 CONSTRAINT [PK_OCLM] PRIMARY KEY CLUSTERED 
(
	[ClaimID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  StoredProcedure [dbo].[CheckSCM1]    Script Date: 12/07/2016 18:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM1]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[CheckSCM1] (@CustID DECIMAL(18, 0), @SchemeID INT)    
AS    
--DECLARE @CustID DECIMAL(18, 0) = 3000330000100001, @SchemeID INT = 8    
BEGIN    
 DECLARE @Value BIT = 0    
 DECLARE @StateID INT    
 DECLARE @PlantID INT    
 DECLARE @Type INT    
 DECLARE @ParentID DECIMAL(18, 0)    
    
 SELECT @Type = Type, @ParentID = ParentID FROM OCRD WHERE CustomerID = @CustID    
    
 SELECT TOP 1 @PlantID = PlantID FROM OGCRD WHERE CustomerID = @ParentID    
    
 SELECT @StateID = StateID FROM OPLT WHERE PlantID = @PlantID    
    
 --PRINT @StateID    
 --PRINT @PlantID    
 --PRINT @Type    
 --PRINT @ParentID    
 --PRINT @CustID    
    
 IF (SELECT count(*) FROM SCM1 WHERE Active = 1 AND SchemeID = @SchemeID) = 0    
  SET @Value = 1    
 ELSE IF EXISTS (SELECT * FROM SCM1 WHERE Active = 1 AND SchemeID = @SchemeID AND CustomerID = @CustID AND Type = @Type)    
  SET @Value = 1    
 ELSE IF EXISTS (SELECT * FROM SCM1 WHERE Active = 1 AND SchemeID = @SchemeID AND CustomerID = @ParentID AND Type = (@Type - 1))    
  SET @Value = 1    
 ELSE IF EXISTS (SELECT * FROM SCM1 WHERE Active = 1 AND SchemeID = @SchemeID AND PlantID = @PlantID)    
  SET @Value = 1    
 ELSE IF EXISTS (SELECT * FROM SCM1 WHERE Active = 1 AND SchemeID = @SchemeID AND RegionID = @StateID)    
  SET @Value = 1    
 ELSE    
  SET @Value = 0  
    
 SELECT @Value    
END ' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[CheckSCM3fn]    Script Date: 12/07/2016 18:04:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM3fn]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[CheckSCM3fn] (@ItemID INT, @SchemeID INT)
RETURNS INT
AS
BEGIN

 DECLARE @ItemGroupID AS INT    
 DECLARE @ItemSubGroupID AS INT    
 DECLARE @SCM2ItemID AS INT    
 DECLARE @CTSCM2EX AS INT    
 DECLARE @DivisionID AS INT    
  
 DECLARE @selVal AS INT
 
 --Declare @ItemID as int = 53,@SchemeID as int = 72   
   
 SET @ItemSubGroupID = IsNull((SELECT SubGroupID FROM OITM WHERE ItemID = @ItemID), 0)    
 SET @ItemGroupID = IsNull((SELECT GroupID FROM OITM WHERE ItemID = @ItemID), 0)    
 SET @SCM2ItemID = IsNull((SELECT Count(ItemID) FROM SCM3 WHERE ItemID = @ItemID AND IsInclude = 0 AND SchemeID = @SchemeID), 0)    
 SET @CTSCM2EX = IsNull((SELECT Count(SCM3ID) FROM SCM3 WHERE IsInclude = 1 AND SchemeID = @SchemeID ), 0)    
 SET @DivisionID = IsNull((SELECT TOP (1) DivisionlID FROM OGITM WHERE ItemID = @ItemID), 0)    
    
 IF (@CTSCM2EX > 0)    
 BEGIN    
 IF IsNull((SELECT COUNT(T0.ItemGroupID) FROM SCM3 T0 WHERE T0.ItemGroupID = @ItemGroupID AND T0.IsInclude = 1 AND @SCM2ItemID = 0 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  1
  END   
  ELSE IF IsNull((SELECT COUNT(T0.ItemSubGroupID) FROM SCM3 T0 WHERE T0.ItemSubGroupID = @ItemSubGroupID AND T0.IsInclude = 1 AND @SCM2ItemID = 0 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL  OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  1
  END    
  ELSE  IF IsNull((SELECT COUNT(T0.ItemID) FROM SCM3 T0 WHERE T0.ItemID = @ItemID AND T0.IsInclude = 1 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  1
  END    
  ELSE IF IsNull((SELECT COUNT(T0.DivisionID) FROM SCM3 T0 WHERE T0.DivisionID = @DivisionID AND T0.IsInclude = 1 AND T0.SchemeID = @SchemeID), 0) > 0    
  BEGIN    
    IF IsNull((SELECT COUNT(T0.ItemSubGroupID) FROM SCM3 T0 WHERE T0.ItemSubGroupID = @ItemSubGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID), 0) > 0    
    BEGIN    
     set @selVal =  0
    END    
    ELSE IF IsNull((SELECT COUNT(T0.ItemGroupID) FROM SCM3 T0 WHERE T0.ItemGroupID = @ItemGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID), 0) > 0    
    BEGIN    
     set @selVal =  0
    END    
 ELSE IF IsNull((SELECT COUNT(T0.ItemID) FROM SCM3 T0 WHERE T0.ItemID = @ItemID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID), 0) > 0    
   BEGIN    
    set @selVal =  0
   END   
  ELSE  
     BEGIN    
    set @selVal =  1
   END   
  END    
  ELSE    
  BEGIN    
   set @selVal =  0
  END    
 END    
 ELSE    
 BEGIN    
  IF IsNull((SELECT COUNT(T0.ItemID) FROM SCM3 T0 WHERE T0.ItemID = @ItemID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  0
  END    
  ELSE IF IsNull((SELECT COUNT(T0.ItemSubGroupID) FROM SCM3 T0 WHERE T0.ItemSubGroupID = @ItemSubGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  0
  END    
  ELSE IF IsNull((SELECT COUNT(T0.ItemGroupID) FROM SCM3 T0 WHERE T0.ItemGroupID = @ItemGroupID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID AND (T0.DivisionID IS NULL OR T0.DivisionID = @DivisionID)), 0) > 0    
  BEGIN    
   set @selVal =  0
  END    
  ELSE IF IsNull((SELECT COUNT(T0.DivisionID) FROM SCM3 T0 WHERE T0.DivisionID = @DivisionID AND T0.IsInclude = 0 AND T0.SchemeID = @SchemeID), 0) > 0    
  BEGIN    
   set @selVal =  0
  END    
  ELSE    
  BEGIN    
   set @selVal =  1
  END    
 END   
 
 RETURN @selVal 
END
' 
END
GO
/****** Object:  StoredProcedure [dbo].[CheckSCM3]    Script Date: 12/07/2016 18:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckSCM3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[CheckSCM3] (@ItemID AS INT, @SchemeID AS INT)    
AS    
BEGIN    
 
	SELECT [dbo].CheckSCM3fn(@ItemID, @SchemeID) AS	STATUS
END ' 
END
GO
/****** Object:  StoredProcedure [dbo].[SaleReturnItem]    Script Date: 12/07/2016 18:04:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaleReturnItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[SaleReturnItem] (@ParentID NUMERIC(18, 0), @SaleID INT)
AS
BEGIN
	--DECLARE @ParentID NUMERIC(18, 0) = 2000010000100000    
	--DECLARE @SaleID INT = 1  
	
	SELECT T.ItemID, T.ItemCode, T.ItemName, S.DispatchQty, S.UnitID, (SELECT UnitName FROM OUNT A WHERE A.UnitID = S.UnitID) AS Unitname,
	S.MapQty AS Quantity, S.Scheme, S.ItemScheme, S.UnitPrice, S.PriceTax, S.TaxID,S.SchemeID, S.TotalQty, 
	STUFF((SELECT  '','' + a.items FROM dbo.Split(O.SchemeID, '','') a 
	LEFT OUTER JOIN SCM4 b ON a.items = b.SchemeID WHERE b.BasedOn = 1 FOR XML PATH(''''), TYPE ).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') 
     as MasterSchemeID
	FROM OPOS O
	LEFT JOIN POS1 S ON O.SaleID = S.SaleID AND O.ParentID = S.ParentID
	LEFT JOIN OITM T ON T.ItemID = S.ItemID
	WHERE S.ParentID = @ParentID AND O.SaleID = @SaleID AND s.IsDeleted = 0
END
' 
END
GO
/****** Object:  ForeignKey [FK_OCLM_OCLMP]    Script Date: 12/07/2016 18:04:54 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCLMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM]  WITH CHECK ADD  CONSTRAINT [FK_OCLM_OCLMP] FOREIGN KEY([ParentClaimID], [ParentID])
REFERENCES [dbo].[OCLMP] ([ParentClaimID], [ParentID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCLMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] CHECK CONSTRAINT [FK_OCLM_OCLMP]
GO
/****** Object:  ForeignKey [FK_OCLM_OCRD]    Script Date: 12/07/2016 18:04:54 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM]  WITH CHECK ADD  CONSTRAINT [FK_OCLM_OCRD] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[OCRD] ([CustomerID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] CHECK CONSTRAINT [FK_OCLM_OCRD]
GO
/****** Object:  ForeignKey [FK_OCLM_OSCM]    Script Date: 12/07/2016 18:04:54 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OSCM]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM]  WITH CHECK ADD  CONSTRAINT [FK_OCLM_OSCM] FOREIGN KEY([SchemeID])
REFERENCES [dbo].[OSCM] ([SchemeID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OCLM_OSCM]') AND parent_object_id = OBJECT_ID(N'[dbo].[OCLM]'))
ALTER TABLE [dbo].[OCLM] CHECK CONSTRAINT [FK_OCLM_OSCM]
GO
