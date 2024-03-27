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

public partial class Reports_AssetHistoryReport : System.Web.UI.Page
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


    #endregion

    #region Pageload

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnAssetUpload);
        scriptManager.RegisterPostBackControl(this.btnDealerUpload);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlDivision.DataSource = ctx.ODIVs.Where(x => x.Active).Select(x => new { x.DivisionlID, x.DivisionName }).ToList();
                ddlDivision.DataTextField = "DivisionName";
                ddlDivision.DataValueField = "DivisionlID";
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
                ddlDivision.SelectedValue = "3";


                ddlAssetType.DataSource = ctx.OASTies.Where(x => x.Active).Select(x => new { x.AssetTypeID, x.AssetTypeName }).ToList();
                ddlAssetType.DataTextField = "AssetTypeName";
                ddlAssetType.DataValueField = "AssetTypeID";
                ddlAssetType.DataBind();
                ddlAssetType.Items.Insert(0, new ListItem("All", "0"));
            }
            txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);


            //Need to comment...
            //txtEmployee.Text = "21200420 - RASESH SHUKLA - 71";
            //txtFromDate.Text = "01/03/2021";
            ////txtToDate.Text = "04/05/2021";
            //txtInvGrAmtTO.Text = "10000";
            //ddlDivision.SelectedValue = "0";


        }
    }



    #endregion

    #region ButtonClick


    protected void btnDealerUpload_Click(object sender, EventArgs e)
    {
        try
        {
            gvMissdata.DataSource = null;
            gvMissdata.DataBind();
            gvMissdata.Visible = false;
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Session time out. Please login again.',3);OnChangeRefortFor();", true);
                return;
            }


            if (DealerCodeUpload.HasFile)
            {
                bool IsError = false;

                hdnDealerCodes.Value = "";
                DataTable DtMissData = new DataTable();
                DtMissData.Columns.Add("ErrorMsg");

                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/AssetHistory/DealerFiles")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/AssetHistory/DealerFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles/AssetHistory/DealerFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(DealerCodeUpload.PostedFile.FileName));
                DealerCodeUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(DealerCodeUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtDATA = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtDATA);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);OnChangeRefortFor();", true);
                        return;
                    }

                    List<string> StrCustCode = new List<string>();

                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtDATA.Rows)
                            {
                                string DealerCode = item["DealerCode"].ToString().Trim(new char[] { ' ', '\'', '#' });
                                var CustData = ctx.OCRDs.Where(x => x.CustomerCode == DealerCode && x.Type == 3).Select(x => x.CustomerCode).DefaultIfEmpty("").FirstOrDefault();
                                if (CustData != null && !string.IsNullOrWhiteSpace(CustData) && CustData.Length > 0)
                                {
                                    StrCustCode.Add(CustData.Trim());
                                }
                                else
                                {
                                    DataRow dr = DtMissData.NewRow();
                                    dr["ErrorMsg"] = DealerCode + " dealer code is invalid.";
                                    DtMissData.Rows.Add(dr);
                                    IsError = true;
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
                    else
                    {
                        gvMissdata.Visible = false;
                    }
                    string CustomerCodes = string.Join(",", StrCustCode);

                    if (CustomerCodes.Length == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one Dealer',3);OnChangeRefortFor();", true);
                        return;
                    }
                    hdnDealerCodes.Value = CustomerCodes;

                    Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
                    Int32 DistRegionId = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out DistRegionId) ? DistRegionId : 0;
                    DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
                    DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    Int32 InvoiceGrossAmtFrom = Int32.TryParse(txtInvGrAmtFr.Text.Trim(), out InvoiceGrossAmtFrom) ? InvoiceGrossAmtFrom : 0;
                    Int32 InvoiceGrossAmtTo = Int32.TryParse(txtInvGrAmtTO.Text.Trim(), out InvoiceGrossAmtTo) ? InvoiceGrossAmtTo : 0;
                    Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue.Trim(), out DivisionID) ? DivisionID : 0;
                    Int32 SaleType = Int32.TryParse(ddlSaleType.SelectedValue, out SaleType) ? SaleType : 0;
                    Int32 AssetType = Int32.TryParse(ddlAssetType.SelectedValue.Trim(), out AssetType) ? AssetType : 0;


                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "AssetHistory_Sales";
                    Cm.Parameters.AddWithValue("@SaleType", SaleType);
                    Cm.Parameters.AddWithValue("@AssetType", AssetType);
                    Cm.Parameters.AddWithValue("@DealerCode", hdnDealerCodes.Value);
                    Cm.Parameters.AddWithValue("@AssetCode", string.Empty);
                    Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
                    Cm.Parameters.AddWithValue("@DealerID", DealerID);
                    Cm.Parameters.AddWithValue("@FromDate", StartDate);
                    Cm.Parameters.AddWithValue("@ToDate", EndDate);
                    Cm.Parameters.AddWithValue("@RegionID", DistRegionId);
                    Cm.Parameters.AddWithValue("@InvoiceGrossAmtFrom", 0);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per zero so report will get all data
                    Cm.Parameters.AddWithValue("@InvoiceGrossAmtTo", 100000000);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per 10,00,00,000 so report will get all data
                    Cm.Parameters.AddWithValue("@Division", DivisionID);
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@SUserID", SUserID);

                    IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                    if (reader == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No data found.',3);OnChangeRefortFor();", true);
                        return;
                    }
                    Response.Clear();
                    Response.Buffer = true;
                    Response.ClearContent();
                    string UserCode;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        UserCode = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    }
                    StringWriter writer = new StringWriter();

                    writer.WriteLine("Customer + Asset wise Sales Report");
                    writer.WriteLine("Sale/Deposit Option," + (ddlSaleType.SelectedItem.Text));
                    writer.WriteLine("Asset Type," + (ddlAssetType.SelectedItem.Text));
                    writer.WriteLine("Employee," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
                    writer.WriteLine("Distributor Region," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && DistRegionId > 0) ? txtRegion.Text : "All"));
                    writer.WriteLine("Distributor," + ((txtDistCode.Text.Split('-').Length > 2) ? txtDistCode.Text.Split('-')[0].ToString() + "-" + txtDistCode.Text.Split('-')[1].ToString() : (txtDistCode.Text.Split('-').Length > 0 && txtDistCode.Text != "" && DistributorID > 0) ? txtDistCode.Text : "All"));
                    writer.WriteLine("Dealer," + ((txtDealerCode.Text.Split('-').Length > 2) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : (txtDealerCode.Text.Split('-').Length > 0 && txtDealerCode.Text != "" && DealerID > 0) ? txtDealerCode.Text : "All"));
                    writer.WriteLine("Division," + (ddlDivision.SelectedValue == "0" ? "All" : ddlDivision.SelectedItem.Text));
                    writer.WriteLine("Inv. Date From,'" + StartDate.ToString("dd-MMM-yy") + "," + " To Date ,'" + EndDate.ToString("dd-MMM-yy"));
                    //writer.WriteLine("Inv. Gross Amt. From," + InvoiceGrossAmtFrom + "," + " To Date ," + InvoiceGrossAmtTo);
                    writer.WriteLine("Report For," + ddlReportFor.SelectedItem.Text);
                    writer.WriteLine("Selected Dealers," + CustomerCodes.Replace(",", " # "));

                    writer.WriteLine("User ID," + UserCode);
                    writer.WriteLine("Run Date/Time,'" + DateTime.Now.ToString("dd-MMM-yy HH:mm"));
                    writer.WriteLine("IP Address," + ((hdnIPAdd.Value == "undefined") ? "" : hdnIPAdd.Value));

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

                    Response.AddHeader("content-disposition", "attachment; filename=Asset_History_Report_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
                    Response.ContentType = "application/txt";
                    Response.Write(writer.ToString());
                    Response.Flush();
                    Response.End();

                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);OnChangeRefortFor();", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);OnChangeRefortFor();", true);
        }
    }
    protected void btnAssetUpload_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Session time out. Please login again.',3);OnChangeRefortFor();", true);
                return;
            }


            if (AssetCodeUpload.HasFile)
            {
                bool IsError = false;
                gvMissdata.DataSource = null;
                gvMissdata.DataBind();
                hdnAssetCodes.Value = "";
                DataTable DtMissData = new DataTable();
                DtMissData.Columns.Add("ErrorMsg");

                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/AssetHistory/AssetFiles")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/AssetHistory/AssetFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles/AssetHistory/AssetFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(DealerCodeUpload.PostedFile.FileName));
                AssetCodeUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(AssetCodeUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtDATA = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtDATA);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);OnChangeRefortFor();", true);
                        return;
                    }

                    List<string> StrAssetCode = new List<string>();

                    if (dtDATA != null && dtDATA.Rows != null && dtDATA.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtDATA.Rows)
                            {
                                string AssetCode = item["AssetSerialNumber"].ToString().Trim(new char[] { ' ', '\'', '#' });
                                var AssetData = ctx.OASTs.Where(x => x.SerialNumber == AssetCode.Trim()).Select(x => x.SerialNumber).DefaultIfEmpty("").FirstOrDefault();
                                if (AssetData != null && !string.IsNullOrWhiteSpace(AssetData) && AssetData.Length > 0)
                                {
                                    StrAssetCode.Add(AssetData.Trim());
                                }
                                else
                                {
                                    DataRow dr = DtMissData.NewRow();
                                    dr["ErrorMsg"] = AssetCode + " Asset Serial Number is invalid.";
                                    DtMissData.Rows.Add(dr);
                                    IsError = true;
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
                    else
                    {
                        gvMissdata.Visible = false;
                    }

                    string AssetCodes = string.Join(",", StrAssetCode);

                    if (AssetCodes.Length == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one asset',3);OnChangeRefortFor();", true);
                        return;
                    }
                    hdnAssetCodes.Value = AssetCodes;

                    Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
                    Int32 DistRegionId = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out DistRegionId) ? DistRegionId : 0;
                    DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
                    DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    Int32 InvoiceGrossAmtFrom = Int32.TryParse(txtInvGrAmtFr.Text.Trim(), out InvoiceGrossAmtFrom) ? InvoiceGrossAmtFrom : 0;
                    Int32 InvoiceGrossAmtTo = Int32.TryParse(txtInvGrAmtTO.Text.Trim(), out InvoiceGrossAmtTo) ? InvoiceGrossAmtTo : 0;
                    Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue.Trim(), out DivisionID) ? DivisionID : 0;
                    Int32 SaleType = Int32.TryParse(ddlSaleType.SelectedValue, out SaleType) ? SaleType : 0;
                    Int32 AssetType = Int32.TryParse(ddlAssetType.SelectedValue.Trim(), out AssetType) ? AssetType : 0;


                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "AssetHistory_Sales";
                    Cm.Parameters.AddWithValue("@SaleType", SaleType);
                    Cm.Parameters.AddWithValue("@AssetType", AssetType);
                    Cm.Parameters.AddWithValue("@DealerCode", string.Empty);
                    Cm.Parameters.AddWithValue("@AssetCode", hdnAssetCodes.Value);
                    Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
                    Cm.Parameters.AddWithValue("@DealerID", DealerID);
                    Cm.Parameters.AddWithValue("@FromDate", StartDate);
                    Cm.Parameters.AddWithValue("@ToDate", EndDate);
                    Cm.Parameters.AddWithValue("@RegionID", DistRegionId);
                    Cm.Parameters.AddWithValue("@InvoiceGrossAmtFrom", 0);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per zero so report will get all data
                    Cm.Parameters.AddWithValue("@InvoiceGrossAmtTo", 100000000);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per 10,00,00,000 so report will get all data
                    Cm.Parameters.AddWithValue("@Division", DivisionID);
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@EmpID", UserID);
                    Cm.Parameters.AddWithValue("@SUserID", SUserID);

                    IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
                    if (reader == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No data found.',3);OnChangeRefortFor();", true);
                        return;
                    }
                    Response.Clear();
                    Response.Buffer = true;
                    Response.ClearContent();
                    string UserCode;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        UserCode = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    }
                    StringWriter writer = new StringWriter();

                    writer.WriteLine("Customer + Asset wise Sales Report");
                    writer.WriteLine("Sale/Deposit Option," + (ddlSaleType.SelectedItem.Text));
                    writer.WriteLine("Asset Type," + (ddlAssetType.SelectedItem.Text));
                    writer.WriteLine("Employee," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
                    writer.WriteLine("Distributor Region," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && DistRegionId > 0) ? txtRegion.Text : "All"));
                    writer.WriteLine("Distributor," + ((txtDistCode.Text.Split('-').Length > 2) ? txtDistCode.Text.Split('-')[0].ToString() + "-" + txtDistCode.Text.Split('-')[1].ToString() : (txtDistCode.Text.Split('-').Length > 0 && txtDistCode.Text != "" && DistributorID > 0) ? txtDistCode.Text : "All"));
                    writer.WriteLine("Dealer," + ((txtDealerCode.Text.Split('-').Length > 2) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : (txtDealerCode.Text.Split('-').Length > 0 && txtDealerCode.Text != "" && DealerID > 0) ? txtDealerCode.Text : "All"));
                    writer.WriteLine("Division," + (ddlDivision.SelectedValue == "0" ? "All" : ddlDivision.SelectedItem.Text));
                    writer.WriteLine("Inv. Date From,'" + StartDate.ToString("dd-MMM-yy") + "," + " To Date ,'" + EndDate.ToString("dd-MMM-yy"));
                    //writer.WriteLine("Inv. Gross Amt. From," + InvoiceGrossAmtFrom + "," + " To Date ," + InvoiceGrossAmtTo);
                    writer.WriteLine("Report For," + ddlReportFor.SelectedItem.Text);
                    writer.WriteLine("Selected Assets," + AssetCodes.Replace(",", " # "));

                    writer.WriteLine("User ID," + UserCode);
                    writer.WriteLine("Run Date/Time,'" + DateTime.Now.ToString("dd-MMM-yy HH:mm"));
                    writer.WriteLine("IP Address," + ((hdnIPAdd.Value == "undefined") ? "" : hdnIPAdd.Value));

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

                    Response.AddHeader("content-disposition", "attachment; filename=Asset_History_Report_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
                    Response.ContentType = "application/txt";
                    Response.Write(writer.ToString());
                    Response.Flush();
                    Response.End();

                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);OnChangeRefortFor();", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);OnChangeRefortFor();", true);
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            gvMissdata.Visible = false;
            if (Session["UserID"] != null && Session["ParentID"] != null &&
            Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
            {
                Int32.TryParse(Session["UserID"].ToString(), out UserID);
                Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Session time out. Please login again.',3);OnChangeRefortFor();", true);
                return;
            }

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 DistRegionId = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out DistRegionId) ? DistRegionId : 0;
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
            Decimal DistributorID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
            Int32 InvoiceGrossAmtFrom = Int32.TryParse(txtInvGrAmtFr.Text.Trim(), out InvoiceGrossAmtFrom) ? InvoiceGrossAmtFrom : 0;
            Int32 InvoiceGrossAmtTo = Int32.TryParse(txtInvGrAmtTO.Text.Trim(), out InvoiceGrossAmtTo) ? InvoiceGrossAmtTo : 0;
            Int32 DivisionID = Int32.TryParse(ddlDivision.SelectedValue.Trim(), out DivisionID) ? DivisionID : 0;
            Int32 SaleType = Int32.TryParse(ddlSaleType.SelectedValue, out SaleType) ? SaleType : 0;
            Int32 AssetType = Int32.TryParse(ddlAssetType.SelectedValue.Trim(), out AssetType) ? AssetType : 0;

            if (SUserID == 0 && DistRegionId == 0 && DealerID == 0 && DistributorID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select some more parameters.',3);OnChangeRefortFor();", true);
                return;
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "AssetHistory_Sales";
            Cm.Parameters.AddWithValue("@SaleType", SaleType);
            Cm.Parameters.AddWithValue("@AssetType", AssetType);
            Cm.Parameters.AddWithValue("@DealerCode", "");
            Cm.Parameters.AddWithValue("@AssetCode", "");
            Cm.Parameters.AddWithValue("@DistributorID", DistributorID);
            Cm.Parameters.AddWithValue("@DealerID", DealerID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@RegionID", DistRegionId);
            Cm.Parameters.AddWithValue("@InvoiceGrossAmtFrom", 0);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per zero so report will get all data
            Cm.Parameters.AddWithValue("@InvoiceGrossAmtTo", 100000000);  ///As per T900007039 # New Report - Customer + Assetwise Sales Report ---amount as per 10,00,00,000 so report will get all data
            Cm.Parameters.AddWithValue("@Division", DivisionID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            string UserCode;
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            if (reader == null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No data found.',3);OnChangeRefortFor();", true);
                return;
            }

            using (DDMSEntities ctx = new DDMSEntities())
            {
                UserCode = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
            }
            StringWriter writer = new StringWriter();

            writer.WriteLine("Customer + Asset wise Sales Report");
            writer.WriteLine("Sale/Deposit Option," + (ddlSaleType.SelectedItem.Text));
            writer.WriteLine("Asset Type," + (ddlAssetType.SelectedItem.Text));
            writer.WriteLine("Employee," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
            writer.WriteLine("Distributor Region," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && DistRegionId > 0) ? txtRegion.Text : "All"));
            writer.WriteLine("Distributor," + ((txtDistCode.Text.Split('-').Length > 2) ? txtDistCode.Text.Split('-')[0].ToString() + "-" + txtDistCode.Text.Split('-')[1].ToString() : (txtDistCode.Text.Split('-').Length > 0 && txtDistCode.Text != "" && DistributorID > 0) ? txtDistCode.Text : "All"));
            writer.WriteLine("Dealer," + ((txtDealerCode.Text.Split('-').Length > 2) ? txtDealerCode.Text.Split('-')[0].ToString() + "-" + txtDealerCode.Text.Split('-')[1].ToString() : (txtDealerCode.Text.Split('-').Length > 0 && txtDealerCode.Text != "" && DealerID > 0) ? txtDealerCode.Text : "All"));
            writer.WriteLine("Division," + (ddlDivision.SelectedValue == "0" ? "All" : ddlDivision.SelectedItem.Text));
            writer.WriteLine("Inv. Date From,'" + StartDate.ToString("dd-MMM-yy") + "," + " To Date ,'" + EndDate.ToString("dd-MMM-yy"));
            //writer.WriteLine("Inv. Gross Amt. From," + InvoiceGrossAmtFrom + "," + " To Amt ," + InvoiceGrossAmtTo);
            writer.WriteLine("Report For," + ddlReportFor.SelectedItem.Text);
            //writer.WriteLine("Selected Dealers," + CustomerCodes.Replace(",", " # "));

            writer.WriteLine("User ID," + UserCode);
            writer.WriteLine("Run Date/Time,'" + DateTime.Now.ToString("dd-MMM-yy HH:mm"));
            writer.WriteLine("IP Address," + ((hdnIPAdd.Value == "undefined") ? "" : hdnIPAdd.Value));

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

            Response.AddHeader("content-disposition", "attachment; filename=Asset_History_Report_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();


        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }


    #endregion
    #region GriedView Events

    protected void gvMissdata_PreRender(object sender, EventArgs e)
    {
        if (gvMissdata.Rows.Count > 0)
        {
            gvMissdata.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMissdata.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region TransferCSVToTable
    public static void TransferCSVToTable(string filePath, DataTable dt)
    {
        try
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
        catch (Exception ex)
        {

        }
    }
    #endregion
}