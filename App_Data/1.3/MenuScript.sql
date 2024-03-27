GO
select * from OMNU where PageName ='SaleOrder.aspx'
Update OMNU set PageName = 'PurchaseOrder.aspx', MenuPath ='~/Purchase/PurchaseOrder.aspx' where PageName ='Inward.aspx'

select * from OMNU where PageName ='DirectReceipt.aspx'
Update OMNU set PageName = 'ReceiptDirect.aspx', MenuPath ='~/Purchase/ReceiptDirect.aspx' where PageName ='DirectReceipt.aspx'
Update OMNU set Active = 0,CMS =0 where PageName ='SaleOrder.aspx'
select * from OCFG

update omnu set active = 1,parentmenuid = 1 where menuid = 56 

Update OEML set PArentID = 1000010000000000

INSERT INTO omnu (MenuID, MenuName, PageName, MenuPath, ParentMenuID, SortOrder, ColorCode, Notes, CreatedDate, CreatedBy, UpdatedDate, 
UpdatedBy, Active, SyncStatus, Company, CMS, DMS, RMS)VALUES (151, 'Purchase Order', 'PurchaseOrder.aspx', '~/Purchase/PurchaseOrder.aspx', 6, 8, '', '', getdate(), 1, getdate(), 1, 1, 0, 1, 0, 0, 0)
GO
INSERT INTO omnu (MenuID, MenuName, PageName, MenuPath, ParentMenuID, SortOrder, ColorCode, Notes, CreatedDate, CreatedBy, UpdatedDate, 
UpdatedBy, Active, SyncStatus, Company, CMS, DMS, RMS)VALUES (152, 'Receipt Direct', 'ReceiptDirect.aspx', '~/Purchase/ReceiptDirect.aspx', 6, 8, '', '', getdate(), 1, getdate(), 1, 1, 0, 1, 0, 0, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (153, N'Email Configuration', N'EmailConfiguration.aspx', N'~/MyAccount/EmailConfiguration.aspx', 1, 38, NULL, NULL, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 0, 0, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (154, N'Item Mapping', N'ItemMapping.aspx', N'~/Master/ItemMapping.aspx', 2, 14, NULL, NULL, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 0, 0, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (155, N'Plant Details', N'PlantDetailsReport.aspx', N'~/CrystalReports/PlantDetailsReport.aspx', NULL, 10, NULL, NULL, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 1, 1, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (156, N'Cancel Order', N'CancelSale.aspx', N'~/Sales/CancelSale.aspx', 7, 10, NULL, NULL, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 0, 1, 0, 0)
GO
insert into OMNU  
values (158,'Claim Process Company','ClaimProcess.aspx','~/Sales/ClaimProcess.aspx',7,12,NULL,NULL,'2014-01-01 00:00:00.000',1,'2014-01-01 00:00:00.000',1,1,0,1,1,1,0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (159, N'Asset Wise Sales', N'AssetWiseSales.aspx', N'~/Reports/AssetWiseSales.aspx', 10, 41, NULL, 7, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 0, 0, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (160, N'Company Sales Summary', N'CompanySalesSummary.aspx', N'~/Reports/CompanySalesSummary.aspx', 10, 42, NULL, 7, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 0, 0, 0)
GO
INSERT [dbo].[OMNU] ([MenuID], [MenuName], [PageName], [MenuPath], [ParentMenuID], [SortOrder], [ColorCode], [Notes], [CreatedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [Active], [SyncStatus], [Company], [CMS], [DMS], [RMS]) 
VALUES (161, N'Claim Register', N'ClaimRegister.aspx', N'~/Reports/ClaimRegister.aspx', 10, 43, NULL, 7, CAST(0x0000A2A600000000 AS DateTime), 1, CAST(0x0000A2A600000000 AS DateTime), 1, 1 , 0, 1, 1, 0, 0)
GO