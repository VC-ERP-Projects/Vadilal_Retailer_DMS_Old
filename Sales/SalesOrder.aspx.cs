using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Data;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.Objects.SqlClient;
using System.Xml.Linq;
using System.IO;
using System.Data.Objects;

public partial class Sales_SalesOrder : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && (x.Type == "O") && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
                {
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Direct Receipt. !',3);", true);
                    //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                    return;
                }
            }
            txtBillNumber.Text = Common.Get8Digits();
        }
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(string Date)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            List<string> Customer = new List<string>();
            List<string> tempCustomer = new List<string>();
            List<string> Template = new List<string>();
            List<string> Vehicle = new List<string>();
            List<string> OrderForm = new List<string>();
            List<DisData> WareHouse = new List<DisData>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(Date), ParentID).FirstOrDefault();
                if (!String.IsNullOrEmpty(DayCloseData))
                {
                    result.Add("ERROR#" + "" + DayCloseData);
                    return result;
                }
                else
                {
                    Customer = ctx.OCRDs.Where(x => x.Active && x.ParentID == ParentID && !x.IsTemp).Select(x => x.CustomerCode + " - " + x.CustomerName).ToList();
                    tempCustomer = ctx.OCRDs.Where(x => x.Active && x.ParentID == ParentID && x.IsTemp).Select(x => x.CustomerCode + " - " + x.CustomerName).ToList();

                    Template = ctx.OTMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.TemplateID, 20, 0).Trim() + " - " + x.TemplateName).ToList();
                    Vehicle = ctx.OVCLs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.VehicleID, 20, 0).Trim() + " - " + x.VehicleNumber).ToList();
                    OrderForm = ctx.OPOS.Where(x => x.OrderType == 11 && x.ParentID == ParentID).OrderByDescending(x => x.SaleID).Select(x =>
                        SqlFunctions.StringConvert((Decimal)x.SaleID, 20, 0).Trim() + " - " + x.BillRefNo + " - " + x.OCRD.CustomerName).ToList();
                    WareHouse = ctx.OWHS.Where(x => x.Active && x.ParentID == ParentID).Select(x => new DisData { Value = x.WhsID, Text = x.WhsName }).ToList();

                    result.Add(Customer);
                    result.Add(Template);
                    result.Add(Vehicle);
                    result.Add(OrderForm);
                    result.Add(WareHouse);
                    result.Add(tempCustomer);
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
    public static List<dynamic> GetOrder(string odrderID)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            int SaleID;
            if (Int32.TryParse(odrderID, out SaleID) && SaleID > 0)
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.SaleID == SaleID && x.ParentID == ParentID && x.OrderType == 11);
                    if (objOPOS != null)
                    {
                        result.Add(objOPOS.OCRD.CustomerCode + " - " + objOPOS.OCRD.CustomerName);
                        if (objOPOS.VehicleID.HasValue)
                        {
                            result.Add(objOPOS.VehicleID + " - " + ctx.OVCLs.FirstOrDefault(x => x.VehicleID == objOPOS.VehicleID && x.ParentID == objOPOS.ParentID).VehicleNumber);
                        }
                        else
                            result.Add("");

                        result.Add(objOPOS.BillRefNo);
                        result.Add(objOPOS.Notes);
                        result.Add(objOPOS.MobilieNumber);

                        List<ItemData> BindList = new List<ItemData>();

                        var POS1s = objOPOS.POS1.Where(x => x.IsDeleted == false).ToList();

                        foreach (POS1 scheme in POS1s)
                        {
                            ItemData item = new ItemData();
                            item.ItemID = scheme.ItemID;
                            item.ItemCode = scheme.OITM.ItemCode + " - " + scheme.OITM.ItemName;
                            item.Quantity = scheme.Quantity;
                            item.TotalQty = scheme.TotalQty;
                            item.SubTotal = scheme.SubTotal;
                            item.Tax = scheme.Tax;
                            item.Total = scheme.Total;
                            item.MainID = scheme.MainID;
                            item.Price = scheme.Price;
                            item.UnitID = scheme.UnitID;
                            item.UnitPrice = scheme.UnitPrice;
                            item.PriceTax = scheme.PriceTax;
                            item.MapQty = scheme.MapQty;
                            item.TaxID = scheme.TaxID.Value;
                            item.UnitName = scheme.OUNT.UnitName;
                            BindList.Add(item);
                        }

                        result.Add(BindList);

                        result.Add(objOPOS.OCRD.IsTemp);
                    }
                    else
                    {
                        result.Add("ERROR=" + "" + "No Order found.");
                    }
                }
            }
            else
            {
                result.Add("ERROR=" + "" + "No Order found.");
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadItemsCustomerWise(string CustomerCode, string WareHouse, Boolean ChkTemp, Boolean chkExisting)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int IntNum = Int32.TryParse(WareHouse, out IntNum) ? IntNum : 0;

                OWH objWHS = ctx.OWHS.FirstOrDefault(x => x.WhsID == IntNum && x.ParentID == ParentID && x.Active);
                if (objWHS == null)
                {
                    result.Add("ERROR=" + "" + "Please select proper warehouse.");
                    return result;
                }

                DisData3 data = new DisData3();
                if (chkExisting)
                {
                    if (ChkTemp)
                    {
                        data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                        if (data == null)
                        {
                            result.Add("ERROR=" + "" + "Un-Register Dealer Not Available for Temporary Customer, Contact To Mktg Dept Only.");
                            return result;
                        }
                    }
                    else
                    {
                        data = ctx.OCRDs.Where(x => x.IsTemp == ChkTemp && x.CustomerCode == CustomerCode && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                    }
                }
                else
                {
                    data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                    if (data == null)
                    {
                        result.Add("ERROR=" + "" + "Un-Register Dealer Not Available for Temporary Customer, Contact To Mktg Dept Only.");
                        return result;
                    }
                }
                if (data == null)
                {
                    result.Add("ERROR=" + "" + "Please select proper customer.");
                    return result;
                }

                List<string> items = ctx.LoadItemsForSale(ParentID, data.Value, objWHS.WhsID).ToList();
                if (items == null)
                {
                    result.Add("ERROR=" + "" + "No Item found for the same customer.");
                    return result;
                }
                if (items.Count == 0)
                {
                    result.Add("ERROR=" + "" + "No Item found for the same customer.");
                    return result;
                }

                result.Add(items);
                result.Add(data.Text);
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
    public static List<dynamic> GetItemDetails(string itemCode, string customer, int WareHouse, Boolean ChkTemp, Boolean chkExisting)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            List<DisData2> units = new List<DisData2>();

            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            using (DDMSEntities ctx = new DDMSEntities())
            {
                DisData3 data = new DisData3();
                if (chkExisting)
                {
                    if (ChkTemp)
                    {
                        data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                    }
                    else
                    {
                        data = ctx.OCRDs.Where(x => x.IsTemp == ChkTemp && x.CustomerCode == customer && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                    }
                }
                else
                {
                    data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone }).FirstOrDefault();
                }
                if (data == null)
                {
                    result.Add("ERROR=" + "" + "Please select proper customer.");
                }
                else
                {
                    int ItemID = ctx.OITMs.FirstOrDefault(x => x.ItemCode == itemCode).ItemID;

                    if (ItemID > 0)
                    {
                        int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID).DivisionlID.Value;
                        int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == data.Value && x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                        List<SaleItem_Result> Data = ctx.SaleItem(ParentID, data.Value, PriceID, 0, ItemID, 0, WareHouse, ParentID).ToList();
                        if (Data.Count > 0)
                        {
                            units = Data.Select(x => new DisData2 { Text = x.Unitname, Value = x.UnitID.ToString() + "," + x.UnitPrice.ToString() + "," + x.Tax.ToString() + "," + x.Quantity.ToString() }).ToList();

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
                        {
                            result.Add("ERROR=" + "" + "Please contact Marketing Department to resolve this issue");
                        }
                    }
                }
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
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

                Decimal DecNum = 0;

                var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());

                string AutoCustomer = Convert.ToString(HeaderData["AutoCustomer"]);
                string AutoTemplate = Convert.ToString(HeaderData["AutoTemplate"]);
                string AutoVehicle = Convert.ToString(HeaderData["AutoVehicle"]);
                string AutoOrderForm = Convert.ToString(HeaderData["AutoOrderForm"]);

                string Mobile = Convert.ToString(HeaderData["Mobile"]);
                string Date = Convert.ToString(HeaderData["Date"]);
                string Pending = Convert.ToString(HeaderData["Pending"]);

                string ChkTemp = Convert.ToString(HeaderData["ChkTemp"]);
                string chkExisting = Convert.ToString(HeaderData["chkExisting"]);

                string ddlWhs = Convert.ToString(HeaderData["ddlWhs"]);
                string SubTotal = Convert.ToString(HeaderData["SubTotal"]);
                string Total = Convert.ToString(HeaderData["Total"]);
                string Tax = Convert.ToString(HeaderData["Tax"]);
                string BillNumber = Convert.ToString(HeaderData["BillNumber"]);
                string Rounding = Convert.ToString(HeaderData["Rounding"]);
                string Notes = Convert.ToString(HeaderData["Notes"]);

                List<ItemData> BindList = new List<ItemData>();

                foreach (var scheme in SchemeData)
                {
                    ItemData item = new ItemData();
                    item.ItemID = scheme["ItemID"];
                    item.Quantity = scheme["RequestQty"];
                    item.TotalQty = scheme["TotalQty"];
                    item.SubTotal = scheme["SubTotal"];
                    item.Tax = scheme["Tax"];
                    item.Total = scheme["Total"];
                    item.MainID = scheme["MainID"];

                    item.Price = scheme["Price"];
                    item.UnitID = scheme["UnitID"];
                    item.UnitPrice = scheme["UnitPrice"];
                    item.PriceTax = scheme["PriceTax"];
                    item.MapQty = scheme["MapQuantity"];
                    item.TaxID = scheme["TaxID"];
                    BindList.Add(item);
                }

                Int32 WhsID = 0;
                if (!Int32.TryParse(ddlWhs, out WhsID))
                {
                    return "ERROR=Select Warehouse.";
                }
                if (BindList.Count == 0)
                {
                    return "ERROR=Select Atleast one item.";
                }
                //Customer
                OCRD objOCRD = null;

                if (chkExisting.ToLower() == "false")
                {
                    objOCRD = new OCRD();
                    objOCRD.Type = Convert.ToInt32(HttpContext.Current.Session["Type"]) + 1;
                    var cid = objOCRD.Type.ToString() + ctx.GetCustomerID("OCRD", "CustomerID", ParentID).FirstOrDefault().Value.ToString("D5") + ParentID.ToString().Substring(1, 10);
                    objOCRD.CustomerID = Convert.ToDecimal(cid);
                    objOCRD.ParentID = ParentID;
                    objOCRD.CustomerCode = objOCRD.CustomerID.ToString();
                    objOCRD.CreatedBy = UserID;
                    objOCRD.Phone = Mobile;
                    objOCRD.CreatedDate = DateTime.Now;
                    objOCRD.CustGroupID = ctx.CGRPs.Where(x => x.Type == 3).FirstOrDefault().CustGroupID;
                    objOCRD.CustomerName = AutoCustomer;
                    objOCRD.UpdatedBy = UserID;
                    objOCRD.Active = true;
                    objOCRD.IsTemp = true;
                    objOCRD.IsDiscount = false;
                    objOCRD.UpdatedDate = DateTime.Now;
                    ctx.OCRDs.Add(objOCRD);

                    var parentCust = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID);

                    CRD1 objCRD1 = new CRD1();
                    objCRD1.CustomerID = objOCRD.CustomerID;
                    objCRD1.BranchID = ctx.GetCustomerIDKey("CRD1", "BranchID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                    objCRD1.Branch = "HO";
                    objCRD1.Type = "B";
                    objCRD1.CityID = parentCust.CityID;
                    objCRD1.StateID = parentCust.StateID;
                    objCRD1.CountryID = parentCust.CountryID;
                    objCRD1.PhoneNumber = Mobile;
                    ctx.CRD1.Add(objCRD1);
                }
                else
                {
                    if (!String.IsNullOrEmpty(AutoCustomer))
                    {
                        if (ChkTemp.ToLower() == "true")
                            objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == ParentID && x.CustomerCode == AutoCustomer && x.IsTemp && x.Active);
                        else
                            objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == ParentID && x.CustomerCode == AutoCustomer && !x.IsTemp && x.Active);
                        objOCRD.Phone = Mobile;
                    }
                }
                if (objOCRD == null)
                {
                    return "ERROR=Select Proper Customer.";
                }

                OPOS objOPOS = null;
                int SaleID;
                if (Int32.TryParse(AutoOrderForm, out SaleID) && SaleID > 0)
                {
                    objOPOS = ctx.OPOS.FirstOrDefault(x => x.ParentID == ParentID && x.OrderType == (int)SaleOrderType.Order && x.SaleID == SaleID);
                }
                if (objOPOS == null)
                {
                    objOPOS = new OPOS();
                    objOPOS.SaleID = ctx.GetKey("OPOS", "SaleID", "", ParentID, 0).FirstOrDefault().Value;

                    int vehicleID = 0;
                    if (!string.IsNullOrEmpty(AutoVehicle) && Int32.TryParse(AutoVehicle, out vehicleID) && vehicleID > 0)
                    {
                        objOPOS.VehicleID = vehicleID;
                    }
                    OSEQ objOSEQ = null;
                    var date = Common.DateTimeConvert(Date);
                    objOPOS.Status = "O";
                    objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "O" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();
                    objOPOS.ProcessID = (int)SalesType.Tax;

                    if (objOSEQ != null)
                    {
                        objOSEQ.RorderNo++;
                        objOPOS.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                    }
                    else
                    {
                        return "ERROR=Invoice Series Not Found.";
                    }
                    objOPOS.ParentID = ParentID;
                    objOPOS.OrderType = (int)SaleOrderType.Order;
                    objOPOS.CustomerID = objOCRD.CustomerID;
                    objOPOS.CreatedDate = DateTime.Now;
                    objOPOS.CreatedBy = UserID;
                    objOPOS.Date = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                    if (ctx.OPOS.Any(x => x.ParentID == ParentID && x.BillRefNo == BillNumber))
                        objOPOS.BillRefNo = Common.Get8Digits();
                    else
                        objOPOS.BillRefNo = BillNumber;
                    ctx.OPOS.Add(objOPOS);
                }
                objOPOS.MobilieNumber = Mobile;
                objOPOS.SubTotal = Decimal.TryParse(SubTotal, out DecNum) ? DecNum : 0;
                objOPOS.Rounding = Decimal.TryParse(Rounding, out DecNum) ? DecNum : 0;
                objOPOS.Tax = Decimal.TryParse(Tax, out DecNum) ? DecNum : 0;
                objOPOS.Total = Decimal.TryParse(Total, out DecNum) ? DecNum : 0;
                objOPOS.Pending = Decimal.TryParse(Pending, out DecNum) ? DecNum : 0;
                objOPOS.Notes = Notes;
                objOPOS.UpdatedDate = DateTime.Now;
                objOPOS.UpdatedBy = UserID;

                objOPOS.POS1.ToList().ForEach(x => x.IsDeleted = true);

                int Count = ctx.GetKey("POS1", "POS1ID", "", ParentID, null).FirstOrDefault().Value;

                foreach (ItemData item in BindList)
                {
                    if (item.ItemID > 0 && item.TotalQty > 0)
                    {
                        POS1 objPOS1 = objOPOS.POS1.FirstOrDefault(x => x.ItemID == item.ItemID);
                        if (objPOS1 == null)
                        {
                            objPOS1 = new POS1();
                            objPOS1.POS1ID = Count++;
                            objPOS1.ItemID = item.ItemID;
                            objOPOS.POS1.Add(objPOS1);
                        }
                        objPOS1.IsDeleted = false;
                        objPOS1.UnitID = item.UnitID;
                        objPOS1.UnitPrice = item.UnitPrice;
                        objPOS1.TaxID = item.TaxID;
                        objPOS1.PriceTax = item.PriceTax;
                        objPOS1.Price = item.Price;
                        objPOS1.MapQty = item.MapQty;
                        objPOS1.Quantity = item.Quantity;
                        objPOS1.DispatchQty = 0;
                        objPOS1.MainID = item.MainID;
                        objPOS1.TotalQty = item.TotalQty;
                        objPOS1.SubTotal = item.SubTotal;
                        objPOS1.Tax = item.Tax;
                        objPOS1.Total = item.Total;
                        objPOS1.AddOn = item.AddOn;
                        objPOS1.Discount = item.Discount;
                        objOPOS.POS1.Add(objPOS1);
                    }
                }
                if (ctx.OPOS.Any(x => x.ParentID == ParentID && x.CustomerID == objOPOS.CustomerID.Value && x.SubTotal == objOPOS.SubTotal && x.Tax == objOPOS.Tax
                    && x.Date.Year == objOPOS.Date.Year && x.Date.Month == objOPOS.Date.Month && x.Date.Day == objOPOS.Date.Day && x.Date.Hour == objOPOS.Date.Hour))
                {
                    return "ERROR=Something is worng";
                }
                ctx.SaveChanges();
                return "SUCCESS=Order Inserted Successfully: OrderID # " + objOPOS.SaleID.ToString();
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
}
