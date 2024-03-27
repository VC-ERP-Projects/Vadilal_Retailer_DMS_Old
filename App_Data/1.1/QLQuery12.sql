ALTER TABLE OCRD  add Latitude nvarchar(50),Longitude nvarchar(50)
GO
ALTER TABLE OPOS add Latitude nvarchar(50),Longitude nvarchar(50),Attachment nvarchar(50)
GO
ALTEr TABLE OMID add Latitude nvarchar(50),Longitude nvarchar(50),Attachment nvarchar (50)
GO 
CREATE TABLE [dbo].[CTRCK](
	[CTRCKID] [int] NOT NULL,
	[EMPID] [int] NOT NULL,
	[ParentID] [numeric](18,0) NOT NULL,
	[Latitude] [nvarchar](50) NULL,
	[Longitude] [nvarchar](150) NULL,
	[Date] [DATETIME] NULL,
	[Time] [nvarchar](50) NULL)
GO	 