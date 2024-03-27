INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) VALUES (131, N'Client Feedback', N'ClientFeedBack.aspx', N'~/Reports/ClientFeedBack.aspx', 10, 38, NULL, 4, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 1, 1, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) VALUES (130, N'Sales Authentication', N'SalesAuthentication.aspx', N'~/Reports/SalesAuthentication.aspx', 10, 37, NULL, 7, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 1, 1, 0)
GO
update OMNU set MenuName = 'Total Sales',PageName = 'TotalSales.aspx' ,MenuPath = '~/Reports/TotalSales.aspx' Where MenuID = 125

