using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_TotalSalesSummary : System.Web.UI.Page
{
    #region Declaration
    protected int UserID, CustType;
    protected decimal ParentID;
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


    #endregion

    #region Pageload

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 4) // SS
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divDealer.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
                }
            }
            else if (CustType == 2) // Distributor
            {
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
                ddlItemGroup.DataBind();
                ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));

                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            }
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            txtItemName.Style.Add("background-color", "rgb(250, 255, 189);");
        }
    }

    protected void ifmTotalSalesSummary_Load(object sender, EventArgs e)
    {

    }

    #endregion

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (DistributorID == 0 && DealerID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        var Item = txtItemName.Text.Split("-".ToArray()).First().Trim();
        decimal exItemID = 0;
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            exItemID = !String.IsNullOrEmpty(Item) ? ctx.OITMs.FirstOrDefault(x => x.ItemCode == Item).ItemID : 0;
            if (DistributorID == 0 && DealerID > 0)
            {
                Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
            }
            else if (DistributorID > 0)
            {
                Distid = DistributorID;
            }
            if (SSID == 0 && DistributorID > 0)
            {
                SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistributorID).ParentID;
            }
            else if (SSID > 0)
            {
                SSSID = SSID;
            }
        }
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        string Group = chkGroup.Checked ? "1" : "0";
        string Detail = chkIsMaterial.Checked ? "1" : "0";
        string Date = ChkIsDate.Checked ? "1" : "0";
        
        ifmTotalSalesSummary.Attributes.Add("src", "../Reports/ViewReport.aspx?TotalSaleSummaryFromDate=" + txtFromDate.Text + "&TotalSaleSummaryToDate=" + txtToDate.Text + "&TotalSaleItem=" + exItemID + "&TotSaleCustomerID=" + DealerID + "&TotSaleItemGroup=" + ddlItemGroup.SelectedValue + "&TotalSaleIsGroup=" + Group + "&TotalSaleIsDate=" + Date + "&TotalSaleSummaryIsMaterial=" + Detail + "&TotSaleDistributorID=" + DistributorID + "&TotSaleSSID=" + SSID + "&TotSaleSaleBy=" + ddlSaleBy.SelectedValue + "&TotSaleSUserID=" + SUserID + "&DivisionID=" + ddlDivision.SelectedValue + "&CompCust=" + CustomerId);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (DistributorID == 0 && DealerID == 0 && SSID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }
        var Item = txtItemName.Text.Split("-".ToArray()).First().Trim();
        decimal exItemID = 0;
        Decimal Distid = 0, SSSID = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            exItemID = !String.IsNullOrEmpty(Item) ? ctx.OITMs.FirstOrDefault(x => x.ItemCode == Item).ItemID : 0;
            if (DistributorID == 0 && DealerID > 0)
            {
                Distid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DealerID).ParentID;
            }
            else if (DistributorID > 0)
            {
                Distid = DistributorID;
            }
            if (SSID == 0 && DistributorID > 0)
            {
                SSSID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == DistributorID).ParentID;
            }
            else if (SSID > 0)
            {
                SSSID = SSID;
            }
        }
        string Group = chkGroup.Checked ? "1" : "0";
        string Detail = chkIsMaterial.Checked ? "1" : "0";
        string Date = ChkIsDate.Checked ? "1" : "0";
        Decimal CustomerId = Distid > 0 ? Distid : SSSID;
        ifmTotalSalesSummary.Attributes.Add("src", "../Reports/ViewReport.aspx?TotalSaleSummaryFromDate=" + txtFromDate.Text + "&TotalSaleSummaryToDate=" + txtToDate.Text + "&TotalSaleItem=" + exItemID + "&TotSaleCustomerID=" + DealerID + "&TotSaleItemGroup=" + ddlItemGroup.SelectedValue + "&TotalSaleIsGroup=" + Group + "&TotalSaleIsDate=" + Date + "&TotalSaleSummaryIsMaterial=" + Detail + "&TotSaleDistributorID=" + DistributorID + "&TotSaleSSID=" + SSID + "&TotSaleSaleBy=" + ddlSaleBy.SelectedValue + "&DivisionID=" + ddlDivision.SelectedValue + "&TotSaleSUserID=" + SUserID + "&Export=1&CompCust=" + CustomerId);
    }

    #endregion

    #region Change Event
    protected void ddlDivision_SelectedIndexChanged(object sender, EventArgs e)
    {
        Int32 divisionID = (Int32.TryParse(ddlDivision.SelectedValue, out divisionID)) ? divisionID : 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (divisionID > 0)
            {
                var itemGroupList = (from a in ctx.OITBs
                                     join b in ctx.OITMs on a.ItemGroupID equals b.GroupID
                                     join c in ctx.OGITMs on b.ItemID equals c.ItemID
                                     where c.DivisionlID == divisionID
                                     orderby a.SortOrder
                                     select new
                                     {
                                         a.ItemGroupID,
                                         a.ItemGroupName
                                     }
                                  ).ToList().Distinct();
                ddlItemGroup.DataSource = itemGroupList;
            }
            else
            {
                ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
            }
        }
        ddlItemGroup.DataBind();
        ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        txtItemName.Text = String.Empty;
        ddlDivision.Focus();
    }
    #endregion
}