using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_SalesRegister : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                CustType = Convert.ToInt32(Session["Type"]);
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    AuthType = Auth.AuthorizationType;

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("reports");
                            if (unit != null)
                            {
                                var ctrls = Common.GetAll(this, typeof(Label));
                                foreach (Label item in ctrls)
                                {
                                    if (unit.Elements().Any(x => x.Name == item.ID))
                                        item.Text = unit.Elements().FirstOrDefault(x => x.Name == item.ID).Value;
                                }
                            }
                        }
                        catch (Exception)
                        { }
                    }
                }
            }
        }
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    public void ClearAllInputs()
    {
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        ddlDocType.Items.Insert(0, new ListItem("----Select----", "0"));
        ddlDocType.DataBind();
        if (CustType == 4) // SS
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divDealer.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "4";
            txtSSDistCode.Enabled = ddlSaleBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)// Distributor
        {
            divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlSaleBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        //txtFromDate.Text = txtToDate.Text = "01/02/2020";
        //txtCode.Text = "21200420 - RASESH SHUKLA - 71";
        //txtDistCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
    }

    #endregion

    #region Griedview Events

    //protected void gvSalesRegister_PreRender(object sender, EventArgs e)
    //{
    //    if (gvSalesRegister.Rows.Count > 0)
    //    {
    //        gvSalesRegister.HeaderRow.TableSection = TableRowSection.TableHeader;
    //        gvSalesRegister.FooterRow.TableSection = TableRowSection.TableFooter;
    //    }
    //}

    #endregion

    #region Button Events

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static ResponseData GetData(string FromDate, string ToDate, string SSDistCode, string DistCode, string DealerCode, string EmpCode, string ddlDocType, string ddlInvoiceType, string ddlSaleBy)
    {
        ResponseData result = new ResponseData();
        try
        {
            int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);
            int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"].ToString());
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"].ToString());
            DateTime StartDate = Convert.ToDateTime(FromDate);
            DateTime EndDate = Convert.ToDateTime(ToDate);
            Decimal SSID = Decimal.TryParse(SSDistCode.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(DistCode.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(DealerCode.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(EmpCode.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            //if (!string.IsNullOrEmpty(EmpCode) && SUserID == 0)
            //{
            //    result.Status = false;
            //    result.Message = "Please select proper User.";
            //    result.Data = null;
            //    return result;
            //    //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            //    //return;
            //}

            if (CustType == 1)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (SUserID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).IsAdmin)
                    {
                        result.Status = false;
                        result.Message = "Please select at least one parameter.";
                        result.Data1 = null;
                        return result;
                    }

                    var Data = (from a in ctx.OCRDs
                                join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                join c in ctx.OCTies on b.CityID equals c.CityID
                                where a.CustomerID == (DistributorID > 0 ? DistributorID : SSID)
                                select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();
                    //txtData.Text = Data != null ? Data.CityName : "";
                    result.Data1 = Data != null ? Data.CityName : "";
                }
            }
            else
            {
                if (SUserID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0)
                {
                    result.Status = false;
                    result.Message = "Please select at least one parameter.";
                    result.Data1 = null;
                    return result;
                    //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    //return;
                }
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = (from a in ctx.OCRDs
                                join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                join c in ctx.OCTies on b.CityID equals c.CityID
                                where a.CustomerID == ParentID
                                select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();
                    //txtData.Text = Data != null ? Data.CityName : "";
                    result.Data1 = Data != null ? Data.CityName : "";
                }
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "SalesRegister";
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DocType", ddlDocType);
            Cm.Parameters.AddWithValue("@GroupBy", ddlInvoiceType);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy);
            DataSet Ds = objClass.CommonFunctionForSelect(Cm);
            Ds.Tables[0].Columns.Remove("ORDERDATE");
            if (Ds.Tables.Count > 0)
            {
                if (!string.IsNullOrEmpty(ddlInvoiceType) && ddlInvoiceType == "1")
                {
                    var RowData = Ds.Tables[0].AsEnumerable().Select(x => new
                    {
                        No = x.Field<dynamic>("No."),
                        ParentName = x.Field<dynamic>("Parent Name"),
                        InvType = x.Field<dynamic>("Inv. Type"),
                        InvNo = x.Field<dynamic>("Inv. No"),
                        Date = x.Field<dynamic>("Date"),
                        CustomerCode = x.Field<dynamic>("Customer Code"),
                        CustomerName = x.Field<dynamic>("Customer Name"),
                        CustomerGroup = x.Field<dynamic>("Customer Group"),
                        GSTNo = x.Field<dynamic>("GST No."),
                        GSTState = x.Field<dynamic>("GST State"),
                        UOM = x.Field<dynamic>("UOM"),
                        Material = x.Field<dynamic>("Material"),
                        Quantity = x.Field<dynamic>("Quantity"),
                        GrossAmount = x.Field<dynamic>("Gross Amount").ToString("0.00"),
                        Discount = x.Field<dynamic>("Discount").ToString("0.00"),
                        TotalValue = x.Field<dynamic>("Total Value").ToString("0.00"),
                        Tax = x.Field<dynamic>("% Tax"),
                        CST = x.Field<dynamic>("CST").ToString("0.00"),
                        AddVAT = x.Field<dynamic>("AddVAT").ToString("0.00"),
                        Surcharge = x.Field<dynamic>("Surcharge").ToString("0.00"),
                        VAT = x.Field<dynamic>("VAT").ToString("0.00"),
                        CGST = x.Field<dynamic>("CGST").ToString("0.00"),
                        IGST = x.Field<dynamic>("IGST").ToString("0.00"),
                        SGST = x.Field<dynamic>("SGST").ToString("0.00"),
                        UGST = x.Field<dynamic>("UGST").ToString("0.00"),
                        TotalTax = x.Field<dynamic>("Total Tax").ToString("0.00"),
                        NetAmount = x.Field<dynamic>("Net Amount").ToString("0.00")
                    }).ToList();
                    result.Data = RowData;
                }
                else if (!string.IsNullOrEmpty(ddlInvoiceType) && ddlInvoiceType == "2")
                {
                    var RowData = Ds.Tables[0].AsEnumerable().Select(x => new
                    {
                        No = x.Field<dynamic>("No."),
                        ParentName = x.Field<dynamic>("Parent Name"),
                        InvType = x.Field<dynamic>("Inv. Type"),
                        InvNo = x.Field<dynamic>("Inv. No"),
                        Date = x.Field<dynamic>("Date"),
                        CustomerCode = x.Field<dynamic>("Customer Code"),
                        CustomerName = x.Field<dynamic>("Customer Name"),
                        CustomerGroup = x.Field<dynamic>("Customer Group"),
                        GSTNo = x.Field<dynamic>("GST No."),
                        GSTState = x.Field<dynamic>("GST State"),
                        UOM = x.Field<dynamic>("UOM"),
                        Quantity = x.Field<dynamic>("Quantity"),
                        GrossAmount = x.Field<dynamic>("Gross Amount").ToString("0.00"),
                        Discount = x.Field<dynamic>("Discount").ToString("0.00"),
                        TotalValue = x.Field<dynamic>("Total Value").ToString("0.00"),
                        Tax = x.Field<dynamic>("% Tax"),
                        CST = x.Field<dynamic>("CST").ToString("0.00"),
                        AddVAT = x.Field<dynamic>("AddVAT").ToString("0.00"),
                        Surcharge = x.Field<dynamic>("Surcharge").ToString("0.00"),
                        VAT = x.Field<dynamic>("VAT").ToString("0.00"),
                        CGST = x.Field<dynamic>("CGST").ToString("0.00"),
                        IGST = x.Field<dynamic>("IGST").ToString("0.00"),
                        SGST = x.Field<dynamic>("SGST").ToString("0.00"),
                        UGST = x.Field<dynamic>("UGST").ToString("0.00"),
                        TotalTax = x.Field<dynamic>("Total Tax").ToString("0.00"),
                        NetAmount = x.Field<dynamic>("Net Amount").ToString("0.00")
                    }).ToList();

                    result.Data = RowData;
                }
                else
                {
                    var RowData = Ds.Tables[0].AsEnumerable().Select(x => new
                    {
                        No = x.Field<dynamic>("No."),
                        ParentName = x.Field<dynamic>("Parent Name"),
                        InvType = x.Field<dynamic>("Inv. Type"),
                        InvNo = x.Field<dynamic>("Inv. No"),
                        Date = x.Field<dynamic>("Date"),
                        CustomerCode = x.Field<dynamic>("Customer Code"),
                        CustomerName = x.Field<dynamic>("Customer Name"),
                        CustomerGroup = x.Field<dynamic>("Customer Group"),
                        GSTNo = x.Field<dynamic>("GST No."),
                        GSTState = x.Field<dynamic>("GST State"),
                        HSNCode = x.Field<dynamic>("HSN Code"),
                        UOM = x.Field<dynamic>("UOM"),
                        Quantity = x.Field<dynamic>("Quantity"),
                        GrossAmount = x.Field<dynamic>("Gross Amount").ToString("0.00"),
                        Discount = x.Field<dynamic>("Discount").ToString("0.00"),
                        TotalValue = x.Field<dynamic>("Total Value").ToString("0.00"),
                        Tax = x.Field<dynamic>("% Tax"),
                        CST = x.Field<dynamic>("CST").ToString("0.00"),
                        AddVAT = x.Field<dynamic>("AddVAT").ToString("0.00"),
                        Surcharge = x.Field<dynamic>("Surcharge").ToString("0.00"),
                        VAT = x.Field<dynamic>("VAT").ToString("0.00"),
                        CGST = x.Field<dynamic>("CGST").ToString("0.00"),
                        IGST = x.Field<dynamic>("IGST").ToString("0.00"),
                        SGST = x.Field<dynamic>("SGST").ToString("0.00"),
                        UGST = x.Field<dynamic>("UGST").ToString("0.00"),
                        TotalTax = x.Field<dynamic>("Total Tax").ToString("0.00"),
                        NetAmount = x.Field<dynamic>("Net Amount").ToString("0.00")
                    }).ToList();
                    result.Data = RowData;
                }
            }
            result.Status = true;
            return result;
            //gvSalesRegister.DataSource = ds.Tables[0];
            //gvSalesRegister.DataBind();
        }
        catch (Exception ex)
        {
            result.Status = false;
            result.Message = "alert('" + Common.GetString(ex) + "')";
            result.Data1 = null;
            return result;
        }
    }

    #endregion
}