--OMNU SS
--Type Table Created

ALTER TABLE OPOS ADD PORefID INT NULL
GO
ALTER TABLE OPOS ADD [Status] nvarchar(1) NULL
GO
UPDATE OPOS SET Status = 'O'
GO
ALTER TABLE OPOS ALTER COLUMN [Status] nvarchar(1) NOT NULL
GO
ALTER TABLE OMID ADD OrderRefID INT NULL
GO
ALTER TABLE MID1 ADD UnitPrice MONEY
GO
UPDATE MID1 SET UnitPrice = Price
GO
ALTER TABLE MID1 ALTER COLUMN UnitPrice MONEY NOT NULL
GO
ALTER TABLE OCLMP ADD IsSAP BIT
GO
UPDATE OCLMP SET IsSAP = 1
GO
ALTER TABLE OCLMP ALTER COLUMN IsSAP BIT NOT NULL
GO
ALTER TABLE OCLMRQ ADD IsSAP BIT
GO
UPDATE OCLMRQ SET IsSAP = 1
GO
ALTER TABLE OCLMRQ ALTER COLUMN IsSAP BIT NOT NULL
GO
ALTER TABLE OCLMRQ ADD PrevApprovedAmount money NULL
GO
UPDATE OCLMRQ SET PrevApprovedAmount =0
GO
ALTER TABLE OCLMRQ ALTER COLUMN PrevApprovedAmount money NOT NULL
GO
ALTER TABLE OCLMRQ ADD ClaimChildID INT NULL,ClaimChildParentID numeric(18,0) NULL
GO
UPdate OMNU set SS=0 where PageName = 'ClaimProcess.aspx'

selecT* from OMNU where PageName = 'ClaimProcess.aspx'
