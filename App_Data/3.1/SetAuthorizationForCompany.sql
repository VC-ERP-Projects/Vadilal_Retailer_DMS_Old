CREATE Procedure SetAuthorizationForCompany(@DistributorID Decimal(18,0),@StateID INT)
AS
BEGIN

--Declare
--@DistributorID Decimal(18,0) = 2000050000100000,
--@StateID INT = 1

Insert into GRP1
Select 
DENSE_RANK ( ) OVER (PARTITION BY B.CustomerID Order By MenuID) + (Select MAX(GRPID) from GRP1 TA Where TA.ParentID = B.CustomerID),
B.CustomerID,1 as 'EmpGroupID',A.MenuID,A.AuthorizationType,'' as Notes,A.Active,A.SyncStatus 
From GRP1 A CROSS JOIN (Select DISTINCT TA.CustomerID From OCRD TA Inner Join CRD1 TB ON TA.CustomerID = TB.CustomerID 
								Where TB.IsDeleted = 0  AND TA.[Type] = 2
								AND TB.StateID = @StateID
								AND EXISTS(Select * From OGRP X Where X.ParentID = TA.CustomerID AND X.EmpGroupID = 1)) B 
Where A.ParentID = @DistributorID AND A.EmpGroupID = 1
AND A.MenuID Not in (Select DISTINCT MenuID from GRP1 TA Where TA.ParentID = B.CustomerID AND TA.EmpGroupID = 1)
Order By B.CustomerID,A.MenuID



Update C Set C.AuthorizationType = A.AuthorizationType,C.Active = A.Active
--Select A.ParentID,C.ParentID,A.MenuID,C.MenuID,A.AuthorizationType,C.AuthorizationType,A.Active,C.Active
From GRP1 A CROSS JOIN (Select DISTINCT TA.CustomerID From OCRD TA Inner Join CRD1 TB ON TA.CustomerID = TB.CustomerID 
								Where TB.IsDeleted = 0  AND TA.[Type] = 2
								AND TB.StateID = @StateID
								AND EXISTS(Select * From OGRP X Where X.ParentID = TA.CustomerID AND X.EmpGroupID = 1)) B
INNER JOIN GRP1 C ON C.ParentID = B.CustomerID AND C.MenuID = A.MenuID	

Where  A.ParentID = @DistributorID AND A.EmpGroupID = 1	

END