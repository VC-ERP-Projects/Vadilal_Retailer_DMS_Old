using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.IO;
using System.Net;
//using System.Device.Location;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System.Data.EntityClient;

public partial class Reports_OrderMap : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected DateTime Date;
    protected Int32 EmpID;
    protected string UserName;

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
                int CustType = Convert.ToInt32(Session["Type"]);
                 var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    UserName = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("employee_master");
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
        txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);

        txtCode.Text = "";
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
            if (Request.QueryString["EmpCode"] != null && Request.QueryString["Date"] != null)
            {
                btnGenerat_Click(sender, e);
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnPrintPDF);
    }

    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            if (Request.QueryString["EmpCode"] != null && Request.QueryString["Date"] != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string EmpCode = Request.QueryString["EmpCode"].ToString();
                    Date = Common.DateTimeConvert(Request.QueryString["Date"].ToString());

                    if (ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpCode == EmpCode))
                    {
                        EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == EmpCode).EmpID;
                        txtFromDate.Text = Date.ToShortDateString();
                        txtFromDate.Enabled = false;
                        var Emp = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault();
                        txtCode.Text = Emp + " - " + EmpID;
                        txtCode.Enabled = false;
                        txtCode.Attributes.Remove("style");
                    }
                }
            }
            else
            {
                EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
                if (!string.IsNullOrEmpty(txtCode.Text) && EmpID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                    return;
                }
                Date = Convert.ToDateTime(txtFromDate.Text);
            }

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "OrderOnMap";
            Cm.Parameters.AddWithValue("@Date", Date);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@SUserID", EmpID);
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    lblTotPrd.Text = ds.Tables[0].Rows[0][0].ToString();
                    lblTotNonPrd.Text = ds.Tables[0].Rows[0][1].ToString();
                    lblTotCall.Text = ds.Tables[0].Rows[0][2].ToString();

                    lblCallDur.Text = ds.Tables[0].Rows[0][3].ToString();
                    lblTransTime.Text = ds.Tables[0].Rows[0][4].ToString();
                    lblWorkHr.Text = ds.Tables[0].Rows[0][5].ToString();
                    lblLocTrack.Text = ds.Tables[0].Rows[0][6].ToString();
                }
                if (ds.Tables[1].Rows.Count > 0)
                {
                    var data = (from DataRow row in ds.Tables[1].Rows
                                select new
                                {
                                    lat = row["LAT"].ToString(),
                                    lng = row["LNG"].ToString(),
                                    desc = row["DESC"].ToString(),
                                    id = row["ID"].ToString(),
                                    color = row["COLOR"].ToString(),
                                    km = row["KM"].ToString()
                                }).ToList();

                    if (data.Count > 0)
                    {
                        lblSFATotDis.Text = data.Sum(x => Convert.ToDecimal(x.km)).ToString("0.00");
                        var jsonSerialiser = new JavaScriptSerializer();
                        var json = jsonSerialiser.Serialize(data);
                        ScriptManager.RegisterStartupScript(this.Page, Page.GetType(), "GoogleMap", "GMAP('" + json + "');", true);
                        if (Date > new DateTime(2019, 2, 14))
                        {
                            lblSFATotDis.Attributes.Remove("Style");
                            lblTotDis.Attributes.Add("Style", "display: none");
                        }
                        else
                        {
                            lblTotDis.Attributes.Remove("Style");
                            lblSFATotDis.Attributes.Add("Style", "display: none");
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found !',3);", true);
                        return;
                    }
                }
                ltrBrand.Text = "";
                if (ds.Tables[2].Rows.Count > 0)
                {
                    ltrBrand.Text = "<table class='table table-bordered table-responsive' style='font-weight: bold; font-size: 10px'><tr>";

                    foreach (DataRow item in ds.Tables[2].Rows)
                    {
                        ltrBrand.Text += "<td style='background-color: " + item[0] + ";'>" + item[1] + "</td>";
                    }
                    ltrBrand.Text += "</tr></table>";
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found !',3);", true);
                return;
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnPrintPDF_Click(object sender, EventArgs e)
    {
        try
        {
            ConnectionInfo myConnectionInfo = new ConnectionInfo();

            if (Request.QueryString["EmpCode"] != null && Request.QueryString["Date"] != null)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    string EmpCode = Request.QueryString["EmpCode"].ToString();
                    Date = Common.DateTimeConvert(Request.QueryString["Date"].ToString());

                    if (ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpCode == EmpCode))
                    {
                        EmpID = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpCode == EmpCode).EmpID;
                        txtFromDate.Text = Date.ToShortDateString();
                        txtFromDate.Enabled = false;
                        var Emp = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.EmpID == EmpID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault();
                        txtCode.Text = Emp + " - " + EmpID;
                        txtCode.Enabled = false;
                        txtCode.Attributes.Remove("style");
                    }
                }
            }
            else
            {
                EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
                if (!string.IsNullOrEmpty(txtCode.Text) && EmpID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                    return;
                }
                Date = Convert.ToDateTime(txtFromDate.Text);
            }

            ReportDocument myReport = new ReportDocument();
            myReport.Load(Server.MapPath("CrystalReports/GPSTracking.rpt"));
            myReport.SetParameterValue("@EmpID", UserID);
            myReport.SetParameterValue("@ParentID", ParentID);
            myReport.SetParameterValue("@LogoImage", Server.MapPath("~/Images/LOGO.jpg"));
            myReport.SetParameterValue("@Date", Date);
            myReport.SetParameterValue("@SUserID", EmpID);

            string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ToString();
            EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);

            Tables myTables = myReport.Database.Tables;
            foreach (CrystalDecisions.CrystalReports.Engine.Table myTable in myTables)
            {
                TableLogOnInfo myTableLogonInfo = myTable.LogOnInfo;
                myConnectionInfo.ServerName = builder.DataSource;
                myConnectionInfo.DatabaseName = builder.InitialCatalog;
                myConnectionInfo.UserID = "sa";
                myConnectionInfo.Password = builder.Password;
                myTableLogonInfo.ConnectionInfo = myConnectionInfo;
                myTable.ApplyLogOnInfo(myTableLogonInfo);
            }

            ExportOptions ep = new ExportOptions();
            ep.ExportFormatType = ExportFormatType.PortableDocFormat;
            myReport.ExportToHttpResponse(ep, Response, true, Path.GetFileNameWithoutExtension(myReport.FileName));

            //Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            //SqlCommand Cm = new SqlCommand();
            //Cm.Parameters.Clear();
            //Cm.CommandType = CommandType.StoredProcedure;
            //Cm.CommandText = "PRINTOrderOnMap";
            //Cm.Parameters.AddWithValue("@Date", Date);
            //Cm.Parameters.AddWithValue("@EmpID", UserID);
            //Cm.Parameters.AddWithValue("@SUserID", EmpID);
            //Cm.Parameters.AddWithValue("@ParentID", ParentID);
            //DataSet ds = objClass.CommonFunctionForSelect(Cm);
            //DataTable dt1 = ds.Tables[1];
            //DataTable dt2 = ds.Tables[0];

            //var TotDist = "0.00";
            //if (ds.Tables[1].Rows.Count > 0 && Date > new DateTime(2019, 2, 14))
            //{
            //    Decimal DecNum = 0;
            //    TotDist = (from DataRow row in ds.Tables[1].Rows
            //               select new
            //               {
            //                   km = (Decimal.TryParse(row["KM"].ToString(), out DecNum) ? DecNum : 0)
            //               }).Sum(x => x.km).ToString("0.00");
            //}

            //using (DDMSEntities ctx = new DDMSEntities())
            //{
            //    var path = Server.MapPath("~/Images/LOGO.jpg");
            //    string bodystr = "<p style='padding-top: 30px; padding-left: 30px;padding-right: 30px;font-family:Arial;'><br /><br />";
            //    bodystr += "<table width='100%' style='border-collapse:collapse;margin-top:5px;font-size:16px;font-family:Arial;'>";
            //    bodystr += "<tbody>";
            //    bodystr += "<tr>";
            //    bodystr += "<td><b>Employee :  </b>" + txtCode.Text.Split("-".ToArray())[0] + "-" + txtCode.Text.Split("-".ToArray())[1] + "</td>";
            //    bodystr += "<td rowspan='5' align='right'><img src='" + path + "'height='80' width='100'></td>";
            //    bodystr += "</tr>";
            //    bodystr += "<tr>";
            //    bodystr += "<td><b> Date : </b>" + txtFromDate.Text + " " + DateTime.Now.ToString("dddd") + "</td>";
            //    bodystr += "</tr>";
            //    bodystr += "<tr>";
            //    bodystr += "<td><b> User Name :  </b>" + UserName + "</td>";
            //    bodystr += "</tr>";
            //    bodystr += "<tr>";
            //    bodystr += "<td><b> Print Date :  </b>" + DateTime.Now.ToString("dd/MM/yy HH:mm") + "</td>";
            //    bodystr += "</tr>";
            //    bodystr += "</tbody>";
            //    bodystr += "</table>";

            //    bodystr += "<table border='1' style='border-collapse:collapse;margin-top:5px;font-size:11px;font-family:Arial;'>";
            //    bodystr += "<thead style='background-color:#a9a1a1; font-size:12px;font-family:Arial;'><tr>";
            //    bodystr += "<th width='2%'>Sr.No</th><th width='10%'>Date/Time</th><th width='13%'>Activity</th><th width='9%'>Lat</th>";
            //    bodystr += "<th width='9%'>Long</th><th width='30%'>Area</th><th width='3%'>KM</th><th width='24%'>Customer Code & Name</th></tr></thead>";
            //    bodystr += "<tbody>";

            //    for (int i = 0; i < dt1.Rows.Count; i++)
            //    {
            //        bodystr += "<tr>";
            //        for (int j = 0; j < dt1.Columns.Count; j++)
            //        {
            //            bodystr += "<td>";
            //            bodystr += dt1.Rows[i][j].ToString();
            //            bodystr += "</td>";
            //        }
            //        bodystr += "</tr>";
            //    }
            //    bodystr += "</tbody>";
            //    bodystr += "<tfoot style='background-color:#a9a1a1; font-size:11px;'><tr>";
            //    if (dt2.Rows.Count > 0)
            //        bodystr += "<td colspan=5>" + "PR Calls = " + dt2.Rows[0][0] + ",&emsp;&emsp;NPR Calls = " + dt2.Rows[0][1] + "&emsp;&emsp;Total Calls = " + dt2.Rows[0][2] + "&emsp;&emsp;Loc. Tracking = " + dt2.Rows[0][3] + "</td><td width='30%' align='right'>Total</td><td width='3%'>" + TotDist + "</td><td width='25%'></td></tr>";
            //    else
            //        bodystr += "<td colspan=5>" + "PR Calls = 0,&emsp;&emsp;NPR Calls = 0&emsp;&emsp;Total Calls = 0,&emsp;&emsp;Loc. Tracking = 0 </td><td width='30%' align='right'>Total</td><td width='3%'>" + TotDist + "</td><td width='25%'></td></tr>";
            //    bodystr += "</tfoot>";

            //    bodystr += "</table>";
            //    // instantiate a html to pdf converter object
            //    HtmlToPdf converter = new HtmlToPdf();
            //    // create a new pdf document converting an url
            //    PdfDocument doc = converter.ConvertHtmlString(bodystr, "");

            //    string file = "";
            //    Response.Clear();
            //    Response.Buffer = true;
            //    Response.ClearContent();

            //    string Emp = string.IsNullOrEmpty(txtCode.Text) ? (ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).EmpCode) : txtCode.Text.Split("-".ToArray())[0];
            //    if (Request.QueryString["EmpCode"] != null && Request.QueryString["Date"] != null)
            //        file = Request.QueryString["EmpCode"] + "_" + Request.QueryString["Date"] + ".pdf";
            //    else
            //        file = Emp + "_" + DateTime.Now.ToString("ddMMyyyyHHmmss") + ".pdf";

            //    string BaseDir = AppDomain.CurrentDomain.BaseDirectory;
            //    doc.Save(BaseDir + "Document\\PDF\\GPSTracking_" + file);

            //    // close pdf document
            //    doc.Close();
            //    try
            //    {
            //        string[] files = Directory.GetFiles(Server.MapPath("~/Document/PDF"));

            //        foreach (string tempfile in files)
            //        {
            //            FileInfo fi = new FileInfo(tempfile);
            //            if (fi.LastAccessTime < DateTime.Now.AddDays(-7))
            //                fi.Delete();
            //        }
            //    }
            //    catch (Exception)
            //    {
            //    }
            //    Response.AppendHeader("Content-Disposition", "attachment; filename=GPSTracking_" + file);
            //    Response.ContentType = "Application/pdf";
            //    Response.WriteFile(Server.MapPath("~/Document/PDF/GPSTracking_" + file));
            //    Response.Flush();
            //    Response.End();
            //}
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}