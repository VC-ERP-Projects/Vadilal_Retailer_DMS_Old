using AjaxControlToolkit;
using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.EntityClient;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Threading;
using System.Transactions;
using System.Web;
using System.Web.Hosting;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_SalesReturn : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    bool printInvoice = false;
    private List<DisData> ORSNs
    {
        get { return this.ViewState["DisData"] as List<DisData>; }
        set { this.ViewState["DisData"] = value; }
    }

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

    public void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "SR" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
            {
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Sales return. !',3);", true);
                //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                return;
            }

            txtDate.Text = Common.DateTimeConvert(DateTime.Now);
            var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(txtDate.Text), ParentID).FirstOrDefault();
            if (!String.IsNullOrEmpty(DayCloseData))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
                btnSubmit.Visible = false;
                return;
            }
            else
            {
                btnSubmit.Visible = true;
            }
            txtItem.Text = txtBill.Text = txtCustomer.Text = txtNotes.Text = txtRounding.Text = txtSearch.Text = txtSubTotal.Text = txtTax.Text = txtScheme.Text = lblBillToPartyCode.Value = txtTotal.Text = "";
            acetxtCustomer.ContextKey = ParentID.ToString();

            var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
            ddlWhs.DataSource = Data;
            ddlWhs.DataBind();

            gvItem.DataSource = null;
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

            ORSNs = ctx.ORSNs.Where(x => x.Active && new List<String> { "X", "R" }.Contains(x.Type)).Select(x => new DisData { Text = x.ReasonName, Value = x.ReasonID }).ToList();
            ddlReason.DataSource = ORSNs;
            ddlReason.DataBind();
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Sales.aspx");
    }

    private static void SendMailReturn(Int32 ORETID, Decimal ParentID, string Email)
    {
        try
        {
            var Message = Common.GetMailBodyPurchaseReturn(ORETID, ParentID);
            Common.SendMail("Vadilal - Purchase Return Entry", Message, Email, "", null, null);
        }
        catch (Exception)
        {

        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            var text = txtBill.Text.Split("-".ToArray());
            Int32 ReasonID = Int32.TryParse(ddlReason.SelectedValue, out ReasonID) ? ReasonID : 0;
            if (text.Length > 1)
            {
                int SaleID = 0;
                if (Int32.TryParse(text.Last(), out SaleID) && SaleID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        var objOPOS = ctx.OPOS.FirstOrDefault(x => x.ParentID == ParentID && x.SaleID == SaleID);
                        if (objOPOS != null)
                        {
                            Int32 IntNum = 0;
                            Decimal DecNum = 0;
                            var CDate = Common.DateTimeConvert(txtDate.Text);

                            ORET objORET = new ORET();
                            objORET.ORETID = ctx.GetKey("ORET", "ORETID", "", ParentID, 0).FirstOrDefault().Value;
                            objORET.ParentID = ParentID;
                            objORET.Type = ((int)ReturnType.SaleReturnAgainBill).ToString();
                            objORET.CustomerID = objOPOS.CustomerID;
                            objORET.BillRefNo = objOPOS.SaleID.ToString();
                            objORET.BillToCustomerID = objOPOS.BillToCustomerID;
                            OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "SR" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(CDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(CDate)).FirstOrDefault();

                            if (objOSEQ != null)
                            {
                                objOSEQ.RorderNo++;
                                objORET.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found. !',3);", true);
                                return;

                            }
                            objORET.Notes = txtNotes.Text;
                            objORET.SubTotal = Decimal.TryParse(txtSubTotal.Text, out DecNum) ? DecNum : 0;
                            objORET.Tax = Decimal.TryParse(txtTax.Text, out DecNum) ? DecNum : 0;
                            objORET.Rounding = Decimal.TryParse(txtRounding.Text, out DecNum) ? DecNum : 0;
                            objORET.Amount = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                            objORET.WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
                            objORET.Date = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
                            objORET.CreatedBy = UserID;
                            objORET.CreatedDate = DateTime.Now;
                            objORET.UpdatedBy = UserID;
                            objORET.SchemeAmount = Decimal.TryParse(txtScheme.Text, out DecNum) ? DecNum : 0;
                            objORET.UpdatedDate = DateTime.Now;
                            ctx.ORETs.Add(objORET);

                            int Count = ctx.GetKey("RET1", "RET1ID", "", ParentID, null).FirstOrDefault().Value;
                            int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;
                            int ItemID = 0;

                            bool returnflag = false;
                            if (ctx.POS3.Count(x => x.SaleID == objOPOS.SaleID && x.ParentID == ParentID && x.Mode == "V" && x.EffectOnBill) > 0)
                            {
                                returnflag = true;
                            }

                            foreach (GridViewRow item in gvItem.Rows)
                            {
                                Label lblItemID = (Label)item.FindControl("lblItemID");
                                TextBox txtEnterQty = item.FindControl("txtEnterQty") as TextBox;
                                TextBox txtAvailQty = item.FindControl("txtAvailQty") as TextBox;

                                if (returnflag && Convert.ToDecimal(txtAvailQty.Text) > Convert.ToDecimal(txtEnterQty.Text))
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Partly quantity should not be return !',3);", true);
                                    return;
                                }

                                if (ctx.ORETs.Any(x => x.ParentID == ParentID && x.CustomerID == objORET.CustomerID.Value && x.SubTotal == objORET.SubTotal && x.Tax == objORET.Tax
                   && x.Date.Year == objORET.Date.Year && x.Date.Month == objORET.Date.Month && x.Date.Day == objORET.Date.Day && SqlFunctions.DateDiff("minute", x.Date, objORET.Date) <= 60))
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not return same dealer bill with same amount in a 1 hour., so please try after one hour !',3);", true);
                                    return;
                                }

                                string StrSaleID = objOPOS.SaleID.ToString();
                                if (lblItemID != null && Int32.TryParse(lblItemID.Text, out ItemID) && ItemID > 0 && Decimal.TryParse(txtEnterQty.Text, out DecNum) && DecNum > 0)
                                {
                                    Label lblUnitID = item.FindControl("lblUnitID") as Label;
                                    Label lblTaxID = item.FindControl("lblTaxID") as Label;
                                    Label lblSchemeID = item.FindControl("lblSchemeID") as Label;

                                    TextBox lblPrice = item.FindControl("lblPrice") as TextBox;


                                    TextBox txtTotalQty = item.FindControl("txtTotalQty") as TextBox;

                                    HtmlInputHidden hdnItemScheme = item.FindControl("hdnItemScheme") as HtmlInputHidden;
                                    HtmlInputHidden hdnScheme = item.FindControl("hdnScheme") as HtmlInputHidden;

                                    HtmlInputHidden hdnSubTotal = item.FindControl("hdnSubTotal") as HtmlInputHidden;
                                    HtmlInputHidden hdnTax = item.FindControl("hdnTax") as HtmlInputHidden;

                                    TextBox lblTotalPrice = item.FindControl("lblTotalPrice") as TextBox;

                                    var Data = lblUnitID.Text.Split(",".ToArray());

                                    var OldORETIds = ctx.ORETs.Where(x => x.BillRefNo == StrSaleID && x.CustomerID == objOPOS.CustomerID).Select(x => new { RetID = x.ORETID }).ToList();

                                    if (OldORETIds != null && OldORETIds.Count > 0)
                                    {
                                        List<int> ListRetIDs = new List<int>();

                                        foreach (var x in OldORETIds)
                                            ListRetIDs.Add(x.RetID);
                                        Decimal qtySum = 0;
                                        if (ctx.RET1.Any(x => ListRetIDs.Contains(x.ORETID) && x.ParentID == ParentID && x.ItemID == ItemID))
                                            qtySum = ctx.RET1.Where(x => ListRetIDs.Contains(x.ORETID) && x.ParentID == ParentID && x.ItemID == ItemID).Sum(x => x.TotalQty);

                                        Decimal TotalQtySaled = objOPOS.POS1.Where(x => x.ItemID == ItemID).Select(x => new { x.TotalQty }).FirstOrDefault().TotalQty;
                                        Decimal TotalQtyItem = Decimal.TryParse(txtTotalQty.Text, out TotalQtyItem) ? TotalQtyItem : 0;
                                        if ((qtySum + TotalQtyItem) > TotalQtySaled)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Return qty must not greater than total number of items is returned yet. !',3);", true);
                                            return;
                                        }
                                    }

                                    RET1 objRET1 = new RET1();
                                    objRET1.RET1ID = Count++;
                                    objRET1.ItemID = ItemID;
                                    objRET1.UnitID = Int32.TryParse(Data[0], out IntNum) ? IntNum : 0;

                                    objRET1.Quantity = DecNum;
                                    objRET1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;

                                    objRET1.UnitPrice = Decimal.TryParse(Data[1], out DecNum) ? DecNum : 0;
                                    objRET1.PriceTax = Decimal.TryParse(Data[2], out DecNum) ? DecNum : 0;
                                    objRET1.Price = Decimal.TryParse(lblPrice.Text, out DecNum) ? DecNum : 0;
                                    objRET1.MapQty = Decimal.TryParse(Data[3], out DecNum) ? DecNum : 0;

                                    objRET1.ItemScheme = Decimal.TryParse(hdnItemScheme.Value, out DecNum) ? DecNum : 0;
                                    objRET1.Scheme = Decimal.TryParse(hdnScheme.Value, out DecNum) ? DecNum : 0;

                                    objRET1.Subtotal = Decimal.TryParse(hdnSubTotal.Value, out DecNum) ? DecNum : 0;
                                    objRET1.Tax = Decimal.TryParse(hdnTax.Value, out DecNum) ? DecNum : 0;
                                    objRET1.Total = objRET1.Subtotal + objRET1.Tax;

                                    objRET1.ReasonID = Int32.TryParse(ddlReason.SelectedValue, out IntNum) ? IntNum : 0;
                                    objRET1.TaxID = Int32.TryParse(lblTaxID.Text, out IntNum) ? IntNum : 0;

                                    if (lblSchemeID.Text != "0")
                                        objRET1.SchemeID = Int32.TryParse(lblSchemeID.Text, out IntNum) ? IntNum : 0;

                                    objORET.RET1.Add(objRET1);


                                    // Item Wise Discount Deducation as per new Table Discount Type wise Bifurgation  23-Feb-23 Ticket #T900015915

                                    List<OIDM> ObjODI = ctx.OIDMs.Where(x => x.ParentId == ParentID && x.SaleId == objOPOS.SaleID && x.ItemId == ItemID).ToList();
                                    if (ObjODI != null)
                                    {
                                        foreach (OIDM Retitm in ObjODI)
                                        {
                                            OIDMRET objOIDM = new OIDMRET();
                                            objOIDM.ParentId = ParentID;
                                            objOIDM.ItemId = ItemID;
                                            int qty = int.TryParse(txtTotalQty.Text, out qty) ? qty : 0;
                                            objOIDM.Qty = Convert.ToInt32(qty) * (-1);
                                            objOIDM.InvoiceDate = DateTime.Now;
                                            objOIDM.SchemeMode = Retitm.SchemeMode;
                                            objOIDM.SchemeId = Retitm.SchemeId;
                                            objOIDM.CompanyContri = ((Retitm.CompanyContri / Retitm.Qty) * qty) * (-1);
                                            objOIDM.DistributorContri = ((Retitm.DistributorContri / Retitm.Qty) * qty) * (-1);
                                            objOIDM.TotalDiscount = ((Retitm.TotalDiscount / Retitm.Qty) * qty) * (-1);
                                            objORET.OIDMRETs.Add(objOIDM);
                                        }
                                    }
                                    //

                                    ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == ItemID && x.WhsID == objORET.WhsID && x.ParentID == ParentID);
                                    if (objITM2 == null)
                                    {
                                        objITM2 = new ITM2();
                                        objITM2.StockID = CountM++;
                                        objITM2.ParentID = ParentID;
                                        objITM2.WhsID = objORET.WhsID;
                                        objITM2.ItemID = ItemID;
                                        ctx.ITM2.Add(objITM2);
                                    }
                                    objITM2.TotalPacket += objRET1.TotalQty;
                                }
                            }

                            if (ReasonID > 0 && (ctx.ORSNs.Any(x => x.ReasonID == ReasonID && x.Type == "X")))
                            {
                                OMIT objOMIT = new OMIT();
                                objOMIT.OMITID = ctx.GetKey("OMIT", "OMITID", "", ParentID, 0).FirstOrDefault().Value;
                                OSEQ objWOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "W" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(CDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(CDate)).FirstOrDefault();

                                if (objWOSEQ != null)
                                {
                                    objWOSEQ.RorderNo++;
                                    objOMIT.InvoiceNumber = objWOSEQ.Prefix + objWOSEQ.RorderNo.ToString("D6");
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for wastage entry. !',3);", true);
                                    return;
                                }

                                objOMIT.ParentID = ParentID;
                                objOMIT.Type = "W";
                                objOMIT.Notes = txtNotes.Text;
                                objOMIT.Ref1 = objORET.ORETID.ToString();
                                objOMIT.ErrMsg = "Auto Wastage";
                                objOMIT.Amount = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                                objOMIT.WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
                                objOMIT.Date = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
                                objOMIT.CreatedDate = DateTime.Now;
                                objOMIT.CreatedBy = UserID;
                                objOMIT.UpdatedDate = DateTime.Now;
                                objOMIT.UpdatedBy = UserID;
                                ctx.OMITs.Add(objOMIT);

                                int WCount = ctx.GetKey("MIT1", "MIT1ID", "", ParentID, null).FirstOrDefault().Value;
                                int WCountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                                foreach (GridViewRow item in gvItem.Rows)
                                {
                                    Label lblItemID = (Label)item.FindControl("lblItemID");
                                    TextBox txtEnterQty = item.FindControl("txtEnterQty") as TextBox;
                                    if (lblItemID != null && Int32.TryParse(lblItemID.Text, out ItemID) && Decimal.TryParse(txtEnterQty.Text, out DecNum) && DecNum > 0)
                                    {
                                        Label lblUnitID = item.FindControl("lblUnitID") as Label;
                                        Label lblTaxID = item.FindControl("lblTaxID") as Label;

                                        TextBox lblPrice = item.FindControl("lblPrice") as TextBox;

                                        TextBox txtAvailQty = item.FindControl("txtAvailQty") as TextBox;
                                        TextBox txtTotalQty = item.FindControl("txtTotalQty") as TextBox;

                                        TextBox lblSubTotal = item.FindControl("lblSubTotal") as TextBox;
                                        TextBox lblTax = item.FindControl("lblTax") as TextBox;
                                        TextBox lblTotalPrice = item.FindControl("lblTotalPrice") as TextBox;

                                        var Data = lblUnitID.Text.Split(",".ToArray());

                                        MIT1 objMIT1 = new MIT1();

                                        objMIT1.MIT1ID = WCount++;
                                        objMIT1.ItemID = ItemID;
                                        objMIT1.UnitID = Int32.TryParse(Data[0], out IntNum) ? IntNum : 0;
                                        objMIT1.AvailableQty = ctx.ITM2.FirstOrDefault(x => x.ItemID == ItemID && x.WhsID == objOMIT.WhsID).TotalPacket;
                                        objMIT1.Quantity = DecNum;
                                        objMIT1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;
                                        objMIT1.Price = Decimal.TryParse(lblPrice.Text, out DecNum) ? DecNum : 0;
                                        objMIT1.Subtotal = Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                                        objMIT1.Tax = Decimal.TryParse(lblTax.Text, out DecNum) ? DecNum : 0;
                                        objMIT1.Total = Decimal.TryParse(lblTotalPrice.Text, out DecNum) ? DecNum : 0;
                                        objMIT1.Reason = ReasonID.ToString();
                                        objOMIT.MIT1.Add(objMIT1);

                                        ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == ItemID && x.WhsID == objOMIT.WhsID && x.ParentID == ParentID);
                                        if (objITM2 == null)
                                        {
                                            objITM2 = new ITM2();
                                            objITM2.StockID = WCountM++;
                                            objITM2.ParentID = ParentID;
                                            objITM2.WhsID = objOMIT.WhsID;
                                            objITM2.ItemID = ItemID;
                                            ctx.ITM2.Add(objITM2);
                                        }
                                        objITM2.TotalPacket -= objMIT1.TotalQty;
                                        if (objITM2.TotalPacket < 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Insufficient Stock, So You Can Not Despatch This Product: " + objITM2.OITM.ItemName + "',3);", true);
                                            return;
                                        }
                                    }
                                }
                            }

                            int ORETID = 0;
                            decimal CParentID = 0;

                            if (Convert.ToInt32(Session["Type"]) == 4)
                            {
                                Decimal ReturnParentID = objORET.CustomerID.Value;

                                ORET objAUTOPRET = new ORET();
                                objAUTOPRET.ORETID = ctx.GetKey("ORET", "ORETID", "", ReturnParentID, 0).FirstOrDefault().Value;
                                OSEQ objPUROSEQ = ctx.OSEQs.Where(x => x.ParentID == ReturnParentID && !x.IsDeleted && x.Type == "PR" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(CDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(CDate)).FirstOrDefault();

                                if (objPUROSEQ != null)
                                {
                                    objPUROSEQ.RorderNo++;
                                    objAUTOPRET.InvoiceNumber = objPUROSEQ.Prefix + objPUROSEQ.RorderNo.ToString("D6");
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Distribur, please contact distributor for create purchase return entry!',3);", true);
                                    return;
                                }

                                var DayCloseData = ctx.CheckDayClose(Common.DateTimeConvert(txtDate.Text), ReturnParentID).FirstOrDefault();
                                if (!String.IsNullOrEmpty(DayCloseData))
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Distributor DayClose Message :" + DayCloseData + "',3);", true);
                                    return;
                                }
                                else
                                {
                                    btnSubmit.Visible = true;
                                }
                                objAUTOPRET.ParentID = ReturnParentID;
                                objAUTOPRET.VendorID = 1;
                                objAUTOPRET.VendorParentID = ParentID;

                                if (ctx.OMIDs.Any(x => x.ParentID == ReturnParentID && x.VendorParentID == ParentID && x.OrderRefID == objOPOS.SaleID))
                                {
                                    objAUTOPRET.BillRefNo = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ReturnParentID && x.VendorParentID == ParentID && x.OrderRefID == objOPOS.SaleID).InwardID.ToString();
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Purchase Invoice Found of this Distributor. so you can not do return entry',3);", true);
                                    return;
                                }
                                objAUTOPRET.Type = ((int)ReturnType.PurchaseReturnAgainBill).ToString();
                                objAUTOPRET.Status = "O";
                                objAUTOPRET.Notes = txtNotes.Text;
                                objAUTOPRET.SubTotal = Decimal.TryParse(txtSubTotal.Text, out DecNum) ? DecNum : 0;
                                objAUTOPRET.Tax = Decimal.TryParse(txtTax.Text, out DecNum) ? DecNum : 0;
                                objAUTOPRET.Rounding = Decimal.TryParse(txtRounding.Text, out DecNum) ? DecNum : 0;
                                objAUTOPRET.Amount = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                                objAUTOPRET.WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
                                objAUTOPRET.Date = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
                                objAUTOPRET.Ref1 = objORET.ORETID.ToString();
                                objAUTOPRET.ErrMsg = "Auto Purchase Return";
                                objAUTOPRET.Amount = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                                objAUTOPRET.CreatedDate = DateTime.Now;
                                objAUTOPRET.CreatedBy = UserID;
                                objAUTOPRET.UpdatedDate = DateTime.Now;
                                objAUTOPRET.UpdatedBy = UserID;
                                ctx.ORETs.Add(objAUTOPRET);

                                int PURRETCount = ctx.GetKey("RET1", "RET1ID", "", ReturnParentID, null).FirstOrDefault().Value;
                                int PURRETCountM = ctx.GetKey("ITM2", "StockID", "", ReturnParentID, null).FirstOrDefault().Value;

                                foreach (GridViewRow item in gvItem.Rows)
                                {
                                    Label lblItemID = (Label)item.FindControl("lblItemID");
                                    TextBox txtEnterQty = item.FindControl("txtEnterQty") as TextBox;
                                    if (lblItemID != null && Int32.TryParse(lblItemID.Text, out ItemID) && Decimal.TryParse(txtEnterQty.Text, out DecNum) && DecNum > 0)
                                    {
                                        Label lblUnitID = item.FindControl("lblUnitID") as Label;
                                        Label lblTaxID = item.FindControl("lblTaxID") as Label;

                                        TextBox lblPrice = item.FindControl("lblPrice") as TextBox;

                                        TextBox txtAvailQty = item.FindControl("txtAvailQty") as TextBox;
                                        TextBox txtTotalQty = item.FindControl("txtTotalQty") as TextBox;

                                        HtmlInputHidden hdnItemScheme = item.FindControl("hdnItemScheme") as HtmlInputHidden;
                                        HtmlInputHidden hdnScheme = item.FindControl("hdnScheme") as HtmlInputHidden;

                                        HtmlInputHidden hdnSubTotal = item.FindControl("hdnSubTotal") as HtmlInputHidden;
                                        HtmlInputHidden hdnTax = item.FindControl("hdnTax") as HtmlInputHidden;

                                        TextBox lblTotalPrice = item.FindControl("lblTotalPrice") as TextBox;

                                        var Data = lblUnitID.Text.Split(",".ToArray());

                                        RET1 objPURRET1 = new RET1();
                                        objPURRET1.RET1ID = PURRETCount++;
                                        objPURRET1.ItemID = ItemID;
                                        objPURRET1.UnitID = Int32.TryParse(Data[0], out IntNum) ? IntNum : 0;

                                        objPURRET1.Quantity = DecNum;
                                        objPURRET1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;

                                        objPURRET1.UnitPrice = Decimal.TryParse(Data[1], out DecNum) ? DecNum : 0;
                                        objPURRET1.PriceTax = Decimal.TryParse(Data[2], out DecNum) ? DecNum : 0;
                                        objPURRET1.Price = Decimal.TryParse(lblPrice.Text, out DecNum) ? DecNum : 0;
                                        objPURRET1.MapQty = Decimal.TryParse(Data[3], out DecNum) ? DecNum : 0;

                                        objPURRET1.ItemScheme = Decimal.TryParse(hdnItemScheme.Value, out DecNum) ? DecNum : 0;
                                        objPURRET1.Scheme = Decimal.TryParse(hdnScheme.Value, out DecNum) ? DecNum : 0;

                                        objPURRET1.Subtotal = Decimal.TryParse(hdnSubTotal.Value, out DecNum) ? DecNum : 0;
                                        objPURRET1.Tax = Decimal.TryParse(hdnTax.Value, out DecNum) ? DecNum : 0;
                                        objPURRET1.Total = objPURRET1.Subtotal + objPURRET1.Tax;

                                        objPURRET1.ReasonID = Int32.TryParse(ddlReason.SelectedValue, out IntNum) ? IntNum : 0;
                                        objPURRET1.TaxID = Int32.TryParse(lblTaxID.Text, out IntNum) ? IntNum : 0;
                                        objAUTOPRET.RET1.Add(objPURRET1);

                                        // Item Wise Discount Deducation as per new Table Discount Type wise Bifurgation  23-Feb-23 Ticket #T900015915

                                        List<OIDM> ObjODI = ctx.OIDMs.Where(x => x.ParentId == ParentID && x.SaleId == objOPOS.SaleID && x.ItemId == ItemID).ToList();
                                        if (ObjODI != null)
                                        {
                                            foreach (OIDM Retitm in ObjODI)
                                            {
                                                OIDMRET objOIDM = new OIDMRET();
                                                objOIDM.ParentId = ParentID;
                                                objOIDM.ItemId = ItemID;
                                                int qty = int.TryParse(txtTotalQty.Text, out qty) ? qty : 0;
                                                objOIDM.Qty = Convert.ToInt32(qty) * (-1);
                                                objOIDM.InvoiceDate = DateTime.Now;
                                                objOIDM.SchemeMode = Retitm.SchemeMode;
                                                objOIDM.SchemeId = Retitm.SchemeId;
                                                objOIDM.CompanyContri = ((Retitm.CompanyContri / Retitm.Qty) * qty) * (-1);
                                                objOIDM.DistributorContri = ((Retitm.DistributorContri / Retitm.Qty) * qty) * (-1);
                                                objOIDM.TotalDiscount = ((Retitm.TotalDiscount / Retitm.Qty) * qty) * (-1);
                                                objORET.OIDMRETs.Add(objOIDM);
                                            }
                                        }
                                        //
                                        ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == ItemID && x.WhsID == objORET.WhsID && x.ParentID == ReturnParentID);
                                        if (objITM2 == null)
                                        {
                                            objITM2 = new ITM2();
                                            objITM2.StockID = PURRETCountM++;
                                            objITM2.ParentID = ReturnParentID;
                                            objITM2.WhsID = objORET.WhsID;
                                            objITM2.ItemID = ItemID;
                                            ctx.ITM2.Add(objITM2);
                                        }
                                        objITM2.TotalPacket -= objPURRET1.TotalQty;
                                        if (objITM2.TotalPacket < 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Insufficient Stock in Distributor, So You Can Not Return This Product: " + objITM2.OITM.ItemName + "',3);", true);
                                            return;
                                        }
                                    }
                                }

                                OGCM objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == ReturnParentID && x.IsActive);
                                if (objOGCM != null)
                                {
                                    string body = "Purchase Return # " + objAUTOPRET.InvoiceNumber + "created from SS for Invoice # " + objOPOS.InvoiceNumber + " of " + Common.DateTimeConvert(objOPOS.Date) + " on " + Common.DateTimeConvert(objAUTOPRET.Date) + " for "
                                        + objOPOS.OCRD.CustomerCode + " # " + objOPOS.OCRD.CustomerName + " for an amount of Rs. " + objAUTOPRET.Amount.ToString("0.00") + " with total quantity of " + objAUTOPRET.RET1.Sum(x => x.TotalQty).ToString("0");
                                    string title = "Purchase Return # " + objAUTOPRET.InvoiceNumber;

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
                                }
                                ORETID = objAUTOPRET.ORETID;
                                CParentID = objAUTOPRET.ParentID;
                            }
                            else
                            {
                                #region Reverse CouponAmount

                                List<POS3> objPOS3 = ctx.POS3.Where(x => x.SaleID == objOPOS.SaleID && x.EffectOnBill && x.ParentID == ParentID && x.Mode != "S").ToList();

                                if (objPOS3 != null)
                                {
                                    Decimal TotalSchemeAmount = objPOS3.Sum(x => x.Amount);
                                    foreach (var item in objPOS3)
                                    {
                                        if (item.Mode == "D" || item.Mode == "P" || item.Mode == "V")
                                        {
                                            SCM1 objSCM1 = ctx.SCM1.FirstOrDefault(x => x.SchemeID == item.SchemeID && x.CustomerID == objOPOS.CustomerID && x.Active);

                                            objSCM1.UsedCoupon = objSCM1.UsedCoupon - ((item.Amount * objORET.SchemeAmount) / TotalSchemeAmount);
                                        }
                                    }
                                }

                                #endregion
                            }


                            var objOCNT = new OCNT();
                            objOCNT.CreditNoteID = ctx.GetKey("OCNT", "CreditNoteID", "", ParentID, 0).FirstOrDefault().Value;
                            objOCNT.ParentID = ParentID;
                            objOCNT.CreditNoteDate = objORET.Date;
                            objOCNT.CustomerID = objORET.CustomerID.Value;
                            objOCNT.CreditNoteType = "R";
                            objOCNT.Amount = objORET.Amount;
                            objOCNT.Status = "C";
                            objOCNT.Notes = "";
                            objOCNT.CreatedDate = DateTime.Now;
                            objOCNT.CreatedBy = UserID;
                            objOCNT.UpdatedDate = DateTime.Now;
                            objOCNT.UpdatedBy = UserID;
                            objOCNT.RemainAmount = objOCNT.Amount;

                            ctx.OCNTs.Add(objOCNT);

                            objORET.CreditNoteID = objOCNT.CreditNoteID;

                            if (objORET.Date.Date != DateTime.Now.Date)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DayClose is missing, please refresh page or do dayclose',3);", true);
                                return;
                            }
                            ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                            int HdocID = ctx.AddHierarchyType_NEW("R", objORET.CustomerID, ParentID, objORET.ORETID, str).FirstOrDefault().GetValueOrDefault(0);
                            string Customer = ctx.OCRDs.Where(x => x.CustomerID == objORET.CustomerID && x.ParentID == objORET.ParentID).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                            if (str.Value.ToString() == "0" || HdocID == 0)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Beat not available for " + Customer + ", so you can not create Sales Return. Contact to your Local  Sales Staff!',3);", true);
                                return;
                            }
                            objORET.HDocID = HdocID;
                            ctx.SaveChanges();

                            if (ORETID > 0 && CParentID > 0)
                            {
                                string Email = objOPOS.OCRD.EMail1;
                                Thread t = new Thread(() => { SendMailReturn(ORETID, CParentID, Email); });
                                t.Name = Guid.NewGuid().ToString();
                                t.Start();
                            }
                            string CustMobileNo = ctx.OCRDs.Where(x => x.CustomerID == objORET.CustomerID).Select(x => x.Phone).DefaultIfEmpty("").FirstOrDefault();
                            if (!string.IsNullOrEmpty(CustMobileNo))
                            {
                                if (CustMobileNo.Length == 10)
                                {
                                    try
                                    {
                                        bool RestrictStatus = false;
                                        var restrictionObj = ctx.GetWhatsAppRestriction(objORET.ParentID).FirstOrDefault();
                                        if (restrictionObj != null)
                                            RestrictStatus = (restrictionObj.HasValue && restrictionObj.Value == 1) ? true : false;
                                        if (!RestrictStatus)
                                        {
                                            Thread t = new Thread(() =>
                                            {
                                                SendSaleRetDocInWhatsAPP(CustMobileNo, Convert.ToString(objORET.ORETID), ParentID, UserID, Customer);
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


                            if (printInvoice)
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenInvoices('" + objORET.ORETID.ToString() + "');", true);
                            else
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sales Return Entry Inserted Successfully # " + objORET.ORETID.ToString() + "',1);", true);


                            ClearAllInputs();
                        }
                        else
                        {
                            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
                        }
                    }
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }
    //generating PDF of sales return and send that doc to customer's whatsapp.
    public static void SendSaleRetDocInWhatsAPP(string CustPhoneNumber, string SaleRetID, decimal ParentID, int UserID, string Customer)
    {
        ReportDocument myReport = new ReportDocument();
        ConnectionInfo myConnectionInfo = new ConnectionInfo();
        try
        {
            myReport.Load(HostingEnvironment.MapPath("~/Reports/CrystalReports/SalesReturnInvoice.rpt"));
            myReport.SetParameterValue("@ReturnID", SaleRetID);
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

            string FileName = SaleRetID + "_" + ParentID + "_" + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".pdf";
            string FilePath = HostingEnvironment.MapPath("~/Document/WhatsAppAPI/SalesRet/") + FileName;
            myReport.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, FilePath);
            Service wb = new Service();
            int TemplateID = Convert.ToInt32(ConfigurationManager.AppSettings["WhatsAppSalesReturnTempID"]);

            wb.SendWhatsApp(CustPhoneNumber, "Document/WhatsAppAPI/SalesRet/" + FileName, "Return Invoice Detail", FileName, TemplateID, Customer);
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
    protected void btnSaveprint_Click(object sender, EventArgs e)
    {
        printInvoice = true;
        btnSubmit_Click(null, null);

    }

    #endregion

    #region GridView Events

    protected void gvItems_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            SaleOrderItemReturn_Result Data = e.Row.DataItem as SaleOrderItemReturn_Result;

            Label lblUnitID = (Label)e.Row.FindControl("lblUnitID");
            DropDownList ddlReason = (DropDownList)e.Row.FindControl("ddlReason");

            lblUnitID.Text = Data.UnitID + "," + Data.UnitPrice + "," + Data.Tax + "," + Data.Quantity;
        }
    }

    #endregion

    #region TextBox Events

    protected void txtTemplate_TextChanged(object sender, EventArgs e)
    {
        try
        {
            var text = txtBill.Text.Split("-".ToArray());
            if (text.Length > 1)
            {
                int SaleID = 0;
                if (Int32.TryParse(text.Last(), out SaleID) && SaleID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.SaleID == SaleID && x.ParentID == ParentID);

                        if (objOPOS != null)
                        {
                            DateTime dt = DateTime.Now.AddMonths(-6);
                            if (objOPOS.Date.Date < dt.Date || objOPOS.POS3.Any(x => x.Mode == "A"))
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('You are not allowed to make return entry for selected invoice',3);", true);
                                ClearAllInputs();
                                return;
                            }
                            var BeatAvail = ctx.AddHierarchyType_Check(objOPOS.CustomerID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                            if (BeatAvail.IsBeatAvail == 2)
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Beat not available for " + objOPOS.OCRD.CustomerCode + " # " + objOPOS.OCRD.CustomerName + ", so you can not create Sales Return. Contact to your Local Sales Staff!',3);", true);
                                ClearAllInputs();
                                return;
                            }
                            else if (BeatAvail.IsBeatAvail == 0)
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('" + BeatAvail.Msg + "',3);", true);
                                ClearAllInputs();
                                return;
                            }
                            if (objOPOS.POS3.Any(x => x.Mode == "S"))//For QPS Return
                                hdnIsFullItem.Value = "1";
                            else
                                hdnIsFullItem.Value = "0";
                            lblBillToPartyCode.Value = (objOPOS.BillToCustomerID != null) ? (ctx.OCRDs.Where(x => x.CustomerID == objOPOS.BillToCustomerID).Select(x => new { BillToPartyCode = x.CustomerCode + " - " + x.CustomerName }).FirstOrDefault().BillToPartyCode) : (ctx.OCRDs.Where(x => x.CustomerID == objOPOS.CustomerID).Select(x => new { BillToPartyCode = x.CustomerCode + " - " + x.CustomerName }).FirstOrDefault().BillToPartyCode);
                        }

                        gvItem.DataSource = ctx.SaleOrderItemReturn(ParentID, 0, 0, SaleID, 0, 0, Convert.ToInt32(ddlWhs.SelectedValue), ParentID).ToList();
                    }
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
                    ClearAllInputs();
                }
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
                ClearAllInputs();
            }
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}