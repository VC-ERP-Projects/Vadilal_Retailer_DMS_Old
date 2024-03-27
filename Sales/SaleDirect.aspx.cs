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
using System.Threading;
using System.Data.SqlClient;
using System.Net;
using AjaxControlToolkit;
using System.Configuration;
using System.Text;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System.Data.EntityClient;
using System.Web.Hosting;
using System.Globalization;
using TaxProEInvoiceModel;
using Newtonsoft.Json.Linq;

public partial class Sales_SaleDirect : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    public int OrderID;
    static int OrderIDQPS;
    public int CustType;
    public string Type;
    public string CustomerID;

    public static string GSTID, GSTPWD, GSTIN, AuthToken;
    public static bool DebiteNote = false;

    public static bool EWayBill = false;
    public static List<ItemWiseDiscountData> ObjItemDisc = new List<ItemWiseDiscountData>();
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {

        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && (x.Type == "T" || x.Type == "S") && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
                {
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Sale Invoice. !',3);", true);
                    //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                    return;
                }
                //if (!ctx.OFSSIs.Any(x => x.FSSIForID == ParentID && !x.IsDeleted))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FSSAI Number Not Available!',3);hideModal();", true);
                //    return;
                //}
                //if (ctx.OFSSIs.Any(x => x.FSSIForID == ParentID && !x.IsDeleted && x.VerifyIs == 0 &&
                //  ((EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.EndDate) >= EntityFunctions.TruncateTime(DateTime.Now))
                //                                    || (EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.StartDate) && EntityFunctions.TruncateTime(DateTime.Now) >= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate)))))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your FSSAI Number Pending for Approval. Please contact HO!',3);hideModal();", true);
                //    // Response.Redirect("~/MyAccount/DIstFSSAIMaster.aspx");
                //    return;
                //}

                //if (ctx.OFSSIs.Any(x => x.FSSIForID == ParentID && !x.IsDeleted && x.VerifyIs == 2 &&
                //  ((EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.EndDate) >= EntityFunctions.TruncateTime(DateTime.Now))
                //                                    || (EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.StartDate) && EntityFunctions.TruncateTime(DateTime.Now) >= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate)))))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your FSSAI Number Reject. So please update the same.!',3);hideModal();", true);
                //    // Response.Redirect("~/MyAccount/DIstFSSAIMaster.aspx");
                //    return;
                //}
                //if (!ctx.OFSSIs.Any(x => x.FSSIForID == ParentID && !x.IsDeleted && x.VerifyIs == 1 &&
                // ((EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.EndDate) >= EntityFunctions.TruncateTime(DateTime.Now))
                //                                    || (EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.StartDate) && EntityFunctions.TruncateTime(DateTime.Now) >= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate)))))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FSSAI Number Not Available!',3);hideModal();", true);
                //    // Response.Redirect("~/MyAccount/DIstFSSAIMaster.aspx");
                //    return;
                //}
                //if (ctx.OFSSIs.Any(x => x.FSSIForID == ParentID && !x.IsDeleted && x.VerifyIs == 1 &&
                //  ((EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.EndDate) >= EntityFunctions.TruncateTime(DateTime.Now))
                //                                    || (EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.StartDate) && EntityFunctions.TruncateTime(DateTime.Now) >= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate))
                //                                    || (EntityFunctions.TruncateTime(x.StartDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.EndDate)))))

                //{
                //    var objOFSSI = ctx.OFSSIs.Where(x => x.FSSIForID == ParentID && !x.IsDeleted && x.VerifyIs == 1).OrderByDescending(x => x.EndDate).FirstOrDefault();

                //    if (objOFSSI != null)
                //    {
                //        if (objOFSSI.EndDate.Date < DateTime.Now.Date)
                //        {
                //            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FSSAI Number Not Available!',3);hideModal();", true);
                //            //  Response.Redirect("~/Master/DIstFSSAIMaster.aspx");
                //            return;
                //        }
                //    }
                //    else
                //    {
                //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('FSSAI Number Not Available!',3);hideModal();", true);

                //        // Response.Redirect("~/Master/DIstFSSAIMaster.aspx");
                //        return;
                //    }
                //}

                if (Request.QueryString["DocNo"] != null && Request.QueryString["DocKey"] != null && Int32.TryParse(Request.QueryString["DocNo"].ToString(), out OrderID) && OrderID > 0)
                {
                    Type = Request.QueryString["Type"].ToString();
                    CustomerID = Request.QueryString["DocKey"].ToString();
                    OrderIDQPS = OrderID;
                    //Set Publice Veriable For Update Order
                }
                if (ctx.OGSTs.Any(x => x.CustomerId == ParentID && x.GSTRequired == true))
                {
                    btnSavePrint.Visible = false;
                }
                else
                {
                    btnSavePrint.Visible = true;
                }
            }
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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadData(string Date)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);

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
                    decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;

                    Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                    SqlCommand Cm = new SqlCommand();
                    Cm.Parameters.Clear();
                    Cm.CommandType = CommandType.StoredProcedure;
                    Cm.CommandText = "LoadDataForSale";
                    Cm.Parameters.AddWithValue("@ParentID", ParentID);
                    Cm.Parameters.AddWithValue("@VehicleParentID", VehicleParentID);
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    if (ds != null && ds.Tables.Count > 0)
                    {

                        List<string> Customer = ds.Tables[0].AsEnumerable().Select(r => r.Field<string>("data")).ToList();
                        List<string> Template = ds.Tables[2].AsEnumerable().Select(r => r.Field<string>("data")).ToList();
                        List<string> Vehicle = ds.Tables[3].AsEnumerable().Select(r => r.Field<string>("data")).ToList();
                        List<string> OrderForm = ds.Tables[4].AsEnumerable().Select(r => r.Field<string>("data")).ToList();
                        List<DisData> WareHouse = ds.Tables[5].AsEnumerable().Select(r => new DisData { Value = r.Field<int>("WhsID"), Text = r.Field<string>("WhsName") }).ToList();
                        List<string> tempCustomer = ds.Tables[1].AsEnumerable().Select(r => r.Field<string>("data")).ToList();

                        result.Add(Customer);
                        result.Add(Template);
                        result.Add(Vehicle);
                        result.Add(OrderForm);
                        result.Add(WareHouse);
                        result.Add(tempCustomer);
                    }
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
    public static List<dynamic> GetOrder(string orderid, string type, decimal custid)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            int OrderID;
            if (Int32.TryParse(orderid, out OrderID) && OrderID > 0)
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var DayCloseData = ctx.CheckDayClose(DateTime.Now, ParentID).FirstOrDefault();
                    if (!String.IsNullOrEmpty(DayCloseData))
                    {
                        result.Add("ERROR=" + "" + DayCloseData);
                        return result;
                    }
                    else
                    {

                        decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;
                        if (type == "O")
                        {
                            ORDR objORDR = ctx.ORDRs.FirstOrDefault(x => x.OrderID == OrderID && x.ParentID == ParentID && x.OrderType == 11);
                            if (objORDR != null)
                            {
                                var BeatAvail = ctx.AddHierarchyType_Check(objORDR.CustomerID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                                if (BeatAvail.IsBeatAvail == 2)
                                {
                                    result.Add("ERROR=" + "Beat not available for " + objORDR.OCRD.CustomerCode + " # " + objORDR.OCRD.CustomerName + ", so you can not create Sales Invoice. Contact to your Local Sales Staff!");
                                    return result;
                                }
                                else if (BeatAvail.IsBeatAvail == 0)
                                {
                                    result.Add("ERROR=" + BeatAvail.Msg);
                                    return result;
                                }

                                result.Add(objORDR.OCRD.CustomerCode + " - " + objORDR.OCRD.CustomerName);
                                if (objORDR.VehicleID.HasValue)
                                {
                                    result.Add(objORDR.OVCL.VehicleID + " - " + objORDR.OVCL.VehicleNumber);
                                }
                                else
                                    result.Add("");

                                result.Add(objORDR.OCRD.GSTIN);
                                result.Add(objORDR.Notes);
                                result.Add(objORDR.MobilieNumber);
                                result.Add(objORDR.OCRD.IsTemp);
                                if (objORDR.OrderTypeReasonID.HasValue)
                                {
                                    result.Add(objORDR.OrderTypeReasonID.Value + " - " + ctx.ORSNs.FirstOrDefault(x => x.ReasonID == objORDR.OrderTypeReasonID.Value).ReasonName);
                                }
                                else
                                    result.Add("");



                                List<string> Vehicle = ctx.OVCLs.Where(x => x.Active && x.ParentID == VehicleParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.VehicleID, 20, 0).Trim() + " - " + x.VehicleNumber).ToList();
                                List<string> OrderForm = ctx.ORSNs.Where(x => x.Type == "T" && x.Active).Select(x => SqlFunctions.StringConvert((Decimal)x.ReasonID, 20, 0).Trim() + " - " + x.ReasonName).ToList();
                                List<DisData> WareHouse = ctx.OWHS.Where(x => x.Active && x.ParentID == ParentID).Select(x => new DisData { Value = x.WhsID, Text = x.WhsName }).ToList();

                                result.Add(Vehicle);
                                result.Add(OrderForm);
                                result.Add(WareHouse);

                                List<ItemData> BindList = new List<ItemData>();

                                var RDR1s = objORDR.RDR1.Where(x => x.IsDeleted == false && x.MainID == 0).ToList();
                                var RDR1qps = objORDR.RDR1.Where(x => x.IsDeleted == false && x.MainID == 1).ToList();
                                int warehouseid = WareHouse.FirstOrDefault().Value;
                                foreach (RDR1 scheme in RDR1s)
                                {
                                    int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == scheme.ItemID).DivisionlID.Value;
                                    int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == objORDR.CustomerID && x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                                    string SaleRate = ctx.IPL1.Where(x => x.ItemID == scheme.ItemID && x.PriceListID == PriceID).FirstOrDefault().UnitPrice.ToString();
                                    string TotalPackt = ctx.ITM2.Where(x => x.ItemID == scheme.ItemID && x.ParentID == ParentID && x.WhsID == warehouseid).FirstOrDefault().TotalPacket.ToString();
                                    ItemData item = new ItemData();
                                    item.ItemID = scheme.ItemID;
                                    string yesno = scheme.OITM.Active == true ? "Y" : "N";
                                    item.ItemCode = scheme.OITM.ItemCode + " - " + scheme.OITM.ItemName + " - " + TotalPackt + " - " + SaleRate + " - " + yesno;
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
                                    if (RDR1qps.Count > 0)
                                    {
                                        item.IsQPS = 1;
                                    }
                                    else {
                                        item.IsQPS = 0;
                                    }
                                    BindList.Add(item);

                                }
                                result.Add(BindList);
                            }
                            else
                            {
                                result.Add("ERROR=" + "" + "No Order found.");
                            }
                        }
                        else if (type == "P")
                        {
                            OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == OrderID && x.ParentID == custid && x.VendorParentID == ParentID && x.InwardType == 1 && x.OrderRefID == null);
                            if (objOMID != null)
                            {
                                var BeatAvail = ctx.AddHierarchyType_Check(objOMID.ParentID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                                if (BeatAvail.IsBeatAvail == 2)
                                {
                                    result.Add("ERROR=" + "" + "Beat not available for " + objOMID.OCRD.CustomerCode + " # " + objOMID.OCRD.CustomerName + ", so you can not create Sales Invoice. Contact to your Local Sales Staff!");
                                    return result;
                                }
                                else if (BeatAvail.IsBeatAvail == 0)
                                {
                                    result.Add("ERROR=" + BeatAvail.Msg);
                                    return result;
                                }
                                result.Add(objOMID.OCRD.CustomerCode + " - " + objOMID.OCRD.CustomerName);
                                if (objOMID.VehicleID.HasValue)
                                {
                                    result.Add(objOMID.OVCL.VehicleID + " - " + objOMID.OVCL.VehicleNumber);
                                }
                                else
                                    result.Add("");

                                result.Add(objOMID.OCRD.GSTIN);
                                result.Add(objOMID.Notes);
                                result.Add(objOMID.OCRD.Phone);
                                result.Add(objOMID.OCRD.IsTemp);
                                result.Add("");

                                List<string> Vehicle = ctx.OVCLs.Where(x => x.Active && x.ParentID == VehicleParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.VehicleID, 20, 0).Trim() + " - " + x.VehicleNumber).ToList();
                                List<string> OrderForm = ctx.ORSNs.Where(x => x.Type == "T" && x.Active).Select(x => SqlFunctions.StringConvert((Decimal)x.ReasonID, 20, 0).Trim() + " - " + x.ReasonName).ToList();
                                List<DisData> WareHouse = ctx.OWHS.Where(x => x.Active && x.ParentID == ParentID).Select(x => new DisData { Value = x.WhsID, Text = x.WhsName }).ToList();

                                result.Add(Vehicle);
                                result.Add(OrderForm);
                                result.Add(WareHouse);

                                List<ItemData> BindList = new List<ItemData>();

                                var MID1s = objOMID.MID1.ToList();

                                foreach (MID1 scheme in MID1s)
                                {
                                    ItemData item = new ItemData();
                                    item.ItemID = scheme.ItemID;
                                    item.ItemCode = scheme.OITM.ItemCode + " - " + scheme.OITM.ItemName;
                                    item.Quantity = scheme.RequestQty;
                                    item.TotalQty = scheme.TotalQty;
                                    item.SubTotal = scheme.SubTotal;
                                    item.Tax = scheme.Tax;
                                    item.Total = scheme.Total;
                                    item.MainID = 0;
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
                            }
                            else
                            {
                                result.Add("ERROR=" + "" + "No Order found.");
                            }
                        }
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

                //Distributor Active/Inactive ## ticket No:T900008281

                decimal CustomerID = 0;
                string CustomerName = string.Empty;
                if (ctx.OCRDs.Any(x => x.CustomerCode == CustomerCode))
                {
                    var CustmoerData = ctx.OCRDs.Where(x => x.CustomerCode == CustomerCode).Select(x => new { x.CustomerID, x.CustomerName }).FirstOrDefault();
                    CustomerID = CustmoerData.CustomerID;
                    CustomerName = CustmoerData.CustomerName;
                }
                if (ctx.AOCRDs.Any(x => x.CustomerID == CustomerID))
                {
                    var DMSObj = ctx.AOCRDs.FirstOrDefault(x => x.CustomerID == CustomerID && !x.Active);
                    if (DMSObj != null)
                    {
                        result.Add("ERROR=DMS Status of " + CustomerCode + " # " + CustomerName + "<br>is In-Active. <br> So, Invoice can’t Create.");
                        return result;
                    }
                }
                if (ctx.OGCRDs.Any(x => x.CustomerID == CustomerID))
                {
                    var CustGroupList = ctx.OGCRDs.Where(x => x.CustomerID == CustomerID && x.PriceListID != null).ToList();
                    if (CustGroupList.Count > 0)
                    {
                        bool priceInactive = false;
                        string priceName = string.Empty;
                        foreach (var CustGroup in CustGroupList)
                        {
                            var PriceObj = ctx.OIPLs.Any(x => x.PriceListID == CustGroup.PriceListID && x.Active);
                            var PriceData = ctx.OIPLs.Where(x => x.PriceListID == CustGroup.PriceListID).Select(x => new { x.Name }).FirstOrDefault();
                            priceName = PriceData.Name;
                            if (PriceObj)
                            {
                                priceInactive = true;
                            }

                        }
                        if (!priceInactive)
                        {
                            result.Add("ERROR=Pricing Group " + priceName + "<br>is In-Active, Contact To Product Dept.");
                            return result;
                        }
                    }
                }
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
                        data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Name = x.CustomerName, Text = x.Phone, GSTIN = x.GSTIN, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                        if (data == null)
                        {
                            result.Add("ERROR=" + "" + "Un-Register Dealer Not Available for Temporary Customer, Contact To Mktg Dept Only.");
                            return result;
                        }
                        else
                        {
                            data = ctx.OCRDs.Where(x => x.CustomerCode == CustomerCode && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = data.Value, Name = data.Name, Text = x.Phone, GSTIN = x.GSTIN, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                        }

                    }
                    else
                    {
                        data = ctx.OCRDs.Where(x => x.IsTemp == ChkTemp && !x.CustomerCode.ToLower().Contains("dfw") && !x.CustomerName.ToLower().Contains("unregistered dealer") && x.CustomerCode == CustomerCode && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Name = x.CustomerName, Text = x.Phone, GSTIN = x.GSTIN, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                    }
                }
                else
                {
                    data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Name = x.CustomerName, Text = x.Phone, GSTIN = x.GSTIN, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
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

                data.BillToPartyCode = ctx.OCRDs.Where(x => x.CustomerID == data.BillToPartyID).Select(x => x.CustomerCode + " - " + x.CustomerName).FirstOrDefault();

                var BeatAvail = ctx.AddHierarchyType_Check(data.Value, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                if (BeatAvail.IsBeatAvail == 2)
                {
                    result.Add("ERROR=" + "" + "Beat not available for " + CustomerCode + " # " + data.Name + ", so you can not create Sales Invoice. Contact to your Local Sales Staff!");
                    return result;
                }
                else if (BeatAvail.IsBeatAvail == 0)
                {
                    result.Add("ERROR=" + BeatAvail.Msg);
                    return result;
                }

                List<string> items = ctx.LoadItemsForSaleWithStock(ParentID, data.Value, objWHS.WhsID).ToList();

                if (items.Count == 1 && items.FirstOrDefault().Contains("ERROR="))
                {
                    result.Add(items.FirstOrDefault().ToString());
                    return result;
                }

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
                result.Add(data.GSTIN);
                result.Add(data.BillToPartyID);
                result.Add(data.BillToPartyCode);
                // 26-Dec-2022 T900015427
                Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                SqlCommand Cmd3 = new SqlCommand();
                Cmd3.Parameters.Clear();
                Cmd3.CommandType = CommandType.StoredProcedure;
                Cmd3.CommandText = "usp_GetSalesGrowthForInvoice";
                Cmd3.Parameters.AddWithValue("@ParentId", ParentID);
                Cmd3.Parameters.AddWithValue("@CustomerId", data.Value);
                DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                if (dsdata2.Tables.Count > 0)
                {
                    if (dsdata2.Tables[0].Rows.Count > 0)
                    {
                        result.Add(dsdata2.Tables[0].Rows[0]["Growth"].ToString());
                        result.Add(dsdata2.Tables[0].Rows[0]["LastYearSale"].ToString());
                        result.Add(dsdata2.Tables[0].Rows[0]["CurrentYearSale"].ToString());
                        result.Add(dsdata2.Tables[0].Rows[0]["IsGrowth"].ToString());
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
                        data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                        if (data == null)
                        {
                            result.Add("ERROR=" + "" + "Un-Register Dealer Not Available for Temporary Customer, Contact To Mktg Dept Only.");
                            return result;
                        }
                    }
                    else
                    {
                        data = ctx.OCRDs.Where(x => x.IsTemp == ChkTemp && x.CustomerCode == customer && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                    }
                }
                else
                {
                    data = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => new DisData3 { Value = x.CustomerID, Text = x.Phone, BillToPartyID = x.BillToPartyCustID.HasValue ? x.BillToPartyCustID.Value : x.CustomerID }).FirstOrDefault();
                    if (data == null)
                    {
                        result.Add("ERROR=" + "" + "Un-Register Dealer Not Available for Temporary Customer, Contact To Mktg Dept Only.");
                        return result;
                    }
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

                        List<SaleItem_Result> Data = ctx.SaleItem(ParentID, data.Value, PriceID, 0, ItemID, 0, WareHouse, data.BillToPartyID).ToList();
                        if (Data.Count > 0)
                        {

                            GetNormalPricing_Result NormalPriceData = ctx.GetNormalPricing(ParentID, data.Value, DivisionlID, ItemID, Data.FirstOrDefault().UnitPrice, PriceID).FirstOrDefault();
                            if (NormalPriceData == null || NormalPriceData.Flag == 0)
                            {
                                result.Add("ERROR=" + NormalPriceData.Msg);
                            }
                            else
                            {
                                units = Data.Select(x => new DisData2 { Text = x.Unitname, Value = x.UnitID.ToString() + "," + x.UnitPrice.ToString("0.00") + "," + x.Tax.ToString() + "," + x.Quantity.ToString() }).ToList();

                                result.Add(units);

                                ItemData tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID, y.MRP }).ToList()
                                                    select new ItemData
                                                    {
                                                        ItemID = x.Key.ItemID,
                                                        ItemCode = x.Key.ItemCode,
                                                        ItemName = x.Key.ItemName,
                                                        AvailQty = x.Key.AvailQty,
                                                        TaxID = x.Key.TaxID,
                                                        MRP = x.Key.MRP,
                                                        NormalPrice = NormalPriceData.NormalRate
                                                    }).FirstOrDefault();

                                result.Add(tmpList);
                            }
                        }
                        else
                        {
                            result.Add("ERROR=" + "" + "Dealer Pricing Group Not Assign, Contact to Mktg Team Only");
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
    public static List<dynamic> LoadSchemeData(string hidJsonInputMaterial, string hidJsonInputHeader)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {
            //ReadData_Actual(2000010000100000, 97639);

            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());

            var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());

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
                item.UnitID = scheme["UnitID"];
                item.UnitPrice = scheme["UnitPrice"];
                item.MRP = scheme["MRP"];
                item.NormalPrice = scheme["NormalPrice"];
                item.PriceTax = scheme["PriceTax"];
                item.MapQty = scheme["MapQuantity"];
                BindList.Add(item);

            }

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var IsTempCust = false;
                OCRD objOCRD = null;
                if (HeaderData["ChkTemp"].ToString().ToLower() == "false")
                {
                    string Rec = HeaderData["AutoCustomer"].ToString().Trim();
                    objOCRD = ctx.OCRDs.FirstOrDefault(y => y.ParentID == ParentID && y.CustomerCode == Rec && y.Active);
                    if (objOCRD == null)
                    {
                        result = new List<dynamic>();
                        result.Add("ERROR=" + "Customer not found");
                        return result;
                    }
                    IsTempCust = false;
                }
                else
                {
                    objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active);
                    if (objOCRD == null)
                    {
                        result = new List<dynamic>();
                        result.Add("ERROR=" + "Customer not found");
                        return result;
                    }
                    IsTempCust = true;
                }

                Decimal MachineDis = 0;
                Decimal VRSDis = 0;
                Decimal MasterDis = 0;
                Decimal DiscoutDis = 0;
                Decimal SubTotal = 0;
                Decimal Tax = 0;
                Boolean MasterApplied = false;
                Decimal MinusAmt = 0;

                List<POS3> SchemeIDs = new List<POS3>();
                List<SchemeData> SchemeList = new List<SchemeData>();

                int CustType = ctx.OCRDs.FirstOrDefault(y => y.CustomerID == ParentID).Type;
                if (IsTempCust == false)
                {
                    #region Apply Machine / Parlour Discount Sale For Only Dist

                    if (CustType == 2)//MACHINE & PARLOUR FOR DISTRIBUTOR
                    {

                        SchemeList = LoadScheme("DP", objOCRD, BindList);
                        foreach (SchemeData item in SchemeList)
                        {
                            if (item.SchemeID > 0 && item.Discount > 0 && (item.Mode == "D" || item.Mode == "P"))
                            {
                                if (item.ItemID > 0)
                                {
                                    //Skip if Item
                                }
                                else
                                {
                                    SCM1 dis = ctx.SCM1.Where(x => x.CustomerID == objOCRD.CustomerID && x.SchemeID == item.SchemeID && x.Active && x.IsInclude &&
                                         x.UsedCoupon.HasValue && x.CouponAmount.HasValue && (x.CouponAmount.Value - x.UsedCoupon.Value) > 0).OrderBy(x => x.AssetID.Value).FirstOrDefault();
                                    if (dis != null && dis.CouponAmount.HasValue && dis.CouponAmount.Value > 0)
                                    {
                                        Decimal remainamt = dis.CouponAmount.Value - (dis.UsedCoupon.HasValue ? dis.UsedCoupon.Value : 0);
                                        if (remainamt > 0)
                                        {
                                            if (remainamt < item.Discount)
                                            {
                                                item.Discount = remainamt;
                                            }
                                        }
                                        else
                                        {
                                            continue;
                                        }

                                        MachineDis += item.Discount;

                                        if (item.BasedOn == (int)BasedOn.Invoice)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => (x.MainID == 0) && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => x.Scheme += (100 * item.Discount) / Total);
                                        }
                                        else if (item.BasedOn == (int)BasedOn.Item)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => (x.MainID == 0) && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                                .ForEach(x =>
                                                {
                                                    x.SchemeID = item.SchemeID;
                                                    x.ItemScheme += (100 * item.Discount) / Total;
                                                });
                                        }
                                        else if (item.BasedOn == (int)BasedOn.Unit)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => (x.MainID == 0) && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                                .ForEach(x =>
                                                {
                                                    x.SchemeID = item.SchemeID;
                                                    x.ItemScheme += (100 * item.Discount) / Total;
                                                });
                                        }
                                        POS3 objPOS3 = new POS3();
                                        objPOS3.SchemeID = item.SchemeID;
                                        objPOS3.Mode = item.Mode;
                                        objPOS3.Amount = item.Discount;
                                        objPOS3.EffectOnBill = true;
                                        objPOS3.ContraTax = item.ContraTax;
                                        objPOS3.ItemID = item.ItemID;
                                        objPOS3.AssetID = dis.AssetID;
                                        objPOS3.SaleAmount = item.SaleAmount;
                                        objPOS3.BasedOn = item.BasedOn;
                                        objPOS3.RateForScheme = 0;
                                        SchemeIDs.Add(objPOS3);
                                    }
                                }
                            }
                        }

                        result.Add(MachineDis.ToString("0.00"));
                    }
                    else if (CustType == 4)//ADD MANUAL ZERO FOR SS
                    {
                        result.Add("0.00");
                    }
                    #endregion

                    #region Apply VRS Discount Sale For Only Dist

                    if (CustType == 2)//VRS Discount
                    {

                        SchemeList = LoadScheme("V", objOCRD, BindList); //load scheme for VRS Discount also
                        foreach (SchemeData item in SchemeList)
                        {
                            if (item.SchemeID > 0 && item.Discount > 0 && item.Mode == "V")
                            {
                                if (item.ItemID > 0)
                                {
                                    //Skip if Item
                                }
                                else
                                {
                                    SCM1 dis = ctx.SCM1.Where(x => x.CustomerID == objOCRD.CustomerID && x.SchemeID == item.SchemeID && x.Active &&
                                         x.UsedCoupon.HasValue && x.CouponAmount.HasValue && (x.CouponAmount.Value - x.UsedCoupon.Value) > 0).OrderBy(x => x.AssetID.Value).FirstOrDefault();
                                    if (dis != null && dis.CouponAmount.HasValue && dis.CouponAmount.Value > 0)
                                    {
                                        Decimal remainamt = dis.CouponAmount.Value - (dis.UsedCoupon.HasValue ? dis.UsedCoupon.Value : 0);
                                        if (remainamt > 0)
                                        {
                                            if (remainamt < item.Discount)
                                            {
                                                item.Discount = remainamt;
                                            }
                                        }
                                        else
                                        {
                                            continue;
                                        }

                                        VRSDis += item.Discount;

                                        if (item.BasedOn == (int)BasedOn.Invoice)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => x.Scheme += (100 * item.Discount) / Total);
                                        }
                                        else if (item.BasedOn == (int)BasedOn.Item)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                                .ForEach(x =>
                                                {
                                                    x.SchemeID = item.SchemeID;
                                                    x.ItemScheme += (100 * item.Discount) / Total;
                                                });
                                        }
                                        else if (item.BasedOn == (int)BasedOn.Unit)
                                        {
                                            var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                            BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                                .ForEach(x =>
                                                {
                                                    x.SchemeID = item.SchemeID;
                                                    x.ItemScheme += (100 * item.Discount) / Total;
                                                });
                                        }
                                        POS3 objPOS3 = new POS3();
                                        objPOS3.SchemeID = item.SchemeID;
                                        objPOS3.Mode = item.Mode;
                                        objPOS3.Amount = item.Discount;
                                        objPOS3.EffectOnBill = true;
                                        objPOS3.ContraTax = item.ContraTax;
                                        objPOS3.ItemID = item.ItemID;
                                        objPOS3.AssetID = dis.AssetID;
                                        objPOS3.SaleAmount = item.SaleAmount;
                                        objPOS3.BasedOn = item.BasedOn;
                                        objPOS3.RateForScheme = 0;
                                        SchemeIDs.Add(objPOS3);
                                    }
                                }
                            }
                        }

                        result.Add(VRSDis.ToString("0.00"));
                    }
                    else if (CustType == 4)//ADD MANUAL ZERO FOR SS
                    {
                        result.Add("0.00");
                    }
                    #endregion

                    #region Apply Master Scheme FOR DIST & SS

                    SchemeList = LoadScheme("M", objOCRD, BindList);

                    foreach (SchemeData item in SchemeList)
                    {
                        if (item.SchemeID > 0 && item.Discount > 0 && item.Mode == "M")
                        {
                            if (item.ItemID > 0)
                            {
                                //Skip if Item
                            }
                            else
                            {
                                MasterDis += item.Discount;

                                if (objOCRD.IsDiscount)
                                {
                                    if (item.BasedOn == (int)BasedOn.Invoice)
                                    {
                                        var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                        BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList().
                                            ForEach(x => x.Scheme += (100 * item.Discount) / Total);
                                    }
                                    else if (item.BasedOn == (int)BasedOn.Item)
                                    {
                                        var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                        BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                            .ForEach(x =>
                                            {
                                                x.SchemeID = item.SchemeID;
                                                x.ItemScheme += (100 * item.Discount) / Total;
                                            });
                                    }
                                    else if (item.BasedOn == (int)BasedOn.Unit)
                                    {
                                        var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                        BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                            .ForEach(x =>
                                            {
                                                x.SchemeID = item.SchemeID;
                                                x.ItemScheme += (100 * item.Discount) / Total;
                                            });
                                    }
                                }

                                POS3 objPOS3 = new POS3();
                                objPOS3.SchemeID = item.SchemeID;
                                objPOS3.Mode = item.Mode;
                                objPOS3.Amount = item.Discount;
                                objPOS3.EffectOnBill = objOCRD.IsDiscount;
                                objPOS3.ContraTax = item.ContraTax;
                                objPOS3.ItemID = item.ItemID;
                                objPOS3.SaleAmount = item.SaleAmount;
                                objPOS3.BasedOn = item.BasedOn;
                                objPOS3.RateForScheme = 0;
                                SchemeIDs.Add(objPOS3);

                                MasterApplied = true;
                            }
                        }
                    }

                    if (objOCRD.IsDiscount)
                    {
                        result.Add(MasterDis.ToString("0.00"));
                    }
                    else
                    {
                        result.Add(MasterDis.ToString("0.00") + "-" + "CN");
                        MinusAmt = MasterDis;
                    }

                    #endregion
                }
                else
                {
                    result.Add("0.00"); // Add Manual ZERO for Machine / Parlour
                    result.Add("0.00");  //Add Manual ZERO for VRS 
                    result.Add("0.00");  //Add Manual ZERO for Master 
                }
                if (CustType == 2)//QPS FRO DISTRIBUTOR & TEMP CUSTOMER DIST
                {
                    result.Add("0.00"); // Add Manual Discount Scheme 

                    BindList = ResetAll(BindList, out SubTotal, out Tax);

                    result.Add(BindList);

                    result.Add(LoadScheme("S", objOCRD, BindList, MinusAmt, MasterApplied, IsTempCust));

                    result.Add(SubTotal);
                    result.Add(Tax);
                    result.Add(SchemeIDs);
                }
                else if (CustType == 4 && IsTempCust == false)//SS && Permanent Customer
                {
                    #region Apply STOD Scheme

                    SchemeList = LoadScheme("A", objOCRD, BindList);

                    foreach (SchemeData item in SchemeList)
                    {
                        if (item.SchemeID > 0 && item.Discount > 0 && item.Mode == "A")
                        {
                            if (item.ItemID > 0)
                            {
                                //Skip if Item
                            }
                            else
                            {
                                var ssdis = ctx.OCLMSUMs.Where(x => x.CustomerID == objOCRD.CustomerID && (x.ApprovedAmount - x.DeductionAmount) > 0).
                                    Select(x => (x.ApprovedAmount - x.DeductionAmount)).DefaultIfEmpty(0).FirstOrDefault();
                                if (ssdis > 0)
                                {
                                    if (ssdis < item.Discount)
                                    {
                                        item.Discount = ssdis;
                                    }
                                }
                                else
                                {
                                    continue;
                                }

                                DiscoutDis += item.Discount;

                                if (item.BasedOn == (int)BasedOn.Invoice)
                                {
                                    var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                    BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList().
                                        ForEach(x => x.Scheme += (100 * item.Discount) / Total);
                                }
                                else if (item.BasedOn == (int)BasedOn.Item)
                                {
                                    var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                    BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                        .ForEach(x =>
                                        {
                                            x.SchemeID = item.SchemeID;
                                            x.ItemScheme += (100 * item.Discount) / Total;
                                        });
                                }
                                else if (item.BasedOn == (int)BasedOn.Unit)
                                {
                                    var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                    BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, objOCRD.CustomerID).FirstOrDefault().Value == 1).ToList()
                                        .ForEach(x =>
                                        {
                                            x.SchemeID = item.SchemeID;
                                            x.ItemScheme += (100 * item.Discount) / Total;
                                        });
                                }

                                POS3 objPOS3 = new POS3();
                                objPOS3.SchemeID = item.SchemeID;
                                objPOS3.Mode = item.Mode;
                                objPOS3.Amount = item.Discount;
                                objPOS3.EffectOnBill = objOCRD.IsDiscount;
                                objPOS3.ContraTax = item.ContraTax;
                                objPOS3.ItemID = item.ItemID;
                                objPOS3.SaleAmount = item.SaleAmount;
                                objPOS3.BasedOn = item.BasedOn;
                                objPOS3.RateForScheme = 0;
                                SchemeIDs.Add(objPOS3);
                            }
                        }
                    }

                    #endregion

                    result.Add(DiscoutDis.ToString("0.00"));

                    BindList = ResetAll(BindList, out SubTotal, out Tax);

                    result.Add(BindList);

                    result.Add(new List<SchemeData>());// Empty Scheme List For QPS only

                    result.Add(SubTotal);
                    result.Add(Tax);
                    result.Add(SchemeIDs);
                }

            }

        }
        catch (Exception ex)
        {
            result = new List<dynamic>();
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }


        return result;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> ApplyScheme(string hidJsonInputMaterial, string hidJsonInputHeader, string hidJsonInputScheme, string hdnSchemeIDs)
    {
        List<dynamic> result = new List<dynamic>();

        try
        {

            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

            var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
            var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());
            var SchemeRecord = JsonConvert.DeserializeObject<dynamic>(hidJsonInputScheme.ToString());
            var SchemeIDrecord = JsonConvert.DeserializeObject<dynamic>(hdnSchemeIDs.ToString());


            List<POS3> SchemeIDs = new List<POS3>();
            if (SchemeIDrecord != null)
            {
                foreach (var scheme in SchemeIDrecord)
                {
                    POS3 item = new POS3();
                    item.SchemeID = scheme["SchemeID"];
                    item.Mode = scheme["Mode"];
                    item.Amount = scheme["Amount"];
                    item.EffectOnBill = scheme["EffectOnBill"];
                    item.AssetID = scheme["AssetID"];
                    item.ContraTax = scheme["ContraTax"];
                    item.ItemID = scheme["ItemID"];
                    item.SaleAmount = scheme["SaleAmount"];
                    item.BasedOn = scheme["BasedOn"];
                    item.RateForScheme = scheme["RateForScheme"];
                    SchemeIDs.Add(item);
                }
            }
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

                item.ItemCode = scheme["ItemCode"];
                item.ItemName = scheme["ItemName"];

                item.Price = scheme["Price"];
                item.Scheme = scheme["Scheme"];
                item.ItemScheme = scheme["ItemScheme"];

                item.UnitID = scheme["UnitID"];
                item.UnitPrice = scheme["UnitPrice"];
                item.MRP = scheme["MRP"];
                item.NormalPrice = scheme["NormalPrice"];
                item.PriceTax = scheme["PriceTax"];

                item.MapQty = scheme["MapQuantity"];
                BindList.Add(item);

            }

            List<SchemeData> SchemeList = new List<SchemeData>();

            foreach (var scheme in SchemeRecord)
            {
                SchemeData item = new SchemeData();

                item.Check = scheme["check"];
                item.ScName = scheme["SchemeName"];
                item.ItemCode = scheme["ItemCode"];
                item.ItemName = scheme["ItemName"];
                item.UnitName = scheme["Unit"];
                if (scheme["Quantity"] == "")
                {
                    scheme["Quantity"] = 0;
                }
                item.Quantity = scheme["Quantity"];
                if (scheme["Discount"] == "")
                {
                    scheme["Discount"] = 0;
                }
                item.Discount = scheme["Discount"];
                if (scheme["SchemeID"] == "")
                {
                    scheme["SchemeID"] = 0;
                }
                item.SchemeID = scheme["SchemeID"];
                item.BasedOn = scheme["BasedOn"];
                item.RateForScheme = scheme["RateForScheme"];
                item.NormalPrice = scheme["NormalPrice"];
                item.SaleAmount = scheme["SaleAmount"];
                item.Mode = scheme["Mode"];
                item.TaxID = scheme["TaxID"];
                item.Tax = scheme["Tax"];
                item.Price = scheme["Price"];
                item.PriceTax = scheme["PriceTax"];
                item.ContraTax = scheme["ContraTax"];
                item.UnitPrice = scheme["UnitPrice"];
                item.MRP = scheme["MRP"];
                item.ItemID = scheme["ItemID"];

                SchemeList.Add(item);

            }

            //if (HeaderData["ChkTemp"].ToString().ToLower() == "false")
            //{
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string AutoCustomer = Convert.ToString(HeaderData["AutoCustomer"]);
                OCRD objOCRD = null;
                if (!String.IsNullOrEmpty(AutoCustomer))
                    objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == ParentID && x.CustomerCode == AutoCustomer);
                decimal Customerid = 0;
                if (objOCRD != null)
                    Customerid = objOCRD.CustomerID;

                Decimal QPSDis = 0;
                foreach (SchemeData item in SchemeList)
                {
                    if (item.SchemeID > 0 && (item.Mode == "Q" || item.Check))
                    {
                        if (item.ItemID > 0)
                        {
                            var stock = ctx.ITM2.FirstOrDefault(x => x.ParentID == ParentID && x.ItemID == item.ItemID);
                            Decimal AvailQty = stock == null ? 0 : stock.TotalPacket;
                            if (AvailQty <= 0)
                            {
                                result.Add("ERROR=Insufficient Stock, So You Can Not Dispatch This Product: " + item.ItemCode);
                            }
                            //if (AvailQty > 0)
                            //{
                            ItemData objPOS1 = new ItemData();

                            objPOS1.ItemID = item.ItemID;
                            objPOS1.ItemCode = item.ItemCode;
                            objPOS1.ItemName = item.ItemName;
                            objPOS1.AvailQty = AvailQty;
                            objPOS1.UnitID = item.UnitID;
                            objPOS1.SchemeID = item.SchemeID;
                            objPOS1.UnitName = item.UnitName;
                            objPOS1.TaxID = item.TaxID;
                            objPOS1.AddOn = true;

                            objPOS1.Quantity = item.Quantity;
                            objPOS1.MapQty = 1;
                            objPOS1.TotalQty = item.Quantity;

                            objPOS1.ItemScheme = item.Discount;
                            objPOS1.MainID = 1;

                            objPOS1.UnitPrice = item.UnitPrice;
                            objPOS1.MRP = item.MRP;
                            objPOS1.NormalPrice = item.NormalPrice;
                            objPOS1.PriceTax = item.PriceTax;

                            objPOS1.Price = item.Price;
                            objPOS1.SubTotal = item.Price * item.Quantity;
                            objPOS1.Tax = item.Tax;
                            objPOS1.Total = objPOS1.SubTotal + objPOS1.Tax;
                            BindList.Add(objPOS1);

                            item.Discount = ((item.UnitPrice * item.Discount) / 100) * item.Quantity;

                            BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value != 1).ToList()
                                .ForEach(x => { x.ItemCode = "#  " + x.ItemCode; x.MainID = 2; });

                            //string WhsID = HeaderData["ddlWhs"];
                            //Int32 WWID = Int32.TryParse(WhsID, out WWID) ? WWID : 0;

                            //if (objPOS1.Quantity > 0)
                            //{
                            //    ITM2 ITM2 = ctx.ITM2.FirstOrDefault(x => x.ParentID == ParentID && x.WhsID == WWID && x.ItemID == objPOS1.ItemID);

                            //    //ITM2.TotalPacket = ITM2 == null ? 0 : ITM2.TotalPacket -= objPOS1.TotalQty;
                            //    //if (ITM2.TotalPacket < 0)
                            //    //{
                            //    //    result.Add("ERROR=Insufficient Stock, So You Can Not Dispatch This Product: " + item.ItemCode);
                            //    //}
                            //}
                            //BindList.Insert(((BindList.Count) - 1), objPOS1);
                            //}
                            //else
                            //{
                            //    Msg += item.ScName + " is not apply beacuse " + item.ItemName + " is not availble.";
                            //}
                        }
                        else
                        {
                            QPSDis += item.Discount;
                            if (item.BasedOn == (int)BasedOn.Invoice)
                            {
                                var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).ToList()
                                    .ForEach(x => x.Scheme += (((100 * item.Discount) / Total) - ((x.Scheme * ((100 * item.Discount) / Total)) / 100)));
                            }
                            else if (item.BasedOn == (int)BasedOn.Item)
                            {
                                var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).ToList()
                                    .ForEach(x =>
                                    {
                                        x.SchemeID = item.SchemeID;
                                        x.ItemScheme += (((100 * item.Discount) / Total) - ((x.Scheme * ((100 * item.Discount) / Total)) / 100));
                                    });
                            }
                            else if (item.BasedOn == (int)BasedOn.Unit)
                            {
                                var Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                                BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, item.SchemeID, Customerid).FirstOrDefault().Value == 1).ToList()
                                    .ForEach(x =>
                                    {
                                        x.SchemeID = item.SchemeID;
                                        x.ItemScheme += (((100 * item.Discount) / Total) - ((x.Scheme * ((100 * item.Discount) / Total)) / 100));
                                    });
                            }
                        }
                        POS3 objPOS3 = new POS3();
                        objPOS3.SchemeID = item.SchemeID;
                        objPOS3.Mode = item.Mode;
                        objPOS3.Amount = item.Discount;
                        objPOS3.EffectOnBill = true;
                        objPOS3.ContraTax = item.ContraTax;
                        objPOS3.ItemID = item.ItemID;
                        objPOS3.SaleAmount = item.SaleAmount;
                        objPOS3.BasedOn = item.BasedOn;
                        objPOS3.RateForScheme = item.RateForScheme;
                        SchemeIDs.Add(objPOS3);
                    }
                }
                result.Add(QPSDis.ToString("0.00"));

                result.Add(BindList);

                Decimal SubTotal = 0;
                Decimal Tax = 0;
                BindList = ResetAll(BindList, out SubTotal, out Tax);
                result.Add(SubTotal);
                result.Add(Tax);
                result.Add(SchemeIDs);

            }
            //}
            //else
            //{
            //    result.Add("Temp");
            //}
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;

        //ddlWhs.Enabled = txtCustomer.Enabled = txtTemplate.Enabled = gvScheme.Enabled = gvItem.Enabled = false;
        //btnApplyScheme.Visible = btnAllScheme.Visible = false;
        //btnRemoveScheme.Visible = true;
        //divdata.Style.Remove("display");
        //ResetAll();
        //hdnSchemeApply.Value = "true";
        //btnSubmit.Enabled = true;
        //btnSavePrint.Enabled = true;
        //if (String.IsNullOrEmpty(Msg))
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
        //else
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Msg + "', 3); ChangeQuantity();", true);
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveData(string hidJsonInputMaterial, string hidJsonInputHeader, string hidJsonInputScheme, string hdnSchemeIDs)
    {

        StringBuilder sb = new StringBuilder();
        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                int UserID = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
                int CustType = Convert.ToInt32(HttpContext.Current.Session["Type"]);

                Int32 IntNum = 0;
                Decimal DecNum = 0;

                var SchemeData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputMaterial.ToString());
                var HeaderData = JsonConvert.DeserializeObject<dynamic>(hidJsonInputHeader.ToString());
                var SchemeRecord = JsonConvert.DeserializeObject<dynamic>(hidJsonInputScheme.ToString());
                var SchemeIDrecord = JsonConvert.DeserializeObject<dynamic>(hdnSchemeIDs.ToString());

                List<POS3> SchemeIDs = new List<POS3>();
                if (SchemeIDrecord != null)
                {
                    foreach (var scheme in SchemeIDrecord)
                    {
                        POS3 item = new POS3();
                        item.SchemeID = scheme["SchemeID"];
                        item.Mode = scheme["Mode"];
                        item.Amount = scheme["Amount"];
                        item.EffectOnBill = scheme["EffectOnBill"];
                        item.AssetID = scheme["AssetID"];
                        item.ContraTax = scheme["ContraTax"];
                        item.ItemID = scheme["ItemID"];
                        item.SaleAmount = scheme["SaleAmount"];
                        item.BasedOn = scheme["BasedOn"];
                        item.RateForScheme = scheme["RateForScheme"];
                        SchemeIDs.Add(item);
                    }
                }
                string strOrderID = Convert.ToString(HeaderData["OrderID"]);
                string strOrderType = Convert.ToString(HeaderData["OrderType"]);
                string strOrderCustID = Convert.ToString(HeaderData["OrderCustID"]);
                string strBillToCustID = Convert.ToString(HeaderData["BillToCustomerID"]);

                string AutoCustomer = Convert.ToString(HeaderData["AutoCustomer"]);
                string AutoTemplate = Convert.ToString(HeaderData["AutoTemplate"]);
                string AutoVehicle = Convert.ToString(HeaderData["AutoVehicle"]);
                string AutoOrderForm = Convert.ToString(HeaderData["AutoOrderForm"]);

                string Mobile = Convert.ToString(HeaderData["Mobile"]);
                string GSTIN = Convert.ToString(HeaderData["GSTIN"]);
                string Date = Convert.ToString(HeaderData["Date"]);
                string Pending = Convert.ToString(HeaderData["Pending"]);

                string ChkTemp = Convert.ToString(HeaderData["ChkTemp"]);
                string chkExisting = Convert.ToString(HeaderData["chkExisting"]);

                string ddlWhs = Convert.ToString(HeaderData["ddlWhs"]);
                string SubTotal = Convert.ToString(HeaderData["SubTotal"]);
                string Total = Convert.ToString(HeaderData["Total"]);
                string Tax = Convert.ToString(HeaderData["Tax"]);
                string Paid = Convert.ToString(HeaderData["Paid"]);
                string MScheme = Convert.ToString(HeaderData["MScheme"]);
                string QScheme = Convert.ToString(HeaderData["QScheme"]);
                string Rounding = Convert.ToString(HeaderData["Rounding"]);
                string Notes = Convert.ToString(HeaderData["Notes"]);
                Decimal BillToPartyID = Decimal.TryParse(strBillToCustID, out BillToPartyID) ? BillToPartyID : 0;
                List<ItemData> BindList = new List<ItemData>();

                foreach (var scheme in SchemeData)
                {
                    ItemData item = new ItemData();
                    item.ItemID = scheme["ItemID"];
                    item.ItemCode = scheme["ItemCode"];
                    item.OrderQuantity = scheme["OrderQty"];
                    item.Quantity = scheme["RequestQty"];
                    item.TotalQty = scheme["TotalQty"];
                    item.SubTotal = scheme["SubTotal"];
                    item.Tax = scheme["Tax"];
                    item.Total = scheme["Total"];
                    item.MainID = scheme["MainID"];

                    item.Price = scheme["Price"];
                    item.Scheme = scheme["Scheme"];
                    item.ItemScheme = scheme["ItemScheme"];

                    if (scheme["SchemeID"] != "0")
                        item.SchemeID = scheme["SchemeID"];

                    item.UnitID = scheme["UnitID"];
                    item.UnitPrice = scheme["UnitPrice"];
                    item.MRP = scheme["MRP"];
                    item.NormalPrice = scheme["NormalPrice"];
                    item.PriceTax = scheme["PriceTax"];
                    item.MapQty = scheme["MapQuantity"];
                    item.TaxID = scheme["TaxID"];
                    BindList.Add(item);

                }

                //List<SchemeData> SchemeList = new List<SchemeData>();

                //foreach (var scheme in SchemeRecord)
                //{
                //    SchemeData item = new SchemeData();

                //    item.Check = scheme["check"];
                //    item.ScName = scheme["SchemeName"];
                //    item.ItemCode = scheme["ItemCode"];
                //    item.ItemName = scheme["ItemName"];
                //    item.UnitName = scheme["Unit"];
                //    item.Quantity = scheme["Quantity"];
                //    item.Discount = scheme["Discount"];
                //    item.SchemeID = scheme["SchemeID"];
                //    item.BasedOn = scheme["BasedOn"];
                //    item.Mode = scheme["Mode"];
                //    item.TaxID = scheme["TaxID"];
                //    item.Tax = scheme["Tax"];
                //    item.Price = scheme["Price"];
                //    item.PriceTax = scheme["PriceTax"];
                //    item.ContraTax = scheme["ContraTax"];
                //    item.ItemID = scheme["ItemID"];
                //    SchemeList.Add(item);

                //}

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
                    if (string.IsNullOrEmpty(AutoCustomer.Trim()))
                    {
                        return "ERROR=Enter Customer Name.";
                    }
                    objOCRD = new OCRD();
                    objOCRD.Type = Convert.ToInt32(HttpContext.Current.Session["Type"]) + 1;
                    var cid = objOCRD.Type.ToString() + ctx.GetCustomerID("OCRD", "CustomerID", ParentID).FirstOrDefault().Value.ToString("D5") + ParentID.ToString().Substring(1, 10);
                    objOCRD.CustomerID = Convert.ToDecimal(cid);
                    objOCRD.ParentID = ParentID;
                    objOCRD.CustomerCode = objOCRD.CustomerID.ToString();
                    objOCRD.CreatedBy = UserID;
                    objOCRD.Phone = Mobile;
                    objOCRD.GSTIN = GSTIN;
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
                    BillToPartyID = objOCRD.CustomerID;
                }
                else
                {
                    if (!String.IsNullOrEmpty(AutoCustomer))
                    {
                        if (ChkTemp.ToLower() == "true")
                        {
                            objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == ParentID && x.CustomerCode == AutoCustomer && x.IsTemp && x.Active);
                            BillToPartyID = objOCRD.CustomerID;
                        }
                        else
                            objOCRD = ctx.OCRDs.FirstOrDefault(x => x.ParentID == ParentID && x.CustomerCode == AutoCustomer && !x.IsTemp && x.Active);
                    }
                }
                if (objOCRD == null)
                {
                    return "ERROR=Select Proper Customer.";
                }
                if ((objOCRD.CustomerName.ToLower().Contains("un") && (objOCRD.CustomerName.ToLower().Contains("register") || objOCRD.CustomerName.ToLower().Contains("registar"))) || objOCRD.CustomerName.ToLower().Contains("unregister") || objOCRD.CustomerName.ToLower().Contains("un-register") || objOCRD.CustomerName.ToLower().Contains("unregistar") || objOCRD.CustomerName.ToLower().Contains("un-registar"))
                {
                    return "ERROR=You can not enter customer name like this.";
                }
                objOCRD.Phone = Mobile;
                objOCRD.GSTIN = GSTIN;

                OPOS objOPOS = new OPOS();
                objOPOS.SaleID = ctx.GetKey("OPOS", "SaleID", "", ParentID, 0).FirstOrDefault().Value;
                objOPOS.CreatedDate = DateTime.Now;
                objOPOS.CreatedBy = UserID;
                objOPOS.OrderType = (int)SaleOrderType.DirectSale;
                objOPOS.Status = "O";


                int OrderID = 0;
                ORDR objORDR = null;
                OMID objOMID = null;
                if (!string.IsNullOrEmpty(strOrderID) && Int32.TryParse(strOrderID, out OrderID) && OrderID > 0)
                {
                    if (strOrderType == "O")
                    {
                        objORDR = ctx.ORDRs.FirstOrDefault(x => x.ParentID == ParentID && x.OrderType == (int)SaleOrderType.Order && x.OrderID == OrderID);
                        if (objORDR == null)
                        {
                            return "ERROR=Same sale order is already closed.";
                        }
                        objORDR.OrderType = (int)SaleOrderType.Delivery;

                        objOPOS.OrderType = (int)SaleOrderType.Delivery;
                        objOPOS.OrderRefID = objORDR.OrderID;
                    }
                    else if (strOrderType == "P")
                    {
                        Decimal custid = Decimal.TryParse(strOrderCustID, out custid) ? custid : 0;

                        objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == custid && x.VendorParentID == ParentID && x.InwardType == 1 && x.InwardID == OrderID && x.OrderRefID == null);
                        if (objOMID == null)
                        {
                            return "ERROR=Same order is already closed.";
                        }
                        objOMID.Status = "C";
                        objOMID.UpdatedDate = DateTime.Now;
                        objOMID.UpdatedBy = UserID;

                        objOPOS.OrderType = (int)SaleOrderType.Delivery;
                        objOPOS.PORefID = objOMID.InwardID;
                        objOPOS.Status = "O";
                    }
                }

                ctx.OPOS.Add(objOPOS);

                int vehicleID = 0;
                decimal VehicleParentID = CustType == 4 ? 1000010000000000 : ParentID;

                if (!string.IsNullOrEmpty(AutoVehicle))
                {
                    if (Int32.TryParse(AutoVehicle, out vehicleID) && vehicleID > 0)
                    {
                        if (ctx.OVCLs.Any(x => x.VehicleID == vehicleID && x.ParentID == VehicleParentID && x.Active))
                        {
                            objOPOS.VehicleID = vehicleID;
                        }
                        else
                        {
                            return "ERROR=Select Proper Vehicle.";
                        }
                    }
                    else
                    {
                        return "ERROR=Select Proper Vehicle.";
                    }
                }
                else if (CustType == 4)
                    return "ERROR=Please select vehicle.";


                OSEQ objOSEQ = null;
                var date = Common.DateTimeConvert(Date);
                //if (!String.IsNullOrEmpty(objOCRD.VATNumber))
                //{
                objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "T" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();
                objOPOS.ProcessID = (int)SalesType.Tax;
                //}
                //else
                //{
                //    objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "S" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();
                //    objOPOS.ProcessID = (int)SalesType.Retail;
                //}

                if (objOSEQ != null)
                {
                    objOSEQ.RorderNo++;
                    objOPOS.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                }
                else
                {
                    return "ERROR=Invoice Series Not Found.";
                }
                string BillRefNo = Common.Get8Digits();
                if (ctx.OPOS.Any(x => x.BillRefNo == BillRefNo))
                    objOPOS.BillRefNo = Common.Get8Digits();
                else
                    objOPOS.BillRefNo = BillRefNo;

                var ParentCust = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(y => new { y.CompositeScheme, y.GSTIN }).FirstOrDefault();

                objOPOS.DocType = "N";
                objOPOS.GSTIN = ParentCust.GSTIN;
                if (ParentCust.CompositeScheme)
                {
                    objOPOS.DocType = "C";
                }
                else if (String.IsNullOrEmpty(ParentCust.GSTIN))
                {
                    objOPOS.DocType = "U";
                    if (ctx.OPOS.Any(x => x.ParentID == ParentID) && ctx.OPOS.Where(x => x.ParentID == ParentID && x.SaleID < objOPOS.SaleID).OrderByDescending(y => y.SaleID).FirstOrDefault().DocType == "N")
                    {
                        return "ERROR=Previous bills are created with GSTIN, so now you can not create bill in under composite.";
                    }
                }

                objOPOS.ParentID = ParentID;

                objOPOS.CustomerID = objOCRD.CustomerID;
                //objOPOS.BillToCustomerID = (BillToPartyID != 0) ? BillToPartyID : objOPOS.CustomerID;
                objOPOS.BillToCustomerID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOPOS.CustomerID) != null && ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOPOS.CustomerID).BillToPartyCustID > 0 ? ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOPOS.CustomerID).BillToPartyCustID : objOPOS.CustomerID;
                objOPOS.Date = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                objOPOS.MobilieNumber = Mobile;
                objOPOS.OrderTypeReasonID = Int32.TryParse(AutoOrderForm.Trim(), out IntNum) ? IntNum : 0;
                objOPOS.SubTotal = Decimal.TryParse(SubTotal, out DecNum) ? DecNum : 0;
                objOPOS.Rounding = Decimal.TryParse(Rounding, out DecNum) ? DecNum : 0;
                objOPOS.Tax = Decimal.TryParse(Tax, out DecNum) ? DecNum : 0;
                objOPOS.Total = Decimal.TryParse(Total, out DecNum) ? DecNum : 0;
                objOPOS.Paid = Decimal.TryParse(Paid, out DecNum) ? DecNum : 0;
                objOPOS.Pending = Decimal.TryParse(Pending, out DecNum) ? DecNum : 0;
                objOPOS.Notes = Notes;
                objOPOS.UpdatedDate = DateTime.Now;
                objOPOS.UpdatedBy = UserID;
                sb.Append("<table><tr><th>SaleId</th><th>CustomerId</th><th>DistributorId</th><th>Total</th><th>Rounding</th><th>Tax</th><th>SubTotal</th><th>Pending</th><th>BillRefNo</th><th>Invoice No</th><th>OrderRefId</th></tr>");
                sb.Append("<tr><td>" + objOPOS.SaleID + "</td><td>" + objOCRD.CustomerID + "</td><td>" + ParentID + "</td><td>" + objOPOS.Total + "</td><td>" + objOPOS.Rounding + "</td><td>" + objOPOS.Tax + "</td><td>" + objOPOS.SubTotal + "</td><td>" + objOPOS.Pending + "</td><td>" + objOPOS.BillRefNo + "</td><td>" + objOPOS.InvoiceNumber + "</td><td>" + objOPOS.OrderRefID + "</td></tr></table><br/><br/><br/><br/>");

                if (!objOCRD.IsDiscount)
                {
                    var Mscheme = MScheme.Split("-".ToArray()).First().ToString();
                    decimal Amount = Decimal.TryParse(Mscheme, out DecNum) ? DecNum : 0;
                    if (Amount > 0)
                    {
                        OCNT objOCNT = new OCNT();
                        objOCNT.CreditNoteID = ctx.GetKey("OCNT", "CreditNoteID", "", ParentID, 0).FirstOrDefault().Value;
                        objOCNT.ParentID = ParentID;
                        objOCNT.CreditNoteDate = DateTime.Now;
                        objOCNT.CustomerID = objOCRD.CustomerID;
                        objOCNT.CreditNoteType = "M";
                        objOCNT.Amount = Amount;
                        objOCNT.Status = "C";
                        objOCNT.Notes = "";
                        objOCNT.CreatedDate = DateTime.Now;
                        objOCNT.CreatedBy = UserID;
                        objOCNT.UpdatedDate = DateTime.Now;
                        objOCNT.UpdatedBy = UserID;
                        objOCNT.RemainAmount = objOCNT.Amount;
                        ctx.OCNTs.Add(objOCNT);

                        objOPOS.WaitingID = objOCNT.CreditNoteID;
                    }
                }
                //if (objOCRD.IsTemp == false)
                //{
                int Count3 = ctx.GetKey("POS3", "POS3ID", "", ParentID, null).FirstOrDefault().Value;
                foreach (POS3 item in SchemeIDs)
                {
                    Decimal remainamt = 0;
                    if (item.Mode == "D" || item.Mode == "P" || item.Mode == "V")
                    {
                        SCM1 dis = ctx.SCM1.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.AssetID == item.AssetID && x.SchemeID == item.SchemeID && x.Active);
                        if (dis != null && dis.CouponAmount.HasValue && dis.CouponAmount.Value > 0)
                        {
                            remainamt = dis.CouponAmount.Value - (dis.UsedCoupon.HasValue ? dis.UsedCoupon.Value : 0);
                            if (remainamt < item.Amount)
                            {
                                if (item.Mode == "D" || item.Mode == "P")
                                    return "ERROR=Machine / Parlour scheme amount exceed";
                                else
                                    return "ERROR=VRS Discount scheme amount exceed";
                            }
                            else
                            {
                                dis.UsedCoupon = dis.UsedCoupon.GetValueOrDefault(0) + item.Amount;
                            }
                        }
                    }
                    if (item.Mode == "A")
                    {
                        var objOCLMSUM = ctx.OCLMSUMs.Where(x => x.CustomerID == objOCRD.CustomerID && (x.ApprovedAmount - x.DeductionAmount) > 0).FirstOrDefault();
                        if (objOCLMSUM != null)
                        {
                            remainamt = objOCLMSUM.ApprovedAmount - objOCLMSUM.DeductionAmount;
                            if (remainamt < item.Amount)
                            {
                                return "ERROR=STOD scheme amount exceed";
                            }
                            else
                            {
                                OCLMINV objINV = new OCLMINV();
                                objINV.ClaimInvID = ctx.GetKey("OCLMINV", "ClaimInvID", "", ParentID, 0).FirstOrDefault().Value;
                                objINV.ParentID = ParentID;
                                objINV.CustomerID = objOCRD.CustomerID;
                                objINV.SaleID = objOPOS.SaleID;
                                objINV.SaleDate = objOPOS.Date;
                                objINV.Available = remainamt;
                                objINV.SaleAmount = objOPOS.Total;
                                objINV.SaleDiscount = item.Amount;
                                objINV.CreatedBy = UserID;
                                objINV.CreatedDate = DateTime.Now;
                                ctx.OCLMINVs.Add(objINV);

                                objOCLMSUM.DeductionAmount = objOCLMSUM.DeductionAmount + item.Amount;
                            }
                        }

                    }
                    POS3 objPOS3 = new POS3();
                    objPOS3.POS3ID = Count3++;
                    objPOS3.ParentID = ParentID;
                    objPOS3.SchemeID = item.SchemeID;
                    objPOS3.Mode = item.Mode;
                    objPOS3.AssetID = item.AssetID;
                    objPOS3.AvailCouponAmount = remainamt;
                    objPOS3.Amount = item.Amount;
                    objPOS3.EffectOnBill = item.EffectOnBill;
                    objPOS3.SaleAmount = item.SaleAmount;
                    objPOS3.BasedOn = item.BasedOn;
                    objPOS3.RateForScheme = item.RateForScheme;
                    objPOS3.ContraTax = item.ContraTax;
                    if (item.ItemID > 0)
                        objPOS3.ItemID = item.ItemID;
                    objOPOS.POS3.Add(objPOS3);
                }
                //}
                DecNum = Decimal.TryParse(Paid, out DecNum) ? DecNum : 0;
                if (DecNum > 0)
                {
                    POS2 objPOS2 = new POS2();
                    objPOS2.POS2ID = ctx.GetKey("POS2", "POS2ID", "", ParentID, null).FirstOrDefault().Value;
                    objPOS2.ParentID = ParentID;
                    objPOS2.Date = DateTime.Now;
                    objPOS2.DocName = "";
                    objPOS2.DocNo = "";
                    objPOS2.Amount = DecNum;
                    objPOS2.PaymentMode = (int)PaymentMode.Cash;
                    objPOS2.Status = "C";
                    objOPOS.POS2.Add(objPOS2);
                }
                int Count = ctx.GetKey("POS1", "POS1ID", "", ParentID, null).FirstOrDefault().Value;
                int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                objOPOS.POS1.ToList().ForEach(x => x.IsDeleted = true);
                Decimal TtlQty = 0;
                sb.Append("<table><tr><th>Sale Id</th><th>ItemId</th><th>DispatchQty</th><th>Unit Price</th><th>Sub Total</th><th>Tax</th><th>Discount</th><th>Total</th></tr>");
                foreach (ItemData item in BindList)
                {
                    if (item.ItemID > 0 && item.TotalQty > 0)
                    {
                        POS1 objPOS1 = objOPOS.POS1.FirstOrDefault(x => x.ItemID == item.ItemID && x.AddOn == item.AddOn && x.SchemeID == item.SchemeID);
                        if (objPOS1 == null)
                        {
                            objPOS1 = new POS1();
                            objPOS1.POS1ID = Count++;
                            objPOS1.ItemID = item.ItemID;
                            objOPOS.POS1.Add(objPOS1);
                        }
                        if (item.UnitID == 0)
                            objPOS1.UnitID = 1;
                        else
                            objPOS1.UnitID = item.UnitID;

                        objPOS1.IsDeleted = false;
                        objPOS1.UnitPrice = item.UnitPrice;
                        objPOS1.MRP = item.MRP;
                        objPOS1.NormalPrice = item.NormalPrice;
                        objPOS1.TaxID = item.TaxID;
                        objPOS1.PriceTax = item.PriceTax;
                        objPOS1.Price = item.Price;
                        objPOS1.MapQty = item.MapQty;
                        objPOS1.Quantity = item.OrderQuantity;
                        objPOS1.DispatchQty = item.Quantity;
                        objPOS1.MainID = item.MainID;
                        objPOS1.TotalQty = item.Quantity;
                        TtlQty += item.Quantity;
                        objPOS1.SubTotal = item.SubTotal;
                        objPOS1.Tax = item.Tax;
                        objPOS1.Total = item.Total;
                        objPOS1.SchemeID = item.SchemeID;
                        objPOS1.AddOn = item.AddOn;
                        objPOS1.ItemScheme = item.ItemScheme;
                        objPOS1.Scheme = item.Scheme;
                        objPOS1.Discount = item.Discount;
                        objOPOS.POS1.Add(objPOS1);


                        sb.Append("<tr><td>" + objOPOS.SaleID + "</td><td>" + item.ItemCode + "</td><td>" + item.Quantity + "</td><td>" + item.UnitPrice + "</td><td>" + item.SubTotal + "</td><td>" + item.Tax + "</td><td>" + item.Discount + "</td><td>" + item.Total + "</td></tr>");


                        if (ctx.OCRDs.Any(x => x.CustomerID == ParentID && x.Type == 2))
                        {
                            int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == item.ItemID).DivisionlID.Value;
                            int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == objOCRD.CustomerID && x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                            if (ctx.ORCLMs.Any(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == DivisionlID && x.PriceListID == PriceID && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
                            {
                                objOPOS.RateClaimID = ctx.ORCLMs.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.DivisionID == DivisionlID && x.PriceListID == PriceID && EntityFunctions.TruncateTime(DateTime.Now) >= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(DateTime.Now) <= EntityFunctions.TruncateTime(x.ToDate)).RateClaimID;
                            }
                        }

                        if (objPOS1.DispatchQty > 0)
                        {
                            ITM2 ITM2 = ctx.ITM2.FirstOrDefault(x => x.ParentID == ParentID && x.WhsID == WhsID && x.ItemID == objPOS1.ItemID);
                            if (ITM2 == null)
                            {
                                ITM2 = new ITM2();
                                ITM2.StockID = CountM++;
                                ITM2.ParentID = ParentID;
                                ITM2.WhsID = WhsID;
                                ITM2.ItemID = objPOS1.ItemID;
                                ctx.ITM2.Add(ITM2);
                            }

                            ITM2.TotalPacket -= objPOS1.TotalQty;
                            objPOS1.PPrice = ITM2.PPrice;

                            if (ITM2.TotalPacket < 0)
                            {
                                return "ERROR=Insufficient Stock, So You Can Not Dispatch This Product: " + item.ItemCode;
                            }
                        }
                    }
                }

                if (objOPOS.Date.Date != DateTime.Now.Date)
                {
                    return "ERROR=DayClose is missing, please refresh page or do dayclose";
                }

                if (objOPOS.Total <= 0)
                {
                    return "ERROR=You can not create Invoice with Zero or Negative Amount";
                }
                if (ctx.OPOS.Any(x => x.ParentID == ParentID && x.CustomerID == objOPOS.CustomerID.Value && x.SubTotal == objOPOS.SubTotal && x.Tax == objOPOS.Tax
                    && x.Date.Year == objOPOS.Date.Year && x.Date.Month == objOPOS.Date.Month && x.Date.Day == objOPOS.Date.Day && SqlFunctions.DateDiff("minute", x.Date, objOPOS.Date) <= 60))
                {
                    return "ERROR=You can not create same dealer bill with same amount in a hour, so please try after one hour.";
                }
                var TDiff = Math.Round(objOPOS.SubTotal, 0) - Math.Round(objOPOS.POS1.Where(x => x.IsDeleted == false).Sum(x => x.SubTotal), 0);
                if (TDiff > 2 || TDiff < -2)
                {
                    return "ERROR=Message Code ER0015, please refresh page and try again";
                }
                ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                int HdocID = ctx.AddHierarchyType_NEW("S", objOPOS.CustomerID, ParentID, objOPOS.SaleID, str).FirstOrDefault().GetValueOrDefault(0);
                if (str.Value.ToString() == "0" || HdocID == 0)
                {
                    return "ERROR=Beat not available for " + objOCRD.CustomerCode + " # " + objOCRD.CustomerName + ", so you can not create Sales Invoice. Contact to your Local  Sales Staff!";
                }
                objOPOS.HDocID = HdocID;

                Int32 DealerHRY = ctx.AddHierarchyType_Check(objOPOS.CustomerID, ParentID).Select(x => x.DealerHRY).DefaultIfEmpty(0).FirstOrDefault();
                if (DealerHRY == 0)
                {
                    HRY1 objHRY1 = new HRY1();
                    objHRY1.HRY1ID = ctx.GetKey("HRY1", "HRY1ID", "", ParentID, 0).FirstOrDefault().Value;
                    objHRY1.EmpID = UserID;
                    objHRY1.ParentID = ParentID;
                    objHRY1.SaleID = objOPOS.SaleID;
                    objHRY1.CustomerID = objOCRD.CustomerID;
                    objHRY1.Qty = TtlQty;
                    objHRY1.SubTotal = objOPOS.SubTotal;
                    objHRY1.CreatedDate = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                    objHRY1.CreatedBy = UserID;
                    ctx.HRY1.Add(objHRY1);
                }

                #region Item wise Discount Calculate insert

                foreach (ItemWiseDiscountData itemDisc in ObjItemDisc)
                {
                    OIDM objOIDM = new OIDM();
                    objOIDM.ItemId = itemDisc.ItemID;
                    objOIDM.ParentId = ParentID;
                    objOIDM.SchemeMode = itemDisc.Mode;
                    objOIDM.SchemeId = itemDisc.SchemeID;
                    objOIDM.Qty = Convert.ToInt32(itemDisc.Quantity);
                    objOIDM.CompanyContri = itemDisc.CompanyContri;
                    objOIDM.DistributorContri = itemDisc.DistributorContri;
                    objOIDM.TotalDiscount = itemDisc.Discount;
                    objOIDM.InvoiceDate = DateTime.Now;
                    objOPOS.OIDMs.Add(objOIDM);
                }
                #endregion

                #region Add Ice-Cream and Dairy division pricelist in invoice

                if (ctx.OGCRDs.Any(x => x.CustomerID == objOPOS.CustomerID && x.PriceListID.HasValue))
                {
                    var IPriceID = ctx.OGCRDs.Where(x => x.CustomerID == objOPOS.CustomerID && x.DivisionlID == 3 && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                    var DPriceID = ctx.OGCRDs.Where(x => x.CustomerID == objOPOS.CustomerID && x.DivisionlID == 5 && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                    objOPOS.IcePriceListName = ctx.OIPLs.Any(x => x.PriceListID == IPriceID) ? ctx.OIPLs.FirstOrDefault(x => x.PriceListID == IPriceID).Name : "";
                    objOPOS.DairyPriceListName = ctx.OIPLs.Any(x => x.PriceListID == DPriceID) ? ctx.OIPLs.FirstOrDefault(x => x.PriceListID == DPriceID).Name : "";
                }

                #endregion

                ctx.SaveChanges();
                ObjItemDisc = new List<ItemWiseDiscountData>();
                if (!string.IsNullOrEmpty(objOCRD.Phone) && objOPOS.POS3.ToList().Count() > 0)
                {
                    var CityID = objOCRD.CRD1.FirstOrDefault().CityID;

                    string Message = "Dear+Customer+Inv.No+" + objOPOS.InvoiceNumber + "+Dt.+" + Common.DateTimeConvert(objOPOS.Date) + "+at+" + objOPOS.Date.ToString("hh:mm tt")
                        + "+Qty+:+" + objOPOS.POS1.Where(x => x.IsDeleted == false).Sum(x => x.TotalQty).ToString("0") + "+Rs.+" + objOPOS.Total.ToString("0.00") + "+generated+for+"
                        + objOPOS.OCRD.CustomerCode + ",+" + objOPOS.OCRD.CustomerName + ",+" + ctx.OCTies.FirstOrDefault(x => x.CityID == CityID).CityName + Environment.NewLine + "Regards," + Environment.NewLine + "Vadilal Enterprises Ltd.";
                    Service wb = new Service();
                    wb.SendSMS(objOCRD.Phone, Message);

                }
                if (!string.IsNullOrEmpty(objOCRD.Phone))//FOR WhatsAPP.
                {

                    if (objOCRD.Phone.Length == 10)
                    {
                        string FilePath = HostingEnvironment.MapPath("~/Document/WhatsAppAPI/SalesInv/");
                        try
                        {
                            bool RestrictStatus = false;
                            var restrictionObj = ctx.GetWhatsAppRestriction(objOCRD.ParentID).FirstOrDefault();
                            if (restrictionObj != null)
                                RestrictStatus = (restrictionObj.HasValue && restrictionObj.Value == 1) ? true : false;
                            if (!RestrictStatus)
                            {
                                Thread t = new Thread(() =>
                                {
                                    SendSaleDocInWhatsAPP(objOCRD.Phone, Convert.ToString(objOPOS.SaleID), ParentID, UserID, objOCRD.CustomerCode + " # " + objOCRD.CustomerName, objOPOS.InvoiceNumber);
                                });
                                t.Name = Guid.NewGuid().ToString();
                                t.Start();
                            }
                        }
                        catch (Exception ex)
                        {
                            var LogFile = HttpContext.Current.Server.MapPath("~/Document/WhatsAppApiLog/") + objOPOS.SaleID.ToString() + "-" + objOPOS.ParentID.ToString() + ".txt";
                            Common.TraceService(LogFile, Common.GetString(ex));
                        }
                    }
                }

                if (objORDR != null)
                {
                    var EmpData = ctx.OEMPs.Where(x => x.EmpID == objORDR.CreatedBy && x.ParentID == 1000010000000000).Select(x => new { x.EmpCode, x.Name }).FirstOrDefault();

                    string body = "Sales Invoice # " + objOPOS.InvoiceNumber + "created from DMS for Order # " + objORDR.InvoiceNumber + " on " + Common.DateTimeConvert(objOPOS.Date) + " for "
                        + objOCRD.CustomerCode + " # " + objOCRD.CustomerName + " for an amount of Rs. " + objOPOS.Total.ToString("0.00") + " with total quantity of " + objOPOS.POS1.Where(x => x.IsDeleted == false).Sum(x => x.TotalQty).ToString("0") + " of Sales Person " + EmpData.EmpCode + " # " + EmpData.Name;
                    string title = "Sales Invoice # " + objOPOS.InvoiceNumber;

                    Thread t = new Thread(() => { Service.SendNotificationFlow(9104, objORDR.CreatedBy, 1000010000000000, body, title, 0); });
                    t.Name = Guid.NewGuid().ToString();
                    t.Start();
                }

                if (objOPOS.CustomerID == 3000400017100001)
                {
                    Common.SendMail("Invoice Amount Mismatch", sb.ToString(), "vimal.lakum@vc-erp.com", "jigneshkhajanchi@vadilalgroup.com", null, null);
                }

                //FSSI number checking T900011635 - FSSI Number Maintain and Printing 
                string FSSIMsg = "";

                if (!ctx.OFSSIs.Any(x => x.FSSIForID == objOPOS.ParentID && !x.IsDeleted && x.IsVerify == true))
                {
                    FSSIMsg += Environment.NewLine + "FSSAI Number Not Available";
                }
                //var objOVCL = ctx.OVCLs.FirstOrDefault(x => x.VehicleID == vehicleID && x.ParentID == VehicleParentID && x.Active);

                //if (objOVCL != null && !ctx.OFSSIs.Any(x => x.VehicleNumber == objOVCL.VehicleNumber && !x.IsDeleted) && vehicleID > 0)
                //{
                //    FSSIMsg += Environment.NewLine + "Vehicle FSSAI Number Not Available";
                //}

                if (ctx.OFSSIs.Any(x => x.FSSIForID == objOPOS.ParentID && !x.IsDeleted && x.IsVerify == true))
                {
                    var objOFSSI = ctx.OFSSIs.Where(x => x.FSSIForID == objOPOS.ParentID && !x.IsDeleted && x.IsVerify == true).OrderByDescending(x => x.EndDate).FirstOrDefault();

                    if (objOFSSI != null)
                    {
                        if ((objOFSSI.EndDate.Date - DateTime.Now.Date).TotalDays > -1 && (objOFSSI.EndDate.Date - DateTime.Now.Date).TotalDays <= 60)
                        {
                            FSSIMsg += Environment.NewLine + "Your FSSAI Number's End Date is " + objOFSSI.EndDate.ToString("dd/MM/yy");
                        }

                        if (objOFSSI.EndDate.Date < DateTime.Now.Date)
                        {
                            FSSIMsg += Environment.NewLine + "FSSAI Number Not Available";
                        }
                    }
                    else
                    {
                        FSSIMsg += Environment.NewLine + "FSSAI Number Not Available";
                    }
                }

                //var OVCLParentID = CustType == 4 ? ParentID : VehicleParentID;

                //if (objOVCL != null && ctx.OFSSIs.Any(x => x.VehicleNumber == objOVCL.VehicleNumber && x.VehicleParentID == OVCLParentID && !x.IsDeleted) && vehicleID > 0)
                //{
                //    var objOFSSIV = ctx.OFSSIs.Where(x => x.VehicleNumber == objOVCL.VehicleNumber && x.VehicleParentID == OVCLParentID && !x.IsDeleted).OrderByDescending(x => x.EndDate).FirstOrDefault();

                //    if (objOFSSIV != null)
                //    {
                //        if ((objOFSSIV.EndDate.Date - DateTime.Now.Date).TotalDays > -1 && (objOFSSIV.EndDate.Date - DateTime.Now.Date).TotalDays <= 30)
                //        {
                //            FSSIMsg += Environment.NewLine + "Selected Vehicle's FSSAI Number's End Date is " + objOFSSIV.EndDate.ToString("dd/MM/yy");
                //        }

                //        if (objOFSSIV.EndDate.Date < DateTime.Now.Date)
                //        {
                //            FSSIMsg += Environment.NewLine + "Vehicle FSSAI Number Not Available";
                //        }
                //    }
                //    else
                //    {
                //        FSSIMsg += Environment.NewLine + "Vehicle FSSAI Number Not Available";
                //    }
                //}
                // 16-Nov-22 Vimal E-Invoice
                //try
                //{
                //    Dictionary<int, string> Data = new Dictionary<int, string>();
                //    if (ctx.OGSTs.Any(x => x.CustomerId == ParentID && x.GSTRequired == true))
                //    {
                //        Data = ReadData_Actual(ParentID, objOPOS.SaleID);
                //        if (Data.FirstOrDefault().Key == 1)
                //        {
                //            return "SUCCESS=E-Invoice Inserted Successfully: InvoiceID # " + objOPOS.SaleID.ToString() + "# .=" + FSSIMsg;
                //        }
                //    }
                //}
                //catch (Exception ex)
                //{
                //    return "ERROR=E-Invoice is worng Please Resend it : " + Common.GetString(ex);
                //}
                return "SUCCESS=Invoice Inserted Successfully: InvoiceID # " + objOPOS.SaleID.ToString() + "# .=" + FSSIMsg;
            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }
    public static void SendSaleDocInWhatsAPP(string CustPhoneNumber, string SaleID, decimal ParentID, int UserID, string CustomerName, string InvNumer)
    {
        ReportDocument myReport = new ReportDocument();
        ConnectionInfo myConnectionInfo = new ConnectionInfo();
        try
        {
            myReport.Load(HostingEnvironment.MapPath("~/Reports/CrystalReports/SalesInvoice_A4.rpt"));
            myReport.SetParameterValue("@SaleID", SaleID);
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
            string FileName = DateTime.Now.ToString("ddMMyyyyhhmmss") + "_" + InvNumer + ".pdf";
            string FilePath = HostingEnvironment.MapPath("~/Document/WhatsAppAPI/SalesInv/") + FileName;

            myReport.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, FilePath);
            Service wb = new Service();
            int TemplateID = Convert.ToInt32(ConfigurationManager.AppSettings["WhatsAppSalesTempID"]);

            wb.SendWhatsApp(CustPhoneNumber, "Document/WhatsAppAPI/SalesInv/" + FileName, "Invoice Detail", FileName, TemplateID, CustomerName);
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
    //private static List<SchemeData> LoadScheme(string Mode, OCRD Cust, List<ItemData> BindList, Decimal MinusAmt = 0, Boolean MasterApplied = false, Boolean IsTempCust = false)
    //{
    //    var day = DateTime.Now.DayOfWeek.ToString();
    //    using (DDMSEntities ctx = new DDMSEntities())
    //    {
    //        List<SchemeData> ScemeList = new List<SchemeData>();

    //        var OrderOtem = BindList.Where(x => x.MainID == 0).ToList();

    //        if (OrderOtem.Count > 0)
    //        {
    //            var dt = DateTime.Now.Date;
    //            var tm = DateTime.Now.TimeOfDay;
    //            List<OSCM> objOSCMs = new List<OSCM>();

    //            if (Mode == "M")
    //            {
    //                objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
    //                            where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                           (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                           (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                           (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                           (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == Cust.Type && y.Active)) &&
    //                           c.ApplicableOn == Cust.Type && c.ApplicableMode == "M" &&
    //                            c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                            select c).OrderBy(x => x.SchemeID).Take(1).ToList();
    //            }
    //            else if (Mode == "DP")
    //            {
    //                OSCM MSC = (from c in ctx.OSCMs.Include("SCM4")
    //                            where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                           (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                           (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                           (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                           (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active
    //                              && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
    //                           c.ApplicableOn == Cust.Type && c.ApplicableMode == "D" &&
    //                            c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                            select c).OrderBy(x => x.SchemeID).FirstOrDefault();
    //                if (MSC != null)
    //                    objOSCMs.Add(MSC);

    //                MSC = (from c in ctx.OSCMs.Include("SCM4")
    //                       where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                      (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                      (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                      (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                      (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active
    //                          && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
    //                      c.ApplicableOn == Cust.Type && c.ApplicableMode == "P" &&
    //                       c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                       select c).OrderBy(x => x.SchemeID).FirstOrDefault();

    //                if (MSC != null)
    //                    objOSCMs.Add(MSC);
    //            }
    //            else if (Mode == "V")
    //            {
    //                OSCM MSC = (from c in ctx.OSCMs.Include("SCM4")
    //                            where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                           (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                           (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                           (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                           (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active
    //                               && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
    //                           c.ApplicableOn == Cust.Type && c.ApplicableMode == "V" &&
    //                            c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                            select c).OrderBy(x => x.SchemeID).FirstOrDefault();

    //                if (MSC != null)
    //                    objOSCMs.Add(MSC);
    //            }
    //            else if (Mode == "S")
    //            {
    //                int intMasterApplied = Convert.ToInt32(MasterApplied);
    //                if (IsTempCust)//FOR TEMP
    //                {
    //                    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
    //                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.ForTemp == true && c.Active
    //                               && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                                select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
    //                }
    //                else if (Cust.CustGroupID == 14)//FOR FOW
    //                {
    //                    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
    //                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.ForFOW == true && c.Active
    //                               && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                                select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
    //                }
    //                else//FOR COMPANY DIST.
    //                {
    //                    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
    //                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.SchemeCondition != 3 &&
    //                               (c.SchemeCondition == 2 || c.SchemeCondition == intMasterApplied) && c.Active
    //                               && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                                select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
    //                }
    //            }
    //            else if (Mode == "A")
    //            {
    //                objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
    //                            where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
    //                           (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
    //                           (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
    //                           (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
    //                           (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 2 && y.Active)) && c.ApplicableMode == "A" &&
    //                            c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
    //                            select c).OrderBy(x => x.SchemeID).Take(1).ToList();
    //            }

    //            Decimal DecNum;
    //            Decimal SaleValue = 0;

    //            foreach (OSCM objScheme in objOSCMs)
    //            {
    //                foreach (SCM4 objSCM4 in objScheme.SCM4)
    //                {
    //                    DecNum = 0;
    //                    SaleValue = 0;
    //                    if (objSCM4.BasedOn == (int)BasedOn.Invoice)
    //                    {
    //                        OrderOtem.Where(x => ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => DecNum += x.SubTotal);
    //                        DecNum = DecNum - MinusAmt;
    //                        SaleValue = DecNum;
    //                        decimal qty = 0;
    //                        if (DecNum > 0 && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= DecNum) && (objSCM4.HigherLimit >= DecNum || objSCM4.HigherLimit == 0))
    //                        {
    //                            if (objSCM4.Occurrence.HasValue && objSCM4.Occurrence.Value > 0)
    //                            {
    //                                qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            }
    //                            else
    //                            {
    //                                qty = objSCM4.Quantity;
    //                            }
    //                            var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
    //                            if (QPSEligibility.EligibleCount > 0)
    //                            {

    //                                if (qty > 0)
    //                                {
    //                                    var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
    //                                    if (QPSEligibility.OptionType == 1)
    //                                    {
    //                                        var TotalQty = objSCM4.IsPair.ToString().ToLower() == "true" ? (qty * 2) + TotalUsedCount : qty + TotalUsedCount;
    //                                        if (TotalQty > 0)
    //                                        {
    //                                            if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
    //                                                if (TotalQty <= QPSEligibility.EligibleCount)
    //                                                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
    //                                                {
    //                                                    if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                    {
    //                                                        if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) > (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                            ScemeList.Add(AddItem(objSCM4, Convert.ToInt16((objSCM4.IsPair.ToString().ToLower() == "true" ? QPSEligibility.EligibleCount - TotalUsedCount * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                        else if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) < QPSEligibility.EligibleCount)
    //                                                            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                        else
    //                                                        {
    //                                                            ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                        }

    //                                                        //if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity))
    //                                                        //if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                        //    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    }
    //                                                    else
    //                                                        ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount))), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                }
    //                                        }
    //                                    }
    //                                    else if (QPSEligibility.OptionType == 2)
    //                                    {

    //                                        if (TotalUsedCount < QPSEligibility.EligibleCount)
    //                                            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                    }
    //                                }
    //                            }
    //                            //}
    //                            //else
    //                            //{

    //                            //}
    //                            ////var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            ////if (qty > 0)
    //                            ////    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //var EligibleQty = ctx.GetEligibleQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //var TotalUsedQty = ctx.GetTotalUsedQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            ////var qty = Math.Ceiling((DecNum - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
    //                            //var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            //var TotalQty = qty + TotalUsedQty;
    //                            //if (EligibleQty == 0)
    //                            //{
    //                            //    var EligInv = ctx.CheckSCM1(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //    var TotalInv = ctx.GetTotalInvoiceByCustomerSchemeId(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //    if (EligInv > 0)
    //                            //    {
    //                            //        if (TotalInv <= EligInv)
    //                            //            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //    }
    //                            //}
    //                            //else
    //                            //{
    //                            //    if (TotalQty > 0)
    //                            //    {
    //                            //        if ((EligibleQty - TotalUsedQty) != 0)
    //                            //            if (TotalQty <= EligibleQty)
    //                            //                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //            else if ((EligibleQty - TotalUsedQty) > 0)
    //                            //            {
    //                            //                if (qty < objSCM4.Quantity * (EligibleQty - TotalUsedQty))
    //                            //                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //                else
    //                            //                    ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity * (EligibleQty - TotalUsedQty), BindList, Cust, SaleValue));
    //                            //                }
    //                            //        //else
    //                            //        //    return ScemeList;
    //                            //    }
    //                            //}

    //                        }
    //                        //else
    //                        //    ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity, BindList, Cust, DecNum, "NULL"));
    //                        //}
    //                    }
    //                    else if (objSCM4.BasedOn == (int)BasedOn.Item)
    //                    {
    //                        OrderOtem.Where(x => ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => { DecNum += x.Quantity; SaleValue += x.SubTotal; });
    //                        if (DecNum > 0 && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= DecNum) && (objSCM4.HigherLimit >= DecNum || objSCM4.HigherLimit == 0))
    //                        {
    //                            decimal qty = 0;
    //                            if (objSCM4.Occurrence.HasValue && objSCM4.Occurrence.Value > 0)
    //                            {
    //                                qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            }
    //                            else
    //                            {
    //                                qty = objSCM4.Quantity;
    //                            }
    //                            var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
    //                            if (QPSEligibility.EligibleCount > 0)
    //                            {

    //                                var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
    //                                if (QPSEligibility.OptionType == 1)
    //                                {
    //                                    var TotalQty = objSCM4.IsPair.ToString().ToLower() == "true" ? qty * 2 : qty + TotalUsedCount;
    //                                    if (TotalQty > 0)
    //                                    {
    //                                        if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
    //                                            if (TotalQty <= QPSEligibility.EligibleCount)
    //                                                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                            else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
    //                                            {

    //                                                if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                {
    //                                                    if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) > (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                        ScemeList.Add(AddItem(objSCM4, Convert.ToInt16((objSCM4.IsPair.ToString().ToLower() == "true" ? QPSEligibility.EligibleCount - TotalUsedCount * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    else if (qty < QPSEligibility.EligibleCount)
    //                                                        ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    else
    //                                                    {
    //                                                        ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    }
    //                                                    // ScemeList.Add(AddItem(objSCM4, Convert.ToInt16(objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString()));
    //                                                }
    //                                                else
    //                                                    ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                            }




    //                                    }
    //                                }
    //                                else if (QPSEligibility.OptionType == 2)
    //                                {

    //                                    if (TotalUsedCount < QPSEligibility.EligibleCount)
    //                                        ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                }
    //                            }

    //                            ////var qty = Math.Ceiling((DecNum - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
    //                            //var EligibleQty = ctx.GetEligibleQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //var TotalUsedQty = ctx.GetTotalUsedQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            ////var qty = Math.Ceiling((DecNum - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
    //                            //var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            //var TotalQty = qty + TotalUsedQty;
    //                            //if (EligibleQty == 0)
    //                            //{
    //                            //    var EligInv = ctx.CheckSCM1(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //    var TotalInv = ctx.GetTotalInvoiceByCustomerSchemeId(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                            //    if (EligInv > 0)
    //                            //    {
    //                            //        if (TotalInv <= EligInv)
    //                            //            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //    }
    //                            //}
    //                            //else
    //                            //{
    //                            //    if (TotalQty > 0)
    //                            //    {
    //                            //        if ((EligibleQty - TotalUsedQty) != 0)
    //                            //            if (TotalQty <= EligibleQty)
    //                            //                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //            else if ((EligibleQty - TotalUsedQty) > 0)
    //                            //            {
    //                            //                if (qty < objSCM4.Quantity * (EligibleQty - TotalUsedQty))
    //                            //                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //                else
    //                            //                    ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity * (EligibleQty - TotalUsedQty), BindList, Cust, SaleValue));
    //                            //            }

    //                            //        //else
    //                            //        //    return ScemeList;
    //                            //    }
    //                            //}
    //                            //var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                            //if (qty > 0)
    //                            //    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
    //                            //}
    //                            //else
    //                            // ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity, BindList, Cust, SaleValue, "NULL"));
    //                        }
    //                    }
    //                    else if (objSCM4.BasedOn == (int)BasedOn.Unit)
    //                    {
    //                        foreach (ItemData item in OrderOtem)
    //                        {
    //                            if (item.Quantity > 0 && (ctx.CheckSCM3(item.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1) && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= item.Quantity) && (objSCM4.HigherLimit >= item.Quantity || objSCM4.HigherLimit == 0))
    //                            {
    //                                DecNum = 0;
    //                                SaleValue = item.SubTotal;
    //                                // var EligibleQty = ctx.GetEligibleQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                                //   var TotalUsedQty = ctx.GetTotalUsedQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                                //var qty = Math.Ceiling((item.Quantity - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
    //                                var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
    //                                var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
    //                                var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
    //                                var TotalQty = qty + TotalUsedCount;

    //                                if (qty > 0)
    //                                {
    //                                    if (objSCM4.ItemID.HasValue)
    //                                        DecNum = qty * objSCM4.Quantity;
    //                                    else
    //                                        DecNum = qty;

    //                                    TotalQty = DecNum;

    //                                    if (QPSEligibility.EligibleCount > 0)
    //                                    {


    //                                        if (QPSEligibility.OptionType == 1)
    //                                        {
    //                                            // var TotalQty = qty + TotalUsedCount;
    //                                            if (TotalQty > 0)
    //                                            {
    //                                                if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
    //                                                    if (TotalQty <= QPSEligibility.EligibleCount)
    //                                                        ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
    //                                                    {
    //                                                        if (qty < objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount))
    //                                                            ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                                    }
    //                                            }
    //                                        }
    //                                        else if (QPSEligibility.OptionType == 2)
    //                                        {

    //                                            if (TotalUsedCount < QPSEligibility.EligibleCount)
    //                                                ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                            else
    //                                                ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal(objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
    //                                        }
    //                                    }
    //                                    //if (EligibleQty == 0)
    //                                    //{
    //                                    //    var EligInv = ctx.CheckSCM1(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                                    //    var TotalInv = ctx.GetTotalInvoiceByCustomerSchemeId(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
    //                                    //    if (EligInv > 0)
    //                                    //    {
    //                                    //        if (TotalInv <= EligInv)
    //                                    //            ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue));
    //                                    //    }
    //                                    //}
    //                                    //else
    //                                    //{
    //                                    //    if (TotalQty > 0)
    //                                    //    {
    //                                    //        if ((EligibleQty - TotalUsedQty) != 0)
    //                                    //            if (TotalQty <= EligibleQty)
    //                                    //                ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue));
    //                                    //            else if ((EligibleQty - TotalUsedQty) > 0)
    //                                    //            {
    //                                    //                if (qty < objSCM4.Quantity * (EligibleQty - TotalUsedQty))
    //                                    //                    ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue));
    //                                    //                else
    //                                    //                    ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity * (EligibleQty - TotalUsedQty), BindList, Cust, SaleValue));
    //                                    //            }

    //                                    //        //else
    //                                    //        //    return ScemeList;
    //                                    //    }
    //                                    //}
    //                                    // ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue));
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        return ScemeList;
    //    }
    //}
    private static List<SchemeData> LoadScheme(string Mode, OCRD Cust, List<ItemData> BindList, Decimal MinusAmt = 0, Boolean MasterApplied = false, Boolean IsTempCust = false)
    {
        var day = DateTime.Now.DayOfWeek.ToString();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<SchemeData> ScemeList = new List<SchemeData>();

            var OrderOtem = BindList.Where(x => x.MainID == 0).ToList();

            if (OrderOtem.Count > 0)
            {
                var dt = DateTime.Now.Date;
                var tm = DateTime.Now.TimeOfDay;
                List<OSCM> objOSCMs = new List<OSCM>();

                if (Mode == "M")
                {
                    //if (System.DateTime.Now >= Convert.ToDateTime("01-01-2023"))
                    //{
                    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                               (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == Cust.Type && y.Active)) &&
                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "M" &&
                                c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                select c).OrderBy(x => x.SchemeID).Take(1).ToList();

                    //objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                    //            where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                    //           (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                    //           (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                    //           (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                    //           (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.ParentCode == Cust.ParentID && y.Type == Cust.Type && y.Active)) &&
                    //           c.ApplicableOn == Cust.Type && c.ApplicableMode == "M" &&
                    //            c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                    //            select c).OrderBy(x => x.SchemeID).Take(1).ToList();
                    //}
                    //else
                    //{
                    //    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                    //                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                    //               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                    //               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                    //               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                    //               (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == Cust.Type && y.Active)) &&
                    //               c.ApplicableOn == Cust.Type && c.ApplicableMode == "M" &&
                    //                c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                    //                select c).OrderBy(x => x.SchemeID).Take(1).ToList();
                    //}
                }
                else if (Mode == "DP")
                {
                    OSCM MSC = (from c in ctx.OSCMs.Include("SCM4")
                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                               (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active && y.IsInclude
                                  && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "D" &&
                                c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                select c).OrderBy(x => x.SchemeID).FirstOrDefault();
                    if (MSC != null)
                        objOSCMs.Add(MSC);

                    MSC = (from c in ctx.OSCMs.Include("SCM4")
                           where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                          (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                          (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                          (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                          (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active && y.IsInclude
                              && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
                          c.ApplicableOn == Cust.Type && c.ApplicableMode == "P" &&
                           c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                           select c).OrderBy(x => x.SchemeID).FirstOrDefault();

                    if (MSC != null)
                        objOSCMs.Add(MSC);
                }
                else if (Mode == "V")
                {
                    OSCM MSC = (from c in ctx.OSCMs.Include("SCM4")
                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                               (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 3 && y.Active
                                   && y.UsedCoupon.HasValue && y.CouponAmount.HasValue && (y.CouponAmount.Value - y.UsedCoupon.Value) > 0)) &&
                               c.ApplicableOn == Cust.Type && c.ApplicableMode == "V" &&
                                c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                select c).OrderBy(x => x.SchemeID).FirstOrDefault();

                    if (MSC != null)
                        objOSCMs.Add(MSC);
                }
                else if (Mode == "S")
                {
                    int intMasterApplied = Convert.ToInt32(MasterApplied);
                    if (IsTempCust)//FOR TEMP
                    {
                        objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                                    where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                                   (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                                   (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                                   (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                                   c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.ForTemp == true && c.Active
                                   && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                    select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1New(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
                    }
                    else if (Cust.CustGroupID == 14)//FOR FOW
                    {
                        objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                                    where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                                   (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                                   (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                                   (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                                   c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.ForFOW == true && c.Active
                                   && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                    select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1New(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
                    }
                    else//FOR COMPANY DIST.
                    {
                        objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                                    where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                                   (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                                   (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                                   (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                                   c.ApplicableOn == Cust.Type && c.ApplicableMode == "S" && c.SchemeCondition != 3 &&
                                   (c.SchemeCondition == 2 || c.SchemeCondition == intMasterApplied) && c.Active
                                   && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                    select c).OrderBy(x => x.SchemeID).ToList().Where(x => (ctx.CheckSCM1New(Cust.CustomerID, x.SchemeID).FirstOrDefault().Value == 1)).OrderBy(x => x.SchemeID).ToList();
                    }
                }
                else if (Mode == "A")
                {
                    objOSCMs = (from c in ctx.OSCMs.Include("SCM4")
                                where (!c.StartDate.HasValue || DateTime.Compare(c.StartDate.Value, dt) <= 0) &&
                               (!c.StartTime.HasValue || c.StartTime.Value <= tm) &&
                               (!c.EndDate.HasValue || DateTime.Compare(c.EndDate.Value, dt) >= 0) &&
                               (!c.EndTime.HasValue || c.EndTime.Value >= tm) &&
                               (c.SCM1.Any(y => y.CustomerID == Cust.CustomerID && y.Type == 2 && y.Active)) && c.ApplicableMode == "A" &&
                                c.Active && (day == "Monday" ? c.Monday : day == "Tuesday" ? c.Tuesday : day == "Wednesday" ? c.Wednesday : day == "Thursday" ? c.Thursday : day == "Friday" ? c.Friday : day == "Saturday" ? c.Saturday : day == "Sunday" ? c.Sunday : false)
                                select c).OrderBy(x => x.SchemeID).Take(1).ToList();
                }

                Decimal DecNum;
                Decimal SaleValue = 0;
                foreach (OSCM objScheme in objOSCMs)
                {
                    foreach (SCM4 objSCM4 in objScheme.SCM4)
                    {
                        DecNum = 0;
                        SaleValue = 0;
                        if (objSCM4.BasedOn == (int)BasedOn.Invoice)
                        {
                            OrderOtem.Where(x => ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => DecNum += x.SubTotal);
                            DecNum = DecNum - MinusAmt;
                            SaleValue = DecNum;
                            decimal qty = 0;
                            if (DecNum > 0 && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= DecNum) && (objSCM4.HigherLimit >= DecNum || objSCM4.HigherLimit == 0))
                            {
                                #region QPS Valiadtion

                                if (objSCM4.Occurrence.HasValue && objSCM4.Occurrence.Value > 0)
                                {
                                    qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
                                }
                                else
                                {
                                    qty = objSCM4.Quantity;
                                }
                                if (Mode == "S")
                                {
                                    var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
                                    if (QPSEligibility.EligibleCount > 0)
                                    {

                                        if (qty > 0)
                                        {
                                            var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
                                            if (QPSEligibility.OptionType == 1)
                                            {
                                                var TotalQty = objSCM4.IsPair.ToString().ToLower() == "true" ? (qty * 2) + TotalUsedCount : qty + TotalUsedCount;
                                                if (TotalQty > 0)
                                                {
                                                    if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
                                                        if (TotalQty <= QPSEligibility.EligibleCount)
                                                            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                        else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
                                                        {
                                                            if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
                                                            {
                                                                if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) > (QPSEligibility.EligibleCount - TotalUsedCount))
                                                                    ScemeList.Add(AddItem(objSCM4, Convert.ToInt16((objSCM4.IsPair.ToString().ToLower() == "true" ? QPSEligibility.EligibleCount - TotalUsedCount * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                                else if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) < QPSEligibility.EligibleCount)
                                                                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                                else
                                                                {
                                                                    ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                                }

                                                                //if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity))
                                                                //if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
                                                                //    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString()));
                                                            }
                                                            else
                                                                ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount))), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                        }
                                                }
                                            }
                                            else if (QPSEligibility.OptionType == 2)
                                            {

                                                if (TotalUsedCount < QPSEligibility.EligibleCount)
                                                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                            }
                                        }
                                    }
                                }
                                else
                                {

                                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, "", DecNum.ToString(), objScheme.ApplicableMode));
                                }


                                //}
                                //else
                                //{

                                //}
                                ////var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
                                ////if (qty > 0)
                                ////    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
                                //var EligibleQty = ctx.GetEligibleQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
                                //var TotalUsedQty = ctx.GetTotalUsedQty(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
                                ////var qty = Math.Ceiling((DecNum - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
                                //var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
                                //var TotalQty = qty + TotalUsedQty;
                                //if (EligibleQty == 0)
                                //{
                                //    var EligInv = ctx.CheckSCM1(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
                                //    var TotalInv = ctx.GetTotalInvoiceByCustomerSchemeId(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault().Value;
                                //    if (EligInv > 0)
                                //    {
                                //        if (TotalInv <= EligInv)
                                //            ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
                                //    }
                                //}
                                //else
                                //{
                                //    if (TotalQty > 0)
                                //    {
                                //        if ((EligibleQty - TotalUsedQty) != 0)
                                //            if (TotalQty <= EligibleQty)
                                //                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
                                //            else if ((EligibleQty - TotalUsedQty) > 0)
                                //            {
                                //                if (qty < objSCM4.Quantity * (EligibleQty - TotalUsedQty))
                                //                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue));
                                //                else
                                //                    ScemeList.Add(AddItem(objSCM4, objSCM4.Quantity * (EligibleQty - TotalUsedQty), BindList, Cust, SaleValue));
                                //                }
                                //        //else
                                //        //    return ScemeList;
                                //    }
                                //}

                                #endregion

                            }
                        }
                        else if (objSCM4.BasedOn == (int)BasedOn.Item)
                        {

                            OrderOtem.Where(x => ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).ToList().ForEach(x => { DecNum += x.Quantity; SaleValue += x.SubTotal; });
                            if (DecNum > 0 && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= DecNum) && (objSCM4.HigherLimit >= DecNum || objSCM4.HigherLimit == 0))
                            {
                                decimal qty = 0;
                                if (objSCM4.Occurrence.HasValue && objSCM4.Occurrence.Value > 0)
                                {
                                    qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
                                }
                                else
                                {
                                    qty = objSCM4.Quantity;
                                }
                                if (Mode == "S")
                                {
                                    var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
                                    if (QPSEligibility.EligibleCount > 0)
                                    {

                                        var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
                                        if (QPSEligibility.OptionType == 1)
                                        {
                                            var TotalQty = objSCM4.IsPair.ToString().ToLower() == "true" ? qty * 2 : qty + TotalUsedCount;
                                            if (TotalQty > 0)
                                            {
                                                if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
                                                    if (TotalQty <= QPSEligibility.EligibleCount)
                                                        ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                    else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
                                                    {

                                                        if (qty < (objSCM4.IsPair.ToString().ToLower() == "true" ? objSCM4.Quantity / 2 : objSCM4.Quantity) * (QPSEligibility.EligibleCount - TotalUsedCount))
                                                        {
                                                            if ((objSCM4.IsPair.ToString().ToLower() == "true" ? qty / 2 : qty) > (QPSEligibility.EligibleCount - TotalUsedCount))
                                                                ScemeList.Add(AddItem(objSCM4, Convert.ToInt16((objSCM4.IsPair.ToString().ToLower() == "true" ? QPSEligibility.EligibleCount - TotalUsedCount * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                            else if (qty < QPSEligibility.EligibleCount)
                                                                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                            else
                                                            {
                                                                ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                            }
                                                            // ScemeList.Add(AddItem(objSCM4, Convert.ToInt16(objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString()));
                                                        }
                                                        else
                                                            ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal((objSCM4.IsPair.ToString().ToLower() == "true" ? (QPSEligibility.EligibleCount - TotalUsedCount) * 2 : QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                    }




                                            }
                                        }
                                        else if (QPSEligibility.OptionType == 2)
                                        {

                                            if (TotalUsedCount < QPSEligibility.EligibleCount)
                                                ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                        }
                                    }
                                }
                                else
                                {
                                    ScemeList.Add(AddItem(objSCM4, qty, BindList, Cust, SaleValue, "", DecNum.ToString(), objScheme.ApplicableMode));
                                }
                            }
                        }
                        else if (objSCM4.BasedOn == (int)BasedOn.Unit)
                        {
                            foreach (ItemData item in OrderOtem)
                            {
                                if (item.Quantity > 0 && (ctx.CheckSCM3(item.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1) && (objSCM4.LowerLimit == 0 || objSCM4.LowerLimit <= item.Quantity) && (objSCM4.HigherLimit >= item.Quantity || objSCM4.HigherLimit == 0))
                                {
                                    DecNum = 0;
                                    SaleValue = item.SubTotal;
                                    //var qty = Math.Ceiling((item.Quantity - objSCM4.Occurrence.Value - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) + objSCM4.Quantity;
                                    var qty = Math.Floor((Math.Floor((DecNum - objSCM4.LowerLimit) / objSCM4.Occurrence.Value) * objSCM4.Quantity) + objSCM4.Quantity);
                                    var QPSEligibility = ctx.usp_CheckQPSEligibility(Cust.CustomerID, objSCM4.SchemeID).FirstOrDefault();
                                    var TotalUsedCount = ctx.GetCustomerQPSEligibilitySP(Cust.CustomerID, objSCM4.SchemeID, QPSEligibility.OptionType).FirstOrDefault();
                                    var TotalQty = qty + TotalUsedCount;

                                    if (qty > 0)
                                    {
                                        if (objSCM4.ItemID.HasValue)
                                            DecNum = qty * objSCM4.Quantity;
                                        else
                                            DecNum = qty;

                                        TotalQty = DecNum;

                                        if (QPSEligibility.EligibleCount > 0)
                                        {


                                            if (QPSEligibility.OptionType == 1)
                                            {
                                                // var TotalQty = qty + TotalUsedCount;
                                                if (TotalQty > 0)
                                                {
                                                    if ((QPSEligibility.EligibleCount - TotalUsedCount) != 0)
                                                        if (TotalQty <= QPSEligibility.EligibleCount)
                                                            ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                        else if ((QPSEligibility.EligibleCount - TotalUsedCount) > 0)
                                                        {
                                                            if (qty < objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount))
                                                                ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                        }
                                                }
                                            }
                                            else if (QPSEligibility.OptionType == 2)
                                            {

                                                if (TotalUsedCount < QPSEligibility.EligibleCount)
                                                    ScemeList.Add(AddItem(objSCM4, DecNum, BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                                else
                                                    ScemeList.Add(AddItem(objSCM4, Convert.ToDecimal(objSCM4.Quantity * (QPSEligibility.EligibleCount - TotalUsedCount)), BindList, Cust, SaleValue, QPSEligibility.AlertMsg.ToString(), DecNum.ToString(), objScheme.ApplicableMode));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return ScemeList;
        }
    }

    private static SchemeData AddItem(SCM4 objSCM4, Decimal Qty, List<ItemData> BindList, OCRD Cust, Decimal SaleAmount, String AlertMessage, string QtyScheme, string ApplicableMode)
    {
        decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

        Decimal DecNum = 0;
        //ObjItemDisc


        SchemeData objScheme = new SchemeData();
        objScheme.BasedOn = objSCM4.BasedOn;
        objScheme.SchemeID = objSCM4.SchemeID;
        objScheme.ScName = objSCM4.OSCM.SchemeID + " - " + objSCM4.OSCM.SchemeName;
        objScheme.Mode = objSCM4.OSCM.ApplicableMode;
        objScheme.SaleAmount = SaleAmount;
        objScheme.AlertMessage = AlertMessage;
        objScheme.QPSQTY = QtyScheme.ToString();
        objScheme.Occurance = Convert.ToDecimal(objSCM4.Occurrence.ToString());
        objScheme.IsPair = objSCM4.IsPair == false ? "No" : "Yes";
        objScheme.HigherLimit = Convert.ToDecimal(objSCM4.HigherLimit.ToString("0.00"));
        objScheme.LowerLimit = Convert.ToDecimal(objSCM4.LowerLimit.ToString("0.00"));

        objScheme.ContraTax = objSCM4.DistributorDisc + "," + objSCM4.CompanyDisc;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (objSCM4.ItemID.HasValue)
            {
                List<SaleItem_Result> Data = null;
                int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == objSCM4.ItemID.Value).DivisionlID.Value;

                Decimal BillCustID = Cust.BillToPartyCustID.HasValue ? Cust.BillToPartyCustID.Value : Cust.CustomerID;
                int PriceID = 0;
                //OWH objWHS = ctx.OWHS.FirstOrDefault(x => x.WhsID ==  && x.ParentID == ParentID && x.Active);
                if (Cust.IsTemp)
                {
                    Decimal TempCustID = ctx.OCRDs.Where(x => x.CustomerName.ToLower().Contains("unregistered dealer") && x.ParentID == ParentID && x.Active).Select(x => x.CustomerID).FirstOrDefault();

                    PriceID = ctx.OGCRDs.Where(x => x.CustomerID == TempCustID && x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                    Data = ctx.SaleItem(ParentID, TempCustID, PriceID, 0, objSCM4.ItemID.Value, 0, 1, BillCustID).ToList();
                }
                else
                {
                    PriceID = Cust.OGCRDs.Where(x => x.DivisionlID == DivisionlID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();
                    Data = ctx.SaleItem(ParentID, Cust.CustomerID, PriceID, 0, objSCM4.ItemID.Value, 0, 1, BillCustID).ToList();
                }

                if (objSCM4.UnitID.HasValue)
                    objScheme.UnitID = objSCM4.UnitID.Value;
                else
                {
                    var objITM1 = ctx.ITM1.FirstOrDefault(x => x.ItemID == objSCM4.ItemID.Value && x.IsBaseUnit);
                    objScheme.UnitID = objITM1.UnitID;
                }

                SaleItem_Result objPrice = Data.FirstOrDefault(x => x.UnitID == objScheme.UnitID);
                if (objPrice == null)
                {
                    throw new Exception("Price is not found for QPS Scheme Item : " + objSCM4.OITM.ItemCode + " # " + objSCM4.OITM.ItemName);
                    ////pass mrp pricelist for dhantesar qps scheme
                    //Data = ctx.SaleItem(ParentID, 1, 0, objSCM4.ItemID.Value, 0, 0).ToList();
                    //objPrice = Data.FirstOrDefault(x => x.UnitID == objScheme.UnitID);
                    //if (objPrice == null)
                    //{
                    //    objPrice = new SaleItem_Result();
                    //    objPrice.Unitname = ctx.OUNTs.FirstOrDefault(x => x.UnitID == objScheme.UnitID).UnitName;
                    //    objPrice.TaxID = 0;
                    //    objPrice.UnitPrice = 0;
                    //    objPrice.Tax = 0;
                    //}
                }
                if (objPrice.UnitPrice == 0)
                {
                    throw new Exception("Zero Price is found for QPS Scheme Item : " + objSCM4.OITM.ItemCode + " # " + objSCM4.OITM.ItemName);
                }
                var RDR1s = ctx.RDR1.Where(x => x.IsDeleted == false && x.MainID == 1 && x.OrderID == OrderIDQPS && x.ParentID == ParentID).FirstOrDefault();
                if (RDR1s != null)
                {
                    if (objSCM4.ItemID.Value == RDR1s.ItemID && objSCM4.SchemeID == RDR1s.SchemeID)
                    {
                        objScheme.MainId = 1;
                    }
                }
                objScheme.AvailQty = objPrice.AvailQty;
                objScheme.ItemID = objSCM4.ItemID.Value;
                objScheme.ItemName = objSCM4.OITM.ItemName;
                objScheme.ItemCode = objSCM4.OITM.ItemCode;
                objScheme.UnitName = objPrice.Unitname;
                objScheme.TaxID = objPrice.TaxID;
                objScheme.UnitPrice = Convert.ToDecimal(objPrice.UnitPrice.ToString("0.00"));
                objScheme.MRP = Convert.ToDecimal(objPrice.MRP.ToString("0.00"));
                objScheme.PriceTax = Convert.ToDecimal(objPrice.Tax.ToString("0.00"));
                objScheme.Quantity = Qty;

                ItemWiseDiscountData ObjItmDiscount = new ItemWiseDiscountData();
                ObjItmDiscount.ItemID = objSCM4.ItemID.Value;
                ObjItmDiscount.Mode = objSCM4.OSCM.ApplicableMode;
                ObjItmDiscount.SchemeID = objSCM4.SchemeID;
                ObjItmDiscount.Quantity = Qty;

                GetNormalPricing_Result NormalPriceData = ctx.GetNormalPricing(ParentID, Cust.CustomerID, DivisionlID, objScheme.ItemID, Data.FirstOrDefault().UnitPrice, PriceID).FirstOrDefault();
                if (NormalPriceData == null || NormalPriceData.Flag == 0)
                {
                    throw new Exception(NormalPriceData.Msg);
                }
                else
                {
                    objScheme.NormalPrice = Convert.ToDecimal(NormalPriceData.NormalRate.ToString("0.00"));
                }


                if (objSCM4.DiscountType == "P")
                {
                    objScheme.Discount = objSCM4.Discount;
                    objScheme.DiscType = "₹";
                }
                else
                {
                    objScheme.Discount = (100 * objSCM4.Discount) / objPrice.UnitPrice;
                    objScheme.DiscType = "%";
                }

                objScheme.Price = Convert.ToDecimal((objScheme.UnitPrice - ((objScheme.UnitPrice * objScheme.Discount) / 100)).ToString("0.00"));

                if (objSCM4.OSCM.IsTaxApplicable)
                {
                    Decimal FinalTax = (100 * objPrice.Tax) / objPrice.UnitPrice;

                    FinalTax = ((FinalTax * objScheme.Price) / 100);

                    objScheme.Tax = FinalTax * Qty;

                }

                objScheme.SubTotal = objScheme.Price * objScheme.Quantity;

                objScheme.Total = objScheme.SubTotal + objScheme.Tax;

                // objSCM4.DistributorDisc + "," + objSCM4.CompanyDisc;
                if (objSCM4.CompanyDisc != 0)
                {
                    ObjItmDiscount.CompanyContri = Convert.ToDecimal((objSCM4.CompanyDisc * objScheme.Discount) / 100);
                }
                else
                {
                    ObjItmDiscount.CompanyContri = 0;
                }
                if (objSCM4.DistributorDisc != 0)
                {
                    ObjItmDiscount.DistributorContri = Convert.ToDecimal((objSCM4.DistributorDisc * objScheme.Discount) / 100);
                }
                else
                {
                    ObjItmDiscount.DistributorContri = 0;
                }
                ObjItmDiscount.Discount = objScheme.Discount;
                ObjItemDisc.Add(ObjItmDiscount);
            }
            else
            {

                if (objSCM4.BasedOn == (int)BasedOn.Invoice)
                {
                    Decimal Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                    if (objSCM4.DiscountType == "P")
                    {
                        DecNum = (Total * objSCM4.Discount) / 100;
                        objScheme.Discount = DecNum;
                        foreach (ItemData itm in BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1))
                        {
                            ItemWiseDiscountData ObjItmDiscount = new ItemWiseDiscountData();
                            ObjItmDiscount.ItemID = itm.ItemID;
                            ObjItmDiscount.Mode = ApplicableMode;
                            ObjItmDiscount.SchemeID = objSCM4.SchemeID;
                            ObjItmDiscount.Quantity = itm.Quantity;
                            if (objSCM4.CompanyDisc != 0)
                            {
                                ObjItmDiscount.CompanyContri = Convert.ToDecimal((objSCM4.CompanyDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.CompanyContri = 0;
                            }
                            if (objSCM4.DistributorDisc != 0)
                            {
                                ObjItmDiscount.DistributorContri = Convert.ToDecimal((objSCM4.DistributorDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.DistributorContri = 0;
                            }
                            ObjItmDiscount.Discount = Convert.ToDecimal((objSCM4.Discount * itm.SubTotal) / 100);
                            ObjItemDisc.Add(ObjItmDiscount);
                        }
                    }
                    else
                    {
                        objScheme.Discount = objSCM4.Discount;
                        foreach (ItemData itm in BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1))
                        {
                            ItemWiseDiscountData ObjItmDiscount = new ItemWiseDiscountData();
                            ObjItmDiscount.ItemID = itm.ItemID;
                            ObjItmDiscount.Mode = ApplicableMode;
                            ObjItmDiscount.SchemeID = objSCM4.SchemeID;
                            ObjItmDiscount.Quantity = itm.Quantity;
                            if (objSCM4.CompanyDisc != 0)
                            {
                                ObjItmDiscount.CompanyContri = Convert.ToDecimal((objSCM4.CompanyDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.CompanyContri = 0;
                            }
                            if (objSCM4.DistributorDisc != 0)
                            {
                                ObjItmDiscount.DistributorContri = Convert.ToDecimal((objSCM4.DistributorDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.DistributorContri = 0;
                            }
                            ObjItmDiscount.Discount = Convert.ToDecimal((objSCM4.Discount * itm.SubTotal) / 100);
                            ObjItemDisc.Add(ObjItmDiscount);
                        }
                    }
                }
                else if (objSCM4.BasedOn == (int)BasedOn.Item)
                {
                    Decimal Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                    if (objSCM4.DiscountType == "P")
                    {
                        DecNum = (Total * objSCM4.Discount) / 100;
                        objScheme.Discount = DecNum;
                        foreach (ItemData itm in BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1))
                        {
                            ItemWiseDiscountData ObjItmDiscount = new ItemWiseDiscountData();
                            ObjItmDiscount.ItemID = itm.ItemID;
                            ObjItmDiscount.Mode = ApplicableMode;
                            ObjItmDiscount.SchemeID = objSCM4.SchemeID;
                            ObjItmDiscount.Quantity = itm.Quantity;
                            if (objSCM4.CompanyDisc != 0)
                            {
                                ObjItmDiscount.CompanyContri = Convert.ToDecimal((objSCM4.CompanyDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.CompanyContri = 0;
                            }
                            if (objSCM4.DistributorDisc != 0)
                            {
                                ObjItmDiscount.DistributorContri = Convert.ToDecimal((objSCM4.DistributorDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.DistributorContri = 0;
                            }
                            ObjItmDiscount.Discount = Convert.ToDecimal((objSCM4.Discount * itm.SubTotal) / 100);
                            ObjItemDisc.Add(ObjItmDiscount);
                        }
                    }
                    else
                        objScheme.Discount = objSCM4.Discount;
                }
                else if (objSCM4.BasedOn == (int)BasedOn.Unit)
                {
                    Decimal Total = BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1).Select(x => x.SubTotal).Sum();
                    if (objSCM4.DiscountType == "P")
                    {
                        DecNum = (Total * objSCM4.Discount) / 100;
                        objScheme.Discount = DecNum * Qty;
                        foreach (ItemData itm in BindList.Where(x => x.MainID == 0 && ctx.CheckSCM3(x.ItemID, objSCM4.SchemeID, Cust.CustomerID).FirstOrDefault().Value == 1))
                        {
                            ItemWiseDiscountData ObjItmDiscount = new ItemWiseDiscountData();
                            ObjItmDiscount.ItemID = itm.ItemID;
                            ObjItmDiscount.Mode = ApplicableMode;
                            ObjItmDiscount.SchemeID = objSCM4.SchemeID;
                            ObjItmDiscount.Quantity = itm.Quantity;
                            if (objSCM4.CompanyDisc != 0)
                            {
                                ObjItmDiscount.CompanyContri = Convert.ToDecimal((objSCM4.CompanyDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.CompanyContri = 0;
                            }
                            if (objSCM4.DistributorDisc != 0)
                            {
                                ObjItmDiscount.DistributorContri = Convert.ToDecimal((objSCM4.DistributorDisc * itm.SubTotal) / 100);
                            }
                            else
                            {
                                ObjItmDiscount.DistributorContri = 0;
                            }
                            ObjItmDiscount.Discount = Convert.ToDecimal((objSCM4.Discount * itm.SubTotal) / 100);
                            ObjItemDisc.Add(ObjItmDiscount);
                        }
                    }
                    else
                    {
                        objScheme.Discount = objSCM4.Discount * Qty;
                    }
                }

                objScheme.Quantity = Qty;
                objScheme.UnitPrice = 0;
                objScheme.Discount = objScheme.Discount;
                objScheme.Total = 0;
                // objSCM4.DistributorDisc + "," + objSCM4.CompanyDisc;

            }
            //Set Rate For QPS From Scheme Master
            objScheme.RateForScheme = objSCM4.Price;
        }

        return objScheme;
    }

    private static List<ItemData> ResetAll(List<ItemData> BindList, out decimal SubTotal, out decimal Tax)
    {
        SubTotal = 0;
        Tax = 0;

        Decimal FinalPrice = 0, FinalTax = 0;

        foreach (ItemData item in BindList)
        {
            if (item.Quantity > 0)
                if (item.SchemeID > 0 && item.AddOn)
                {
                    Tax += item.Tax;
                    SubTotal += item.SubTotal;
                }
                else
                {
                    item.Discount = 0;
                    FinalPrice = item.UnitPrice;

                    FinalPrice = FinalPrice - ((FinalPrice * item.ItemScheme) / 100);
                    FinalPrice = FinalPrice - ((FinalPrice * item.Scheme) / 100);
                    FinalPrice = FinalPrice - ((FinalPrice * item.Discount) / 100);

                    FinalTax = (100 * item.PriceTax) / item.UnitPrice;

                    FinalTax = ((FinalTax * FinalPrice) / 100);

                    item.Price = FinalPrice + FinalTax;

                    item.Tax = item.Quantity * FinalTax;
                    item.SubTotal = item.Quantity * FinalPrice;

                    Tax += item.Tax;
                    SubTotal += item.SubTotal;
                }

            item.Total = item.SubTotal + item.Tax;
        }

        return BindList;
    }

    public static Dictionary<int, string> ReadData_Actual(Decimal ParentId, Int32 SaleId)
    {
        var result = new Dictionary<int, string>();
        try
        {
            Oledb_ConnectionClass objCon = new Oledb_ConnectionClass();
            ServiceLayerSync ServiceLayerData = new ServiceLayerSync();
            Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
            SqlCommand Cmd = new SqlCommand();
            Cmd.Parameters.Clear();
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.CommandText = "usp_GetInvoiceDetailsForEInvoice";
            Cmd.Parameters.AddWithValue("@ParentID", ParentId);
            Cmd.Parameters.AddWithValue("@SaleID", SaleId);
            DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
            DataTable oRecordSet = new DataTable();
            oRecordSet = dsdata.Tables[0];
            // 5 objCon.ByProcedureReturnDataTable("{Call Schema.VC_EINV_Query_TEST_Invoice(?,?)}", 2, ParamName, ParamVal);
            TaxProEInvoice objAPICAll = new TaxProEInvoice();
            TaxProEInvoice Invoice = new TaxProEInvoice();
            ItemList objItemList = new ItemList();
            if (oRecordSet.Rows.Count > 0)
            {
                for (int i = 0; i < 1; i++)
                {
                    GSTIN = string.Empty;

                    Invoice = new TaxProEInvoice();
                    GSTID = Convert.ToString(oRecordSet.Rows[0]["U_GSTID"]);
                    GSTPWD = Convert.ToString(oRecordSet.Rows[0]["U_GSTPW"]);


                    Invoice.Version = "1.1";

                    Invoice.TranDtls.TaxSch = "GST";
                    Invoice.TranDtls.SupTyp = Convert.ToString(oRecordSet.Rows[0]["SupTyp"]);
                    Invoice.TranDtls.RegRev = "N";
                    Invoice.TranDtls.EcmGstin = null;//Convert.ToString(oRecordSet.Rows[0]["CompanyGstInNo"]); ;
                    Invoice.TranDtls.IgstOnIntra = Convert.ToString(oRecordSet.Rows[0]["IGSTONITRA"]);

                    Invoice.DocDtls.Typ = Convert.ToString(oRecordSet.Rows[0]["DocDtls.Typ"]);
                    Invoice.DocDtls.No = Convert.ToString(oRecordSet.Rows[0]["InvoiceNumber"]);
                    Invoice.DocDtls.Dt = Convert.ToString(oRecordSet.Rows[0]["InvoiceDate"]);

                    Invoice.SellerDtls.Gstin = Convert.ToString(oRecordSet.Rows[0]["CompanyGstInNo"]);
                    Invoice.SellerDtls.LglNm = Convert.ToString(oRecordSet.Rows[0]["CompanyName"]);
                    Invoice.SellerDtls.TrdNm = null;

                    string Add1 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress1"]);
                    if (Add1.Length > 100)
                    {
                        Invoice.SellerDtls.Addr1 = Add1.Substring(0, 100);
                    }
                    else
                    {
                        Invoice.SellerDtls.Addr1 = Add1;
                    }

                    if (Convert.ToString(oRecordSet.Rows[0]["CompanyAddress2"]).Length > 1)
                    {
                        string Add2 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress2"]);
                        if (Add2.Length > 100)
                        {
                            Invoice.SellerDtls.Addr2 = Add2.Substring(0, 100);
                        }
                        else
                        {
                            Invoice.SellerDtls.Addr2 = Add2;
                        }
                    }
                    else
                    { Invoice.SellerDtls.Addr2 = null; }

                    Invoice.SellerDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["SellerLocation"]);
                    Invoice.SellerDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["SellerPin"]));
                    Invoice.SellerDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["Stcd"]);
                    if (Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWOP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "DEXP")
                    {
                        Invoice.BuyerDtls.Gstin = "";
                        Invoice.BuyerDtls.Pos = "";
                        Invoice.BuyerDtls.Pin = 0;
                        Invoice.BuyerDtls.Stcd = "";
                    }
                    else
                    {
                        Invoice.BuyerDtls.Gstin = Convert.ToString(oRecordSet.Rows[0]["Demo"]);
                        Invoice.BuyerDtls.Pos = Convert.ToString(oRecordSet.Rows[0]["Demo1"]);
                        Invoice.BuyerDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["ShipDtls.Pin"]));
                        Invoice.BuyerDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["Demo1"]);
                    }


                    Invoice.BuyerDtls.LglNm = Convert.ToString(oRecordSet.Rows[0]["CustomerName"]);
                    Invoice.BuyerDtls.TrdNm = null;
                    string ShipDtlsAdd1 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress1"]);
                    if (ShipDtlsAdd1.Length > 100)
                    {
                        Invoice.BuyerDtls.Addr1 = ShipDtlsAdd1.Substring(0, 100);
                    }
                    else
                    {
                        Invoice.BuyerDtls.Addr1 = ShipDtlsAdd1;
                    }


                    if (Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]).Length > 1)
                    {
                        string ShipDtlsAdd2 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]);
                        if (ShipDtlsAdd2.Length > 100)
                        {
                            Invoice.BuyerDtls.Addr2 = ShipDtlsAdd2.Substring(0, 100);
                        }
                        else
                        {
                            Invoice.BuyerDtls.Addr2 = ShipDtlsAdd2;
                        }
                    }
                    else
                    {
                        Invoice.BuyerDtls.Addr2 = null;
                    }
                    Invoice.BuyerDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["CustomerLocation"]);

                    //For testing nidhi // 15-Nov-22
                    //if (DebiteNote == false)
                    //{
                    //    Invoice.DispDtls.Nm = Convert.ToString(oRecordSet.Rows[0]["CustomerName"]);
                    //    string DispAdd1 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress1"]);
                    //    if (DispAdd1.Length > 100)
                    //    {
                    //        Invoice.DispDtls.Addr1 = DispAdd1.Substring(0, 100);//oRec.Fields.Item("DispDtls.Addr1").Value;
                    //    }
                    //    else
                    //    {
                    //        Invoice.DispDtls.Addr1 = DispAdd1;
                    //    }

                    //    string DispAdd2 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]);
                    //    if (DispAdd2.Length > 100)
                    //    {
                    //        Invoice.DispDtls.Addr2 = DispAdd2.Substring(0, 100);
                    //    }
                    //    else
                    //    {
                    //        Invoice.DispDtls.Addr2 = DispAdd2;
                    //    }

                    //    Invoice.DispDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["CustomerLocation"]);
                    //    Invoice.DispDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["CustomerPin"]));
                    //    Invoice.DispDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["CustomerStcd"]);

                    //}
                    //if (DebiteNote == true)
                    //{
                    //    Invoice.DispDtls.Nm = Convert.ToString(oRecordSet.Rows[0]["CompanyName"]);
                    //    string SellAdd1 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress1"]);
                    //    if (SellAdd1.Length > 100)
                    //    {
                    //        Invoice.DispDtls.Addr1 = SellAdd1.Substring(0, 100);
                    //    }
                    //    else
                    //    {
                    //        Invoice.DispDtls.Addr1 = SellAdd1;
                    //    }
                    //    if (oRecordSet.Rows[0]["CompanyAddress2"].ToString().Length > 1)
                    //    {
                    //        string selAdd2 = Convert.ToString(oRecordSet.Rows[0]["CompanyAddress2"]);
                    //        if (selAdd2.Length > 100)
                    //        {
                    //            Invoice.DispDtls.Addr2 = selAdd2.Substring(0, 100);
                    //        }
                    //        else
                    //        {
                    //            Invoice.DispDtls.Addr2 = selAdd2;
                    //        }
                    //    }
                    //    else
                    //    {
                    //        Invoice.DispDtls.Addr2 = null;
                    //    }

                    //    Invoice.DispDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["SellerLocation"]);
                    //    Invoice.DispDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["SellerPin"]));
                    //    Invoice.DispDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["Stcd"]);
                    //}
                    //For testing nidhi // Vimal 15-Nov-22

                    if (Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "EXPWOP" || Convert.ToString(oRecordSet.Rows[0]["SupTyp"]) == "DEXP")
                    {
                        DataTable oRecor = new DataTable();
                        oRecor = dsdata.Tables[0];
                        // 4 objCon.ByQueryReturnDataTable("select * from Schema.\"@VCPORT\" where \"Code\"='" + Convert.ToString(oRecordSet.Rows[0]["ExpDtls.Port"]) + "'");

                        try
                        {
                            if (oRecor.Rows.Count > 0)
                            {

                                // 15-Nov-22 Vimal
                                //   Invoice.ShipDtls.LglNm = Convert.ToString(oRecor.Rows[0]["CustomerName"]);
                                //string PortAdd = Convert.ToString(oRecor.Rows[0]["CustomerAddress1"]);
                                //if (PortAdd.Length > 100)
                                //{
                                //    Invoice.ShipDtls.Addr1 = PortAdd.Substring(0, 100);//Port Address
                                //}
                                //else
                                //{
                                //    Invoice.ShipDtls.Addr1 = PortAdd;
                                //}
                                //Invoice.ShipDtls.Loc = Convert.ToString(oRecor.Rows[0]["CustomerLocation"]);//Location
                                //Invoice.ShipDtls.Pin = Convert.ToInt32(Convert.ToString(oRecor.Rows[0]["CustomerPin"]));// 370421;
                                //Invoice.ShipDtls.Stcd = Convert.ToString(oRecor.Rows[0]["CustomerStcd"]);// "24";
                                //Invoice.ShipDtls.Pin = ;
                                //Invoice.ShipDtls.Stcd = "";
                                // 15-Nov-22 Vimal
                            }
                        }
                        catch { }


                    }
                    else
                    {
                        // 15-Nov-22 Vimal
                        //Invoice.ShipDtls.LglNm = Convert.ToString(oRecordSet.Rows[0]["CustomerName"]); //oRec.Fields.Item("ShipDtls.LglNm").Value;
                        //Invoice.ShipDtls.TrdNm = null;
                        //string ShAdd1 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress1"]);
                        //if (ShAdd1.Length > 100)
                        //{
                        //    Invoice.ShipDtls.Addr1 = ShAdd1.Substring(0, 100); //oRec.Fields.Item("ShipDtls.Add1").Value;
                        //}
                        //else
                        //{
                        //    Invoice.ShipDtls.Addr1 = ShAdd1;
                        //}
                        //if (Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]).Length > 1)//oRec.Fields.Item("ShipDtls.Add2").Value
                        //{
                        //    string ShAdd2 = Convert.ToString(oRecordSet.Rows[0]["CustomerAddress2"]);
                        //    if (ShAdd2.Length > 100)
                        //    {
                        //        Invoice.ShipDtls.Addr2 = ShAdd2.Substring(0, 100);
                        //    }
                        //    else
                        //    {
                        //        Invoice.ShipDtls.Addr2 = ShAdd2;
                        //    }
                        //}
                        //else
                        //{
                        //    Invoice.ShipDtls.Addr2 = null;
                        //}
                        //Invoice.ShipDtls.Loc = Convert.ToString(oRecordSet.Rows[0]["CustomerLocation"]);// oRec.Fields.Item("ShipDtls.Dst").Value;

                        //Invoice.ShipDtls.Gstin = Convert.ToString(oRecordSet.Rows[0]["CustomerGstInNo"]); //oRec.Fields.Item("Demo").Value;
                        //Invoice.ShipDtls.Pin = Convert.ToInt32(Convert.ToString(oRecordSet.Rows[0]["CustomerPin"]));// oRec.Fields.Item("ShipDtls.Pin").Value;
                        //Invoice.ShipDtls.Stcd = Convert.ToString(oRecordSet.Rows[0]["CustomerStcd"]);//oRec.Fields.Item("Demo1").Value;
                        // 15-Nov-22 Vimal
                    }

                }
                DataTable oRec1 = new DataTable();
                //  objCon = new Oledb_ConnectionClass();
                oRec1 = dsdata.Tables[0];

                // 3    oRec1 = objCon.ByProcedureReturnDataTable("{Call Schema.VC_EINV_Query_TEST_InvoiceItem1(?,?)}", 2, "SERIES|DOCNUM", Series + "|" + DocNum);
                if (oRec1.Rows.Count > 0)
                {
                    double IGSTActSum = 0.0;
                    int SrlNo = 0;
                    for (int k = 0; k < oRec1.Rows.Count; k++)
                    {
                        objItemList = new ItemList();
                        GSTIN = Convert.ToString(oRec1.Rows[k]["CompanyGstInNo"]);
                        //Convert.ToInt16(Convert.ToString(oRec1.Rows[k]["ItemList.Item.Slno"]));
                        SrlNo = SrlNo + 1;
                        objItemList.SlNo = Convert.ToString(SrlNo);
                        if (DebiteNote == false)
                        {
                            if (!string.IsNullOrEmpty(Convert.ToString(oRec1.Rows[k]["ItemName"])))
                            {
                                objItemList.PrdDesc = Convert.ToString(oRec1.Rows[k]["ItemName"]);
                            }
                        }
                        if (DebiteNote == true)
                        {
                            if (Convert.ToString(oRec1.Rows[k]["ItemName"]).Length > 1)
                            {
                                objItemList.PrdDesc = Convert.ToString(oRec1.Rows[k]["ItemName"]);
                            }
                        }
                        objItemList.IsServc = Convert.ToString(oRec1.Rows[k]["IsServc"]);

                        if (DebiteNote == false)
                        {
                            string HSNCode = Convert.ToString(oRec1.Rows[k]["HSNCode"]);
                            if (HSNCode.Contains(".") || HSNCode.Contains("-"))
                            {
                                HSNCode = HSNCode.Remove(4, 1);
                                HSNCode = HSNCode.Remove(6, 1);
                            }
                            objItemList.HsnCd = HSNCode;
                        }
                        if (DebiteNote == true)
                        {
                            string HSNCode = Convert.ToString(oRec1.Rows[k]["HSNCode"]);
                            objItemList.HsnCd = HSNCode;
                        }
                        if (DebiteNote == false)
                        {
                            objItemList.Qty = Convert.ToDouble(oRec1.Rows[k]["Quantity"].ToString());
                            // 15-Nov-22 Vimal
                            if (!string.IsNullOrEmpty(oRec1.Rows[k]["UnitName"].ToString()))
                            {
                                objItemList.Unit = "CTN";//oRec1.Rows[k]["UnitName"].ToString();
                            }
                            // 15-Nov-22 Vimal
                        }
                        objItemList.UnitPrice = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["UnitPrice"])), 2);
                        objItemList.TotAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GrossAmt"])), 2);
                        objItemList.Discount = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2);
                        objItemList.AssAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GrossAmt"])) - Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2);
                        objItemList.GstRt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["GSTRate"])), 2);


                        // 14-Nov-22
                        if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                        {
                            double Amount = Math.Round(((Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DocTotal"])) * Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["ItemList.Item.GstRate"]))) / 100), 2);
                            IGSTActSum += Amount;
                            objItemList.IgstAmt = Amount;
                        }
                        else
                        {
                            objItemList.IgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["IGSTVal"])), 2);
                        }

                        objItemList.CgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CGSTVal"])), 2);
                        objItemList.SgstAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["SGSTVal"])), 2);
                        objItemList.CesRt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CesRt"])), 2);
                        objItemList.CesAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["CessSum"])), 2);
                        objItemList.CesNonAdvlAmt = 0;
                        objItemList.StateCesRt = 0;
                        objItemList.StateCesAmt = 0;
                        objItemList.StateCesNonAdvlAmt = 0;
                        objItemList.OthChrg = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["OthChrg"])), 2);
                        if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                        {
                            objItemList.TotItemVal = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["Total"])) + Math.Round(objItemList.IgstAmt), 2);
                        }
                        else
                        {
                            objItemList.TotItemVal = Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["Total"]))); //+ Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["IGSTVal"])) - Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DiscountAmt"])), 2); // Math.Round(Convert.ToDouble(Convert.ToString(oRec1.Rows[k]["DocTotal"])), 2);
                        }
                        Invoice.ItemList.Add(objItemList);
                    }
                    Invoice.PrecDocDtls.InvNo = null;
                    Invoice.PrecDocDtls.InvDt = null;
                    // 15-Nov-22 Vimal
                    //if (Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                    //{
                    //    Invoice.ExpDtls.RefClm = Convert.ToString(oRecordSet.Rows[0]["Refund"]);
                    //    if (Convert.ToString(oRecordSet.Rows[0]["ShipBNo"]) == "")
                    //    {
                    //        Invoice.ExpDtls.ShipBNo = null;
                    //    }
                    //    else
                    //    {
                    //        Invoice.ExpDtls.ShipBNo = Convert.ToString(oRecordSet.Rows[0]["ShipBNo"]);
                    //    }
                    //    if (Convert.ToString(oRecordSet.Rows[0]["ShipBDt"]) == "" || Convert.ToString(oRecordSet.Rows[0]["ShipBDt"]) == null)
                    //    {
                    //        Invoice.ExpDtls.ShipBDt = null;
                    //    }
                    //    else
                    //    {
                    //        Invoice.ExpDtls.ShipBDt = Convert.ToString(oRecordSet.Rows[0]["ShipBDt"]);
                    //    }
                    //}
                    //else
                    //{
                    //    Invoice.ExpDtls = null;
                    //}
                    // 15-Nov-22 Vimal
                    Invoice.ValDtls.AssVal = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["TotalbBefTax"])), 2);
                    Invoice.ValDtls.Item_Taxable_Value = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["TotalbBefTax"])), 2);
                    Invoice.ValDtls.CgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalCGSTVal"])), 2);
                    Invoice.ValDtls.SgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalSGSTVal"])), 2);
                    //if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                    //{
                    //    Invoice.ValDtls.IgstVal = Math.Round(IGSTActSum, 2);
                    //}
                    //else
                    //{
                    Invoice.ValDtls.IgstVal = Math.Round(Convert.ToDouble(Convert.ToString(dsdata.Tables[1].Rows[0]["TotalIGSTVal"])), 2);
                    //}

                    //Invoice.ValDtls.CesVal = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["CesVal"])), 2);
                    //Invoice.ValDtls.OthChrg = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["OthChrg"])), 2);
                    //Invoice.ValDtls.StCesVal = 0;
                    Invoice.ValDtls.RndOffAmt = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["Roundoff"])), 2);
                    if (Convert.ToString(oRecordSet.Rows[0]["ExportTypeName"]) == "SEZ" && Convert.ToString(oRecordSet.Rows[0]["ImpOrExp"]) == "Y")
                    {
                        Invoice.ValDtls.TotInvVal = Math.Round((Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["DocTotal"]))), 2); //+ Invoice.ValDtls.IgstVal + Invoice.ValDtls.CesVal), 2);
                    }
                    else
                    {
                        Invoice.ValDtls.TotInvVal = Math.Round(Convert.ToDouble(Convert.ToString(oRecordSet.Rows[0]["DocTotal"])), 2);
                    }

                    bool EwayFlag = false;
                    try
                    {
                        DataTable oRecord = new DataTable();
                        // 2    oRecord = objCon.ByQueryReturnDataTable("Select * from Schema.\"@LICENSEMST\" where  \"Name\" = 'EI'  and \"U_EWayBil\"='Y' ");
                        if (oRecord.Rows.Count > 0)
                        {
                            EwayFlag = true;
                        }
                    }
                    catch { }
                    if (EwayFlag == true && ((Invoice.TranDtls.SupTyp != "B2B") || (Invoice.SellerDtls.Stcd != Invoice.BuyerDtls.Stcd) || (Invoice.SellerDtls.Stcd == Invoice.BuyerDtls.Stcd && Invoice.TranDtls.SupTyp == "B2B" && Invoice.ValDtls.TotInvVal >= Convert.ToDouble("50000"))))
                    {
                        EWayBill = true;
                    }
                    else
                    {
                        EWayBill = false;
                    }

                    if (DebiteNote == false && EwayFlag == true && EWayBill == true && Invoice.DocDtls.Typ == "INV") //&& DocType == "I"
                    {
                        DataTable oRecor;
                        oRecor = new DataTable();
                        // 1  oRecor = objCon.ByQueryReturnDataTable(" select ifnull(\"Distance\",0) as \"Distance\",\"TransID\",\"TransName\",\"TransMode\",\"TransDocNo\",TO_NVARCHAR(\"TransDate\", 'DD/MM/YYYY') as \"TransDat\",\"VehicleTyp\",\"VehicleNo\" from Schema.INV26  where \"DocEntry\" = (select \"DocEntry\" from Schema.OINV where \"DocNum\"=" + DocNum + " and \"Series\"=" + Series + ")");
                        if (oRecor.Rows.Count > 0)
                        {
                            EWayBill = false;
                            //Invoice.EwbDtls.Distance = Convert.ToInt32(oRecor.Rows[0]["Distance"]);
                            //Invoice.EwbDtls.TransMode = Convert.ToString(oRecor.Rows[0]["TransMode"]);
                            //Invoice.EwbDtls.TransId = Convert.ToString(oRecor.Rows[0]["TransID"]);
                            //Invoice.EwbDtls.TransName = Convert.ToString(oRecor.Rows[0]["TransName"]);
                            //Invoice.EwbDtls.TransDocDt = Convert.ToString(oRecor.Rows[0]["TransDat"]);
                            //Invoice.EwbDtls.TransDocNo = Convert.ToString(oRecor.Rows[0]["TransDocNo"]);
                            //Invoice.EwbDtls.VehNo = Convert.ToString(oRecor.Rows[0]["VehicleNo"]);
                            //Invoice.EwbDtls.VehType = Convert.ToString(oRecor.Rows[0]["VehicleTyp"]);
                        }
                    }
                    else
                    {
                        //  Invoice.EwbDtls = null;
                    }

                    try
                    {
                        var obtGetToken = new Dictionary<int, string>();
                        obtGetToken = ServiceLayerData.SAPGetToken(GSTIN, GSTID, GSTPWD);
                        if (obtGetToken.Count > 0)
                        {
                            //AuthToken
                            if (obtGetToken.FirstOrDefault().Key == 1)
                            {
                                string SuccessToken = obtGetToken[1];
                                dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                                dynamic data1T = JsonConvert.SerializeObject(DataT["Data"]);
                                dynamic data2T = JsonConvert.DeserializeObject(data1T);
                                AuthToken = Convert.ToString(data2T["AuthToken"]);
                            }
                            else
                            {
                                string ErrToken = obtGetToken[1];
                                dynamic DataTT = JsonConvert.DeserializeObject(ErrToken);
                                dynamic data1TT = JsonConvert.SerializeObject(DataTT["error"]);
                                dynamic data2TTT = JsonConvert.DeserializeObject(data1TT);
                                result.Add(2, "Failed to generate AuthToken due to error" + Convert.ToString(data2TTT["message"]));
                                return result;
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        result.Add(2, "Error due to:" + e.Message);
                        return result;
                    }

                    string data = JsonConvert.SerializeObject(Invoice, new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Include });

                    var objArray = new Dictionary<int, string>();

                    objArray = ServiceLayerData.SAPAddToEInvoice(data, AuthToken, GSTIN, GSTID);
                    if (objArray.Count > 0)
                    {
                        try
                        {
                            if (objArray.FirstOrDefault().Key == 1)
                            {
                                string Success2 = (objArray[1]);
                                dynamic Data = JsonConvert.DeserializeObject(Success2);
                                string Status = Convert.ToString(Data["Status"]);

                                dynamic Err = JsonConvert.SerializeObject(Data["ErrorDetails"]);
                                dynamic DErr = "";
                                string ErMessage = "";
                                if (Err != "null")
                                {
                                    DErr = JsonConvert.DeserializeObject(Err);
                                    ErMessage = DErr[0]["ErrorMessage"];
                                }
                                var obtGetIRNDtl = new Dictionary<int, string>();
                                if (Status == "0")
                                {
                                    if (Data["InfoDtls"] != null)
                                    {
                                        dynamic Dtls = JsonConvert.SerializeObject(Data["InfoDtls"]);
                                        dynamic Dtlss = JsonConvert.DeserializeObject(Dtls);

                                        string IRNNo = Dtlss[0]["Desc"].Irn;
                                        obtGetIRNDtl = ServiceLayerData.SAPGetIRN(IRNNo, AuthToken, GSTIN, GSTID);
                                        string SuccessToken = obtGetIRNDtl[1];
                                        if (ErMessage == "Duplicate IRN")
                                        {
                                            try
                                            {

                                                if (obtGetIRNDtl.Count > 0)
                                                {
                                                    if (obtGetIRNDtl.FirstOrDefault().Key == 1)
                                                    {
                                                        try
                                                        {

                                                            dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                                                            dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                                                            dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                                                            dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);

                                                            if (Sucss != null && ErrorDetails == "null")
                                                            {
                                                                dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                                                                var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                                                                Data1 EInvClass = new Data1();
                                                                EInvClass.Irn = res.Irn;
                                                                EInvClass.SignedQRCode = res.SignedQRCode;
                                                                EInvClass.AckNo = res.AckNo;
                                                                EInvClass.AckDt = res.AckDt;
                                                                //EInvClass.EwbNo = res.EwbNo;
                                                                //EInvClass.EwbDt = res.EwbDt;
                                                                //EInvClass.EwbValidTill = res.EwbValidTill;

                                                                var objArray1 = new Dictionary<int, string>();
                                                                objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                                                                if (objArray1.FirstOrDefault().Key == 1)
                                                                {
                                                                    result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                                                                    return result;
                                                                }
                                                                else
                                                                {
                                                                    result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                                                                    return result;
                                                                }
                                                            }
                                                            else
                                                            {
                                                                result.Add(2, Convert.ToString("Fetch IRN Failed : " + Convert.ToString(ErrDetails[0].ErrorMessage)));
                                                                return result;
                                                            }
                                                        }
                                                        catch (Exception ex)
                                                        {
                                                            result.Add(2, Convert.ToString("Fetch IRN Failed : " + ex.ToString()));
                                                            return result;
                                                        }
                                                    }
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                result.Add(2, "Invoice can't posted on portal due to " + Convert.ToString(ex.Message));
                                                return result;
                                            }
                                        }
                                        else
                                        {

                                            dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                                            dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                                            dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                                            dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);

                                            if (Sucss != null && ErrorDetails == "null")
                                            {
                                                dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                                                var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                                                Data1 EInvClass = new Data1();
                                                EInvClass.Irn = res.Irn;
                                                EInvClass.SignedQRCode = res.SignedQRCode;
                                                EInvClass.AckNo = res.AckNo;
                                                EInvClass.AckDt = res.AckDt;
                                                //EInvClass.EwbNo = res.EwbNo;
                                                //EInvClass.EwbDt = res.EwbDt;
                                                //EInvClass.EwbValidTill = res.EwbValidTill;

                                                var objArray1 = new Dictionary<int, string>();
                                                objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                                            }
                                            result.Add(2, "Invoice can't posted on portal due to " + ErMessage);
                                            return result;
                                        }
                                    }
                                    else
                                    {
                                        dynamic Sucss = JsonConvert.SerializeObject(Data["Data"]);
                                        dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                                        Data1 EInvClass = new Data1();
                                        if (DSucss != null)
                                        {
                                            var res = JsonConvert.DeserializeObject<dynamic>(DSucss);
                                            EInvClass.Irn = res.Irn;
                                            EInvClass.SignedQRCode = res.SignedQRCode;
                                            EInvClass.AckNo = res.AckNo;
                                            EInvClass.AckDt = res.AckDt;
                                        }
                                        //EInvClass.EwbNo = res.EwbNo;
                                        //EInvClass.EwbDt = res.EwbDt;
                                        //EInvClass.EwbValidTill = res.EwbValidTill;
                                        var objArray1 = new Dictionary<int, string>();
                                        objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                                        if (objArray1.FirstOrDefault().Key == 1)
                                        {
                                            //result.Add(1, "IRN Number Updated Successfully");
                                            result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                                            return result;
                                        }
                                        else
                                        {
                                            result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                                            return result;
                                        }
                                    }
                                }
                                else if (Status == "1")
                                {
                                    dynamic Dtls = JsonConvert.SerializeObject(Data["Data"]);
                                    dynamic Dtlss = JsonConvert.DeserializeObject(Dtls);
                                    var res = JsonConvert.DeserializeObject<dynamic>(Dtlss);
                                    string IRNNo = Convert.ToString(res.Irn);
                                    obtGetIRNDtl = ServiceLayerData.SAPGetIRN(IRNNo, AuthToken, GSTIN, GSTID);
                                    string SuccessToken = obtGetIRNDtl[1];

                                    dynamic DataT = JsonConvert.DeserializeObject(SuccessToken);
                                    dynamic Sucss = JsonConvert.SerializeObject(DataT["Data"]);
                                    dynamic ErrorDetails = JsonConvert.SerializeObject(DataT["ErrorDetails"]);
                                    dynamic ErrDetails = JsonConvert.DeserializeObject(ErrorDetails);
                                    if (Sucss != null && ErrorDetails == null)
                                    {
                                        dynamic DSucss = JsonConvert.DeserializeObject(Sucss);
                                        var res1 = JsonConvert.DeserializeObject<dynamic>(DSucss);
                                        Data1 EInvClass = new Data1();
                                        EInvClass.Irn = res1.Irn;
                                        EInvClass.SignedQRCode = res1.SignedQRCode;
                                        EInvClass.AckNo = res1.AckNo;
                                        EInvClass.AckDt = res1.AckDt;

                                        //EInvClass.EwbNo = res.EwbNo;
                                        //EInvClass.EwbDt = res.EwbDt;
                                        //EInvClass.EwbValidTill = res.EwbValidTill;

                                        var objArray1 = new Dictionary<int, string>();
                                        objArray1 = UpdateInvoice(ParentId, SaleId, EInvClass.Irn, EInvClass.SignedQRCode, EInvClass.AckNo, EInvClass.AckDt, ErMessage, Convert.ToInt16(Status));
                                        if (objArray1.FirstOrDefault().Key == 1)
                                        {
                                            result.Add(1, Convert.ToString(objArray1.FirstOrDefault().Value));
                                            return result;
                                        }
                                        else
                                        {
                                            result.Add(2, Convert.ToString(objArray1.FirstOrDefault().Value));
                                            return result;
                                        }
                                    }
                                }
                            }
                            else if (objArray.FirstOrDefault().Key == 2)
                            {
                                result.Add(2, "Invoice can't posted on portal due to:" + objArray.FirstOrDefault().Value);
                                return result;
                            }
                            else
                            {
                                result.Add(2, "Invoice can't posted on portal due to:" + objArray.FirstOrDefault().Value);
                                return result;
                            }
                            DebiteNote = false;
                        }
                        catch (Exception e)
                        {
                            result.Add(2, "Error due to:" + e);
                            return result;
                        }
                    }
                }
                //   }
            }
            else
            {
                result.Add(2, "GST No. Or Import/Export Data should be mandatory");
                return result;
            }
        }
        catch (Exception e)
        {
            result.Add(3, "Error due to:" + e.Message);
            return result;
        }
        return result;
    }

    public static Dictionary<int, string> UpdateInvoice(Decimal ParentId, Int32 SaleId, string IrnData, string SignQRCodeData, string AckNos, string AckDts, String ErrorMsg, int Status)
    {
        DDMSEntities ctx = new DDMSEntities();

        var result = new Dictionary<int, string>();
        try
        {
            ServiceLayerSync ServiceLayerData = new ServiceLayerSync();
            POS4 oInvDocument = new POS4();
            oInvDocument.ParentId = ParentId;
            oInvDocument.SaleId = SaleId;
            oInvDocument.IRN = IrnData;
            oInvDocument.SignedQRCode = SignQRCodeData;
            oInvDocument.AckNo = AckNos;
            oInvDocument.CreatedDate = System.DateTime.Now;
            oInvDocument.Status = Status;
            if (AckDts != null)
            {
                AckDts = AckDts.Remove(10);
                string dt2 = AckDts.Substring(AckDts.Length - 2) + "/" + AckDts.Substring(AckDts.Length - 5, AckDts.Length - 8) + "/" + AckDts.Substring(0, 4);
                DateTime todaysDt = DateTime.ParseExact(dt2, "dd/MM/yyyy", CultureInfo.InvariantCulture);
                oInvDocument.AckDate = todaysDt;
            }
            else
            {
                oInvDocument.AckDate = null;
            }
            oInvDocument.ErrorDetails = ErrorMsg;
            ctx.POS4.Add(oInvDocument);
            OPOS ObjPOs = ctx.OPOS.Where(x => x.ParentID == ParentId && x.SaleID == SaleId).FirstOrDefault();
            if (ObjPOs != null)
            {
                ObjPOs.EInvoiceStatus = Status;
            }
            ctx.SaveChanges();
            return result;
        }
        catch (Exception e)
        {
            result.Add(2, "Error due to:" + e);
            return result;
        }
    }
}
