using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_PurchaseRegister : System.Web.UI.Page
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

        txtDistCode.Text = txtSSDistCode.Text = txtCode.Text = txtData.Text = "";
    }

    #endregion

    #region PageLoad

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

    #endregion

    #region Griedview Events

    protected void gvSalesRegister_PreRender(object sender, EventArgs e)
    {
        if (gvSalesRegister.Rows.Count > 0)
        {
            gvSalesRegister.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSalesRegister.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void gvSalesDivision_PreRender(object sender, EventArgs e)
    {
        if (gvSalesDivision.Rows.Count > 0)
        {
            gvSalesDivision.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSalesDivision.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void gvHSN_PreRender(object sender, EventArgs e)
    {
        if (gvHSN.Rows.Count > 0)
        {
            gvHSN.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvHSN.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }

            if (ddlPurchaseBy.SelectedValue == "4" && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Super Stockist.',3);", true);
                return;
            }
            else if (ddlPurchaseBy.SelectedValue == "2" && DistributorID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "PurchaseRegister";

            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@GroupBy", ddlGroupBy.SelectedValue);
            Cm.Parameters.AddWithValue("@InwardType", ddlInvoiceType.SelectedValue);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@PurchaseBy", ddlPurchaseBy.SelectedValue);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('None data is available on basis of selected criteria.',3);", true);
                return;
            }
            //ds.Tables[0].Columns.Remove("ORDERDATE");
            if (ddlGroupBy.SelectedValue == "1")
            {
                gvSalesRegister.DataSource = null;
                gvSalesRegister.DataBind();
                gvHSN.DataSource = null;
                gvHSN.DataBind();
                gvSalesDivision.Visible = true;
                gvSalesDivision.DataSource = ds.Tables[0];
                gvSalesDivision.DataBind();
            }
            else if (ddlGroupBy.SelectedValue == "2")
            {
                gvSalesDivision.DataSource = null;
                gvSalesDivision.DataBind();
                gvHSN.DataSource = null;
                gvHSN.DataBind();
                gvSalesRegister.Visible = true;
                gvSalesRegister.DataSource = ds.Tables[0];
                gvSalesRegister.DataBind();
            }
            else if (ddlGroupBy.SelectedValue == "3")
            {
                gvSalesDivision.DataSource = null;
                gvSalesDivision.DataBind();
                gvSalesRegister.DataSource = null;
                gvSalesRegister.DataBind();
                gvHSN.Visible = true;
                gvHSN.DataSource = ds.Tables[0];
                gvHSN.DataBind();
            }


            txtData.Text = "";

            if (CustType == 1 && DistributorID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = (from a in ctx.OCRDs
                                join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                join c in ctx.OCTies on b.CityID equals c.CityID
                                where a.CustomerID == DistributorID
                                select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();

                    txtData.Text = Data.GST + " # " + Data.CityName;
                }
            }
            else if (CustType == 1 && SSID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = (from a in ctx.OCRDs
                                join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                join c in ctx.OCTies on b.CityID equals c.CityID
                                where a.CustomerID == SSID
                                select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();

                    txtData.Text = Data.GST + " # " + Data.CityName;
                }
            }
            else
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = (from a in ctx.OCRDs
                                join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                join c in ctx.OCTies on b.CityID equals c.CityID
                                where a.CustomerID == ParentID
                                select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();

                    txtData.Text = Data.GST + " # " + Data.CityName;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}