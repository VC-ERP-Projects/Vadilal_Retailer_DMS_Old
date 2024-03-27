
/****** Object:  ForeignKey [FK_OGPS_OEMP]    Script Date: 06/15/2017 10:19:08 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OGPS_OEMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OGPS]'))
ALTER TABLE [dbo].[OGPS] DROP CONSTRAINT [FK_OGPS_OEMP]
GO
/****** Object:  ForeignKey [FK_RUT2_ORUT]    Script Date: 06/15/2017 10:19:08 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RUT2_ORUT]') AND parent_object_id = OBJECT_ID(N'[dbo].[RUT2]'))
ALTER TABLE [dbo].[RUT2] DROP CONSTRAINT [FK_RUT2_ORUT]
GO
/****** Object:  ForeignKey [FK_TCRD1_TOCRD]    Script Date: 06/15/2017 10:19:09 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TCRD1_TOCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[TCRD1]'))
ALTER TABLE [dbo].[TCRD1] DROP CONSTRAINT [FK_TCRD1_TOCRD]
GO
/****** Object:  Table [dbo].[RUT2]    Script Date: 06/15/2017 10:19:08 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RUT2_ORUT]') AND parent_object_id = OBJECT_ID(N'[dbo].[RUT2]'))
ALTER TABLE [dbo].[RUT2] DROP CONSTRAINT [FK_RUT2_ORUT]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RUT2]') AND type in (N'U'))
DROP TABLE [dbo].[RUT2]
GO
/****** Object:  Table [dbo].[OGPS]    Script Date: 06/15/2017 10:19:08 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OGPS_OEMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OGPS]'))
ALTER TABLE [dbo].[OGPS] DROP CONSTRAINT [FK_OGPS_OEMP]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OGPS]') AND type in (N'U'))
DROP TABLE [dbo].[OGPS]
GO
/****** Object:  Table [dbo].[TCRD1]    Script Date: 06/15/2017 10:19:09 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TCRD1_TOCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[TCRD1]'))
ALTER TABLE [dbo].[TCRD1] DROP CONSTRAINT [FK_TCRD1_TOCRD]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TCRD1]') AND type in (N'U'))
DROP TABLE [dbo].[TCRD1]
GO
/****** Object:  Table [dbo].[TOCRD]    Script Date: 06/15/2017 10:19:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TOCRD]') AND type in (N'U'))
DROP TABLE [dbo].[TOCRD]
GO
/****** Object:  Table [dbo].[TOCRD]    Script Date: 06/15/2017 10:19:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TOCRD]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TOCRD](
	[TCustID] [int] NOT NULL,
	[ParentID] [decimal](18, 0) NOT NULL,
	[PAN] [nvarchar](250) NULL,
	[PANApplicable] [bit] NOT NULL,
	[PANUpload] [nvarchar](250) NULL,
	[GST] [nvarchar](250) NULL,
	[GSTUpload] [nvarchar](250) NULL,
	[CompositeScheme] [bit] NOT NULL,
	[VAT] [nvarchar](250) NULL,
	[VATUpload] [nvarchar](250) NULL,
	[CST] [nvarchar](250) NULL,
	[CSTupload] [nvarchar](250) NULL,
	[SAPFlag] [nvarchar](250) NULL,
	[SAPMessage] [nvarchar](250) NULL,
 CONSTRAINT [PK_TOCRD] PRIMARY KEY CLUSTERED 
(
	[TCustID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[TCRD1]    Script Date: 06/15/2017 10:19:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TCRD1]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TCRD1](
	[TCRD1ID] [int] NOT NULL,
	[ParentID] [decimal](18, 0) NOT NULL,
	[TCustID] [int] NOT NULL,
	[AddressType] [nvarchar](1) NOT NULL,
	[Address1] [nvarchar](250) NULL,
	[Address2] [nvarchar](250) NULL,
	[Landmark] [nvarchar](250) NULL,
	[CityID] [int] NULL,
	[District] [nvarchar](50) NULL,
	[StateID] [int] NULL,
	[CountryID] [int] NULL,
	[PinCode] [nvarchar](10) NULL,
	[OfficalEmail] [nvarchar](250) NULL,
	[OfficalPhone] [nvarchar](15) NULL,
	[ContactPerson] [nvarchar](250) NULL,
	[MobileNo] [nvarchar](15) NULL,
	[EmailID] [nvarchar](250) NULL,
	[Web] [nvarchar](250) NULL,
 CONSTRAINT [PK_TCRD1] PRIMARY KEY CLUSTERED 
(
	[TCRD1ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[OGPS]    Script Date: 06/15/2017 10:19:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OGPS]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OGPS](
	[GPSID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[EmpID] [int] NOT NULL,
	[Datetime] [datetime] NOT NULL,
	[Lat] [nvarchar](50) NOT NULL,
	[Long] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_OGPS] PRIMARY KEY CLUSTERED 
(
	[GPSID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[RUT2]    Script Date: 06/15/2017 10:19:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RUT2]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RUT2](
	[OffBitID] [int] NOT NULL,
	[ParentID] [numeric](18, 0) NOT NULL,
	[EmpID] [int] NOT NULL,
	[RouteID] [int] NOT NULL,
	[Datetime] [datetime] NOT NULL,
	[ManagerID] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[CancelBy] [nvarchar](1) NULL,
 CONSTRAINT [PK_RUT2] PRIMARY KEY CLUSTERED 
(
	[OffBitID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  ForeignKey [FK_OGPS_OEMP]    Script Date: 06/15/2017 10:19:08 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OGPS_OEMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OGPS]'))
ALTER TABLE [dbo].[OGPS]  WITH CHECK ADD  CONSTRAINT [FK_OGPS_OEMP] FOREIGN KEY([EmpID], [ParentID])
REFERENCES [dbo].[OEMP] ([EmpID], [ParentID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_OGPS_OEMP]') AND parent_object_id = OBJECT_ID(N'[dbo].[OGPS]'))
ALTER TABLE [dbo].[OGPS] CHECK CONSTRAINT [FK_OGPS_OEMP]
GO
/****** Object:  ForeignKey [FK_RUT2_ORUT]    Script Date: 06/15/2017 10:19:08 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RUT2_ORUT]') AND parent_object_id = OBJECT_ID(N'[dbo].[RUT2]'))
ALTER TABLE [dbo].[RUT2]  WITH CHECK ADD  CONSTRAINT [FK_RUT2_ORUT] FOREIGN KEY([RouteID], [ParentID])
REFERENCES [dbo].[ORUT] ([RouteID], [ParentID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RUT2_ORUT]') AND parent_object_id = OBJECT_ID(N'[dbo].[RUT2]'))
ALTER TABLE [dbo].[RUT2] CHECK CONSTRAINT [FK_RUT2_ORUT]
GO
/****** Object:  ForeignKey [FK_TCRD1_TOCRD]    Script Date: 06/15/2017 10:19:09 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TCRD1_TOCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[TCRD1]'))
ALTER TABLE [dbo].[TCRD1]  WITH CHECK ADD  CONSTRAINT [FK_TCRD1_TOCRD] FOREIGN KEY([TCustID])
REFERENCES [dbo].[TOCRD] ([TCustID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TCRD1_TOCRD]') AND parent_object_id = OBJECT_ID(N'[dbo].[TCRD1]'))
ALTER TABLE [dbo].[TCRD1] CHECK CONSTRAINT [FK_TCRD1_TOCRD]
GO
