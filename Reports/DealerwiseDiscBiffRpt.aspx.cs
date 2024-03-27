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

public partial class Reports_DealerwiseDiscBiffRpt : System.Web.UI.Page
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
        if (CustType == 1)
        {
            //NO ACTION
        }
        else
        {
            txtCustCode.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
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
        }
    }
    #endregion Page Load

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal Decnum;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

        Decimal DistID = CustType == 1 ? DistributorID : ParentID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmDealerwiseDiscBiff.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerWiseDiscBiffFromDate=" + txtFromDate.Text + "&DealerWiseDiscBiffToDate=" + txtToDate.Text + "&DealerWiseDiscBiffDistID=" + DistID + "&DealerWiseDiscBiffDealerID=" + DealerID + "&IsDetail=" + IsDetail + "&DealerWiseDiscBiffRegionID=" + RegionID + "&DealerWiseDiscBiffSSID=" + SSID + "&DealerWiseDiscBiffSUserID=" + SUserID + "&DealerWiseDiscBiffReportBy=" + ddlReportBy.SelectedValue);
    }

    protected void ifmDealerwiseDiscBiff_Load(object sender, EventArgs e)
    {

    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal Decnum;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

        Decimal DistID = CustType == 1 ? DistributorID : ParentID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmDealerwiseDiscBiff.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerWiseDiscBiffFromDate=" + txtFromDate.Text + "&DealerWiseDiscBiffToDate=" + txtToDate.Text + "&DealerWiseDiscBiffDistID=" + DistID + "&DealerWiseDiscBiffDealerID=" + DealerID + "&IsDetail=" + IsDetail + "&DealerWiseDiscBiffRegionID=" + RegionID + "&DealerWiseDiscBiffSSID=" + SSID + "&DealerWiseDiscBiffSUserID=" + SUserID + "&DealerWiseDiscBiffReportBy=" + ddlReportBy.SelectedValue + "&Export=1");
    }
}