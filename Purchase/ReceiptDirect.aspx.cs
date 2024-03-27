using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Purchase_ReceiptDirect : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OSEQs.Any(x => x.ParentID == ParentID && x.Type == "PC" && !x.IsDeleted && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
                {
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Direct Receipt. !',3);", true);
                    //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                    return;
                }
            }
        }
    }

    #endregion

    #region HelperMethod

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

    #endregion

    #region AjaxMethods

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(string Date)
    {

        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            decimal PID = Convert.ToDecimal(HttpContext.Current.Session["OutletPID"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var BeatAvail = ctx.AddHierarchyType_Check(ParentID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                if (BeatAvail.IsBeatAvail == 2)
                {
                    result.Add("ERROR#" + "" + "Beat not available for you, so you can not create Direct Receipt. Contact to your Local Sales Staff!");
                    return result;
                }
                else if (BeatAvail.IsBeatAvail == 0)
                {
                    result.Add("ERROR#" + BeatAvail.Msg);
                    return result;
                }
                var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(Date), ParentID).FirstOrDefault();
                if (!String.IsNullOrEmpty(DayCloseData))
                {
                    result.Add("ERROR#" + "" + DayCloseData);
                    return result;
                }
                else
                {
                    var vendor = ctx.OVNDs.Where(x => x.Active && (x.ParentID == ParentID || x.ParentID == PID)).Select(x => new { VendorID = SqlFunctions.StringConvert((double)x.VendorID) + "," + SqlFunctions.StringConvert(x.ParentID, 20), x.VendorName }).ToList();
                    var lstDivision = ctx.ODIVs.Where(x => x.DivisionCode == "19" && x.Active).Select(x => new { DivisionlID = SqlFunctions.StringConvert((double)x.DivisionlID), DivisionName = x.DivisionName }).OrderBy(x => x.DivisionlID).ToList();
                    var WareHouse = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).Select(x => new { Value = SqlFunctions.StringConvert((double)x.WhsID), Name = x.WhsName }).OrderBy(x => x.Value).ToList();
                    var Vehicle = ctx.OVCLs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.VehicleID, 20, 0).Trim() + " - " + x.VehicleNumber).ToList();
                    var Template = ctx.OTMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.TemplateID, 20, 0).Trim() + " - " + x.TemplateName).ToList();
                    var Reason = ctx.ORSNs.Where(x => x.Active && x.Type == "I").Select(x => new { ReasonID = SqlFunctions.StringConvert((double)x.ReasonID), ReasonName = x.ReasonName }).ToList();

                    result.Add(vendor);
                    result.Add(lstDivision);
                    result.Add(WareHouse);
                    result.Add(Vehicle);
                    result.Add(Template);
                    result.Add(Reason);
                }

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
    public static List<dynamic> LoadItemsByDivision(int DivisionID)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var items = ctx.OITMs.Where(x => x.Active && x.OGITMs.Any(s => s.DivisionlID == DivisionID)).Select(x => x.ItemCode + " - " + x.ItemName).ToList();
                result.Add(items);
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
    public static List<dynamic> GetItemDetails(string txt, int WhsID)
    {
        List<dynamic> result = new List<dynamic>();
        List<PurchaseItem_Result> Data = new List<PurchaseItem_Result>();
        List<DisData2> units = new List<DisData2>();
        try
        {
            var word = txt.Split("-".ToArray());
            if (word.Length > 1)
            {
                var ItemCode = word.First().Trim();
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                    int ItemID = ctx.OITMs.Where(x => x.ItemCode == ItemCode && x.Active).Select(x => x.ItemID).DefaultIfEmpty(0).FirstOrDefault();
                    if (ItemID > 0)
                    {
                        var ItemData = ctx.OGITMs.Where(x => x.ItemID == ItemID && x.DivisionlID.HasValue && x.PlantID.HasValue).Select(x => new { PlantID = x.PlantID.Value, DivisionID = x.DivisionlID.Value }).ToList();
                        if (ItemData.Count > 0)
                        {
                            int did = ItemData.FirstOrDefault().DivisionID;
                            var plids = ItemData.Select(z => z.PlantID).ToList();
                            int PriceListID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == did && x.PlantID.HasValue && x.PriceListID.HasValue && plids.Contains(x.PlantID.Value)).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                            if (PriceListID > 0)
                            {
                                Data = ctx.PurchaseItem(ParentID, PriceListID, 0, ItemID, 0, WhsID).ToList();

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
                                    result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact to Mktg Team Only");
                            }
                            else
                                result.Add("ERROR=" + "" + "This material is not extended in your plant, Please contact Marketing Department to resolve this issue");
                        }
                        else
                            result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact to Mktg Team Only");
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
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                Decimal DecNum = 0;
                var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());
                string Date = Convert.ToString(HeaderData["Date"]);
                string Pending = Convert.ToString(HeaderData["Pending"]);
                string ddlWhs = Convert.ToString(HeaderData["ddlWhs"]);
                string SubTotal = Convert.ToString(HeaderData["SubTotal"]);
                string Total = Convert.ToString(HeaderData["Total"]);
                string Tax = Convert.ToString(HeaderData["Tax"]);
                string Paid = Convert.ToString(HeaderData["Paid"]);
                string BillNumber = Convert.ToString(HeaderData["BillNumber"]);
                string Rounding = Convert.ToString(HeaderData["Rounding"]);
                string Notes = Convert.ToString(HeaderData["Notes"]);
                // string Vehicle = Convert.ToString(HeaderData["Vehicle"]);
                string Vendor = Convert.ToString(HeaderData["Vendor"]);
                string Discount = Convert.ToString(HeaderData["Discount"]);
                string paidTo = Convert.ToString(HeaderData["paidTo"]);

                List<ItemData> BindList = new List<ItemData>();

                foreach (var scheme in SchemeData)
                {
                    ItemData item = new ItemData();
                    item.ItemID = scheme["ItemID"];
                    item.ItemCode = scheme["ItemCode"];
                    item.Quantity = scheme["txtReciept"];
                    item.AvailQty = scheme["AvlQty"];
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
                    item.ReasonID = scheme["Reason"];
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
                OMID OnjectMID = ctx.OMIDs.Where(x => x.BillNumber == BillNumber && x.ParentID == ParentID).FirstOrDefault();
                if (OnjectMID != null)
                {
                    return "ERROR=Same Bill no already exists in system.";
                }
                OMID objOMID = null;
                objOMID = new OMID();
                objOMID.InwardID = ctx.GetKey("OMID", "InwardID", "", ParentID, 0).FirstOrDefault().Value;
                var date = Common.DateTimeConvert(Date);
                OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "PC" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();

                if (objOSEQ != null)
                {
                    objOSEQ.RorderNo++;
                    objOMID.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                }
                else
                {
                    return "ERROR=Invoice Series Not Found.";
                }
                objOMID.ParentID = ParentID;
                objOMID.InwardType = 4;


                //if (!String.IsNullOrEmpty(Vehicle))
                //{
                //    var veh = Vehicle.Split("-".ToArray());
                //    if (veh.Length == 2)
                //    {

                //        string id = veh.Last().Trim();
                //        int VehicleID = ctx.OVCLs.Where(x => x.VehicleNumber == id && x.ParentID == ParentID && x.Active).Select(x => x.VehicleID).DefaultIfEmpty(0).FirstOrDefault();
                //        if (VehicleID > 0)
                //            objOMID.VehicleID = VehicleID;
                //        else
                //        {
                //            return "ERROR=Select Proper Vehicle.";
                //        }
                //    }

                //}
                var Rec = Vendor.Split(",".ToArray());
                if (Rec.Length == 2)
                {
                    objOMID.VendorID = Convert.ToInt32(Rec.First());
                    objOMID.VendorParentID = Convert.ToDecimal(Rec.Last());
                }
                objOMID.ReceiveDate = objOMID.BillDate = objOMID.Date = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                objOMID.Status = "O";
                objOMID.ToWhsID = WhsID;
                objOMID.CreatedDate = DateTime.Now;
                objOMID.CreatedBy = UserID;
                ctx.OMIDs.Add(objOMID);

                if (!String.IsNullOrEmpty(Paid) && Decimal.TryParse(Paid, out DecNum) && DecNum > 0)
                {
                    MID2 objMID2 = new MID2();
                    objMID2.MID2ID = ctx.GetKey("MID2", "MID2ID", "", ParentID, null).FirstOrDefault().Value;
                    objMID2.ParentID = ParentID;
                    objMID2.Date = DateTime.Now;
                    objMID2.DocName = "";
                    objMID2.DocNo = "";
                    objMID2.Amount = DecNum;
                    objMID2.PaymentMode = (int)PaymentMode.Cash;
                    objMID2.Status = "C";
                    objOMID.MID2.Add(objMID2);
                }
                objOMID.UpdatedDate = DateTime.Now;
                objOMID.UpdatedBy = UserID;
                objOMID.Status = "O";
                if (BillNumber.Length != 10)
                {
                    var Bill = BillNumber.PadLeft(BillNumber.Length + (10 - BillNumber.Length), '0');
                    objOMID.BillNumber = Bill;
                }
                else
                    objOMID.BillNumber = BillNumber;

                objOMID.SubTotal = Decimal.TryParse(SubTotal, out DecNum) ? DecNum : 0;
                objOMID.Discount = Decimal.TryParse(Discount, out DecNum) ? DecNum : 0;
                objOMID.Rounding = Decimal.TryParse(Rounding, out DecNum) ? DecNum : 0;
                objOMID.Tax = Decimal.TryParse(Tax, out DecNum) ? DecNum : 0;
                objOMID.Total = Decimal.TryParse(Total, out DecNum) ? DecNum : 0;
                objOMID.Paid = Decimal.TryParse(Paid, out DecNum) ? DecNum : 0;
                objOMID.Pending = Decimal.TryParse(Pending, out DecNum) ? DecNum : 0;
                objOMID.Notes = Notes;
                objOMID.PaidTo = paidTo;
                ctx.OMIDs.Add(objOMID);
                int Count = ctx.GetKey("MID1", "MID1ID", "", ParentID, null).FirstOrDefault().Value;
                int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                int ItemID = BindList.FirstOrDefault().ItemID;
                objOMID.DivisionID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID && x.DivisionlID != null).DivisionlID;
                objOMID.PlantID = ctx.OGCRDs.Where(x => x.CustomerID == objOMID.ParentID && x.DivisionlID == objOMID.DivisionID && x.PlantID.HasValue).Select(x => x.PlantID.Value).DefaultIfEmpty(0).FirstOrDefault();

                foreach (ItemData item in BindList)
                {
                    if (item.ItemID > 0 && item.Quantity > 0)
                    {
                        MID1 objMID1 = objOMID.MID1.FirstOrDefault(x => x.ItemID == item.ItemID);
                        if (objMID1 == null)
                        {
                            objMID1 = new MID1();
                            objMID1.MID1ID = Count++;
                            objMID1.ItemID = item.ItemID;
                            objOMID.MID1.Add(objMID1);
                        }
                        objMID1.UnitID = item.UnitID;
                        objMID1.PriceTax = item.PriceTax;
                        objMID1.UnitPrice = item.UnitPrice;
                        objMID1.Discount = item.Discount;
                        objMID1.MapQty = item.MapQty;
                        objMID1.Price = item.Price;
                        objMID1.AvailableQty = item.AvailQty;
                        objMID1.RequestQty = item.Quantity;
                        objMID1.DisptchQty = 0;
                        objMID1.DiffirenceQty = 0;
                        objMID1.TotalQty = item.Quantity;
                        objMID1.RecieptQty = item.Quantity;
                        objMID1.SubTotal = item.SubTotal;
                        objMID1.Tax = item.Tax;
                        objMID1.Total = item.Total;
                        objMID1.ReasonID = item.ReasonID;
                        objMID1.TaxID = item.TaxID;

                        if (objMID1.RecieptQty > 0)
                        {
                            ITM2 ITM2 = ctx.ITM2.FirstOrDefault(x => x.ParentID == ParentID && x.WhsID == WhsID && x.ItemID == objMID1.ItemID);
                            if (ITM2 == null)
                            {
                                ITM2 = new ITM2();
                                ITM2.StockID = CountM++;
                                ITM2.ParentID = ParentID;
                                ITM2.WhsID = WhsID;
                                ITM2.ItemID = objMID1.ItemID;
                                //ITM2.PPrice = objMID1.UnitPrice;
                                ctx.ITM2.Add(ITM2);
                            }
                            ITM2.PPrice = objMID1.UnitPrice;
                            //else
                            //{
                            //    if ((ITM2.TotalPacket + objMID1.TotalQty) == 0)
                            //        ITM2.PPrice = ((ITM2.TotalPacket * ITM2.PPrice) + (objMID1.UnitPrice * objMID1.TotalQty)) / 1;
                            //    else
                            //        ITM2.PPrice = ((ITM2.TotalPacket * ITM2.PPrice) + (objMID1.UnitPrice * objMID1.TotalQty)) / (ITM2.TotalPacket + objMID1.TotalQty);
                            //}
                            ITM2.TotalPacket += objMID1.TotalQty;
                        }
                    }
                }
                if (objOMID.ReceiveDate.Value.Date != DateTime.Now.Date)
                {
                    return "ERROR=DayClose is missing, please refresh page or do dayclose";
                }
                ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                int HdocID = ctx.AddHierarchyType_NEW("PR", objOMID.ParentID, ParentID, objOMID.InwardID, str).FirstOrDefault().GetValueOrDefault(0);
                if (str.Value.ToString() == "0" || HdocID == 0)
                {
                    return "ERROR=Beat Not Available So, you can not do Purchase Receipt - Direct. Contact to your Local  Sales Staff!";
                }
                objOMID.HDocID = HdocID;
                ctx.SaveChanges();

                #region AUTO GAIN LOSSS

                if (objOMID.MID1.Any(x => ctx.ITM5.Any(z => z.PurchaseItemID == x.ItemID && z.IsActive == true)))
                {

                    var PurBindList = objOMID.MID1.Where(x => ctx.ITM5.Any(z => z.PurchaseItemID == x.ItemID && z.IsActive == true)).ToList();

                    List<int> IDs = PurBindList.Select(x => x.ItemID).ToList();
                    var ItemUpBindList = ctx.ITM5.Where(x => IDs.Any(z => z == x.PurchaseItemID && x.IsActive == true)).ToList();

                    INRT objINRT = new INRT();
                    objINRT.INRTID = ctx.GetKey("INRT", "INRTID", "", ParentID, 0).FirstOrDefault().Value;

                    objINRT.ParentID = ParentID;
                    objINRT.CustomerID = ParentID;
                    objINRT.Notes = "This is Auto Entry From Receipt Invoice Number " + objOMID.InvoiceNumber;
                    objINRT.WhsID = objOMID.ToWhsID;
                    objINRT.DocumentDate = objOMID.ReceiveDate.Value;
                    objINRT.CreatedDate = DateTime.Now;
                    objINRT.CreatedBy = UserID;
                    objINRT.UpdatedDate = DateTime.Now;
                    objINRT.UpdatedBy = UserID;
                    objINRT.TotalItemAmt = 0;
                    objINRT.Status = "D";

                    if (ctx.INRTs.Any(x => x.ParentID == ParentID && x.DocumentType == "O") || ctx.OMIDs.Any(x => x.ParentID == ParentID && new int[] { 3, 4 }.Contains(x.InwardType)))
                        objINRT.DocumentType = "U";
                    else
                        objINRT.DocumentType = "O";

                    ctx.INRTs.Add(objINRT);

                    int NRT1Count = ctx.GetKey("NRT1", "NRT1ID", "", ParentID, null).FirstOrDefault().Value;
                    int ITM2Count = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                    foreach (var item in PurBindList)
                    {

                        ITM2 objMNSITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == item.ItemID && x.WhsID == objINRT.WhsID && x.ParentID == ParentID);

                        NRT1 objMNSNRT1 = new NRT1();
                        objMNSNRT1.NRT1ID = NRT1Count++;
                        objMNSNRT1.ItemID = item.ItemID;
                        objMNSNRT1.UnitID = item.UnitID;
                        objMNSNRT1.AvalQty = objMNSITM2.TotalPacket;
                        objMNSNRT1.Qty = objMNSITM2.TotalPacket - item.TotalQty;
                        objMNSNRT1.TotalQty = item.TotalQty * -1;
                        objMNSNRT1.Price = item.UnitPrice;
                        objMNSNRT1.Total = item.Total;
                        objMNSNRT1.TranType = objINRT.DocumentType;
                        objINRT.NRT1.Add(objMNSNRT1);

                        objMNSITM2.TotalPacket -= item.TotalQty;

                        var InvUpItme = ItemUpBindList.FirstOrDefault(x => x.PurchaseItemID == item.ItemID);

                        ITM2 objPLSITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == InvUpItme.SaleItemID && x.WhsID == objINRT.WhsID && x.ParentID == ParentID);
                        if (objPLSITM2 == null)
                        {
                            objPLSITM2 = new ITM2();
                            objPLSITM2.StockID = ITM2Count++;
                            objPLSITM2.ParentID = ParentID;
                            objPLSITM2.WhsID = objINRT.WhsID;
                            objPLSITM2.ItemID = InvUpItme.SaleItemID;
                            ctx.ITM2.Add(objPLSITM2);
                        }
                        NRT1 objPLSNRT1 = new NRT1();
                        objPLSNRT1.NRT1ID = NRT1Count++;
                        objPLSNRT1.ItemID = InvUpItme.SaleItemID;
                        objPLSNRT1.UnitID = InvUpItme.UnitID;
                        objPLSNRT1.AvalQty = objPLSITM2.TotalPacket;
                        objPLSNRT1.Qty = objPLSITM2.TotalPacket + (item.TotalQty * InvUpItme.MapQty);
                        objPLSNRT1.TotalQty = item.TotalQty * InvUpItme.MapQty;
                        objPLSNRT1.Price = item.UnitPrice / InvUpItme.MapQty;
                        objPLSNRT1.Total = objPLSNRT1.Price * objPLSNRT1.Qty;
                        objPLSNRT1.TranType = objINRT.DocumentType;
                        objINRT.NRT1.Add(objPLSNRT1);

                        objPLSITM2.PPrice = objPLSNRT1.Price;
                        objPLSITM2.TotalPacket += item.TotalQty * InvUpItme.MapQty;
                    }

                    ctx.SaveChanges();
                }
                #endregion

                return "SUCCESS=Order Recived Succesfully: OrderID # " + objOMID.InwardID.ToString();
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadTemplateItems(int ddlWhs, int division, int TempId)
    {
        List<dynamic> result = new List<dynamic>();
        List<PurchaseItem_Result> Data = new List<PurchaseItem_Result>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (division != 0 || ddlWhs != 0 || TempId != 0)
                {

                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                    int TemplateID = Convert.ToInt32(TempId);
                    int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == division && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                    Data = ctx.PurchaseItem(ParentID, PriceID, 0, 0, TemplateID, Convert.ToInt32(ddlWhs)).ToList();

                    List<ItemData> tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty }).ToList()
                                              select new ItemData
                                              {
                                                  ItemID = x.Key.ItemID,
                                                  ItemCode = x.Key.ItemCode,
                                                  ItemName = x.Key.ItemName,
                                                  AvailQty = x.Key.AvailQty,
                                              }).ToList();
                    result.Add(tmpList);
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    #endregion
}