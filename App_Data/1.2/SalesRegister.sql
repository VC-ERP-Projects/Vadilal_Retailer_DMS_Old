
ALTER Procedure SalesRegister(@ParentID Decimal(18,0),@FromDate DATE,@ToDate DATE)
AS
--Declare                  
                  
--@ParentID Nvarchar(MAX) = 2000010000100000 ,                  
--@FromDate DATE = '20160624',                  
--@ToDate DATE = '20160626'                 
              
BEGIN            
                   
SELECT  

A.CustomerCode ,A.CustomerName ,A.InvoiceDate,A.InvoiceNumber,A.totalQty,  
A.SubTotal,
A.AssValuefor_15,
A.AssValuefor_5,
A.AssValuefor_EXPT,
A.Discount,A.InvoiceType,    
A.Scheme,    
A.Tax ,   
A.AVAT1TaxAmt,  
A.VT4TaxAmt,  
A.[AVAT2.5TaxAmt],  
A.[VT12.5TaxAmt],  
A.VTEXPTTaxAmt,  
A.Subtotal + A.AVAT1TaxAmt + A.VT4TaxAmt + A.[AVAT2.5TaxAmt] + A.[VT12.5TaxAmt] + A.VTEXPTTaxAmt as 'Total',  
A.VTEXPTTaxAmt
  
 FROM        
            
(select T3.CustomerCode ,T3.CustomerName ,convert(varchar,T0.[Date],103) as 'InvoiceDate',T0.InvoiceNumber,ISNULL(SUM(T1.totalQty),0) as 'totalQty' ,  
ISNULL(T0.Discount,0) as 'Discount',(CASE WHEN T3.VATNumber = '' then 'Retail' Else 'Tax' END) as 'InvoiceType',                  
ISNULL(T0.Scheme,0) as 'Scheme' ,    
ISNULL(SUM(T1.Tax),0) as 'Tax' ,    
ISNULL(SUM(T1.SubTotal),0) as 'SubTotal',


Isnull((select SUM(TA.SubTotal)  
From POS1 TA Left Outer Join OTAX TD on TD.TaxID = TA.TaxID  
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '15.00'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) > 0 Group By TD.Percentage),0) as 'AssValuefor_15',  


Isnull((select SUM(TA.SubTotal)  
From POS1 TA Left Outer Join OTAX TD on TD.TaxID = TA.TaxID  
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '5.00'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) > 0 Group By TD.Percentage),0) as 'AssValuefor_5',  


Isnull((select SUM(TA.SubTotal)  
From POS1 TA Left Outer Join OTAX TD on TD.TaxID = TA.TaxID  
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '0.00'   
And IsNull(TA.TotalQty,0) > 0  Group By TD.Percentage),0) as 'AssValuefor_EXPT',
   
   
  ---------------- Tax Bifurcation  
   
   
Isnull((select SUM(((IsNull(TA.SubTotal,0)) * IsNull(TD.Percentage,0))/100)  
From POS1 TA Left Outer Join TAX1 TD on TD.TaxID = TA.TaxID  
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '1.00'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) > 0 Group By TD.Percentage),0) as 'AVAT1TaxAmt',  
  
Isnull((select  SUM(((IsNull(TA.SubTotal,0)) * IsNull(TD.Percentage,0))/100)  
From POS1 TA Left Outer Join TAX1 TD on TD.TaxID = TA.TaxID   
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '4.00' 
And IsNull(TA.TotalQty,0) > 0  And IsNull(TD.Percentage,0) > 0 Group By TD.Percentage),0) as 'VT4TaxAmt',  
  
Isnull((select  SUM(((IsNull(TA.SubTotal,0)) * IsNull(TD.Percentage,0))/100)  
From POS1 TA Left Outer Join TAX1 TD on TD.TaxID = TA.TaxID   
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '2.50'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) > 0  Group By TD.Percentage),0) as 'AVAT2.5TaxAmt',  
  
Isnull((select SUM(((IsNull(TA.SubTotal,0)) * IsNull(TD.Percentage,0))/100)  
From POS1 TA Left Outer Join TAX1 TD on TD.TaxID = TA.TaxID   
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '12.50'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) > 0 Group By TD.Percentage),0) as 'VT12.5TaxAmt',  
  
Isnull((select SUM(((IsNull(TA.SubTotal,0)) * IsNull(TD.Percentage,0))/100)  
From POS1 TA Left Outer Join TAX1 TD on TD.TaxID = TA.TaxID  
Where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID AND TA.IsDeleted = 0 And TD.percentage = '0'   
And IsNull(TA.TotalQty,0) > 0 And IsNull(TD.Percentage,0) = 0 Group By TD.Percentage),0) as 'VTEXPTTaxAmt'  
     
    
           
 ----------- From POS1          
                  
--IsNull((select ((SUM(IsNull(TA.SubTotal,0)) *                
-- CASE WHEN ISNULL(T0.ContraTax,'0') = '0' THEN '0' ELSE ISNULL((selecT items from dbo.Split(T0.ContraTax,',') where tempid = 2),0) END)/100)                    
-- From POS1 TA where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID And TA.AddOn = 0),0) as 'CompanyDisc',                  
                   
                    
-- IsNull((select ((SUM(IsNull(TA.SubTotal,0)) *                
-- CASE WHEN ISNULL(T0.ContraTax,'0') = '0' THEN '0' ELSE ISNULL((selecT items from dbo.Split(T0.ContraTax,',') where tempid = 1),0) END)/100)                    
-- From POS1 TA where TA.SaleID = T0.SaleID And TA.ParentID = T0.ParentID And TA.AddOn = 0),0) as 'DistributorDisc'                
          
                  
From OPOS T0 left outer join POS1 T1 on T0.SaleID = T1.SaleID AND T0.ParentID = T1.ParentID                  
Left outer join OCRD T3 on T3.CustomerID = T0.CustomerID                  
where  T0.ParentID = @ParentID
AND CONVERT(date,date) >= @FromDate AND CONVERT(date,date) <= @ToDate                  
AND T1.IsDeleted = 0                  
                  
GROUP BY T3.CustomerCode,T3.CustomerName,T0.[Date],T0.InvoiceNumber,T0.SubTotal,T0.Discount,T0.Scheme,T0.Tax,T0.Total,T0.SaleID,T0.ParentID,T0.contratax,T0.[Date],T0.Rounding,T3.VATNumber  
                 
 ) A                 
                 
Order by A.InvoiceDate 
            
END