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

public partial class Reports_StockUpdate : System.Web.UI.Page
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

    private void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (CustType == 2)
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                ddlReportBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlReportBy.Enabled = false;

                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
            else if (CustType == 4)
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divDistributor.Attributes.Add("style", "display:none;");
                ddlReportBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlReportBy.Enabled = false;

                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }

            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivision.DataSource = Division;
            ddlDivision.DataBind();
            ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
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

    #region ButtonEvents

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime ToDte, FromDte;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if ((ddlReportBy.SelectedValue == "2" && DistributorID == 0) || (ddlReportBy.SelectedValue == "4" && SSID == 0))
        {
            if (ddlReportBy.SelectedValue == "2")
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Distributor.',3);", true);
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select SuperStockist.',3);", true);
            return;
        }
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text) && DateTime.TryParse(txtFromDate.Text, out FromDte) && DateTime.TryParse(txtToDate.Text, out ToDte))
        {
            if (FromDte <= ToDte)
                ifmStockUpdate.Attributes.Add("src", "../Reports/ViewReport.aspx?StockUpdateFromDate=" + txtFromDate.Text + "&StockUpdateToDate=" + txtToDate.Text
                    + "&StockUpdateSS=" + SSID + "&StockUpdateDistributor=" + DistributorID + "&StockUpdateDivisionID=" + ddlDivision.SelectedValue + "&StockUpdateItemID="
                    + ItemID + "&StockUpdateReportOption=" + ddlReport.SelectedValue + "&StockUpdateSUserID=" + SUserID + "&StockUpdateRptBy=" + ddlReportBy.SelectedValue);
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FromDate cannot be greater than ToDate.',3);", true);
                return;
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper From / To Date.',3);", true);
            return;
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        DateTime ToDte, FromDte;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if ((ddlReportBy.SelectedValue == "2" && DistributorID == 0) || (ddlReportBy.SelectedValue == "4" && SSID == 0))
        {
            if (ddlReportBy.SelectedValue == "2")
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Distributor.',3);", true);
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select SuperStockist.',3);", true);
            return;
        }
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text) && DateTime.TryParse(txtFromDate.Text, out FromDte) && DateTime.TryParse(txtToDate.Text, out ToDte))
        {
            if (FromDte <= ToDte)
                ifmStockUpdate.Attributes.Add("src", "../Reports/ViewReport.aspx?StockUpdateFromDate=" + txtFromDate.Text + "&StockUpdateToDate=" + txtToDate.Text
                    + "&StockUpdateSS=" + SSID + "&StockUpdateDistributor=" + DistributorID + "&StockUpdateDivisionID=" + ddlDivision.SelectedValue + "&StockUpdateItemID="
                    + ItemID + "&StockUpdateReportOption=" + ddlReport.SelectedValue + "&StockUpdateSUserID=" + SUserID + "&StockUpdateRptBy=" + ddlReportBy.SelectedValue + "&Export=1");
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FromDate cannot be greater than ToDate.',3);", true);
                return;
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper From / To Date.',3);", true);
            return;
        }
    }

    protected void ifmStockUpdate_Load(object sender, EventArgs e)
    {

    }

    #endregion

}