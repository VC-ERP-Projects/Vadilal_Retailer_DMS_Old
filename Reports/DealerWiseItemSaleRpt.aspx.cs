using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DealerWiseItemSaleRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;

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

                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.OMNU.PageName == pagename && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
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

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            }
        }
    }
    #endregion Page Load

    #region Button Click
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (DistributorID == 0 && DealerID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (DistributorID == 0 && DealerID > 0)
            {
                Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
            }
            else if (DistributorID > 0)
            {
                Distid = DistributorID;
            }
            if (SSID == 0 && DistributorID > 0)
            {
                SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistributorID).ParentID;
            }
            else if (SSID > 0)
            {
                SSSID = SSID;
            }
        }
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        string IsDetail = chkIsDetail.Text;
        ifmInvoicewiseItemSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DeaWiseItmSaleFromDate=" + txtFromDate.Text + "&DeaWiseItmSaleToDate=" + txtToDate.Text + "&SSID=" + SSID + "&DistributorID=" + DistributorID + "&DealerID=" + DealerID + "&SaleBy=" + ddlSaleBy.SelectedValue + "&DivisionID=" + ddlDivision.SelectedValue + "&SUserID=" + SUserID + "&IsDetail=" + IsDetail + "&CompCust=" + CustomerId);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (DistributorID == 0 && DealerID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (DistributorID == 0 && DealerID > 0)
            {
                Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
            }
            else if (DistributorID > 0)
            {
                Distid = DistributorID;
            }
            if (SSID == 0 && DistributorID > 0)
            {
                SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistributorID).ParentID;
            }
            else if (SSID > 0)
            {
                SSSID = SSID;
            }
        }
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        string IsDetail = chkIsDetail.Text;
        ifmInvoicewiseItemSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DeaWiseItmSaleFromDate=" + txtFromDate.Text + "&DeaWiseItmSaleToDate=" + txtToDate.Text + "&SSID=" + SSID + "&DistributorID=" + DistributorID + "&DealerID=" + DealerID + "&SaleBy=" + ddlSaleBy.SelectedValue + "&DivisionID=" + ddlDivision.SelectedValue + "&SUserID=" + SUserID + "&IsDetail=" + IsDetail + "&Export=1&CompCust=" + CustomerId);
    }
    #endregion

    protected void ifmInvoicewiseItemSale_Load(object sender, EventArgs e)
    {

    }
}