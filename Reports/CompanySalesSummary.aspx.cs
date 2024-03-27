using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_CompanySalesSummary : System.Web.UI.Page
{

    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected String LogoURL;
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
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);
                LogoURL = Common.GetLogo(ParentID);
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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
            var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            ddlDivsion.DataSource = Division;
            ddlDivsion.DataBind();
            ddlDivsion.Items.Insert(0, new ListItem("---Select---", "0"));

        }
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtDistCode.Text = txtDealerCode.Text = txtPlant.Text = txtRegion.Text = txtSSDistCode.Text = txtCode.Text = txtFromAmt.Text = txtToAmt.Text = "";
        gvDelearSummary.Visible = gvDistributorSummary.Visible = false;
        gvDelearSummary.DataSource = null;
        gvDelearSummary.DataBind();
        gvDistributorSummary.DataSource = null;
        gvDistributorSummary.DataBind();
        //txtDistCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
        //txtFromDate.Text = "01/08/2021";
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
                divPlant.Attributes.Add("style", "display:none;");
                divRegion.Attributes.Add("style", "display:none;");
                divEmpCode.Attributes.Add("style", "display:none;");
                divDealer.Attributes.Add("style", "display:none;");
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
            divPlant.Attributes.Add("style", "display:none;");
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExport);
    }

    #endregion

    #region GriedView Events

    protected void gvDelearSummary_PreRender(object sender, EventArgs e)
    {
        if (gvDelearSummary.Rows.Count > 0)
        {
            gvDelearSummary.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDelearSummary.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvDistributorSummary_PreRender(object sender, EventArgs e)
    {
        if (gvDistributorSummary.Rows.Count > 0)
        {
            gvDistributorSummary.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDistributorSummary.FooterRow.TableSection = TableRowSection.TableFooter;
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
            Decimal FromAmt = Decimal.TryParse(txtFromAmt.Text, out FromAmt) ? FromAmt : 0;
            Decimal ToAmt = Decimal.TryParse(txtToAmt.Text, out ToAmt) ? ToAmt : 0;

            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if ((EndDate - StartDate).TotalDays > 92)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Report should be run for Maximum 3 Months',3);", true);
                return;
            }
            if (CustType == 4)
            {
                SSID = ParentID;
                RegionID = PlantID = 0;
            }
            else if (CustType == 2)
            {
                DistributorID = ParentID;
                SSID = RegionID = PlantID = 0;
            }

            if (DistributorID == 0 && DealerID == 0 && PlantID == 0 && RegionID == 0 && SSID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }

            if (FromAmt < 0 || ToAmt < 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invalid Value',3);", true);
                return;
            }
            if (FromAmt > ToAmt)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('To Amount should be greater than From Amount',3);", true);
                return;
            }


            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CompanySalesSummary_Hierarchy_New";

            Cm.Parameters.AddWithValue("@ReportType", ddlReportType.SelectedValue);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@FromAmt", FromAmt);
            Cm.Parameters.AddWithValue("@ToAmt", ToAmt);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@DivsionId", ddlDivsion.SelectedValue);
            Cm.Parameters.AddWithValue("@OptionId", ddlOption.SelectedValue);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ddlReportType.SelectedValue == "0")
            {
                gvDelearSummary.DataSource = null;
                gvDelearSummary.DataBind();
                gvDelearSummary.Visible = false;
                gvDistributorSummary.Visible = true;
                gvDistributorSummary.DataSource = ds.Tables[0];
                gvDistributorSummary.DataBind();
                gvDistributorSummary.Visible = true;
            }
            else if (ddlReportType.SelectedValue == "1")
            {
                gvDistributorSummary.DataSource = null;
                gvDistributorSummary.DataBind();
                gvDistributorSummary.Visible = false;
                gvDelearSummary.Visible = true;
                gvDelearSummary.DataSource = ds.Tables[0];
                gvDelearSummary.DataBind();
                gvDelearSummary.Visible = true;
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal FromAmt = Decimal.TryParse(txtFromAmt.Text, out FromAmt) ? FromAmt : 0;
            Decimal ToAmt = Decimal.TryParse(txtToAmt.Text, out ToAmt) ? ToAmt : 0;

            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).Last().Trim(), out PlantID) ? PlantID : 0;
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            if (CustType == 4)
            {
                SSID = ParentID;
                RegionID = PlantID = 0;
            }
            else if (CustType == 2)
            {
                DistributorID = ParentID;
                SSID = RegionID = PlantID = 0;
            }

            if (DistributorID == 0 && DealerID == 0 && PlantID == 0 && RegionID == 0 && SSID == 0 && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);", true);
                return;
            }

            if (FromAmt < 0 || ToAmt < 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invalid Value',3);", true);
                return;
            }
            if (FromAmt > ToAmt)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('To Amount should be greater than From Amount',3);", true);
                return;
            }


            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CompanySalesSummary_Hierarchy_New";

            Cm.Parameters.AddWithValue("@ReportType", ddlReportType.SelectedValue);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@SSID", SSID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@PlantID", PlantID);
            Cm.Parameters.AddWithValue("@FromAmt", FromAmt);
            Cm.Parameters.AddWithValue("@ToAmt", ToAmt);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SaleBy", ddlSaleBy.SelectedValue);
            Cm.Parameters.AddWithValue("@DivsionId", ddlDivsion.SelectedValue);
            Cm.Parameters.AddWithValue("@OptionId", ddlOption.SelectedValue);
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            string DivisionName = ddlDivsion.SelectedValue.ToString() != "0" ? ddlDivsion.SelectedItem.ToString() : "ALL";

            writer.WriteLine("Distributor/Dealer wise Sales Summary ,");
            writer.WriteLine("From Date ," + txtFromDate.Text + ",");
            writer.WriteLine("To Date ," + txtToDate.Text);
            writer.WriteLine("Region ," + (RegionID != 0 ? txtRegion.Text.Split('-')[1].ToString() : "All Region"));
           // writer.WriteLine("Plant ," + (PlantID != 0 ? txtPlant.Text.Split('-')[0].ToString() + "," + txtPlant.Text.Split('-')[1].ToString() : "All Plant"));
            writer.WriteLine("Sale By ," + ddlSaleBy.SelectedItem.Text);
            if (ddlSaleBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist ," + (SSID != 0 ? txtSSDistCode.Text.Split('-')[0].ToString() + "," + txtSSDistCode.Text.Split('-')[1].ToString() : "All Super Stockist"));
            writer.WriteLine("Distributor ," + (DistributorID != 0 ? txtDistCode.Text.Split('-')[0].ToString() + "," + txtDistCode.Text.Split('-')[1].ToString() : "All Distributors"));
            if (ddlSaleBy.SelectedValue == "2")
                writer.WriteLine("Dealer ," + (DealerID != 0 ? txtDealerCode.Text.Split('-')[0].ToString() + "," + txtDealerCode.Text.Split('-')[1].ToString() : "All Dealer"));

            writer.WriteLine("Employee ," + (SUserID != 0 ? txtCode.Text.Split('-')[0].ToString() + "," + txtCode.Text.Split('-')[1].ToString() : ""));
            writer.WriteLine("Report Type ," + ddlReportType.SelectedItem.Text);
         //   writer.WriteLine("From Amount ," + txtFromAmt.Text);
          //  writer.WriteLine("To Amount ," + txtToAmt.Text);
            writer.WriteLine("Division ," + DivisionName);
            writer.WriteLine("Option ," + ddlOption.SelectedItem.ToString());
            writer.WriteLine("User Name ," + hdnUserName.Value);
            writer.WriteLine("Created on ," + DateTime.Now);

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

            string filepath = "DistributorDealerwiseSalesSummary_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv";
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

    #endregion
}
