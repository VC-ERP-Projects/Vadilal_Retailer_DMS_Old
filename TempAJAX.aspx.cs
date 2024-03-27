using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Threading;
using System.Web.UI.WebControls;
using AjaxControlToolkit;
using System.IO;
using System.Net;
using System.Data.Objects.SqlClient;
using System.Data.Objects.DataClasses;
using System.Data.Metadata.Edm;
using System.Data.Objects;
using System.Xml.Linq;
using System.Data;

public partial class TempAJAX : System.Web.UI.Page
{
    static string baseUri = "http://maps.googleapis.com/maps/api/geocode/xml?latlng={0},{1}&sensor=false";
    string location = string.Empty;

    public static string RetrieveFormatedAddress(string lat, string lng)
    {
        string requestUri = string.Format(baseUri, lat, lng);
        string city = "";
        using (WebClient wc = new WebClient())
        {
            string result = wc.DownloadString(requestUri);
            var xmlElm = XElement.Parse(result);
            var status = (from elm in xmlElm.Descendants()
                          where
                              elm.Name == "status"
                          select elm).FirstOrDefault();
            if (status.Value.ToLower() == "ok")
            {
                IEnumerable<XElement> resultElement = from rs in xmlElm.Elements("result") select rs;
                if (resultElement.FirstOrDefault() != null)
                {
                    IEnumerable<XElement> addressElement = from ad in resultElement.FirstOrDefault().Elements("address_component") select ad;
                    foreach (XElement element in addressElement)
                    {
                        IEnumerable<XElement> typeElement = from te in element.Elements("type") select te;
                        string type = typeElement.FirstOrDefault().Value;
                        if (type == "locality")
                        {
                            IEnumerable<XElement> cityElement = from ln in element.Elements("long_name") select ln;
                            city = cityElement.FirstOrDefault().Value;
                            break;
                        }
                    }
                }
            }
        }
        return city;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        var city = RetrieveFormatedAddress("40.7465136", "-73.9722245");

        DDMSEntities ctx = new DDMSEntities();

        var data = ctx.OSEQs.Select(x => EntityFunctions.TruncateTime(x.FromDate)).ToList();

        var properties = (from p in typeof(OCRD).GetProperties()
                          select p.Name).ToList();

        //var properties = CollectionExtensions.GetProperty(typeof(OCRD).GetProperties());

        //Type t = GetCoreType(property.PropertyType);
        //    if (t == typeof(Char) || t == typeof(Double) || t == typeof(Decimal) || t == typeof(String) || t == typeof(Boolean) || t == typeof(Int16) || t == typeof(Int32) || t == typeof(Int64) || t == typeof(DateTime) || t == typeof(DateTime) || t == typeof(TimeSpan))

        //where (from a in p.GetCustomAttributes(false)
        //                         where a is EdmScalarPropertyAttribute
        //                         select true).FirstOrDefault()

        var Path = "";
        var Drives = DriveInfo.GetDrives();
        if (Drives.Any(x => x.Name == "D:\\"))
            Path = @"D:\DDMS\DDMS_Balaji";
        else if (Drives.Any(x => x.Name == "E:\\"))
            Path = @"E:\DDMS\DDMS_Balaji";
        else if (Drives.Any(x => x.Name == "C:\\"))
            Path = @"C:\DDMS\DDMS_Balaji";
        else
        {
            var str = Drives.First().Name;
            Path = str + "DDMS\\DDMS_Balaji";
        }
        if (!Directory.Exists(Path))
        {
            Directory.CreateDirectory(Path);
        }



    }
    protected void btnsend_Click(object sender, EventArgs e)
    {

    }

    // #region variable Declaration
    //string dbcon = ConfigurationManager.ConnectionStrings["AdvWorks"].ConnectionString;
    //SqlConnection con;
    //SqlCommand cmd;
    //SqlDataAdapter da;
    //DataSet ds;
    //string pdfFile = "D:\\Testcrystal.pdf";
    //#endregion
    //protected void Page_Load(object sender, EventArgs e)
    //{
    //    if (!IsPostBack)
    //    {
    //        FillDropDown();
    //    }
    //}
    //public void FillDropDown()
    //{
    //    con = new SqlConnection(dbcon);
    //    da = new SqlDataAdapter("select * from Emp", con);
    //    ds = new DataSet();
    //    da.Fill(ds);
    //    for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
    //    {
    //        ddEmpcode.Items.Add(ds.Tables[0].Rows[i][0].ToString());
    //    }
    //}
    //protected void btnSubmit_Click(object sender, EventArgs e)
    //{
    //    ReportDocument crystalReport = new ReportDocument();
    //    try
    //    {
    //        crystalReport.Load(Server.MapPath("~/CrystalReport.rpt"));
    //        crystalReport.SetDatabaseLogon("username of Sql", "password of sql", "server name", "Database name");
    //        crystalReport.SetParameterValue("empid", ddEmpcode.Text);
    //        CrystalReportViewer1.ReportSource = crystalReport;
    //        crystalReport.ExportToDisk(ExportFormatType.PortableDocFormat, pdfFile);
    //        sendMail();
    //    }
    //    catch (Exception e1)
    //    {
    //        string script = "<script>alert('"+e1.Message+"')</script>";
    //        ClientScript.RegisterStartupScript(this.GetType(), "mailSent", script);
    //    }
    //}
    //private void sendMail()
    //{
    //    MailMessage msg = new MailMessage();
    //    try
    //    {
    //        msg.From = new MailAddress("email id from which the mail has to sent");
    //        msg.To.Add("email id which will receive the mail");
    //        msg.Body = "Employee Record";
    //        msg.Attachments.Add(new Attachment(pdfFile));
    //        msg.IsBodyHtml = true;
    //        msg.Subject = "Emp Data Report uptil " +DateTime.Now.ToString() + " date";
    //        SmtpClient smt = new SmtpClient("smtp.gmail.com");
    //        smt.Port = 587;
    //        smt.Credentials = new NetworkCredential("gmail email id", "gmail password");
    //        smt.EnableSsl = true;
    //        smt.Send(msg);
    //        string script = "<script>alert('Mail Sent Successfully')</script>";
    //        ClientScript.RegisterStartupScript(this.GetType(), "mailSent", script);
    //    }
    ////    catch (DbEntityValidationException ex)
    //    {
    //        foreach (var eve in ex.EntityValidationErrors)
    //        {
    //            Console.WriteLine("Entity of type \"{0}\" in state \"{1}\" has the following validation errors:",
    //                eve.Entry.Entity.GetType().Name, eve.Entry.State);
    //            foreach (var ve in eve.ValidationErrors)
    //            {
    //                Console.WriteLine("- Property: \"{0}\", Error: \"{1}\"",
    //                    ve.PropertyName, ve.ErrorMessage);
    //            }
    //        }
    //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
    //    }
    //    finally
    //    {

    //        msg.Dispose();
    //    }
    //}

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

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

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        var filepath = Server.MapPath("~/Document/POData/Log.txt");
        try
        {
            TraceService(filepath, "101 Started");
            var strdata = Directory.GetFiles(Server.MapPath("~/Document/POData/Data/"));

            foreach (string item in strdata)
            {
                TraceService(filepath, "201 File Started" + item);

                FileInfo f = new FileInfo(item);
                if (f.Extension == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    TransferCSVToTable(item, dtPOH);

                    TraceService(filepath, "202 row count" + dtPOH.Rows.Count.ToString());
                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        var maindata = (from row in dtPOH.AsEnumerable()
                                        where row.Field<string>(3).Trim() != ""
                                        select new
                                        {
                                            custcode = row.Field<string>(0).Trim(),
                                            invno = Convert.ToInt32(row.Field<string>(3).Trim()).ToString("D10"),
                                            orgcustcode = row.Field<string>(0),
                                            orginvo = row.Field<string>(3)
                                        }).Distinct().ToList();
                        foreach (var mainitem in maindata)
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                if (ctx.OCRDs.Any(x => x.CustomerCode == mainitem.custcode && x.Type == 2))
                                {
                                    Decimal cid = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == mainitem.custcode && x.Type == 2).CustomerID;

                                    var InwardData = ctx.OMIDs.Where(x => x.BillNumber == mainitem.invno && x.ParentID == cid && new int[] { 2, 3, 4 }.Contains(x.InwardType)).Select(x => new { x.InwardID, x.ParentID, x.BillNumber }).FirstOrDefault();
                                    if (InwardData != null)
                                    {
                                        var trpodata = dtPOH.Select("Assignment = '" + mainitem.orginvo + "' AND Soldtopt = '" + mainitem.orgcustcode + "'");
                                        var objMID1s = ctx.MID1.Where(x => x.InwardID == InwardData.InwardID && x.ParentID == InwardData.ParentID).ToList();

                                        if (objMID1s.Count == trpodata.Length)
                                        {
                                            foreach (var objMID1 in objMID1s)
                                            {
                                                var tritempodata = trpodata.CopyToDataTable().Select("Material = '" + objMID1.OITM.ItemCode + "'");
                                                if (tritempodata != null && tritempodata.Length == 1)
                                                {
                                                    objMID1.UnitPrice = Convert.ToDecimal(tritempodata.FirstOrDefault().Field<string>(6));
                                                    objMID1.Discount = Convert.ToDecimal(tritempodata.FirstOrDefault().Field<string>(7));
                                                    objMID1.FromWhsID = -1;
                                                }
                                                else
                                                {
                                                    TraceService(filepath, "352 no po item found or item count mismatch " + mainitem.invno);
                                                }
                                            }
                                            ctx.SaveChanges();
                                            TraceService(filepath, "355 completed " + mainitem.invno);
                                        }
                                        else
                                        {
                                            TraceService(filepath, "354 item count mismatch " + mainitem.invno);
                                        }
                                    }
                                    else
                                    {
                                        TraceService(filepath, "351 no po found " + mainitem.invno);
                                    }
                                }
                                else
                                {
                                    TraceService(filepath, "350 customer not found " + mainitem.invno);
                                }
                            }
                        }
                        TraceService(filepath, "203 File Completed" + item);
                    }
                    else
                    {
                        TraceService(filepath, "349 no record found");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            TraceService(filepath, "555 " + Common.GetString(ex));
        }
    }
}
