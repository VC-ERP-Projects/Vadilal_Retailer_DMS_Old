using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Master_ExportingReport : System.Web.UI.Page
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
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        //ValidateUser();
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExportCust);
        scriptManager.RegisterPostBackControl(this.btnExportItem);
        scriptManager.RegisterPostBackControl(this.btnExportSalesReg);
        scriptManager.RegisterPostBackControl(this.btnExportPurchaseReg);
        scriptManager.RegisterPostBackControl(this.btnExportSPItemWise);
        scriptManager.RegisterPostBackControl(this.btnExportSalesReturnReg);
        scriptManager.RegisterPostBackControl(this.btnExportPurchaseReturnReg);
    }

    #endregion

    protected void btnExportCust_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=CustomerMaster_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportCustMaster";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

    protected void btnExportItem_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=ItemMaster_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportItemMaster";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
        Response.End();
    }

    protected void btnExportSalesReg_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=SalesRegister_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportSalesRegister";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

    protected void btnExportPurchaseReg_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=PurchaseRegister_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportPurchaseRegister";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

    protected void btnExportSPItemWise_Click(object sender, EventArgs e)
    {
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportSalePurItemWise";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            Response.Clear();
            Response.Buffer = false;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=SalePurItemWise_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
            excel.DataSource = ds.Tables[1];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
            excel.DataSource = ds.Tables[2];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
            excel.DataSource = ds.Tables[3];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
        Response.End();
    }

    protected void btnExportSalesReturnReg_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=SalesReturnRegister_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportSalesReturnRegister";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

    protected void btnExportPurchaseReturnReg_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=PurchaseReturnRegister_.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportPurchaseReturnRegister";
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

}


