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
using System.Diagnostics;
using System.IO;

public partial class Reports_DealerWiseGrowthSaleReport : System.Web.UI.Page
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
        txtSSDistCode.Text = txtDistCode.Text = txtDealerCode.Text = txtFromMonth1.Text = txtFromMonth2.Text = txtToMonth1.Text = txtToMonth2.Text = "";
        txtToMonth2.Text = txtFromMonth2.Text = txtToMonth1.Text = txtFromMonth1.Text = DateTime.Now.Month.ToString() + '/' + DateTime.Now.Year.ToString();
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
        try
        {
            if (String.IsNullOrEmpty(txtFromMonth1.Text) || String.IsNullOrEmpty(txtToMonth1.Text) || String.IsNullOrEmpty(txtFromMonth2.Text) || String.IsNullOrEmpty(txtToMonth2.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                return;
            }
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (RegionID == 0 && CityID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
                return;
            }
            DateTime Fromdate1 = Convert.ToDateTime(txtFromMonth1.Text);
            DateTime Todate1 = Convert.ToDateTime(txtToMonth1.Text);
            DateTime Fromdate2 = Convert.ToDateTime(txtFromMonth2.Text);
            DateTime Todate2 = Convert.ToDateTime(txtToMonth2.Text);
            DateTime nTodate1 = new DateTime(Todate1.Year, Todate1.Month, DateTime.DaysInMonth(Todate1.Year, Todate1.Month));
            DateTime nTodate2 = new DateTime(Todate2.Year, Todate2.Month, DateTime.DaysInMonth(Todate2.Year, Todate2.Month));

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "DealerWiseGrowthSale";

            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@Division", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@FromDate1", Fromdate1);
            Cm.Parameters.AddWithValue("@ToDate1", nTodate1);
            Cm.Parameters.AddWithValue("@FromDate2", Fromdate2);
            Cm.Parameters.AddWithValue("@ToDate2", nTodate2);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            gvGrid.DataSource = ds.Tables[0];
            gvGrid.DataBind();
            string FD1 = Convert.ToDateTime(txtFromMonth1.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtFromMonth1.Text).Year.ToString();
            string TD1 = Convert.ToDateTime(txtToMonth1.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtToMonth1.Text).Year.ToString();
            string FD2 = Convert.ToDateTime(txtFromMonth2.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtFromMonth2.Text).Year.ToString();
            string TD2 = Convert.ToDateTime(txtToMonth2.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtToMonth2.Text).Year.ToString();
            if (gvGrid.Rows.Count > 0)
            {
                gvGrid.HeaderRow.Cells[9].Text = FD1 + " # " + TD1 + " Ltrs.";
                gvGrid.HeaderRow.Cells[10].Text = FD1 + " # " + TD1 + " Value ";
                gvGrid.HeaderRow.Cells[11].Text = FD2 + " # " + TD2 + " Ltrs.";
                gvGrid.HeaderRow.Cells[12].Text = FD2 + " # " + TD2 + " Value ";
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #region Griedview Events

    protected void gvGrid_PreRender(object sender, EventArgs e)
    {
        if (gvGrid.Rows.Count > 0)
        {
            gvGrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvGrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            var CustCol = ddlSaleBy.SelectedValue == "2" ? "Dealer" : "Distributor";
            var ParentCol = ddlSaleBy.SelectedValue == "4" ? "SuperStockist" : "Distributor";

            if (String.IsNullOrEmpty(txtFromMonth1.Text) || String.IsNullOrEmpty(txtToMonth1.Text) || String.IsNullOrEmpty(txtFromMonth2.Text) || String.IsNullOrEmpty(txtToMonth2.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                return;
            }
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (RegionID == 0 && CityID == 0 && SSID == 0 && DistributorID == 0 && DealerID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one parameter.',3);", true);
                return;
            }
            DateTime Fromdate1 = Convert.ToDateTime(txtFromMonth1.Text);
            DateTime Todate1 = Convert.ToDateTime(txtToMonth1.Text);
            DateTime Fromdate2 = Convert.ToDateTime(txtFromMonth2.Text);
            DateTime Todate2 = Convert.ToDateTime(txtToMonth2.Text);
            DateTime nTodate1 = new DateTime(Todate1.Year, Todate1.Month, DateTime.DaysInMonth(Todate1.Year, Todate1.Month));
            DateTime nTodate2 = new DateTime(Todate2.Year, Todate2.Month, DateTime.DaysInMonth(Todate2.Year, Todate2.Month));

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "DealerWiseGrowthSale";

            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@CityID", CityID);
            Cm.Parameters.AddWithValue("@Division", ddlDivision.SelectedValue);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@FromDate1", Fromdate1);
            Cm.Parameters.AddWithValue("@ToDate1", nTodate1);
            Cm.Parameters.AddWithValue("@FromDate2", Fromdate2);
            Cm.Parameters.AddWithValue("@ToDate2", nTodate2);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            string FD1 = Convert.ToDateTime(txtFromMonth1.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtFromMonth1.Text).Year.ToString();
            string TD1 = Convert.ToDateTime(txtToMonth1.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtToMonth1.Text).Year.ToString();
            string FD2 = Convert.ToDateTime(txtFromMonth2.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtFromMonth2.Text).Year.ToString();
            string TD2 = Convert.ToDateTime(txtToMonth2.Text).ToString("MMM") + " - " + Convert.ToDateTime(txtToMonth2.Text).Year.ToString();

            writer.WriteLine("Customer + Month Wise Sale Report,");
            writer.WriteLine("Month Duration From ," + FD1 + " - " + TD1 + ",");
            writer.WriteLine("To ," + FD2 + " - " + TD2 + ",");
            writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);

            writer.WriteLine("Sale By," + ddlSaleBy.SelectedItem.Text);
            writer.WriteLine(ParentCol + " Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
            writer.WriteLine(CustCol + " City ," + (CityID != 0 ? txtCity.Text.Split('-')[1].ToString() : "All City"));
            if (ddlSaleBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));
            writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
            if (ddlSaleBy.SelectedValue == "2")
                writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All Dealer"));
            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
            writer.WriteLine("User ," + UserName);
            writer.WriteLine("Created On ," + DateTime.Now);
            int rowcount = 0;
            do
            {
                writer.Write("SrNo,");
                writer.Write(ParentCol + " Code,");
                writer.Write(ParentCol + " Name,");
                writer.Write(ParentCol + " Region,");
                writer.Write(CustCol + " City,");
                writer.Write(CustCol + " Code,");
                writer.Write(CustCol + " Name,");
                writer.Write(CustCol + " Start Date,");
                writer.Write("Total Assets,");
                writer.Write(FD1 + " # " + TD1 + " Ltrs.,");
                writer.Write(FD1 + " # " + TD1 + " Value,");
                writer.Write(FD2 + " # " + TD2 + " Ltrs.,");
                writer.Write(FD2 + " # " + TD2 + " Value,");

                writer.WriteLine(string.Join(",", Enumerable.Range(13, reader.FieldCount - 13).Select(reader.GetName).ToList()));

                int count = 0;
                while (reader.Read())
                {
                    rowcount += 1;
                    writer.WriteLine(string.Join(",", Enumerable.Range(0, reader.FieldCount).Select(reader.GetValue).ToList()));
                    if (++count % 100 == 0)
                    {
                        writer.Flush();
                    }
                }
                if (rowcount == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found.',3);", true);
                    return;
                }
            }
            while (reader.NextResult());

            string filepath = "TransactionDetailData_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
            Response.AddHeader("content-disposition", "attachment;filename=" + filepath);
            Response.Output.Write(writer.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
}