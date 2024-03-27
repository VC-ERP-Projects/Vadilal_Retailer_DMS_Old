using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_SalesReturnRegister : System.Web.UI.Page
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

        ddlDocType.Items.Insert(0, new ListItem("----Select----", "0"));
        ddlDocType.DataBind();

        if (CustType == 1)
        {
            txtDistCode.Enabled = true;
            acetxtName.ContextKey = (CustType + 1).ToString();
        }
        else
        {
            txtDistCode.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }

        }

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

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal Decnum = 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) ? Decnum : 0;

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "SalesReturnRegister";

            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@CustomerID", DealerID);
            Cm.Parameters.AddWithValue("@DocType", ddlDocType.SelectedValue);
            Cm.Parameters.AddWithValue("@GroupBy", ddlInvoiceType.SelectedValue);

            if (CustType == 1)
            {
                if (Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out Decnum) && Decnum > 0)
                {
                    Cm.Parameters.AddWithValue("@ParentID", Decnum);
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    ds.Tables[0].Columns.Remove("ORDERDATE");
                    gvSalesRegister.DataSource = ds.Tables[0];
                    gvSalesRegister.DataBind();

                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        var Data = (from a in ctx.OCRDs
                                    join b in ctx.CRD1 on a.CustomerID equals b.CustomerID
                                    join c in ctx.OCTies on b.CityID equals c.CityID
                                    where a.CustomerID == Decnum
                                    select new { GST = a.GSTIN, CityName = c.CityName }).FirstOrDefault();

                        txtData.Text = Data.GST + " # " + Data.CityName;
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Distributor.',3);", true);
                    txtDistCode.Text = "";
                    txtDistCode.Focus();
                }
            }
            else
            {
                Cm.Parameters.AddWithValue("@ParentID", ParentID.ToString());
                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                ds.Tables[0].Columns.Remove("ORDERDATE");
                gvSalesRegister.DataSource = ds.Tables[0];
                gvSalesRegister.DataBind();
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