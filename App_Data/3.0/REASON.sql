select * from ORSN where Type ='S'

Update ORSN set ReasonName = 'Sec Freight Transport (C53)', ReasonDesc= 'T', SAPReasonItemCode='C53' where ReasonID = 5
Update ORSN set ReasonName = 'Master Scheme (C52)', ReasonDesc= 'M', SAPReasonItemCode='C52' where ReasonID = 12
Update ORSN set ReasonName = 'QPS Scheme (C51)', ReasonDesc= 'S', SAPReasonItemCode='C51' where ReasonID = 13
Update ORSN set ReasonName = 'Free I/C Scheme - Machine Purchase Dlr. (C33)', ReasonDesc= 'D', SAPReasonItemCode='C33' where ReasonID = 14
Update ORSN set ReasonName = 'Free I/C Scheme For Parlour (C34)', ReasonDesc= 'P', SAPReasonItemCode='C34' where ReasonID = 15
Update ORSN set ReasonName = 'FOW Electricity (C11)', ReasonDesc= 'F',Active=1, SAPReasonItemCode='C11' where ReasonID = 4

Insert into ORSN  values(26,'All Dealer Schemes (Value)','C02','S',GETDATE(),1,GETDATE(),1,1,0,'C02')
Insert into ORSN  values(27,'VRS Schemes (%)','C03','S',GETDATE(),1,GETDATE(),1,1,0,'C03')
Insert into ORSN  values(28,'Outstation Freight Claims (%)','C04','S',GETDATE(),1,GETDATE(),1,1,0,'C04')
Insert into ORSN  values(29,'All Mela Scheme (%)','C05','S',GETDATE(),1,GETDATE(),1,1,0,'C05')
Insert into ORSN  values(30,'QPS Scheme','C06','S',GETDATE(),1,GETDATE(),1,1,0,'C06')
Insert into ORSN  values(31,'IOU related Damages (%)','C08','S',GETDATE(),1,GETDATE(),1,1,0,'C08')
Insert into ORSN  values(32,'Rate Difference Primary Discount','C09','S',GETDATE(),1,GETDATE(),1,1,0,'C09')
Insert into ORSN  values(33,'Rate Difference Secondary Discount','C10','S',GETDATE(),1,GETDATE(),1,1,0,'C10')
Insert into ORSN  values(35,'Machine Failure related Damage','C12','S',GETDATE(),1,GETDATE(),1,1,0,'C12')
Insert into ORSN  values(36,'Delayed Free Scheme Claim','C13','S',GETDATE(),1,GETDATE(),1,1,0,'C13')
Insert into ORSN  values(37,'Free Ice Cream/PFD','C14','S',GETDATE(),1,GETDATE(),1,1,0,'C14')
Insert into ORSN  values(38,'Rates and Taxes','C15','S',GETDATE(),1,GETDATE(),1,1,0,'C15')
Insert into ORSN  values(39,'Miscellaneous Expense','C16','S',GETDATE(),1,GETDATE(),1,1,0,'C16')
Insert into ORSN  values(40,'Octroi','C17','S',GETDATE(),1,GETDATE(),1,1,0,'C17')
Insert into ORSN  values(41,'Primary/Secondary Freight- Reimbursement','C18','S',GETDATE(),1,GETDATE(),1,1,0,'C18')
Insert into ORSN  values(42,'Product Complaint ( Secondary Sales )','C20','S',GETDATE(),1,GETDATE(),1,1,0,'C20')
Insert into ORSN  values(43,'Empty Raper / Material Shortage','C21','S',GETDATE(),1,GETDATE(),1,1,0,'C21')
Insert into ORSN  values(44,'VRS Schemes (Value)','C22','S',GETDATE(),1,GETDATE(),1,1,0,'C22')
Insert into ORSN  values(45,'Trade Discount','C23','S',GETDATE(),1,GETDATE(),1,1,0,'C23')
Insert into ORSN  values(46,'Shortage / Excess','C26','S',GETDATE(),1,GETDATE(),1,1,0,'C26')
Insert into ORSN  values(47,'ASP Free IceCream/PFD','C27','S',GETDATE(),1,GETDATE(),1,1,0,'C27')
Insert into ORSN  values(48,'Rate Difference(Additional)','C28','S',GETDATE(),1,GETDATE(),1,1,0,'C28')
Insert into ORSN  values(49,'Special Discount for Machine','C35','S',GETDATE(),1,GETDATE(),1,1,0,'C35')
Go

UPdate B SET B.SAPReasonItemCode = C.SAPReasonItemCode from OCLMP A 
JOIN OCLM B ON A.ParentClaimID = B.ParentClaimID AND A.ParentID = B.ParentiD
JOIN ORSN C ON C.ReasonDesc = B.SchemeType
 where COnvert(Date,A.FromDate) >= '20170701'