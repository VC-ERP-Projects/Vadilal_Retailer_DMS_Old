using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_ClaimBalanceDetailRpt : System.Web.UI.Page
{

    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    private void ClearAllInputs()
    {
        txtDistCode.Text = "";
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);

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

    #endregion

    protected void ifmClaimBalDetail_Load(object sender, EventArgs e)
    {

    }

    #region Button Click Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Int32 RptFor = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out RptFor) ? RptFor : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Int32 SUserID = Int32.TryParse(txtEmployeeCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        Decimal DistID = 0;

        if (!string.IsNullOrEmpty(ddlOption.SelectedValue))
        {
            Int32 SelectedValue = Int32.TryParse(ddlOption.SelectedValue, out SelectedValue) ? SelectedValue : 0;

            if (SelectedValue == 2)
            {
                DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            }
            else
            {
                DistID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            }
        }

        ifmClaimBalDetail.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimBalDetailFromDate=" + txtFromDate.Text + "&ClaimBalDetailToDate= " + txtToDate.Text +
            "&ClaimBalDetailReportType=" + ddlReportType.SelectedValue + "&ClaimBalDetailDistID=" + DistID +
            "&ClaimBalDetailCustType=" + ddlOption.SelectedValue + "&ClaimBalDetailEmpID=" + RptFor + "&ClaimBalDetailSUserID=" + SUserID + "&ClaimBalDetailRegionID=" + RegionID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 RptFor = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out RptFor) ? RptFor : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Int32 SUserID = Int32.TryParse(txtEmployeeCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        Decimal DistID = 0;

        if (!string.IsNullOrEmpty(ddlOption.SelectedValue))
        {
            Int32 SelectedValue = Int32.TryParse(ddlOption.SelectedValue, out SelectedValue) ? SelectedValue : 0;

            if (SelectedValue == 2)
            {
                DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            }
            else
            {
                DistID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            }
        }

        ifmClaimBalDetail.Attributes.Add("src", "../Reports/ViewReport.aspx?ClaimBalDetailFromDate=" + txtFromDate.Text + "&ClaimBalDetailToDate= " + txtToDate.Text +
            "&ClaimBalDetailReportType=" + ddlReportType.SelectedValue + "&ClaimBalDetailDistID=" + DistID +
            "&ClaimBalDetailCustType=" + ddlOption.SelectedValue + "&ClaimBalDetailEmpID=" + RptFor + "&ClaimBalDetailSUserID=" + SUserID + "&ClaimBalDetailRegionID=" + RegionID + "&Export=1");
    }

    #endregion
}