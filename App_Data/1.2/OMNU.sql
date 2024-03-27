INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (140, N'VAT Computation', N'VATComputation.aspx', N'~/Reports/VATComputation.aspx', 10, 39, NULL, 4, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (141, N'Sale Direct', N'SaleDirect.aspx', N'~/Sales/SaleDirect.aspx', 7, 11, NULL, NULL, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (142, N'Gross Dealer Summary', N'GrossDealerSummary.aspx', N'~/Reports/GrossDealerSummary.aspx', 10, 40, NULL, 7, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (143, N'201A', N'201A.aspx', N'~/Reports/201A.aspx', 10, 40, NULL, 4, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (144, N'201B', N'201B.aspx', N'~/Reports/201B.aspx', 10, 41, NULL, 4, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (145, N'201C', N'201C.aspx', N'~/Reports/201C.aspx', 10, 42, NULL, 4, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (146, N'Sales Register', N'SalesRegister.aspx', N'~/Reports/SalesRegister.aspx', 10, 9, NULL, 7, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 0, 0, 0)
GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (147, N'Claim Process', N'ClaimProcess.aspx', N'~/Sales/ClaimProcess.aspx', 7, 12, NULL, NULL, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 1, 1, 0)

GO

INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS])
VALUES (148, N'Sales Comparison', N'SalesComparison.aspx', N'~/Reports/SalesComparison.aspx', 10, 38, NULL, 7, CAST(0x0000A2A600000000 AS DATETIME), 1, CAST(0x0000A2A600000000 AS DATETIME), 1, 1, 0, 1, 0, 0, 0)


GO



Update OMNU set Active=0 where PageName='DirectSale.aspx'
Update OMNU set Active =0 where PageName='SaleOrder.aspx'
Update OMNU set Company=0  where MenuID in (47,50,111,112,137,134)
Update OMNU set SortOrder=999 where Notes=10