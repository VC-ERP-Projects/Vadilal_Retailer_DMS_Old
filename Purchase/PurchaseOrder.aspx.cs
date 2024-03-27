﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Threading;
using System.Web;
using System.Web.Hosting;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using WebReference;

public partial class Purchase_PurchaseOrder : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    private List<ItemData> BindList
    {
        get { return this.Session["MID1s"] as List<ItemData>; }
        set { this.Session["MID1s"] = value; }
    }

    private List<NewItemData> NewList
    {
        get { return this.Session["NewItemDatas"] as List<NewItemData>; }
        set { this.Session["NewItemDatas"] = value; }
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

    private static void SendPurchaseinSAP(Int32 InwardID, Decimal ParentID, Int32 DivisionID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {


                OCFG objOCFG = ctx.OCFGs.FirstOrDefault();
                if (objOCFG != null)
                {
                    OMID objOMID = ctx.OMIDs.Include("MID1").FirstOrDefault(x => x.InwardID == InwardID && x.ParentID == ParentID);
                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);

                    if (objOMID != null && objOMID.InProcess.GetValueOrDefault(false) == false)
                    {
                        //objOMID.InProcess = true;
                        //ctx.SaveChanges();
                        if (ctx.OGCRDs.Any(x => x.SaleOrgID.HasValue && x.CustomerID == ParentID)
                            && ctx.OGCRDs.Any(x => x.PlantID.HasValue && x.DivisionlID == DivisionID && x.CustomerID == ParentID))
                        {

                            OPLT objOPLT = ctx.OGCRDs.FirstOrDefault(x => x.PlantID.HasValue && x.DivisionlID == DivisionID && x.CustomerID == ParentID).OPLT;
                            objOMID.PlantID = objOPLT.PlantID;
                            ctx.SaveChanges();
                            //#region Indent Order

                            //try
                            //{
                            //    DT_IndentCreation_Response Response = new DT_IndentCreation_Response();
                            //    SI_SynchOut_IndentCreationService _proxy = new SI_SynchOut_IndentCreationService();
                            //    _proxy.Url = objOCFG.SAPLINK;
                            //    _proxy.Timeout = 3000000;
                            //    _proxy.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);

                            //    DT_IndentCreation_Request Request = new DT_IndentCreation_Request();
                            //    DT_IndentCreation_RequestItem[] D4 = new DT_IndentCreation_RequestItem[1];
                            //    DT_IndentCreation_RequestItem1[] D5 = new DT_IndentCreation_RequestItem1[objOMID.MID1.Count];

                            //    Request = new DT_IndentCreation_Request();
                            //    D4 = new DT_IndentCreation_RequestItem[1];

                            //    int j = 0;
                            //    D4[j] = new DT_IndentCreation_RequestItem();
                            //    D4[j].DistributionChannel = "11";
                            //    D4[j].Division = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == DivisionID).DivisionCode;
                            //    D4[j].DocumentType = "ZORD";
                            //    D4[j].SalesOrganization = ctx.OGCRDs.FirstOrDefault(x => x.SaleOrgID.HasValue && x.DivisionlID == DivisionID && x.PlantID == objOPLT.PlantID && x.CustomerID == ParentID).OSRG.SaleOrgCode;
                            //    D4[j].ShipToParty = objOCRD.CustomerCode;
                            //    D4[j].SoldToParty = objOCRD.CustomerCode;
                            //    D4[j].TransactionType = "A";
                            //    D4[j].Plant = objOPLT.PlantCode;
                            //    D4[j].DMS_REFNO = objOMID.InwardID.ToString();
                            //    int i = 0;
                            //    D5 = new DT_IndentCreation_RequestItem1[objOMID.MID1.Count];
                            //    foreach (MID1 obj in objOMID.MID1)
                            //    {
                            //        if (i > objOMID.MID1.Count)
                            //        {
                            //            break;
                            //        }
                            //        D5[i] = new DT_IndentCreation_RequestItem1();
                            //        D5[i].MaterialNumber = ctx.OITMs.FirstOrDefault(x => x.ItemID == obj.ItemID).ItemCode;
                            //        D5[i].Quantity = obj.RequestQty.ToString("0.000");
                            //        i = i + 1;
                            //    }
                            //    Request.REPEAT_FLAG = "";
                            //    Request.IT_HEADER = D4;
                            //    Request.IT_ITEM = D5;
                            //    Response = _proxy.SI_SynchOut_IndentCreation(Request);
                            //    objOMID.Ref1 = Response.MESSAGE;
                            //    objOMID.Ref2 = Response.FLAG;
                            //    objOMID.Ref3 = Response.NUMBER_INDENT;
                            //    objOMID.Ref4 = Response.STATUS;
                            //    objOMID.UpdatedDate = DateTime.Now;
                            //    objOMID.InProcess = false;
                            //    ctx.SaveChanges();
                            //}
                            //catch (Exception ex)
                            //{
                            //    objOMID.Ref1 = Common.GetString(ex);
                            //    objOMID.Ref2 = "ERROR";
                            //    objOMID.UpdatedDate = DateTime.Now;
                            //    objOMID.InProcess = false;
                            //    ctx.SaveChanges();
                            //}

                            //#endregion

                            #region Customer EMail

                            try
                            {
                                if (!string.IsNullOrEmpty(objOCRD.Phone))
                                {
                                    string Message = "Dear+Customer+Purchase Order+" + objOMID.InvoiceNumber + "+Dt.+" + Common.DateTimeConvert(objOMID.Date) + "+at+" + objOMID.Date.ToString("hh:mm tt")
                                                    + "+Qty+:+" + objOMID.MID1.Sum(x => x.TotalQty).ToString("0") + "+Rs.+" + objOMID.Total.Value.ToString("0.00") + "+generated+for+"
                                                    + objOCRD.CustomerCode + ",+" + objOCRD.CustomerName + ",+" + objOCRD.CRD1.FirstOrDefault().OCTY.CityName;

                                    Service wb = new Service();
                                    wb.SendSMS(objOCRD.Phone, Message);
                                }
                                if (!string.IsNullOrEmpty(objOCRD.EMail1))
                                {
                                    try
                                    {
                                        string ccEmail = "";
                                        if (objOCRD.Email2 != "")
                                        {
                                            ccEmail = objOCRD.Email2 + ";";
                                        }
                                        if (objOCRD.Email3 != "")
                                        {
                                            ccEmail += objOCRD.Email3 + ";";
                                        }
                                        if (objOCRD.Email4 != "")
                                        {
                                            ccEmail += objOCRD.Email4;
                                        }
                                        var Message = Common.GetMailBodyPurchase(InwardID, ParentID);
                                        Common.SendMail("Vadilal - Purchase Order", Message, objOCRD.EMail1, ccEmail.TrimEnd(';'), null, null);
                                    }
                                    catch (Exception)
                                    {

                                    }
                                }
                            }
                            catch (Exception)
                            {

                            }

                            #endregion

                            #region Company Email

                            try
                            {
                                EML2 objEML2 = ctx.EML2.FirstOrDefault(x => x.PlantID == objOPLT.PlantID && x.DocType == "P");
                                if (objEML2 != null)
                                {
                                    string DivisionName = "";
                                    if (DivisionID == 11)
                                    {
                                        DivisionName = "I/c";
                                    }
                                    else if (DivisionID == 13)
                                    {
                                        DivisionName = "D/p";
                                    }
                                    try
                                    {
                                        var Message = Common.GetMailBodyPurchase(InwardID, ParentID);
                                        var FileName = HostingEnvironment.MapPath("~/Document/POExport/") + Guid.NewGuid().ToString("N") + ".csv";
                                        Common.GetExcelBody(FileName, objOMID.InwardID, objOMID.ParentID);

                                        List<Attachment> Attchs = new List<Attachment>();
                                        var at = new Attachment(FileName);
                                        at.Name = objOCRD.CustomerCode + "_" + objOMID.InvoiceNumber + "_" + objOMID.InwardID + ".csv";
                                        Attchs.Add(at);
                                        // Common.SendMail("Vadilal-" + DivisionName + " PO -" + objOCRD.CustomerCode, Message, objEML2.FailureEmail, "", null, Attchs);
                                        Common.SendMail("Vadilal-" + DivisionName + " PO -" + objOCRD.CustomerCode + "-" + (objOCRD.CustomerName.Length > 40 ? objOCRD.CustomerName.Substring(0, 40) : objOCRD.CustomerName), Message, objEML2.FailureEmail, "", null, Attchs);
                                    }
                                    catch (Exception)
                                    {

                                    }

                                }
                            }
                            catch (Exception)
                            {

                            }
                            #endregion
                        }
                        else
                        {
                            objOMID.Ref1 = "Plant or SaleOrg not map";
                            objOMID.Ref2 = "ERROR";
                            objOMID.UpdatedDate = DateTime.Now;
                            objOMID.InProcess = false;
                            ctx.SaveChanges();
                        }
                    }
                    else
                    {
                        objOMID.Ref1 = "Please wait for sometime your order is in InProcess.";
                        objOMID.Ref2 = "ERROR";
                        objOMID.UpdatedDate = DateTime.Now;
                        ctx.SaveChanges();
                    }
                }
            }
        }
        catch (Exception)
        {

        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                decimal ParentCustID = Convert.ToDecimal(HttpContext.Current.Session["OutletPID"]);

                txtVendor.Value = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentCustID).CustomerName;

                if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "P" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
                {
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Purchase. !',3);", true);
                    //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                    return;
                }
            }
            BindList = new List<ItemData>();
            BindList.Add(new ItemData());
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
                    result.Add("ERROR#" + "Beat not available for you, so you can not create Purchase Order. Contact to your Local Sales Staff!");
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
                    var lstDivision = ctx.ODIVs.Where(x => x.Active &&
                        ctx.OGCRDs.Any(y => y.PlantID.HasValue && y.PriceListID.HasValue && y.DivisionlID == x.DivisionlID && y.CustomerID == ParentID)).Select(x =>
                        new
                        {
                            DivisionlID = SqlFunctions.StringConvert((double)x.DivisionlID).Trim(),
                            DivisionName = x.DivisionName + " # " + ctx.OGCRDs.FirstOrDefault(y => y.PlantID.HasValue && y.DivisionlID == x.DivisionlID && y.CustomerID == ParentID).OPLT.PlantName
                            + " # " + ctx.OGCRDs.FirstOrDefault(y => y.PlantID.HasValue && y.DivisionlID == x.DivisionlID && y.CustomerID == ParentID).OPLT.PlantCode
                        }).ToList();

                    var WareHouse = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).Select(x => new { Value = SqlFunctions.StringConvert((double)x.WhsID), Name = x.WhsName }).OrderBy(x => x.Value).ToList();
                    var Vehicle = ctx.OVCLs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.VehicleID, 20, 0).Trim() + " - " + x.VehicleNumber).ToList();
                    var Template = ctx.OTMPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => SqlFunctions.StringConvert((Decimal)x.TemplateID, 20, 0).Trim() + " - " + x.TemplateName).ToList();

                    result.Add("0");
                    result.Add(lstDivision);
                    result.Add(WareHouse);
                    result.Add(Vehicle);
                    result.Add(Template);
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
    public static List<dynamic> LoadItems(int DivisionID, int WhsID)
    {
        List<dynamic> result = new List<dynamic>();
        List<PurchaseItem_Result> Data = new List<PurchaseItem_Result>();
        List<DisData2> units = new List<DisData2>();
        List<ItemData> tmpList = new List<ItemData>();
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {

                Data = ctx.GetTopItems(DivisionID, ParentID, WhsID).ToList();
                if (Data.Count > 0)
                {
                    units = Data.Select(x => new DisData2 { Text = x.Unitname, Value = x.UnitID.ToString() + "," + x.UnitPrice.ToString() + "," + x.Tax.ToString() + "," + x.Quantity.ToString() }).ToList();

                    result.Add(units);

                    tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                               select new ItemData
                               {
                                   ItemID = x.Key.ItemID,
                                   ItemCode = x.Key.ItemCode,
                                   ItemName = x.Key.ItemName,
                                   AvailQty = x.Key.AvailQty,
                                   TaxID = x.Key.TaxID
                               }).ToList();

                    result.Add(tmpList);
                }
                else
                    result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
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
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);

                int PlantID = ctx.OGCRDs.FirstOrDefault(y => y.PlantID.HasValue && y.DivisionlID == DivisionID && y.CustomerID == ParentID).PlantID.Value;

                if (ctx.PSP3.Any(x => x.CustomerID == ParentID))
                {
                    var items = ctx.OITMs.Where(x => x.Active && (x.OGITMs.Any(s => s.DivisionlID == DivisionID && s.PlantID == PlantID && s.Active))).Select(x => x.ItemCode + " - " + x.ItemName).ToList();

                    result.Add(items);
                }
                else
                {


                    //var items = (from c in ctx.OITMs
                    //             join d in ctx.ITM2 on c.ItemID equals d.ItemID
                    //             join s in ctx.OGITMs on c.ItemID equals s.ItemID
                    //             where (c.Active && s.Active && s.DivisionlID == DivisionID && s.PlantID == PlantID
                    //             && (!ctx.PSP1.Any(z => z.SpecialItemID == c.ItemID && z.OPSPID != 3)) && d.ParentID == ParentID)
                    //             select (c.ItemCode + " - " + c.ItemName + " - " + SqlFunctions.StringConvert((double)d.TotalPacket))).ToList();


                    // (x => x.Active && (x.OGITMs.Any(s => s.DivisionlID == DivisionID && s.PlantID == PlantID && s.Active)) &&
                    //(!ctx.PSP1.Any(z => z.SpecialItemID == x.ItemID && z.OPSPID != 3))).Select(x => x.ItemCode + " - " + x.ItemName).ToList();

                    var items = ctx.OITMs.Where(x => x.Active && (x.OGITMs.Any(s => s.DivisionlID == DivisionID && s.PlantID == PlantID && s.Active)) &&
                      (!ctx.PSP1.Any(z => z.SpecialItemID == x.ItemID && z.OPSPID != 3))).Select(x => x.ItemCode + " - " + x.ItemName).ToList();

                    result.Add(items);

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
                        if (!ctx.ITM5.Any(x => x.SaleItemID == ItemID && x.IsActive == true))
                        {
                            var ItemData = ctx.OGITMs.Where(x => x.ItemID == ItemID && x.DivisionlID.HasValue && x.PlantID.HasValue && x.Active).Select(x => new { PlantID = x.PlantID.Value, DivisionID = x.DivisionlID.Value }).ToList();
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
                                        result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
                                }
                                else
                                    result.Add("ERROR=" + "" + "This material is not extended in your plant, Please contact Marketing Department to resolve this issue");
                            }
                            else
                                result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
                        }
                        else
                        {
                            int pitmid = ctx.ITM5.FirstOrDefault(x => x.SaleItemID == ItemID && x.IsActive == true).PurchaseItemID;

                            result.Add("ERROR=" + "" + "You can not select this Pcs Product Code, Please select the item code : " + ctx.OITMs.Where(x => x.ItemID == pitmid).Select(x => x.ItemCode + " # " + x.ItemName).FirstOrDefault());
                        }
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

        //List<dynamic> result = new List<dynamic>();
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                decimal ParentCustID = Convert.ToDecimal(HttpContext.Current.Session["OutletPID"]);
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
                //string Vehicle = Convert.ToString(HeaderData["Vehicle"]);
                string Discount = Convert.ToString(HeaderData["Discount"]);
                string paidTo = Convert.ToString(HeaderData["paidTo"]);
                string Division = Convert.ToString(HeaderData["Division"]);
                List<ItemData> BindList = new List<ItemData>();

                foreach (var scheme in SchemeData)
                {
                    ItemData item = new ItemData();
                    item.ItemID = scheme["ItemID"];
                    item.ItemCode = scheme["ItemCode"];
                    item.Quantity = scheme["txtReciept"];
                    item.TotalQty = scheme["TotalQty"];
                    item.SubTotal = scheme["SubTotal"];
                    item.Tax = scheme["Tax"];
                    item.Total = scheme["Total"];
                    item.MainID = scheme["MainID"];
                    if (scheme["Price"] == "")
                    {
                        scheme["Price"] = 0;
                    }
                    item.Price = scheme["Price"];
                    item.UnitID = scheme["UnitID"];
                    if (scheme["UnitPrice"] == "")
                    {
                        scheme["UnitPrice"] = 0;
                    }
                    item.UnitPrice = scheme["UnitPrice"];
                    if (scheme["PriceTax"] == "")
                    {
                        scheme["PriceTax"] = 0;
                    }
                    item.PriceTax = scheme["PriceTax"];
                    if (scheme["MapQuantity"] == "")
                    {
                        scheme["MapQuantity"] = 0;
                    }
                    item.MapQty = scheme["MapQuantity"];
                    if (scheme["TaxID"] == "")
                    {
                        scheme["TaxID"] = 0;
                    }
                    item.TaxID = scheme["TaxID"];
                    item.AvailQty = scheme["AvlQty"];
                    BindList.Add(item);

                }

                #region Check Purchase Special Items

                if (ctx.PSP3.Any(x => x.CustomerID == ParentID))
                {
                    List<Int32> OPSPIDs = ctx.PSP3.Where(x => x.CustomerID == ParentID).Select(x => x.OPSPID).ToList();

                    foreach (var OPSPID in OPSPIDs)
                    {
                        if (BindList.Any(x => ctx.PSP1.Where(y => y.OPSPID == OPSPID).Select(y => y.SpecialItemID).ToList().Contains(x.ItemID)))
                        {
                            if (BindList.Any(x => ctx.PSP2.Where(y => y.OPSPID == OPSPID).Select(y => y.ItemID).ToList().Contains(x.ItemID)))
                            {
                                Decimal SpecialItemTotal = 0;
                                Decimal RegularItemTotal = 0;

                                SpecialItemTotal = BindList.Where(x => ctx.PSP1.Where(y => y.OPSPID == OPSPID).Select(y => y.SpecialItemID).ToList().Contains(x.ItemID)).Sum(x => x.SubTotal);
                                RegularItemTotal = BindList.Where(x => ctx.PSP2.Where(y => y.OPSPID == OPSPID).Select(y => y.ItemID).ToList().Contains(x.ItemID)).Sum(x => x.SubTotal);

                                if (RegularItemTotal < SpecialItemTotal)
                                {
                                    return "ERROR=Sub Material order value is lesser than main material vaule. Please contact DMS Team only. Special Product Total Gross Amount : " + Convert.ToString(SpecialItemTotal) + " & Routine Product Total Gross Amount :" + Convert.ToString(RegularItemTotal);
                                }
                            }
                            else
                            {
                                return "ERROR=Regular Items with special item were not found.";
                            }
                        }
                    }
                }

                #endregion

                Int32 WhsID = 0;
                if (!Int32.TryParse(ddlWhs, out WhsID))
                {
                    return "ERROR=Select Warehouse.";
                }
                if (BindList.Count == 0)
                {
                    return "ERROR=Select Atleast one item.";
                }
                OMID objOMID = null;

                objOMID = new OMID();
                objOMID.InwardID = ctx.GetKey("OMID", "InwardID", "", ParentID, 0).FirstOrDefault().Value;
                var date = Common.DateTimeConvert(Date);
                OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "P" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();

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
                objOMID.InwardType = 1;
                objOMID.VendorID = 1;
                objOMID.VendorParentID = ParentCustID;
                objOMID.Date = Common.DateTimeConvert(Date).Add(DateTime.Now.TimeOfDay);
                objOMID.Status = "O";
                objOMID.ToWhsID = WhsID;
                objOMID.CreatedDate = DateTime.Now;
                objOMID.CreatedBy = UserID;
                objOMID.UpdatedDate = DateTime.Now;
                objOMID.UpdatedBy = UserID;
                objOMID.Status = "O";
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
                        objMID1.TaxID = item.TaxID;
                        objMID1.UnitID = item.UnitID;
                        objMID1.PriceTax = item.PriceTax;
                        objMID1.MapQty = item.MapQty;
                        objMID1.UnitPrice = item.Price;
                        objMID1.Price = item.Price;
                        objMID1.AvailableQty = item.AvailQty;
                        objMID1.RequestQty = item.Quantity;
                        objMID1.DisptchQty = 0;
                        objMID1.DiffirenceQty = 0;
                        objMID1.TotalQty = item.Quantity;
                        objMID1.RecieptQty = 0;
                        objMID1.SubTotal = item.SubTotal;
                        objMID1.Tax = item.Tax;
                        objMID1.Total = item.Total;
                    }
                }

                if (objOMID.MID1.Count == 0)
                {
                    return "ERROR=Something went wrong please refresh page and try again!";
                }
                ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                int HdocID = ctx.AddHierarchyType_NEW("PO", objOMID.ParentID, ParentID, objOMID.InwardID, str).FirstOrDefault().GetValueOrDefault(0);
                if (str.Value.ToString() == "0" || HdocID == 0)
                {
                    return "ERROR=Beat Not Available So, you can not do PO Entry. Contact to your Local  Sales Staff!";
                }
                objOMID.HDocID = HdocID;
                ctx.SaveChanges();

                if (ParentCustID == 1000010000000000)
                {
                    Int32 InwardID = objOMID.InwardID;
                    Decimal CParentID = objOMID.ParentID;
                    Int32 DivisionID = Convert.ToInt32(Division);

                    Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

                    Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); SendPurchaseinSAP(InwardID, CParentID, DivisionID); });
                    t.Name = Guid.NewGuid().ToString();
                    t.Start();
                }

                return "SUCCESS=Order Inserted Successfully: Order Number # " + objOMID.InvoiceNumber.ToString();


            }
        }
        catch (Exception ex)
        {
            return "ERROR=Something is worng: " + Common.GetString(ex);
        }
    }

    [WebMethod(EnableSession = true)]
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


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadItemsOnDemand(int DivisionID, int WhsID, int OptionId)
    {
        List<dynamic> result = new List<dynamic>();
        List<PurchaseItem_Result> Data = new List<PurchaseItem_Result>();
        List<DisData2> units = new List<DisData2>();
        List<ItemData> tmpList = new List<ItemData>();
        try
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetLoadItemsONDemand";
                Cm.Parameters.AddWithValue("@DivisionID", DivisionID);
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
                Cm.Parameters.AddWithValue("@WhsID", WhsID);
                Cm.Parameters.AddWithValue("@OptionId", OptionId);

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataTable dt = ds.Tables[0];
                    
                    Data = (from DataRow dr in dt.Rows
                                   select new PurchaseItem_Result()
                                   {
                                       ItemID = Convert.ToInt32(dr["ItemID"]),
                                       ItemCode  = dr["ItemCode"].ToString(),
                                       ItemName = dr["ItemName"].ToString(),
                                       AvailQty = Convert.ToInt32(dr["AvailQty"]),
                                       DispatchQty = Convert.ToInt32(dr["DispatchQty"]),
                                       UnitID = Convert.ToInt32(dr["UnitID"]),
                                       Unitname = dr["Unitname"].ToString(),
                                       Quantity = Convert.ToInt32(dr["Quantity"]),
                                       UnitPrice = Convert.ToInt32(dr["UnitPrice"]),
                                       Tax = Convert.ToInt32(dr["Tax"]),
                                       TaxID = Convert.ToInt32(dr["TaxID"]),
                                       RANKNO = dr["RANKNO"].ToString()
                                   }).ToList();

                    //  Data = ctx.GetLoadItemsONDemand(DivisionID, ParentID, WhsID, OptionId).ToList();
                    if (Data.Count > 0)
                    {
                        units = Data.Select(x => new DisData2 { Text = x.Unitname, Value = x.UnitID.ToString() + "," + x.UnitPrice.ToString() + "," + x.Tax.ToString() + "," + x.Quantity.ToString() }).ToList();

                        result.Add(units);

                        tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                   select new ItemData
                                   {
                                       ItemID = x.Key.ItemID,
                                       ItemCode = x.Key.ItemCode,
                                       ItemName = x.Key.ItemName,
                                       AvailQty = x.Key.AvailQty,
                                       TaxID = x.Key.TaxID
                                   }).ToList();

                        result.Add(tmpList);
                    }
                    else
                        result.Add("ERROR=" + "" + "Distributor Pricing Group Not Assign, Contact To Mktg Team Only");
                }
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }
        return result;
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
    protected void btnSaveData_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            bool flag = true;
            List<PurchaseItem_Result> Data = new List<PurchaseItem_Result>();
            List<DisData2> units = new List<DisData2>();
            int WhsID = 0;
            if (flCUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                flCUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }


                    if (flag)
                    {
                        try
                        {
                            using (DDMSEntities ctx = new DDMSEntities())
                            {
                                foreach (DataRow item in dtPOH.Rows)
                                {
                                    String ItemCode = item["ItemCode"].ToString().Trim();
                                    Int32 OrderQty = Int32.TryParse(item["OrderQty"].ToString().Trim(), out OrderQty) ? OrderQty : 0;
                                    decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
                                    int ItemID = ctx.OITMs.Where(x => x.ItemCode == ItemCode && x.Active).Select(x => x.ItemID).DefaultIfEmpty(0).FirstOrDefault();
                                    if (ItemID > 0)
                                    {
                                        if (!ctx.ITM5.Any(x => x.SaleItemID == ItemID && x.IsActive == true))
                                        {
                                            var ItemData = ctx.OGITMs.Where(x => x.ItemID == ItemID && x.DivisionlID.HasValue && x.PlantID.HasValue && x.Active).Select(x => new { PlantID = x.PlantID.Value, DivisionID = x.DivisionlID.Value }).ToList();
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

                                                        ItemData tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                                            select new ItemData
                                                                            {
                                                                                ItemID = x.Key.ItemID,
                                                                                ItemCode = x.Key.ItemCode,
                                                                                ItemName = x.Key.ItemName,
                                                                                AvailQty = x.Key.AvailQty,
                                                                                TaxID = x.Key.TaxID
                                                                            }).FirstOrDefault();

                                                     //   result.Add(tmpList);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch (DbEntityValidationException ex)
                        {
                            var error = ex.EntityValidationErrors.First().ValidationErrors.First();
                            if (error != null)
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
                            else
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                            return;
                        }
                    }
                    else
                    {

                    }
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    #endregion
}