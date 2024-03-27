ALTER TABLE MID1 ADD TaxID int Default(0)
EXEC sp_RENAME 'POS1.WaitingID', 'TaxID', 'COLUMN'

EXEC sp_RENAME 'OPOS.SignatureFile', 'ContraTax', 'COLUMN'

ALTER TABLE OITB ADD [Image] nvarchar(500)
ALTER TABLE OITB ADD Banner nvarchar(500)
ALTER TABLE OITG ADD [Image] nvarchar(500)


ALTER TABLE OPLT ADD StateID int
GO

CREATE VIEW [dbo].[vwCustomer]
AS
SELECT DISTINCT TOP (100) PERCENT REPLACE(C.CustomerName, '-', '') AS CustomerName, C.Type, C.CustomerCode, C.Phone, O.CustomerID, P.PlantID, P.StateID
FROM         dbo.OCRD AS C INNER JOIN
                      dbo.OGCRD AS O ON C.CustomerID = O.CustomerID INNER JOIN
                      dbo.OPLT AS P ON O.PlantID = P.PlantID
WHERE     (C.Active = 1)
ORDER BY C.Type, CustomerName




