﻿using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_BillPayment : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected decimal ParentCustID;
    protected String AuthType;
    DDMSEntities ctx;
    int ItemID;

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
            ParentCustID = Convert.ToDecimal(Session["OutletPID"]);

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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 1)
            {
                txtCustCode.Visible = true;
                ddlVendor.Visible = false;
                lblVendor.Text = "Customer";
            }
            else
            {
                txtCustCode.Visible = false;
                ddlVendor.Visible = true;
                lblVendor.Text = "Vendor";
            }

            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtName.ContextKey = (CustType + 1).ToString();

            ddlVendor.DataSource = ctx.OVNDs.Where(x => x.Active && (x.ParentID == ParentID || x.ParentID == ParentCustID)).Select(x => new { VendorID = SqlFunctions.StringConvert((double)x.VendorID) + "," + SqlFunctions.StringConvert(x.ParentID, 20), x.VendorName }).ToList();
            ddlVendor.DataBind();
            ddlVendor.Items.Insert(0, new ListItem("---Select---", "0"));

            ////txtFromDate.Focus();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }
    protected void ifmBillPayment_Load(object sender, EventArgs e)
    {

    }
    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
        decimal CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;
        ifmBillPayment.Attributes.Add("src", "../Reports/ViewReport.aspx?BillPymtFromDate=" + txtFromDate.Text + "&BillPymtToDate=" + txtToDate.Text + "&BillPymtVendorID=" + ddlVendor.SelectedValue + "&CompCust=" + CustomerID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
        decimal CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;
        ifmBillPayment.Attributes.Add("src", "../Reports/ViewReport.aspx?BillPymtFromDate=" + txtFromDate.Text + "&BillPymtToDate=" + txtToDate.Text + "&BillPymtVendorID=" + ddlVendor.SelectedValue + "&CompCust=" + CustomerID + "&Export=1");

    }


    #endregion

}