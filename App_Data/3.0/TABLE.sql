
CREATE TABLE [dbo].[ORDR](
	[OrderID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[Date] [datetime] NOT NULL,
	[OrderType] [int] NOT NULL,
	[SalesPerSonID] [int] NULL,
	[IsWholeSale] [bit] NOT NULL,
	[Total] [money] NOT NULL,
	[Discount] [money] NOT NULL,
	[Rounding] [money] NOT NULL,
	[Delivery] [money] NOT NULL,
	[Tax] [money] NOT NULL,
	[ServiceTax] [money] NOT NULL,
	[Advance] [money] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[Paid] [money] NOT NULL,
	[Scheme] [money] NOT NULL,
	[Pending] [money] NOT NULL,
	[Notes] [varchar](max) NULL,
	[CustomerID] [numeric](18, 0) NULL,
	[RequiredDate] [datetime] NULL,
	[RequiredTime] [time](7) NULL,
	[ChargedBy] [nvarchar](50) NULL,
	[DeliveredDate] [datetime] NULL,
	[DeliveredTime] [time](7) NULL,
	[DeliveryBoy] [nvarchar](50) NULL,
	[MobilieNumber] [nvarchar](15) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
	[SyncStatus] [bit] NOT NULL,
	[IsDelivered] [bit] NOT NULL,
	[BillRefNo] [nvarchar](100) NULL,
	[Ref1] [nvarchar](100) NULL,
	[ErrMsg] [nvarchar](max) NULL,
	[WaitingID] [int] NULL,
	[SchemeID] [nvarchar](max) NULL,
	[ProcessID] [int] NULL,
	[IsMobile] [bit] NOT NULL,
	[BranchID] [int] NULL,
	[OutletID] [int] NULL,
	[InvoiceDate] [datetime] NULL,
	[VehicleID] [int] NULL,
	[ContraTax] [nvarchar](max) NULL,
	[OrderTypeReasonID] [int] NULL,
	[Attachment] [nvarchar](50) NULL,
	[InvoiceNumber] [nvarchar](50) NULL,
	[Ref2] [nvarchar](max) NULL,
	[DocType] [varchar](1) NULL,
 CONSTRAINT [PK_ORDR] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RDR1]    Script Date: 26-10-2017 10:55:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RDR1](
	[RDR1ID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[MainID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[FoodTypeID] [int] NULL,
	[IsParcel] [bit] NOT NULL,
	[ItemID] [int] NOT NULL,
	[UnitID] [int] NOT NULL,
	[Duration] [int] NOT NULL,
	[SchemeID] [int] NULL,
	[HandleEmpID] [int] NULL,
	[Quantity] [money] NOT NULL,
	[TotalQty] [money] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[PriceTax] [money] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[MapQty] [money] NOT NULL,
	[Tax] [money] NOT NULL,
	[Discount] [money] NOT NULL,
	[Price] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[AddOn] [bit] NOT NULL,
	[SyncStatus] [bit] NOT NULL,
	[TaxID] [int] NULL,
	[Scheme] [money] NOT NULL,
	[ItemScheme] [money] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[MRP] [money] NOT NULL,
	[PPrice] [money] NULL,
 CONSTRAINT [PK_RDR1] PRIMARY KEY CLUSTERED 
(
	[RDR1ID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ORDR] ADD  CONSTRAINT [DF_ORDR_Scheme]  DEFAULT ((0)) FOR [Scheme]
GO
ALTER TABLE [dbo].[ORDR] ADD  CONSTRAINT [DF_ORDR_SyncStatus]  DEFAULT ((0)) FOR [SyncStatus]
GO
ALTER TABLE [dbo].[ORDR] ADD  CONSTRAINT [DF_ORDR_IsDelivered]  DEFAULT ((0)) FOR [IsDelivered]
GO
ALTER TABLE [dbo].[ORDR] ADD  DEFAULT ((0)) FOR [IsMobile]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_IsParcel]  DEFAULT ((0)) FOR [IsParcel]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Duration]  DEFAULT ((0)) FOR [Duration]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_SchemeID]  DEFAULT ((0)) FOR [SchemeID]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_TotalQty]  DEFAULT ((0)) FOR [TotalQty]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_UnitPrice]  DEFAULT ((0)) FOR [UnitPrice]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_PriceTax]  DEFAULT ((0)) FOR [PriceTax]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_SubTotal]  DEFAULT ((0)) FOR [SubTotal]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_MapQty]  DEFAULT ((0)) FOR [MapQty]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Tax]  DEFAULT ((0)) FOR [Tax]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Price]  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Total]  DEFAULT ((0)) FOR [Total]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_AddOn]  DEFAULT ((0)) FOR [AddOn]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_SyncStatus]  DEFAULT ((0)) FOR [SyncStatus]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_Scheme]  DEFAULT ((0)) FOR [Scheme]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_ItemScheme]  DEFAULT ((0)) FOR [ItemScheme]
GO
ALTER TABLE [dbo].[RDR1] ADD  CONSTRAINT [DF_RDR1_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RDR1] ADD  DEFAULT ((0)) FOR [MRP]
GO
ALTER TABLE [dbo].[ORDR]  WITH CHECK ADD  CONSTRAINT [FK_ORDR_OCRD] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[OCRD] ([CustomerID])
GO
ALTER TABLE [dbo].[ORDR] CHECK CONSTRAINT [FK_ORDR_OCRD]
GO
ALTER TABLE [dbo].[ORDR]  WITH CHECK ADD  CONSTRAINT [FK_ORDR_OEMP] FOREIGN KEY([SalesPerSonID], [ParentID])
REFERENCES [dbo].[OEMP] ([EmpID], [ParentID])
GO
ALTER TABLE [dbo].[ORDR] CHECK CONSTRAINT [FK_ORDR_OEMP]
GO
ALTER TABLE [dbo].[ORDR]  WITH CHECK ADD  CONSTRAINT [FK_ORDR_OVCL] FOREIGN KEY([VehicleID], [ParentID])
REFERENCES [dbo].[OVCL] ([VehicleID], [ParentID])
GO
ALTER TABLE [dbo].[ORDR] CHECK CONSTRAINT [FK_ORDR_OVCL]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_OEMP] FOREIGN KEY([HandleEmpID], [ParentID])
REFERENCES [dbo].[OEMP] ([EmpID], [ParentID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_OEMP]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_OFTP] FOREIGN KEY([FoodTypeID])
REFERENCES [dbo].[OFTP] ([TypeID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_OFTP]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_OITM] FOREIGN KEY([ItemID])
REFERENCES [dbo].[OITM] ([ItemID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_OITM]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_ORDR] FOREIGN KEY([OrderID], [ParentID])
REFERENCES [dbo].[ORDR] ([OrderID], [ParentID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_ORDR]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_OSCM] FOREIGN KEY([SchemeID])
REFERENCES [dbo].[OSCM] ([SchemeID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_OSCM]
GO
ALTER TABLE [dbo].[RDR1]  WITH CHECK ADD  CONSTRAINT [FK_RDR1_OUNT] FOREIGN KEY([UnitID])
REFERENCES [dbo].[OUNT] ([UnitID])
GO
ALTER TABLE [dbo].[RDR1] CHECK CONSTRAINT [FK_RDR1_OUNT]
GO
