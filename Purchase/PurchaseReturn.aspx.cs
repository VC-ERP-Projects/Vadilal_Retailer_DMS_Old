using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Purchase_PurchaseReturn : System.Web.UI.Page
{

    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    String TempPath = Path.GetTempPath();

    private List<ItemData> BindList
    {
        get { return this.Session["RET1"] as List<ItemData>; }
        set { this.Session["RET1"] = value; }
    }

    private List<DisData> ORSNs
    {
        get { return this.ViewState["DisData"] as List<DisData>; }
        set { this.ViewState["DisData"] = value; }
    }

    private List<NewItemData> NewList
    {
        get { return this.Session["NewItemDatas"] as List<NewItemData>; }
        set { this.Session["NewItemDatas"] = value; }
    }

    #endregion

    #region Helper Method

    [WebMethod(EnableSession = true)]
    public static Boolean AddRecord(int LineID, int UnitID, string UnitName, Decimal UnitPrice, Decimal PriceTax, Decimal Quantity, Decimal MapQty, Decimal TotalQty, Decimal SubTotal, Decimal Tax, Decimal Total, int ReasonID, string RANKNO)
    {
        Boolean RetVal = false;
        try
        {
            List<ItemData> RET1s = HttpContext.Current.Session["RET1"] as List<ItemData>;
            if (RET1s == null) RET1s = new List<ItemData>();
            var objRET1 = RET1s[LineID];
            if (objRET1 != null)
            {
                objRET1.RANKNO = RANKNO;
                objRET1.UnitID = UnitID;
                objRET1.UnitPrice = UnitPrice;
                objRET1.UnitName = UnitName;
                objRET1.PriceTax = PriceTax;
                objRET1.Price = objRET1.UnitPrice + objRET1.PriceTax;
                objRET1.MapQty = MapQty;
                objRET1.Quantity = Quantity;
                objRET1.TotalQty = TotalQty;
                objRET1.SubTotal = SubTotal;
                objRET1.Tax = Tax;
                objRET1.Total = Total;
                objRET1.ReasonID = ReasonID;
            }
            HttpContext.Current.Session["RET1"] = RET1s;

            RetVal = true;
        }
        catch (Exception)
        {
            RetVal = true;
        }
        return RetVal;
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

    public void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (Convert.ToDecimal(Session["OutletPID"]) != 1000010000000000)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Purchase return not allowed, Please contact to DMS Team only',3);", true);
                btnSubmit.Visible = false;
                return;
            }

            txtSubTotal.Text = txtTax.Text = txtTotal.Text = txtRounding.Text = "0";
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

            txtTemplate.Style.Add("background-color", "rgb(250, 255, 189);");

            txtTemplate.Text = txtNotes.Text = "";
            ddlType_SelectedIndexChanged(ddlType, EventArgs.Empty);

            var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
            ddlWhs.DataSource = Data;
            ddlWhs.DataBind();
            Session["PhotoFileName"] = null;
            NewList = new List<NewItemData>();
            BindList = new List<ItemData>();
            BindList.Add(new ItemData());
            gvItem.DataSource = BindList;
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
            ORSNs = ctx.ORSNs.Where(x => x.Active && x.Type == "P").Select(x => new DisData { Text = x.ReasonName, Value = x.ReasonID }).ToList();
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "PR" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
            {
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Purchase Return. !',3);", true);
                btnSubmit.Visible = false;

                gvItem.DataSource = null;
                gvItem.DataBind();

                return;
            }
        }
        if (!IsPostBack)
        {
            ClearAllInputs();
            ddlType.Focus();
        }

    }

    #endregion

    #region Button Click

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal DecNum;
                var CDate = Common.DateTimeConvert(txtDate.Text);
                ORET objORET = new ORET();
                objORET.ORETID = ctx.GetKey("ORET", "ORETID", "", ParentID, 0).FirstOrDefault().Value;
                OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "PR" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(CDate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(CDate)).FirstOrDefault();

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
                objORET.ParentID = ParentID;

                if (ddlType.SelectedValue == "1")
                {
                    if (txtVendor.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Valid Bill Number',3);", true);
                        return;
                    }
                    var Rec = txtVendor.Text.Split("-".ToArray());
                    if (Rec.Length > 1)
                    {
                        var POID = Convert.ToInt32(Rec.FirstOrDefault());
                        var objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ParentID && x.InwardID == POID);
                        if (objOMID != null)
                        {
                            objORET.VendorID = objOMID.VendorID;
                            objORET.VendorParentID = objOMID.VendorParentID;
                            objORET.BillRefNo = objOMID.InwardID.ToString();
                            objORET.Type = ((int)ReturnType.PurchaseReturnAgainBill).ToString();
                        }
                    }
                }
                else
                {
                    if (txtVendor.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Vendor',3);", true);
                        return;
                    }
                    var Rec = txtVendor.Text.Split("-".ToArray());
                    if (Rec.Length > 1)
                    {
                        String VCode = Rec.First().Trim();
                        String Vname = Rec.Last().Trim();
                        var objOVND = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == VCode && x.VendorName == Vname);
                        objORET.VendorID = objOVND.VendorID;
                        objORET.VendorParentID = objOVND.ParentID;
                        objORET.Type = ((int)ReturnType.PurchaseReturn).ToString();
                    }
                }

                objORET.Status = "O";
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
                objORET.UpdatedDate = DateTime.Now;
                ctx.ORETs.Add(objORET);

                int Count = ctx.GetKey("RET1", "RET1ID", "", ParentID, null).FirstOrDefault().Value;
                int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;

                foreach (ItemData item in BindList)
                {
                    if (item.Quantity > 0)
                    {
                        RET1 objRET1 = new RET1();
                        objRET1.RET1ID = Count++;
                        objRET1.ItemID = item.ItemID;

                        objRET1.UnitID = item.UnitID;
                        objRET1.UnitPrice = item.UnitPrice;
                        objRET1.PriceTax = item.PriceTax;
                        objRET1.Price = item.Price;
                        objRET1.MapQty = item.MapQty;

                        objRET1.RANKNO = item.RANKNO;

                        objRET1.Quantity = item.Quantity;
                        objRET1.TotalQty = item.TotalQty;
                        objRET1.Subtotal = item.SubTotal;
                        objRET1.Tax = item.Tax;
                        objRET1.TaxID = item.TaxID;
                        objRET1.Total = item.Total;

                        objRET1.ReasonID = item.ReasonID;

                        objORET.RET1.Add(objRET1);

                        ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == item.ItemID && x.WhsID == objORET.WhsID && x.ParentID == ParentID);
                        if (objITM2 == null)
                        {
                            objITM2 = new ITM2();
                            objITM2.StockID = CountM++;
                            objITM2.ParentID = ParentID;
                            objITM2.WhsID = objORET.WhsID;
                            objITM2.ItemID = item.ItemID;
                            ctx.ITM2.Add(objITM2);
                        }
                        objITM2.TotalPacket -= objRET1.TotalQty;
                        if (objITM2.TotalPacket < 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Insufficient Stock, So You Can Not Despatch This Product: " + item.ItemName + "',3);", true);
                            return;
                        }
                    }
                }
                if (objORET.Date.Date != DateTime.Now.Date)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DayClose is missing, please refresh page or do dayclose',3);", true);
                    return;
                }
                ObjectParameter str = new ObjectParameter("Flag", typeof(int));
                int HdocID = ctx.AddHierarchyType_NEW("T", objORET.ParentID, ParentID, objORET.ORETID, str).FirstOrDefault().GetValueOrDefault(0);
                if (str.Value.ToString() == "0" || HdocID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Beat Not Available So, you can not do Purchase Return. Contact to your Local Sales Staff!',3);", true);
                    return;
                }
                objORET.HDocID = HdocID;
                ctx.SaveChanges();

                if (Session["PhotoFileName"] != null)
                {
                    string FileName = Session["PhotoFileName"].ToString();
                    string SavePath = Path.Combine(Server.MapPath(Constant.Wastage), FileName);
                    string SourcePath = TempPath + FileName;
                    File.Copy(SourcePath, SavePath);

                    if (!String.IsNullOrEmpty(objORET.Attachment) && File.Exists(Constant.Wastage + objORET.Attachment))
                        File.Delete(Constant.Wastage + objORET.Attachment);

                    objORET.Attachment = FileName;
                    Session["PhotoFileName"] = null;
                }

                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Purchase Return Entry Inserted Successfully # " + objORET.ORETID.ToString() + "',1);", true);
            }
            ClearAllInputs();
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
            //gvItem.Columns[6].Visible = false;
            ItemData Data = e.Row.DataItem as ItemData;
            if (Data.ItemID > 0)
            {
                DropDownList ddlUnit = (DropDownList)e.Row.FindControl("ddlUnit");
                foreach (NewItemData item in NewList.Where(x => x.ItemID == Data.ItemID).ToList())
                {
                    ddlUnit.Items.Add(new ListItem(item.Unitname, item.UnitID + "," + item.UnitPrice + "," + item.PriceTax + "," + item.Quantity));
                }
                ddlUnit.SelectedIndex = ddlUnit.Items.IndexOf(ddlUnit.Items.FindByText(Data.UnitName));
            }
            DropDownList ddlReason = (DropDownList)e.Row.FindControl("ddlReason");
            ddlReason.DataSource = ORSNs;
            ddlReason.DataBind();
            ddlReason.SelectedValue = Data.ReasonID.ToString();
        }
        //if (e.Row.RowType == DataControlRowType.Footer)
        //{
        //    TextBox totallblCAmount = (TextBox)e.Row.FindControl("lblTSubTotal");
        //    decimal pricValue = 0;
        //    totallblCAmount.Text = String.Format("{0}", pricValue);
        //}
    }

    #endregion

    #region TextBox Events

    protected void txtTemplate_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (Convert.ToDecimal(Session["OutletPID"]) != 1000010000000000)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Purchase return not allowed, Please contact to DMS Team only',3);", true);
                btnSubmit.Visible = false;
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var BeatAvail = ctx.AddHierarchyType_Check(ParentID, ParentID).Select(x => new { x.IsBeatAvail, x.Msg }).FirstOrDefault();
                if (BeatAvail.IsBeatAvail == 2)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Beat not available for you, so you can not create Purchase Return. Contact to your Local Sales Staff!',3);", true);
                    ClearAllInputs();
                    return;
                }
                else if (BeatAvail.IsBeatAvail == 0)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('" + BeatAvail.Msg + "',3);", true);
                    ClearAllInputs();
                    return;
                }
                if (ddlType.SelectedValue == "1")
                {
                    var TEXT = txtVendor.Text.Split("-".ToArray());
                    if (TEXT.Length > 1)
                    {
                        int InwardID = 0;
                        if (Int32.TryParse(TEXT.First(), out InwardID) && InwardID > 0)
                        {
                            OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ParentID && x.Status == "O" && x.InwardID == InwardID);
                            if (objOMID != null)
                            {
                                txtInvoiceDate.Text = objOMID.InvoiceDate.HasValue ? Common.DateTimeConvert(objOMID.InvoiceDate.Value) : string.Empty;
                                txtDivision.Text = ctx.ODIVs != null ? ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOMID.DivisionID).DivisionName : string.Empty;
                                txtReceivedDate.Text = objOMID.ReceiveDate.HasValue ? Common.DateTimeConvert(objOMID.ReceiveDate.Value) : string.Empty;
                            }
                            if (ctx.OMIDs.Any(x => x.InwardID == InwardID && x.ParentID == ParentID && x.Discount > 0))
                            {
                                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('You can not take purchase return of discount bill.',3);", true);
                            }
                            else
                            {
                                List<PurchaseItem_Result> Data = ctx.PurchaseItem(ParentID, 0, InwardID, 0, 0, Convert.ToInt32(ddlWhs.SelectedValue)).ToList();

                                NewList = (from x in Data
                                           select new NewItemData
                                           {
                                               ItemID = x.ItemID,
                                               UnitID = x.UnitID,
                                               Unitname = x.Unitname,
                                               UnitPrice = x.UnitPrice,
                                               PriceTax = x.Tax,
                                               Quantity = x.Quantity
                                           }).ToList();

                                List<ItemData> tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.UnitPrice, y.ItemCode, y.DispatchQty, y.TaxID }).ToList()
                                                          select new ItemData
                                                          {
                                                              ItemID = x.Key.ItemID,
                                                              ItemCode = x.Key.ItemCode,
                                                              ItemName = x.Key.ItemName,
                                                              UnitPrice = x.Key.UnitPrice,
                                                              AvailQty = x.Key.DispatchQty,
                                                              TaxID = x.Key.TaxID
                                                          }).ToList();

                                BindList = tmpList;
                            }
                        }
                        else
                            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);

                    }
                    else
                        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper order.',3);", true);
                }
                else
                {
                    var Rec = txtVendor.Text.Split("-".ToArray());
                    if (Rec.Length > 1)
                    {
                        var Vendorcode = Rec.FirstOrDefault().Trim();
                        OVND Vendor = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == Vendorcode && x.Active);
                        if (Vendor != null)
                        {
                            int InwardID = 0;
                            int.TryParse(Vendorcode, out InwardID);
                            OMID objOMID = ctx.OMIDs.FirstOrDefault(x => x.ParentID == ParentID && x.Status == "O" && x.InwardID == InwardID);
                            if (objOMID != null)
                            {
                                txtInvoiceDate.Text = objOMID.InvoiceDate.HasValue ? Common.DateTimeConvert(objOMID.InvoiceDate.Value) : string.Empty;
                                txtDivision.Text = ctx.ODIVs != null ? ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objOMID.DivisionID).DivisionName : string.Empty;
                                txtReceivedDate.Text = objOMID.ReceiveDate.HasValue ? Common.DateTimeConvert(objOMID.ReceiveDate.Value) : string.Empty;
                            }
                            var word = txtTemplate.Text.Split("-".ToArray());
                            if (word.Length == 2)
                            {
                                int TemplateID = Convert.ToInt32(word.First().Trim());
                                int DivisionID = ctx.OTMPs.FirstOrDefault(x => x.TemplateID == TemplateID && x.ParentID == ParentID).DivisionlID.Value;
                                int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                                List<PurchaseItem_Result> Data = ctx.PurchaseItem(ParentID, PriceID, 0, 0, TemplateID, Convert.ToInt32(ddlWhs.SelectedValue)).ToList();

                                NewList = (from x in Data
                                           select new NewItemData
                                           {
                                               ItemID = x.ItemID,
                                               UnitID = x.UnitID,
                                               Unitname = x.Unitname,
                                               UnitPrice = x.UnitPrice,
                                               PriceTax = x.Tax,
                                               Quantity = x.Quantity
                                           }).ToList();

                                List<ItemData> tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                          select new ItemData
                                                          {
                                                              ItemID = x.Key.ItemID,
                                                              ItemCode = x.Key.ItemCode,
                                                              ItemName = x.Key.ItemName,
                                                              AvailQty = x.Key.AvailQty,
                                                              TaxID = x.Key.TaxID
                                                          }).ToList();

                                BindList = tmpList;
                                BindList.Add(new ItemData());
                            }
                        }
                        else
                            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper customer.',3);", true);
                    }
                    else
                        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Select proper customer.',3);", true);
                }
            }
            gvItem.DataSource = BindList;
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void txtItem_TextChanged(object sender, EventArgs e)
    {
        int WhsID;
        if (Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
        {
            TextBox txt = (TextBox)sender;
            GridViewRow row = (GridViewRow)txt.NamingContainer;

            if (ddlType.SelectedValue == "1")
            {
                if (String.IsNullOrEmpty(txtVendor.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Valid Bill Number',3);", true);
                }
            }
            else if (!String.IsNullOrEmpty(txt.Text))
            {
                var word = txt.Text.Split("-".ToArray());
                if (word.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        var ItemCode = word.First().Trim();
                        int ItemID = ctx.OITMs.Where(x => x.ItemCode == ItemCode && x.Active).Select(x => x.ItemID).DefaultIfEmpty(0).FirstOrDefault();
                        if (ItemID > 0)
                        {
                            string[] Rec = txtVendor.Text.Split("-".ToArray());

                            if (Rec.Length > 1 && Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
                            {
                                var CustCode = Rec.FirstOrDefault();
                                OVND Cust = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == CustCode && x.Active);
                                if (Cust != null)
                                {
                                    int DivisionlID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID && x.DivisionlID.HasValue).DivisionlID.Value;
                                    int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

                                    var Data = ctx.PurchaseItem(ParentID, PriceID, 0, ItemID, 0, WhsID).ToList();
                                    if (Data.Count > 0)
                                    {
                                        if (NewList == null)
                                            NewList = new List<NewItemData>();

                                        if (BindList[row.RowIndex].ItemID > 0)
                                        {
                                            NewList.RemoveAll(x => x.ItemID == BindList[row.RowIndex].ItemID);
                                            NewList.AddRange((from x in Data
                                                              select new NewItemData
                                                              {
                                                                  ItemID = x.ItemID,
                                                                  UnitID = x.UnitID,
                                                                  Unitname = x.Unitname,
                                                                  UnitPrice = x.UnitPrice,
                                                                  PriceTax = x.Tax,
                                                                  Quantity = x.Quantity
                                                              }).ToList());

                                            ItemData tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                                select new ItemData
                                                                {
                                                                    ItemID = x.Key.ItemID,
                                                                    ItemCode = x.Key.ItemCode,
                                                                    ItemName = x.Key.ItemName,
                                                                    AvailQty = x.Key.AvailQty,
                                                                    TaxID = x.Key.TaxID
                                                                }).FirstOrDefault();

                                            BindList[row.RowIndex] = tmpList;
                                        }
                                        else
                                        {
                                            NewList.RemoveAll(x => x.ItemID == BindList[row.RowIndex].ItemID);
                                            NewList.AddRange((from x in Data
                                                              select new NewItemData
                                                              {
                                                                  ItemID = x.ItemID,
                                                                  UnitID = x.UnitID,
                                                                  Unitname = x.Unitname,
                                                                  UnitPrice = x.UnitPrice,
                                                                  PriceTax = x.Tax,
                                                                  Quantity = x.Quantity
                                                              }).ToList());

                                            List<ItemData> tmpList = (from x in Data.GroupBy(y => new { y.ItemID, y.ItemName, y.ItemCode, y.AvailQty, y.TaxID }).ToList()
                                                                      select new ItemData
                                                                      {
                                                                          ItemID = x.Key.ItemID,
                                                                          ItemCode = x.Key.ItemCode,
                                                                          ItemName = x.Key.ItemName,
                                                                          AvailQty = x.Key.AvailQty,
                                                                          TaxID = x.Key.TaxID
                                                                      }).ToList();


                                            BindList.RemoveAt(BindList.Count - 1);
                                            BindList.AddRange(tmpList);
                                            BindList.Add(new ItemData());
                                        }
                                        gvItem.DataSource = BindList;
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please contact Marketing Department to resolve this issue.',3); ChangeQuantity();", true);
                                        txt.Text = "";
                                        return;
                                    }
                                }
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Item is not found.',3); ChangeQuantity();", true);
                            txt.Text = "";
                            return;
                        }
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Item.',3); ChangeQuantity();", true);
                    txt.Text = "";
                    return;
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
            }
            else
            {
                if (BindList.Count - 1 != row.RowIndex)
                {
                    BindList.RemoveAt(row.RowIndex);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
                }
            }
            gvItem.DataSource = BindList;
            gvItem.DataBind();
            TextBox txtQty = (TextBox)row.FindControl("txtEnterQty");
            txtQty.Focus();

        }
    }

    #endregion

    #region Dropdown Events
    protected void ddlType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtVendor.Text = txtTemplate.Text = "";
        if (ddlType.SelectedValue == "1")
        {
            lblVendor.Text = "Invoice No";
            acetxtVendor.Enabled = false;
            acetxtBill.Enabled = true;
            txtTemplate.Enabled = false;
            txtTemplate.Style.Remove("background-color");
        }
        else
        {
            txtTemplate.Style.Add("background-color", "rgb(250, 255, 189);");
            txtTemplate.Enabled = true;
            lblVendor.Text = "Vendor";
            acetxtVendor.Enabled = true;
            acetxtBill.Enabled = false;
        }
    }

    #endregion


}