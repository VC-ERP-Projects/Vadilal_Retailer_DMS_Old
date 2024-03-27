using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DealerMonthWiseSaleRpt : System.Web.UI.Page
{

    #region Property

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType, UserName;

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

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + "," + x.Name).FirstOrDefault().ToString();
                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("Inward");
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
        txtSSDistCode.Text = txtDistCode.Text = txtDealerCode.Text = "";
        txtToMonth.Text = txtFromMonth.Text = DateTime.Now.Month.ToString() + '/' + DateTime.Now.Year.ToString();
    }

    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
    }
    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime FromDate = Convert.ToDateTime(txtFromMonth.Text);
        DateTime ToDate = Convert.ToDateTime(txtToMonth.Text);
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        string Todate = new DateTime(ToDate.Year, ToDate.Month, DateTime.DaysInMonth(ToDate.Year, ToDate.Month)).ToShortDateString();

        if (DateTime.Compare(ToDate, FromDate) == -1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('From Month should small then To Month',3);", true);
            return;
        }
        if ((ToDate - FromDate).TotalDays >= 365)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
            return;
        }

        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
        Decimal SS = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SS) ? SS : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        if (RegionID == 0 && CityID == 0 && SS == 0 && DistributorID == 0 && DealerID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
            return;
        }

        ifmDealerMnthSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerMnthSaleFromDate=" + FromDate.ToShortDateString() + "&DealerMnthSaleToDate=" + Todate + "&DealerMnthSaleRegion=" + RegionID + "&DealerMnthSaleCity=" + CityID + "&DealerMnthSaleSaleBy=" + ddlSaleBy.SelectedValue + "&DealerMnthSaleSS=" + SS + "&DealerMnthSaleDist=" + DistributorID + "&DealerMnthSaleDealer=" + DealerID + "&DealerMnthSaleDivision=" + ddlDivision.SelectedValue + "&DealerMnthSaleSUserID=" + SUserID);
    }
    protected void ifmDealerMnthSale_Load(object sender, EventArgs e)
    {

    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        DateTime FromDate = Convert.ToDateTime(txtFromMonth.Text);
        DateTime ToDate = Convert.ToDateTime(txtToMonth.Text);
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        DateTime Todate = new DateTime(ToDate.Year, ToDate.Month, DateTime.DaysInMonth(ToDate.Year, ToDate.Month));

        if (DateTime.Compare(ToDate, FromDate) == -1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('From Month should small then To Month',3);", true);
            return;
        }
        if ((ToDate - FromDate).TotalDays >= 365)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
            return;
        }

        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
        Decimal SS = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SS) ? SS : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
        if (RegionID == 0 && CityID == 0 && SS == 0 && DistributorID == 0 && DealerID == 0 && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
            return;
        }

        //ifmDealerMnthSale.Attributes.Add("src", "../Reports/ViewReport.aspx?DealerMnthSaleFromDate=" + FromDate.ToShortDateString() + "&DealerMnthSaleToDate=" + Todate + "&DealerMnthSaleRegion=" + RegionID + "&DealerMnthSaleCity=" + CityID + "&DealerMnthSaleSaleBy=" + ddlSaleBy.SelectedValue + "&DealerMnthSaleSS=" + SS + "&DealerMnthSaleDist=" + DistributorID + "&DealerMnthSaleDealer=" + DealerID + "&DealerMnthSaleDivision=" + ddlDivision.SelectedValue + "&DealerMnthSaleSUserID=" + SUserID + "&Export=1");
        try
        {
            var CustCol = ddlSaleBy.SelectedValue == "2" ? "Dealer" : "Distributor";
            var ParentCol = ddlSaleBy.SelectedValue == "4" ? "SuperStockist" : "Distributor";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CUSTMONTHWISESALE";

            Cm.Parameters.AddWithValue("@FromDate", FromDate);
            Cm.Parameters.AddWithValue("@ToDate", Todate);
            Cm.Parameters.AddWithValue("@CITYID", CityID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@SSID", SS);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@Division", ddlDivision.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();

            StringWriter writer = new StringWriter();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            writer.WriteLine("Customer + Month Wise Sale Report,");
            writer.WriteLine("From Date ," + FromDate.ToString("MMM-yy") + ",");
            writer.WriteLine("To Date ," + Todate.ToString("MMM-yy"));
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);
            writer.WriteLine("Sale By ," + ddlSaleBy.SelectedItem.Text);
            writer.WriteLine(ParentCol + " Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
            writer.WriteLine(CustCol + " City ," + (CityID != 0 ? txtCity.Text.Split('-')[1].ToString() : "All City"));
            if (ddlSaleBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SS != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));
            writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
            if (ddlSaleBy.SelectedValue == "2")
                writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All Dealer"));
            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
            writer.WriteLine("User ," + UserName);
            writer.WriteLine("Created On ," + DateTime.Now);

            do
            {
                writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetName).ToList()));
                int count = 0;
                while (reader.Read())
                {
                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                    if (++count % 100 == 0)
                    {
                        writer.Flush();
                    }
                }
            }
            while (reader.NextResult());

            Response.AddHeader("content-disposition", "attachment; filename=CustomerMonthWiseSale" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void gvSalevsDispatch_PreRender(object sender, EventArgs e)
    {
        if (gvSalevsDispatch.Rows.Count > 0)
        {
            gvSalevsDispatch.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSalevsDispatch.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}