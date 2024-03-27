
/****** Object:  Index [NonClusteredIndex-20160506-182749]    Script Date: 06/30/2017 12:55:16 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OCRD]') AND name = N'NonClusteredIndex-20160506-182749')
DROP INDEX [NonClusteredIndex-20160506-182749] ON [dbo].[OCRD] WITH ( ONLINE = OFF )
GO



/****** Object:  Index [NonClusteredIndex-20160506-182749]    Script Date: 06/30/2017 12:55:17 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160506-182749] ON [dbo].[OCRD] 
(
	[Type] ASC,
	[CustomerCode] ASC,
	[CustGroupID] ASC,
	[Phone] ASC,
	[Active] ASC,
	[IsTemp] ASC
)
INCLUDE ( [CustomerID],
[ParentID],
[CustomerName],
[Website],
[EMail1],
[Fax],
[Notes],
[Bank],
[BankBranch],
[IFSCCode],
[PANNumber],
[VATNumber],
[CSTNumber],
[GSTIN],
[FoodLicenceNo],
[BarCode],
[Photo],
[CreatedDate],
[CreatedBy],
[UpdatedDate],
[UpdatedBy],
[SyncStatus],
[IsMobile],
[CreditLimit],
[BulkEmail],
[BulkSMS],
[CUsername],
[CPassword],
[IsApplication],
[Gender],
[AllowNotify],
[DeviceID],
[Ratings],
[IsDiscount],
[Latitude],
[Longitude]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


