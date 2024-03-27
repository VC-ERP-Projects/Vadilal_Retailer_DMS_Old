using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_MasterDiscListing : System.Web.UI.Page
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
        txtRegion.Text = "";
        txtDealerCode.Text = "";
        txtCustCode.Text = "";
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        lbldealer.Text = "Dealer/FOW";
        if (CustType == 1)
        {
            divDistributor.Visible = true;
            //acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            acetxtDealerCode.ServiceMethod = "GetDealerofDist";
            ClearAllInputs();
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
        }
    }
    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal DistID = 0;
        Decimal DealerID = 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        DistID = CustType == 1 ? (Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0) : ParentID;
        DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Decimal CompanyFrom = Decimal.TryParse(txtCpnyContriFrom.Value, out CompanyFrom) ? CompanyFrom : 0;
        Decimal CompanyTo = Decimal.TryParse(txtCpnyContriTo.Value, out CompanyTo) ? CompanyTo : 100;
        Decimal DistFrom = Decimal.TryParse(txtDistContriFrom.Value, out DistFrom) ? DistFrom : 0;
        Decimal DistTo = Decimal.TryParse(txtDistContriTo.Value, out DistTo) ? DistTo : 100;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        ifmDataReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&MasterDiscFromDate=" + txtFromDate.Text + "&MasterDiscToDate=" + txtToDate.Text
            + "&MasterDiscRegionID=" + RegionID + "&MasterDiscDistID=" + DistID + "&MasterDiscDealerID=" + DealerID
            + "&MasterDiscCmpnyFrom=" + CompanyFrom + "&MasterDiscCmpnyTo=" + CompanyTo + "&MasterDiscDistFrom=" + DistFrom + "&MasterDiscDistTo=" + DistTo
            + "&MasterDistStatus=" + ddlDistStatus.SelectedValue + "&MasterDiscDivision=" + ddlDivision.SelectedValue + "&MasterDiscReportFor=" + ddlReportFor.SelectedValue
            + "&MasterDistSUserID=" + SUserID + "&MDisSalesPeriod=" + ddlSalesPeriod.SelectedValue);
    }


    protected void ifmDataReq_Load(object sender, EventArgs e)
    {

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal DistID = 0;
        Decimal DealerID = 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        DistID = CustType == 1 ? (Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0) : ParentID;
        DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Decimal CompanyFrom = Decimal.TryParse(txtCpnyContriFrom.Value, out CompanyFrom) ? CompanyFrom : 0;
        Decimal CompanyTo = Decimal.TryParse(txtCpnyContriTo.Value, out CompanyTo) ? CompanyTo : 100;
        Decimal DistFrom = Decimal.TryParse(txtDistContriFrom.Value, out DistFrom) ? DistFrom : 0;
        Decimal DistTo = Decimal.TryParse(txtDistContriTo.Value, out DistTo) ? DistTo : 100;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        ifmDataReq.Attributes.Add("src", "../Reports/ViewReport.aspx?&MasterDiscFromDate=" + txtFromDate.Text + "&MasterDiscToDate=" + txtToDate.Text
            + "&MasterDiscRegionID=" + RegionID + "&MasterDiscDistID=" + DistID + "&MasterDiscDealerID=" + DealerID
            + "&MasterDiscCmpnyFrom=" + CompanyFrom + "&MasterDiscCmpnyTo=" + CompanyTo + "&MasterDiscDistFrom=" + DistFrom + "&MasterDiscDistTo=" + DistTo
            + "&MasterDistStatus=" + ddlDistStatus.SelectedValue + "&MasterDiscDivision=" + ddlDivision.SelectedValue + "&MasterDiscReportFor=" + ddlReportFor.SelectedValue
            + "&MasterDistSUserID=" + SUserID + "&Export=1&MDisSalesPeriod=" + ddlSalesPeriod.SelectedValue);
    }
}