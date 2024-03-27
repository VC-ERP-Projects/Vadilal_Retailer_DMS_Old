using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.EntityClient;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Transactions;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
[ScriptService]

public class Service : System.Web.Services.WebService
{
    public Service()
    {
        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    #region New Used Service
    public class MainInput
    {
        public string from { get; set; }
        public string to { get; set; }
        public string type { get; set; }
        public ChlInput message { get; set; }
    }
    public class WhatsappData
    {
        public string from { get; set; }
        public string contact { get; set; }
    }
    public class ChlInput
    {
        public int templateid { get; set; }
        public string filename { get; set; }
        public string url { get; set; }
        public string[] placeholders { get; set; }
    }

    public String SendNotification(string deviceid, string body, string title)
    {
        string Msg = "";
        try
        {
            string applicationid = WebConfigurationManager.AppSettings["applicationid"].ToString();
            string senderid = WebConfigurationManager.AppSettings["senderid"].ToString();

            WebRequest tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
            tRequest.Method = "post";
            tRequest.ContentType = "application/json";
            var data = new
            {
                to = deviceid,
                notification = new
                {
                    body = body,
                    title = title,
                    sound = "Enabled"

                }
            };
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(data);
            Byte[] byteArray = Encoding.UTF8.GetBytes(json);
            tRequest.Headers.Add(string.Format("Authorization: key={0}", applicationid));
            tRequest.Headers.Add(string.Format("Sender: id={0}", senderid));
            tRequest.ContentLength = byteArray.Length;
            using (Stream dataStream = tRequest.GetRequestStream())
            {
                dataStream.Write(byteArray, 0, byteArray.Length);
                using (WebResponse tResponse = tRequest.GetResponse())
                {
                    using (Stream dataStreamResponse = tResponse.GetResponseStream())
                    {
                        using (StreamReader tReader = new StreamReader(dataStreamResponse))
                        {
                            Msg = tReader.ReadToEnd();
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Msg = Common.GetString(ex);
        }
        return Msg;
    }

    public static void SendNotificationFlow(int menuid, int UserID, decimal ParentID, string body, string title, decimal CustomerID)
    {
        try
        {
            string applicationid = WebConfigurationManager.AppSettings["applicationid"].ToString();
            string senderid = WebConfigurationManager.AppSettings["senderid"].ToString();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                // int GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                List<OSM> list = ctx.OSMS.Where(x => x.RequestTypeMenuID == menuid && x.Status == 2 && x.Active).OrderBy(x => x.LevelNo).ToList();
                Boolean IsFirst = true;
                Boolean NotiSend = true;
                Boolean IsExclude = false;
                //Below varible update as level
                Decimal NextCustID = CustomerID;
                Decimal NextEmpID = UserID;

                foreach (OSM item in list)
                {
                    for (int i = 1; i <= 3; i++)
                    {
                        NotiSend = true;
                        IsExclude = false;
                        OGCM objOGCM = null;
                        if (i == 1 && IsFirst)
                        {
                            objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == NextEmpID && x.ParentID == ParentID && x.IsActive);
                            IsFirst = false;
                        }
                        else if (i == 2)
                        {
                            if (item.IsManager)
                            {
                                if (ctx.OEMPs.Any(x => x.EmpID == NextEmpID && x.ManagerID.HasValue && x.ParentID == ParentID))
                                {
                                    int ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == NextEmpID && x.ParentID == ParentID).ManagerID.Value;
                                    NextEmpID = ManagerID;
                                    foreach (string EmpIDs in item.ExcEmp.Split(','))
                                    {
                                        if (EmpIDs == ManagerID.ToString())
                                            IsExclude = true;
                                    }
                                    if (!IsExclude)
                                        objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == ManagerID && x.ParentID == ParentID && x.IsActive);
                                }
                            }
                            else if (item.UserID.HasValue)
                            {
                                foreach (string EmpIDs in item.ExcEmp.Split(','))
                                {
                                    if (EmpIDs == item.UserID.ToString())
                                        IsExclude = true;
                                }
                                if (!IsExclude)
                                    objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == item.UserID.Value && x.ParentID == ParentID && x.IsActive);

                                NextEmpID = item.UserID.Value;
                            }
                        }
                        else if (i == 3)
                        {
                            if (NextCustID > 0 && item.IsCustomer)
                            {
                                if (ctx.OCRDs.Any(x => x.CustomerID == NextCustID && x.Type > 1 && x.Active))
                                {
                                    Decimal CustParentID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == NextCustID && x.Type > 1 && x.Active).ParentID;
                                    if (CustParentID > 1000010000000000)
                                    {
                                        NextCustID = CustParentID;
                                        objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == CustParentID && x.IsActive);
                                        if (objOGCM != null)
                                        {
                                            GCM1 objGCM1 = new GCM1();
                                            //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", objOGCM.ParentID, 0).FirstOrDefault().Value;
                                            objGCM1.ParentID = objOGCM.ParentID;
                                            objGCM1.DeviceID = 1;
                                            objGCM1.CreatedDate = DateTime.Now;
                                            objGCM1.CreatedBy = UserID;
                                            objGCM1.Body = body;
                                            objGCM1.Title = title;
                                            objGCM1.UnRead = true;
                                            objGCM1.IsDeleted = false;
                                            objGCM1.SentOn = false;
                                            ctx.GCM1.Add(objGCM1);
                                            ctx.SaveChanges();
                                        }
                                    }
                                    NotiSend = false;
                                }
                            }
                        }

                        if (objOGCM != null && NotiSend && !IsExclude)
                        {
                            WebRequest tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
                            tRequest.Method = "post";
                            tRequest.ContentType = "application/json";
                            var data = new
                            {
                                to = objOGCM.Token,
                                notification = new
                                {
                                    body = body,
                                    title = title,
                                    sound = "Enabled"

                                }
                            };
                            JavaScriptSerializer serializer = new JavaScriptSerializer();
                            string json = serializer.Serialize(data);
                            Byte[] byteArray = Encoding.UTF8.GetBytes(json);
                            tRequest.Headers.Add(string.Format("Authorization: key={0}", applicationid));
                            tRequest.Headers.Add(string.Format("Sender: id={0}", senderid));
                            tRequest.ContentLength = byteArray.Length;
                            using (Stream dataStream = tRequest.GetRequestStream())
                            {
                                dataStream.Write(byteArray, 0, byteArray.Length);
                                using (WebResponse tResponse = tRequest.GetResponse())
                                {
                                    using (Stream dataStreamResponse = tResponse.GetResponseStream())
                                    {
                                        using (StreamReader tReader = new StreamReader(dataStreamResponse))
                                        {
                                            var Result = tReader.ReadToEnd();
                                            if (!string.IsNullOrEmpty(Result))
                                            {
                                                GCM1 objGCM1 = new GCM1();
                                                //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                                                objGCM1.ParentID = ParentID;
                                                objGCM1.DeviceID = objOGCM.DeviceID;
                                                objGCM1.CreatedDate = DateTime.Now;
                                                objGCM1.CreatedBy = UserID;
                                                objGCM1.Body = body;
                                                objGCM1.Title = title;
                                                objGCM1.UnRead = true;
                                                objGCM1.IsDeleted = false;
                                                if (Result.IndexOf("\"success\":", StringComparison.CurrentCultureIgnoreCase) > 0)
                                                    objGCM1.SentOn = true;
                                                else
                                                    objGCM1.SentOn = false;
                                                ctx.GCM1.Add(objGCM1);
                                                ctx.SaveChanges();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
        }
    }

    public static void SendNotificationFlow(int menuid, int RequestID, int UserID, decimal ParentID, string body, string title, decimal CustomerID)
    {
        try
        {
            string applicationid = WebConfigurationManager.AppSettings["applicationid"].ToString();
            string senderid = WebConfigurationManager.AppSettings["senderid"].ToString();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                // int GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                List<OSM> list = ctx.OSMS.Where(x => x.RequestTypeMenuID == menuid && x.Status == 2 && x.Active).OrderBy(x => x.LevelNo).ToList();
                Boolean IsFirst = true;
                Boolean NotiSend = true;
                Boolean IsExclude = false;
                //Below varible update as level
                Decimal NextCustID = CustomerID;
                Decimal NextEmpID = UserID;

                foreach (OSM item in list)
                {
                    for (int i = 1; i <= 3; i++)
                    {
                        NotiSend = true;
                        IsExclude = false;
                        OGCM objOGCM = null;
                        if (i == 1 && IsFirst)
                        {
                            objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == RequestID && x.ParentID == ParentID && x.IsActive);
                            IsFirst = false;
                        }
                        else if (i == 2)
                        {
                            if (item.IsManager)
                            {
                                if (ctx.OEMPs.Any(x => x.EmpID == NextEmpID && x.ManagerID.HasValue && x.ParentID == ParentID))
                                {
                                    int ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == NextEmpID && x.ParentID == ParentID).ManagerID.Value;
                                    NextEmpID = ManagerID;
                                    foreach (string EmpIDs in item.ExcEmp.Split(','))
                                    {
                                        if (EmpIDs == ManagerID.ToString())
                                            IsExclude = true;
                                    }
                                    if (!IsExclude)
                                        objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == ManagerID && x.ParentID == ParentID && x.IsActive);
                                }
                            }
                            else if (item.UserID.HasValue)
                            {
                                foreach (string EmpIDs in item.ExcEmp.Split(','))
                                {
                                    if (EmpIDs == item.UserID.ToString())
                                        IsExclude = true;
                                }
                                if (!IsExclude)
                                    objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == item.UserID.Value && x.ParentID == ParentID && x.IsActive);
                                NextEmpID = item.UserID.Value;
                            }
                        }
                        else if (i == 3)
                        {
                            if (NextCustID > 0 && item.IsCustomer)
                            {
                                if (ctx.OCRDs.Any(x => x.CustomerID == NextCustID && x.Type > 1 && x.Active))
                                {
                                    Decimal CustParentID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == NextCustID && x.Type > 1 && x.Active).ParentID;
                                    if (CustParentID > 1000010000000000)
                                    {
                                        NextCustID = CustParentID;
                                        objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == CustParentID && x.IsActive);
                                        if (objOGCM != null)
                                        {
                                            GCM1 objGCM1 = new GCM1();
                                            //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", objOGCM.ParentID, 0).FirstOrDefault().Value;
                                            objGCM1.ParentID = objOGCM.ParentID;
                                            objGCM1.DeviceID = 1;
                                            objGCM1.CreatedDate = DateTime.Now;
                                            objGCM1.CreatedBy = UserID;
                                            objGCM1.Body = body;
                                            objGCM1.Title = title;
                                            objGCM1.UnRead = true;
                                            objGCM1.IsDeleted = false;
                                            objGCM1.SentOn = false;
                                            ctx.GCM1.Add(objGCM1);
                                            ctx.SaveChanges();
                                        }
                                    }
                                    NotiSend = false;
                                }
                            }
                        }

                        if (objOGCM != null && NotiSend && !IsExclude)
                        {
                            WebRequest tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
                            tRequest.Method = "post";
                            tRequest.ContentType = "application/json";
                            var data = new
                            {
                                to = objOGCM.Token,
                                notification = new
                                {
                                    body = body,
                                    title = title,
                                    sound = "Enabled"

                                }
                            };
                            JavaScriptSerializer serializer = new JavaScriptSerializer();
                            string json = serializer.Serialize(data);
                            Byte[] byteArray = Encoding.UTF8.GetBytes(json);
                            tRequest.Headers.Add(string.Format("Authorization: key={0}", applicationid));
                            tRequest.Headers.Add(string.Format("Sender: id={0}", senderid));
                            tRequest.ContentLength = byteArray.Length;
                            using (Stream dataStream = tRequest.GetRequestStream())
                            {
                                dataStream.Write(byteArray, 0, byteArray.Length);
                                using (WebResponse tResponse = tRequest.GetResponse())
                                {
                                    using (Stream dataStreamResponse = tResponse.GetResponseStream())
                                    {
                                        using (StreamReader tReader = new StreamReader(dataStreamResponse))
                                        {
                                            var Result = tReader.ReadToEnd();
                                            if (!string.IsNullOrEmpty(Result))
                                            {
                                                GCM1 objGCM1 = new GCM1();
                                                //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                                                objGCM1.ParentID = ParentID;
                                                objGCM1.DeviceID = objOGCM.DeviceID;
                                                objGCM1.CreatedDate = DateTime.Now;
                                                objGCM1.CreatedBy = UserID;
                                                objGCM1.Body = body;
                                                objGCM1.Title = title;
                                                objGCM1.UnRead = true;
                                                objGCM1.IsDeleted = false;
                                                if (Result.IndexOf("\"success\":", StringComparison.CurrentCultureIgnoreCase) > 0)
                                                    objGCM1.SentOn = true;
                                                else
                                                    objGCM1.SentOn = false;
                                                ctx.GCM1.Add(objGCM1);
                                                ctx.SaveChanges();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
        }
    }

    public String changeNumericToWords(double numb)
    {
        String num = numb.ToString();
        return changeToWords(num, false);
    }

    public String changeCurrencyToWords(String numb)
    {
        return changeToWords(numb, true);
    }

    public String changeCurrencyToWords(double numb)
    {
        return changeToWords(numb.ToString(), true);
    }

    public String changeNumericToWords(String numb)
    {
        return changeToWords(numb, false);
    }

    private String changeToWords(String numb, bool isCurrency)
    {
        String val = "", wholeNo = numb, points = "", andStr = "", pointStr = "";
        String endStr = (isCurrency) ? ("Only") : ("");
        try
        {
            int decimalPlace = numb.IndexOf(".");
            if (decimalPlace > 0)
            {
                wholeNo = numb.Substring(0, decimalPlace);
                points = numb.Substring(decimalPlace + 1);
                if (Convert.ToInt32(points) > 0)
                {
                    andStr = (isCurrency) ? ("and") : ("point");// just to separate whole numbers from points/Rupees
                    endStr = (isCurrency) ? ("Paisa " + endStr) : ("");
                    pointStr = " " + translateWholeNumber(points);
                }
                else
                {
                    endStr = (isCurrency) ? ("Rupees " + endStr) : ("");
                }
            }
            else
            {
                endStr = (isCurrency) ? ("Rupees " + endStr) : ("");
            }
            val = String.Format("{0} {1}{2} {3}", translateWholeNumber(wholeNo).Trim(), andStr, pointStr, endStr);
        }
        catch
        {
            ;
        }
        return val;
    }

    private String translateWholeNumber(String number)
    {
        string word = "";
        try
        {
            bool beginsZero = false;//tests for 0XX
            bool isDone = false;//test if already translated
            double dblAmt = (Convert.ToDouble(number));
            //if ((dblAmt > 0) && number.StartsWith("0"))

            if (dblAmt > 0)
            {//test for zero or digit zero in a nuemric
                beginsZero = number.StartsWith("0");
                int numDigits = number.Length;
                int pos = 0;//store digit grouping
                String place = "";//digit grouping name:hundres,thousand,etc...
                switch (numDigits)
                {
                    case 1://ones' range
                        word = ones(number);
                        isDone = true;
                        break;
                    case 2://tens' range
                        word = tens(number);
                        isDone = true;
                        break;
                    case 3://hundreds' range
                        pos = (numDigits % 3) + 1;
                        place = " Hundred ";
                        break;
                    case 4://thousands' range
                    case 5:
                    case 6:
                        pos = (numDigits % 4) + 1;
                        place = " Thousand ";
                        break;
                    case 7://millions' range
                    case 8:
                    case 9:
                        pos = (numDigits % 7) + 1;
                        place = " Million ";
                        break;
                    case 10://Billions's range
                        pos = (numDigits % 10) + 1;
                        place = " Billion ";
                        break;
                    //add extra case options for anything above Billion...
                    default:
                        isDone = true;
                        break;
                }
                if (!isDone)
                {//if transalation is not done, continue...(Recursion comes in now!!)
                    word = translateWholeNumber(number.Substring(0, pos)) + place + translateWholeNumber(number.Substring(pos));
                    //check for trailing zeros
                    if (beginsZero) word = " and " + word.Trim();
                }
                //ignore digit grouping names
                if (word.Trim().Equals(place.Trim())) word = "";
            }
        }
        catch
        {
            ;
        }
        return word.Trim();
    }

    private String tens(String digit)
    {
        int digt = Convert.ToInt32(digit);
        String name = null;
        switch (digt)
        {
            case 10:
                name = "Ten";
                break;
            case 11:
                name = "Eleven";
                break;
            case 12:
                name = "Twelve";
                break;
            case 13:
                name = "Thirteen";
                break;
            case 14:
                name = "Fourteen";
                break;
            case 15:
                name = "Fifteen";
                break;
            case 16:
                name = "Sixteen";
                break;
            case 17:
                name = "Seventeen";
                break;
            case 18:
                name = "Eighteen";
                break;
            case 19:
                name = "Nineteen";
                break;
            case 20:
                name = "Twenty";
                break;
            case 30:
                name = "Thirty";
                break;
            case 40:
                name = "Fourty";
                break;
            case 50:
                name = "Fifty";
                break;
            case 60:
                name = "Sixty";
                break;
            case 70:
                name = "Seventy";
                break;
            case 80:
                name = "Eighty";
                break;
            case 90:
                name = "Ninety";
                break;
            default:
                if (digt > 0)
                {
                    name = tens(digit.Substring(0, 1) + "0") + " " + ones(digit.Substring(1));
                }
                break;
        }
        return name;
    }

    private String ones(String digit)
    {
        int digt = Convert.ToInt32(digit);
        String name = "";
        switch (digt)
        {
            case 1:
                name = "One";
                break;
            case 2:
                name = "Two";
                break;
            case 3:
                name = "Three";
                break;
            case 4:
                name = "Four";
                break;
            case 5:
                name = "Five";
                break;
            case 6:
                name = "Six";
                break;
            case 7:
                name = "Seven";
                break;
            case 8:
                name = "Eight";
                break;
            case 9:
                name = "Nine";
                break;
        }
        return name;
    }

    private String translateRupees(String Rupees)
    {
        String cts = "", digit = "", engOne = "";
        for (int i = 0; i < Rupees.Length; i++)
        {
            digit = Rupees[i].ToString();
            if (digit.Equals("0"))
            {
                engOne = "Zero";
            }
            else
            {
                engOne = ones(digit);
            }
            cts += " " + engOne;
        }
        return cts;
    }

    public void SendSMS(string MobileNumber, string Message)
    {
        try
        {
            string UserName = Convert.ToString(ConfigurationManager.AppSettings["SMSUserID"]);
            string Password = Convert.ToString(ConfigurationManager.AppSettings["SMSPassword"]);
            string SenderID = Convert.ToString(ConfigurationManager.AppSettings["SMSSenderID"]);

            string result = apicall("http://smsjust.com/sms/user/urlsms.php?username=" + UserName + "&pass=" + Password + "&senderid=" + SenderID + "&dlttempid=1507161891090449058" + "&msgtype=TXT" + "&dest_mobileno=" + MobileNumber + "&message=" + Message + "&response=Y");
        }
        catch
        {
        }
    }
    //public string SendWhatsAppNew(string MobileNumber, string filePath = "", string Caption = "", string FileName = "")
    //{
    //    string result = string.Empty;
    //    try
    //    {
    //        var client = new RestSharp.RestClient(@"http://localhost:3000/91" + MobileNumber + "/sendMedia");
    //        var request = new RestRequest(Method.POST);
    //        request.AddHeader("Content-Type", "application/json");
    //        request.AddHeader("accept", "application/json");
    //        request.AddJsonBody(new
    //        {
    //            base64data = Convert.ToBase64String(File.ReadAllBytes(filePath)),
    //            mimeType = "application/pdf",
    //            caption = Caption,
    //            filename = FileName,
    //        });
    //        request.Timeout = 120000;
    //        IRestResponse response = client.Execute(request);
    //        if (response.StatusCode.ToString() == "OK")
    //            result = "Status:Success DateTime=>" + DateTime.Now + "=>MobileNumber::" + MobileNumber + " =>FilePath:" + filePath;
    //        else if (response.StatusCode.ToString() == "0")
    //            result = "Status:May be Connected Mobile Number does not connected with Internet. Error==>" + response.ErrorMessage + " =>DateTime=>" + DateTime.Now + "=>MobileNumber" + MobileNumber + " =>FilePath:" + filePath;
    //        else
    //            result = "Status:Error==>" + response.Content + " =>DateTime=>" + DateTime.Now + "=>MobileNumber" + MobileNumber + " =>FilePath:" + filePath;
    //    }
    //    catch
    //    {
    //    }
    //    return result;
    //}

    public string SendWhatsApp(string MobileNumber, string filePath = "", string Caption = "", string FileName = "", int TemplateId = 0, string CustomerName = "")
    {
        string result = string.Empty;
        try
        {
            string TokenKey = Convert.ToString(ConfigurationManager.AppSettings["WhatsAppApiKey"]);
            string WebsiteURL = Convert.ToString(ConfigurationManager.AppSettings["WebsiteURL"]);
            string WhatsAppMobileNumber = Convert.ToString(ConfigurationManager.AppSettings["WhatsAppMobileNumber"]);

            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            var client1 = new RestClient(@"https://api.pinbot.ai/v1/wamessage/optin");
            RestRequest request1 = new RestRequest(Method.POST);
            request1.AddHeader("Cache-Control", "no-cache");
            request1.AddHeader("apikey", TokenKey);
            request1.AddHeader("Content-Type", "application/json");

            WhatsappData _objwhsdata = new WhatsappData();
            _objwhsdata.from = "91" + WhatsAppMobileNumber;
            _objwhsdata.contact = "91" + MobileNumber;
            request1.RequestFormat = DataFormat.Json;
            request1.AddJsonBody(_objwhsdata);

            IRestResponse response1 = client1.Execute(request1);

            if (response1.StatusCode.ToString() == "OK")
            {
                var client = new RestClient(@"https://api.pinbot.ai/v1/wamessage/send");
                var request = new RestRequest(Method.POST);
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("apikey", TokenKey);
                MainInput obj = new MainInput();
                obj.from = "91" + WhatsAppMobileNumber;
                obj.to = "91" + MobileNumber;
                obj.type = "template";
                obj.message = new ChlInput();
                obj.message.templateid = TemplateId;
                obj.message.url = WebsiteURL + filePath;
                obj.message.filename = FileName;
                obj.message.placeholders = new string[] { DateTime.Now.ToString("dd-MMM-yy HH:mm"), CustomerName };

                request.RequestFormat = DataFormat.Json;
                request.AddJsonBody(obj);
                IRestResponse response = client.Execute(request);
                if (response.StatusCode.ToString() == "OK")
                {
                    result = "ok";
                }
                else
                {
                    result = response.ErrorMessage;
                }
            }
        }
        catch
        {
        }
        return result;
    }

    public string SendNoSaleWhatsApp(string MobileNumber, string filePath = "", string FileName = "", int TemplateId = 0)
    {
        string result = string.Empty;
        try
        {
            string TokenKey = Convert.ToString(ConfigurationManager.AppSettings["WhatsAppApiKey"]);
            string WebsiteURL = Convert.ToString(ConfigurationManager.AppSettings["WebsiteURL"]);
            string WhatsAppMobileNumber = Convert.ToString(ConfigurationManager.AppSettings["WhatsAppMobileNumber"]);

            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            var client1 = new RestClient(@"https://api.pinbot.ai/v1/wamessage/optin");
            var request1 = new RestRequest(Method.POST);
            request1.AddHeader("Cache-Control", "no-cache");
            request1.AddHeader("apikey", TokenKey);
            request1.AddHeader("Content-Type", "application/json");

            WhatsappData _objwhsdata = new WhatsappData();
            _objwhsdata.from = "91" + WhatsAppMobileNumber;
            _objwhsdata.contact = "91" + MobileNumber;
            request1.RequestFormat = DataFormat.Json;
            request1.AddJsonBody(_objwhsdata);

            IRestResponse response1 = client1.Execute(request1);
            if (response1.StatusCode.ToString() == "OK")
            {
                var client = new RestClient(@"https://api.pinbot.ai/v1/wamessage/send");
                var request = new RestRequest(Method.POST);
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("apikey", TokenKey);
                MainInput obj = new MainInput();
                obj.from = "91" + WhatsAppMobileNumber;
                obj.to = "91" + MobileNumber;
                obj.type = "template";
                obj.message = new ChlInput();
                obj.message.templateid = TemplateId;
                obj.message.url = WebsiteURL + filePath;
                obj.message.filename = FileName;
                obj.message.placeholders = new string[] { };

                request.RequestFormat = DataFormat.Json;
                request.AddJsonBody(obj);
                IRestResponse response = client.Execute(request);
                if (response.StatusCode.ToString() == "OK")
                {
                    result = "ok";
                }
                else
                {
                    result = response.ErrorMessage;
                }
            }
        }
        catch
        {
        }
        return result;
    }

    public string apicall(string url)
    {
        HttpWebRequest httpreq = (HttpWebRequest)WebRequest.Create(url);

        try
        {

            HttpWebResponse httpres = (HttpWebResponse)httpreq.GetResponse();

            StreamReader sr = new StreamReader(httpres.GetResponseStream());

            string results = sr.ReadToEnd();

            sr.Close();
            return results;

        }
        catch
        {
            return "0";
        }
    }

    #endregion

    public class DataRecord
    {
        public string Data { get; set; }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmpty(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        return StrCust;
    }

    #region Common Get Master Data For All Transection Pages

    [WebMethod(EnableSession = true)]
    public List<string> GetStates(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "State");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", 0);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetIndianStates(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        Int32 CountryId = 0;
        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 1)
        {
            CountryId = Int32.TryParse(contextKey.Split("-".ToArray())[0], out CountryId) ? CountryId : 0;
        }

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetIndianState";

        
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@CountryId", CountryId);
        

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetCitys(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 StateID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 1)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "City");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPlants(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "Plant");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSSFromPlantState(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "SS");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistFromSSPlantState(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetDistributrForClaim(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 ReasonId = 0;
        string ClaimMonth = "";


        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            ReasonId = Int32.TryParse(contextKey.Split("-".ToArray())[0], out ReasonId) ? ReasonId : 0;
            ClaimMonth = contextKey.Split("-".ToArray())[1];
        }

        DateTime Fromdate = Convert.ToDateTime(ClaimMonth);
        DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistributorForClaim";

      //  Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@ReasonId", ReasonId);
        Cm.Parameters.AddWithValue("@Fromdate", Fromdate);
        Cm.Parameters.AddWithValue("@Todate", Todate);
      

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetSSForClaimProcess(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 ReasonId = 0;
        string ClaimMonth = "";


        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            ReasonId = Int32.TryParse(contextKey.Split("-".ToArray())[0], out ReasonId) ? ReasonId : 0;
            ClaimMonth = contextKey.Split("-".ToArray())[1];
        }

        DateTime Fromdate = Convert.ToDateTime(ClaimMonth);
        DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetSSForClaim";

        //  Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@ReasonId", ReasonId);
        Cm.Parameters.AddWithValue("@Fromdate", Fromdate);
        Cm.Parameters.AddWithValue("@Todate", Todate);


        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetDealerFromDistSSPlantState(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Decimal DistID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 5)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[4], out DistID) ? DistID : 0;
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterData";

        Cm.Parameters.AddWithValue("@Type", "Dealer");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;

    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeList(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeList";

        Cm.Parameters.AddWithValue("@UserID", contextKey != null ? contextKey : UserID.ToString());
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeListSalesSchme(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeListSalesSchme";

        Cm.Parameters.AddWithValue("@UserID", contextKey != null ? contextKey : UserID.ToString());
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeListIncludingSelfEmpData(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = 0;
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();
        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 1)
        {
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out UserID) ? UserID : 0;
        }
        if (UserID == 0)
            UserID = Convert.ToInt32(Session["UserID"]);
        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeList_withSelfData";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeListTillM4(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeListTillM4";

        Cm.Parameters.AddWithValue("@UserID", contextKey != null ? contextKey : UserID.ToString());
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeListByGroup(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        List<String> StrCust = new List<string>();
        Int32 EmpID = 0;
        Int32 EmpGroupID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            EmpID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out EmpID) ? EmpID : 0;
            EmpGroupID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out EmpGroupID) ? EmpGroupID : 0;
        }
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeListByGroup";

        Cm.Parameters.AddWithValue("@UserID", EmpID > 0 ? EmpID : UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@GroupID", EmpGroupID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }
    [WebMethod(EnableSession = true)]
    public List<string> GetEmployeeListByRegion(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        var Types = "";

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out StateID) ? StateID : 0;
            //CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            // PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            Types = contextKey.Split("-".ToArray()).Last();

        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetEmployeeRegionCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateId", StateID);
        Cm.Parameters.AddWithValue("@MessageFor", Types);
        //Cm.Parameters.AddWithValue("@PlantID", PlantID);
        //Cm.Parameters.AddWithValue("@Types", Types);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }
    //GetCustomerByTypePlantStateForRSDApp
    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerByTypePlantStateRSDApp(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        var Types = "";

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            Types = contextKey.Split("-".ToArray()).Last();

        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCustomerByTypePlantStateRSDApp";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@Types", Types);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerByTypePlantState(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        var Types = "";

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            Types = contextKey.Split("-".ToArray()).Last();

        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCustomerByTypePlantState";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@Types", Types);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerByAllTypeWithoutTemp(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCustomerByAllTypeWithoutTemp";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetItemGroup(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OITBs
                           where c.Active
                           orderby c.SortOrder
                           select c.ItemGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemGroupID).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OITBs
                           where (c.ItemGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemGroupID).Contains(prefixText)) && c.Active
                           orderby c.SortOrder
                           select c.ItemGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemGroupID).Trim()).Take(20).ToList();
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSubGroupItem(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int ItemGroupID;
            if (Int32.TryParse(contextKey, out ItemGroupID))
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.OITGs
                               where c.Active && c.ItemGroupID == ItemGroupID
                               orderby c.SortOrder
                               select c.ItemSubGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.OITGs
                               where (c.ItemSubGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemSubGroupID).Contains(prefixText)) && c.Active && c.ItemGroupID == ItemGroupID
                               orderby c.SortOrder
                               select c.ItemSubGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim()).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.OITGs
                               where c.Active
                               orderby c.SortOrder
                               select c.ItemSubGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.OITGs
                               where (c.ItemSubGroupName.Contains(prefixText) || SqlFunctions.StringConvert((double)c.ItemSubGroupID).Contains(prefixText)) && c.Active
                               orderby c.SortOrder
                               select c.ItemSubGroupName.Replace("-", " ") + " - " + SqlFunctions.StringConvert((double)c.ItemSubGroupID).Trim()).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetItemWithID(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        using (var ctx = new DDMSEntities())
        {
            int ItemSubGroupID;
            decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (Int32.TryParse(contextKey, out ItemSubGroupID))
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.SITMs.Include("OITM").Include("OTMP")
                               where c.OTMP.IsDefault && c.ParentID == ParentID && c.OITM.SubGroupID == ItemSubGroupID
                               group c by new { c.OITM.ItemID, c.OITM.ItemCode, c.OITM.ItemName, c.Priority } into gcs
                               orderby gcs.Key.Priority
                               select gcs.Key.ItemCode + " - " + gcs.Key.ItemName + " - " + SqlFunctions.StringConvert((double)gcs.Key.ItemID).Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.SITMs.Include("OITM").Include("OTMP")
                               where c.OTMP.IsDefault && c.ParentID == ParentID && c.OITM.SubGroupID == ItemSubGroupID && (c.OITM.ItemCode.Contains(prefixText) || c.OITM.ItemName.Contains(prefixText))
                               group c by new { c.OITM.ItemID, c.OITM.ItemCode, c.OITM.ItemName, c.Priority } into gcs
                               orderby gcs.Key.Priority
                               select gcs.Key.ItemCode + " - " + gcs.Key.ItemName + " - " + SqlFunctions.StringConvert((double)gcs.Key.ItemID).Trim()).Take(20).ToList();
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = (from c in ctx.SITMs.Include("OITM").Include("OTMP")
                               where c.OTMP.IsDefault && c.ParentID == ParentID
                               group c by new { c.OITM.ItemID, c.OITM.ItemCode, c.OITM.ItemName, c.Priority } into gcs
                               orderby gcs.Key.Priority
                               select gcs.Key.ItemCode + " - " + gcs.Key.ItemName + " - " + SqlFunctions.StringConvert((double)gcs.Key.ItemID).Trim()).Take(20).ToList();
                }
                else
                {
                    StrCust = (from c in ctx.SITMs.Include("OITM").Include("OTMP")
                               where c.OTMP.IsDefault && c.ParentID == ParentID && (c.OITM.ItemCode.Contains(prefixText) || c.OITM.ItemName.Contains(prefixText))
                               group c by new { c.OITM.ItemID, c.OITM.ItemCode, c.OITM.ItemName, c.Priority } into gcs
                               orderby gcs.Key.Priority
                               select gcs.Key.ItemCode + " - " + gcs.Key.ItemName + " - " + SqlFunctions.StringConvert((double)gcs.Key.ItemID).Trim()).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerByTypeTempState(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);
        Int32 StateID = 0;
        Int32 Istemp = 0;
        var Types = "";

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            Istemp = Int32.TryParse(contextKey.Split("-".ToArray())[1], out Istemp) ? Istemp : 0;
            Types = contextKey.Split("-".ToArray()).Last();
        }
        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCustomerByTypeTempState";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@IsTemp", Istemp);
        Cm.Parameters.AddWithValue("@Types", Types);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetBroadcastMessage(string prefixText, int count, string contextKey)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();

            if (prefixText == "*")
            {
                StrCust = ctx.OMSGs.Where(x => x.ApplicableFor == contextKey).OrderByDescending(x => x.MessageID).Select(x => SqlFunctions.StringConvert((double)x.MessageID).Trim() + " - " + x.Subject.Replace("-", "")).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OMSGs.Where(x => x.ApplicableFor == contextKey && (x.Subject.Contains(prefixText) || (SqlFunctions.StringConvert((double)x.MessageID).Contains(prefixText)))).OrderByDescending(x => x.MessageID).Select(x => SqlFunctions.StringConvert((double)x.MessageID).Trim() + " - " + x.Subject.Replace("-", "")).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetWhatsAppMessage(string prefixText, int count, string contextKey)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();

            if (prefixText == "*")
            {
                //  StrCust = ctx.OWPMs.OrderByDescending(x => x.OWPMID).Select(x => SqlFunctions.StringConvert((double)x.OWPMID).Trim()).Take(20).ToList();
                var Data = (from c in ctx.OWPMs
                            orderby c.Active descending, c.FromDate descending
                            select new { c.MessagePeriod, c.FromDate, c.MessageTo, c.OWPMID, c.Active }
                          ).Take(40).ToList();

                foreach (var x in Data)
                {
                    StrCust.Add((x.MessagePeriod.Trim() == "D" ? "Daily" : x.MessagePeriod.Trim() == "M" ? "Monthly" : "Weekly") + " - " + (x.MessageTo.Trim() == "E" ? "Employee" : "Customer") + " - ( " + (Convert.ToBoolean(x.Active) ? "Active" : "InActive") + " ) " + " - " + x.OWPMID);
                }

            }
            else
            {
                //StrCust = ctx.OWPMs.Where(x => (SqlFunctions.StringConvert((double)x.OWPMID).Contains(prefixText))).OrderByDescending(x => x.OWPMID).Select(x => SqlFunctions.StringConvert((double)x.OWPMID).Trim()).Take(20).ToList();
                var Data = (from c in ctx.OWPMs
                            where ((c.MessagePeriod.Trim() == "D" ? "Daily" : c.MessagePeriod.Trim() == "M" ? "Monthly" : "Weekly").Contains(prefixText) || (c.MessageTo.Trim() == "E" ? "Employee" : "Customer").Contains(prefixText) || (SqlFunctions.StringConvert((double)c.OWPMID).Contains(prefixText)))
                            orderby c.Active descending, c.FromDate descending
                            select new { c.MessagePeriod, c.FromDate, c.MessageTo, c.OWPMID, c.Active }
                         ).Take(40).ToList();

                foreach (var x in Data)
                {
                    StrCust.Add((x.MessagePeriod.Trim() == "D" ? "Daily" : x.MessagePeriod.Trim() == "M" ? "Monthly" : "Weekly") + " - " + (x.MessageTo.Trim() == "E" ? "Employee" : "Customer") + " - ( " + (Convert.ToBoolean(x.Active) ? "Active" : "InActive") + " ) " + " - " + x.OWPMID);
                }
            }

            return StrCust;
        }
    }

    // Asset Register (Get all customers without type condition)
    [WebMethod(EnableSession = true)]
    public List<string> GetCustomerWithoutType(string prefixText, int count, string contextKey)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();

            if (prefixText == "*")
            {
                StrCust = ctx.OCRDs.OrderBy(x => x.CustomerCode).Select(x => x.CustomerCode + " - " + x.CustomerName + " - " + SqlFunctions.StringConvert((Decimal)x.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OCRDs.Where(x => x.CustomerCode.Contains(contextKey) || x.CustomerName.Contains(contextKey)).OrderBy(x => x.CustomerCode).Select(x => x.CustomerCode + " - " + x.CustomerName + " - " + SqlFunctions.StringConvert((Decimal)x.CustomerID, 20, 0).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }
    [WebMethod(EnableSession = true)]
    public List<DicData> GetBrandlist(string prefixText, int count, string contextKey)
    {
        List<DicData> StrCust = new List<DicData>();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OBRNDs
                           where c.Active
                           group c by new { c.BrandID, c.BrandName } into gcs
                           orderby gcs.Key.BrandID descending
                           select new DicData
                           {
                               Value = gcs.Key.BrandID,
                               Text = gcs.Key.BrandName
                           }).Take(20).ToList();
            }
            else
            {
                if (prefixText.Contains(","))
                {
                    string[] splitstring = prefixText.Split(',');
                    string splitBrand = splitstring.LastOrDefault().Trim();
                    if (splitBrand == "*")
                    {
                        StrCust = (from c in ctx.OBRNDs
                                   where c.Active
                                   group c by new { c.BrandID, c.BrandName } into gcs
                                   orderby gcs.Key.BrandID descending
                                   select new DicData
                                   {
                                       Value = gcs.Key.BrandID,
                                       Text = gcs.Key.BrandName
                                   }).Take(20).ToList();
                    }
                    else
                    {
                        StrCust = (from c in ctx.OBRNDs
                                   where (c.BrandName.Contains(splitBrand)) && c.Active
                                   group c by new { c.BrandID, c.BrandName } into gcs
                                   orderby gcs.Key.BrandID descending
                                   select new DicData
                                   {
                                       Value = gcs.Key.BrandID,
                                       Text = gcs.Key.BrandName
                                   }).Take(20).ToList();
                    }
                }
                else
                {
                    StrCust = (from c in ctx.OBRNDs
                               where (c.BrandName.Contains(prefixText)) && c.Active
                               group c by new { c.BrandID, c.BrandName } into gcs
                               orderby gcs.Key.BrandID descending
                               select new DicData
                               {
                                   Value = gcs.Key.BrandID,
                                   Text = gcs.Key.BrandName
                               }).Take(20).ToList();
                }
            }
            return StrCust;
        }
    }

    //Get Route by empid
    [WebMethod(EnableSession = true)]
    public List<string> GetRouteByEmpID(string prefixText, int count, string contextKey)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();

            int EmpID = int.TryParse(contextKey, out EmpID) ? EmpID : 0;

            if (prefixText == "*")
            {
                StrCust = ctx.ORUTs.Where(x => (EmpID == 0 || x.PrefSalesPersonID == EmpID) && x.Active == true).OrderBy(x => x.RouteCode).Select(x => x.RouteCode + " - " + x.RouteName + " - " + SqlFunctions.StringConvert((Decimal)x.RouteID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.ORUTs.Where(x => (EmpID == 0 || x.PrefSalesPersonID == EmpID) && x.Active == true && x.RouteCode.Contains(prefixText) || x.RouteName.Contains(prefixText)).OrderBy(x => x.RouteCode).Select(x => x.RouteCode + " - " + x.RouteName + " - " + SqlFunctions.StringConvert((Decimal)x.RouteID, 20, 0).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }

    //Get Route by empid
    [WebMethod(EnableSession = true)]
    public List<string> GetCompetitorRouteByEmpID(string prefixText, int count, string contextKey)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<string> StrCust = new List<string>();

            int EmpID = int.TryParse(contextKey, out EmpID) ? EmpID : 0;

            if (prefixText == "*")
            {
                StrCust = ctx.OCRUTs.Where(x => (EmpID == 0 || x.PrefSalesPersonID == EmpID) && x.Active == true).OrderBy(x => x.RouteCode).Select(x => x.RouteCode + " - " + x.RouteName + " - " + SqlFunctions.StringConvert((Decimal)x.CompRouteID, 20, 0).Trim()).Take(20).ToList();
            }
            else
            {
                StrCust = ctx.OCRUTs.Where(x => (EmpID == 0 || x.PrefSalesPersonID == EmpID) && x.Active == true && x.RouteCode.Contains(prefixText) || x.RouteName.Contains(prefixText)).OrderBy(x => x.RouteCode).Select(x => x.RouteCode + " - " + x.RouteName + " - " + SqlFunctions.StringConvert((Decimal)x.CompRouteID, 20, 0).Trim()).Take(20).ToList();
            }

            return StrCust;
        }
    }
    #endregion

    #region With hierarchy For Store Heirarchy Report

    [WebMethod(EnableSession = true)]
    public List<string> GetStatesStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        if (!String.IsNullOrEmpty(contextKey))
        {
            UserID = Int32.TryParse(contextKey, out UserID) ? UserID : 0;
        }

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "State");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", 0);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCitysStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = 0;

        Int32 StateID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "City");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPlantsStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Plant");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSSStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);


        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[3], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "SS");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 5)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[4], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerFromStoreHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Decimal DistID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 6)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[4], out DistID) ? DistID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[5], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForStoreHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Dealer");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;

    }

    #endregion

    #region With hierarchy For Currnet Heirarchy Report

    [WebMethod(EnableSession = true)]
    public List<string> GetStatesCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        if (!String.IsNullOrEmpty(contextKey))
        {
            UserID = Int32.TryParse(contextKey, out UserID) ? UserID : 0;
        }

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "State");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", 0);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCitysCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = 0;

        Int32 StateID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "City");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPlantsCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Plant");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSSCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);


        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[3], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "SS");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCompetitorName(string prefixText, int count, string contextKey)
    {
        List<String> StrCust = new List<string>();
        Int32 SelectedEmp = 0, BeatEmp = 0, CreatedByEMP = 0, StateID = 0, UserID = 0, ReportOption = 0;
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Decimal DistID = 0;
        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 7)
        {
            SelectedEmp = Int32.TryParse(contextKey.Split("-".ToArray())[0], out SelectedEmp) ? SelectedEmp : 0;
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out StateID) ? StateID : 0;
            CreatedByEMP = Int32.TryParse(contextKey.Split("-".ToArray())[2], out CreatedByEMP) ? CreatedByEMP : 0;
            BeatEmp = Int32.TryParse(contextKey.Split("-".ToArray())[3], out BeatEmp) ? BeatEmp : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[4], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
            DistID = decimal.TryParse(contextKey.Split("-".ToArray())[5], out DistID) ? DistID : 0;
            ReportOption = Int32.TryParse(contextKey.Split("-".ToArray())[6], out ReportOption) ? ReportOption : 0;
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetCompetitors";

        Cm.Parameters.AddWithValue("@EMPID", UserID);
        Cm.Parameters.AddWithValue("@SUserID", SelectedEmp);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CreatedByEMP", CreatedByEMP);
        Cm.Parameters.AddWithValue("@BeatEmp", BeatEmp);
        Cm.Parameters.AddWithValue("@DistID", DistID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@ReportOption", ReportOption);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
            StrCust = ds.Tables[0].AsEnumerable()
                               .Select(r => r.Field<string>("Data"))
                               .ToList();

        return StrCust;
    }


    [WebMethod(EnableSession = true)]

    public List<string> GetCompcreateEmpTeam(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 CustType = 0;
        Int32 EmpID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey))
        {
            EmpID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out EmpID) ? EmpID : 0;
            CustType = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CustType) ? CustType : 0;
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetTempCompByEmp";
        Cm.Parameters.AddWithValue("@EmpID", UserID);
        Cm.Parameters.AddWithValue("@SUserID", EmpID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@CustType", CustType);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
            StrCust = ds.Tables[0].AsEnumerable()
                               .Select(r => r.Field<string>("Data"))
                               .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]

    public List<string> GetDistCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 5)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[4], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerFromCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Decimal DistID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 6)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[4], out DistID) ? DistID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[5], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Dealer");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;

    }

    // For Region distributor dealer listing RPT change
    [WebMethod(EnableSession = true)]
    public List<string> GetDealerRegionCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 DistStateID = 0;
        Decimal DistStatusID = 0;
        Decimal DistID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            DistStateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out DistStateID) ? DistStateID : 0;
            DistStatusID = Decimal.TryParse(contextKey.Split("-".ToArray())[1], out DistStatusID) ? DistStatusID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[2], out DistID) ? DistID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[3], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDealerRegionCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@DistStatus", DistStatusID);
        Cm.Parameters.AddWithValue("@DistStateID", DistStateID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> SaleMachineGetDealerRegionCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 DistStateID = 0;
        Decimal DistStatusID = 0;
        Decimal DistID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            DistStateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out DistStateID) ? DistStateID : 0;
            DistStatusID = Decimal.TryParse(contextKey.Split("-".ToArray())[1], out DistStatusID) ? DistStatusID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[2], out DistID) ? DistID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[3], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "SaleMachineGetDealerRegionCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@DistStatus", DistStatusID);
        Cm.Parameters.AddWithValue("@DistStateID", DistStateID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistributorRegionCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistributorRegionCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> SaleSchmeGetDistributorRegionCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "SaleSchmeGetDistributorRegionCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]//Current Hierarchy up to Distributor Level 
    public List<string> GetDistributorCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 DistStateID = 0;
        Decimal DistStatusID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            DistStateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out DistStateID) ? DistStateID : 0;
            DistStatusID = Decimal.TryParse(contextKey.Split("-".ToArray())[1], out DistStatusID) ? DistStatusID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistributorCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@DistStatus", DistStatusID);
        Cm.Parameters.AddWithValue("@DistStateID", DistStateID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    #endregion

    #region With hierarchy For In-active Currnet Heirarchy Report

    [WebMethod(EnableSession = true)]
    public List<string> GetStatesInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        if (!String.IsNullOrEmpty(contextKey))
        {
            UserID = Int32.TryParse(contextKey, out UserID) ? UserID : 0;
        }

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "State");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", 0);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetCitysInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = 0;

        Int32 StateID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "City");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", 0);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetPlantsInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 3)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Plant");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", 0);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetSSInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);


        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[3], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "SS");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", 0);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDistInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 5)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[4], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", 0);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetDealerFromInActCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 CityID = 0;
        Int32 PlantID = 0;
        Decimal SSID = 0;
        Decimal DistID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 6)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            CityID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out CityID) ? CityID : 0;
            PlantID = Int32.TryParse(contextKey.Split("-".ToArray())[2], out PlantID) ? PlantID : 0;
            SSID = Decimal.TryParse(contextKey.Split("-".ToArray())[3], out SSID) ? SSID : 0;
            DistID = Decimal.TryParse(contextKey.Split("-".ToArray())[4], out DistID) ? DistID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[5], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetMasterDataForInActCurrHierarchyReports";

        Cm.Parameters.AddWithValue("@Type", "Dealer");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@StateID", StateID);
        Cm.Parameters.AddWithValue("@CityID", CityID);
        Cm.Parameters.AddWithValue("@PlantID", PlantID);
        Cm.Parameters.AddWithValue("@SSID", SSID);
        Cm.Parameters.AddWithValue("@DistID", DistID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;

    }
    [WebMethod(EnableSession = true)]
    public List<string> GetStateEmpwiseMapping(string prefixText, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        if (!String.IsNullOrEmpty(contextKey))
        {
            UserID = Int32.TryParse(contextKey, out UserID) ? UserID : 0;
        }

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "usp_GetEmpwiseState";
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        if (ds.Tables.Count > 0)
        {
            if (ds.Tables[0].Rows.Count > 0)
            {
                StrCust = ds.Tables[0].AsEnumerable()
                               .Select(r => r.Field<string>("Data"))
                               .ToList();
            }
        }
        return StrCust;
    }
    #endregion

    #region Mechanical

    [WebMethod(EnableSession = true)]
    public List<string> GetAssetSerialNo(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        List<String> StrCust = new List<string>();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (prefixText == "*")
            {
                StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null).Select(x => x.SerialNumber).Take(40).ToList();
            }
            else
            {
                StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null && x.SerialNumber.Contains(prefixText)).Select(x => x.SerialNumber).Take(40).ToList();
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetTypeWiseAssetSerialNo(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        List<String> StrCust = new List<string>();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 AssetTypeID = 0;
            if (int.TryParse(contextKey, out AssetTypeID))
            {
                if (AssetTypeID > 0)
                {

                    if (prefixText == "*")
                    {
                        StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null && x.AssetTypeID == AssetTypeID).Select(x => x.SerialNumber).Take(40).ToList();
                    }
                    else
                    {
                        StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null && x.AssetTypeID == AssetTypeID && x.SerialNumber.Contains(prefixText)).Select(x => x.SerialNumber).Take(40).ToList();
                    }
                }
                else
                {
                    if (prefixText == "*")
                    {
                        StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null).Select(x => x.SerialNumber).Take(40).ToList();
                    }
                    else
                    {
                        StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null && x.SerialNumber.Contains(prefixText)).Select(x => x.SerialNumber).Take(40).ToList();
                    }
                }
            }
            else
            {
                if (prefixText == "*")
                {
                    StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null).Select(x => x.SerialNumber).Take(40).ToList();
                }
                else
                {
                    StrCust = ctx.OASTs.Where(x => x.Active && x.HoldByCustomerID != null && x.SerialNumber.Contains(prefixText)).Select(x => x.SerialNumber).Take(40).ToList();
                }
            }
        }
        return StrCust;
    }

    [WebMethod(EnableSession = true)]
    public List<string> GetStorageLocationCurrHierarchy(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);

        Int32 StateID = 0;
        Int32 UserID = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 2)
        {
            StateID = Int32.TryParse(contextKey.Split("-".ToArray())[0], out StateID) ? StateID : 0;
            UserID = Int32.TryParse(contextKey.Split("-".ToArray())[1], out UserID) ? UserID : Convert.ToInt32(Session["UserID"]);
        }
        UserID = UserID == 0 ? Convert.ToInt32(Session["UserID"]) : UserID;

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetStorageLocationCurrHierarchy";

        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@StateID", StateID);

        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                       .Select(r => r.Field<string>("Data"))
                       .ToList();
        return StrCust;
    }


    [WebMethod(EnableSession = true)]
    public List<string> GetDistributrSSForClaimApproval(string prefixText, int count, string contextKey)
    {
        Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
        Int32 UserID = Convert.ToInt32(Session["UserID"]);

        String ReasonId = "";
        string ClaimMonth = "";
        int StatusId = 0;

        if (!String.IsNullOrEmpty(contextKey) && contextKey.Split("-".ToArray()).Length == 4)
        {
            ReasonId = contextKey.Split("-".ToArray())[0].ToString();
            ClaimMonth = contextKey.Split("-".ToArray())[1];
            StatusId = int.TryParse(contextKey.Split("-".ToArray())[3], out StatusId) ? StatusId : 0;
        }

        DateTime Fromdate = Convert.ToDateTime(ClaimMonth);
        DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

        List<String> StrCust = new List<string>();
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "GetDistributorSSForClaimApproval";

        //  Cm.Parameters.AddWithValue("@Type", "Distributor");
        Cm.Parameters.AddWithValue("@UserID", UserID);
        Cm.Parameters.AddWithValue("@ParentID", ParentID);
        Cm.Parameters.AddWithValue("@Prefix", prefixText);
        Cm.Parameters.AddWithValue("@Count", count);
        Cm.Parameters.AddWithValue("@ReasonId", ReasonId);
        Cm.Parameters.AddWithValue("@Fromdate", Fromdate);
        Cm.Parameters.AddWithValue("@Todate", Todate);
        Cm.Parameters.AddWithValue("@StatusId", StatusId);


        DataSet ds = objClass.CommonFunctionForSelect(Cm);
        StrCust = ds.Tables[0].AsEnumerable()
                           .Select(r => r.Field<string>("Data"))
                           .ToList();
        return StrCust;
    }
    #endregion
}