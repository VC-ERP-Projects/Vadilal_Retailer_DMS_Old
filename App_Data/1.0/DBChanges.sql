ALTER TABLE OPOS ADD IsMobile bit not null default 0
GO
ALTER TABLE OMID ADD IsMobile bit not null default 0
GO
ALTER TABLE OCRD ADD IsTemp bit not null default 0
GO
Update OMNU set CMS=1 where MenuID=126
GO
Update OMNU set NOtes=7 where MenuID=121
GO
ALTER TABLE OPOS  ADD InvoiceDate DateTime
GO
ALTER TABLE OMID  ADD InvoiceDate DateTime
GO
ALTER TABLE CGRP ADD PPriceListID int 