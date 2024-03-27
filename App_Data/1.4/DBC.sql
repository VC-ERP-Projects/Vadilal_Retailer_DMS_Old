GO
Alter table SCM1 ADD CreatedDate datetime
GO
Alter table SCM1 ADD Active bit default(1) not null
GO
Update b set b.CreatedDate = a.CreatedDate from OSCM a JOIN SCM1 b  ON a.SchemeID = b.SchemeID where A.ApplicableMode = 'M'
GO
ALTER TABLE OCLMP ADD SchemeType nvarchar(10)
GO
Alter table NRT1 add Price money not null default(0)
GO
Alter table NRT1 add Total money not null default(0)


