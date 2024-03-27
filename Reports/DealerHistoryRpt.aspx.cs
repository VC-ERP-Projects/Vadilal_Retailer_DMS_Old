using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DealerHistoryRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;

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

    private void ClearAllInputs()
    {
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        if (CustType == 4) // SS
        {
            divDealer.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "4";
            txtSSCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2) // Distributor
        {
            divSS.Attributes.Add("style", "display:none;");
            ddlReportBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlReportBy.Enabled = false;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
        }
        gvHistory.DataSource = null;
        gvHistory.DataBind();
        hdnCustNames.Value = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
        }

        //txtEmployee.Text = "21200420 - RASESH SHUKLA - 71";
        //txtFromDate.Text = "13/03/2021";
        //txtToDate.Text = "04/05/2021";
        //ddlRptType.SelectedValue = "2";
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnCustUpload);
        scriptManager.RegisterPostBackControl(this.btnExport);
        scriptManager.RegisterPostBackControl(this.btnEmpUpload);
    }

    #endregion
    #region GriedView Events
    protected void gvHistory_PreRender(object sender, EventArgs e)
    {
        if (gvHistory.Rows.Count > 0)
        {
            gvHistory.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvHistory.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    protected void gvMissdata_PreRender(object sender, EventArgs e)
    {
        if (gvMissdata.Rows.Count > 0)
        {
            gvMissdata.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdata.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            gvMissdata.DataSource = null;
            gvMissdata.DataBind();
            gvMissdata.Visible = false;
            gvHistory.Visible = true;
            gvHistory.DataSource = null;
            gvHistory.DataBind();
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 DlrEmpID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out DlrEmpID) ? DlrEmpID : 0;

            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

            Decimal CustomerID = ddlReportBy.SelectedValue == "3" ? DealerID : ddlReportBy.SelectedValue == "2" ? DistributorID : SSID;
            if (SUserID == 0 && DlrEmpID == 0 && DistributorID == 0 && DealerID == 0 && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one Employee / Customer',3);", true);
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ReportDealerHistory";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@IsStoredHry", (chkStoredHRY.Checked ? 1 : 0));
            Cm.Parameters.AddWithValue("@SUserID", ddlReportBy.SelectedValue == "3" ? DlrEmpID : SUserID);
            Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@ReportType", ddlRptType.SelectedValue);
            Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
            Cm.Parameters.AddWithValue("@UploadEmpID", 0);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                gvHistory.DataSource = ds.Tables[0];
            else
                gvHistory.DataSource = null;
            gvHistory.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #region TransferCSVToTable

    public static void TransferCSVToTable(string filePath, DataTable dt)
    {

        string[] csvRows = System.IO.File.ReadAllLines(filePath);
        string[] fields = null;
        bool head = true;
        foreach (string csvRow in csvRows)
        {
            if (head)
            {
                if (dt.Columns.Count == 0)
                {
                    fields = csvRow.Split(',');
                    foreach (string column in fields)
                    {
                        DataColumn datecolumn = new DataColumn(column);
                        datecolumn.AllowDBNull = true;
                        dt.Columns.Add(datecolumn);
                    }
                }
                head = false;
            }
            else
            {
                fields = csvRow.Split(',');
                DataRow row = dt.NewRow();
                row.ItemArray = new object[fields.Length];
                row.ItemArray = fields;
                dt.Rows.Add(row);
            }
        }

    }

    #endregion

    protected void btnCustUpload_Click(object sender, EventArgs e)
    {
        try
        {
            bool IsError = false;
            gvHistory.Visible = false;
            gvHistory.DataSource = null;
            gvHistory.DataBind();
            gvMissdata.Visible = false;
            gvMissdata.DataSource = null;
            gvMissdata.DataBind();

            DataTable DtMissData = new DataTable();
            DtMissData.Columns.Add("ErrorMsg");

            hdnCustNames.Value = "";

            if (CustCodeUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(CustCodeUpload.PostedFile.FileName));
                CustCodeUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(CustCodeUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtDATA = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtDATA);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    List<string> StrCust = new List<string>();
                    List<string> StrCustCode = new List<string>();

                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtDATA.Rows)
                            {
                                string CustCode = item["CustomerCode"].ToString().Trim(new char[] { ' ', '\'', '#' });
                                if (CustCode != "")
                                {
                                    var CustData = ctx.OCRDs.Where(x => x.CustomerCode == CustCode).Select(x => x.CustomerID).DefaultIfEmpty(0).FirstOrDefault();
                                    if (CustData > 0)
                                    {
                                        StrCustCode.Add(CustCode.Trim());
                                        StrCust.Add(CustData.ToString());
                                    }
                                    else
                                    {
                                        DataRow dr = DtMissData.NewRow();
                                        dr["ErrorMsg"] = CustCode + " code is invalid.";
                                        DtMissData.Rows.Add(dr);
                                        IsError = true;
                                    }
                                }
                            }
                        }
                    }
                    if (IsError)
                    {
                        gvMissdata.Visible = true;
                        gvMissdata.DataSource = DtMissData;
                        gvMissdata.DataBind();
                        return;
                    }

                    Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
                    Int32 DlrEmpID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out DlrEmpID) ? DlrEmpID : 0;

                    DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
                    DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

                    string CustomerIds = string.Join(",", StrCust);

                    if (CustomerIds.Length == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one Customer',3);", true);
                        return;
                    }
                    hdnCustNames.Value = string.Join(" # ", StrCustCode);
                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "ReportDealerHistory";

                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@IsStoredHry", (chkStoredHRY.Checked ? 1 : 0));
                    Cm.Parameters.AddWithValue("@SUserID", ddlReportBy.SelectedValue == "3" ? DlrEmpID : SUserID);
                    Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
                    Cm.Parameters.AddWithValue("@FromDate", StartDate);
                    Cm.Parameters.AddWithValue("@ToDate", EndDate);
                    Cm.Parameters.AddWithValue("@ReportType", ddlRptType.SelectedValue);
                    Cm.Parameters.AddWithValue("@CustomerID", CustomerIds);
                    Cm.Parameters.AddWithValue("@UploadEmpID", 0);

                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    gvHistory.Visible = true;
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        gvHistory.DataSource = ds.Tables[0];
                    else
                        gvHistory.DataSource = null;
                    gvHistory.DataBind();
                }

            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 DlrEmpID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out DlrEmpID) ? DlrEmpID : 0;

            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

            Decimal CustomerID = ddlReportBy.SelectedValue == "3" ? DealerID : ddlReportBy.SelectedValue == "2" ? DistributorID : SSID;
            if (SUserID == 0 && DlrEmpID == 0 && DistributorID == 0 && DealerID == 0 && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one Employee / Customer',3);", true);
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ReportDealerHistory";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@IsStoredHry", (chkStoredHRY.Checked ? 1 : 0));
            Cm.Parameters.AddWithValue("@SUserID", ddlReportBy.SelectedValue == "3" ? DlrEmpID : SUserID);
            Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@ReportType", ddlRptType.SelectedValue);
            Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();

            writer.WriteLine("Dealer Visit History Report");
            writer.WriteLine("Stored Hierarchy ," + chkStoredHRY.Checked);
            writer.WriteLine("From Date ," + StartDate.ToString("dd/MM/yy") + "," + "To Date ," + EndDate.ToString("dd/MM/yy"));
            writer.WriteLine("Option," + ddlReportBy.SelectedItem);

            if (ddlReportBy.SelectedValue == "3")
                writer.WriteLine("Employee," + (!string.IsNullOrEmpty(txtEmployee.Text) ? txtEmployee.Text.Split('-')[0].ToString() + "-" + txtEmployee.Text.Split('-')[1].ToString() : "All"));
            else
                writer.WriteLine("Employee," + (!string.IsNullOrEmpty(txtCode.Text) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : "All"));
            writer.WriteLine("Report Type," + ddlRptType.SelectedItem);
            if (ddlReportBy.SelectedValue == "4")
                writer.WriteLine("Super Stockist," + (!string.IsNullOrEmpty(txtSSCode.Text) ? txtSSCode.Text.Split('-')[0].ToString() + "-" + txtSSCode.Text.Split('-')[1].ToString() : "All"));
            else if (ddlReportBy.SelectedValue == "2")
                writer.WriteLine("Distributor," + (!string.IsNullOrEmpty(txtDistCode.Text) ? txtDistCode.Text.Split('-')[0].ToString() + "-" + txtDistCode.Text.Split('-')[1].ToString() : "All"));
            else if (ddlReportBy.SelectedValue == "3")
                writer.WriteLine("Dealer," + (!string.IsNullOrEmpty(txtDealerCode.Text) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : "All"));

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

            Response.AddHeader("content-disposition", "attachment; filename=Dealer_History_Report" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
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
    protected void btnEmpUpload_Click(object sender, EventArgs e)
    {
        try
        {
            bool IsError = false;
            gvHistory.Visible = false;
            gvHistory.DataSource = null;
            gvHistory.DataBind();
            gvMissdata.Visible = false;
            gvMissdata.DataSource = null;
            gvMissdata.DataBind();

            DataTable DtMissData = new DataTable();
            DtMissData.Columns.Add("ErrorMsg");

            if (CustCodeUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(CustCodeUpload.PostedFile.FileName));
                CustCodeUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(CustCodeUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtDATA = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtDATA);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    List<string> StrEmp = new List<string>();

                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtDATA.Rows)
                            {
                                string EmployeeCode = item["EmployeeCode"].ToString().Trim(new char[] { ' ', '\'', '#' });
                                if (EmployeeCode != "")
                                {
                                    var EmpData = ctx.OEMPs.Where(x => x.EmpCode == EmployeeCode).Select(x => x.EmpID).DefaultIfEmpty(0).FirstOrDefault();
                                    if (EmpData > 0)
                                    {
                                        StrEmp.Add(EmpData.ToString());
                                    }
                                    else
                                    {
                                        DataRow dr = DtMissData.NewRow();
                                        dr["ErrorMsg"] = EmployeeCode + " code is invalid.";
                                        DtMissData.Rows.Add(dr);
                                        IsError = true;
                                    }
                                }
                            }
                        }
                    }
                    if (IsError)
                    {
                        gvMissdata.Visible = true;
                        gvMissdata.DataSource = DtMissData;
                        gvMissdata.DataBind();
                        return;
                    }

                    Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
                    Int32 DlrEmpID = Int32.TryParse(txtEmployee.Text.Split("-".ToArray()).Last().Trim(), out DlrEmpID) ? DlrEmpID : 0;
                    DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
                    DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

                    string EmpIds = string.Join(",", StrEmp);

                    if (EmpIds.Length == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one Employee',3);", true);
                        return;
                    }
                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "ReportDealerHistory";

                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@IsStoredHry", (chkStoredHRY.Checked ? 1 : 0));
                    Cm.Parameters.AddWithValue("@SUserID", ddlReportBy.SelectedValue == "3" ? DlrEmpID : SUserID);
                    Cm.Parameters.AddWithValue("@ReportBy", ddlReportBy.SelectedValue);
                    Cm.Parameters.AddWithValue("@FromDate", StartDate);
                    Cm.Parameters.AddWithValue("@ToDate", EndDate);
                    Cm.Parameters.AddWithValue("@ReportType", ddlRptType.SelectedValue);
                    Cm.Parameters.AddWithValue("@CustomerID", 0);
                    Cm.Parameters.AddWithValue("@UploadEmpID", EmpIds);

                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    gvHistory.Visible = true;
                    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        gvHistory.DataSource = ds.Tables[0];
                    else
                        gvHistory.DataSource = null;
                    gvHistory.DataBind();
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
}