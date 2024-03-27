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

public partial class Reports_ItemWiseInvoicePurchaseRpt : System.Web.UI.Page
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

        using (DDMSEntities ctx = new DDMSEntities())
        {

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

            if (CustType == 4)
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divDistributor.Attributes.Add("style", "display:none;");
                ddlPurchaseBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlPurchaseBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
            else if (CustType == 2)
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                ddlPurchaseBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlPurchaseBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
        }
    }
    #endregion Page Load

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (CustType == 4)
        {
            SSID = ParentID;
        }
        else if (CustType == 2)
        {
            DistributorID = ParentID;
            SSID = 0;
        }

        if (DistributorID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        Decimal CustomerId = DistributorID > 0 ? DistributorID : SSID;
        ifmItemWiseInvoicePurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?ItmWiseIvnPurchaseFromDate=" + txtFromDate.Text + "&ItmWiseIvnPurchaseToDate=" + txtToDate.Text +
           "&IvnPurchaseBy=" + ddlPurchaseBy.SelectedValue + "&IvnSSID=" + SSID + "&IvnDistributorID=" + DistributorID + "&IvnDivisionID=" + ddlDivision.SelectedValue + "&IvnDateOption=" +
           ddlDateOption.SelectedValue + "&IvnItemID=" + ItemID + "&IsDetail=" + IsDetail + "&IvnSUserID=" + SUserID + "&CompCust=" + CustomerId);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (CustType == 4)
        {
            SSID = ParentID;
        }
        else if (CustType == 2)
        {
            DistributorID = ParentID;
            SSID = 0;
        }

        if (DistributorID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        Decimal CustomerId = DistributorID > 0 ? DistributorID : SSID;
        ifmItemWiseInvoicePurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?ItmWiseIvnPurchaseFromDate=" + txtFromDate.Text + "&ItmWiseIvnPurchaseToDate=" + txtToDate.Text +
           "&IvnPurchaseBy=" + ddlPurchaseBy.SelectedValue + "&IvnSSID=" + SSID + "&IvnDistributorID=" + DistributorID + "&IvnDivisionID=" + ddlDivision.SelectedValue + "&IvnDateOption=" +
           ddlDateOption.SelectedValue + "&IvnItemID=" + ItemID + "&IsDetail=" + IsDetail + "&IvnSUserID=" + SUserID + "&Export=1&CompCust=" + CustomerId);
    }

    protected void ifmItemWiseInvoicePurchase_Load(object sender, EventArgs e)
    {

    }
}