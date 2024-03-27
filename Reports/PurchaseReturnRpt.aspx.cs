using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PurchaseReturn : System.Web.UI.Page
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


    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 1)
                divCustomer.Visible = true;
            else
                divCustomer.Visible = false;

            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtItemName.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtName.ContextKey = (CustType + 1).ToString();

            ddlItemGroup.DataSource = ctx.OITBs.OrderBy(x => x.SortOrder).ToList();
            ddlItemGroup.DataBind();
            ddlItemGroup.Items.Insert(0, new ListItem("---Select---", "0"));

            ddlReason.DataSource = ctx.ORSNs.Where(x => x.Type == "P").OrderBy(x => x.ReasonID).ToList();
            ddlReason.DataBind();
            ddlReason.Items.Insert(0, new ListItem("---Select---", "0"));

            //ddlType.DataSource = EnumList.Of<ReturnType1>().ToList();
            //ddlType.DataBind();

            ////txtFromDate.Focus();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }

    protected void ifmPurchaseReturn_Load(object sender, EventArgs e)
    {

    }
    #endregion

    #region ButtonClick
    protected void btnGenerat_Click(object sender, EventArgs e)
    {

        var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
        decimal CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;

        string Item = txtItemName.Text.Split("-".ToArray()).First().Trim();
        int exItemID = 0;
        if (!String.IsNullOrEmpty(Item) && ctx.OITMs.Any(x => x.ItemCode == Item))
        {
            exItemID = ctx.OITMs.FirstOrDefault(x => x.ItemCode == Item).ItemID;
        }

        
        ifmPurchaseReturn.Attributes.Add("src", "../Reports/ViewReport.aspx?PRFromDate=" + txtFromDate.Text + "&PRToDate=" + txtToDate.Text + "&PRIGID=" + ddlItemGroup.SelectedValue + "&PRType=" + ddlType.SelectedValue + "&CompCust=" + CustomerID + "&PRItem=" + exItemID + "&PRReasonID=" + ddlReason.SelectedValue+ "&CompCust=" + CustomerID);
    }



    protected void btnExport_Click(object sender, EventArgs e)
    {
        var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
        decimal CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;

        string Item = txtItemName.Text.Split("-".ToArray()).First().Trim();
        int exItemID = 0;
        if (!String.IsNullOrEmpty(Item) && ctx.OITMs.Any(x => x.ItemCode == Item))
        {
            exItemID = ctx.OITMs.FirstOrDefault(x => x.ItemCode == Item).ItemID;
        }

        ifmPurchaseReturn.Attributes.Add("src", "../Reports/ViewReport.aspx?PRFromDate=" + txtFromDate.Text + "&PRToDate=" + txtToDate.Text + "&PRIGID=" + ddlItemGroup.SelectedValue + "&CompCust=" + CustomerID + "&PRType=" + ddlType.SelectedValue + "&PRItem=" + exItemID + "&PRReasonID=" + ddlReason.SelectedValue + "&Export=1&CompCust=" + CustomerID);
    }
    #endregion
}