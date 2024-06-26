
/****** Object:  Table [dbo].[OCLG]    Script Date: 04/25/2017 12:23:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLG]') AND type in (N'U'))
DROP TABLE [dbo].[OCLG]
GO
/****** Object:  Table [dbo].[OCLG]    Script Date: 04/25/2017 12:23:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCLG]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OCLG](
	[LedgerReqID] [int] NOT NULL,
	[ParentID] [decimal](18, 0) NOT NULL,
	[Status] [int] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
	[RequiredDate] [datetime] NOT NULL,
	[DivisionID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [int] NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[SapMsg] [nvarchar](500) NULL,
	[SapFlag] [nvarchar](50) NULL,
 CONSTRAINT [PK_OCLG] PRIMARY KEY CLUSTERED 
(
	[LedgerReqID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
