ALTER PROCEDURE [dbo].[SchemeReport] 
@Type  Varchar(255),
@RegionID  Varchar(255),
@PlantID  Varchar(255),
@CustomerID  Varchar(255),
@Active  Varchar (255)

AS
BEGIN

Select 

T0.SchemeCode,T0.SchemeName,T3.StateName,T4.PlantName,CONVERT(numeric(18,2),T2.CompanyDisc) as 'Comp Discount(%)',Convert(numeric(18,2),T2.DistributorDisc) as 'Distr Discount(%)',Convert(Varchar,T0.StartDate,103) as 'StartDate',Convert(Varchar,T0.EndDate,103) as 'EndDate',
(case when T0.ApplicableMode='S' then 'QPS' else 'Master' end) as 'Type'
from  
OSCM T0
left outer join SCM1 T1 on T1.SchemeID = T0.SchemeID
left outer join SCM4 T2 on T2.SchemeID=T0.SchemeID
left outer join OCST T3 on T3.StateID = T1.RegionID
left outer join OPLT T4 on T4.PlantID = T1.PlantID

where(T0.ApplicableMode=@Type) and (@RegionID=0 or T1.RegionID=@RegionID) and (@PlantID=0 or T1.PlantID=@PlantID)
and T0.Active = @Active And (@CustomerID = '0' or (select CustomerID from SCM1 Where CustomerID = @CustomerID And SchemeID = T0.SchemeID) = @CustomerID)


Group By T0.SchemeID,T0.SchemeCode,T0.SchemeName,T3.StateName,T4.PlantName,T2.CompanyDisc,T2.DistributorDisc,T0.StartDate,T0.EndDate,T0.ApplicableMode

END