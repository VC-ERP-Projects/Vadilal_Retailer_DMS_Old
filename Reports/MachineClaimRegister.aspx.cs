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

public partial class Reports_ClaimRegister : System.Web.UI.Page
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
        if (CustType == 4)
        {

            divRegion.Attributes.Add("style", "display:none;");
            divEmpCode.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "4";
            txtSSDistCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
        else if (CustType == 2)
        {
            divRegion.Attributes.Add("style", "display:none;");
            divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "2";
            txtCustCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        var ReportBy = ddlReportBy.SelectedValue;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

        if (String.IsNullOrEmpty(txtCustCode.Text) && ReportBy == "2")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }

        if (String.IsNullOrEmpty(txtSSDistCode.Text) && ReportBy == "4")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
           // exItemID = !String.IsNullOrEmpty(Item) ? ctx.OITMs.FirstOrDefault(x => x.ItemCode == Item).ItemID : 0;
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
        ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?MCClaimRegFromDate=" + txtFromDate.Text + "&MCClaimRegToDate=" + txtToDate.Text + "&MCClaimRegDealerID=" + DealerID + "&MCClaimRegDistributorID=" + DistributorID + "&MCClaimRegRegionID=" + RegionID + "&MCClaimRegSUserID=" + SUserID + "&MCClaimRegSSID=" + SSID + "&MCClaimRegReportBy=" + ReportBy+ "&CompCust=" + CustomerId);
    }
    protected void ifmMaterialPurchase_Load(object sender, EventArgs e)
    {

    }
}