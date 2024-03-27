
CREATE TABLE [dbo].[TAX3](
	[TaxCodeID] [int] NOT NULL,
	[TaxCode] [int] NOT NULL,
	[SS] [int] NOT NULL,
	[OS] [int] NOT NULL,
	[US] [int] NOT NULL,
 CONSTRAINT [PK_TAX3] PRIMARY KEY CLUSTERED 
(
	[TaxCodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (1, 108, 108, 109, 110)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (2, 109, 108, 109, 110)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (3, 110, 108, 109, 110)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (4, 114, 114, 115, 116)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (5, 115, 114, 115, 116)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (6, 116, 114, 115, 116)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (7, 111, 111, 112, 113)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (8, 112, 111, 112, 113)
GO
INSERT [dbo].[TAX3] ([TaxCodeID], [TaxCode], [SS], [OS], [US]) VALUES (9, 113, 111, 112, 113)
GO
