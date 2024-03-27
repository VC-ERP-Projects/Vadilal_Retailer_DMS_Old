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

public partial class Reports_AsOnClaimStatus : System.Web.UI.Page
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

        if (CustType == 1)
        {
            divDistributor.Visible = true;
            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
        }
        txtAsOnDate.Text = Common.DateTimeConvert(DateTime.Now);
    }

    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            if (CustType == 4)
            {
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                txtSSDistCode.Enabled = false;
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
                txtCustCode.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataBind();
                ddlMode.Items.Insert(0, new ListItem("---Select Claim Type---", "0"));
            }
        }
    }

    #endregion

    #region Render
    protected void ifmAsonClaimStatus_Load(object sender, EventArgs e)
    {

    }
    #endregion

    #region ButtonClick
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        if (String.IsNullOrEmpty(txtFromMonth.Text) || String.IsNullOrEmpty(txtToMonth.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Claim From & To Month.',3);", true);
            return;
        }
        DateTime Fromdate = Convert.ToDateTime(txtFromMonth.Text);
        DateTime Todate = Convert.ToDateTime(txtToMonth.Text);
        DateTime ASOnDate = Convert.ToDateTime(txtAsOnDate.Text);
        DateTime Todate1 = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));
        if (Fromdate > ASOnDate || Todate1 > ASOnDate)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim From month and To month is not more than AsOn Date.',3);", true);
            return;
        }
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }

        ifmAsonClaimStatus.Attributes.Add("src", "../Reports/ViewReport.aspx?ASClaimType=" + ddlMode.SelectedValue + "&ASClaimRegionID=" + RegionID + "&ASClaimSSID=" + SSID + "&ASClaimDistributorID=" + DistributorID + "&ASCLaimFrom=" + Fromdate.ToShortDateString() + "&ASCLaimTo=" + Todate1.ToShortDateString() + "&ASCLaimReportType=" + ddldrp.SelectedValue + "&ASOnDate=" + ASOnDate.ToShortDateString() + "&AsOnSUserID=" + SUserID);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (String.IsNullOrEmpty(txtFromMonth.Text) || String.IsNullOrEmpty(txtToMonth.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Claim From & To Month.',3);", true);
            return;
        }
        DateTime Fromdate = Convert.ToDateTime(txtFromMonth.Text);
        DateTime Todate = Convert.ToDateTime(txtToMonth.Text);
        DateTime ASOnDate = Convert.ToDateTime(txtAsOnDate.Text);
        DateTime Todate1 = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));
        if (Fromdate > ASOnDate || Todate1 > ASOnDate)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim From month and To month is not more than AsOn Date.',3);", true);
            return;
        }
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }

        ifmAsonClaimStatus.Attributes.Add("src", "../Reports/ViewReport.aspx?ASClaimType=" + ddlMode.SelectedValue + "&ASClaimRegionID=" + RegionID + "&ASClaimSSID=" + SSID + "&ASClaimDistributorID=" + DistributorID + "&ASCLaimFrom=" + Fromdate.ToShortDateString() + "&ASCLaimTo=" + Todate1.ToShortDateString() + "&ASCLaimReportType=" + ddldrp.SelectedValue + "&ASOnDate=" + ASOnDate.ToShortDateString() + "&AsOnSUserID=" + SUserID + "&Export=1");
    }

    #endregion
}