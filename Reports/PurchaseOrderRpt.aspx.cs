using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PurchaseOrderRpt : System.Web.UI.Page
{

    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    Decimal DefaultPageSize = 50;
    int ViewPageNumber = 10;
    string InwardNumber;

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

    private void BindGrid(int pageIndex, string pageName)
    {
        try
        {

            DateTime start = Convert.ToDateTime(txtFromDate.Text);
            DateTime end = Convert.ToDateTime(txtToDate.Text);


            int OrderID = 0;
            if (!String.IsNullOrEmpty(txtDocNo.Text))
                OrderID = Int32.TryParse(txtDocNo.Text.Split("-".ToArray()).First().Trim(), out OrderID) ? OrderID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "Loadpurchaseorders";

            Cm.Parameters.AddWithValue("@SDate", start);
            Cm.Parameters.AddWithValue("@EDate", end);
            Cm.Parameters.AddWithValue("@PageIndex", pageIndex);
            Cm.Parameters.AddWithValue("@PageSize", DefaultPageSize);
            Cm.Parameters.AddWithValue("@InvNo", OrderID);
            //Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);

            Decimal CustomerID = 0;
            if (CustType == 1)
            {
                if (!String.IsNullOrEmpty(txtCustCode.Text))
                    CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;

                if (CustomerID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Distributor.', 3);", true);
                    return;
                }
                Cm.Parameters.AddWithValue("@ParentID", CustomerID);
            }
            else
            {
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
            }
            Cm.Parameters.AddWithValue("@Type", ddltype.SelectedValue);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvOrder.DataSource = ds.Tables[0];
                gvOrder.DataBind();

                Decimal recordCount = Convert.ToDecimal(ds.Tables[1].Rows[0][0].ToString());
                //  Decimal recordCount = ds.Tables[0].Rows.Count;
                PopulatePager(recordCount, pageIndex, pageName);
            }
            else
            {
                gvOrder.DataSource = null;
                gvOrder.DataBind();
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
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
            //using (DDMSEntities ctx = new DDMSEntities())
            //{
            //    var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            //    ddlDivision.DataSource = Division;
            //    ddlDivision.DataBind();
            //    ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            //}


            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        }
    }

    #endregion

    #region Button Click

    protected void ifmPurchaseOrder_Load(object sender, EventArgs e)
    {

    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid(1, "");
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                    if (chk.Checked == true)
                    {
                        errFound = false;
                    }
                }

                if (errFound == true)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select atleast one row!',3);", true);
                    return;
                }


                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");

                    if (chk.Checked)
                    {
                        Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");
                        InwardNumber += lblOrderID.Text + ',';
                    }
                }

                Decimal CustomerID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;
                if (CustomerID == 0 && CustType == 1)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Distributor.', 3);", true);
                    return;
                }
                else
                {
                    InwardNumber = InwardNumber.TrimEnd(",".ToArray());
                    // ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenInvoices('" + InwardNumber + "','" + CustomerID + "','" + ddlDivision.SelectedValue + "');", true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenInvoices('" + InwardNumber + "','" + CustomerID + "');", true);
                }

            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}