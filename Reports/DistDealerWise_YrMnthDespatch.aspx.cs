using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DistDealerWise_YrMnthDespatch : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
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
                        {

                        }
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
        txtToDate.Text = txtFromDate.Text = DateTime.Now.Month.ToString() + '/' + DateTime.Now.Year.ToString();
        txtDistCode.Text = txtPlant.Text = txtRegion.Text = txtSSDistCode.Text = txtCode.Text = "";
        gvgrid.DataSource = null;
        gvgrid.DataBind();
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

            if (CustType == 4)
            {
                divPlant.Attributes.Add("style", "display:none;");
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "4";
                txtSSDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtSSDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
            else if (CustType == 2)
            {
                divPlant.Attributes.Add("style", "display:none;");
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                divSS.Attributes.Add("style", "display:none;");
                ddlSaleBy.SelectedValue = "2";
                txtDistCode.Enabled = ddlSaleBy.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);

    }
    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        DateTime Todate = Convert.ToDateTime(txtToDate.Text);

        if (DateTime.Compare(Todate, Fromdate) == -1)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('From Month should small then To Month',3);", true);
            return;
        }
        DateTime LstTodate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

        if ((LstTodate - Fromdate).TotalDays > 365)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
            return;
        }

        var ReportType = ddlReportOption.SelectedValue;
        Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
        Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue.ToString(), out DivisionID) ? DivisionID : 0;
        Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
        Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
            return;
        }
        if (DistributorID == 0 && PlantID == 0 && RegionID == 0 && SSID == 0 && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
            return;
        }

        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;

        Cm.CommandText = "GetYrMnthwiseDispatchSumm";
        Cm.Parameters.AddWithValue("@FromDate", Fromdate);
        Cm.Parameters.AddWithValue("@ToDate", LstTodate);
        Cm.Parameters.AddWithValue("@RegionID", RegionID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@Division", DivisionID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
        Cm.Parameters.AddWithValue("@ReportType", ReportType);
        Cm.Parameters.AddWithValue("@EmpID", UserID);
        Cm.Parameters.AddWithValue("@SUserID", SUserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);

        if (ds.Tables.Count > 0)
        {
            gvgrid.DataSource = ds.Tables[0];
        }

        gvgrid.DataBind();
    }

    #region GridviewEvent
    protected void gvgrid_PreRender(object sender, EventArgs e)
    {
        if (gvgrid.Rows.Count > 0)
        {
            gvgrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvgrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }

    }
    #endregion

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
            DateTime Todate = Convert.ToDateTime(txtToDate.Text);

            if (DateTime.Compare(Todate, Fromdate) == -1)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('From Month should small then To Month',3);", true);
                return;
            }
            DateTime LstTodate = new DateTime(Todate.Year, Todate.Month, DateTime.DaysInMonth(Todate.Year, Todate.Month));

            if ((LstTodate - Fromdate).TotalDays > 365)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Month Diffrence should be only 12 Months',3);", true);
                return;
            }

            var ReportType = ddlReportOption.SelectedValue;
            Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue.ToString(), out DivisionID) ? DivisionID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (DistributorID == 0 && PlantID == 0 && RegionID == 0 && SSID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;

            Cm.CommandText = "GetYrMnthwiseDispatchSumm";
            Cm.Parameters.AddWithValue("@FromDate", Fromdate);
            Cm.Parameters.AddWithValue("@ToDate", LstTodate);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@Division", DivisionID);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@ReportType", ReportType);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Distributor/Dealerwise + YrMon wise Sales ,");
            writer.WriteLine("From Month ," + txtFromDate.Text + ",");
            writer.WriteLine("To Month ," + txtToDate.Text);
            writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
            writer.WriteLine("Plant ," + (PlantID != 0 ? txtPlant.Text.Split('-')[0].ToString() + "," + txtPlant.Text.Split('-')[1].ToString() : "All Plant"));
            writer.WriteLine("Report Option ," + ddlReportOption.SelectedItem.Text);
            if (ddlSaleBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));

            if (ddlSaleBy.SelectedValue == "2")
                writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));

            writer.WriteLine("Division ," + ddlDivision.SelectedItem.Text);
            writer.WriteLine("SaleBy ," + ddlSaleBy.SelectedItem.Text);
            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
            writer.WriteLine("User ," + hdnUserName.Value);
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

            string filepath = "DistributorDealerwiseYrMonwiseSales_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
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