
/****** Object:  Table [dbo].[OASTZ]    Script Date: 07/28/2015 16:55:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OASTZ](
	[AssetSizeID] [int] IDENTITY(1,1) NOT NULL,
	[AssetSizeName] [nvarchar](100) NOT NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[SyncStatus] [bit] NOT NULL,
 CONSTRAINT [PK_OASTZ] PRIMARY KEY CLUSTERED 
(
	[AssetSizeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[OASTZ] ON
INSERT [dbo].[OASTZ] ([AssetSizeID], [AssetSizeName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (1, N'4 X 6', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF00D0DC8C AS DateTime), 1, 1, 1, 0)
INSERT [dbo].[OASTZ] ([AssetSizeID], [AssetSizeName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (2, N'6 X 8', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF0105F68A AS DateTime), 1, 1, 1, 0)
INSERT [dbo].[OASTZ] ([AssetSizeID], [AssetSizeName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (3, N'5 X 3', NULL, CAST(0x0000A4DF00D10F06 AS DateTime), 1, CAST(0x0000A4DF00D12EE2 AS DateTime), 1, 1, 0, 0)
SET IDENTITY_INSERT [dbo].[OASTZ] OFF
/****** Object:  Table [dbo].[OASTB]    Script Date: 07/28/2015 16:55:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OASTB](
	[AssetBrandID] [int] IDENTITY(1,1) NOT NULL,
	[AssetBrandName] [nvarchar](100) NOT NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[SyncStatus] [bit] NOT NULL,
 CONSTRAINT [PK_OASTB] PRIMARY KEY CLUSTERED 
(
	[AssetBrandID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[OASTB] ON
INSERT [dbo].[OASTB] ([AssetBrandID], [AssetBrandName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (1, N'Blue Star', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF0105F68A AS DateTime), 1, 1, 1, 0)
INSERT [dbo].[OASTB] ([AssetBrandID], [AssetBrandName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (2, N'Voltas', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF00D09F0A AS DateTime), 1, 1, 0, 0)
INSERT [dbo].[OASTB] ([AssetBrandID], [AssetBrandName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (3, N'Godrej', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF0105F68A AS DateTime), 1, 1, 0, 0)
INSERT [dbo].[OASTB] ([AssetBrandID], [AssetBrandName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (4, N'LG', NULL, CAST(0x0000A4DF0105F68A AS DateTime), 1, CAST(0x0000A4DF0105F68A AS DateTime), 1, 1, 0, 0)
INSERT [dbo].[OASTB] ([AssetBrandID], [AssetBrandName], [Remarks], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [IsDefault], [SyncStatus]) VALUES (5, N'Samsung', NULL, CAST(0x0000A4DF00D0F1F9 AS DateTime), 1, CAST(0x0000A4DF00D0F1FA AS DateTime), 1, 1, 0, 0)
SET IDENTITY_INSERT [dbo].[OASTB] OFF
/****** Object:  Default [DF_OASTB_Active]    Script Date: 07/28/2015 16:55:57 ******/
ALTER TABLE [dbo].[OASTB] ADD  CONSTRAINT [DF_OASTB_Active]  DEFAULT ((0)) FOR [Active]
GO
/****** Object:  Default [DF_OASTB_SyncStatus]    Script Date: 07/28/2015 16:55:57 ******/
ALTER TABLE [dbo].[OASTB] ADD  CONSTRAINT [DF_OASTB_SyncStatus]  DEFAULT ((0)) FOR [SyncStatus]
GO
/****** Object:  Default [DF_OASTZ_Active]    Script Date: 07/28/2015 16:55:57 ******/
ALTER TABLE [dbo].[OASTZ] ADD  CONSTRAINT [DF_OASTZ_Active]  DEFAULT ((0)) FOR [Active]
GO
/****** Object:  Default [DF_OASTZ_SyncStatus]    Script Date: 07/28/2015 16:55:57 ******/
ALTER TABLE [dbo].[OASTZ] ADD  CONSTRAINT [DF_OASTZ_SyncStatus]  DEFAULT ((0)) FOR [SyncStatus]
GO


-- TABLE CHANGES & RELATIONSHIP

ALTER TABLE OAST 
ADD AssetBrandID INT NULL

ALTER TABLE OAST
ADD AssetSizeID INT NULL


ALTER TABLE EXAST
ADD AssetBrandID INT NULL

ALTER TABLE EXAST
ADD AssetSizeID INT NULL


ALTER TABLE OAST 
ADD CONSTRAINT FK_OAST_OASTB FOREIGN KEY (AssetBrandID) REFERENCES OASTB(AssetBrandID)

ALTER TABLE OAST
ADD CONSTRAINT FK_OAST_OASTZ FOREIGN KEY (AssetSizeID) REFERENCES OASTZ(AssetSizeID)


ALTER TABLE EXAST
ADD CONSTRAINT FK_EXAST_OASTB FOREIGN KEY (AssetBrandID) REFERENCES OASTB(AssetBrandID)

ALTER TABLE EXAST
ADD CONSTRAINT FK_EXAST_OASTZ FOREIGN KEY (AssetSizeID) REFERENCES OASTZ(AssetSizeID)


----Store Procedure Scheme Report
USE [VDMS]
GO
/****** Object:  StoredProcedure [dbo].[SchemeReport]    Script Date: 07/31/2015 10:32:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SchemeReport] 
@Type  Varchar(255),
@RegionID  Varchar(255),
@PlantID  Varchar(255),
@CustomerID  Varchar(255),
@Active  Varchar (255)

AS
BEGIN

Select 

T0.SchemeCode,T0.SchemeName,T3.RegionName,T4.PlantName,CONVERT(numeric(18,2),T2.CompanyDisc) as 'Comp Discount(%)',Convert(numeric(18,2),T2.DistributorDisc) as 'Distr Discount(%)',Convert(Varchar,T0.StartDate,103) as 'StartDate',Convert(Varchar,T0.EndDate,103) as 'EndDate',
(case when T0.ApplicableMode='S' then 'QPS' else 'Master' end) as 'Type'
from  
OSCM T0
left outer join SCM1 T1 on T1.SchemeID = T0.SchemeID
left outer join SCM4 T2 on T2.SchemeID=T0.SchemeID
left outer join OREG T3 on T3.RegionID = T1.RegionID
left outer join OPLT T4 on T4.PlantID = T1.PlantID

where(T0.ApplicableMode=@Type) and (@RegionID=0 or T1.RegionID=@RegionID) and (@PlantID=0 or T1.PlantID=@PlantID)
and T0.Active = @Active And (@CustomerID = '0' or (select CustomerID from SCM1 Where CustomerID = @CustomerID And SchemeID = T0.SchemeID) = @CustomerID)


Group By T0.SchemeID,T0.SchemeCode,T0.SchemeName,T3.RegionName,T4.PlantName,T2.CompanyDisc,T2.DistributorDisc,T0.StartDate,T0.EndDate,T0.ApplicableMode

END