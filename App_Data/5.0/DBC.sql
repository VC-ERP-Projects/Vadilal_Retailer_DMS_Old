Alter Table OCFG Add MechanicVersion nvarchar(50)
GO

ALTER TABLE TASK3 ADD RefDocNo varchar(20) NULL
ALTER TABLE TASK4 ADD RefDocNo varchar(20) NULL

ALTER TABLE TASK3 ADD Flag varchar(2) NULL
ALTER TABLE TASK4 ADD Flag varchar(2) NULL

ALTER TABLE TASK3 ADD RefMessage varchar(200) NULL
ALTER TABLE TASK4 ADD RefMessage varchar(200) NULL

Alter Table OAST add Room nvarchar(50)
Alter Table OAST add SortField nvarchar(50)
Alter Table OAST add Brand nvarchar(50)
GO

ALTER TABLE TASK4 ADD RplcRefDocNo varchar(20) NULL
ALTER TABLE TASK4 ADD RplcFlag varchar(2) NULL
ALTER TABLE TASK4 ADD RplcRefMessage varchar(200) NULL
ALTER TABLE OEMP Add FieldStaffManagerID INT
GO
ALTER TABLE OCRD ADD BillToPartyCustID DECIMAL(18,0) NULL
GO

-------T900009054 Vadilal Pulse Temp. Customer ----------------
ALTER TABLE OCRD Add YearlySale decimal(18,2)
GO
ALTER TABLE OCRD Add Remarks1 nvarchar(100)
GO
ALTER TABLE OCRD Add Remarks2 nvarchar(100)
GO
ALTER TABLE OCRD Add IsTempPR BIT
GO
UPDATE OCRD SET IsTempPR= 0

--------T900007342 Competitor/Temporary Data Update Utility -----------------
INSERT INTO OSET 
SELECT 'CompInfoLink','http://dms.vadilalgroup.com:83/Document/CompInfo/'

ALTER TABLE OCVE Add EmpID INT
GO

ALTER TABLE OCVE
DROP CONSTRAINT FK_OCVE_OGRP;

INSERT INTO OSET
SELECT 'MechImage','http://dmsqa.vadilalgroup.com:1918/Document/TaskCompletion/'

INSERT INTO OSET
SELECT 'MechImage','http://dms.vadilalgroup.com:1918/Document/TaskCompletion/'

INSERT INTO OSET
SELECT 'IsAssetListShowAtOrder',1

ALTER TABLE OSCM Add CreatedIPAddress varchar(20)

ALTER TABLE OSCM Add UpdatedIPAddress varchar(20)

ALTER TABLE SCM1 ADD CustGroupID int

ALTER TABLE ITM5 ADD CreatedDate datetime

ALTER TABLE ITM5 ADD CreatedBy int
		
ALTER TABLE ITM5 ADD UpdatedDate datetime

ALTER TABLE ITM5 ADD UpdatedBy int

ALTER TABLE AORDR ADD IsManual bit	
ALTER TABLE ITM5 ADD IsActive bit

insert into OSET
select 'DMSSupport','9909040814'

INSERT INTO EEML
SELECT (SELECT TOP 1 EMAILID FROM EEML ORDER BY EmailID DESC)+1,1000010000000000,'Last FSSAI Expiry Date @HANGOUT',1,'12:00:00.0000000','exec dbo.GetFSSAIExpiryCustomerData',GETDATE()+1,GETDATE(),1,GETDATE(),1,1,0

INSERT INTO EEML
SELECT (SELECT TOP 1 EMAILID FROM EEML ORDER BY EmailID DESC)+1,1000010000000000,'Last FSSAI Expiry Date @HAPPINEZZ',1,'12:00:00.0000000','exec dbo.GetFSSAIExpiryCustomerData',GETDATE()+1,GETDATE(),1,GETDATE(),1,1,0

INSERT INTO EEML
SELECT (SELECT TOP 1 EMAILID FROM EEML ORDER BY EmailID DESC)+1,1000010000000000,'Last FSSAI Expiry Date @MELTIN',1,'12:00:00.0000000','exec dbo.GetFSSAIExpiryCustomerData',GETDATE()+1,GETDATE(),1,GETDATE(),1,1,0 

INSERT INTO EML1
SELECT (SELECT TOP 1 EML1ID FROM EML1 ORDER BY EML1ID DESC)+1,1000010000000000,5,NULL,1,0,'chirag.prajapati@vc-erp.com',getdate(),1,0

ALTER TABLE AORDR
ADD ConflictCustID decimal(18,0)

ALTER TABLE OCLMP
ADD ClaimRemarks nvarchar(200)

ALTER TABLE OCLMP
ADD ClaimImage varchar(max)

ALTER TABLE ORCLM ADD PriceListID int

ALTER TABLE ORCLMLOG ADD PriceListID int

ALTER TABLE OPOS
ADD RateClaimID int

INSERT INTO OSET
SELECT 'SAPToDMSAssetSyncEmail','chirag.prajapati@vc-erp.com'

ALTER TABLE OPOS 
ADD IcePriceListName VARCHAR(30)

ALTER TABLE OPOS 
ADD DairyPriceListName VARCHAR(30)