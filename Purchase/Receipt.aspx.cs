using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Purchase_Receipt : System.Web.UI.Page
{
    #region Property

    protected int UserID;
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
        txtDate.Text = Common.DateTimeConvert(DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            //var Division = ctx.ODIVs.Where(x => x.Active).ToList();
            //ddlDivision.DataSource = Division;
            //ddlDivision.DataBind();
            //ddlDivision.Items.Insert(0, new ListItem("---Select---", "0"));
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

            var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
            ddlWhs.DataSource = Data;
            ddlWhs.DataBind();
        }
        txtDocNo.Text = "";
        txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");

        gvItem.DataSource = null;
        gvItem.DataBind();

        txtBillAmount.Text = txtDiscount.Text = txtPaid.Text = txtPending.Text = txtRounding.Text = txtTax.Text = txtTotal.Text = "0";
        txtPaidTo.Text = txtNotes.Text = txtBillNumber.Text = "";

        txtReceiveDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtReceiveDate.Enabled = false;
        txtDate.Enabled = txtBillDate.Enabled = false;
        txtIndentNo.Text = string.Empty;
        txtPONo.Text = string.Empty;
        txtInvoiceDate.Text = string.Empty;
        txtPODate.Text = string.Empty;
        txtReceiptDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtDivision.Text = string.Empty;
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "PC" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
            {
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series not found for Purchase Receipt',3);", true);
                return;
            }
        }
        if (!IsPostBack)
        {
            txtDocNo.Focus();
            ClearAllInputs();
        }

    }

    #endregion

    #region TextBox Events

    protected void txtDocNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            Int32 OrderID;
            int WhsID;
            var Data = txtDocNo.Text.Split("-".ToArray());

            if (Data.Length >= 2)
            {
                if (Int32.TryParse(Data.FirstOrDefault(), out OrderID))
                {
                    if (Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            var BeatAvail = ctx.AddHierarchyType_Check(ParentID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                            if (BeatAvail.IsBeatAvail == 2)
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Beat not available for you, so you can not create Receipt Entry. Contact to your Local Sales Staff!',3);", true);
                                ClearAllInputs();
                                return;
                            }
                            else if (BeatAvail.IsBeatAvail == 0)
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('" + BeatAvail.Msg + "',3);", true);
                                ClearAllInputs();
                                return;
                            }
                            var OrderType = Data.LastOrDefault().Trim();
                            if (OrderType == "P")
                            {
                                OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ParentID && x.InwardType == (int)InwardType.Delivery && x.Status == "O" && x.InwardID == OrderID);
                                if (objOMID != null)
                                {
                                    var data = (from c in objOMID.MID1
                                                select new ItemData
                                                    {
                                                        ItemID = c.ItemID,
                                                        ItemCode = c.OITM.ItemCode,
                                                        ItemName = c.OITM.ItemName,
                                                        UnitName = c.OUNT.UnitName,
                                                        AvailQty = ctx.ITM2.Where(x => x.ParentID == ParentID && x.WhsID == WhsID && x.ItemID == c.ItemID).Select(x => x.TotalPacket).DefaultIfEmpty(0).FirstOrDefault(),
                                                        UnitID = c.UnitID,
                                                        UnitPrice = c.UnitPrice,
                                                        PriceTax = c.PriceTax,
                                                        MapQty = c.MapQty,
                                                        TaxID = c.TaxID.Value,
                                                        Price = c.Price,
                                                        Discount = c.Discount,
                                                        OrderQuantity = c.RequestQty,
                                                        Quantity = c.DisptchQty,
                                                        SubTotal = c.SubTotal,
                                                        Tax = c.Tax,
                                                        Total = c.Total
                                                    }).ToList();

                                    gvItem.DataSource = data;
                                    gvItem.DataBind();

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

                                    txtDate.Text = Common.DateTimeConvert(objOMID.Date);
                                    txtBillNumber.Text = objOMID.BillNumber;
                                    txtIndentNo.Text = objOMID.Ref3;
                                    txtPONo.Text = objOMID.InvoiceNumber;
                                    txtInvoiceDate.Text = objOMID.InvoiceDate.HasValue ? Common.DateTimeConvert(objOMID.InvoiceDate.Value) : string.Empty;
                                    txtPODate.Text = objOMID.Date != null ? Common.DateTimeConvert(objOMID.Date) : string.Empty;
                                    txtReceiptDate.Text = Common.DateTimeConvert(DateTime.Now);
                                    txtDivision.Text = ctx.ODIVs != null ? ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOMID.DivisionID).DivisionName : string.Empty;

                                    if (objOMID.BillDate.HasValue)
                                        txtBillDate.Text = Common.DateTimeConvert(objOMID.BillDate.Value);
                                    txtBillAmount.Text = objOMID.SubTotal.ToString();
                                    txtDiscount.Text = objOMID.Discount.ToString();
                                    txtRounding.Text = objOMID.Rounding.ToString();
                                    txtTax.Text = objOMID.Tax.ToString();
                                    txtTotal.Text = objOMID.Total.ToString();
                                    txtPaid.Text = objOMID.Paid.ToString();
                                    txtPending.Text = objOMID.Pending.ToString();
                                    txtNotes.Text = objOMID.Notes;
                                    txtPaidTo.Text = objOMID.PaidTo;
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is a no dispatch order of this number',3);", true);
                                    ClearAllInputs();
                                }
                            }
                            else if (OrderType == "O")
                            {
                                var dateData = Data[3].Trim().Split('/');
                                DateTime InvDate = new DateTime(Convert.ToInt32(dateData[2]), Convert.ToInt32(dateData[1]), Convert.ToInt32(dateData[0]));
                                OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.CustomerID == ParentID && new int[] { 12, 13 }.Contains(x.OrderType) && x.Status == "O" && x.SaleID == OrderID && x.IsDelivered == false && EntityFunctions.TruncateTime(x.Date) == EntityFunctions.TruncateTime(InvDate));
                                if (objOPOS != null)
                                {
                                    var data = (from c in objOPOS.POS1
                                                select new ItemData
                                                {
                                                    ItemID = c.ItemID,
                                                    ItemCode = c.OITM.ItemCode,
                                                    ItemName = c.OITM.ItemName,
                                                    UnitName = c.OUNT.UnitName,
                                                    AvailQty = ctx.ITM2.Where(x => x.ParentID == ParentID && x.WhsID == WhsID && x.ItemID == c.ItemID).Select(x => x.TotalPacket).DefaultIfEmpty(0).FirstOrDefault(),
                                                    UnitID = c.UnitID,
                                                    UnitPrice = c.UnitPrice,
                                                    PriceTax = c.PriceTax,
                                                    MapQty = c.MapQty,
                                                    TaxID = c.TaxID.Value,
                                                    Price = c.UnitPrice - Math.Round((((c.UnitPrice) * c.ItemScheme) / 100) + (((c.UnitPrice - (((c.UnitPrice) * c.ItemScheme) / 100)) * c.Scheme) / 100), 4),
                                                    Discount = Math.Round((((c.TotalQty * c.UnitPrice) * c.ItemScheme) / 100) + (((c.TotalQty * c.UnitPrice - (((c.TotalQty * c.UnitPrice) * c.ItemScheme) / 100)) * c.Scheme) / 100), 4),
                                                    OrderQuantity = c.Quantity,
                                                    Quantity = c.DispatchQty,
                                                    SubTotal = c.SubTotal,
                                                    Tax = c.Tax,
                                                    Total = c.Total
                                                }).ToList();

                                    gvItem.DataSource = data;
                                    gvItem.DataBind();

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

                                    txtDate.Text = Common.DateTimeConvert(objOPOS.Date);
                                    txtBillNumber.Text = objOPOS.InvoiceNumber;
                                    txtBillDate.Text = Common.DateTimeConvert(objOPOS.Date);
                                    txtBillAmount.Text = objOPOS.SubTotal.ToString();
                                    txtDiscount.Text = objOPOS.Discount.ToString();
                                    txtRounding.Text = objOPOS.Rounding.ToString();
                                    txtTax.Text = objOPOS.Tax.ToString();
                                    txtTotal.Text = objOPOS.Total.ToString();
                                    txtPaid.Text = objOPOS.Paid.ToString();
                                    txtPending.Text = objOPOS.Pending.ToString();
                                    txtNotes.Text = objOPOS.Notes;
                                    txtPaidTo.Text = "";
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is a no dispatch order of this number',3);", true);
                                    ClearAllInputs();
                                }
                            }
                            else
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper dispatch number',3);", true);
                        }
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select warehouse first',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper dispatch number',3);", true);
            }
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper dispatch number',3);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
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
            ItemData Data = e.Row.DataItem as ItemData;
            if (Data.ItemID > 0)
            {
                Label lblUnitID = (Label)e.Row.FindControl("lblUnitID");
                Label lblUnit = (Label)e.Row.FindControl("lblUnit");

                lblUnitID.Text = Data.UnitID + "," + Data.UnitPrice + "," + Data.PriceTax + "," + Data.MapQty + "," + Data.TaxID;
            }
        }
    }

    #endregion

    #region Button Events

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            Int32 WhsID = 0;
            if (!Int32.TryParse(ddlWhs.SelectedValue, out WhsID))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Warehouse.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {

                Decimal DecNum;
                Int32 IntNum;
                int OrderID;
                var OrderData = txtDocNo.Text.Split("-".ToArray());
                if (OrderData.Length >= 2)
                {
                    if (Int32.TryParse(OrderData.FirstOrDefault(), out OrderID) && OrderID > 0)
                    {
                        OMID objOMID = null;
                        var OrderType = OrderData.LastOrDefault().Trim();
                        if (OrderType == "P")
                        {
                            objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ParentID && x.InwardType == (int)InwardType.Delivery && x.Status == "O" && x.InwardID == OrderID);
                            if (objOMID != null)
                            {
                                if (ctx.OMIDs.Any(x => x.BillNumber == objOMID.BillNumber && x.InwardType == 3))
                                {
                                    objOMID.InwardType = 5;
                                    objOMID.UpdatedDate = DateTime.Now;
                                    objOMID.UpdatedBy = UserID;
                                    ctx.SaveChanges();
                                    ClearAllInputs();
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same BillNumber is already received, so we updated this bill as Cancel',3);", true);
                                    return;
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is a no dispatch order of this number',3);", true);
                                ClearAllInputs();
                            }
                        }
                        else if (OrderType == "O")
                        {
                            OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.CustomerID == ParentID && new int[] { 12, 13 }.Contains(x.OrderType) && x.Status == "O" && x.SaleID == OrderID);
                            if (objOPOS != null)
                            {
                                objOPOS.Status = "C";
                                objOPOS.UpdatedDate = DateTime.Now;
                                objOPOS.UpdatedBy = UserID;

                                objOMID = new OMID();
                                objOMID.InwardID = ctx.GetKey("OMID", "InwardID", "", ParentID, 0).FirstOrDefault().Value;
                                objOMID.ParentID = ParentID;
                                objOMID.VendorID = 1;
                                objOMID.VendorParentID = objOPOS.ParentID;
                                objOMID.Date = DateTime.Now;
                                objOMID.Status = "C";
                                objOMID.BillDate = objOPOS.Date;
                                objOMID.OrderRefID = objOPOS.SaleID;
                                objOMID.GSTInvNo = txtBillNumber.Text;
                                objOMID.CreatedDate = DateTime.Now;
                                objOMID.CreatedBy = UserID;
                                ctx.OMIDs.Add(objOMID);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is a no dispatch order of this number',3);", true);
                                ClearAllInputs();
                            }
                        }

                        objOMID.InwardType = 3;
                        objOMID.ToWhsID = WhsID;
                        objOMID.ReceiveDate = Common.DateTimeConvert(txtReceiveDate.Text).Add(DateTime.Now.TimeOfDay);
                        objOMID.UpdatedDate = DateTime.Now;
                        objOMID.UpdatedBy = UserID;
                        objOMID.Status = "O";
                        objOMID.BillNumber = txtBillNumber.Text;
                        objOMID.SubTotal = Decimal.TryParse(txtBillAmount.Text, out DecNum) ? DecNum : 0;
                        objOMID.Discount = Decimal.TryParse(txtDiscount.Text, out DecNum) ? DecNum : 0;
                        objOMID.Rounding = Decimal.TryParse(txtRounding.Text, out DecNum) ? DecNum : 0;
                        objOMID.Tax = Decimal.TryParse(txtTax.Text, out DecNum) ? DecNum : 0;
                        objOMID.Total = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                        objOMID.Paid = Decimal.TryParse(txtPaid.Text, out DecNum) ? DecNum : 0;
                        objOMID.Pending = Decimal.TryParse(txtPending.Text, out DecNum) ? DecNum : 0;
                        objOMID.Notes = txtNotes.Text;
                        objOMID.PaidTo = txtPaidTo.Text;

                        OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "PC" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(objOMID.ReceiveDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(objOMID.ReceiveDate)).FirstOrDefault();

                        if (objOSEQ != null)
                        {
                            objOSEQ.RorderNo++;
                            objOMID.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series not found',3);", true);
                            return;
                        }

                        int Count = ctx.GetKey("MID1", "MID1ID", "", ParentID, null).FirstOrDefault().Value;
                        int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;
                        string[] Data;
                        int ItemID = 0;

                        foreach (GridViewRow item in gvItem.Rows)
                        {
                            Label lblItemID = (Label)item.FindControl("lblItemID");

                            if (Int32.TryParse(lblItemID.Text, out ItemID) && ItemID > 0)
                            {
                                Label lblUnitID = (Label)item.FindControl("lblUnitID");
                                Label lblTaxID = (Label)item.FindControl("lblTaxID");

                                TextBox txtAvailQty = (TextBox)item.FindControl("txtAvailQty");
                                TextBox txtRequestQty = (TextBox)item.FindControl("txtRequestQty");
                                TextBox txtRecieptQty = (TextBox)item.FindControl("txtRecieptQty");

                                TextBox lblDiscount = (TextBox)item.FindControl("lblDiscount");
                                TextBox lblSubTotal = (TextBox)item.FindControl("lblSubTotal");
                                TextBox lblTax = (TextBox)item.FindControl("lblTax");
                                TextBox lblTotalPrice = (TextBox)item.FindControl("lblTotalPrice");
                                HtmlInputHidden hdnAvailQty = (HtmlInputHidden)item.FindControl("hdnAvailQty");
                                HtmlInputHidden hdnPrice = (HtmlInputHidden)item.FindControl("hdnPrice");

                                Data = lblUnitID.Text.Split(",".ToArray());

                                if (Data.Length == 5)
                                {
                                    MID1 objMID1 = objOMID.MID1.FirstOrDefault(x => x.ItemID == ItemID);
                                    if (objMID1 == null)
                                    {
                                        objMID1 = new MID1();
                                        objMID1.MID1ID = Count++;
                                        objMID1.ItemID = ItemID;
                                        objOMID.MID1.Add(objMID1);
                                    }
                                    objMID1.UnitID = Int32.TryParse(Data[0], out IntNum) ? IntNum : 0;

                                    objMID1.UnitPrice = Decimal.TryParse(Data[1], out DecNum) ? DecNum : 0;
                                    objMID1.Price = Decimal.TryParse(hdnPrice.Value, out DecNum) ? DecNum : 0;
                                    //DecNum = Convert.ToDecimal(Data[2]);
                                    //objMID1.PriceTax = (objMID1.Price * DecNum) / 100;
                                    objMID1.PriceTax = Convert.ToDecimal(Data[2]);

                                    objMID1.MapQty = Decimal.TryParse(Data[3], out DecNum) ? DecNum : 0;
                                    objMID1.TaxID = Int32.TryParse(lblTaxID.Text, out IntNum) ? IntNum : 0;
                                    objMID1.AvailableQty = Decimal.TryParse(hdnAvailQty.Value, out DecNum) ? DecNum : 0;
                                    objMID1.RequestQty = Decimal.TryParse(txtRequestQty.Text, out DecNum) ? DecNum : 0;
                                    objMID1.DiffirenceQty = 0;
                                    objMID1.RecieptQty = Decimal.TryParse(txtRecieptQty.Text, out DecNum) ? DecNum : 0;
                                    objMID1.TotalQty = objMID1.MapQty * objMID1.RecieptQty;
                                    objMID1.Discount = Decimal.TryParse(lblDiscount.Text, out DecNum) ? DecNum : 0;
                                    objMID1.SubTotal = Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                                    objMID1.Tax = Decimal.TryParse(lblTax.Text, out DecNum) ? DecNum : 0;
                                    objMID1.Total = Decimal.TryParse(lblTotalPrice.Text, out DecNum) ? DecNum : 0;

                                    objOMID.MID1.Add(objMID1);

                                    // Update Stock
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
                                    if (objMID1.RecieptQty > 0)
                                    {
                                        ITM2.TotalPacket += objMID1.TotalQty;
                                    }
                                }
                            }
                        }
                        if (objOMID.ReceiveDate.Value.Date != DateTime.Now.Date)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DayClose is missing, please refresh page or do dayclose',3);", true);
                            return;
                        }
                        ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                        int HdocID = ctx.AddHierarchyType_NEW("PR", objOMID.ParentID, ParentID, objOMID.InwardID, str).FirstOrDefault().GetValueOrDefault(0);
                        if (str.Value.ToString() == "0" || HdocID == 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Beat Not Available So, you can not do Purchase Receipt. Contact to your Local  Sales Staff!',3);", true);
                            return;
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

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Order Inserted Successfully: OrderID: " + objOMID.InwardID.ToString() + "',1);", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper inward number',3);", true);
                        return;
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper inward number',3);", true);
                    return;
                }
            }
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}