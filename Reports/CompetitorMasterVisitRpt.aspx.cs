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
using MigraDoc.Rendering;
using PdfSharp.Pdf;

public partial class Reports_CompetitorMasterVisitRpt : System.Web.UI.Page
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

    private void ClearAllInputs()
    {
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtCode.Text = txtRegion.Text = txtCreatedEmp.Text = txtBeatEmp.Text = txtDistCode.Text = txtCompetitorCode.Text = "";

        if (CustType == 2)// Distributor
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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            txtDistCode.Style.Add("background-color", "rgb(250, 255, 189);");
            //acetxtName.ContextKey = (CustType + 1).ToString();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Division = ctx.ODIVs.Where(x => x.Active).ToList();
                ddlDivision.DataSource = Division;
                ddlDivision.DataBind();
                ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
                txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
            }

            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
        //  scriptManager.RegisterPostBackControl(this.btnExpPDF);
        //txtFromDate.Text = new DateTime(2020, 12, 20).ToString("dd/MM/yyyy");

    }

    #endregion


    protected void btnGenerat_Click(object sender, EventArgs e)
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Your session time out. Please login again.',2);", true);
                return;
            }

            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            Int32 CompetitorID = Int32.TryParse(txtCompetitorCode.Text.Split("-".ToArray()).Last().Trim(), out CompetitorID) ? CompetitorID : 0;
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Int32 BeatEmpID = Int32.TryParse(txtBeatEmp.Text.Split("-".ToArray()).Last().Trim(), out BeatEmpID) ? BeatEmpID : 0;
            Int32 CreatedByEmpID = Int32.TryParse(txtCreatedEmp.Text.Split("-".ToArray()).Last().Trim(), out CreatedByEmpID) ? CreatedByEmpID : 0;

            if (SUserID == 0 && CompetitorID == 0 && RegionID == 0 && BeatEmpID == 0 && CreatedByEmpID == 0)
            {
                if ((ddlReport.SelectedValue == "1" && DistID == 0) || ddlReport.SelectedValue == "2" && DistID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one parameter.',3);ddlReportChange();", true);
                    return;
                }
            }

            string UserCode;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                UserCode = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "CompetitorMasterVisitRpt";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            Cm.Parameters.AddWithValue("@Type", ddlReport.SelectedValue);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@DistributorID", DistID);
            Cm.Parameters.AddWithValue("@CompetitorID", CompetitorID);
            Cm.Parameters.AddWithValue("@BeatEmpID", BeatEmpID);
            Cm.Parameters.AddWithValue("@CreatedBy", CreatedByEmpID);
            Cm.Parameters.AddWithValue("@RegionID", RegionID);
            Cm.Parameters.AddWithValue("@DivisionID", ddlDivision.SelectedValue);

            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            IDataReader reader = objClass.CommonFunctionForSelectDR(Cm);
            StringWriter writer = new StringWriter();
            if (ddlDivision.SelectedValue == "0")
                writer.WriteLine("Competitor Master Visit Report For All Division");
            else
                writer.WriteLine("Competitor Master Visit Report For "+ddlDivision.SelectedItem.Text);

            if (ddlReport.SelectedValue == "1")
                writer.WriteLine("Created Period From ," + StartDate.ToString("dd-MMM-yy") + "," + "To ," + EndDate.ToString("dd-MMM-yy"));
            else
                writer.WriteLine("Visited Period From ," + StartDate.ToString("dd-MMM-yy") + "," + "To ," + EndDate.ToString("dd-MMM-yy"));
            writer.WriteLine("Report Option," + (ddlReport.SelectedItem));
            writer.WriteLine("Employee," + ((txtCode.Text.Split('-').Length > 2) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : (txtCode.Text.Split('-').Length > 0 && txtCode.Text != "" && SUserID > 0) ? txtCode.Text : "All"));
            writer.WriteLine("Region of Competitor," + ((txtRegion.Text.Split('-').Length > 2) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : (txtRegion.Text.Split('-').Length > 0 && txtRegion.Text != "" && RegionID > 0) ? txtRegion.Text : "All"));
            if (ddlReport.SelectedValue == "1")
                writer.WriteLine("Created By," + ((txtCreatedEmp.Text.Split('-').Length > 2) ? txtCreatedEmp.Text.Split('-')[0].ToString() + "-" + txtCreatedEmp.Text.Split('-')[1].ToString() : (txtCreatedEmp.Text.Split('-').Length > 0 && txtCreatedEmp.Text != "" && CreatedByEmpID > 0) ? txtCreatedEmp.Text : "All"));
            else
                writer.WriteLine("Visited By," + ((txtCreatedEmp.Text.Split('-').Length > 2) ? txtCreatedEmp.Text.Split('-')[0].ToString() + "-" + txtCreatedEmp.Text.Split('-')[1].ToString() : (txtCreatedEmp.Text.Split('-').Length > 0 && txtCreatedEmp.Text != "" && CreatedByEmpID > 0) ? txtCreatedEmp.Text : "All"));

            writer.WriteLine("Beat Employee," + ((txtBeatEmp.Text.Split('-').Length > 2) ? txtBeatEmp.Text.Split('-')[0].ToString() + "-" + txtBeatEmp.Text.Split('-')[1].ToString() : (txtBeatEmp.Text.Split('-').Length > 0 && txtBeatEmp.Text != "" && BeatEmpID > 0) ? txtBeatEmp.Text : "All"));
            writer.WriteLine("Distributor," + ((txtDistCode.Text.Split('-').Length > 2) ? txtDistCode.Text.Split('-')[0].ToString() + "-" + txtDistCode.Text.Split('-')[1].ToString() : (txtDistCode.Text.Split('-').Length > 0 && txtDistCode.Text != "" && DistID > 0) ? txtDistCode.Text : "All"));

            writer.WriteLine("Competitor," + ((txtCompetitorCode.Text.Split('-').Length > 2) ? txtCompetitorCode.Text.Split('-')[0].ToString() + "-" + txtCompetitorCode.Text.Split('-')[1].ToString() : (txtCompetitorCode.Text.Split('-').Length > 0 && txtCompetitorCode.Text != "" && CompetitorID > 0) ? txtCompetitorCode.Text : "All"));
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

            Response.AddHeader("content-disposition", "attachment; filename=DataExport_Competitor_Master_Visit_Report" + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".csv");
            Response.ContentType = "application/txt";
            Response.Write(writer.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);ddlReportChange();", true);
        }
    }

    ////Not used currently due to taking much time to create pdf for large data.
    //protected void btnExpPDF_Click(object sender, EventArgs e)
    //{
    //    try
    //    {
    //        if (Session["UserID"] != null && Session["ParentID"] != null &&
    //        Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
    //        {
    //            Int32.TryParse(Session["UserID"].ToString(), out UserID);
    //            Decimal.TryParse(Session["ParentID"].ToString(), out ParentID);
    //        }

    //        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

    //        DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
    //        DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
    //        Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
    //        Int32 CompetitorID = Int32.TryParse(txtCompetitorCode.Text.Split("-".ToArray()).Last().Trim(), out CompetitorID) ? CompetitorID : 0;
    //        Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
    //        Int32 BeatEmpID = Int32.TryParse(txtBeatEmp.Text.Split("-".ToArray()).Last().Trim(), out BeatEmpID) ? BeatEmpID : 0;
    //        Int32 CreatedByEmpID = Int32.TryParse(txtCreatedEmp.Text.Split("-".ToArray()).Last().Trim(), out CreatedByEmpID) ? CreatedByEmpID : 0;

    //        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
    //        SqlCommand Cm = new SqlCommand();
    //        Cm.Parameters.Clear();
    //        Cm.CommandType = CommandType.StoredProcedure;
    //        Cm.CommandText = "CompetitorMasterVisitRpt";

    //        Cm.Parameters.AddWithValue("@ParentID", ParentID);
    //        Cm.Parameters.AddWithValue("@EmpID", UserID);
    //        Cm.Parameters.AddWithValue("@SUserID", SUserID);
    //        Cm.Parameters.AddWithValue("@Type", ddlReport.SelectedValue);
    //        Cm.Parameters.AddWithValue("@FromDate", StartDate);
    //        Cm.Parameters.AddWithValue("@ToDate", EndDate);
    //        Cm.Parameters.AddWithValue("@DistributorID", DistID);
    //        Cm.Parameters.AddWithValue("@CompetitorID", CompetitorID);
    //        Cm.Parameters.AddWithValue("@BeatEmpID", BeatEmpID);
    //        Cm.Parameters.AddWithValue("@CreatedBy", CreatedByEmpID);
    //        Cm.Parameters.AddWithValue("@RegionID", RegionID);

    //        Response.Clear();
    //        Response.Buffer = true;
    //        Response.ClearContent();
    //        DataSet ds = objClass.CommonFunctionForSelect(Cm);
    //        if (ds.Tables.Count > 0)
    //        {
    //            string strPeriod = "Visited Period From : " + StartDate.ToString("dd/MM/yyyy") + "  To : " + EndDate.ToString("dd/MM/yyyy");
    //            string strReportOption = "Report Option : " + (ddlReport.SelectedItem);
    //            string strEmployee = "Employee : " + ((SUserID > 0) ? txtCode.Text.Split('-')[0].ToString() + "-" + txtCode.Text.Split('-')[1].ToString() : " All");
    //            string strRegion = "Region of Competitor : " + ((RegionID > 0) ? txtRegion.Text.Split('-')[0].ToString() + "-" + txtRegion.Text.Split('-')[1].ToString() : " All");
    //            string strCreatedBy = "Visited By : " + ((CreatedByEmpID > 0) ? txtCreatedEmp.Text.Split('-')[0].ToString() + "-" + txtCreatedEmp.Text.Split('-')[1].ToString() : " All");
    //            string strBeatEmp = "Beat Employee : " + ((BeatEmpID > 0) ? txtBeatEmp.Text.Split('-')[0].ToString() + "-" + txtBeatEmp.Text.Split('-')[1].ToString() : " All");
    //            string strCompetitor = "Competitor : " + ((CompetitorID > 0) ? txtCompetitorCode.Text.Split('-')[0].ToString() + "-" + txtCompetitorCode.Text.Split('-')[1].ToString() : " All");
    //            string strUserID = string.Empty;
    //            using (DDMSEntities ctx = new DDMSEntities())
    //            {
    //                strUserID = "UserId : " + ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
    //            }
    //            PDFFormCreation pdfForm = new PDFFormCreation(ds.Tables[0], Server.MapPath("~/Images/logo.png"), "Competitor Master Visit Report", strPeriod, strReportOption, strEmployee, strRegion, strCreatedBy, strBeatEmp, strCompetitor, strUserID);

    //            MigraDoc.DocumentObjectModel.Document document = pdfForm.CreateDocument();
    //            document.UseCmykColor = true;

    //            PdfDocumentRenderer pdfRenderer = new PdfDocumentRenderer(false, PdfFontEmbedding.Always);
    //            pdfRenderer.Document = document;
    //            pdfRenderer.RenderDocument();
    //            if (!Directory.Exists(HttpContext.Current.Server.MapPath("~/Document/ReportPDF/Competitor/")))
    //            {
    //                Directory.CreateDirectory(HttpContext.Current.Server.MapPath("~/Document/ReportPDF/Competitor/"));
    //            }
    //            String fileName = "CompVisitReport" + "_" + DateTime.Now.ToString("ddMMyyyyHHmmss") + ".pdf";
    //            pdfRenderer.Save(Server.MapPath("~/Document/ReportPDF/Competitor/" + fileName));
    //            Response.AppendHeader("content-disposition", "attachment; filename=" + fileName);
    //            Response.ContentType = "application/octet-stream";
    //            ////Response.Write(pdfRenderer.ToString());
    //            Response.WriteFile(Server.MapPath("~/Document/ReportPDF/Competitor/" + fileName), false);
    //            //MemoryStream s = new MemoryStream();
    //            //pdfRenderer.PdfDocument.Save(s);
    //            //Response.BinaryWrite(s.ToArray());

    //            Response.Flush();
    //            Response.End();
    //        }
    //        //else
    //        //{
    //        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No data found!',3);", true);
    //        //}
    //    }
    //    catch (Exception ex)
    //    {
    //        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
    //    }
    //}
}