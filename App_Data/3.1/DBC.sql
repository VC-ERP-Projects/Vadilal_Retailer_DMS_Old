ALTER TABLE OASTQ ADD ApplicationDate Datetime NULL
GO
UPDATE OASTQ SET ApplicationDate = CreatedDate
GO
ALTER TABLE OASTQ ALTER COLUMN ApplicationDate Datetime NOT NULL
GO
ALTER TABLE OARQ ADD ApplicationDate Datetime NULL
GO
UPDATE OARQ SET ApplicationDate = CreatedDate
GO
ALTER TABLE OARQ ALTER COLUMN ApplicationDate Datetime NOT NULL
GO
ALTER TABLE OERQ ADD ApplicationDate Datetime NULL
GO
UPDATE OERQ SET ApplicationDate = CreatedDate
GO
ALTER TABLE OERQ ALTER COLUMN ApplicationDate Datetime NOT NULL
GO
