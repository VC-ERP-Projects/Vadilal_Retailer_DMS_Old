
CREATE TABLE [dbo].[OSPM](
	[ShippingID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[ShipmentNo] [nvarchar](200) NOT NULL,
	[VehicleID] [int] NOT NULL,
	[IsFTPUpload] [bit] NOT NULL CONSTRAINT [DF_OSPM_IsFTPUpload]  DEFAULT ((0)),
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
 CONSTRAINT [PK_OSPM] PRIMARY KEY CLUSTERED 
(
	[ShippingID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
