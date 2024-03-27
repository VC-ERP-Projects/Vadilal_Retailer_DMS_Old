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
        ddlClaimStatus.SelectedValue = "0";
        ddlMode.SelectedIndex = 0;

        if (CustType == 4) // SS
        {
            divDealer.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "4";
            txtSSCode.Enabled = ddlSaleBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)
        {
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                //ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID,x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                ddlMode.DataBind();
            }
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);

        if (String.IsNullOrEmpty(txtDate.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Date.',3);", true);
            txtDate.Text = "";
            txtDate.Focus();
            return;
        }

        Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

        if (ddlSaleBy.SelectedValue == "4" && DistID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
            return;
        }
        else if (ddlSaleBy.SelectedValue == "2" && DistID == 0 && DealerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one Dist / Dealer.',3);", true);
            return;
        }
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }

        //Decimal PID = ddlSaleBy.SelectedValue == "4" ? SSID : DistID;
        //Decimal CustomerID = ddlSaleBy.SelectedValue == "4" ? DistID : DealerID;

        DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
        string Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month)).ToShortDateString();

        var ItemDetail = chkItemDetail.Checked ? "1" : "0";

        string ipvalue = (string.IsNullOrEmpty(IPAdd) ? "" : " / " + IPAdd);
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ddlSaleBy.SelectedValue == "2")
            {
                if (DistID == 0 && DealerID > 0)
                {
                    Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
                }
                else if (DistID > 0)
                {
                    Distid = DistID;
                }
            }
            else
            {
                if (SSID == 0 && DistID > 0)
                {
                    SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistID).ParentID;
                }
                else if (SSID > 0)
                {
                    SSSID = SSID;
                }
            }
        }
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimRegFromDate=" + Fromdate.ToShortDateString() + "&ClaimRegToDate=" + Todate + "&ClaimRegClaimStatus=" + ddlClaimStatus.SelectedValue + "&ClaimRegDealerID=" + DealerID + "&ClaimRegDistID=" + DistID + "&ClaimRegSSID=" + SSID + "&ClaimItemDetail=" + ItemDetail + "&Stype=" + ddlMode.SelectedValue + "&ReportBy=" + ddlSaleBy.SelectedValue + "&SUserID=" + SUserID + "&IpAddress=" + ipvalue+ "&CompCust=" + CustomerId);
    }
    protected void ifmMaterialPurchase_Load(object sender, EventArgs e)
    {

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);
        if (String.IsNullOrEmpty(txtDate.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Date.',3);", true);
            txtDate.Text = "";
            txtDate.Focus();
            return;
        }

        Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

        if (ddlSaleBy.SelectedValue == "4" && DistID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
            return;
        }
        else if (ddlSaleBy.SelectedValue == "2" && DistID == 0 && DealerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one Dist / Dealer.',3);", true);
            return;
        }
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }

        DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
        string Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month)).ToShortDateString();
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ddlSaleBy.SelectedValue == "2")
            {
                if (DistID == 0 && DealerID > 0)
                {
                    Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
                }
                else if (DistID > 0)
                {
                    Distid = DistID;
                }
            }
            else
            {
                if (SSID == 0 && DistID > 0)
                {
                    SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistID).ParentID;
                }
                else if (SSID > 0)
                {
                    SSSID = SSID;
                }
            }
        }
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        var ItemDetail = chkItemDetail.Checked ? "1" : "0";
        string ipvalue = (string.IsNullOrEmpty(IPAdd) ? "" : " / " + IPAdd);
        ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimRegFromDate=" + Fromdate.ToShortDateString() + "&ClaimRegToDate=" + Todate + "&ClaimRegClaimStatus=" + ddlClaimStatus.SelectedValue + "&ClaimRegDealerID=" + DealerID + "&ClaimRegDistID=" + DistID + "&ClaimRegSSID=" + SSID + "&ClaimItemDetail=" + ItemDetail + "&Stype=" + ddlMode.SelectedValue + "&ReportBy=" + ddlSaleBy.SelectedValue + "&SUserID=" + SUserID + "&IpAddress=" + ipvalue + "&Export=1&CompCust=" + CustomerId);
    }

}