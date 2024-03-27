using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_InvoiceWiseItemSaleRpt : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    protected String Version;

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
        else if (CustType == 2) // Distributor
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

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        DateTime Todate = Convert.ToDateTime(txtToDate.Text);
        bool isvalid = true;
        //if ((Todate - Fromdate).TotalDays > 31)
        //{
        //    isvalid = false;
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Date Diffrence should be only 31 Days',3);", true);
        //    return;
        //}
        //DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        //DateTime Todate = Convert.ToDateTime(txtToDate.Text);
        //DateTime LstTodate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

        //if ((LstTodate - Fromdate).TotalDays > 365)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
        //    return;
        //}

        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        if (CustType == 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (SUserID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).IsAdmin)
                {
                    isvalid = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
        }
        else
        {
            if (DistributorID == 0 && DealerID == 0 && SSID == 0)
            {
                isvalid = false;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }
        }
        if (isvalid)
        {
            string IsDetail = chkIsDetail.Checked ? "1" : "0";
            ifmInvoicewiseItemSale.Attributes.Add("src", "../Reports/ViewReport.aspx?IvnWiseItmSaleFromDate=" + txtFromDate.Text + "&IvnWiseItmSaleToDate=" + txtToDate.Text + "&IvnSSID=" + SSID + "&InvSaleBy=" + ddlSaleBy.SelectedValue + "&IvnDistributorID=" + DistributorID + "&IvnDealerID=" + DealerID + "&IvnSUserID=" + SUserID + "&IsDetail=" + IsDetail + "&DivisionID=" + ddlDivision.SelectedValue + "&Version=" + Version);
        }
    }

    protected void ifmInvoicewiseItemSale_Load(object sender, EventArgs e)
    {

    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        DateTime Todate = Convert.ToDateTime(txtToDate.Text);
        bool isvalid = true;
        //if ((Todate - Fromdate).TotalDays > 31)
        //{
        //    isvalid = false;
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Date Diffrence should be only 31 Days',3);", true);
        //    return;
        //}
        //DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        //DateTime Todate = Convert.ToDateTime(txtToDate.Text);
        //DateTime LstTodate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

        //if ((LstTodate - Fromdate).TotalDays > 365)
        //{
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
        //    return;
        //}
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        if (CustType == 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (SUserID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).IsAdmin)
                {
                    isvalid = false;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                    return;
                }
            }
        }
        else
        {
            if (DistributorID == 0 && DealerID == 0 && SSID == 0)
            {
                isvalid = false;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }
        }
        if (isvalid)
        {
            string IsDetail = chkIsDetail.Checked ? "1" : "0";
            ifmInvoicewiseItemSale.Attributes.Add("src", "../Reports/ViewReport.aspx?IvnWiseItmSaleFromDate=" + txtFromDate.Text + "&IvnWiseItmSaleToDate=" + txtToDate.Text + "&IvnSSID=" + SSID + "&InvSaleBy=" + ddlSaleBy.SelectedValue + "&IvnDistributorID=" + DistributorID + "&IvnDealerID=" + DealerID + "&IvnSUserID=" + SUserID + "&IsDetail=" + IsDetail + "&DivisionID=" + ddlDivision.SelectedValue + "&Export=1 & DivisionID = " + ddlDivision.SelectedValue + "&Version=" + Version);
        }
    }

    #endregion
}