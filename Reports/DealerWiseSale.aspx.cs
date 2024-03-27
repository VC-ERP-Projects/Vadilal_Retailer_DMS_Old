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

public partial class Reports_DealerWiseSale : System.Web.UI.Page
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
            txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
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
        Int32 ItemGrpID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).Last().Trim(), out ItemGrpID) ? ItemGrpID : 0;
        Int32 ItemSubGrpID = Int32.TryParse(txtSubGroup.Text.Split("-".ToArray()).Last().Trim(), out ItemSubGrpID) ? ItemSubGrpID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        var DealerIDs = (txtDealerCode.Text.Split("-".ToArray()).First().Trim() + ',' + hdnCustCode.Value).TrimEnd(",".ToArray()).TrimStart(",".ToArray());

        if (DealerIDs != "")
            ifmDealerSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerSaleFromDate=" + txtFromDate.Text + "&DelaerSaleToDate=" + txtToDate.Text + "&DealerSaleDivision=" + ddlDivision.SelectedValue + "&DealerSaleItemGrpID=" + ItemGrpID + "&DealerSaleItemSubGrpID=" + ItemSubGrpID + "&DealerSaleItemID=" + ItemID + "&DealerSaleReportoption=" + ddlReport.SelectedValue + "&DealerSaleDealerCode=" + DealerIDs);
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Upload Or Select Atleast one Dealer Code!',3);", true);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        Int32 ItemGrpID = Int32.TryParse(txtGroup.Text.Split("-".ToArray()).Last().Trim(), out ItemGrpID) ? ItemGrpID : 0;
        Int32 ItemSubGrpID = Int32.TryParse(txtSubGroup.Text.Split("-".ToArray()).Last().Trim(), out ItemSubGrpID) ? ItemSubGrpID : 0;
        Int32 ItemID = Int32.TryParse(txtItem.Text.Split("-".ToArray()).Last().Trim(), out ItemID) ? ItemID : 0;
        var DealerIDs = (txtDealerCode.Text.Split("-".ToArray()).First().Trim() + ',' + hdnCustCode.Value).TrimEnd(",".ToArray()).TrimStart(",".ToArray());

        if (DealerIDs != "")
            ifmDealerSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerSaleFromDate=" + txtFromDate.Text + "&DelaerSaleToDate=" + txtToDate.Text + "&DealerSaleDivision=" + ddlDivision.SelectedValue + "&DealerSaleItemGrpID=" + ItemGrpID + "&DealerSaleItemSubGrpID=" + ItemSubGrpID + "&DealerSaleItemID=" + ItemID + "&DealerSaleReportoption=" + ddlReport.SelectedValue + "&DealerSaleDealerCode=" + DealerIDs + "&Export=1");
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Upload Or Select Atleast one Dealer Code!',3);", true);
    }

    protected void ifmDealerSale_Load(object sender, EventArgs e)
    {

    }
    #endregion

}