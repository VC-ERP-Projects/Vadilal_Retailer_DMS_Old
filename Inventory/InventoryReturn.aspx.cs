using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Inventory_InventoryReturn : System.Web.UI.Page
{
    #region Property

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
                            var unit = xml.Descendants("Inward");
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 1)
            {
                txtCustCode.Enabled = true;
                acetxtName.ContextKey = (CustType + 1).ToString();
            }
            else
            {
                txtCustCode.Enabled = false;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtCustCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
                }
            }
        }
    }

    #region Button Click

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Inventory.aspx");
    }

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(string Date, string CustID)
    {

        List<dynamic> result = new List<dynamic>();
        try
        {
            Decimal DistID = Convert.ToDecimal(CustID);

            using (DDMSEntities ctx = new DDMSEntities())
            {
                DateTime Fromdate = Convert.ToDateTime(Date);

                OINVR objONVR = ctx.OINVRs.Where(x => x.ParentID == DistID && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year)
                    .OrderByDescending(x => x.OINVRID).FirstOrDefault();

                if (objONVR != null)
                {
                    var RowData = (from a in ctx.INVR1
                                   join b in ctx.OCRDs on a.CustomerID equals b.CustomerID
                                   join c in ctx.OITMs on a.ItemID equals c.ItemID
                                   join d in ctx.OUNTs on a.UnitID equals d.UnitID
                                   where a.ParentID == objONVR.ParentID && a.OINVRID == objONVR.OINVRID && !a.IsDeleted
                                   select new
                                   {
                                       Date = a.Date,
                                       a.CustomerID,
                                       CustomerCode = b.CustomerCode + " # " + b.CustomerName + " # " + SqlFunctions.StringConvert((Decimal)b.CustomerID, 20, 0),
                                       b.CustomerName,
                                       c.ItemID,
                                       ItemCode = c.ItemCode + " - " + c.ItemName,
                                       c.ItemName,
                                       a.UnitID,
                                       d.UnitName,
                                       a.MapQty,
                                       a.MainPrice,
                                       a.Price,
                                       a.Quantity,
                                       a.Subtotal,
                                       a.OINVRID,
                                       a.INVR1ID,
                                       TempDate = a.Date
                                   }).ToList().Select(x => new
                                   {
                                       Date = x.Date.ToString("dd/MM/yyyy HH:mm"),
                                       x.CustomerID,
                                       x.CustomerCode,
                                       x.CustomerName,
                                       x.ItemID,
                                       x.ItemCode,
                                       x.ItemName,
                                       x.UnitID,
                                       x.UnitName,
                                       x.MapQty,
                                       x.MainPrice,
                                       x.Price,
                                       x.Quantity,
                                       x.Subtotal,
                                       x.OINVRID,
                                       x.INVR1ID,
                                       TempDate = x.Date

                                   }).OrderBy(x => x.CustomerCode).ThenBy(x => x.TempDate).ThenBy(x => x.ItemCode).ToList();

                    result.Add(RowData);

                    var HeaderDetail = new
                    {
                        objONVR.Notes,
                        objONVR.OINVRID,
                        objONVR.Subtotal,
                        objONVR.Rounding,
                        objONVR.Total
                    };

                    result.Add(HeaderDetail);
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR#" + "" + Common.GetString(ex));
        }
        return result;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetItems(string DistCode)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<string> Customer = new List<string>();
                Decimal DistID = Convert.ToDecimal(DistCode);
                Customer = ctx.OCRDs.Where(x => x.Active && !x.IsTemp && x.ParentID == DistID && x.Type == 3).Select(x => x.CustomerCode + " # " + x.CustomerName + " # " + SqlFunctions.StringConvert((Decimal)x.CustomerID, 20, 0)).ToList();
                List<string> items = ctx.LoadItemsForPurchase(DistID).ToList();

                result.Add(items);
                result.Add(Customer);
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> GetItemDetails(string txt, int WhsID, string CustID)
    {
        List<dynamic> result = new List<dynamic>();
        List<SaleItem_Result> Data = new List<SaleItem_Result>();
        List<DisData2> units = new List<DisData2>();
        try
        {
            var word = txt.Split("-".ToArray());
            var CustData = CustID.Split("#".ToArray()).ToList();
            Decimal DisID = Decimal.TryParse(CustData[0].ToString(), out DisID) ? DisID : 0;
            Decimal DealerID = Decimal.TryParse(CustData[1].ToString(), out DealerID) ? DealerID : 0;
            if (DisID == 0 || DealerID == 0)
            {
                result.Add("ERROR=" + "" + "Select proper Distributor OR Dealer.");
                return result;
            }

            if (word.Length > 1)
            {
                var ItemCode = word.First().Trim();
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int ItemID = ctx.OITMs.Where(x => x.ItemCode == ItemCode).Select(x => x.ItemID).DefaultIfEmpty(0).FirstOrDefault();
                    if (ItemID > 0)
                    {
                        //var ItemData = ctx.OGITMs.Where(x => x.ItemID == ItemID && x.DivisionlID.HasValue && x.PlantID.HasValue && x.Active).Select(x => new { PlantID = x.PlantID.Value, DivisionID = x.DivisionlID.Value }).ToList();

                        int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID).DivisionlID.Value;

                        if (DivisionlID > 0)
                        {
                            //int did = ItemData.FirstOrDefault().DivisionID;
                            int PriceListID = ctx.OGCRDs.Where(x => x.CustomerID == DealerID && x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                            //var plids = ItemData.Select(z => z.PlantID).ToList();
                            //int PriceListID = ctx.OGCRDs.Where(x => x.CustomerID == DisID && x.DivisionlID == did && x.PlantID.HasValue && x.PriceListID.HasValue && plids.Contains(x.PlantID.Value)).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                            if (PriceListID > 0)
                            {
                                //Data = ctx.PurchaseItem(DisID, PriceListID, 0, ItemID, 0, WhsID).ToList();
                                Data = ctx.SaleItem(DisID, DealerID, PriceListID, 0, ItemID, 0, WhsID, DisID).ToList();

                                if (Data.Count > 0)
                                {

                                    var UnitPrice = Data.FirstOrDefault().UnitPrice;

                                    units = ctx.ITM3.Where(x => x.ItemID == ItemID && x.UnitID == 2).Select(x => new DisData2 { Text = x.OUNT.UnitName, Value = SqlFunctions.StringConvert((double)x.UnitID) + "," + SqlFunctions.StringConvert((decimal)(UnitPrice / x.Qty), 10, 2) + "," + SqlFunctions.StringConvert((decimal)(UnitPrice), 10, 2) + "," + SqlFunctions.StringConvert((double)x.Qty) }).ToList();
                                    if (units.Count > 0)
                                    {
                                        result.Add(units);

                                        ItemData tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                            select new ItemData
                                                            {
                                                                ItemID = x.Key.ItemID,
                                                                ItemCode = x.Key.ItemCode,
                                                                ItemName = x.Key.ItemName,
                                                                AvailQty = x.Key.AvailQty,
                                                                TaxID = x.Key.TaxID
                                                            }).FirstOrDefault();

                                        result.Add(tmpList);
                                    }
                                    else
                                        result.Add("ERROR=" + "" + "Item mapping not found for selected item.");
                                }
                                else
                                    result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
                            }
                            else
                                result.Add("ERROR=" + "" + "This material is not extended in your plant, Please contact Marketing Department to resolve this issue");
                        }
                        else
                            result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
                    }
                    else
                        result.Add("ERROR=" + "" + "Select proper Item");
                }
            }
            else
                result.Add("ERROR=" + "" + "Select proper Item");
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {

        //List<dynamic> result = new List<dynamic>();SubTotal
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);




                Decimal DecNum = 0;
                var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());
                string Date = Convert.ToString(HeaderData["Date"]);
                string Pending = Convert.ToString(HeaderData["Pending"]);
                string SubTotal = Convert.ToString(HeaderData["SubTotal"]);
                string Total = Convert.ToString(HeaderData["Total"]);
                string Rounding = Convert.ToString(HeaderData["Rounding"]);
                string Notes = Convert.ToString(HeaderData["Notes"]);
                string OINVRID = Convert.ToString(HeaderData["OINVRID"]);
                string CustID = Convert.ToString(HeaderData["CustomerID"]);

                List<IOUData> BindList = new List<IOUData>();

                Decimal DistID = Convert.ToDecimal(CustID);
                if (DistID == 0)
                {
                    return "ERROR=Please select customer properly.";
                }

                
                if (!ctx.OCUMs.Any(x => x.CustID == DistID && x.Active == true))
                {
                    return "ERROR=Distributor unit entry not found please contact mktg department";
                }
                var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == DistID && x.Active == true).Unit;
                if (CustType != 2)
                {

                    if (!ctx.OCUMs.Any(x => x.CustID == UserID && x.OptionId == 1 && x.Unit == DistUnitId))
                    {
                        //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this unit claim.',3);", true);
                        return "ERROR=you are not authorize for this unit claim.";
                    }
                }
                foreach (var scheme in SchemeData)
                {
                    IOUData item = new IOUData();
                    item.CustomerID = scheme["CustomerID"];
                    item.ItemID = scheme["ItemID"];
                    if (scheme["Price"] == "")
                    {
                        scheme["Price"] = 0;
                    }
                    item.UnitPrice = scheme["Price"];
                    item.Quantity = scheme["txtReciept"];
                    item.Total = scheme["Total"];
                    item.MainID = scheme["MainID"];
                    item.LineID = scheme["LineNum"];
                    item.UnitID = scheme["UnitID"];
                    if (scheme["BoxRate"] == "")
                    {
                        scheme["BoxRate"] = 0;
                    }
                    item.BoxRate = scheme["BoxRate"];

                    if (scheme["MapQuantity"] == "")
                    {
                        scheme["MapQuantity"] = 0;
                    }
                    item.MapQty = scheme["MapQuantity"];
                    BindList.Add(item);
                }

                if (BindList.Count == 0)
                {
                    return "ERROR=Select Atleast one item.";
                }

                Decimal CustomerID = 0;
                if (Decimal.TryParse(CustID, out CustomerID) && CustomerID == 0)
                {
                    return "ERROR=Please select customer properly.";
                }

                Int32 OINVRid = Int32.TryParse(OINVRID, out OINVRid) ? OINVRid : 0;
                int HCount = ctx.GetKey("OINVR", "OINVRID", "", DistID, 0).FirstOrDefault().Value;
                DateTime date = Convert.ToDateTime(Date);
                DateTime FromDate = new DateTime(date.Year, date.Month, 1);
                DateTime ToDate = FromDate.AddMonths(1).AddDays(-1);

                if (OINVRid == 0 && ctx.OINVRs.Any(x => x.ParentID == DistID && x.FromDate == FromDate && x.ToDate == ToDate))
                {
                    return "ERROR=Same Month Entry Found. Please Refrash page & Try again.";
                }

                OINVR objOINVR = ctx.OINVRs.FirstOrDefault(x => x.OINVRID == OINVRid && x.ParentID == DistID && x.FromDate == FromDate && x.ToDate == ToDate);
                if (objOINVR == null)
                {
                    objOINVR = new OINVR();
                    objOINVR.OINVRID = HCount++;
                    objOINVR.ParentID = DistID;
                    ctx.OINVRs.Add(objOINVR);
                }
                objOINVR.FromDate = FromDate;
                objOINVR.ToDate = ToDate;
                objOINVR.CreatedDate = DateTime.Now;
                objOINVR.CreatedBy = UserID;
                objOINVR.Subtotal = Decimal.TryParse(SubTotal, out DecNum) ? DecNum : 0;
                objOINVR.Rounding = Decimal.TryParse(Rounding, out DecNum) ? DecNum : 0;
                objOINVR.Total = Decimal.TryParse(Total, out DecNum) ? DecNum : 0;
                objOINVR.Notes = Notes;
                objOINVR.IsCompany = CustType == 1 ? true : false;

                int Count = ctx.GetKey("INVR1", "INVR1ID", "", DistID, null).FirstOrDefault().Value;

                var Data = objOINVR.INVR1.ToList();

                Data.ForEach(x => x.IsDeleted = true);

                foreach (IOUData item in BindList)
                {
                    if (item.ItemID > 0 && item.Quantity > 0 && ctx.OITMs.Any(x => x.ItemID == item.ItemID))
                    {
                        if (Data.Any(x => x.INVR1ID == item.LineID) || ctx.OCRDs.Any(x => x.CustomerID == item.CustomerID && x.ParentID == objOINVR.ParentID))
                        {
                            INVR1 objINVR1 = Data.FirstOrDefault(x => x.INVR1ID == item.LineID);
                            if (objINVR1 == null)
                            {
                                objINVR1 = new INVR1();
                                objINVR1.INVR1ID = Count++;
                                objOINVR.ParentID = DistID;
                                objINVR1.Date = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                                objOINVR.INVR1.Add(objINVR1);
                            }
                            objINVR1.IsDeleted = false;
                            objINVR1.CustomerID = item.CustomerID;
                            objINVR1.ItemID = item.ItemID;
                            objINVR1.UnitID = item.UnitID;
                            objINVR1.Price = item.UnitPrice;
                            objINVR1.MainPrice = item.BoxRate;
                            objINVR1.Quantity = item.Quantity;
                            objINVR1.MapQty = item.MapQty;
                            objINVR1.Subtotal = item.Total;
                        }
                        else
                        {
                            return "ERROR=Invalid Customer found. Please refresh the page & try again.";
                        }
                    }
                    else
                    {
                        return "ERROR=Invalid Item found. Please refresh the page & try again.";
                    }
                }

                if (OINVRid == 0 && ctx.OINVRs.Any(x => x.ParentID == DistID && x.FromDate == FromDate && x.ToDate == ToDate))
                {
                    return "ERROR=Same Month Entry Found. Please Refrash page & Try again.";
                }

                ctx.SaveChanges();

                return "SUCCESS=Order Inserted Successfully";
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }

    #endregion
}