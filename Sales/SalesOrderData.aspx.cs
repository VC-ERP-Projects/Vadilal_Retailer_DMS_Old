﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_SalesOrderData : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID, CustomerID;
    Decimal DefaultPageSize = 50;
    int ViewPageNumber = 10;

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

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtName.ContextKey = (CustType + 1).ToString();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }

    #endregion

    #region ButtonClick

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid(1, "");

        if (drpOrderType.SelectedValue == "11" || drpOrderType.SelectedValue == "15")
        {
            btnCancel.Attributes.Add("Style", "display:inline-block");
        }
        else
        {
            btnCancel.Attributes.Add("Style", "display:none");
            for (int i = 0; i < gvOrder.Rows.Count; i++)
            {
                Label lbl = (Label)gvOrder.Rows[i].FindControl("lblInvNo");
                LinkButton lnk = (LinkButton)gvOrder.Rows[i].FindControl("lnkInvNo");
                lbl.Visible = true;
                lnk.Visible = false;
            }
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (drpOrderType.SelectedValue == "15")//OPen SO of Ss's Dist
                {
                    foreach (GridViewRow row in gvOrder.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)row.FindControl("chkCheck");
                        if (chkCheck.Checked)
                        {
                            Label lblOrderID = (Label)row.FindControl("lblOrderID");
                            int OrderID = Int32.TryParse(lblOrderID.Text, out OrderID) ? OrderID : 0;
                            OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == OrderID && x.VendorParentID == ParentID && x.Status == "O" && x.InwardType == 1);
                            if (objOMID == null)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper order in checked row.', 3);", true);
                                return;
                            }
                            objOMID.InwardType = 5;
                            objOMID.UpdatedDate = DateTime.Now;
                            objOMID.UpdatedBy = UserID;

                            string body = "Purchase Order Cancelled of " + objOMID.OCRD.CustomerCode + " # " + objOMID.OCRD.CustomerName + " Total : " + objOMID.Total.Value.ToString("0.00") + " By Super Stockiest";
                            string title = "Purchase Order Cancelled # " + objOMID.InvoiceNumber;

                            OGCM objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == objOMID.OCRD.CustomerID && x.IsActive);
                            if (objOGCM != null)
                            {
                                GCM1 objGCM1 = new GCM1();
                                //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", objOGCM.ParentID, 0).FirstOrDefault().Value;
                                objGCM1.ParentID = objOGCM.ParentID;
                                objGCM1.DeviceID = 1;
                                objGCM1.CreatedDate = DateTime.Now;
                                objGCM1.CreatedBy = 1;
                                objGCM1.Body = body;
                                objGCM1.Title = title;
                                objGCM1.UnRead = true;
                                objGCM1.IsDeleted = false;
                                objGCM1.SentOn = false;
                                ctx.GCM1.Add(objGCM1);
                            }
                        }
                    }
                }
                if (drpOrderType.SelectedValue == "11")
                {
                    foreach (GridViewRow row in gvOrder.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)row.FindControl("chkCheck");
                        if (chkCheck.Checked)
                        {
                            Label lblOrderID = (Label)row.FindControl("lblOrderID");
                            int OrderID = Int32.TryParse(lblOrderID.Text, out OrderID) ? OrderID : 0;
                            ORDR objORDR = ctx.ORDRs.FirstOrDefault(x => x.OrderID == OrderID && x.ParentID == ParentID && x.OrderType == 11);
                            if (objORDR == null)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper order in checked row.', 3);", true);
                                return;
                            }
                            objORDR.OrderType = (int)SaleOrderType.Cancel;
                            objORDR.UpdatedDate = DateTime.Now;
                            objORDR.UpdatedBy = UserID;
                            objORDR.CancelDate = DateTime.Now;
                            objORDR.CancelBy = UserID;
                            objORDR.CancelFlag = (CustType == 1 && UserID == 1) ? CancelFlag.COMP.ToString() : (CustType == 1 && UserID > 1) ? CancelFlag.EMP.ToString() : CustType == 2 ? CancelFlag.DIST.ToString() : "";

                            string body = "Order Cancelled of " + objORDR.OCRD.CustomerCode + " # " + objORDR.OCRD.CustomerName + " Total : " + objORDR.Total.ToString("0.00") + " By Distributor";
                            string title = "Order Cancelled # " + objORDR.InvoiceNumber;

                            Thread t = new Thread(() => { Service.SendNotificationFlow(9104, objORDR.CreatedBy, 1000010000000000, body, title, objORDR.ParentID); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Order Cancelled.',1);", true);
                BindGrid(1, "");
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region GridEvent

    protected void Page_Changed(object sender, EventArgs e)
    {
        int pageIndex = int.Parse(((LinkButton)sender).CommandArgument);
        string pageName = ((LinkButton)sender).CommandName;
        BindGrid(pageIndex, pageName);
    }

    private void PopulatePager(Decimal recordCount, int currentPage, string pageName)
    {
        double dblPageCount = Convert.ToDouble((recordCount / DefaultPageSize));
        int pageCount = Convert.ToInt32(Math.Ceiling(dblPageCount));
        List<ListItem> pages = new List<ListItem>();
        if (pageCount > 0)
        {
            pages.Add(new ListItem("First", "1", (currentPage > 1)));

            int i = 1;

            if (pageName.ToString().ToLower().Contains("last"))
            {
                i = Convert.ToInt32((Math.Floor(Convert.ToDouble(pageCount / ViewPageNumber)) * ViewPageNumber) + 1);
            }
            else if (pageName.ToString().ToLower().Contains("first"))
            {
                i = 1;
            }
            else if (pageName.ToString().ToLower().Contains("..."))
            {
                i = currentPage;
            }
            else if (pageName.ToString().ToLower().Contains(".."))
            {
                i = currentPage - 9;
            }
            else
            {
                for (int Temp = 0; Temp <= rptPager.Items.Count - 1; Temp++)
                {
                    LinkButton lknPage = new LinkButton();
                    lknPage = (LinkButton)rptPager.Items[Temp].FindControl("lknPage");
                    if (lknPage.CommandName.ToString().ToLower() == "..")
                    {
                        lknPage = (LinkButton)rptPager.Items[Temp + 1].FindControl("lknPage");
                        i = (Convert.ToInt32(lknPage.CommandArgument.ToString()));
                        break; // TODO: might not be correct. Was : Exit For
                    }
                }
            }

            int x = i + ViewPageNumber;
            int z = i;

            while (i <= pageCount & i <= x)
            {
                if (i > 0)
                {
                    //'i = 1
                    if (x == i)
                    {
                        pages.Add(new ListItem("...", i.ToString(), (i != currentPage)));
                    }
                    else if (z == i & i > 1)
                    {
                        pages.Add(new ListItem("..", (i - 1).ToString(), (i != currentPage)));
                        pages.Add(new ListItem(i.ToString(), i.ToString(), (i != currentPage)));
                    }
                    else
                    {
                        pages.Add(new ListItem(i.ToString(), i.ToString(), (i != currentPage)));
                    }
                }
                i = i + 1;
            }
            pages.Add(new ListItem("Last", pageCount.ToString(), (currentPage < pageCount)));
        }
        rptPager.DataSource = pages;
        rptPager.DataBind();

        for (int Temp = 0; Temp <= rptPager.Items.Count - 1; Temp++)
        {
            LinkButton lknPage = new LinkButton();
            lknPage = (LinkButton)rptPager.Items[Temp].FindControl("lknPage");
            if (lknPage.CommandArgument.ToString().ToLower() == currentPage.ToString().ToLower() & !lknPage.CommandName.ToString().ToLower().Contains(".."))
            {
                lknPage.Attributes.Add("class", "numericLink active");
            }
            else
            {
                lknPage.Attributes.Add("class", "numericLink");
            }
        }
    }

    private void BindGrid(int pageIndex, string pageName)
    {
        try
        {

            DateTime start = Convert.ToDateTime(txtFromDate.Text);
            DateTime end = Convert.ToDateTime(txtToDate.Text);

            Decimal CustomerID = 0;
            if (!String.IsNullOrEmpty(txtCustCode.Text))
                CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;

            int SaleID = 0;
            if (!String.IsNullOrEmpty(txtDocNo.Text))
                SaleID = Int32.TryParse(txtDocNo.Text.Split("-".ToArray()).First().Trim(), out SaleID) ? SaleID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "Loadopenorders";

            Cm.Parameters.AddWithValue("@SDate", start);
            Cm.Parameters.AddWithValue("@EDate", end);
            Cm.Parameters.AddWithValue("@PageIndex", pageIndex);
            Cm.Parameters.AddWithValue("@PageSize", DefaultPageSize);
            Cm.Parameters.AddWithValue("@InvNo", SaleID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
            Cm.Parameters.AddWithValue("@Type", drpOrderType.SelectedValue);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            if (ds.Tables[0].Rows.Count > 0)
            {
                gvOrder.DataSource = ds.Tables[0];
                gvOrder.DataBind();
            }
            else {
                gvOrder.DataSource = null;
                gvOrder.DataBind();
            }
            Decimal recordCount = Convert.ToDecimal(ds.Tables[1].Rows[0][0].ToString());
           // PopulatePager(recordCount, pageIndex, pageName);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvOrder_PreRender(object sender, EventArgs e)
    {
        if (gvOrder.Rows.Count > 0)
        {
            gvOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion


   
}