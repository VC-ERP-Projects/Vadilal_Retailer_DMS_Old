using System.Data;
using System.Data.Objects;
using System.Data.Objects.DataClasses;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Drawing.Imaging;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.Net.NetworkInformation;
using System.Net.Mail;
using System.Net;
using System.Net.Sockets;
using System.Web;
using System.Data.SqlClient;

public enum ClaimStatus
{
    Open = 1, //Pending
    Error = 2, //SAP
    Sucess = 3, //SAP
    InProcess = 4,
    Reject = 5,
    Delete = 6
}

public class DicData
{
    public string Text { get; set; }
    public int Value { get; set; }
}

public enum DayCloseStatus
{
    Open = 1,
    Confirm = 2,
    Handover = 3
}

public enum LedgerReqStatus
{
    Open = 1,
    Confirm = 2,
}

public enum SalesType
{
    Tax = 1,
    Retail = 2,
}

public enum ReturnType
{
    SaleReturnAgainBill = 1,
    SaleReturnOther = 2,
    PurchaseReturn = 3,
    PurchaseReturnAgainBill = 4,
    SaleReturnCancel = 5,
    PurchaseReturnCancel = 6
}

public enum ClaimType
{
    Pending = 1,
    Complate = 2,
    Cancel = 3
}

public enum InwardType
{
    Purchase = 1,
    Delivery = 2,
    Receipt = 3,
    DirectReceipt = 4,
    Cancel = 5
}

public enum ApplicableOn
{
    ItemQuantity = 1,
    ItemAmount = 2,
    BillAmount = 3
}

public enum BasedOn
{
    Invoice = 1,
    Item = 2,
    Unit = 3
}

public enum CreditNoteType
{
    MasterScheme = 'M',
    SaleReturn = 'R',
    Cancel = 'L'
}


public enum SaleOrderType
{
    Order = 11,
    Delivery = 12,
    DirectSale = 13,
    Cancel = 14,
}

public enum CType //Customer Type
{
    Company = 1,
    Outlet = 2,
    Customer = 3,
    Retailer = 4
}

public enum OWHS
{
    Regular = 'R',
    Return = 'N'
}

public enum PaymentMode
{
    Cash = 1,
    Card = 2,
    Cheque = 3,
    BankTransfer = 4,
    CreditNote = 5,
    CouponSale = 6,
    GiftSale = 7
}

public enum PurchasePaymentMode
{
    Cash = 1,
    Card = 2,
    Cheque = 3,
    BankTransfer = 4
}

public enum InventoryType //Inventory (Update,Return,Transfer) Type
{
    Vehicle = 'V',
    Godown = 'G',
    Branch = 'B'
}

public enum Journal
{
    DailyActivity = 'D',
    Manual = 'M',
    CreditNote = 'C',
    Order = 'O',
    PurChaseOrder = 'p',
    SaleBill = 'S'
}

public enum VehicleType
{
    MiniTruck = 'M',
    Rickshok = 'R',
    HeavyTruck = 'H'
}

public enum FuleType
{
    Petrol = 'P',
    Diesel = 'D',
    CNG = 'C',
    LPG = 'L'
}

public enum WheelType
{
    Three_Wheeler = '3',
    Four_Wheeler = '4',
    Six_Wheeler_Above = '6'
}

public enum JEType
{
    Cash = 'C',
    Bank = 'B',
    Contract = 'T'
}

public enum QuestionMaster
{
    // Type
    Product = 'P',
    Service = 'S',
    Other = 'O',

    //DocType
    FeedBack = 'F',
    Campaign = 'C',
    SecurityQuestion = 'S'
}

public enum CancelFlag
{
    AUTO = 1,
    COMP = 2,
    EMP = 3,
    DIST = 4,
    DELR = 5
}
public enum MenuAccessibleType //UserType
{
    DMS = 'D',
    Mechanic = 'M',
    Both = 'B'
}
public class EnumList
{
    public static IEnumerable<KeyValuePair<int, string>> Of<T>()
    {
        return Enum.GetValues(typeof(T)).Cast<T>().Select(p => new KeyValuePair<int, string>(Convert.ToInt32(p), p.ToString())).ToList();
    }
}

public class Constant
{
    public const string AuthKey = "=vCd&DBj=";

    public const string DateFormat = "dd/MM/yyyy";
    public const string TimeFormat = "hh:mm:ss";
    public const string Currency = "INR";

    public const string VehiclePhoto = "~/Document/Vehicle/Photo/";
    public const string CustomerPhoto = "~/Document/Customer/";
    public const string MaterialPhoto = "~/Document/Material/";
    public const string ItemGroupPhoto = "~/Document/MaterialGroup/";
    public const string ItemSubGroupPhoto = "~/Document/MaterialSubGroup/";
    public const string BannerPhoto = "~/Document/Banner/";
    public const string OutletPhoto = "~/Document/Outlet/";
    public const string EmployeePhoto = "~/Document/Employee/";
    public const string VehicleDoc = "~/Document/Vehicle/Document/";
    public const string BreakDownDoc = "~/Document/Vehicle/BreakDown/";
    public const string ClaimDoc = "~/Document/Vehicle/Claim/";
    public const string InsuranceDoc = "~/Document/Vehicle/Insurance/";
    public const string SchMaintenance = "~/Document/Vehicle/ScheduleMaintenance/";
    public const string Cheques = "~/Document/Cheques/";
    public const string Audio = "~/Document/Audio/";
    public const string Reports = "~/Document/Reports/";
    public const string Wastage = "~/Document/Wastage/";

    public const string AssetRegister = "~/Document/Asset/Register/";
    public const string AssetTransfer = "~/Document/Asset/Transfer/";
    public const string AssetConfirm = "~/Document/Asset/Confirm/";
}

public class QWeek
{
    public QWeek()
    {

    }
    public QWeek(int cfirst, int clast)
    {
        first = cfirst;
        last = clast;
    }
    public int first { get; set; }
    public int last { get; set; }
}

[Serializable]
public class Payment
{
    public string BankName { get; set; }
    public string Mode { get; set; }
    public string Notes { get; set; }
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string DocumentNumber { get; set; }
    public int InwardID { get; set; }
    public int VendorID { get; set; }
    public decimal VParentID { get; set; }
    public string VendorName { get; set; }
    public string BillNumber { get; set; }
    public decimal Total { get; set; }
    public decimal Paid { get; set; }
    public decimal Pending { get; set; }
}

public class Common
{
    public static QWeek GetQDays(DateTime date, int totalq, int nos)
    {
        List<QWeek> list = new List<QWeek>();

        int totalDays = DateTime.DaysInMonth(date.Year, date.Month);

        DateTime lastdate = new DateTime(date.Year, date.Month, DateTime.DaysInMonth(date.Year, date.Month));

        int dayInQ = totalDays / totalq;
        int first = 0, last = 0;
        for (int j = 0; j < totalq; j++)
        {
            if (j == 0)
            {
                first = 1;
                last = dayInQ;

                list.Add(new QWeek(first, last));

            }
            else if (j == (totalq - 1))
            {

                QWeek res = list[j - 1];

                first = res.last + 1;
                last = int.Parse(lastdate.ToString("dd/MM/yyyy").Split("/".ToArray())[0]);

                list.Add(new QWeek(first, last));
            }
            else
            {
                QWeek res = list[j - 1];

                first = res.last + 1;
                last = ((first + dayInQ) - 1);

                list.Add(new QWeek(first, last));
            }
        }
        return list[nos - 1];
    }

    public static string Get8Digits()
    {
        var bytes = new byte[8];
        var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        UInt64 random = BitConverter.ToUInt64(bytes, 0) % 10000000000;
        return String.Format("{0:D10}", random);
    }

    public static IEnumerable<Control> GetAll(Control control, Type type)
    {
        var controls = control.Controls.Cast<Control>();

        return controls.SelectMany(ctrl => GetAll(ctrl, type)).Concat(controls).Where(c => c.GetType() == type);
    }

    public static IDictionary<string, string> GetAll<TEnum>() where TEnum : struct
    {
        var enumerationType = typeof(TEnum);

        if (!enumerationType.IsEnum)
            throw new ArgumentException("Enumeration type is expected.");

        var dictionary = new Dictionary<string, string>();
        var ENUMS = Enum.GetValues(enumerationType);
        foreach (string value in ENUMS)
        {
            var name = Enum.GetName(enumerationType, value);
            dictionary.Add(value, name);
        }

        return dictionary;
    }

    public static int GetKey(EntityObject table, decimal parentID)
    {
        int KeyID = 0;
        using (var ctx = new DDMSEntities())
        {
            if (parentID > 0)
            {
                var dat = table.EntityKey;
            }
            else
            {

            }
        }
        return KeyID;
    }

    public static void AttachUpdated(ObjectContext obj, EntityObject objectDetached)
    {
        if (objectDetached.EntityState == EntityState.Detached)
        {
            object original = null;
            if (obj.TryGetObjectByKey(objectDetached.EntityKey, out original))
                obj.ApplyCurrentValues(objectDetached.EntityKey.EntitySetName, objectDetached);
            else
                throw new ObjectNotFoundException();
        }
    }

    public static bool IsImageValid(Stream stream)
    {
        try
        {
            var i = System.Drawing.Image.FromStream(stream);
            stream.Seek(0, SeekOrigin.Begin);
            return ImageFormat.Png.Equals(i.RawFormat)
                || ImageFormat.Gif.Equals(i.RawFormat)
                || ImageFormat.Jpeg.Equals(i.RawFormat)
                || ImageFormat.Bmp.Equals(i.RawFormat);
        }
        catch
        {
            return false;
        }
    }
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
    public static string EncryptNumber(String Key, String Str)
    {
        byte[] keyArray;
        byte[] toEncryptArray = UTF8Encoding.UTF8.GetBytes(Str);

        MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
        keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(Key));

        TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
        tdes.Key = keyArray;
        tdes.Mode = CipherMode.ECB;
        tdes.Padding = PaddingMode.PKCS7;

        ICryptoTransform cTransform = tdes.CreateEncryptor();
        byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);

        return Convert.ToBase64String(resultArray, 0, resultArray.Length);
    }

    public static string DecryptNumber(String Key, String Str)
    {


        //string a = EncryptNumber("D0091264", "vadi@123");
        byte[] keyArray;
        byte[] toEncryptArray = Convert.FromBase64String(Str);
        MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
        keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(Key));
        TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
        tdes.Key = keyArray;
        tdes.Mode = CipherMode.ECB;
        tdes.Padding = PaddingMode.PKCS7;
        ICryptoTransform cTransform = tdes.CreateDecryptor();
        byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
        return UTF8Encoding.UTF8.GetString(resultArray);
    }

    public static List<string> GetMACAddress()
    {
        NetworkInterface[] nics = NetworkInterface.GetAllNetworkInterfaces();
        List<string> sMacAddress = new List<string>();
        int i = 0;
        foreach (NetworkInterface adapter in nics)
        {
            IPInterfaceProperties properties = adapter.GetIPProperties();
            sMacAddress.Add(adapter.GetPhysicalAddress().ToString());

            i += 1;
        }
        return sMacAddress;
    }

    public static DateTime DateTimeConvert(string Date)
    {
        var temp = Date.Split("/".ToCharArray());

        int Day = Convert.ToInt32(temp[0]);
        int Month = Convert.ToInt32(temp[1]);
        int Year = Convert.ToInt32(temp[2]);

        return new DateTime(Year, Month, Day);
    }

    public static Boolean DateTimeConvert(string Date, out DateTime Dt)
    {
        Dt = DateTime.Now;
        try
        {

            var temp = Date.Split("/".ToCharArray());

            int Day = Convert.ToInt32(temp[0]);
            int Month = Convert.ToInt32(temp[1]);
            int Year = Convert.ToInt32(temp[2]);

            Dt = new DateTime(Year, Month, Day);
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    public static String DateTimeConvert(DateTime Date)
    {
        string Day = Date.Day.ToString("D2");
        string Month = Date.Month.ToString("D2");
        string Year = Date.Year.ToString("D4");
        return Day + '/' + Month + '/' + Year;
    }

    public static string GetString(Exception ex)
    {
        try
        {
            if (ex.InnerException != null)
                if (ex.InnerException.InnerException != null)
                    return ex.InnerException.InnerException.Message.Replace("'", "").Replace(@"""", "");
                else
                    return ex.InnerException.Message.Replace("'", "").Replace(@"""", "");
            else
                return ex.Message.Replace("'", "").Replace(@"""", "");
        }
        catch (Exception)
        {
            return "";
        }
    }

    public static string GetMailBodyPurchaseReturn(int ORETID, decimal ParentID, string ErrMsg = "")
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            string mailBody = "";
            ORET objORET = ctx.ORETs.FirstOrDefault(x => x.ORETID == ORETID && x.ParentID == ParentID);
            CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID && x.IsDeleted == false);

            mailBody += "<html><body style='background:url(http://vadilalicecreams.com/wp-content/uploads/2015/04/doodle.jpg)'>";
            mailBody += "<div style='padding:5px;width:100%'>";
            mailBody += "<table border='0' width='100%'><tr><td width='30%'><img src='http://vadilalgroup.com/wp-content/uploads/2013/08/cropped-images.png' alt='vadilal' style='float:left;' /></td><td width='70%' align='right'><strong style='font-size:30px;margin-left:-30%'>Purchase Return</strong></td></tr></table>";
            mailBody += "<table style='border:0;background-color:#E6E6E6;margin-top:5px' width='100%'>";
            mailBody += "<tr><td width='50%'>";
            if (!string.IsNullOrEmpty(ErrMsg))
            {
                mailBody += "<table><tr><td style='background-color: yellow; color: red; font-weight: 700;'> " + ErrMsg + " </td></tr></table>";
            }
            mailBody += "<table>";
            int pid = Convert.ToInt32(objORET.Ref1);
            mailBody += "<tr><td><strong>Order No.</strong> </td><td> " + objORET.InvoiceNumber.ToString() + "</td></tr>";
            mailBody += "<tr><td><strong>Ref No.</strong> </td><td> " + ctx.ORETs.FirstOrDefault(x => x.ParentID == objORET.VendorParentID && x.ORETID == pid).InvoiceNumber.ToString() + "</td></tr>";
            mailBody += "<tr><td><strong>Order Date</strong> </td><td> " + objORET.Date.ToString("dd/MM/yyyy") + " </td></tr>";
            mailBody += "<tr><td><strong>Contact No</strong> </td><td> " + objCRD1.OCRD.Phone + "</td></tr>";
            mailBody += "<tr><td><strong>Email</strong> </td><td> " + objCRD1.OCRD.EMail1 + "</td></tr>";
            mailBody += "</table>";
            mailBody += "</td>";
            mailBody += "<td align='right' width='50%'>";
            mailBody += "<div style='float:right'>";
            mailBody += "<h3 style='margin:0'>" + objCRD1.OCRD.CustomerName + "</h3> </br>";
            mailBody += "<div>" + objCRD1.Address1 + "</div>";
            mailBody += "<div>" + objCRD1.Address2 + " </div>";
            mailBody += "<div>" + objCRD1.Location + " - " + objCRD1.LandMark + " </div>";
            mailBody += "<div>" + objCRD1.OCTY.CityName + " - " + objCRD1.ZipCode + "</div>";
            mailBody += "<div>" + objCRD1.OCST.StateName + "</div>";
            mailBody += "</div>";
            mailBody += "</td>";
            mailBody += "</tr>";
            mailBody += "</table>";
            mailBody += "</br></br>";
            mailBody += "<table border='1' style='border-collapse:collapse;margin-top:5px' width='100%'>";
            mailBody += "<thead style='background-color:#E6E6E6'><tr>";
            mailBody += "<th width='55%'>Product</th><th width='15%'>Price</th><th width='15%'>Qty</th><th width='15%'>Total</th></tr></thead>";
            mailBody += "<tbody >";

            string itemDetails = "";
            foreach (RET1 objRET1 in objORET.RET1)
            {
                itemDetails += "<tr ><td >" + objRET1.OITM.ItemName + "</td><td align='center'>" + objRET1.Price.ToString("0.00") + "</td><td align='center'>" + objRET1.Quantity.ToString("0") + "</td><td align='center'>" + objRET1.Subtotal.ToString("0.00") + "</td></tr>";
            }

            mailBody += itemDetails;
            mailBody += "</tbody>";
            mailBody += "</table>";
            mailBody += "</br>";
            mailBody += "<table width='100%' style='margin-top:5px'>";
            mailBody += "<tr>";
            mailBody += "<td width='70%'>";
            mailBody += "<strong>Amount in words</strong>";

            Service wb = new Service();
            string amount = wb.changeCurrencyToWords(objORET.Amount.ToString());

            string terms = ctx.OEMPs.FirstOrDefault(x => x.EmpID == 1 && x.ParentID == ParentID).TermsNConditions;
            //string termsCondition = "";
            //if (!string.IsNullOrEmpty(terms))
            //{
            //    termsCondition = terms.Replace("#", "<br/> * ");
            //}
            //else
            //{
            //    termsCondition = "Icecream might be loose at the time of delivery due to outside temperature";
            //}

            mailBody += "<div>" + amount + "</div>";
            mailBody += "</td><td width='30%' align='right'>";
            mailBody += "<table width='80%'>";
            mailBody += "<tr><td><strong>Sub Total</strong></td><td>" + objORET.SubTotal.Value.ToString("0.00") + "</td></tr>";
            mailBody += "<tr><td><strong>Tax</strong></td><td>" + objORET.Tax.Value.ToString("0.00") + "</td></tr>";
            mailBody += "<tr><td><strong>Discount</strong><hr></td><td>0.00<hr></td></tr>";
            mailBody += "<tr><td><strong>Rounding</strong><hr></td><td>" + objORET.Rounding.Value.ToString("0.00") + "<hr></td></tr>";
            mailBody += "<tr><td><strong>Total</strong></td><td><strong>" + objORET.Amount.ToString("0.00") + "</strong></td></tr>";
            mailBody += "</table>";
            mailBody += "</td></tr>";
            mailBody += "<tr><td colspan='2'><strong>Terms & Conditions :</strong></br><div>" + terms + "</div></td></tr></table>";
            mailBody += "</br>";

            mailBody += "<h3 align='center' style='margin:0'>* Thank you for your Order *</h3>";
            mailBody += "<hr>";
            mailBody += "<div align='center' style='font-size:12px'>Vadilal Industries Ltd,Nr. Navrangpura Rly Crossing,Navangapura, Ahmedabad -9,Gujarat,India</div>";
            mailBody += "<div align='center' style='font-size:12px'>Tele: +91 79 26564018 to 24 Email : info@vadilalgroup.com</div><hr>";
            mailBody += "<div align='center'><span>This is an electronically generated invoice and does not require a signatury</span></div></div>";
            mailBody += "</body></html>";

            return mailBody;
        }
    }


    public static string GetMailBodyPurchase(int InwardID, decimal ParentID, string ErrMsg = "")
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            string mailBody = "";
            OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == InwardID && x.ParentID == ParentID);
            CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID && x.IsDeleted == false);
            string LogoSRC = "http://dms.vadilalgroup.com/Images/CompanyLogo/" + GetLogo(ParentID);
            //OCRD ObjCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
            //Int16 OptionId = 1;
            //if (ObjCRD.Type == 2)
            //{
            //    OptionId = 1;
            //}
            //else
            //{
            //    OptionId = 2;
            //}

            //Int16 RegionId = Convert.ToInt16(objCRD1.StateID);
            //ODCM ObjODCM = ctx.ODCMs.FirstOrDefault(x => x.RegionId == RegionId && x.OptionId == OptionId);
            //
            //if (ObjODCM != null)
            //{
            //    LogoSRC = "http://dms.vadilalgroup.com/Images/CompanyLogo/" + ObjODCM.Logo;
            //}

            ////http://dms.vadilalgroup.com/Images/LOGO.png
            mailBody += "<html><body>";
            mailBody += "<div style='padding:5px;width:794px'>";
            mailBody += "<table border='0' width='100%'><tr><td width='30%'><img src='" + LogoSRC + "' alt='vadilal' style='width: 120px; float:left;' /></td><td width='70%' align='right'><strong style='font-size:30px;margin-left:-30%'>Proforma Invoice</strong></td></tr></table>";
            mailBody += "<table style='border:0;background-color:#E6E6E6;margin-top:5px' width='100%'>";
            mailBody += "<tr><td width='50%'>";
            if (!string.IsNullOrEmpty(ErrMsg))
            {
                mailBody += "<table><tr><td style='background-color: yellow; color: red; font-weight: 700;'> " + ErrMsg + " </td></tr></table>";
            }
            mailBody += "<table>";
            mailBody += "<tr><td><strong>Order No.</strong> </td><td> " + objOMID.InvoiceNumber + "</td></tr>";
            mailBody += "<tr><td><strong>Order Date</strong> </td><td> " + objOMID.Date.ToString("dd/MM/yyyy hh:mm tt") + " </td></tr>";
            mailBody += "<tr><td><strong>Contact No</strong> </td><td> " + objCRD1.OCRD.Phone + "</td></tr>";
            mailBody += "<tr><td><strong>Email</strong> </td><td> " + objCRD1.OCRD.EMail1 + "</td></tr>";
            mailBody += "<tr><td><strong>Plant</strong> </td><td> " + (objOMID.PlantID.HasValue ? ctx.OPLTs.Where(x => x.PlantID == objOMID.PlantID.Value).Select(x => x.PlantCode + " # " + x.PlantName).FirstOrDefault() : "") + "</td></tr>";
            mailBody += "</table>";
            mailBody += "</td>";
            mailBody += "<td align='right' width='50%'>";
            mailBody += "<div style='float:right'>";
            mailBody += "<h3 style='margin:0'>" + objCRD1.OCRD.CustomerName + "</h3></br>";
            mailBody += "<div><h3 style='margin:0'>" + objCRD1.OCRD.CustomerCode + "</h3></div>";
            mailBody += "<div>" + objCRD1.Address1 + "</div>";
            mailBody += "<div>" + objCRD1.Address2 + " </div>";
            mailBody += "<div>" + objCRD1.Location + " - " + objCRD1.LandMark + " </div>";
            mailBody += "<div>" + objCRD1.OCTY.CityName + " - " + objCRD1.ZipCode + "</div>";
            mailBody += "<div>" + objCRD1.OCST.StateName + "</div>";
            mailBody += "</div>";
            mailBody += "</td>";
            mailBody += "</tr>";
            mailBody += "</table>";
            mailBody += "</br></br>";
            mailBody += "<table border='1' style='border-collapse:collapse;margin-top:5px' width='100%'>";
            mailBody += "<thead style='background-color:#E6E6E6'><tr>";
            mailBody += "<th width='5%'>No.</th><th width='10%'>Item Code</th><th width='55%'>Item Name</th><th width='10%'>Price</th><th width='8%'>Qty</th><th width='10%'>Total</th></tr></thead>";
            mailBody += "<tbody>";


            Service wb = new Service();
            string amount = wb.changeCurrencyToWords(objOMID.Total.ToString());

            string itemDetails = "";
            int i = 1;
            foreach (MID1 objMID1 in objOMID.MID1)
            {
                itemDetails += "<tr ><td align='right'>" + (i++).ToString() + "</td><td >" + objMID1.OITM.ItemCode + "</td><td >" + objMID1.OITM.ItemName + "</td><td align='right'>" + objMID1.Price.ToString("0.00") + "</td><td align='right'>" + objMID1.RequestQty.ToString("0") + "</td><td align='right'>" + objMID1.SubTotal.ToString("0.00") + "</td></tr>";
            }

            mailBody += itemDetails;
            mailBody += "<tr><td colspan='6'></td>";
            mailBody += "<tr><td colspan='3'></td><td align='right' style='border-bottom: 1px solid #000000;'><strong>Total</strong></td>";
            mailBody += "<td align='right'>" + objOMID.MID1.Sum(x => x.RequestQty).ToString("0") + "</td>";
            mailBody += "<td align='right'>" + objOMID.SubTotal.Value.ToString("0.00") + "</td></tr>";

            mailBody += "<tr><td colspan='4' style='border-bottom: 1px solid #FFFFFF;border-top: 1px solid #FFFFFF;'></td>";
            mailBody += "<td align='right'><strong>Discount</strong></td><td align='right'>" + objOMID.Discount.Value.ToString("0.00") + "</td></tr>";

            mailBody += "<tr><td colspan='4'><strong>Amount in words</strong></td>";
            mailBody += "<td align='right'><strong>GST</strong></td><td align='right'>" + objOMID.Tax.Value.ToString("0.00") + "</td></tr>";

            mailBody += "<tr><td colspan='4' style='border-bottom: 1px solid #FFFFFF;border-top: 1px solid #FFFFFF;'>" + amount + "</td>";
            mailBody += "<td align='right'><strong>Rounding</strong></td><td align='right'>" + objOMID.Rounding.Value.ToString("0.00") + "</td></tr>";

            mailBody += "<tr><td colspan='4'></td>";
            mailBody += "<td align='right'><strong>Total</strong></td><td align='right'>" + objOMID.Total.Value.ToString("0.00") + "</td></tr>";

            mailBody += "<tr><td colspan='6'><strong>Terms & Conditions :</strong></br><div>" + ctx.OEMPs.FirstOrDefault(x => x.EmpID == 1 && x.ParentID == ParentID).TermsNConditions + "</div></td></tr>";

            mailBody += "</tbody>";
            mailBody += "</table>";

            mailBody += "<h3 align='center' style='margin:0'>* Thank you for your Order *</h3>";
            mailBody += "<hr>";
            mailBody += "<div align='center' style='font-size:12px'>Vadilal Industries Ltd,Nr. Navrangpura Rly Crossing,Navangapura, Ahmedabad -9,Gujarat,India</div>";
            mailBody += "<div align='center' style='font-size:12px'>Tele: +91 79 26564018 to 24 Email : info@vadilalgroup.com</div><hr>";
            mailBody += "<div align='center'><span>This is an electronically generated invoice and does not require a signatury</span></div></div>";
            mailBody += "</body></html>";

            return mailBody;
        }
    }

    public static void SendMail(string subject, string mailBody, string email, string ccemail = "", List<string> strAttachments = null, List<Attachment> Attachments = null)
    {

        MailMessage mail = new MailMessage();

        OEML objMail = null;
        using (var ctx = new DDMSEntities())
        {
            objMail = ctx.OEMLs.FirstOrDefault();
            try
            {
                mail.From = new MailAddress(objMail.Email);
                mail.To.Add(email);
                if (ccemail != "")
                {
                    string[] CCId = ccemail.Split(';');
                    foreach (string CCEmail in CCId)
                    {
                        mail.CC.Add(new MailAddress(CCEmail)); //Adding Multiple CC email Id  
                    }
                }
                //mail.CC.Add(ccemail);

                if (strAttachments != null)
                {
                    foreach (string item in strAttachments)
                    {
                        mail.Attachments.Add(new Attachment(item));
                    }
                }

                if (Attachments != null)
                {
                    foreach (Attachment item in Attachments)
                    {
                        mail.Attachments.Add(item);
                    }
                }

                mail.Body = mailBody;
                mail.IsBodyHtml = true;
                mail.Subject = subject;
                SmtpClient smt = new SmtpClient(objMail.Domain);
                smt.Port = objMail.Port;
                smt.UseDefaultCredentials = false;
                if (!string.IsNullOrEmpty(objMail.UserName))
                    smt.Credentials = new NetworkCredential(objMail.UserName, objMail.Password);
                else
                    smt.Credentials = new NetworkCredential(objMail.Email, objMail.Password);
                smt.EnableSsl = false;
                smt.Send(mail);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                mail.Dispose();
            }
        }
    }

    public static void GetExcelBody(string filepath, int InwardID, decimal ParentID)
    {
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand cm = new SqlCommand();
            cm.CommandType = System.Data.CommandType.StoredProcedure;
            cm.CommandText = "GetExcelBodyForPO";
            cm.Parameters.AddWithValue("@InwardID", InwardID);
            cm.Parameters.AddWithValue("@ParentID", ParentID);
            DataSet Ds = objClass.CommonFunctionForSelect(cm);
            if (Ds != null && Ds.Tables[0] != null && Ds.Tables[0].Rows.Count > 0)
            {
                DataTable dt = Ds.Tables[0];
                TransferCreateCSV(filepath, dt, dt.Select());
            }
        }
        catch (Exception)
        {
            throw;
        }
        finally
        {

        }

    }
    public static void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }
    public static void TransferCreateCSV(string filePath, DataTable dt, DataRow[] drs)
    {
        StreamWriter sw = null;
        int iColCount = dt.Columns.Count;
        if (!File.Exists(filePath))
        {
            sw = new StreamWriter(filePath, false);

            //for (int i = 0; i < iColCount; i++)
            //{
            //    sw.Write(dt.Columns[i]);
            //    if (i < iColCount - 1)
            //    {
            //        sw.Write(",");
            //    }
            //}
            //sw.Write(sw.NewLine);
        }
        else
            sw = new StreamWriter(filePath, true);

        foreach (DataRow dr in drs)
        {
            for (int i = 0; i < iColCount; i++)
            {
                if (!Convert.IsDBNull(dr[i]))
                {
                    sw.Write(dr[i].ToString());
                }
                if (i < iColCount - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        sw.Close();
    }

    public static string GetLogo(Decimal ParentID)
    {
        string LogoSRC = "";
        using (DDMSEntities ctx = new DDMSEntities())
        {
            //if (ParentID != 1000010000000000)
            //{
                CRD1 objCRD1 = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID && x.IsDeleted == false);
                OCRD ObjCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                Int16 OptionId = 1;
                if (ObjCRD.Type == 2 || ObjCRD.Type == 3)
                {
                    OptionId = 1;
                }
                else
                {
                    OptionId = 2;
                }

                Int16 RegionId = Convert.ToInt16(objCRD1.StateID);
                ODCM ObjODCM = ctx.ODCMs.FirstOrDefault(x => x.RegionId == RegionId && x.OptionId == OptionId);

                if (ObjODCM != null)
                {
                    //LogoSRC = "http://dms.vadilalgroup.com/Images/CompanyLogo/" + ObjODCM.Logo;
                    // LogoSRC = Server.MapPath("~/Images/CompanyLogo/" + ObjODCM.Logo);
                    LogoSRC = ObjODCM.Logo;
                }
            //}
            //else
            //{
            //    EMP1 ObjEmp = ctx.EMP1.FirstOrDefault(x => x.EmpID == UserId);
            //    Int16 RegionId = Convert.ToInt16(ObjEmp.StateID);
            //    ODCM ObjODCM = ctx.ODCMs.FirstOrDefault(x => x.RegionId == RegionId && x.OptionId == 1);
            //    if (ObjODCM != null)
            //    {
            //        LogoSRC = ObjODCM.Logo;
            //    }
            //}
        }
        return LogoSRC;
    }
}

[Serializable]
public class DisData
{
    public int Value { get; set; }
    public string Text { get; set; }
}

[Serializable]
public class DisData2
{
    public DisData2()
    {

    }
    public DisData2(string value, string text)
    {
        Value = value;
        Text = text;
    }

    public string Value { get; set; }
    public string Text { get; set; }
}

[Serializable]
public class DisData3
{
    public decimal Value { get; set; }
    public string Text { get; set; }
    public string GSTIN { get; set; }
    public string Name { get; set; }
    public decimal BillToPartyID { get; set; }
    public string BillToPartyCode { get; set; }
}

public class MessageData
{
    public string PID { get; set; }
    public string Type { get; set; }
    public string Name { get; set; }
    public string GID { get; set; }
}

[Serializable]
public class NewItemData
{
    public int ItemID { get; set; }
    public int UnitID { get; set; }
    public string Unitname { get; set; }
    public Decimal UnitPrice { get; set; }
    public Decimal PriceTax { get; set; }
    public Decimal Quantity { get; set; }
    public Decimal TaxID { get; set; }
}

[Serializable]
public partial class IOUData
{
    public Decimal CustomerID { get; set; }
    public int ItemID { get; set; }
    public int UnitID { get; set; }
    public string Unitname { get; set; }
    public Decimal UnitPrice { get; set; }
    public Decimal Quantity { get; set; }
    public Decimal Total { get; set; }
    public Decimal BoxRate { get; set; }
    public int MapQty { get; set; }
    public int MainID { get; set; }
    public int LineID { get; set; }
}

[Serializable]
public partial class ItemData
{
    public int POS1ID { get; set; }
    public int MainID { get; set; }
    public int ItemID { get; set; }
    public string ItemCode { get; set; }
    public string ItemName { get; set; }
    public string UnitName { get; set; }
    public int UnitID { get; set; }
    public Nullable<int> SchemeID { get; set; }
    public decimal OrderQuantity { get; set; }
    public decimal Quantity { get; set; }
    public decimal TotalQty { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal PriceTax { get; set; }
    public decimal SubTotal { get; set; }
    public decimal MapQty { get; set; }
    public decimal Tax { get; set; }
    public decimal Discount { get; set; }
    public decimal Price { get; set; }
    public decimal Total { get; set; }
    public bool AddOn { get; set; }
    public decimal Scheme { get; set; }
    public decimal ItemScheme { get; set; }
    public decimal AvailQty { get; set; }
    public Nullable<int> ReasonID { get; set; }
    public int TaxID { get; set; }
    public string RANKNO { get; set; }
    public decimal MRP { get; set; }
    public decimal NormalPrice { get; set; }
    public int IsQPS { get; set; }
}

[Serializable]
public partial class SchemeData
{
    public Boolean Check { get; set; }
    public string ScName { get; set; }
    public int BasedOn { get; set; }
    public string Mode { get; set; }
    public int ItemID { get; set; }
    public string ItemCode { get; set; }
    public string ItemName { get; set; }
    public int SchemeID { get; set; }
    public int UnitID { get; set; }
    public int TaxID { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Tax { get; set; }
    public decimal Discount { get; set; }
    public decimal Price { get; set; }
    public decimal Total { get; set; }
    public decimal PriceTax { get; set; }
    public string UnitName { get; set; }
    public string ContraTax { get; set; }
    public decimal SubTotal { get; set; }
    public decimal SaleAmount { get; set; }
    public decimal MRP { get; set; }
    public decimal RateForScheme { get; set; }
    public decimal NormalPrice { get; set; }
    public string AlertMessage { get; set; }
    public string QPSQTY { get; set; }
    public decimal Occurance { get; set; }
    public string IsPair { get; set; }
    public decimal HigherLimit { get; set; }
    public decimal LowerLimit { get; set; }
    public String DiscType { get; set; }
    public decimal AvailQty { get; set; }
    public int MainId { get; set; }
}
[Serializable]
public partial class ItemWiseDiscountData
{
    public string Mode { get; set; }
    public int ItemID { get; set; }
    public int SchemeID { get; set; }
    public decimal Quantity { get; set; }

    public decimal CompanyContri { get; set; }
    public decimal DistributorContri { get; set; }
    public decimal Discount { get; set; }
}
namespace System.Runtime.CompilerServices
{
    public class ExtensionAttribute : Attribute { }
}
[Serializable]
public class InvItemData
{
    public int ItemID { get; set; }
    public int UnitID { get; set; }
    public string Unitname { get; set; }
    public Decimal UnitPrice { get; set; }
    public Decimal PriceTax { get; set; }
    public int Quantity { get; set; }
    public Decimal TaxID { get; set; }
}
[Serializable]
public partial class InventoryItemData
{
    public int POS1ID { get; set; }
    public int MainID { get; set; }
    public int ItemID { get; set; }
    public string ItemCode { get; set; }
    public string ItemName { get; set; }
    public string UnitName { get; set; }
    public int UnitID { get; set; }
    public Nullable<int> SchemeID { get; set; }
    public int OrderQuantity { get; set; }
    public int Quantity { get; set; }
    public int TotalQty { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal PriceTax { get; set; }
    public decimal SubTotal { get; set; }
    public int MapQty { get; set; }
    public decimal Tax { get; set; }
    public decimal Discount { get; set; }
    public decimal Price { get; set; }
    public decimal Total { get; set; }
    public bool AddOn { get; set; }
    public decimal Scheme { get; set; }
    public decimal ItemScheme { get; set; }
    public int AvailQty { get; set; }
    public Nullable<int> ReasonID { get; set; }
    public int TaxID { get; set; }
    public string RANKNO { get; set; }
    public decimal MRP { get; set; }
    public decimal NormalPrice { get; set; }
}
public class NotiData
{
    public NotiData(int menuid, string title, string body, int requestid, decimal custid)
    {
        Title = title;
        Body = body;
        RequestID = requestid;
        CustomerID = custid;
        MenuID = menuid;
    }
    public string Title { get; set; }
    public string Body { get; set; }
    public int RequestID { get; set; }
    public int MenuID { get; set; }
    public decimal CustomerID { get; set; }
}

public class OCTMData
{
    public string Customer { get; set; }
    public decimal CustomerID { get; set; }
    public string EmailID { get; set; }
    public DateTime? CreatedDate { get; set; }
    public DateTime? UpdatedDate { get; set; }
    public string CreatedBy { get; set; }
    public string UpdatedBy { get; set; }
}

public class ResponseData
{
    public bool Status { get; set; }
    public string Message { get; set; }
    public object Data { get; set; }
    public object Data1 { get; set; }
}