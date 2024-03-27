using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using TaxProEInvoiceModel;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Globalization;
using System.Text;
using System.IO;

public partial class Reports_SalesRetailInvioce : System.Web.UI.Page
{
    public static string GSTID, GSTPWD, GSTIN, AuthToken;
    public static bool DebiteNote = false;

    public static bool EWayBill = false;

    #region Declaration

    string OrderNumber;
    protected int UserID, CustType;
    protected decimal ParentID, CustomerID;
    DDMSEntities ctx;
    protected String AuthType;
    Decimal DefaultPageSize = 50;
    int ViewPageNumber = 10;

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
            txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtName.ContextKey = (CustType + 1).ToString();
            acetxtVehicle.ContextKey = CustType == 4 ? 1000010000000000.ToString() : ParentID.ToString();
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);


            var PrintSize = ctx.OCFGs.Select(x => x.InvoicePrintSize).FirstOrDefault();
            ddlPrintSize.SelectedValue = PrintSize;
        }
        if (CustType == 4) // SS
        {
            divCustomer.Attributes.Add("style", "display:none;");
            divDealer.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "4";
            txtSSDistCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSDistCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;

                if (ctx.OCUMs.Any(x => x.CustID == ParentID && x.Active == true && x.OptionId == 9))
                {
                    btnJsonDownload.Visible = true;
                }
                else
                {
                    btnJsonDownload.Visible = false;
                }
            }
        }
        else if (CustType == 2)// Distributor
        {
            //divEmpCode.Attributes.Add("style", "display:none;");
            divSS.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "2";
            txtCustCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {

                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;

                if (ctx.OCUMs.Any(x => x.CustID == ParentID && x.Active == true && x.OptionId == 8))
                {
                    btnJsonDownload.Visible = true;
                }
                else
                {
                    btnJsonDownload.Visible = false;
                }
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnJsonDownload);


    }

    #endregion

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {

        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                if (CustType == 1)
                {
                    decimal FinalParentID;
                    var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
                    if (ddlReportBy.SelectedValue == "4")
                    {
                        CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out FinalParentID) ? FinalParentID : ParentID;
                    }
                    else
                    {
                        CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust).CustomerID : 0;
                    }
                }

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
                        OrderNumber += lblOrderID.Text + ',';

                    }

                }
                OrderNumber = OrderNumber.TrimEnd(",".ToArray());

                DateTime start = Convert.ToDateTime(txtFromDate.Text);
                DateTime end = Convert.ToDateTime(txtToDate.Text);

                //Boolean IsOld = true;
                //if (start >= new DateTime(2017, 1, 1))
                //{
                //    IsOld = false;
                //}
                //else if (end >= new DateTime(2017, 1, 1))
                //{
                //    txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('select one month data only',3);", true);
                //    return;
                //}

                var IsOld = "2";

                if (start < new DateTime(2017, 1, 1) && end >= new DateTime(2017, 1, 1))
                {
                    txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('select one month data only',3);", true);
                    return;
                }
                else if (start < new DateTime(2017, 1, 1))
                {
                    IsOld = "0";
                }
                else if (start >= new DateTime(2017, 1, 1) && start < new DateTime(2017, 6, 30) && end > new DateTime(2017, 6, 30))
                {
                    txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('select one month data only',3);", true);
                    return;
                }
                else if (start >= new DateTime(2017, 1, 1) && end <= new DateTime(2017, 6, 30))
                {
                    IsOld = "1";
                }

                var PrintSize = ddlPrintSize.SelectedValue;

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenInvoices('" + OrderNumber + "','" + CustomerID + "','" + PrintSize + "','" + IsOld + "');", true);
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

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid(1, "");
    }

    protected void btnTripReport_Click(object sender, EventArgs e)
    {

        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                if (CustType == 1)
                {
                    var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
                    CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;
                }
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
                        OrderNumber += lblOrderID.Text + ',';
                    }
                }
                OrderNumber = OrderNumber.TrimEnd(",".ToArray());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenTripReport('" + OrderNumber + "', '" + CustomerID + "');", true);
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

    protected void btnSalesRegister_Click(object sender, EventArgs e)
    {
        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {

                if (CustType == 1)
                {
                    var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
                    CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust && x.ParentID == ParentID).CustomerID : 0;
                }

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
                        OrderNumber += lblOrderID.Text + ',';
                    }
                }
                OrderNumber = OrderNumber.TrimEnd(",".ToArray());



                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenSalesRegister('" + OrderNumber + "', '" + CustomerID + "');", true);
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
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

            //if (SUserID == 0 && DistributorID == 0 && DealerID == 0 && CustType == 1)
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
            //    txtCustCode.Text = "";
            //    txtCustCode.Focus();
            //    return;
            //}

            if (String.IsNullOrEmpty(txtCustCode.Text) && ddlReportBy.SelectedValue == "2")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                return;
            }

            if (String.IsNullOrEmpty(txtSSDistCode.Text) && ddlReportBy.SelectedValue == "4")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
                txtCustCode.Text = "";
                txtCustCode.Focus();
                return;
            }

            DateTime start = Convert.ToDateTime(txtFromDate.Text);
            DateTime end = Convert.ToDateTime(txtToDate.Text);

            if (start < new DateTime(2017, 1, 1) && end >= new DateTime(2017, 1, 1))
            {
                txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('select one month data only',3);", true);
                gvOrder.DataSource = null;
                gvOrder.DataBind();
                PopulatePager(0, 0, "");
                return;
            }
            else if (start >= new DateTime(2017, 1, 1) && start < new DateTime(2017, 6, 30) && end > new DateTime(2017, 6, 30))
            {
                txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsgs", "ModelMsg('select one month data only',3);", true);
                gvOrder.DataSource = null;
                gvOrder.DataBind();
                PopulatePager(0, 0, "");
                return;
            }

            string Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
            string vehcleno = txtVehicle.Text.Trim().ToString();

            if (ddlReportBy != null)
            {
                if (CustType == 4)
                {
                    ddlReportBy.SelectedValue = "4";
                }
                else if (CustType == 2)
                {
                    ddlReportBy.SelectedValue = "2";
                }
            }

            decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;
            int VehicleID = 0;
            if (!String.IsNullOrEmpty(vehcleno) && ctx.OVCLs.Any(x => x.VehicleNumber == vehcleno && x.ParentID == VehicleParentID))
            {
                VehicleID = ctx.OVCLs.FirstOrDefault(x => x.VehicleNumber == vehcleno && x.ParentID == VehicleParentID).VehicleID;
            }
            int SaleID = 0;
            if (!String.IsNullOrEmpty(txtDocNo.Text))
                SaleID = Int32.TryParse(txtDocNo.Text.Split("-".ToArray()).First().Trim(), out SaleID) ? SaleID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "LoadOrders";

            Cm.Parameters.AddWithValue("@SDate", start);
            Cm.Parameters.AddWithValue("@EDate", end);
            Cm.Parameters.AddWithValue("@PageIndex", pageIndex);
            Cm.Parameters.AddWithValue("@PageSize", DefaultPageSize);
            Cm.Parameters.AddWithValue("@InvNo", SaleID);
            Cm.Parameters.AddWithValue("@OrderType", Convert.ToInt32(ddltype.SelectedValue));
            if (CustType == 1)
            {
                Cm.Parameters.AddWithValue("@Company", 1);
                Cm.Parameters.AddWithValue("@VehicleNo", 0);
            }
            else
            {
                Cm.Parameters.AddWithValue("@Company", 0);
                Cm.Parameters.AddWithValue("@VehicleNo", VehicleID);
            }
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvOrder.DataSource = ds.Tables[0];
                gvOrder.DataBind();
                //Decimal recordCount = Convert.ToDecimal(ds.Tables[1].Rows[0][0].ToString());
                //PopulatePager(recordCount, pageIndex, pageName);
            }
            else
            {
                gvOrder.DataSource = null;
                gvOrder.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void gvOrder_Prerender(object sender, EventArgs e)
    {
        if (gvOrder.Rows.Count > 0)
        {
            gvOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion

    protected void btnJsonDownload_Click(object sender, EventArgs e)
    {
        StringBuilder sb = new StringBuilder();
        bool errFound = true;
        try
        {
            if (Page.IsValid)
            {
                if (CustType == 1)
                {
                    decimal FinalParentID;
                    var Cust = txtCustCode.Text.Split("-".ToArray()).First().Trim();
                    if (ddlReportBy.SelectedValue == "4")
                    {
                        CustomerID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out FinalParentID) ? FinalParentID : ParentID;
                    }
                    else
                    {
                        CustomerID = !String.IsNullOrEmpty(Cust) ? ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Cust).CustomerID : 0;
                    }
                }

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
                sb.Append("[");
                for (int i = 0; i < gvOrder.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");

                    if (chk.Checked)
                    {
                        Label lblOrderID = (Label)gvOrder.Rows[i].FindControl("lblOrderID");
                        Label lblParentID = (Label)gvOrder.Rows[i].FindControl("lblParentID");
                        Decimal CustomerCode = Decimal.TryParse(lblParentID.Text, out CustomerCode) ? CustomerCode : ParentID;
                        // OrderNumber += lblOrderID.Text + ',';
                        string jsonData = ReadData_Actual(CustomerCode, Convert.ToInt32(lblOrderID.Text));
                        if (jsonData != "")
                        {
                            sb.Append(jsonData + ",");
                        }
                    }
                }
                string JsonFile = sb.ToString().TrimEnd(',');
                JsonFile = JsonFile + "]";
                string fileName = string.Format("{0}{1}", System.IO.Path.GetTempPath(), "Activity.txt");
                using (System.IO.StreamWriter writer = new System.IO.StreamWriter(fileName, false, Response.ContentEncoding))
                {
                    writer.WriteLine(JsonFile);
                } //Important! writer.Dispose is called automatically here
                
                


                Response.Clear();
                Response.AddHeader("content-disposition", "attachment; filename=E_Invoice_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".json");
                Response.ContentType = "application/json";
                Response.Charset = "utf-8";
                Response.WriteFile(fileName);
                  Response.End();

                Response.Flush();
                // and think about doing this, sooner or later:
                System.IO.File.Delete(fileName);
                //// File.WriteAllText(@"D:\Vimal Lakum\Documents\path.json", JsonFile);
                //Response.AddHeader("content-disposition", "attachment; filename=E_Invoice_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".json");
                //Response.ContentType = "application/json";
                //Response.Write(JsonFile.ToString());
                //Response.Flush();
                //Response.End();
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
    //  public static Dictionary<int, string> ReadData_Actual(Decimal ParentId, Int32 SaleId)
    public String ReadData_Actual(Decimal ParentId, Int32 SaleId)
    {
        string data = "";
        var result = new Dictionary<int, string>();
        try
        {
            Oledb_ConnectionClass objCon = new Oledb_ConnectionClass();
            ServiceLayerSync ServiceLayerData = new ServiceLayerSync();
            Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
            SqlCommand Cmd = new SqlCommand();
            Cmd.Parameters.Clear();
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.CommandText = "usp_GetInvoiceDetailsForEInvoice";
            Cmd.Parameters.AddWithValue("@ParentID", ParentId);
            Cmd.Parameters.AddWithValue("@SaleID", SaleId);
            DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
            DataTable oRecordSet = new DataTable();
            oRecordSet = dsdata.Tables[0];
            // 5 objCon.ByProcedureReturnDataTable("{Call Schema.VC_EINV_Query_TEST_Invoice(?,?)}", 2, ParamName, ParamVal);
            TaxProEInvoice objAPICAll = new TaxProEInvoice();
            TaxProEInvoice Invoice = new TaxProEInvoice();
            ItemList objItemList = new ItemList();
            if (oRecordSet.Rows.Count > 0)
            {
                for (int i = 0; i < 1; i++)
                {
                    GSTIN = string.Empty;

                    Invoice = new TaxProEInvoice();
                    GSTID = Convert.ToString(oRecordSet.Rows[0]["U_GSTID"]);
                    GSTPWD = Convert.ToString(oRecordSet.Rows[0]["U_GSTPW"]);


                    Invoice.Version = "1.1";

                    Invoice.TranDtls.TaxSch = "GST";
                    Invoice.TranDtls.SupTyp = Convert.ToString(oRecordSet.Rows[0]["SupTyp"]);
                    Invoice.TranDtls.RegRev = "N";
                    Invoice.TranDtls.EcmGstin = null;//Convert.ToString(oRecordSet.Rows[0]["CompanyGstInNo"]); ;
                    Invoice.TranDtls.IgstOnIntra = Convert.ToString(oRecordSet.Rows[0]["IGSTONITRA"]);

                    Invoice.DocDtls.Typ = Convert.ToString(oRecordSet.Rows[0]["DocDtls.Typ"]);
                    Invoice.DocDtls.No = Convert.ToString(oRecordSet.Rows[0]["InvoiceNumber"]);
                    Invoice.DocDtls.Dt = Convert.ToString(oRecordSet.Rows[0]["InvoiceDate"]);

                    Invoice.SellerDtls.Gstin = Convert.ToString(oRecordSet.Rows[0]["CompanyGstInNo"]);
                    Invoice.SellerDtls.LglNm = Convert.ToString(oRecordSet.Rows[0]["CompanyName"]);
                    Invoice.SellerDtls.TrdNm = null;

                    string Add1 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress1"]);
                    if (Add1.Length > 100)
                    {
                        Invoice.SellerDtls.Addr1 = Add1.Substring(0, 100);
                    }
                    else
                    {
                        Invoice.SellerDtls.Addr1 = Add1;
                    }

                    if (Convert.ToString(oRecordSet.Rows[0]["CompanyAddress2"]).Length > 1)
                    {
                        string Add2 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress2"]);
                        if (Add2.Length > 100)
                        {
                            Invoice.SellerDtls.Addr2 = Add2.Substring(0, 100);
                        }
                        else
                        {
                            Invoice.SellerDtls.Addr2 = Add2;
                        }
                    }
                    else
                    { Invoice.SellerDtls.Addr2 = null; }

                    Invoice.SellerDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["SellerLocation"]);
                    Invoice.SellerDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["SellerPin"]));
                    Invoice.SellerDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["Stcd"]);
                    if (Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWOP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "DEXP")
                    {
                        Invoice.BuyerDtls.Gstin = "";
                        Invoice.BuyerDtls.Pos = "";
                        Invoice.BuyerDtls.Pin = 0;
                        Invoice.BuyerDtls.Stcd = "";
                    }
                    else
                    {
                        Invoice.BuyerDtls.Gstin = Convert.ToString(oRecordSet.Rows[0]["Demo"]);
                        Invoice.BuyerDtls.Pos = Convert.ToString(oRecordSet.Rows[0]["Demo1"]);
                        Invoice.BuyerDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["ShipDtls.Pin"]));
                        Invoice.BuyerDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["Demo1"]);
                    }


                    Invoice.BuyerDtls.LglNm = Convert.ToString(oRecordSet.Rows[0]["CustomerName"]);
                    Invoice.BuyerDtls.TrdNm = null;
                    string ShipDtlsAdd1 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress1"]);
                    if (ShipDtlsAdd1.Length > 100)
                    {
                        Invoice.BuyerDtls.Addr1 = ShipDtlsAdd1.Substring(0, 100);
                    }
                    else
                    {
                        Invoice.BuyerDtls.Addr1 = ShipDtlsAdd1;
                    }


                    if (Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]).Length > 1)
                    {
                        string ShipDtlsAdd2 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]);
                        if (ShipDtlsAdd2.Length > 100)
                        {
                            Invoice.BuyerDtls.Addr2 = ShipDtlsAdd2.Substring(0, 100);
                        }
                        else
                        {
                            Invoice.BuyerDtls.Addr2 = ShipDtlsAdd2;
                        }
                    }
                    else
                    {
                        Invoice.BuyerDtls.Addr2 = null;
                    }
                    Invoice.BuyerDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["CustomerLocation"]);


                    if (Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWOP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "DEXP")
                    {
                        DataTable oRecor = new DataTable();
                        oRecor = dsdata.Tables[0];
                    }
                    else
                    {

                    }

                }
                DataTable oRec1 = new DataTable();

                oRec1 = dsdata.Tables[0];
                if (oRec1.Rows.Count > 0)
                {
                    double IGSTActSum = 0.0;
                    int SrlNo = 0;
                    for (int k = 0; k < oRec1.Rows.Count; k++)
                    {
                        objItemList = new ItemList();
                        GSTIN = Convert.ToString(oRec1.Rows[k]["CompanyGstInNo"]);
                        SrlNo = SrlNo + 1;
                        objItemList.SlNo = Convert.ToString(SrlNo);
                        if (DebiteNote == false)
                        {
                            if (!string.IsNullOrEmpty(Convert.ToString(oRec1.Rows[k]["ItemName"])))
                            {
                                objItemList.PrdDesc = Convert.ToString(oRec1.Rows[k]["ItemName"]);
                            }
                        }
                        if (DebiteNote == true)
                        {
                            if (Convert.ToString(oRec1.Rows[k]["ItemName"]).Length > 1)
                            {
                                objItemList.PrdDesc = Convert.ToString(oRec1.Rows[k]["ItemName"]);
                            }
                        }
                        objItemList.IsServc = Convert.ToString(oRec1.Rows[k]["IsServc"]);

                        if (DebiteNote == false)
                        {
                            string HSNCode = Convert.ToString(oRec1.Rows[k]["HSNCode"]);
                            if (HSNCode.Contains(".") || HSNCode.Contains("-"))
                            {
                                HSNCode = HSNCode.Remove(4, 1);
                                HSNCode = HSNCode.Remove(6, 1);
                            }
                            objItemList.HsnCd = HSNCode;
                        }
                        if (DebiteNote == true)
                        {
                            string HSNCode = Convert.ToString(oRec1.Rows[k]["HSNCode"]);
                            objItemList.HsnCd = HSNCode;
                        }
                        if (DebiteNote == false)
                        {
                            objItemList.Qty = Convert.ToDouble(oRec1.Rows[k]["Quantity"].ToString());
                            // 15-Nov-22 Vimal
                            if (!string.IsNullOrEmpty(oRec1.Rows[k]["UnitName"].ToString()))
                            {
                                objItemList.Unit = "CTN";//oRec1.Rows[k]["UnitName"].ToString();
                            }
                            // 15-Nov-22 Vimal
                        }
                        objItemList.UnitPrice = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["UnitPrice"])), 2);
                        objItemList.TotAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GrossAmt"])), 2);
                        objItemList.Discount = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2);
                        objItemList.AssAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GrossAmt"])) - Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2);
                        objItemList.GstRt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GSTRate"])), 2);


                        // 14-Nov-22
                        if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                        {
                            double Amount = Math.Round(((Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DocTotal"])) * Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["ItemList.Item.GstRate"]))) / 100), 2);
                            IGSTActSum += Amount;
                            objItemList.IgstAmt = Amount;
                        }
                        else
                        {
                            objItemList.IgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["IGSTVal"])), 2);
                        }

                        objItemList.CgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CGSTVal"])), 2);
                        objItemList.SgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["SGSTVal"])), 2);
                        objItemList.CesRt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CesRt"])), 2);
                        objItemList.CesAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CessSum"])), 2);
                        objItemList.CesNonAdvlAmt = 0;
                        objItemList.StateCesRt = 0;
                        objItemList.StateCesAmt = 0;
                        objItemList.StateCesNonAdvlAmt = 0;
                        objItemList.OthChrg = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["OthChrg"])), 2);
                        if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                        {
                            objItemList.TotItemVal = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["Total"])) + Math.Round(objItemList.IgstAmt), 2);
                        }
                        else
                        {
                            objItemList.TotItemVal = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["Total"]))); //+ Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["IGSTVal"])) - Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2); // Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DocTotal"])), 2);
                        }
                        Invoice.ItemList.Add(objItemList);
                    }
                    Invoice.PrecDocDtls.InvNo = null;
                    Invoice.PrecDocDtls.InvDt = null;

                    Invoice.ValDtls.AssVal = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["TotalbBefTax"])), 2);
                    Invoice.ValDtls.Item_Taxable_Value = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["TotalbBefTax"])), 2);
                    Invoice.ValDtls.CgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalCGSTVal"])), 2);
                    Invoice.ValDtls.SgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalSGSTVal"])), 2);

                    Invoice.ValDtls.IgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalIGSTVal"])), 2);
                    Invoice.ValDtls.RndOffAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["Roundoff"])), 2);
                    if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                    {
                        Invoice.ValDtls.TotInvVal = Math.Round((Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["DocTotal"]))), 2); //+ Invoice.ValDtls.IgstVal + Invoice.ValDtls.CesVal), 2);
                    }
                    else
                    {
                        Invoice.ValDtls.TotInvVal = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["DocTotal"])), 2);
                    }

                    bool EwayFlag = false;
                    try
                    {
                        DataTable oRecord = new DataTable();
                        if (oRecord.Rows.Count > 0)
                        {
                            EwayFlag = true;
                        }
                    }
                    catch { }
                    if (EwayFlag == true && ((Invoice.TranDtls.SupTyp != "B2B") || (Invoice.SellerDtls.Stcd != Invoice.BuyerDtls.Stcd) || (Invoice.SellerDtls.Stcd == Invoice.BuyerDtls.Stcd && Invoice.TranDtls.SupTyp == "B2B" && Invoice.ValDtls.TotInvVal >= Convert.ToDouble("50000"))))
                    {
                        EWayBill = true;
                    }
                    else
                    {
                        EWayBill = false;
                    }

                    if (DebiteNote == false && EwayFlag == true && EWayBill == true && Invoice.DocDtls.Typ == "INV") //&& DocType == "I"
                    {
                        DataTable oRecor;
                        oRecor = new DataTable();
                        if (oRecor.Rows.Count > 0)
                        {
                            EWayBill = false;
                        }
                    }
                    else
                    {
                        //  Invoice.EwbDtls = null;
                    }

                    //try
                    //{
                    //    var obtGetToken = new Dictionary<int, string>();
                    //    obtGetToken = ServiceLayerData.SAPGetToken(GSTIN, GSTID, GSTPWD);
                    //    if (obtGetToken.Count > 0)
                    //    {
                    //        //AuthToken
                    //        if (obtGetToken.FirstOrDefault().Key == 1)
                    //        {
                    //            string SuccessToken = obtGetToken[1];
                    //            dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                    //            dynamic data1T = JsonConvert.SerializeObject(DataT["Data"]);
                    //            dynamic data2T = JsonConvert.DeserializeObject(data1T);
                    //            AuthToken = Convert.ToString(data2T["AuthToken"]);
                    //        }
                    //        else
                    //        {
                    //            string ErrToken = obtGetToken[1];
                    //            dynamic DataTT = JsonConvert.DeserializeObject(ErrToken);
                    //            dynamic data1TT = JsonConvert.SerializeObject(DataTT["error"]);
                    //            dynamic data2TTT = JsonConvert.DeserializeObject(data1TT);
                    //            result.Add(2, "Failed to generate AuthToken due to error" + Convert.ToString(data2TTT["message"]));
                    //            return result;
                    //        }
                    //    }
                    //}
                    //catch (Exception e)
                    //{
                    //    result.Add(2, "Error due to:" + e.Message);
                    //    return result;
                    //}

                    data = JsonConvert.SerializeObject(Invoice, new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Include });


                    //var objArray = new Dictionary<int, string>();

                    //objArray = ServiceLayerData.SAPAddToEInvoice(data, AuthToken, GSTIN, GSTID);
                    //if (objArray.Count > 0)
                    //{
                    //    try
                    //    {
                    //        if (objArray.FirstOrDefault().Key == 1)
                    //        {
                    //            string Success2 = (objArray[1]);
                    //            dynamic Data = JsonConvert.DeserializeObject(Success2);
                    //            string Status = Convert.ToString(Data["Status"]);

                    //            dynamic Err = JsonConvert.SerializeObject(Data["ErrorDetails"]);
                    //            dynamic DErr = "";
                    //            string ErMessage = "";
                    //            if (Err != "null")
                    //            {
                    //                DErr = JsonConvert.DeserializeObject(Err);
                    //                ErMessage = DErr[0]["ErrorMessage"];
                    //            }
                    //            var obtGetIRNDtl = new Dictionary<int, string>();
                    //            if (Status == "0")
                    //            {
                    //                if (Data["InfoDtls"] != null)
                    //                {
                    //                    dynamic Dtls = JsonConvert.SerializeObject(Data["InfoDtls"]);
                    //                    dynamic Dtlss = JsonConvert.DeserializeObject(Dtls);

                    //                    string IRNNo = Dtlss[0]["Desc"].Irn;
                    //                    obtGetIRNDtl = ServiceLayerData.SAPGetIRN(IRNNo, AuthToken, GSTIN, GSTID);
                    //                    string SuccessToken = obtGetIRNDtl[1];
                    //                    if (ErMessage == "Duplicate IRN")
                    //                    {
                    //                        try
                    //                        {

                    //                            if (obtGetIRNDtl.Count > 0)
                    //                            {
                    //                                if (obtGetIRNDtl.FirstOrDefault().Key == 1)
                    //                                {
                    //                                    try
                    //                                    {

                    //                                        dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                    //                                        dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                    //                                        dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                    //                                        dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);

                    //                                        if (Sucss != null && ErrorDetails == "null")
                    //                                        {
                    //                                            dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                    //                                            var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                    //                                            Data1 EInvClass = new Data1();
                    //                                            EInvClass.Irn = res.Irn;
                    //                                            EInvClass.SignedQRCode = res.SignedQRCode;
                    //                                            EInvClass.AckNo = res.AckNo;
                    //                                            EInvClass.AckDt = res.AckDt;
                    //                                            //EInvClass.EwbNo = res.EwbNo;
                    //                                            //EInvClass.EwbDt = res.EwbDt;
                    //                                            //EInvClass.EwbValidTill = res.EwbValidTill;

                    //                                            var objArray1 = new Dictionary<int, string>();
                    //                                            objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                    //                                            if (objArray1.FirstOrDefault().Key == 1)
                    //                                            {
                    //                                                result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                                                return result;
                    //                                            }
                    //                                            else
                    //                                            {
                    //                                                result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                                                return result;
                    //                                            }
                    //                                        }
                    //                                        else
                    //                                        {
                    //                                            result.Add(2, Convert.ToString("Fetch IRN Failed : " + Convert.ToString(ErrDetails[0].ErrorMessage)));
                    //                                            return result;
                    //                                        }
                    //                                    }
                    //                                    catch (Exception ex)
                    //                                    {
                    //                                        result.Add(2, Convert.ToString("Fetch IRN Failed : " + ex.ToString()));
                    //                                        return result;
                    //                                    }
                    //                                }
                    //                            }
                    //                        }
                    //                        catch (Exception ex)
                    //                        {
                    //                            result.Add(2, "Invoice can't posted on portal due to " + Convert.ToString(ex.Message));
                    //                            return result;
                    //                        }
                    //                    }
                    //                    else
                    //                    {

                    //                        dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                    //                        dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                    //                        dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                    //                        dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);

                    //                        if (Sucss != null && ErrorDetails == "null")
                    //                        {
                    //                            dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                    //                            var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                    //                            Data1 EInvClass = new Data1();
                    //                            EInvClass.Irn = res.Irn;
                    //                            EInvClass.SignedQRCode = res.SignedQRCode;
                    //                            EInvClass.AckNo = res.AckNo;
                    //                            EInvClass.AckDt = res.AckDt;
                    //                            //EInvClass.EwbNo = res.EwbNo;
                    //                            //EInvClass.EwbDt = res.EwbDt;
                    //                            //EInvClass.EwbValidTill = res.EwbValidTill;

                    //                            var objArray1 = new Dictionary<int, string>();
                    //                            objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                    //                        }
                    //                        result.Add(2, "Invoice can't posted on portal due to " + ErMessage);
                    //                        return result;
                    //                    }
                    //                }
                    //                else
                    //                {
                    //                    dynamic Sucss = JsonConvert.SerializeObject(Data["Data"]);
                    //                    dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                    //                    Data1 EInvClass = new Data1();
                    //                    if (DSucss != null)
                    //                    {
                    //                        var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                    //                        EInvClass.Irn = res.Irn;
                    //                        EInvClass.SignedQRCode = res.SignedQRCode;
                    //                        EInvClass.AckNo = res.AckNo;
                    //                        EInvClass.AckDt = res.AckDt;
                    //                    }
                    //                    //EInvClass.EwbNo = res.EwbNo;
                    //                    //EInvClass.EwbDt = res.EwbDt;
                    //                    //EInvClass.EwbValidTill = res.EwbValidTill;
                    //                    var objArray1 = new Dictionary<int, string>();
                    //                    objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                    //                    if (objArray1.FirstOrDefault().Key == 1)
                    //                    {
                    //                        //result.Add(1, "IRN Number Updated Successfully");
                    //                        result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                        return result;
                    //                    }
                    //                    else
                    //                    {
                    //                        result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                        return result;
                    //                    }
                    //                }
                    //            }
                    //            else if (Status == "1")
                    //            {
                    //                dynamic Dtls = JsonConvert.SerializeObject(Data["Data"]);
                    //                dynamic Dtlss = JsonConvert.DeserializeObject(Dtls);
                    //                var res = JsonConvert.DeserializeObject<dynamic>(Dtlss);
                    //                string IRNNo = Convert.ToString(res.Irn);
                    //                obtGetIRNDtl = ServiceLayerData.SAPGetIRN(IRNNo, AuthToken, GSTIN, GSTID);
                    //                string SuccessToken = obtGetIRNDtl[1];

                    //                dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                    //                dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                    //                dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                    //                dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);
                    //                if (Sucss != null && ErrorDetails == null)
                    //                {
                    //                    dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                    //                    var res1 = JsonConvert.DeserializeObject<dynamic>(DSucss);
                    //                    Data1 EInvClass = new Data1();
                    //                    EInvClass.Irn = res1.Irn;
                    //                    EInvClass.SignedQRCode = res1.SignedQRCode;
                    //                    EInvClass.AckNo = res1.AckNo;
                    //                    EInvClass.AckDt = res1.AckDt;

                    //                    //EInvClass.EwbNo = res.EwbNo;
                    //                    //EInvClass.EwbDt = res.EwbDt;
                    //                    //EInvClass.EwbValidTill = res.EwbValidTill;

                    //                    var objArray1 = new Dictionary<int, string>();
                    //                    objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                    //                    if (objArray1.FirstOrDefault().Key == 1)
                    //                    {
                    //                        result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                        return result;
                    //                    }
                    //                    else
                    //                    {
                    //                        result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                    //                        return result;
                    //                    }
                    //                }
                    //            }
                    //        }
                    //        else if (objArray.FirstOrDefault().Key == 2)
                    //        {
                    //            result.Add(2, "Invoice can't posted on portal due to:" + objArray.FirstOrDefault().Value);
                    //            return result;
                    //        }
                    //        else
                    //        {
                    //            result.Add(2, "Invoice can't posted on portal due to:" + objArray.FirstOrDefault().Value);
                    //            return result;
                    //        }
                    //        DebiteNote = false;
                    //    }
                    //    catch (Exception e)
                    //    {
                    //        result.Add(2, "Error due to:" + e);
                    //        return result;
                    //    }
                    //}
                }
                //   }
            }
            else
            {
                result.Add(2, "GST No. Or Import/Export Data should be mandatory");
                //return result;
            }
        }
        catch (Exception e)
        {
            result.Add(3, "Error due to:" + e.Message);
            //return result;
        }
        return data;
    }
    public static Dictionary<int, string> UpdateInvoice(Decimal ParentId, Int32 SaleId, string IrnData, string SignQRCodeData, string AckNos, string AckDts, String ErrorMsg, int Status)
    {
        DDMSEntities ctx = new DDMSEntities();

        var result = new Dictionary<int, string>();
        try
        {
            ServiceLayerSync ServiceLayerData = new ServiceLayerSync();
            POS4 oInvDocument = new POS4();
            oInvDocument.ParentId = ParentId;
            oInvDocument.SaleId = SaleId;
            oInvDocument.IRN = IrnData;
            oInvDocument.SignedQRCode = SignQRCodeData;
            oInvDocument.AckNo = AckNos;
            oInvDocument.CreatedDate = System.DateTime.Now;
            oInvDocument.Status = Status;
            if (AckDts != null)
            {
                AckDts = AckDts.Remove(10);
                string dt2 = AckDts.Substring(AckDts.Length - 2) + "/" + AckDts.Substring(AckDts.Length - 5, AckDts.Length - 8) + "/" + AckDts.Substring(0, 4);
                DateTime todaysDt = DateTime.ParseExact(dt2, "dd/MM/yyyy", CultureInfo.InvariantCulture);
                oInvDocument.AckDate = todaysDt;
            }
            else
            {
                oInvDocument.AckDate = null;
            }
            oInvDocument.ErrorDetails = ErrorMsg;
            ctx.POS4.Add(oInvDocument);
            OPOS ObjPOs = ctx.OPOS.Where(x => x.ParentID == ParentId && x.SaleID == SaleId).FirstOrDefault();
            if (ObjPOs != null)
            {
                ObjPOs.EInvoiceStatus = Status;
            }
            ctx.SaveChanges();
            return result;
        }
        catch (Exception e)
        {
            result.Add(2, "Error due to:" + e);
            return result;
        }
    }

}