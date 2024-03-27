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

public partial class Reports_SalesVCPurchAmtCompareRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx = new DDMSEntities();

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
            divDistributor.Visible = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            divDistributor.Visible = false;
            divDistributor.Style.Add("Display", "none");
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
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }
    #endregion Page Load

    protected void ifmSalesVSPurchAmtCompare_Load(object sender, EventArgs e)
    {

    }
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal Decnum;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        if (DistributorID == 0 && DealerID == 0 && CustType == 1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }
        Decimal DistID = CustType == 1 ? DistributorID : ParentID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Decimal Distid = 0;
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
        }
        ifmSalesVSPurchAmtCompare.Attributes.Add("src", "../Reports/ViewReport.aspx?SalesVSPurchFromDate=" + txtFromDate.Text + "&SalesVSPurchToDate=" + txtToDate.Text + "&SalesVSPurchDistributorID=" + DistID + "&SalesVSPurchDealerID=" + DealerID + "&SalesVSPurchDivisionID=" + ddlDivision.SelectedValue + "&SalesVSPurchDiffBtwn=" + ddlDiffBtwn.SelectedValue + "&IsDetail=" + IsDetail + "&CompCust=" + Distid);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal Decnum;
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;
        Decimal DealerID = Decimal.TryParse(txtdealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        if (DistributorID == 0 && DealerID == 0 && CustType == 1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
            txtCustCode.Text = "";
            txtCustCode.Focus();
            return;
        }
        Decimal DistID = CustType == 1 ? DistributorID : ParentID;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Decimal Distid = 0;
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
        }
            ifmSalesVSPurchAmtCompare.Attributes.Add("src", "../Reports/ViewReport.aspx?SalesVSPurchFromDate=" + txtFromDate.Text + "&SalesVSPurchToDate=" + txtToDate.Text + "&SalesVSPurchDistributorID=" + DistID + "&SalesVSPurchDealerID=" + DealerID + "&SalesVSPurchDivisionID=" + ddlDivision.SelectedValue + "&SalesVSPurchDiffBtwn=" + ddlDiffBtwn.SelectedValue + "&IsDetail=" + IsDetail + "&Export=1&CompCust=" + Distid);
    }
}