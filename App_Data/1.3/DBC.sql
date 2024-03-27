ALTER TABLE OCFG ADD SAPMasterClaimLink NVARCHAR(MAX)
GO
ALTER TABLE OCFG ADD SAPQPSClaimLink NVARCHAR(MAX)
GO
ALTER TABLE OCFG ADD UserID NVARCHAR(MAX)
GO
ALTER TABLE OCFG ADD Password NVARCHAR(MAX)
GO
SP_RENAME 'ORSN.SAPReasonNo', 'SAPReasonItemCode', 'COLUMN'
GO
ALTER TABLE OSEQ ADD FromDate DATE NULL 
GO
ALTER TABLE OSEQ ADD ToDate DATE NULL
GO
ALTER TABLE ORET ADD SubTotal MONEY
GO
ALTER TABLE ORET ADD Tax MONEY
GO
ALTER TABLE ORET ADD Rounding MONEY
GO
CREATE TABLE [dbo].[OCLM] ([ClaimID] [int] NOT NULL, [ParentID] [numeric](18, 0) NOT NULL, [Date] [datetime] NOT NULL, [Status] [nvarchar](10) NOT NULL, [CustomerID] [numeric](18, 0) NULL, [SchemeType] [nvarchar](10) NULL, [SchemeID] [int] NULL, [ItemID] [int] NOT NULL, [TotalQty] [decimal](18, 3) NULL, [SchemeAmount] [money] NOT NULL, [SAPDocNo] [nvarchar](max) NULL, [SAPErrMsg] [nvarchar](max) NULL, [CreatedDate] [datetime] NOT NULL, [CreatedBy] [int] NOT NULL, [UpdatedDate] [datetime] NOT NULL, [Updatedby] [int] NOT NULL, [Active] [bit] NOT NULL CONSTRAINT [DF_OCLM_Active] DEFAULT((1)), [SyncStatus] [bit] NOT NULL CONSTRAINT [DF_OCLM_SyncStatus] DEFAULT((0)), CONSTRAINT [PK_OCLM] PRIMARY KEY CLUSTERED ([ClaimID] ASC, [ParentID] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY]
GO
CREATE TABLE [dbo].[OSTS] ([StatusID] [int] NOT NULL, [Code] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, [Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)
GO
ALTER TABLE [dbo].[OSTS] ADD CONSTRAINT [PK_OSTS] PRIMARY KEY CLUSTERED ([StatusID])
GO
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (1, N'OPEN', N'Indent Open')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (2, N'CRBL', N'Blocked Indent Credit Issue')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (3, N'CRRJ', N'Rejected Indent Credit Issue')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (4, N'PLAN', N'Transported Planned')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (5, N'PICK', N'Picking Started')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (6, N'RELS', N'Released for Process')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (7, N'DELT', N'Deleted')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (8, N'PROC', N'Processed')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (9, N'RELF', N'Released finally for SO PO creation')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (10, N'MVT1', N'TRAY MOVEMENT Z61V')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (11, N'MVT3', N'TRAY MOVEMENT 303')
INSERT [dbo].[OSTS] ([StatusID], [Code], [Description]) VALUES (12, N'NTRY', N'No Tray Movement')
GO
ALTER TABLE SCM3 ADD DivisionID int NULL
GO
CREATE TABLE [dbo].[EML2]
(
[EML2ID] [int] NOT NULL,
[ParentID] [numeric] (18, 0) NOT NULL,
[DocType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlantID] [int] NOT NULL,
[SuccessEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FailureEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SuccessSMS] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FailureSMS] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedBy] [int] NOT NULL,
[UpdatedDate] [datetime] NOT NULL,
[UpdatedBy] [int] NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_EML2_Active] DEFAULT ((1))
)
GO
ALTER TABLE [dbo].[EML2] ADD CONSTRAINT [PK_EML2] PRIMARY KEY CLUSTERED  ([EML2ID], [ParentID])
GO
CREATE TABLE [dbo].[PLT1]
(
[PLT1ID] [int] NOT NULL,
[ParentID] [numeric] (18, 0) NOT NULL,
[ItemID] [int] NOT NULL,
[PlantID] [int] NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_PLT1_Active] DEFAULT ((1))
)
GO
ALTER TABLE [dbo].[PLT1] ADD CONSTRAINT [PK_PLT1] PRIMARY KEY CLUSTERED  ([PLT1ID], [ParentID])
GO



