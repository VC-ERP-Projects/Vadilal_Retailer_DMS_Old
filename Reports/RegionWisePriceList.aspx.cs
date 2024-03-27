using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Reports_RegionWisePriceList : System.Web.UI.Page
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
        txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");

        using (DDMSEntities ctx = new DDMSEntities())
        {
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
        }
    }

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal CustomerID = 0;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        if (ddlPriceList.SelectedValue == "3")
            CustomerID = DistributorID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        ifmRegionWisePriceList.Attributes.Add("src", "../Reports/ViewReport.aspx?RegionWiseDistributorID=" + CustomerID + "&RegionWiseDivisionID=" + ddlDivision.SelectedValue + "&RegionWisePriceType=" + ddlPriceList.SelectedValue + "&RegionWiseRegionID=" + RegionID + "&IsDetail=" + IsDetail + "&RegionWiseDealerType=" + ddlDealerType.SelectedValue + "&RegionWiseSUserID=" + SUserID);

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal CustomerID = 0;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        if (ddlPriceList.SelectedValue == "3")
            CustomerID = DistributorID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        ifmRegionWisePriceList.Attributes.Add("src", "../Reports/ViewReport.aspx?RegionWiseDistributorID=" + CustomerID + "&RegionWiseDivisionID=" + ddlDivision.SelectedValue + "&RegionWisePriceType=" + ddlPriceList.SelectedValue + "&RegionWiseRegionID=" + RegionID + "&IsDetail=" + IsDetail + "&RegionWiseDealerType=" + ddlDealerType.SelectedValue + "&RegionWiseSUserID=" + SUserID + "&Export=1");

    }
    protected void ifmRegionWisePriceList_Load(object sender, EventArgs e)
    {

    }
}