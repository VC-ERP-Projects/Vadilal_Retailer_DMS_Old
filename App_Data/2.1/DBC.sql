ALTER TABLE OGITM ADD Active BIT 
GO
UPDATE OGITM SET Active = 1
GO
ALTER TABLE OGITM ALTER COLUMN Active BIT NOT NULL
GO
ALTER TABLE OPOS ADD DocType varchar(1) 
GO
UPDATE OPOS Set DocType = 'N'
GO
GO
ALTER TABLE OGCM ADD ModelNo nvarchar(250)
ALTER TABLE OGCM ADD AndroidVersion nvarchar(10)
ALTER TABLE OGCM ADD OS nvarchar(50)
ALTER TABLE OGCM ADD MAC nvarchar(50)
ALTER TABLE OGCM ADD IMEI nvarchar(50)
ALTER TABLE OGCM ADD EmailID nvarchar(250)
ALTER TABLE OGCM ADD BatteryInfo nvarchar(max)
GO
ALTER TABLE OCST ADD StateType nvarchar(2)
ALTER TABLE OCST ADD ISO nvarchar(5)
GO
