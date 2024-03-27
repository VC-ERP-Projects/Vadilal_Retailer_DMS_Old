ALTER TABLE POS3 ADD SaleAmount MONEY NULL
ALTER TABLE POS3 ADD BasedOn INT NULL
GO
ALTER TABLE ORET ADD SchemeAmount MONEY
GO
ALTER TABLE RET1 ADD ItemScheme MONEY
ALTER TABLE RET1 ADD Scheme MONEY
GO
Alter table NRT1 add Price money not null default(0)
Alter table NRT1 add Total money not null default(0)
GO
ALTER TABLE OPOS add Ref2 nvarchar(max)
GO
ALTER TABLE ORUT ADD OwnCustomer INT NULL
ALTER TABLE ORUT ADD CompCustomer INT NULL
GO
ALTER TABLE TAX1 ADD RefPer MONEY NULL
GO
DROP INDEX [NonClusteredIndex-20160507-104500] ON [dbo].[OTAX]
GO
ALTER TABLE OTAX ALTER COLUMN Percentage MONEY NOT NULL
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160507-104500] ON [dbo].[OTAX]
(
	[TaxName] ASC,
	[Type] ASC,
	[Active] ASC,
	[ValidFrom] ASC,
	[ValidTo] ASC
)
INCLUDE ( 	[TaxID],
	[TaxDesc],
	[Percentage],
	[Formula],
	[CreatedDate],
	[CreatedBy],
	[UpdatedDate],
	[UpdatedBy],
	[SyncStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO
Alter Table EMP1 Alter Column Block Nvarchar(500) 
GO
Alter Table EMP1 Alter Column Street Nvarchar(500) 
GO
Alter Table TOCRD Add SAPFlag Nvarchar(250)
GO
Alter Table TOCRD Add SAPMessage Nvarchar(250)
GO
Alter Table TOCRD Add  Active bit
GO
Alter Table TOCRD Add CreatedDate DateTime
GO
Alter Table TOCRD Add CreatedBy int
