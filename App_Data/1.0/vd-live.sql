
ALTER TABLE OCRD ADD CUsername nvarchar(50)
GO
ALTER TABLE OCRD ADD CPassword nvarchar(100)
GO
ALTER TABLE OCRD ADD CSeqQuestion nvarchar(50)
GO
ALTER TABLE OCRD ADD CSeqAnswer nvarchar(50)
GO
ALTER TABLE OCRD ADD IsApplication bit not null default 0
GO
ALTER TABLE OCRD ADD Gender nvarchar(10)
GO
ALTER TABLE OPOS ADD BranchID int
GO
ALTER TABLE OPOS ADD OutletID int
GO
ALTER TABLE OCRD ADD AllowNotify bit not null default(0)
GO

ALTER TABLE CRD1 ADD IsDeleted bit not null default 0
GO
ALTER TABLE CRD2 ADD IsDeleted bit not null default 0
GO
ALTER TABLE EOD3 ADD IsDeleted bit not null default 0
GO
ALTER TABLE BOM1 ADD IsDeleted bit not null default 0
GO
ALTER TABLE VND1 ADD IsDeleted bit not null default 0
GO


/****** Object:  Table [dbo].[ONTF]    Script Date: 08/01/2015 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ONTF](
	[NotifyID] [bigint] IDENTITY(1,1) NOT NULL,
	[Subject] [nvarchar](200) NULL,
	[Message] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ONTF] PRIMARY KEY CLUSTERED 
(
	[NotifyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OGCM]    Script Date: 08/01/2015 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OGCM](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[GCM_REGID] [nvarchar](max) NULL,
	[DeviceID] [nvarchar](max) NULL,
	[RegisteredDate] [datetime] NULL,
	[TotalCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OCPN]    Script Date: 08/01/2015 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OCPN](
	[CouponID] [int] NOT NULL,
	[CouponCode] [nvarchar](100) NOT NULL,
	[CouponName] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[DiscountType] [nvarchar](1) NULL,
	[DiscountValue] [decimal](18, 2) NULL,
	[StartDate] [date] NULL,
	[StartTime] [time](7) NULL,
	[ExpireDate] [date] NULL,
	[ExpireTime] [time](7) NULL,
	[IsMultipleUse] [bit] NULL,
	[MaxNoUsuable] [int] NULL,
	[TotalNoUsuable] [int] NULL,
	[IsNewUser] [bit] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_OCPN] PRIMARY KEY CLUSTERED 
(
	[CouponID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OTLT]    Script Date: 08/01/2015 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OTLT](
	[OutletID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[TypeID] [int] NOT NULL,
	[Shift1ST] [time](7) NULL,
	[Shift1ET] [time](7) NULL,
	[Shift2ST] [time](7) NULL,
	[Shift2ET] [time](7) NULL,
	[Shift3ST] [time](7) NULL,
	[Shift3ET] [time](7) NULL,
	[Shift4ST] [time](7) NULL,
	[Shift4ET] [time](7) NULL,
	[CPurchasePriceListID] [int] NULL,
	[PurchasePriceListID] [int] NULL,
	[RetailPriceListID] [int] NOT NULL,
	[WholeSalePriceListID] [int] NULL,
	[ServiceTax] [nvarchar](1) NULL,
	[ServiceTaxAmt] [money] NOT NULL,
	[SeatingCapacity] [nvarchar](1) NULL,
	[SeatingCapacityAmt] [money] NOT NULL,
	[GiftSales] [bit] NOT NULL,
	[HomeDelivery] [bit] NOT NULL,
	[NegativeInventory] [bit] NOT NULL,
	[TaxOnParcel] [bit] NOT NULL,
	[POSAmountMandatory] [bit] NOT NULL,
	[POSQuantityEdit] [bit] NOT NULL,
	[HelpDeskNumber] [nvarchar](20) NULL,
	[OutletLogo] [nvarchar](100) NULL,
	[Active] [bit] NOT NULL,
	[SyncStatus] [bit] NOT NULL,
	[Latitude] [nvarchar](250) NULL,
	[Longitude] [nvarchar](250) NULL,
 CONSTRAINT [PK_OTLT] PRIMARY KEY CLUSTERED 
(
	[OutletID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF_OCPN_IsMultipleUse]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OCPN] ADD  CONSTRAINT [DF_OCPN_IsMultipleUse]  DEFAULT ((0)) FOR [IsMultipleUse]
GO
/****** Object:  Default [DF_OCPN_IsNewUser]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OCPN] ADD  CONSTRAINT [DF_OCPN_IsNewUser]  DEFAULT ((0)) FOR [IsNewUser]
GO
/****** Object:  Default [DF_OCPN_Active]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OCPN] ADD  CONSTRAINT [DF_OCPN_Active]  DEFAULT ((0)) FOR [Active]
GO
/****** Object:  Default [DF_OTLT_ServiceTaxAmt]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_ServiceTaxAmt]  DEFAULT ((0)) FOR [ServiceTaxAmt]
GO
/****** Object:  Default [DF_OTLT_SeatingCapacityAmt]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_SeatingCapacityAmt]  DEFAULT ((0)) FOR [SeatingCapacityAmt]
GO
/****** Object:  Default [DF_OTLT_GiftSales]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_GiftSales]  DEFAULT ((0)) FOR [GiftSales]
GO
/****** Object:  Default [DF_OTLT_HomeDelivery]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_HomeDelivery]  DEFAULT ((0)) FOR [HomeDelivery]
GO
/****** Object:  Default [DF_OTLT_NegativeInventory]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_NegativeInventory]  DEFAULT ((0)) FOR [NegativeInventory]
GO
/****** Object:  Default [DF_OTLT_TaxOnParcel]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_TaxOnParcel]  DEFAULT ((0)) FOR [TaxOnParcel]
GO
/****** Object:  Default [DF_OTLT_POSAmountMandatory]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_POSAmountMandatory]  DEFAULT ((0)) FOR [POSAmountMandatory]
GO
/****** Object:  Default [DF_OTLT_POSQuantityEdit]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_POSQuantityEdit]  DEFAULT ((0)) FOR [POSQuantityEdit]
GO
/****** Object:  Default [DF_OTLT_Active]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_Active]  DEFAULT ((0)) FOR [Active]
GO
/****** Object:  Default [DF_OTLT_SyncStatus]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT] ADD  CONSTRAINT [DF_OTLT_SyncStatus]  DEFAULT ((0)) FOR [SyncStatus]
GO
/****** Object:  ForeignKey [FK_OTLT_OCRD]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT]  WITH CHECK ADD  CONSTRAINT [FK_OTLT_OCRD] FOREIGN KEY([ParentID])
REFERENCES [dbo].[OCRD] ([CustomerID])
GO
ALTER TABLE [dbo].[OTLT] CHECK CONSTRAINT [FK_OTLT_OCRD]
GO
/****** Object:  ForeignKey [FK_OTLT_OIPLRetail]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT]  WITH CHECK ADD  CONSTRAINT [FK_OTLT_OIPLRetail] FOREIGN KEY([RetailPriceListID])
REFERENCES [dbo].[OIPL] ([PriceListID])
GO
ALTER TABLE [dbo].[OTLT] CHECK CONSTRAINT [FK_OTLT_OIPLRetail]
GO
/****** Object:  ForeignKey [FK_OTLT_OTLTWhole]    Script Date: 08/01/2015 16:57:45 ******/
ALTER TABLE [dbo].[OTLT]  WITH CHECK ADD  CONSTRAINT [FK_OTLT_OTLTWhole] FOREIGN KEY([WholeSalePriceListID])
REFERENCES [dbo].[OIPL] ([PriceListID])
GO
ALTER TABLE [dbo].[OTLT] CHECK CONSTRAINT [FK_OTLT_OTLTWhole]
GO



