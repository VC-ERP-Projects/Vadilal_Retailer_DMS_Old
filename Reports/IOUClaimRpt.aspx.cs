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

public partial class Reports_IOUClaimRpt : System.Web.UI.Page
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
            txtCustCode.Enabled = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        acetxtName.ContextKey = (CustType + 1).ToString();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    protected void ifmIOUClaim_Load(object sender, EventArgs e)
    {

    }
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal DistributorID = 0;
        if (String.IsNullOrEmpty(txtCustCode.Text) && CustType == 1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }
        else
        {
            DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            if (DistributorID == 0 && CustType == 1)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                return;
            }
        }

        if (String.IsNullOrEmpty(txtDate.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
            txtDate.Text = "";
            txtDate.Focus();
            return;
        }

        DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
        string Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month)).ToShortDateString();
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;

        ifmIOUClaim.Attributes.Add("src", "../Reports/ViewReport.aspx?IOUClaimFromDate=" + Fromdate.ToShortDateString() + "&IOUClaimToDate=" + Todate + "&IOUClaimDist=" + DistributorID + "&IOUClaimSUserID=" + SUserID + "&IOUClaimRegionID=" + RegionID);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal DistributorID = 0;
        if (String.IsNullOrEmpty(txtCustCode.Text) && CustType == 1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }
        else
        {
            DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            if (DistributorID == 0 && CustType == 1)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                return;
            }
        }

        if (String.IsNullOrEmpty(txtDate.Text))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
            txtDate.Text = "";
            txtDate.Focus();
            return;
        }

        DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
        string Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month)).ToShortDateString();
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;

        ifmIOUClaim.Attributes.Add("src", "../Reports/ViewReport.aspx?IOUClaimFromDate=" + Fromdate.ToShortDateString() + "&IOUClaimToDate=" + Todate + "&IOUClaimDist=" + DistributorID + "&IOUClaimSUserID=" + SUserID + "&IOUClaimRegionID=" + RegionID + "&Export=1");
    }
}