using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.Objects.SqlClient;
using System.Net;
using System.IO;
using System.Text;
using System.Web.Configuration;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Data;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService]
public class WebService : System.Web.Services.WebService
{
    public WebService()
    {

    }

    [WebMethod(EnableSession = true)]
    public List<string> GetQPSSchemeItem(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OSCMs
                           join d in ctx.SCM4 on c.SchemeID equals d.SchemeID
                           join e in ctx.OITMs on d.ItemID equals e.ItemID
                           where c.ApplicableMode == "S"
                           orderby c.SchemeID descending
                           select SqlFunctions.StringConvert((double)e.ItemID).Trim() + " - " + e.ItemCode + " - " + e.ItemName).Take(40).Distinct().ToList();

            }
            else
            {
                StrCust = (from c in ctx.OSCMs
                           join d in ctx.SCM4 on c.SchemeID equals d.SchemeID
                           join e in ctx.OITMs on d.ItemID equals e.ItemID
                           where (e.ItemName.Contains(prefixText) || e.ItemCode.Contains(prefixText)) && c.ApplicableMode == "S"
                           orderby c.SchemeID descending
                           select SqlFunctions.StringConvert((double)e.ItemID).Trim() + " - " + e.ItemCode + " - " + e.ItemName).Take(40).Distinct().ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmpty(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetInventoryUpdateDate(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(contextKey);
        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrMat = (from c in ctx.INRTs
                          where c.ParentID == ParentID && c.DocumentType == "U"
                          select EntityFunctions.TruncateTime(c.DocumentDate).Value).Distinct().ToList()
                          .OrderByDescending(x => x.ToLocalTime())
                            .Select(y => y.ToShortDateString()).ToList();
            }
            else
            {
                StrMat = (from c in ctx.INRTs
                          where (c.ParentID == ParentID) && c.DocumentType == "U"
                          select EntityFunctions.TruncateTime(c.DocumentDate).Value).Distinct().ToList()
                          .OrderByDescending(x => x.ToLocalTime())
                            .Where(x => x.ToShortDateString().Contains(prefixText)).Select(x => x.ToShortDateString()).ToList();
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPriceGroup(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            Decimal CustomerID = Decimal.TryParse(contextKey.Split("#".ToArray()).First().Trim(), out CustomerID) ? CustomerID : 0;
            Int32 Div = Int32.TryParse(contextKey.Split("#".ToArray()).Last().Trim(), out Div) ? Div : 0;

            if (prefixText == "*")
            {
                StrCust = (from a in ctx.OCRDs
                           join b in ctx.OGCRDs on a.CustomerID equals b.CustomerID
                           join c in ctx.OIPLs on b.PriceListID equals c.PriceListID
                           //join e in ctx.ODIVs on c.DivisionlID equals e.DivisionlID
                           where (CustomerID == 0 || a.CustomerID == CustomerID) && b.DivisionlID == Div && b.PlantID != null && b.PriceListID != null && b.DivisionlID != null
                           select SqlFunctions.StringConvert((double)c.PriceListID).Trim() + " - " + c.Name.Trim()).Distinct().ToList();
            }
            else
            {
                StrCust = (from a in ctx.OCRDs
                           join b in ctx.OGCRDs on a.CustomerID equals b.CustomerID
                           join c in ctx.OIPLs on b.PriceListID equals c.PriceListID
                           //join e in ctx.ODIVs on c.DivisionlID equals e.DivisionlID
                           where (CustomerID == 0 || a.CustomerID == CustomerID) && b.DivisionlID == Div && b.PlantID != null && b.PriceListID != null && b.DivisionlID != null
                           && (c.Name.Contains(prefixText))
                           select SqlFunctions.StringConvert((double)c.PriceListID).Trim() + " - " + c.Name.Trim()).Distinct().ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetALLCustomer(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where contextKey.Contains(SqlFunctions.StringConvert((double)c.Type).Trim()) && c.Active
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where contextKey.Contains(SqlFunctions.StringConvert((double)c.Type).Trim())
                           && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetALLCustomerByType(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where contextKey.Contains(SqlFunctions.StringConvert((double)c.Type).Trim())
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where contextKey.Contains(SqlFunctions.StringConvert((double)c.Type).Trim())
                           && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomer(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == Type && c.ParentID == ParentID && c.Active
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == Type && c.ParentID == ParentID && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveInActiveCustomer(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int Type = Convert.ToInt32(contextKey);
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == Type && c.ParentID == ParentID
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == Type && c.ParentID == ParentID && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetOnlyChildCustomer(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.ParentID == ParentID && c.Active
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.ParentID == ParentID && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetChildCustomer(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(contextKey);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.ParentID == ParentID && c.Active
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.ParentID == ParentID && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveReason(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.ORSNs.Where(x => x.Active && (contextKey == null || x.Type == contextKey)).OrderBy(x => x.ReasonName).Select(x => SqlFunctions.StringConvert((double)x.ReasonID).Trim() + " - " + x.ReasonName).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.ORSNs.Where(x => x.Active && x.ReasonName.Contains(prefixText) && (contextKey == null || x.Type == contextKey)).OrderBy(x => x.ReasonName).Select(x => SqlFunctions.StringConvert((double)x.ReasonID).Trim() + " - " + x.ReasonName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetTaxName(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = ctx.OTAXes.OrderBy(x => x.TaxName).Select(x => x.TaxName).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OTAXes.Where(x => x.TaxName.Contains(prefixText)).OrderBy(x => x.TaxName).Select(x => x.TaxName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    // Get Asset Model for Customer + Assset wise sales report
    [WebMethod(EnableSession = true)]
    public List<string> GetAssetModel(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.OASTs.Where(x => !string.IsNullOrEmpty(x.ModelNumber)).OrderBy(x => x.ModelNumber).Select(x => x.ModelNumber).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OASTs.Where(x => x.ModelNumber.Contains(prefixText) && !string.IsNullOrEmpty(x.ModelNumber)).OrderBy(x => x.ModelNumber).Select(x => x.ModelNumber).Take(20).ToList();
            }

            return StrCust;
        }
    }

    // Get Asset Size for Customer + Assset wise sales report
    [WebMethod(EnableSession = true)]
    public List<string> GetAssetSize(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.OASTs.OrderBy(x => x.Volume).Select(x => x.ModelNumber).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OASTs.Where(x => x.ModelNumber.Contains(prefixText)).OrderBy(x => x.ModelNumber).Select(x => x.ModelNumber).Take(20).ToList();
            }

            return StrCust;
        }
    }

    // Get Storage location for Customer + Assset wise sales report
    [WebMethod(EnableSession = true)]
    public List<string> GetStorageLocation(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                //StrCust = ctx.OSTRLs.OrderBy(x => x.StorageLocCode).Select(x => x.StorageLocCode + " - " + x.StorageLocName + " - " + x.StorageLocID).Take(20).ToList();
                StrCust = (from c in ctx.OASTLOCs
                           orderby (c.AssetLocation)
                           select c.AssetLocation.Replace("-", " ")).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OASTLOCs
                           where (c.AssetLocation.Contains(prefixText))
                           orderby (c.AssetLocation)
                           select c.AssetLocation.Replace("-", " ")).Take(20).ToList();

                //StrCust = ctx.OSTRLs.Where(x => x.StorageLocCode.Contains(prefixText) || x.StorageLocName.Contains(prefixText)).OrderBy(x => x.StorageLocCode).Select(x => x.StorageLocCode + " - " + x.StorageLocName + " - " + x.StorageLocID).Take(20).ToList();
            }

            return StrCust;
        }
    }
    // Get Plant Storage location for Asset scan and not scan report
    [WebMethod(EnableSession = true)]
    public List<string> GetPlantStorageLocation(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.OSTRLs.OrderBy(x => x.StorageLocCode).Select(x => x.StorageLocCode + " - " + x.StorageLocName + " - " + SqlFunctions.StringConvert((double)x.StorageLocID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OSTRLs.Where(x => x.StorageLocCode.Contains(prefixText) || x.StorageLocName.Contains(prefixText)).OrderBy(x => x.StorageLocCode).Select(x => x.StorageLocCode + " - " + x.StorageLocName + " - " + SqlFunctions.StringConvert((double)x.StorageLocID).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetMaterial(string prefixText, int count, string contextKey)
    {
        List<String> StrMat = new List<string>();
        int ItemGroupID = 0, divisionId = 0;
        if (!string.IsNullOrEmpty(contextKey))
        {
            ItemGroupID = Int32.TryParse(contextKey.Trim().Split('-')[0], out ItemGroupID) ? ItemGroupID : 0;
            divisionId = Int32.TryParse(contextKey.Trim().Split('-')[1], out divisionId) ? divisionId : 0;
        }

        using (var ctx = new DDMSEntities())
        {
            if (ItemGroupID > 0 || divisionId > 0)
            {
                if (prefixText == "*")
                {
                    StrMat = (from c in ctx.OITMs
                              where (ItemGroupID == 0 || c.GroupID == ItemGroupID)
                              && (divisionId == 0 || c.OGITMs.Any(x => x.DivisionlID == divisionId && x.ItemID == c.ItemID))
                              orderby c.ItemName
                              select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
                }
                else
                {
                    StrMat = (from c in ctx.OITMs
                              where (ItemGroupID == 0 || c.GroupID == ItemGroupID) && (c.ItemCode.Contains(prefixText) || c.ItemName.Contains(prefixText))
                              && (divisionId == 0 || c.OGITMs.Any(x => x.DivisionlID == divisionId && x.ItemID == c.ItemID))
                              orderby c.ItemName
                              select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrMat = (from c in ctx.OITMs
                              orderby c.ItemName
                              select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
                }
                else
                {
                    StrMat = (from c in ctx.OITMs
                              where (c.ItemCode.Contains(prefixText) || c.ItemName.Contains(prefixText))
                              orderby c.ItemName
                              select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
                }
            }
            return StrMat;
        }
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeGroupName(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            List<String> StrCust = new List<string>();
            if (prefixText == "*")
            {
                StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerGroupNameDesc(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            List<String> StrCust = new List<string>();
            if (prefixText == "*")
            {
                StrCust = ctx.CGRPs.OrderBy(x => x.CustGroupName).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.CGRPs.Where(x => x.CustGroupName.Contains(prefixText) || x.CustGroupDesc.Contains(prefixText)).OrderBy(x => x.CustGroupName).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetApprovalEmployee(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

            int GroupID = Int32.TryParse(contextKey, out GroupID) ? GroupID : 0;

            if (prefixText == "*")
            {
                StrCust = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.Active && x.IsApprover).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OEMPs.Where(x => (x.EmpCode.Contains(prefixText) || x.Name.Contains(prefixText)) && x.ParentID == ParentID && x.Active && x.IsApprover).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveEmployee(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

            int GroupID = Int32.TryParse(contextKey, out GroupID) ? GroupID : 0;

            if (prefixText == "*")
            {
                StrCust = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.Active && (GroupID == 0 || x.EmpGroupID == GroupID)).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OEMPs.Where(x => (x.EmpCode.Contains(prefixText) || x.Name.Contains(prefixText)) && x.ParentID == ParentID && x.Active && (GroupID == 0 || x.EmpGroupID == GroupID)).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployee(string prefixText, int count, string contextKey)
    {
        List<string> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = ctx.OEMPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OEMPs.Where(x => (x.UserName.Contains(prefixText) || x.EmpCode.Contains(prefixText) || x.Name.Contains(prefixText)) && x.ParentID == ParentID).OrderBy(x => x.Name).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveCustomer(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.ParentID == ParentID && c.Active && (contextKey == "1" ? c.IsTemp : true)
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ")).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText)) && c.ParentID == ParentID && c.Active
                           && (contextKey == "1" ? c.IsTemp : true)
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ")).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCampaign(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCMPs
                           where c.ParentID == ParentID
                           orderby c.CampaignName
                           select c.CampaignName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCMPs
                           where (c.CampaignName.Contains(prefixText)) && c.ParentID == ParentID
                           orderby c.CampaignName
                           select c.CampaignName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetWarehouse(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrVeh = new List<string>();
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrVeh = ctx.OWHS.Where(x => x.ParentID == ParentID).OrderBy(x => x.WhsName).Select(x => x.WhsName).Take(20).ToList();
            }
            else
            {
                StrVeh = ctx.OWHS.Where(x => x.WhsName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.WhsName).Select(x => x.WhsName).Take(20).ToList();
            }

            return StrVeh;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPriceList(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrCust = new List<string>();

            if (prefixText == "*")
                StrCust = ctx.OIPLs.OrderBy(x => x.PriceListID).Select(x => SqlFunctions.StringConvert((double)x.PriceListID).Trim() + " - " + x.Name).Take(20).ToList();
            else
                StrCust = ctx.OIPLs.Where(x => (SqlFunctions.StringConvert((double)x.PriceListID).Contains(prefixText)) || x.Name.Contains(prefixText)).OrderBy(x => x.PriceListID).Select(x => SqlFunctions.StringConvert((double)x.PriceListID).Trim() + " - " + x.Name).Take(20).ToList();
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPriceListByID(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrCust = new List<string>();

            if (prefixText == "*")
                StrCust = ctx.OIPLs.OrderBy(x => x.PriceListID).Select(x => x.Name + " - " + SqlFunctions.StringConvert((double)x.PriceListID).Trim()).Take(20).ToList();
            else
                StrCust = ctx.OIPLs.Where(x => (SqlFunctions.StringConvert((double)x.PriceListID).Contains(prefixText)) || x.Name.Contains(prefixText)).OrderBy(x => x.PriceListID).Select(x => x.Name + " - " + SqlFunctions.StringConvert((double)x.PriceListID).Trim()).Take(20).ToList();
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetReceiptInwardNo(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OMIDs
                            where c.ParentID == ParentID && c.InwardType == 2
                            select new
                            {
                                ID = c.InwardID,
                                c.Date,
                                c.BillNumber,
                                c.InvoiceNumber,
                                Type = "P"
                            }).Union(from c in ctx.OPOS
                                     where c.CustomerID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType) && c.Status == "O" && c.IsDelivered == false
                                     select new
                                     {
                                         ID = c.SaleID,
                                         c.Date,
                                         BillNumber = c.InvoiceNumber,
                                         InvoiceNumber = "",
                                         Type = "O"
                                     }).OrderByDescending(x => x.Date).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.ID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date) + " - " + x.Type);
            }
            else
            {
                var Data = (from c in ctx.OMIDs
                            where c.ParentID == ParentID && c.InwardType == 2
                            && c.InvoiceNumber.Contains(prefixText)
                            && c.BillNumber.Contains(prefixText)
                            select new
                            {
                                ID = c.InwardID,
                                c.Date,
                                c.BillNumber,
                                c.InvoiceNumber,
                                Type = "P"
                            }).Union(from c in ctx.OPOS
                                     where c.CustomerID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType) && c.Status == "O" && c.IsDelivered == false
                                      && c.InvoiceNumber.Contains(prefixText)
                                     select new
                                     {
                                         ID = c.SaleID,
                                         c.Date,
                                         BillNumber = c.InvoiceNumber,
                                         InvoiceNumber = "",
                                         Type = "O"
                                     }).OrderByDescending(x => x.Date).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.ID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date) + " - " + x.Type);
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetInwardNo(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        var data = contextKey.Split(",".ToArray()).ToArray();
        Int32 InwardType = Convert.ToInt32(data[0]);
        decimal CustID = 0;
        if (InwardType == 1)
            CustID = Convert.ToDecimal(data[1]);
        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OMIDs
                            where (InwardType == 1 ? c.VendorParentID == ParentID && c.ParentID == CustID : c.ParentID == ParentID) && c.InwardType == InwardType
                            orderby c.Date descending
                            select new
                            {
                                c.InwardID,
                                c.Date,
                                c.BillNumber,
                                c.InvoiceNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }
            else
            {
                var Data = (from c in ctx.OMIDs
                            where (InwardType == 1 ? c.VendorParentID == ParentID && c.ParentID == CustID : c.ParentID == ParentID) && c.InwardType == InwardType
                            && SqlFunctions.StringConvert((double)c.InwardID).Contains(prefixText)
                            && c.BillNumber.Contains(prefixText)
                            orderby c.Date descending
                            select new
                            {
                                c.InwardID,
                                c.Date,
                                c.BillNumber,
                                c.InvoiceNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetOrderNo(string prefixText, int count, string contextKey)
    {
        //var data = contextKey.Split(" - ".ToArray()).ToArray();
        //  Int32 saleID = Convert.ToInt32(data[0]);

        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OPOS
                            where (c.ParentID == ParentID)
                            orderby c.Date descending
                            select new
                            {
                                c.Date,
                                c.SaleID
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.SaleID.ToString() + " - " + Common.DateTimeConvert(x.Date));

            }
            else
            {
                var Data = (from c in ctx.OPOS
                            where (c.ParentID == ParentID)
                            && SqlFunctions.StringConvert((double)c.SaleID).Contains(prefixText)
                            orderby c.Date descending
                            select new
                            {
                                c.Date,
                                c.SaleID
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.SaleID.ToString() + " - " + Common.DateTimeConvert(x.Date));
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSalesOrderNo(string prefixText, int count, string contextKey)
    {
        //var data = contextKey.Split(" - ".ToArray()).ToArray();
        //  Int32 saleID = Convert.ToInt32(data[0]);

        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.ORDRs
                            where (c.ParentID == ParentID)
                            orderby c.Date descending
                            select new
                            {
                                c.Date,
                                c.OrderID,
                                c.InvoiceNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.OrderID.ToString() + " - " + Common.DateTimeConvert(x.Date) + " - " + x.InvoiceNumber);

            }
            else
            {
                var Data = (from c in ctx.ORDRs
                            where (c.ParentID == ParentID)
                            && (SqlFunctions.StringConvert((double)c.OrderID).Contains(prefixText) || c.InvoiceNumber.Contains(prefixText))
                            orderby c.Date descending
                            select new
                            {
                                c.Date,
                                c.OrderID,
                                c.InvoiceNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.OrderID.ToString() + " - " + Common.DateTimeConvert(x.Date) + " - " + x.InvoiceNumber);
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistofPlantState(string prefixText, int count, string contextKey)
    {
        //decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Decimal StateID = 0;
        Decimal PlantID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length > 0)
        {
            StateID = Decimal.TryParse(contextKey.Split("-".ToArray()).First(), out StateID) ? StateID : 0;
            PlantID = Decimal.TryParse(contextKey.Split("-".ToArray()).Last(), out PlantID) ? PlantID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 2 && c.Active
                           && (StateID == 0 || c.CRD1.Any(x => x.StateID == StateID))
                           && (PlantID == 0 || c.OGCRDs.Any(x => x.PlantID == PlantID))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 2 && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           && (StateID == 0 || c.CRD1.Any(x => x.StateID == StateID))
                           && (PlantID == 0 || c.OGCRDs.Any(x => x.PlantID == PlantID))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerofDist(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            ParentID = Decimal.TryParse(contextKey, out ParentID) ? ParentID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3 && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetFOWDealerofDist(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            ParentID = Decimal.TryParse(contextKey, out ParentID) ? ParentID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3 && c.CustGroupID == 14
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3 && c.CustGroupID == 14 && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetNotFOWDealerofDist(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            ParentID = Decimal.TryParse(contextKey, out ParentID) ? ParentID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3 && c.CustGroupID != 14
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where (ParentID == 0 || c.ParentID == ParentID) && c.Active && c.Type == 3 && c.CustGroupID != 14 && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSaleBillForReturn(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Decimal CustID = 0;
        Decimal ItemID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length > 0)
        {
            CustID = Decimal.TryParse(contextKey.Split("-".ToArray()).First(), out CustID) ? CustID : 0;
            ItemID = Decimal.TryParse(contextKey.Split("-".ToArray()).Last(), out ItemID) ? ItemID : 0;
        }
        List<String> StrMat = new List<string>();
        DateTime dt = DateTime.Now.AddMonths(-6);

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OPOS
                            join d in ctx.OCRDs on c.CustomerID equals d.CustomerID
                            where c.ParentID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType)
                            && (EntityFunctions.TruncateTime(c.Date) >= EntityFunctions.TruncateTime(dt))
                            && (CustID == 0 || c.CustomerID == CustID)
                            && (ItemID == 0 || c.POS1.Any(x => x.ItemID == ItemID))
                            && !c.POS3.Any(x => x.Mode == "A")
                            orderby c.SaleID descending
                            select new
                            {
                                c.SaleID,
                                c.InvoiceNumber,
                                d.CustomerName,
                                c.Date,
                                c.BillRefNo
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.SaleID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + (String.IsNullOrEmpty(x.BillRefNo) ? "" : " - " + x.BillRefNo) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + Common.DateTimeConvert(x.Date));
            }
            else
            {
                var Data = (from c in ctx.OPOS
                            join d in ctx.OCRDs on c.CustomerID equals d.CustomerID
                            where c.ParentID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType)
                            && (EntityFunctions.TruncateTime(c.Date) >= EntityFunctions.TruncateTime(dt))
                            && (CustID == 0 || c.CustomerID == CustID)
                            && (ItemID == 0 || c.POS1.Any(x => x.ItemID == ItemID))
                            && !c.POS3.Any(x => x.Mode == "A")
                            && (c.InvoiceNumber.Contains(prefixText) || c.BillRefNo.Contains(prefixText) || d.CustomerName.Contains(prefixText))
                            orderby c.SaleID descending
                            select new
                            {
                                c.SaleID,
                                c.InvoiceNumber,
                                d.CustomerName,
                                c.BillRefNo,
                                c.Date
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.SaleID.ToString() + (String.IsNullOrEmpty(x.InvoiceNumber) ? "" : " - " + x.InvoiceNumber) + (String.IsNullOrEmpty(x.BillRefNo) ? "" : " - " + x.BillRefNo) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + Common.DateTimeConvert(x.Date));
            }

            return StrMat;
        }
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetSaleBillForReturnNew(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Decimal CustID = 0;
        Decimal ItemID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length > 0)
        {
            CustID = Decimal.TryParse(contextKey.Split("-".ToArray()).First(), out CustID) ? CustID : 0;
            ItemID = Decimal.TryParse(contextKey.Split("-".ToArray()).Last(), out ItemID) ? ItemID : 0;
        }
        List<String> StrMat = new List<string>();
        DateTime dt = DateTime.Now.AddMonths(-6);

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OPOS
                            join d in ctx.OCRDs on c.CustomerID equals d.CustomerID
                            // join ordr in ctx.ORDRs on c.OrderRefID equals ordr.OrderID
                            //into dept
                            //from department in dept.DefaultIfEmpty()  
                            where c.ParentID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType)
                            // && ((department.CustomerID == c.CustomerID) || (c.OrderRefID == department.OrderID) || (c.ParentID == department.ParentID))
                            && (EntityFunctions.TruncateTime(c.Date) >= EntityFunctions.TruncateTime(dt))
                            && (CustID == 0 || c.CustomerID == CustID)
                            && (ItemID == 0 || c.POS1.Any(x => x.ItemID == ItemID))
                            && !c.POS3.Any(x => x.Mode == "A")
                            orderby c.SaleID descending
                            select new
                            {
                                Customerid = c.CustomerID,
                                ParentID = c.ParentID,
                                OrderRefId = c.OrderRefID,
                                SaleID = c.SaleID,
                                InvoiceNumber = c.InvoiceNumber,
                                CustomerName = d.CustomerName,
                                BillRefNo = c.BillRefNo,
                                Date = c.Date
                                //   OrderNo = department.InvoiceNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                {

                    ORDR ord = ctx.ORDRs.Where(y => y.OrderID == x.OrderRefId && y.CustomerID == x.Customerid && y.ParentID == x.ParentID).FirstOrDefault();
                    if (ord != null)
                    {
                        StrMat.Add((String.IsNullOrEmpty(x.InvoiceNumber) ? "" : x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(ord.InvoiceNumber) ? "" : ord.InvoiceNumber) + " - " + Common.DateTimeConvert(x.Date) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + x.SaleID.ToString());
                    }
                    else
                    {
                        StrMat.Add((String.IsNullOrEmpty(x.InvoiceNumber) ? "" : x.InvoiceNumber) + " - " + "" + " - " + Common.DateTimeConvert(x.Date) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + x.SaleID.ToString());
                    }
                }
            }
            else
            {
                var Data = (from c in ctx.OPOS
                            join d in ctx.OCRDs on c.CustomerID equals d.CustomerID
                            //join ordr in ctx.ORDRs on c.OrderRefID equals ordr.OrderID 
                            // into dept
                            //from department in dept.DefaultIfEmpty()  
                            where c.ParentID == ParentID && new int[] { 12, 13 }.Contains(c.OrderType)
                            // && ((department.CustomerID == c.CustomerID) || (c.OrderRefID == department.OrderID) || (c.ParentID == department.ParentID))
                            && (EntityFunctions.TruncateTime(c.Date) >= EntityFunctions.TruncateTime(dt))
                            && (CustID == 0 || c.CustomerID == CustID)
                            && (ItemID == 0 || c.POS1.Any(x => x.ItemID == ItemID))
                            && !c.POS3.Any(x => x.Mode == "A")
                            && (c.InvoiceNumber.Contains(prefixText) || c.BillRefNo.Contains(prefixText) || d.CustomerName.Contains(prefixText))
                            orderby c.SaleID descending

                            select new
                            {
                                Customerid = c.CustomerID,
                                ParentID = c.ParentID,
                                OrderRefId = c.OrderRefID,
                                SaleID = c.SaleID,
                                InvoiceNumber = c.InvoiceNumber,
                                CustomerName = d.CustomerName,
                                BillRefNo = c.BillRefNo,
                                Date = c.Date
                                //   OrderNo =  department.InvoiceNumber 
                            }).Take(20).ToList();

                foreach (var x in Data)
                {
                    ORDR ord = ctx.ORDRs.Where(y => y.OrderID == x.OrderRefId && y.CustomerID == x.Customerid && y.ParentID == x.ParentID).FirstOrDefault();
                    if (ord != null)
                    {
                        StrMat.Add((String.IsNullOrEmpty(x.InvoiceNumber) ? "" : x.InvoiceNumber) + " - " + (String.IsNullOrEmpty(ord.InvoiceNumber) ? "" : ord.InvoiceNumber) + " - " + Common.DateTimeConvert(x.Date) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + x.SaleID.ToString());

                    }
                    else
                    {
                        StrMat.Add((String.IsNullOrEmpty(x.InvoiceNumber) ? "" : x.InvoiceNumber) + " - " + "" + " - " + Common.DateTimeConvert(x.Date) + (String.IsNullOrEmpty(x.CustomerName) ? "" : " - " + x.CustomerName.Replace("-", " ")) + " - " + x.SaleID.ToString());
                    }
                }
            }

            return StrMat;
        }
    }



    [WebMethod(EnableSession = true)]
    public List<string> GetVendor(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OVNDs
                           where c.ParentID == ParentID
                           orderby c.VendorName
                           select c.VendorCode + " - " + c.VendorName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OVNDs
                           where (c.VendorName.Contains(prefixText) || c.VendorCode.Contains(prefixText)) && c.ParentID == ParentID
                           orderby c.VendorName
                           select c.VendorCode + " - " + c.VendorName).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveVendor(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            var objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
            if (prefixText == "*")
            {
                StrCust = ctx.OVNDs.Where(x => (x.ParentID == ParentID || x.ParentID == objOCRD.ParentID) && x.Active).OrderBy(x => x.VendorCode).Select(x => x.VendorCode + " - " + x.VendorName).Take(20).ToList();

            }
            else
            {
                StrCust = ctx.OVNDs.Where(x => (x.ParentID == ParentID || x.ParentID == objOCRD.ParentID) && x.Active &&
                    (x.VendorCode.Contains(prefixText) || x.VendorName.Contains(prefixText))).OrderBy(x => x.VendorCode).Select(x => x.VendorCode + " - " + x.VendorName).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetQPSScheme(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OSCMs
                            where c.ApplicableMode == "S"
                            orderby c.SchemeID descending
                            select new
                            {
                                c.SchemeID,
                                c.SchemeName,
                                c.SchemeCode,
                                c.StartDate,
                                c.EndDate
                            }).Take(40).ToList();

                foreach (var x in Data)
                    StrCust.Add(x.SchemeID.ToString() + " - " + x.SchemeCode + " - " + x.SchemeName + " | " + (x.StartDate.HasValue ? Common.DateTimeConvert(x.StartDate.Value) + " # " : "") + (x.EndDate.HasValue ? Common.DateTimeConvert(x.EndDate.Value) : ""));
            }
            else
            {
                var Data1 = (from c in ctx.OSCMs
                             where (c.SchemeName.Contains(prefixText) || c.SchemeCode.Contains(prefixText)) && c.ApplicableMode == "S"
                             orderby c.SchemeID descending
                             select new
                             {
                                 c.SchemeID,
                                 c.SchemeName,
                                 c.SchemeCode,
                                 c.StartDate,
                                 c.EndDate
                             }).Take(40).ToList();

                foreach (var x in Data1)
                    StrCust.Add(x.SchemeID.ToString() + " - " + x.SchemeCode + " - " + x.SchemeName + " | " + (x.StartDate.HasValue ? Common.DateTimeConvert(x.StartDate.Value) + " # " : "") + (x.EndDate.HasValue ? Common.DateTimeConvert(x.EndDate.Value) : ""));
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetScheme(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OSCMs
                           orderby c.SchemeID descending
                           select c.SchemeCode + " - " + c.SchemeName + " - " +
                           (c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "")).Take(40).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OSCMs
                           where (c.SchemeName.Contains(prefixText) || c.SchemeCode.Contains(prefixText) || (SqlFunctions.StringConvert((decimal)c.SchemeID).Contains(prefixText)))
                           orderby c.SchemeID descending
                           select c.SchemeCode + " - " + c.SchemeName + " - " +
                           (c.ApplicableMode == "M" ? "Master" : c.ApplicableMode == "S" ? "QPS" : c.ApplicableMode == "D" ? "Machine Discount" : c.ApplicableMode == "P" ? "Parlour Discount" : c.ApplicableMode == "A" ? "S to D " : "")).Take(40).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetMinimumOrderData(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OMOAEs
                           orderby c.MiniOrderEnteryID descending
                           select c.MinimumOrderCode + " - " + c.MinimumOrderName + " - " +
                           (c.ApplicableMode == "OA" ? "OrderAmount" : c.ApplicableMode == "OE" ? "OrderEntry" : "")).Take(40).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OMOAEs
                           where (c.MinimumOrderName.Contains(prefixText) || c.MinimumOrderCode.Contains(prefixText) || (SqlFunctions.StringConvert((decimal)c.MiniOrderEnteryID).Contains(prefixText)))
                           orderby c.MiniOrderEnteryID descending
                           select c.MinimumOrderCode + " - " + c.MinimumOrderName + " - " +
                           (c.ApplicableMode == "OA" ? "OrderAmount" : c.ApplicableMode == "OE" ? "OrderEntry" : "")).Take(40).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetProductCataLog(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {

                var query = (from c in ctx.OPCATs
                             orderby c.CataLogID descending
                             select new
                             {
                                 c.CataLogID,
                                 c.ItemName,
                                 c.Fromdate,
                                 c.Todate,
                                 c.Active
                             }).Take(40).ToList();

                StrCust = query.Select(c => c.CataLogID.ToString().Trim() + " - " + c.ItemName + " - " +
                                            (c.Fromdate != null ? Common.DateTimeConvert(c.Fromdate.Value).ToString() : "") + " - " +
                                            (c.Todate != null ? Common.DateTimeConvert(c.Todate.Value).ToString() : "") + " - " + (c.Active == true ? "Active" : "Inactive")).ToList();
                //StrCust = (from c in ctx.OPCATs
                //           orderby c.CataLogID descending
                //           //select c.ItemName + " - " + c.ItemName
                //           select SqlFunctions.StringConvert((double)c.CataLogID).Trim() + " - " + (c.ItemName) + " - " + ((c.Fromdate != null) ? c.Fromdate.ToString() : "") + " - " + ((c.Todate != null) ? c.Todate.ToString() : "")
                //           ).Take(40).ToList();
            }
            else
            {
                var query = (from c in ctx.OPCATs
                             where (c.ItemName.Contains(prefixText) || c.ItemName.Contains(prefixText) || (SqlFunctions.StringConvert((decimal)c.CataLogID).Contains(prefixText)))
                             orderby c.CataLogID descending
                             select new
                             {
                                 c.CataLogID,
                                 c.ItemName,
                                 c.Fromdate,
                                 c.Todate,
                                 c.Active
                             }).Take(40).ToList();

                StrCust = query.Select(c => c.CataLogID.ToString().Trim() + " - " + c.ItemName + " - " +
                                            (c.Fromdate != null ? Common.DateTimeConvert(c.Fromdate.Value).ToString() : "") + " - " +
                                            (c.Todate != null ? Common.DateTimeConvert(c.Todate.Value).ToString() : "") + " - " + (c.Active == true ? "Active" : "Inactive")).ToList();

                //StrCust = (from c in ctx.OPCATs
                //           where (c.ItemName.Contains(prefixText) || c.ItemName.Contains(prefixText) || (SqlFunctions.StringConvert((decimal)c.CataLogID).Contains(prefixText)))
                //           orderby c.CataLogID descending
                //           select SqlFunctions.StringConvert((double)c.CataLogID).Trim() + " - " + (c.ItemName)
                //           ).Take(40).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetNoSaleEmailSms(string prefixText, int count, string contextKey)
    {
        List<String> StrNoSale = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OSCHDLs
                            orderby c.Active descending, c.StartDate descending
                            select new { c.SchedulePeriod, c.StartDate, c.MessageTo, c.ScheduleID, c.Active }
                           ).Take(40).ToList();

                foreach (var x in Data)
                {
                    StrNoSale.Add(x.SchedulePeriod + " - " + Common.DateTimeConvert(x.StartDate) + " - " + x.MessageTo + " - ( " + (x.Active ? "Active" : "InActive") + " ) " + " - " + x.ScheduleID);
                }
            }
            else
            {
                var Data1 = (from c in ctx.OSCHDLs
                             where (c.SchedulePeriod.Contains(prefixText) || c.MessageTo.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ScheduleID).Contains(prefixText))
                             orderby c.Active descending, c.StartDate descending
                             select new { c.SchedulePeriod, c.StartDate, c.MessageTo, c.ScheduleID, c.Active }
                           ).Take(40).ToList();
                foreach (var x in Data1)
                {
                    StrNoSale.Add(x.SchedulePeriod + " - " + Common.DateTimeConvert(x.StartDate) + " - " + x.MessageTo + " - ( " + (x.Active ? "Active" : "InActive") + " ) " + " - " + x.ScheduleID);
                }
            }
            return StrNoSale;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetMasters(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (contextKey == "OITP")
            {
                if (prefixText == "*")
                    StrCust = ctx.OITPs.OrderBy(x => x.TypeID).Select(x => SqlFunctions.StringConvert((double)x.TypeID).Trim() + " - " + x.TypeName).Take(20).ToList();
                else
                    StrCust = ctx.OITPs.Where(x => (SqlFunctions.StringConvert((double)x.TypeID).Contains(prefixText)) || x.TypeName.Contains(prefixText)).OrderBy(x => x.TypeID).Select(x => SqlFunctions.StringConvert((double)x.TypeID).Trim() + " - " + x.TypeName).Take(20).ToList();
            }
            else if (contextKey == "OITB")
            {
                if (prefixText == "*")
                    StrCust = ctx.OITBs.OrderBy(x => x.SortOrder).Select(x => SqlFunctions.StringConvert((double)x.ItemGroupID).Trim() + " - " + x.ItemGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                else
                    StrCust = ctx.OITBs.Where(x => (SqlFunctions.StringConvert((double)x.ItemGroupID).Contains(prefixText)) || x.ItemGroupName.Contains(prefixText)).OrderBy(x => x.SortOrder).Select(x => SqlFunctions.StringConvert((double)x.ItemGroupID).Trim() + " - " + x.ItemGroupName.Replace("-", " ").Trim()).Take(20).ToList();
            }
            else if (contextKey == "OIMG")
            {
                if (prefixText == "*")
                    StrCust = ctx.OIMGs.OrderBy(x => x.SortOrder).Select(x => SqlFunctions.StringConvert((double)x.ImageID).Trim() + " - " + x.ImageName).Take(20).ToList();
                else
                    StrCust = ctx.OIMGs.Where(x => (SqlFunctions.StringConvert((double)x.ImageID).Contains(prefixText)) || x.ImageName.Contains(prefixText)).OrderBy(x => x.SortOrder).Select(x => SqlFunctions.StringConvert((double)x.ImageID).Trim() + " - " + x.ImageName).Take(20).ToList();
            }
            else if (contextKey == "OUNT")
            {
                if (prefixText == "*")
                    StrCust = ctx.OUNTs.OrderBy(x => x.UnitID).Select(x => SqlFunctions.StringConvert((double)x.UnitID).Trim() + " - " + x.UnitName).Take(20).ToList();
                else
                    StrCust = ctx.OUNTs.Where(x => (SqlFunctions.StringConvert((double)x.UnitID).Contains(prefixText)) || x.UnitName.Contains(prefixText)).OrderBy(x => x.UnitID).Select(x => SqlFunctions.StringConvert((double)x.UnitID).Trim() + " - " + x.UnitName).Take(20).ToList();
            }
            else if (contextKey == "OCRY")
            {
                if (prefixText == "*")
                    StrCust = ctx.OCRies.OrderBy(x => x.CountryID).Select(x => SqlFunctions.StringConvert((double)x.CountryID).Trim() + " - " + x.CountryName).Take(20).ToList();
                else
                    StrCust = ctx.OCRies.Where(x => (SqlFunctions.StringConvert((double)x.CountryID).Contains(prefixText)) || x.CountryName.Contains(prefixText)).OrderBy(x => x.CountryID).Select(x => SqlFunctions.StringConvert((double)x.CountryID).Trim() + " - " + x.CountryName).Take(20).ToList();
            }
            else if (contextKey == "OCST")
            {
                if (prefixText == "*")
                    StrCust = ctx.OCSTs.OrderBy(x => x.StateID).Select(x => SqlFunctions.StringConvert((double)x.StateID).Trim() + " - " + x.StateName).Take(20).ToList();
                else
                    StrCust = ctx.OCSTs.Where(x => (SqlFunctions.StringConvert((double)x.StateID).Contains(prefixText)) || x.StateName.Contains(prefixText)).OrderBy(x => x.StateID).Select(x => SqlFunctions.StringConvert((double)x.StateID).Trim() + " - " + x.StateName).Take(20).ToList();
            }
            else if (contextKey == "OCTY")
            {
                if (prefixText == "*")
                    StrCust = ctx.OCTies.OrderBy(x => x.CityID).Select(x => SqlFunctions.StringConvert((double)x.CityID).Trim() + " - " + x.CityName).Take(20).ToList();
                else
                    StrCust = ctx.OCTies.Where(x => (SqlFunctions.StringConvert((double)x.CityID).Contains(prefixText)) || x.CityName.Contains(prefixText)).OrderBy(x => x.CityID).Select(x => SqlFunctions.StringConvert((double)x.CityID).Trim() + " - " + x.CityName).Take(20).ToList();
            }
            else if (contextKey == "OFTP")
            {
                if (prefixText == "*")
                    StrCust = ctx.OFTPs.OrderBy(x => x.TypeID).Select(x => SqlFunctions.StringConvert((double)x.TypeID).Trim() + " - " + x.TypeName).Take(20).ToList();
                else
                    StrCust = ctx.OFTPs.Where(x => (SqlFunctions.StringConvert((double)x.TypeID).Contains(prefixText)) || x.TypeName.Contains(prefixText)).OrderBy(x => x.TypeID).Select(x => SqlFunctions.StringConvert((double)x.TypeID).Trim() + " - " + x.TypeName).Take(20).ToList();
            }
            else if (contextKey == "ORLN")
            {
                if (prefixText == "*")
                    StrCust = ctx.ORLNs.OrderBy(x => x.RelationID).Select(x => SqlFunctions.StringConvert((double)x.RelationID).Trim() + " - " + x.RelationName).Take(20).ToList();
                else
                    StrCust = ctx.ORLNs.Where(x => (SqlFunctions.StringConvert((double)x.RelationID).Contains(prefixText)) || x.RelationName.Contains(prefixText)).OrderBy(x => x.RelationID).Select(x => SqlFunctions.StringConvert((double)x.RelationID).Trim() + " - " + x.RelationName).Take(20).ToList();
            }
            else if (contextKey == "CGRP")
            {
                if (prefixText == "*")
                    StrCust = ctx.CGRPs.OrderBy(x => x.CustGroupID).Select(x => SqlFunctions.StringConvert((double)x.CustGroupID).Trim() + " - " + x.CustGroupName).Take(20).ToList();
                else
                    StrCust = ctx.CGRPs.Where(x => (SqlFunctions.StringConvert((double)x.CustGroupID).Contains(prefixText)) || x.CustGroupName.Contains(prefixText)).OrderBy(x => x.CustGroupID).Select(x => SqlFunctions.StringConvert((double)x.CustGroupID).Trim() + " - " + x.CustGroupName).Take(20).ToList();
            }
            else if (contextKey == "OITG")
            {
                if (prefixText == "*")
                    StrCust = ctx.OITGs.OrderBy(x => x.ItemSubGroupID).Select(x => SqlFunctions.StringConvert((double)x.ItemSubGroupID).Trim() + " - " + x.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                else
                    StrCust = ctx.OITGs.Where(x => (SqlFunctions.StringConvert((double)x.ItemSubGroupID).Contains(prefixText)) || x.ItemSubGroupName.Contains(prefixText)).OrderBy(x => x.ItemSubGroupID).Select(x => SqlFunctions.StringConvert((double)x.ItemSubGroupID).Trim() + " - " + x.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
            }
            else if (contextKey == "OQUS")
            {
                if (prefixText == "*")
                    StrCust = ctx.OQUS.Where(x => x.ParentID == ParentID).OrderBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.QuesName).Take(20).ToList();
                else
                    StrCust = ctx.OQUS.Where(x => x.ParentID == ParentID && ((SqlFunctions.StringConvert((double)x.QuesID).Contains(prefixText)) || x.QuesName.Contains(prefixText))).OrderBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.QuesName).Take(20).ToList();
            }
            else if (contextKey == "OGRP")
            {
                if (prefixText == "*")
                    StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupID).Select(x => SqlFunctions.StringConvert((double)x.EmpGroupID).Trim() + " - " + x.EmpGroupName).Take(20).ToList();
                else
                    StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID && ((SqlFunctions.StringConvert((double)x.EmpGroupID).Contains(prefixText)) || x.EmpGroupName.Contains(prefixText))).OrderBy(x => x.EmpGroupID).Select(x => SqlFunctions.StringConvert((double)x.EmpGroupID).Trim() + " - " + x.EmpGroupName).Take(20).ToList();
            }
            else if (contextKey == "OEXT")
            {
                if (prefixText == "*")
                    StrCust = ctx.OEXTs.OrderBy(x => x.ExpTypeID).Select(x => SqlFunctions.StringConvert((double)x.ExpTypeID).Trim() + " - " + x.ExpType).Take(20).ToList();
                else
                    StrCust = ctx.OEXTs.Where(x => (SqlFunctions.StringConvert((double)x.ExpTypeID).Contains(prefixText)) || x.ExpType.Contains(prefixText)).OrderBy(x => x.ExpTypeID).Select(x => SqlFunctions.StringConvert((double)x.ExpTypeID).Trim() + " - " + x.ExpType).Take(20).ToList();
            }
            else if (contextKey == "ORSN")
            {
                if (prefixText == "*")
                    StrCust = ctx.ORSNs.OrderBy(x => x.ReasonID).Select(x => SqlFunctions.StringConvert((double)x.ReasonID).Trim() + " - " + x.ReasonName).Take(20).ToList();
                else
                    StrCust = ctx.ORSNs.Where(x => (SqlFunctions.StringConvert((double)x.ReasonID).Contains(prefixText)) || x.ReasonName.Contains(prefixText)).OrderBy(x => x.ReasonID).Select(x => SqlFunctions.StringConvert((double)x.ReasonID).Trim() + " - " + x.ReasonName).Take(20).ToList();
            }
            else if (contextKey == "OASTG")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTGs.OrderBy(x => x.AssetGroupID).Select(x => SqlFunctions.StringConvert((double)x.AssetGroupID).Trim() + " - " + x.AssetGroupName).Take(20).ToList();
                else
                    StrCust = ctx.OASTGs.Where(x => (SqlFunctions.StringConvert((double)x.AssetGroupID).Contains(prefixText)) || x.AssetGroupName.Contains(prefixText)).OrderBy(x => x.AssetGroupID).Select(x => SqlFunctions.StringConvert((double)x.AssetGroupID).Trim() + " - " + x.AssetGroupName).Take(20).ToList();
            }
            else if (contextKey == "OASTC")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTCs.OrderBy(x => x.AssetConditionID).Select(x => SqlFunctions.StringConvert((double)x.AssetConditionID).Trim() + " - " + x.AssetConditionName).Take(20).ToList();
                else
                    StrCust = ctx.OASTCs.Where(x => (SqlFunctions.StringConvert((double)x.AssetConditionID).Contains(prefixText)) || x.AssetConditionName.Contains(prefixText)).OrderBy(x => x.AssetConditionID).Select(x => SqlFunctions.StringConvert((double)x.AssetConditionID).Trim() + " - " + x.AssetConditionName).Take(20).ToList();
            }
            else if (contextKey == "OASTU")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTUs.OrderBy(x => x.AssetStatusID).Select(x => SqlFunctions.StringConvert((double)x.AssetStatusID).Trim() + " - " + x.AssetStatusName).Take(20).ToList();
                else
                    StrCust = ctx.OASTUs.Where(x => (SqlFunctions.StringConvert((double)x.AssetStatusID).Contains(prefixText)) || x.AssetStatusName.Contains(prefixText)).OrderBy(x => x.AssetStatusID).Select(x => SqlFunctions.StringConvert((double)x.AssetStatusID).Trim() + " - " + x.AssetStatusName).Take(20).ToList();
            }
            else if (contextKey == "OASTY")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTies.OrderBy(x => x.AssetTypeID).Select(x => SqlFunctions.StringConvert((double)x.AssetTypeID).Trim() + " - " + x.AssetTypeName).Take(20).ToList();
                else
                    StrCust = ctx.OASTies.Where(x => (SqlFunctions.StringConvert((double)x.AssetTypeID).Contains(prefixText)) || x.AssetTypeName.Contains(prefixText)).OrderBy(x => x.AssetTypeID).Select(x => SqlFunctions.StringConvert((double)x.AssetTypeID).Trim() + " - " + x.AssetTypeName).Take(20).ToList();
            }
            else if (contextKey == "OASTYB")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTYBs.OrderBy(x => x.AssetSubTypeName).Select(x => SqlFunctions.StringConvert((double)x.AssetSubTypeID).Trim() + " - " + x.AssetSubTypeName).Take(50).ToList();
                else
                    StrCust = ctx.OASTYBs.Where(x => (SqlFunctions.StringConvert((double)x.AssetSubTypeID).Contains(prefixText)) || x.AssetSubTypeName.Contains(prefixText)).OrderBy(x => x.AssetSubTypeName).Select(x => SqlFunctions.StringConvert((double)x.AssetSubTypeID).Trim() + " - " + x.AssetSubTypeName).Take(50).ToList();
            }
            else if (contextKey == "OASTB")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTBs.OrderBy(x => x.AssetBrandID).Select(x => SqlFunctions.StringConvert((double)x.AssetBrandID).Trim() + " - " + x.AssetBrandName + " - " + x.OASTZ.AssetSizeName + " - " + x.OASTZ.OASTYB.AssetSubTypeName).Take(50).ToList();
                else
                    StrCust = ctx.OASTBs.Where(x => (SqlFunctions.StringConvert((double)x.AssetBrandID).Contains(prefixText)) || x.AssetBrandName.Contains(prefixText)).OrderBy(x => x.AssetBrandID).Select(x => SqlFunctions.StringConvert((double)x.AssetBrandID).Trim() + " - " + x.AssetBrandName + " - " + x.OASTZ.AssetSizeName + " - " + x.OASTZ.OASTYB.AssetSubTypeName).Take(50).ToList();
            }
            else if (contextKey == "OEXM")
            {
                if (prefixText == "*")
                    StrCust = ctx.OEXMs.OrderBy(x => x.ExpModeID).Select(x => SqlFunctions.StringConvert((double)x.ExpModeID).Trim() + " - " + x.ExpMode).Take(20).ToList();
                else
                    StrCust = ctx.OEXMs.Where(x => (SqlFunctions.StringConvert((double)x.ExpModeID).Contains(prefixText)) || x.ExpMode.Contains(prefixText)).OrderBy(x => x.ExpModeID).Select(x => SqlFunctions.StringConvert((double)x.ExpModeID).Trim() + " - " + x.ExpMode).Take(20).ToList();
            }
            else if (contextKey == "OASTZ")
            {
                if (prefixText == "*")
                    StrCust = ctx.OASTZs.OrderBy(x => x.AssetSizeID).Select(x => SqlFunctions.StringConvert((double)x.AssetSizeID).Trim() + " - " + x.AssetSizeName + " - " + x.OASTYB.AssetSubTypeName).Take(50).ToList();
                else
                    StrCust = ctx.OASTZs.Where(x => (SqlFunctions.StringConvert((double)x.AssetSizeID).Contains(prefixText)) || x.AssetSizeName.Contains(prefixText)).OrderBy(x => x.AssetSizeID).Select(x => SqlFunctions.StringConvert((double)x.AssetSizeID).Trim() + " - " + x.AssetSizeName + " - " + x.OASTYB.AssetSubTypeName).Take(50).ToList();
            }
            else if (contextKey == "OPLT")
            {
                if (prefixText == "*")
                    StrCust = ctx.OPLTs.OrderBy(x => x.PlantID).Select(x => SqlFunctions.StringConvert((double)x.PlantID).Trim() + " - " + x.PlantName).Take(20).ToList();
                else
                    StrCust = ctx.OPLTs.Where(x => (SqlFunctions.StringConvert((double)x.PlantID).Contains(prefixText)) || x.PlantName.Contains(prefixText)).OrderBy(x => x.PlantID).Select(x => SqlFunctions.StringConvert((double)x.PlantID).Trim() + " - " + x.PlantName).Take(20).ToList();
            }
            else if (contextKey == "OPIN")
            {
                if (prefixText == "*")
                    StrCust = ctx.OPINs.OrderBy(x => x.PinCodeID).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim()).Take(20).ToList();
                else
                    StrCust = ctx.OPINs.Where(x => SqlFunctions.StringConvert((double)x.PinCodeID).Contains(prefixText)).OrderBy(x => x.PinCodeID).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim()).Take(20).ToList();
            }
            else if (contextKey == "OBRND")
            {
                if (prefixText == "*")
                    StrCust = ctx.OBRNDs.OrderBy(x => x.BrandID).Select(x => SqlFunctions.StringConvert((double)x.BrandID).Trim() + " - " + x.BrandName).Take(20).ToList();
                else
                    StrCust = ctx.OBRNDs.Where(x => (SqlFunctions.StringConvert((double)x.BrandID).Contains(prefixText)) || x.BrandName.Contains(prefixText)).OrderBy(x => x.BrandID).Select(x => SqlFunctions.StringConvert((double)x.BrandID).Trim() + " - " + x.BrandName).Take(20).ToList();
            }
            else if (contextKey == "OTRSN")
            {
                if (prefixText == "*")
                    StrCust = ctx.OTRSNs.OrderBy(x => x.TaskReasonID).Select(x => SqlFunctions.StringConvert((double)x.TaskReasonID).Trim() + " - " + x.TaskReasonName).Take(20).ToList();
                else
                    StrCust = ctx.OTRSNs.Where(x => (SqlFunctions.StringConvert((double)x.TaskReasonID).Contains(prefixText)) || x.TaskReasonName.Contains(prefixText)).OrderBy(x => x.TaskReasonID).Select(x => SqlFunctions.StringConvert((double)x.TaskReasonID).Trim() + " - " + x.TaskReasonName).Take(20).ToList();
            }
            else if (contextKey == "OTTY")
            {
                if (prefixText == "*")
                    StrCust = ctx.OTTies.OrderBy(x => x.TaskTypeID).Select(x => SqlFunctions.StringConvert((double)x.TaskTypeID).Trim() + " - " + x.TaskTypeName).Take(20).ToList();
                else
                    StrCust = ctx.OTTies.Where(x => (SqlFunctions.StringConvert((double)x.TaskTypeID).Contains(prefixText)) || x.TaskTypeName.Contains(prefixText)).OrderBy(x => x.TaskTypeID).Select(x => SqlFunctions.StringConvert((double)x.TaskTypeID).Trim() + " - " + x.TaskTypeName).Take(20).ToList();
            }
            else if (contextKey == "OPLM")
            {
                if (prefixText == "*")
                    StrCust = ctx.OPLMs.OrderBy(x => x.ProblemID).Select(x => SqlFunctions.StringConvert((double)x.ProblemID).Trim() + " - " + x.ProbemName).Take(20).ToList();
                else
                    StrCust = ctx.OPLMs.Where(x => (SqlFunctions.StringConvert((double)x.ProblemID).Contains(prefixText)) || x.ProbemName.Contains(prefixText)).OrderBy(x => x.ProblemID).Select(x => SqlFunctions.StringConvert((double)x.ProblemID).Trim() + " - " + x.ProbemName).Take(20).ToList();
            }
            else if (contextKey == "OTCF")
            {
                if (prefixText == "*")
                    StrCust = ctx.OTCFs.OrderBy(x => x.TaskCreatedFromID).Select(x => SqlFunctions.StringConvert((double)x.TaskCreatedFromID).Trim() + " - " + x.TaskCreatedFrom).Take(20).ToList();
                else
                    StrCust = ctx.OTCFs.Where(x => (SqlFunctions.StringConvert((double)x.TaskCreatedFromID).Contains(prefixText)) || x.TaskCreatedFrom.Contains(prefixText)).OrderBy(x => x.TaskCreatedFromID).Select(x => SqlFunctions.StringConvert((double)x.TaskCreatedFromID).Trim() + " - " + x.TaskCreatedFrom).Take(20).ToList();
            }
            else if (contextKey == "OPLCK")
            {
                if (prefixText == "*")
                    StrCust = ctx.OPLCKs.OrderBy(x => x.ProblemCheckID).Select(x => SqlFunctions.StringConvert((double)x.ProblemCheckID).Trim() + " - " + x.CheckPointTask).Take(20).ToList();
                else
                    StrCust = ctx.OPLCKs.Where(x => (SqlFunctions.StringConvert((double)x.ProblemCheckID).Contains(prefixText)) || x.CheckPointTask.Contains(prefixText)).OrderBy(x => x.ProblemCheckID).Select(x => SqlFunctions.StringConvert((double)x.ProblemCheckID).Trim() + " - " + x.CheckPointTask).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetItemGroup(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OITBs
                           where c.Active
                           orderby c.SortOrder
                           select SqlFunctions.StringConvert((double)c.ItemGroupID).Trim() + " - " + c.ItemGroupName.Replace("-", " ").Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OITBs
                           where (c.ItemGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemGroupID).Contains(prefixText)) && c.Active
                           orderby c.SortOrder
                           select SqlFunctions.StringConvert((double)c.ItemGroupID).Trim() + " - " + c.ItemGroupName.Replace("-", " ").Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSubGroupItem(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int ItemGroupID;
            if (Int32.TryParse(contextKey, out ItemGroupID))
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.OITGs
                               where c.Active && c.ItemGroupID == ItemGroupID
                               orderby c.SortOrder
                               select SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim() + " - " + c.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.OITGs
                               where (c.ItemSubGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemSubGroupID).Contains(prefixText)) && c.Active && c.ItemGroupID == ItemGroupID
                               orderby c.SortOrder
                               select SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim() + " - " + c.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.OITGs
                               where c.Active
                               orderby c.SortOrder
                               select SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim() + " - " + c.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.OITGs
                               where (c.ItemSubGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemSubGroupID).Contains(prefixText)) && c.Active
                               orderby c.SortOrder
                               select SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim() + " - " + c.ItemSubGroupName.Replace("-", " ").Trim()).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetItemWithID(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int ItemSubGroupID;
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (Int32.TryParse(contextKey, out ItemSubGroupID))
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.SITMs
                               where c.OTMP.IsDefault && c.ParentID == ParentID && c.OITM.SubGroupID == ItemSubGroupID
                               orderby c.Priority
                               select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.SITMs
                               where c.OTMP.IsDefault && c.ParentID == ParentID && c.OITM.SubGroupID == ItemSubGroupID && (c.OITM.ItemCode.Contains(prefixText) || c.OITM.ItemName.Contains(prefixText))
                               orderby c.Priority
                               select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.SITMs
                               where c.OTMP.IsDefault && c.ParentID == ParentID
                               orderby c.Priority
                               select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.SITMs
                               where c.OTMP.IsDefault && c.ParentID == ParentID && (c.OITM.ItemCode.Contains(prefixText) || c.OITM.ItemName.Contains(prefixText))
                               orderby c.Priority
                               select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetItemWithGroupID(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int ItemGroupID = 0, divisionId = 0;
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (!string.IsNullOrEmpty(contextKey))
            {
                ItemGroupID = Int32.TryParse(contextKey.Trim().Split('-')[0], out ItemGroupID) ? ItemGroupID : 0;
                divisionId = Int32.TryParse(contextKey.Trim().Split('-')[1], out divisionId) ? divisionId : 0;
            }

            if (prefixText == "*")
            {
                StrCust = (from c in ctx.SITMs
                           where c.OTMP.IsDefault &&
                           c.ParentID == ParentID &&
                           (ItemGroupID == 0 || c.OITM.GroupID == ItemGroupID) &&
                           (divisionId == 0 || c.OITM.OGITMs.Any(x => x.DivisionlID == divisionId && x.ItemID == c.ItemID))
                           orderby c.Priority
                           select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.SITMs
                           where c.OTMP.IsDefault && c.ParentID == ParentID && c.OITM.GroupID == ItemGroupID && (c.OITM.ItemCode.Contains(prefixText) || c.OITM.ItemName.Contains(prefixText))
                            && (ItemGroupID == 0 || c.OITM.GroupID == ItemGroupID) &&
                           (divisionId == 0 || c.OITM.OGITMs.Any(x => x.DivisionlID == divisionId && x.ItemID == c.ItemID))
                           orderby c.Priority
                           select SqlFunctions.StringConvert((double)c.ItemID).Trim() + " - " + c.OITM.ItemCode + " - " + c.OITM.ItemName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSITM(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OTMPs
                           where c.ParentID == ParentID
                           orderby c.TemplateName
                           select SqlFunctions.StringConvert((double)c.TemplateID).Trim() + " - " + c.TemplateName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OTMPs
                           where (c.TemplateName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.TemplateID).Contains(prefixText)) && c.ParentID == ParentID
                           orderby c.TemplateName
                           select SqlFunctions.StringConvert((double)c.TemplateID).Trim() + " - " + c.TemplateName).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveOAST(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OASTs
                           orderby c.SerialNumber
                           select c.SerialNumber.Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OASTs
                           where (c.AssetName.Contains(prefixText) || c.SerialNumber.Contains(prefixText))
                           orderby c.SerialNumber
                           select c.SerialNumber.Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveSITM(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OTMPs
                           where c.ParentID == ParentID && c.Active && !c.IsDefault
                           orderby c.TemplateName
                           select SqlFunctions.StringConvert((double)c.TemplateID).Trim() + " - " + c.TemplateName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OTMPs
                           where c.ParentID == ParentID && c.Active && !c.IsDefault && (c.TemplateName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.TemplateID).Contains(prefixText))
                           orderby c.TemplateName
                           select SqlFunctions.StringConvert((double)c.TemplateID).Trim() + " - " + c.TemplateName).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveExpense(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (prefixText == "*")
            {
                StrCust = StrCust = ctx.OEXPs.Where(x => x.ParentID == ParentID && x.Active).OrderByDescending(x => x.ExpenseID).Select(x => SqlFunctions.StringConvert((double)x.ExpenseID).Trim() + " - " + x.Name).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OEXPs.Where(x => x.ParentID == ParentID && x.Active && (SqlFunctions.StringConvert((double)x.ExpenseID).Contains(prefixText)) || x.Name.Contains(prefixText)).OrderByDescending(x => x.ExpenseID).Select(x => SqlFunctions.StringConvert((double)x.ExpenseID).Trim() + " - " + x.Name).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetInwardReportNo(string prefixText, int count, string contextKey)
    {
        var data = contextKey.Split(",".ToArray()).ToArray();
        Int32 InwardType = Convert.ToInt32(data[0]);
        decimal ParentID = Convert.ToDecimal(data[1]);

        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OMIDs
                            where c.ParentID == ParentID && c.InwardType == InwardType
                            orderby c.Date descending
                            select new
                            {
                                c.InwardID,
                                c.InvoiceNumber,
                                c.Date,
                                c.BillNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + " - " + x.InvoiceNumber + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }
            else
            {
                var Data = (from c in ctx.OMIDs
                            where (c.ParentID == ParentID) && c.InwardType == InwardType
                            && (c.InvoiceNumber.Contains(prefixText) || c.BillNumber.Contains(prefixText))
                            orderby c.Date descending
                            select new
                            {
                                c.InwardID,
                                c.InvoiceNumber,
                                c.Date,
                                c.BillNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + " - " + x.InvoiceNumber + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveInward(string prefixText, int count, string contextKey)
    {
        decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        DateTime currentDate = DateTime.Now.AddDays(-180);
        List<String> StrMat = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OMIDs
                            where c.ParentID == ParentID && c.InvoiceDate >= currentDate && new int[] { 3, 4 }.Contains(c.InwardType) && c.Discount == 0
                            orderby c.InvoiceDate, c.InvoiceNumber
                            select new
                            {
                                c.InwardID,
                                c.Date,
                                c.BillNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }
            else
            {
                var Data = (from c in ctx.OMIDs
                            where c.ParentID == ParentID && c.InvoiceDate >= currentDate && new int[] { 3, 4 }.Contains(c.InwardType) && c.Discount == 0
                            && (SqlFunctions.StringConvert((double)c.InwardID).Contains(prefixText) || c.BillNumber.Contains(prefixText))
                            orderby c.InvoiceDate, c.InvoiceNumber
                            select new
                            {
                                c.InwardID,
                                c.Date,
                                c.BillNumber
                            }).Take(20).ToList();

                foreach (var x in Data)
                    StrMat.Add(x.InwardID.ToString() + (String.IsNullOrEmpty(x.BillNumber) ? "" : " - " + x.BillNumber) + " - " + Common.DateTimeConvert(x.Date));
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetAssetsCode(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

            List<String> assetList = new List<string>();
            if (prefixText == "*")
            {
                assetList = ctx.OASTs.OrderBy(x => x.AssetCode).Select(x => x.AssetCode + " - " + x.AssetName).Take(20).ToList();
            }
            else
            {
                assetList = ctx.OASTs.Where(x => x.AssetName.Contains(prefixText)).OrderBy(x => x.AssetCode).Select(x => x.AssetCode + " - " + x.AssetName).Take(20).ToList();
            }

            return assetList;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetHoldingAssetsCode(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

            List<OAST> assetList = new List<OAST>();
            if (prefixText == "*")
            {
                assetList = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID == ParentID).OrderBy(x => x.AssetCode).Take(20).ToList();
            }
            else
            {
                assetList = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID == ParentID && x.AssetName.Contains(prefixText)).OrderBy(x => x.AssetCode).Take(20).ToList();
            }

            List<string> assetCodes = new List<string>();
            List<string> finalAssetCodes = new List<string>();
            int astID = 0;
            OASTF astf = null;
            foreach (OAST objast in assetList)
            {
                astID = ctx.OASTs.FirstOrDefault(x => x.AssetCode == objast.AssetCode).AssetID;
                astf = ctx.OASTFs.FirstOrDefault(x => x.IsConfirm == false && x.TransferByCustomerID == ParentID && x.AssetID == astID);
                if (astf == null)
                {
                    finalAssetCodes.Add(objast.AssetCode + " - " + objast.AssetName);
                }
            }
            return finalAssetCodes;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCouponCodes(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<string> couponList = new List<string>();
            if (prefixText == "*")
            {
                var Data = (from c in ctx.OCPNs
                            orderby c.CouponCode
                            select new
                            {
                                c.CouponCode,
                                c.CouponName
                            }).Take(10).ToList();

                foreach (var x in Data)
                    couponList.Add(x.CouponCode + " - " + x.CouponName);
            }
            else
            {
                var Data = (from c in ctx.OCPNs
                            where c.CouponCode.Contains(prefixText) || c.CouponName.Contains(prefixText)
                            orderby c.CouponCode
                            select new
                            {
                                c.CouponCode,
                                c.CouponName
                            }).Take(10).ToList();

                foreach (var x in Data)
                    couponList.Add(x.CouponCode + " - " + x.CouponName);
            }

            return couponList;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPinCodes(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<string> PinCodes = new List<string>();
            if (prefixText == "*")
            {
                PinCodes = ctx.OPINs.Where(x => x.Active).OrderBy(x => x.Area).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim() + " - " + x.Area).Take(20).ToList();
            }
            else
            {
                PinCodes = ctx.OPINs.Where(x => x.Active && SqlFunctions.StringConvert((double)x.PinCodeID).Contains(prefixText) || x.Area.Contains(prefixText)).OrderBy(x => x.Area).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim() + " - " + x.Area).Take(20).ToList();
            }

            return PinCodes;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveMaterialByPlant(string prefixText, int count, string contextKey)
    {
        List<String> StrMat = new List<string>();
        List<int> ItemIDs = new List<int>();
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        if (!string.IsNullOrEmpty(contextKey) && contextKey.Split("#".ToArray()).Length == 2)
        {
            var itms = contextKey.Split("#".ToArray());

            ParentID = Decimal.TryParse(itms[0], out ParentID) ? ParentID : 0;

            var stritem = itms[1].Trim();
            if (!String.IsNullOrEmpty(stritem))
            {
                stritem.Split(",".ToArray()).ToList().ForEach(x => ItemIDs.Add(Convert.ToInt32(x)));
            }
        }

        using (var ctx = new DDMSEntities())
        {
            List<int> PlantIDs = ctx.OGCRDs.Where(y => y.PlantID.HasValue && y.DivisionlID.HasValue && y.CustomerID == ParentID).Select(x => x.PlantID.Value).Distinct().ToList();

            if (prefixText == "*")
            {
                StrMat = ctx.OITMs.Where(x => x.Active && !(ItemIDs.Contains(x.ItemID)) && (x.OGITMs.Any(s => s.PlantID.HasValue && PlantIDs.Contains(s.PlantID.Value) && s.Active))).
                    Select(x => x.ItemCode + " - " + x.ItemName).Take(20).ToList();
            }
            else
            {
                StrMat = ctx.OITMs.Where(x => x.Active && !(ItemIDs.Contains(x.ItemID)) &&
                        (x.ItemCode.Contains(prefixText) || x.ItemName.Contains(prefixText))
                        && (x.OGITMs.Any(s => s.PlantID.HasValue && PlantIDs.Contains(s.PlantID.Value) && s.Active))).
                        Select(x => x.ItemCode + " - " + x.ItemName).Take(20).ToList();
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveMaterialByDivision(string prefixText, int count, string contextKey)
    {
        List<String> StrMat = new List<string>();

        List<int> ItemIDs = new List<int>();
        int divID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            var arr = contextKey.Split('#').ToArray();
            if (arr.Length == 2)
            {
                divID = Convert.ToInt32(arr[0]);
                if (!String.IsNullOrEmpty(arr[1]))
                    arr[1].Split(",".ToArray()).ToList().ForEach(x => ItemIDs.Add(Convert.ToInt32(x)));
            }
        }

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrMat = (from c in ctx.OITMs
                          where c.Active && c.OGITMs.Any(s => s.DivisionlID == divID) && (!ItemIDs.Contains(c.ItemID))
                          orderby c.ItemName
                          select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
            }
            else
            {
                StrMat = (from c in ctx.OITMs
                          where c.Active && c.OGITMs.Any(s => s.DivisionlID == divID) && (c.ItemCode.Contains(prefixText) || c.ItemName.Contains(prefixText))
                          && (!ItemIDs.Contains(c.ItemID))
                          orderby c.ItemName
                          select c.ItemCode + " - " + c.ItemName).Take(20).ToList();
            }

            return StrMat;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetVehicle(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrVeh = new List<string>();
            decimal ParentID = Convert.ToDecimal(contextKey);
            if (prefixText == "*")
            {
                StrVeh = ctx.OVCLs.Where(x => x.ParentID == ParentID).OrderByDescending(x => x.VehicleID).Select(x => x.VehicleNumber).Take(20).ToList();
            }
            else
            {
                StrVeh = ctx.OVCLs.Where(x => x.VehicleNumber.Contains(prefixText) && x.ParentID == ParentID).OrderByDescending(x => x.VehicleID).Select(x => x.VehicleNumber).Take(20).ToList();
            }
            return StrVeh;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveVehicle(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrVeh = new List<string>();
            decimal ParentID = Convert.ToDecimal(contextKey);
            if (prefixText == "*")
            {
                StrVeh = ctx.OVCLs.Where(x => x.Active && x.ParentID == ParentID).OrderByDescending(x => x.VehicleID).Select(x => x.VehicleNumber).Take(20).ToList();
            }
            else
            {
                StrVeh = ctx.OVCLs.Where(x => x.Active && x.VehicleNumber.Contains(prefixText) && x.ParentID == ParentID).OrderByDescending(x => x.VehicleID).Select(x => x.VehicleNumber).Take(20).ToList();
            }
            return StrVeh;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetRoute(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            Int32 RouteType = Int32.TryParse(contextKey.Split("-".ToArray()).Last(), out RouteType) ? RouteType : 0;
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.ORUTs
                           where c.ParentID == 1000010000000000 && (RouteType == 0 || c.RouteType == RouteType)
                           orderby c.Active descending, c.RouteCode
                           select c.RouteCode + " - " + c.RouteName + " - ( " + (c.Active ? "Active" : "InActive") + " ) - " + SqlFunctions.StringConvert((Double)c.RouteID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.ORUTs
                           where (c.RouteName.Contains(prefixText) || c.RouteCode.Contains(prefixText) || c.OEMP1.Name.Contains(prefixText) || c.OEMP1.EmpCode.Contains(prefixText)) && c.ParentID == 1000010000000000 && (RouteType == 0 || c.RouteType == RouteType)
                           orderby c.Active descending, c.RouteCode
                           select c.RouteCode + " - " + c.RouteName + " - ( " + (c.Active ? "Active" : "InActive") + " ) - " + SqlFunctions.StringConvert((Double)c.RouteID).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCompetitorRoute(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            Int32 CBRoute = Int32.TryParse(contextKey.Split("-".ToArray()).Last(), out CBRoute) ? CBRoute : 0;
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRUTs
                           where c.ParentID == 1000010000000000 && (CBRoute == 0 || c.CompRouteID == CBRoute)
                           orderby c.Active descending, c.RouteCode
                           select c.RouteCode + " - " + c.RouteName + " - ( " + (c.Active ? "Active" : "InActive") + " ) - " + SqlFunctions.StringConvert((Double)c.CompRouteID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCRUTs
                           where (c.RouteName.Contains(prefixText) || c.RouteCode.Contains(prefixText) || c.OEMP.Name.Contains(prefixText) || c.OEMP.EmpCode.Contains(prefixText)) && c.ParentID == 1000010000000000 && (CBRoute == 0 || c.CompRouteID == CBRoute)
                           orderby c.Active descending, c.RouteCode
                           select c.RouteCode + " - " + c.RouteName + " - ( " + (c.Active ? "Active" : "InActive") + " ) - " + SqlFunctions.StringConvert((Double)c.CompRouteID).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPlant(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            Int32 StateID = Int32.TryParse(contextKey, out StateID) ? StateID : 0;

            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OPLTs
                           where c.Active == true && (StateID == 0 || c.StateID == StateID)
                           orderby c.PlantID
                           select SqlFunctions.StringConvert((Double)c.PlantID, 5, 0).Trim() + " - " + c.PlantCode + " - " + c.PlantName).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OPLTs
                           where (c.PlantName.Contains(prefixText) || c.PlantCode.Contains(prefixText)) && c.Active == true && (StateID == 0 || c.StateID == StateID)
                           orderby c.PlantID
                           select SqlFunctions.StringConvert((Double)c.PlantID, 5, 0).Trim() + " - " + c.PlantCode + " - " + c.PlantName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerWithLocation(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        Decimal ParentID = 0;
        Int32 Custtype = 0;
        using (var ctx = new DDMSEntities())
        {
            if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
            {
                ParentID = Decimal.TryParse(contextKey.Split("-".ToArray()).First(), out ParentID) ? ParentID : 0;
                Custtype = Int32.TryParse(contextKey.Split("-".ToArray()).Last(), out Custtype) ? Custtype : 0;
            }
            if (ParentID > 0)
            {
                if (prefixText == "*")
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where d.ParentID == ParentID && d.Active && c.BranchID == 1 //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
                else
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where (d.CustomerName.Contains(prefixText) || d.CustomerCode.Contains(prefixText)) && c.BranchID == 1 && d.ParentID == ParentID && d.Active  //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where d.Type == Custtype && d.Active && c.BranchID == 1 //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
                else
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where (d.CustomerName.Contains(prefixText) || d.CustomerCode.Contains(prefixText)) && d.Type == Custtype && d.Active //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerWithLocationForRouteMaster(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        Decimal ParentID = 0;
        Int32 Custtype = 0;
        using (var ctx = new DDMSEntities())
        {
            if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
            {
                ParentID = Decimal.TryParse(contextKey.Split("-".ToArray()).First(), out ParentID) ? ParentID : 0;
                Custtype = Int32.TryParse(contextKey.Split("-".ToArray()).Last(), out Custtype) ? Custtype : 0;
            }
            if (ParentID > 0)
            {
                if (prefixText == "*")
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where d.ParentID == ParentID && d.Active == (d.IsTemp == false ? d.Active == true : d.Active) && c.BranchID == 1 //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
                else
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where (d.CustomerName.Contains(prefixText) || d.CustomerCode.Contains(prefixText)) && c.BranchID == 1 && d.ParentID == ParentID
                               && d.Active == (d.IsTemp == false ? d.Active == true : d.Active)
                               //d.Active  //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where d.Type == Custtype && d.Active == (d.IsTemp == false ? d.Active == true : d.Active) && c.BranchID == 1 //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
                else
                {
                    StrCust = (from d in ctx.OCRDs
                               join c in ctx.CRD1 on d.CustomerID equals c.CustomerID
                               join a in ctx.AOCRDs on d.CustomerID equals a.CustomerID into ps
                               from p in ps.DefaultIfEmpty()
                               where (d.CustomerName.Contains(prefixText) || d.CustomerCode.Contains(prefixText)) && d.Type == Custtype
                               && d.Active == (d.IsTemp == false ? d.Active == true : d.Active) //&& d.Active //&& !ctx.RUT1.Any(x => x.CustomerID == d.CustomerID)
                               orderby d.CustomerName
                               select d.CustomerCode + " - " + d.CustomerName.Replace("-", " ") + (!String.IsNullOrEmpty(c.Branch) ? " - " + c.Branch : "") + (!String.IsNullOrEmpty(c.Location) ? " - " + c.Location : "")).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetStateNames(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();
            if (prefixText == "*")
            {
                StrCust = ctx.OCSTs.Where(x => x.Active).OrderBy(x => x.StateID).Select(x => SqlFunctions.StringConvert((double)x.StateID).Trim() + " - " + x.StateName).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OCSTs.Where(x => x.Active && (SqlFunctions.StringConvert((double)x.StateID).Contains(prefixText)) || x.StateName.Contains(prefixText)).OrderBy(x => x.StateID).Select(x => SqlFunctions.StringConvert((double)x.StateID).Trim() + " - " + x.StateName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCityNames(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();
            int stateID = 0;
            if (contextKey != "")
            {
                stateID = Convert.ToInt32(contextKey);
            }

            if (prefixText == "*")
            {
                StrCust = ctx.OCTies.Where(x => x.Active && (stateID == 0 || x.StateID == stateID)).OrderBy(x => x.CityName).Select(x => SqlFunctions.StringConvert((double)x.CityID).Trim() + " - " + x.CityName).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OCTies.Where(x => x.Active && (stateID == 0 || x.StateID == stateID) && ((SqlFunctions.StringConvert((double)x.CityID).Contains(prefixText)) || x.CityName.Contains(prefixText))).OrderBy(x => x.CityName).Select(x => SqlFunctions.StringConvert((double)x.CityID).Trim() + " - " + x.CityName).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPinCodesByCriteria(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            int stateID = 0;
            int cityID = 0;

            if (contextKey != "")
            {
                var array = contextKey.Split('#');
                if (array.Length == 2)
                {
                    stateID = Convert.ToInt32(array[0]);
                    cityID = Convert.ToInt32(array[1]);
                }
                else
                {
                    stateID = Convert.ToInt32(array[0]);
                }
            }

            List<string> PinCodes = new List<string>();
            if (prefixText == "*")
            {
                PinCodes = ctx.OPINs.Where(x => x.Active && (x.StateID == stateID || stateID == 0) && (x.CityID == cityID || cityID == 0)).OrderBy(x => x.Area).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim() + " - " + x.Area).Take(20).ToList();
            }
            else
            {
                PinCodes = ctx.OPINs.Where(x => x.Active && (x.StateID == stateID || stateID == 0) && (x.CityID == cityID || cityID == 0) && SqlFunctions.StringConvert((double)x.PinCodeID).Contains(prefixText) || x.Area.Contains(prefixText)).OrderBy(x => x.Area).Select(x => SqlFunctions.StringConvert((double)x.PinCodeID).Trim() + " - " + x.Area).Take(20).ToList();
            }

            return PinCodes;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCreditNoteNo(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            Decimal CustomerID = Decimal.TryParse(contextKey, out CustomerID) ? CustomerID : 0;

            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCNTs
                           where c.RemainAmount > 1 && c.ParentID == ParentID && c.CustomerID == CustomerID && c.CreditNoteType == "R"
                           && c.Status == "C" && (!c.ValidTillDate.HasValue || c.ValidTillDate.Value > DateTime.Now)
                           orderby c.CreditNoteID
                           select SqlFunctions.StringConvert((double)c.CreditNoteID).Trim() + " - Rs." + SqlFunctions.StringConvert((double)c.RemainAmount, 6, 4).Trim()).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OCNTs
                           where c.RemainAmount > 1 && c.ParentID == ParentID && c.CustomerID == CustomerID && c.CreditNoteType == "R"
                           && c.Status == "C" && (!c.ValidTillDate.HasValue || c.ValidTillDate.Value > DateTime.Now)
                           && SqlFunctions.StringConvert((double)c.CreditNoteID).Contains(prefixText)
                           orderby c.CreditNoteID
                           select SqlFunctions.StringConvert((double)c.CreditNoteID).Trim() + " - Rs." + SqlFunctions.StringConvert((double)c.RemainAmount, 6, 4).Trim()).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetActiveDivision(string prefixText, int count, string contextKey)
    {
        List<String> StrDiv = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrDiv = ctx.ODIVs.Where(x => x.Active).OrderBy(x => x.DivisionlID).Select(x => SqlFunctions.StringConvert((double)x.DivisionlID).Trim() + " - " + x.DivisionName).Take(20).ToList();
            }
            else
            {
                StrDiv = ctx.ODIVs.Where(x => x.Active && (SqlFunctions.StringConvert((double)x.DivisionlID).Contains(prefixText)) || x.DivisionName.Contains(prefixText)).OrderBy(x => x.DivisionlID).Select(x => SqlFunctions.StringConvert((double)x.DivisionlID).Trim() + " - " + x.DivisionName).Take(20).ToList();
            }


            return StrDiv;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerWiseDivision(string prefixText, int count, string contextKey)
    {
        List<String> StrDiv = new List<string>();

        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrDiv = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID.HasValue).Select(x =>
                SqlFunctions.StringConvert((double)x.DivisionlID).Trim() + " - " + x.ODIV.DivisionName).Distinct().Take(20).ToList();
            }
            else
            {
                StrDiv = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID.HasValue &&
                    (SqlFunctions.StringConvert((double)x.DivisionlID).Contains(prefixText) || x.ODIV.DivisionName.Contains(prefixText))).OrderBy(x => x.DivisionlID)
                            .Select(x => SqlFunctions.StringConvert((double)x.DivisionlID).Trim() + " - " + x.ODIV.DivisionName).Distinct().Take(20).ToList();
            }

            return StrDiv;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPolicyNo(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrPolicy = new List<string>();
            if (prefixText == "*")
            {
                StrPolicy = ctx.OLVPies.OrderBy(x => x.LeavePolicyID).Select(x => SqlFunctions.StringConvert((double)x.LeavePolicyID).Trim() + " - " + x.PolicyName).Take(20).ToList();
            }
            else
            {
                StrPolicy = ctx.OLVPies.Where(x => x.PolicyName.Contains(prefixText) || (SqlFunctions.StringConvert((double)x.LeavePolicyID).Contains(prefixText))).OrderBy(x => x.LeavePolicyID).Select(x => SqlFunctions.StringConvert((double)x.LeavePolicyID).Trim() + " - " + x.PolicyName).Take(20).ToList();
            }

            return StrPolicy;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSaleMachineSchemeNo(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            List<String> StrPolicy = new List<string>();
            if (prefixText == "*")
            {
                StrPolicy = ctx.SMVSPNs.OrderBy(x => x.LeavePolicyID).Select(x => SqlFunctions.StringConvert((double)x.LeavePolicyID).Trim() + " - " + x.SaleMachineSchemeName).Take(20).ToList();
            }
            else
            {
                StrPolicy = ctx.SMVSPNs.Where(x => x.SaleMachineSchemeName.Contains(prefixText) || (SqlFunctions.StringConvert((double)x.LeavePolicyID).Contains(prefixText))).OrderBy(x => x.LeavePolicyID).Select(x => SqlFunctions.StringConvert((double)x.LeavePolicyID).Trim() + " - " + x.SaleMachineSchemeName).Take(20).ToList();
            }

            return StrPolicy;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetQuestion(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.OQUES.Where(x => x.Type == contextKey).OrderBy(x => x.SortOrder).ThenBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.Question).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OQUES.Where(x => x.Type == contextKey && (SqlFunctions.StringConvert((double)x.QuesID).Contains(prefixText) || x.Question.Contains(prefixText))).OrderBy(x => x.SortOrder).ThenBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.Question).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerQuestion(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.DFQUES.Where(x => x.Type == contextKey).OrderBy(x => x.SortOrder).ThenBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.Question).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.DFQUES.Where(x => x.Type == contextKey && (SqlFunctions.StringConvert((double)x.QuesID).Contains(prefixText) || x.Question.Contains(prefixText))).OrderBy(x => x.SortOrder).ThenBy(x => x.QuesID).Select(x => SqlFunctions.StringConvert((double)x.QuesID).Trim() + " - " + x.Question).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetRouteByParentID(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetRouteByParentID";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeGroup(string prefixText, int count, string contextKey)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            List<String> StrCust = new List<string>();
            if (prefixText == "*")
            {
                StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)x.EmpGroupID)).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)x.EmpGroupID)).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistributorfState(string prefixText, int count, string contextKey)
    {
        //decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Decimal StateID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length > 0)
        {
            StateID = Decimal.TryParse(contextKey.Split("-".ToArray()).Last(), out StateID) ? StateID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 2 && c.Active
                           && (StateID == 0 || c.CRD1.Any(x => x.StateID == StateID))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 2 && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           && (StateID == 0 || c.CRD1.Any(x => x.StateID == StateID))
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerOfCustGroup(string prefixText, int count, string contextKey)
    {
        //decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 CustGroupID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            CustGroupID = Int32.TryParse(contextKey, out CustGroupID) ? CustGroupID : 0;
        }

        List<String> StrCust = new List<string>();

        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 3 && c.Active
                           && (CustGroupID == 0 || c.CustGroupID == CustGroupID)
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();

            }
            else
            {
                StrCust = (from c in ctx.OCRDs
                           where c.Type == 3 && c.Active && (c.CustomerName.Contains(prefixText) || c.CustomerCode.Contains(prefixText))
                           && (CustGroupID == 0 || c.CustGroupID == CustGroupID)
                           orderby c.CustomerName
                           select c.CustomerCode + " - " + c.CustomerName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((Decimal)c.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
        }
        return StrCust;
    }
}

