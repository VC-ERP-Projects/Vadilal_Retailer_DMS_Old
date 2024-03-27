using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.EntityClient;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Hosting;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Test : System.Web.UI.Page
{
    [Serializable]
    public class NoSaleMsg
    {
        public int ScheduleID { get; set; }
        public string MessageTo { get; set; }
        public decimal SendToID { get; set; }
        public int LastInvDay { get; set; }
        public string Phone { get; set; }
        public DateTime NextDate { get; set; }
    }
    public class WhatsAppBusinessMsg
    {
        public int OWPMID { get; set; }
        public string Phone { get; set; }
        public string ImageUpload { get; set; }

    }
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

    protected void btnSendMail_Click(object sender, EventArgs e)
    {
        Decimal ParentID = 1000010000000000;

        string BaseDir = AppDomain.CurrentDomain.BaseDirectory;

        string strPath = BaseDir + "Document\\log.txt";

        TraceService(strPath, "Code Start : " + DateTime.Now);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            SqlConnection sConnection = ((SqlConnection)ctx.Database.Connection);
            try
            {
                OEML objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == ParentID);
                if (objOEML != null)
                {
                    var objEML1 = ctx.EML1.Where(x => x.Active && x.EmailID == 10 && x.ParentID == ParentID).Select(x => x.EmailID).ToList();
                    if (objEML1 != null && objEML1.Count > 0)
                    {
                        var objEEML = ctx.EEMLs.Where(x => x.EmailID == 10 && x.ParentID == ParentID && x.Active).ToList();

                        if (objEEML != null && objEEML.Count > 0)
                        {
                            if (sConnection != null && sConnection.State == ConnectionState.Closed)
                                sConnection.Open();

                            DateTime date = DateTime.Now;
                            foreach (EEML item in objEEML)
                            {
                                try
                                {
                                    if (date.Year >= item.NextDate.Year && date.Month >= item.NextDate.Month && date.Day >= item.NextDate.Day && date.TimeOfDay >= item.FreqTime)
                                    {
                                        item.NextDate = date.AddDays(item.FreqDay);
                                        DataTable dt = new DataTable();
                                        SqlDataAdapter com = new SqlDataAdapter(item.SQLQuery, sConnection);
                                        com.Fill(dt);
                                        try
                                        {
                                            List<string> uniquedrw = dt.AsEnumerable().Select(r => r.Field<string>("ToMail")).Distinct().ToList();


                                            foreach (string uniqemail in uniquedrw)
                                            {
                                                DataTable filterdt = dt.Select("ToMail = '" + uniqemail + "'").CopyToDataTable();

                                                MailMessage message = new MailMessage();
                                                message.From = new MailAddress(objOEML.Email);

                                                message.CC.Add(ctx.OSETs.FirstOrDefault(x => x.KeyName == "dmsemptybeatmailsend").Value);
                                                message.Subject = "Beat Creation";
                                                message.To.Add(uniqemail);
                                                SmtpClient client = new SmtpClient();
                                                client.Host = objOEML.Domain;
                                                client.Port = Convert.ToInt32(objOEML.Port);
                                                client.UseDefaultCredentials = true;
                                                client.EnableSsl = false;
                                                if (!string.IsNullOrEmpty(objOEML.UserName))
                                                    client.Credentials = new System.Net.NetworkCredential(objOEML.UserName, objOEML.Password);
                                                else
                                                    client.Credentials = new System.Net.NetworkCredential(objOEML.Email, objOEML.Password);

                                                string bodystr = "Dear Sir, <br /><br /> Beat not available for following dealers so, please arrange for Beat Creation for the same. <br /> <br />";
                                                bodystr += "<table border='1' style='border-collapse:collapse;margin-top:5px' width='100%'>";
                                                bodystr += "<thead style='background-color:#E6E6E6; font-size:12px;'><tr>";
                                                bodystr += "<th width='3%'>Sr No</th><th width='6%'>Dealer Code</th><th width='30%'>Name</th><th width='13%'>City</th><th width='4%'>Boxes</th><th width='8%'>Gross Amount</th><th width='6%'>Dist. Code</th><th width='30%'>Dist. Name</th></tr></thead>";
                                                bodystr += "<tbody>";

                                                int Qty = 0;
                                                Decimal Amount = 0;
                                                int k = 1;
                                                for (int i = 0; i < filterdt.Rows.Count; i++)
                                                {
                                                    bodystr += "<tr ><td align='right' style='font-size:11px;'>" + (k++).ToString() + "</td>";

                                                    Qty += Int32.TryParse(filterdt.Rows[i][3].ToString(), out Qty) ? Qty : 0;
                                                    Amount += Decimal.TryParse(filterdt.Rows[i][4].ToString(), out Amount) ? Amount : 0;

                                                    for (int j = 0; j < 7; j++)
                                                    {
                                                        if (j == 3 || j == 4)
                                                        {
                                                            bodystr += "<td align='right' style='font-size:11px;' >";
                                                            bodystr += filterdt.Rows[i][j].ToString();
                                                            bodystr += "</td >";
                                                        }
                                                        else
                                                        {
                                                            bodystr += "<td style='font-size:11px'>";
                                                            bodystr += filterdt.Rows[i][j].ToString();
                                                            bodystr += "</td >";
                                                        }
                                                    }
                                                    bodystr += "</tr >";
                                                }
                                                bodystr += "<tr><td></td><td></td><td></td><td style='font-size:11px;'>Total</td><td align='right' style='font-size:11px;'>" + Qty.ToString() + "</td><td align='right' style='font-size:11px;'>" + Amount.ToString() + "</td><td></td><td></td></tr >";

                                                bodystr += "</tbody>";
                                                bodystr += "</table>";
                                                bodystr += "<br /><br /> Thanks & Regards, <br /> Team DMS.";

                                                message.Body = bodystr;
                                                message.IsBodyHtml = true;
                                                client.Send(message);

                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            TraceService(strPath, "Error in sending mail @ " + Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                        }
                                    }
                                    ctx.SaveChanges();
                                }
                                catch (Exception ex)
                                {
                                    TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                }
                            }
                            TraceService(strPath, "Process Completed. @ " + DateTime.Now.ToString());
                        }
                        else
                            TraceService(strPath, "No Email Query found @ " + DateTime.Now.ToString());
                    }
                    else
                        TraceService(strPath, "No Mapping found @ " + DateTime.Now.ToString());
                }
                else
                    TraceService(strPath, "No Email Setting " + DateTime.Now.ToString());
            }
            catch (Exception ex)
            {
                TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
            }
            finally
            {
                sConnection.Close();
            }
        }
    }

    protected void btnAutoCancel_Click(object sender, EventArgs e)
    {
        string BaseDir = AppDomain.CurrentDomain.BaseDirectory;

        string strPath = BaseDir + "Document\\log.txt";

        TraceService(strPath, "Code Start : " + DateTime.Now);

        using (DDMSEntities ctx = new DDMSEntities())
        {
            SqlConnection sConnection = ((SqlConnection)ctx.Database.Connection);
            try
            {
                var objOpenOrder = ctx.ORDRs.Where(x => x.OrderType == (int)SaleOrderType.Order).ToList();
                var objCancelOrder = objOpenOrder.Where(x => x.Date.AddDays(4) <= DateTime.Now).ToList();
                foreach (var item in objCancelOrder)
                {
                    item.OrderType = (int)SaleOrderType.Cancel;
                    item.UpdatedDate = DateTime.Now;
                    item.UpdatedBy = 1;
                    item.CancelBy = 1;
                    item.CancelDate = DateTime.Now;
                    item.CancelFlag = CancelFlag.AUTO.ToString();
                }
                ctx.SaveChanges();
            }
            catch (Exception ex)
            {
                TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
            }
            finally
            {
                sConnection.Close();
            }
        }
    }

    public static string Interact(string Msg, string Destination)
    {
        string result = "";
        var client1 = new RestClient(@"https://api.gupshup.io/sm/api/v1/app/opt/in/VCERP101");
        var request1 = new RestRequest(Method.POST);
        request1.AddHeader("Content-Type", "application/x-www-form-urlencoded");
        request1.AddHeader("apikey", "deda323c6a144669c67ee4f0489ea398");
        request1.AddParameter("user", "91" + Destination);

        IRestResponse response1 = client1.Execute(request1);
        if (response1.StatusCode.ToString() == "Accepted")
        {
        }

        var client = new RestClient(@"https://api.gupshup.io/sm/api/v1/msg");
        var request = new RestRequest(Method.POST);
        request.AddHeader("Content-Type", "application/x-www-form-urlencoded");
        request.AddHeader("apikey", "deda323c6a144669c67ee4f0489ea398");
        request.AddHeader("cache-control", "no-cache");
        request.AddParameter("channel", "whatsapp");
        request.AddParameter("source", "919512000149");
        request.AddParameter("destination", "91" + Destination);
        //request.AddParameter("message", "{'type':'text','text':'Your transaction was completed successfully.'}");
        string FUrl = "http://dmsqa.vadilalgroup.com/Document/WhatsAppAPI/SalesInv/56013_20012021062907.pdf";
        //string Ffilename = "Balaji Wafers # 21365232";
        string Ffilename = "56013_20012021062907";
        //request.AddParameter("message", "{'type':'file','url':'"+ FUrl + "','caption':'Hi Sanjay,Please find the attached Invoice','filename':'"+ Ffilename + "'}");"HI sanjay invpoin {2}"
        request.AddParameter("message", "{'type':'file','url':'" + FUrl + "','caption':'Hi Vadilal Dealer,Please find the attached Invoice','filename':'" + Ffilename + "'}");
        request.AddParameter("src.name", "VCERP101");

        IRestResponse response = client.Execute(request);
        if (response.StatusCode.ToString() == "OK")
        {
            result = "ok";
        }
        else
        {
            result = response.ErrorMessage;
        }
        return result;
    }

    protected void Button1_Click(object sender, EventArgs e)
    {

        //Interact("", "8460157815");
        // Interact("", "9974632583");
        //   Interact("", "8866551707");
        //Interact("", "7048198342");
        //Interact("", "7487823339");
        //Interact("", "9909301020");

        //// ===================== send WhatsAPP using GupShup.
        //Service wb = new Service();
        //wb.SendWhatsApp("8980054654", txttest.Text);
        ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
        string result = "";

        var client1 = new RestClient(@"https://www.pinbot.ai/wamessage/v1/optin");
        var request1 = new RestRequest(Method.POST);
        request1.AddHeader("apikey", "94526541-b48d-41f7-bf13-090b47cc72e5");
        request1.AddHeader("Content-Type", "application/json");
        //request1.AddParameter("contact", "918980054654");
        request1.AddParameter("contact", "918980054654");

        IRestResponse response1 = client1.Execute(request1);
        if (response1.StatusCode.ToString() == "OK")
        {

        }
        status.Text = response1.StatusCode + "::" + DateTime.Now;

        var client = new RestClient(@"https://www.pinbot.ai/wamessage/v1/send");
        var request = new RestRequest(Method.POST);
        request.AddHeader("Content-Type", "application/json");
        request.AddHeader("apikey", "94526541-b48d-41f7-bf13-090b47cc72e5");
        //MainInput obj = new MainInput();
        //obj.to = "918980054654";
        //obj.type = "template";
        //obj.message = new ChlInput();
        //obj.message.templateid = "pbwa1879";
        //obj.message.url = "https://dms.vadilalgroup.com/document/WhatsAppAPI/SalesInv/56023_01022021122346.pdf";
        //obj.message.filename = "56023_01022021122346.pdf";
        //obj.message.placeholders = new string[] { DateTime.Now.ToString("dd-MMM-yy HH:mm"), "sdsdsd" };

        //request.RequestFormat = DataFormat.Json;
        //request.AddJsonBody(obj);
        //'{"to": "918980054654","type": "template","message": {"templateid": "pbwa1879","url": "https://dms.vadilalgroup.com/document/WhatsAppAPI/SalesInv/56023_01022021122346.pdf","filename": "56023_01022021122346.pdf","placeholders": ["sdsd","sdasds"]}}');
        //request.AddParameter("to", "918980054654");
        //request.AddParameter("type", "template");
        //string FUrl = "https://dms.vadilalgroup.com/document/WhatsAppAPI/SalesInv/56023_01022021122346.pdf";
        //string Ffilename = "56023_01022021122346.pdf";

        //JArray JArrayPlaceHolder = new JArray(); 
        //JArrayPlaceHolder.Add(DateTime.Now.ToShortDateString());
        //JArrayPlaceHolder.Add("sds");

        //JObject message = new JObject();
        //message.Add("templateid", "pbwa1879");
        //message.Add("url", FUrl);
        //message.Add("filename", Ffilename);
        //message.Add("placeholders", JArrayPlaceHolder);

        ////request.AddParameter("message", "{\"templateid\":\"pbwa1879\",\"url\":\"" + FUrl + "\",\"filename\":\"" + Ffilename + "\",\"placeholders\":[\"" + DateTime.Now.ToShortDateString() + "\",\"sds\"]}");

        //request.AddParameter("message", message);

        IRestResponse response = client.Execute(request);
        if (response.StatusCode.ToString() == "OK")
        {
            result = "ok";
        }
        else
        {
            result = response.ErrorMessage;
        }




        //IRestResponse response = client.Execute(request);
        //if (response.StatusCode.ToString() == "OK")
        //{
        //    result = "Message is sent successfully.";
        //}
        //else
        //{
        //    result = response.Content;
        //}


        // ===================== OTHER MEthod to send WhatsAPP but shown as malware in SonicFirewall in vadilal QA server.

        ////Service wb = new Service();
        ////wb.SendWhatsApp("8980054654", txttest.Text);
        //string result = "";

        //var client = new RestSharp.RestClient(@"http://whatsservice.online/Api/Sms");
        //var request = new RestRequest(Method.GET);
        ////request.AddHeader("Cache-Control", "no-cache");
        ////request.AddHeader("Accept-Encoding", "gzip, deflate");
        ////request.AddParameter("action", "send-sms");
        //request.AddParameter("api_key", "99927375ea7b87596bad8d4ba075d7659d311804");
        //request.AddParameter("to", "918980054654");
        //request.AddParameter("from", "9868702449");
        //////===PDF 
        //////request.AddParameter("globalmedia", "http://dmsqa.vadilalgroup.com/document/UserManualG.pdf");
        //////===CSV 
        //////request.AddParameter("globalmedia", "http://dmsqa.vadilalgroup.com/document/CSV%20Formats/AssetEmpMappingFormat.csv");
        //////IMG ::: PNG/JPG ==> Less than 1MB.
        //////request.AddParameter("globalmedia", "http://dmsqa.vadilalgroup.com/images/3asdasd.jpg");
        //request.AddParameter("sms", txttest.Text);

        //IRestResponse response = client.Execute(request);
        //if (response.StatusCode.ToString() == "OK")
        //{
        //    result = response.Content;
        //}
        //else
        //{
        //    result = response.ErrorMessage;
        //}
        ////status.Text = result + "::" + DateTime.Now;
        //status.Text = "::" + DateTime.Now;

        //========= Third Method...businesssms FROM TaxPro... send WhatsAPP =======================
        //=== for Text sending by using DLL...
        //SendTextMsgJson body = new SendTextMsgJson { text = txttest.Text, sendLinkPreview = false };
        //TxnRespWithSendMessageDtls txnResp = APIMethods.SendTextMessage(txtMobileNo.Text, body);
        //status.Text = JsonConvert.SerializeObject(txnResp, Formatting.Indented);

        //========= Third Method...businesssms FROM TaxPro... send WhatsAPP =======================
        //=== for Text sending by using API...

        //============ Getting QR Code from API======
        //var client1 = new RestSharp.RestClient(@"http://localhost:3000/qrcode");
        //var request1 = new RestRequest(Method.GET);
        //request1.AddHeader("Content-Type", "application/json");
        //request1.AddHeader("accept", "application/json");
        //request1.Timeout = 120000;
        //IRestResponse response = client1.Execute(request1);
        //if (response.StatusCode.ToString() == "OK")
        //{
        //    byte[] img = response.RawBytes;
        //    imgQRcode.ImageUrl = "data:image;base64," + Convert.ToBase64String(img);
        //}


        //var client = new RestSharp.RestClient(@"http://localhost:3000/91" + txtMobileNo.Text + "/sendText");
        //var request = new RestRequest(Method.POST);
        //request.AddHeader("Content-Type", "application/json");
        //request.AddHeader("accept", "application/json");
        //request.AddJsonBody(new
        //{
        //    text = txttest.Text,
        //    sendLinkPreview = false
        //});
        //request.Timeout = 120000;
        //IRestResponse response1 = client.Execute(request);
        //if (response1.StatusCode.ToString() == "OK")
        //{
        //    //result = response.Content;
        //}

        // === for media sending..
        //SendMediaMsgJson waMediaMsgBody = new SendMediaMsgJson();
        //string Attachment = Convert.ToBase64String(File.ReadAllBytes(dlgOpenDialog.FileName));
        //string AttachmentFileName = Path.GetFileName(dlgOpenDialog.FileName);
        //waMediaMsgBody.base64data = Attachment;
        //waMediaMsgBody.mimeType = MimeMapping.GetMimeMapping(AttachmentFileName);
        //waMediaMsgBody.caption = "APIMethod SendMediaMessage from CISPLWhatsAppAPI.dll";
        //waMediaMsgBody.filename = AttachmentFileName;
        //TxnRespWithSendMessageDtls txnResp = await APIMethods.SendMediaMessageAsync(txtMobileNo.Text, waMediaMsgBody);

        //txtResponse.Text = JsonConvert.SerializeObject(txnResp, Formatting.Indented);

    }

    protected void btnSendNoSaleMail_Click(object sender, EventArgs e)
    {
        Decimal ParentID = 1000010000000000;
        int UserID = 1576;
        string BaseDir = AppDomain.CurrentDomain.BaseDirectory;

        string strPath = BaseDir + "Document\\log.txt";

        TraceService(strPath, "Code Start : " + DateTime.Now);

        Service cs = new Service();
        #region DMS No Sale Whatsapp MSG

        using (DDMSEntities ctx = new DDMSEntities())
        {
            SqlConnection sConnection = ((SqlConnection)ctx.Database.Connection);

            try
            {
                var objOSCHDL = ctx.OSCHDLs.Where(x => x.Active).ToList();

                if (objOSCHDL != null && objOSCHDL.Count > 0)
                {
                    if (sConnection != null && sConnection.State == ConnectionState.Closed)
                        sConnection.Open();

                    try
                    {
                        DataTable dt = new DataTable();
                        SqlDataAdapter com = new SqlDataAdapter("EXEC SendMSGToNoSaleData", sConnection);
                        com.Fill(dt);

                        List<NoSaleMsg> SendMsgData = null;

                        try
                        {
                            SendMsgData = dt.AsEnumerable().Select(r => new NoSaleMsg { ScheduleID = r.Field<int>("ScheduleID"), MessageTo = r.Field<string>("MessageTo"), SendToID = r.Field<decimal>("SendToID"), Phone = r.Field<string>("Phone"), LastInvDay = r.Field<int>("LastInvDay") }).Distinct().ToList();

                            if (SendMsgData != null && SendMsgData.Count > 0)
                            {
                                foreach (var SendMsg in SendMsgData)
                                {
                                  //  ReportDocument myReport = new ReportDocument();
                                    ConnectionInfo myConnectionInfo = new ConnectionInfo();

                                    string SendToCode = "";

                                    if (SendMsg.MessageTo == "Employee Category")
                                    {
                                        SendToCode = ctx.OEMPs.FirstOrDefault(x => x.EmpID == SendMsg.SendToID && x.ParentID == ParentID) != null ? ctx.OEMPs.FirstOrDefault(x => x.EmpID == SendMsg.SendToID && x.ParentID == ParentID).EmpCode : "";
                                    //    myReport.Load(BaseDir + "Reports\\CrystalReports\\NoSaleSMSEmp.rpt");
                                    //    myReport.SetParameterValue("@SUserID", SendMsg.SendToID);
                                    }
                                    else if (SendMsg.MessageTo == "Distributor")
                                    {
                                        SendToCode = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == SendMsg.SendToID) != null ? ctx.OCRDs.FirstOrDefault(x => x.CustomerID == SendMsg.SendToID).CustomerCode : "";
                                     //   myReport.Load(BaseDir + "Reports\\CrystalReports\\NoSaleSMSDist.rpt");
                                     //   myReport.SetParameterValue("@DistributorID", SendMsg.SendToID);
                                    }

                                   // myReport.SetParameterValue("@ParentID", ParentID);
                                   // myReport.SetParameterValue("@NoSaleDays", SendMsg.LastInvDay);
                                  //  myReport.SetParameterValue("@LogoImage", BaseDir + "Document\\LOGO1.jpg");

                                    string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DMSEntities"].ToString();
                                    EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
                                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);

                                   // Tables myTables = myReport.Database.Tables;

                                    //foreach (CrystalDecisions.CrystalReports.Engine.Table myTable in myTables)
                                    //{
                                    //    TableLogOnInfo myTableLogonInfo = myTable.LogOnInfo;
                                    //    myConnectionInfo.ServerName = builder.DataSource;
                                    //    myConnectionInfo.DatabaseName = builder.InitialCatalog;
                                    //    myConnectionInfo.UserID = "sa";
                                    //    myConnectionInfo.Password = builder.Password;
                                    //    myTableLogonInfo.ConnectionInfo = myConnectionInfo;
                                    //    myTable.ApplyLogOnInfo(myTableLogonInfo);
                                    //}
                                    string FileName = SendToCode + "_" + DateTime.Now.ToString("ddMMyyyyHHmmss") + ".pdf";

                                    string WebsiteURL = Convert.ToString(ConfigurationManager.AppSettings["WebsiteURLLocal"]);

                                    string FilePath = WebsiteURL + "Document\\WhatsAppAPI\\NoSaleData\\" + FileName;

                                    //myReport.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, FilePath);
                                    //myReport.Close();
                                    //myReport.Dispose();
                                    GC.Collect();

                                    int EmpTemplateID = Convert.ToInt32(ConfigurationManager.AppSettings["WhatsAppNoSalesEmpTempID"]);
                                    int DistTemplateID = Convert.ToInt32(ConfigurationManager.AppSettings["WhatsAppNoSalesDistTempID"]);
                                    string DMSSupportNo = ctx.OSETs.FirstOrDefault(x => x.KeyName == "DMSSupport").Value;
                                    string DMSSupportCC = ctx.OSETs.FirstOrDefault(x => x.KeyName == "DMSSupportCC").Value;

                                    if (SendMsg.MessageTo == "Employee Category")
                                    {
                                        if (!string.IsNullOrEmpty(SendMsg.Phone))
                                        {
                                            cs.SendNoSaleWhatsApp(SendMsg.Phone, "Document\\WhatsAppAPI\\NoSaleData\\" + FileName, FileName, EmpTemplateID);
                                            //try
                                            //{
                                            //    if (!string.IsNullOrEmpty(DMSSupportNo))
                                            //    {
                                            //        OEML objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == ParentID);
                                            //        MailMessage message = new MailMessage();
                                            //        message.From = new MailAddress(objOEML.Email);
                                            //        if (!string.IsNullOrEmpty(DMSSupportCC))
                                            //            message.CC.Add(DMSSupportCC);

                                            //        message.Subject = "DMS No Sale Data -" + SendToCode + "";
                                            //        message.To.Add(DMSSupportNo);
                                            //        SmtpClient client = new SmtpClient();
                                            //        client.Host = objOEML.Domain;
                                            //        client.Port = Convert.ToInt32(objOEML.Port);
                                            //        client.UseDefaultCredentials = true;
                                            //        client.EnableSsl = false;
                                            //        if (!string.IsNullOrEmpty(objOEML.UserName))
                                            //            client.Credentials = new System.Net.NetworkCredential(objOEML.UserName, objOEML.Password);
                                            //        else
                                            //            client.Credentials = new System.Net.NetworkCredential(objOEML.Email, objOEML.Password);
                                            //        string bodystr = "Dear Sir, <br /><br /> Please find attachment <br /> <br />";
                                            //        message.Body = bodystr;

                                            //        System.Net.Mail.Attachment att = new System.Net.Mail.Attachment(FilePath);
                                            //        message.Attachments.Add(att);

                                            //        message.IsBodyHtml = true;
                                            //        client.Send(message);
                                            //    }
                                            //}
                                            //catch (Exception ex)
                                            //{
                                            //    TraceService(strPath, "Error 1 in sending mail @ " + Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                            //}
                                        }
                                        else
                                        {
                                            TraceService(strPath, "Employee: No Support Phone no found for " + SendMsg.Phone + " in date " + DateTime.Now.ToString());
                                        }
                                    }
                                    else if (SendMsg.MessageTo == "Distributor")
                                    {
                                        if (!string.IsNullOrEmpty(SendMsg.Phone))
                                        {
                                            cs.SendNoSaleWhatsApp(SendMsg.Phone, "Document\\WhatsAppAPI\\NoSaleData\\" + FileName, FileName, DistTemplateID);
                                            //try
                                            //{
                                            //    if (!string.IsNullOrEmpty(DMSSupportNo))
                                            //    {
                                            //        OEML objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == ParentID);
                                            //        MailMessage message = new MailMessage();
                                            //        message.From = new MailAddress(objOEML.Email);
                                            //        if (!string.IsNullOrEmpty(DMSSupportCC))
                                            //            message.CC.Add(DMSSupportCC);

                                            //        message.Subject = "DMS No Sale Data from -" + SendToCode + "";
                                            //        message.To.Add(DMSSupportNo);
                                            //        SmtpClient client = new SmtpClient();
                                            //        client.Host = objOEML.Domain;
                                            //        client.Port = Convert.ToInt32(objOEML.Port);
                                            //        client.UseDefaultCredentials = true;
                                            //        client.EnableSsl = false;
                                            //        if (!string.IsNullOrEmpty(objOEML.UserName))
                                            //            client.Credentials = new System.Net.NetworkCredential(objOEML.UserName, objOEML.Password);
                                            //        else
                                            //            client.Credentials = new System.Net.NetworkCredential(objOEML.Email, objOEML.Password);
                                            //        string bodystr = "Dear Sir, <br /><br /> Please find attachment <br /> <br />";
                                            //        message.Body = bodystr;

                                            //        System.Net.Mail.Attachment att = new System.Net.Mail.Attachment(FilePath);
                                            //        message.Attachments.Add(att);

                                            //        message.IsBodyHtml = true;
                                            //        client.Send(message);
                                            //    }
                                            //}
                                            //catch (Exception ex)
                                            //{
                                            //    TraceService(strPath, "Error 1 in sending mail @ " + Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                                            //}
                                        }
                                        else
                                        {
                                            TraceService(strPath, "Distributor: No Support Phone no found for " + SendMsg.Phone + " in date " + DateTime.Now.ToString());
                                        }
                                    }
                                }

                                List<int> ScheduleIDs = SendMsgData.Distinct().Select(x => x.ScheduleID).ToList();
                                foreach (var ScheduleID in ScheduleIDs)
                                {
                                    var objOldOSCHDL = ctx.OSCHDLs.FirstOrDefault(x => x.ScheduleID == ScheduleID);

                                    if (objOldOSCHDL != null)
                                        objOldOSCHDL.LastRunDate = DateTime.Now;
                                    else
                                        TraceService(strPath, "No ScheduleID found" + ScheduleID + " in date " + DateTime.Now.ToString());
                                }
                                ctx.SaveChanges();
                            }
                        }
                        catch (Exception ex)
                        {
                            TraceService(strPath, "Error in sending No sale whatsapp msg @ " + Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                        }
                    }
                    catch (Exception ex)
                    {
                        TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
                    }
                    TraceService(strPath, "Process Completed. @ " + DateTime.Now.ToString());
                }
                else
                    TraceService(strPath, "No active schedule found @ " + DateTime.Now.ToString());
            }
            catch (Exception ex)
            {
                TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
            }
            finally
            {
                sConnection.Close();
            }
        }
        #endregion

    }

    public static void SendSaleDocInWhatsAPP(string CustPhoneNumber, decimal DistID, decimal ParentID, int UserID)
    {
        ReportDocument myReport = new ReportDocument();
        ConnectionInfo myConnectionInfo = new ConnectionInfo();
        try
        {
            myReport.Load(HostingEnvironment.MapPath("~/Reports/CrystalReports/NoSaleSMSDist.rpt"));
            myReport.SetParameterValue("@DistID", DistID);
            myReport.SetParameterValue("@ParentID", ParentID);
            myReport.SetParameterValue("@EmpID", UserID);
            myReport.SetParameterValue("@LogoImage", HostingEnvironment.MapPath("~/Images/LOGO.jpg"));

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
            string FileName = DistID + "_" + ParentID + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".pdf";
            string FilePath = HostingEnvironment.MapPath("~/Document/WhatsAppAPI/NoSaleDist/") + FileName;

            myReport.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, FilePath);
            Service wb = new Service();
            int TemplateID = Convert.ToInt32(ConfigurationManager.AppSettings["WhatsAppSalesTempID"]);

            wb.SendWhatsApp(CustPhoneNumber, "Document/WhatsAppAPI/NoSaleDist/" + FileName, "Invoice Detail", FileName, TemplateID, null);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            myReport.Close();
            myReport.Dispose();
            GC.Collect();
        }
    }


    protected void btnSendPromotionalWhatsAPP_Click(object sender, EventArgs e)
    {
        Service wb = new Service();
        #region Send Whats App Promotional Message
        string BaseDir = AppDomain.CurrentDomain.BaseDirectory;

        string strPath = BaseDir + "Document\\log.txt";

        TraceService(strPath, "  Whatsapp promotional message Start : " + DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            //var objOSCHDL = ctx.OSCHDLs.Where(x => x.Active).ToList();

            //if (objOSCHDL != null && objOSCHDL.Count > 0)
            //{

            SqlConnection sConnection = ((SqlConnection)ctx.Database.Connection);
            if (sConnection != null && sConnection.State == ConnectionState.Closed)
                sConnection.Open();
            try
            {
                DataTable dt = new DataTable();
                SqlDataAdapter com = new SqlDataAdapter("EXEC SendPromotionalWhatsAPPMessage", sConnection);
                com.Fill(dt);
                List<WhatsAppBusinessMsg> SendWhatsMsgData = null;
                string WebsiteURL = Convert.ToString(ConfigurationSettings.AppSettings["WebsiteURLLocal"]);

                int EmpTemplateID = Convert.ToInt32(ConfigurationSettings.AppSettings["WhatsAppSalesTempID"]);
                SendWhatsMsgData = dt.AsEnumerable().Select(r => new WhatsAppBusinessMsg { OWPMID = r.Field<int>("OWPMID"), ImageUpload = r.Field<string>("ImageUpload"), Phone = r.Field<string>("Phone") }).Distinct().ToList();
                //SendNoSaleWhatsApp(SendWhatsMsgData.Phone, "Document\\WhatsAppAPI\\NoSaleData\\" + FileName, FileName, DistTemplateID);
                if (SendWhatsMsgData != null && SendWhatsMsgData.Count > 0)
                {
                    foreach (var SendWhatsMsg in SendWhatsMsgData)
                    {
                        string FileName = SendWhatsMsg.ImageUpload;
                        // string FilePath = WebsiteURL + "Document\\WhatsAppMessageBroadCast\\" + FileName;
                        wb.SendNoSaleWhatsApp(SendWhatsMsg.Phone, "Document\\WhatsAppMessageBroadCast\\" + FileName, FileName, EmpTemplateID);
                        //wb.SendWhatsApp(SendWhatsMsg.Phone, "Document/WhatsAppMessageBroadCast/" + FileName, "", FileName, EmpTemplateID, null);
                    }
                }
            }
            catch (Exception ex)
            {
                TraceService(strPath, Common.GetString(ex) + " @ " + DateTime.Now.ToString());
            }
            finally
            {
                sConnection.Close();
            }
            // }
        }


        TraceService(strPath, "  Whatsapp promotional message End : " + DateTime.Now);
        #endregion
    }
}