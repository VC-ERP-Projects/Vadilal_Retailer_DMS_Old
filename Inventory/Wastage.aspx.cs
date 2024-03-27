using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Inventory_Wastage : System.Web.UI.Page
{

    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

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
    public static Boolean AddRecord(int LineID, int UnitID, string UnitName, Decimal UnitPrice, Decimal PriceTax, Decimal Quantity, Decimal MapQty, Decimal TotalQty, Decimal SubTotal, int ReasonID)
    {
        Boolean RetVal = false;
        try
        {
            List<ItemData> RET1s = HttpContext.Current.Session["RET1"] as List<ItemData>;
            if (RET1s == null) RET1s = new List<ItemData>();
            var objRET1 = RET1s[LineID];
            if (objRET1 != null)
            {
                objRET1.UnitID = UnitID;
                objRET1.UnitPrice = UnitPrice;
                objRET1.UnitName = UnitName;
                objRET1.PriceTax = PriceTax;
                objRET1.Price = objRET1.UnitPrice + objRET1.PriceTax;
                objRET1.MapQty = MapQty;
                objRET1.Quantity = Quantity;
                objRET1.TotalQty = TotalQty;
                objRET1.SubTotal = SubTotal;
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
        txtDate.Text = Common.DateTimeConvert(DateTime.Now);
        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.OSEQs.Any(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "W" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(DateTime.Now) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(DateTime.Now)))
            {
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found for Wastage. !',3);", true);
                //Response.Redirect("~/MyAccount/ResetOrderNo.aspx");
                return;

            }

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

            txtTemplate.Text = txtNotes.Text = txtAmount.Text = "";
            txtDate.Text = Common.DateTimeConvert(DateTime.Now);

            var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
            ddlWhs.DataSource = Data;
            ddlWhs.DataBind();
            NewList = new List<NewItemData>();
            BindList = new List<ItemData>();
            BindList.Add(new ItemData());
            gvItem.DataSource = BindList;
            gvItem.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
            ORSNs = ctx.ORSNs.Where(x => x.Active && x.Type == "W").Select(x => new DisData { Text = x.ReasonName, Value = x.ReasonID }).ToList();
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ////txtDate.Focus();
            ClearAllInputs();
        }

    }

    #endregion

    #region Button Click

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Inventory.aspx");
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal DecNum;
                int IntNum = 0;
                var date = DateTime.Now.Date;
                if (txtDate.Text != "")
                {
                    date = Common.DateTimeConvert(txtDate.Text);
                }
                OMIT objOMIT = new OMIT();
                objOMIT.OMITID = ctx.GetKey("OMIT", "OMITID", "", ParentID, 0).FirstOrDefault().Value;
                OSEQ objOSEQ = ctx.OSEQs.Where(x => x.ParentID == ParentID && !x.IsDeleted && x.Type == "W" && EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(date) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(date)).FirstOrDefault();

                if (objOSEQ != null)
                {
                    objOSEQ.RorderNo++;
                    objOMIT.InvoiceNumber = objOSEQ.Prefix + objOSEQ.RorderNo.ToString("D6");
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Invoice Series Not Found. !',3);", true);
                    return;

                }
                objOMIT.ParentID = ParentID;
                objOMIT.Type = "W";
                objOMIT.Notes = txtNotes.Text;
                objOMIT.Amount = Decimal.TryParse(txtAmount.Text, out DecNum) ? DecNum : 0;
                objOMIT.WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
                objOMIT.Date = Common.DateTimeConvert(txtDate.Text).Add(DateTime.Now.TimeOfDay);
                objOMIT.CreatedDate = DateTime.Now;
                objOMIT.CreatedBy = UserID;
                objOMIT.UpdatedDate = DateTime.Now;
                objOMIT.UpdatedBy = UserID;
                ctx.OMITs.Add(objOMIT);

                int Count = ctx.GetKey("MIT1", "MIT1ID", "", ParentID, null).FirstOrDefault().Value;
                int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;
                int ItemID = 0;

                foreach (GridViewRow item in gvItem.Rows)
                {
                    Label lblItemID = (Label)item.FindControl("lblItemID");
                    TextBox txtEnterQty = item.FindControl("txtEnterQty") as TextBox;
                    if (lblItemID != null && Int32.TryParse(lblItemID.Text, out ItemID) && Decimal.TryParse(txtEnterQty.Text, out DecNum) && DecNum > 0)
                    {
                        DropDownList ddlUnit = item.FindControl("ddlUnit") as DropDownList;

                        TextBox txtTotalQty = item.FindControl("txtTotalQty") as TextBox;
                        TextBox txtAvailQty = item.FindControl("txtAvailQty") as TextBox;
                        TextBox lblPrice = item.FindControl("lblPrice") as TextBox;

                        TextBox lblSubTotal = item.FindControl("lblSubTotal") as TextBox;
                        DropDownList ddlReason = item.FindControl("ddlReason") as DropDownList;

                        MIT1 objMIT1 = new MIT1();

                        objMIT1.MIT1ID = Count++;
                        objMIT1.ItemID = ItemID;
                        objMIT1.UnitID = Int32.TryParse(ddlUnit.SelectedValue.Split(",".ToArray()).First(), out IntNum) ? IntNum : 0;
                        objMIT1.AvailableQty = Decimal.TryParse(txtAvailQty.Text, out DecNum) ? DecNum : 0;
                        objMIT1.Quantity = Decimal.TryParse(txtEnterQty.Text, out DecNum) ? DecNum : 0;
                        objMIT1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;
                        objMIT1.Price = Decimal.TryParse(lblPrice.Text, out DecNum) ? DecNum : 0;
                        objMIT1.Subtotal = Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                        objMIT1.Tax = 0;
                        objMIT1.Total = objMIT1.Subtotal;
                        objMIT1.Reason = ddlReason.SelectedValue;
                        objOMIT.MIT1.Add(objMIT1);


                        ITM2 objITM2 = ctx.ITM2.FirstOrDefault(x => x.ItemID == ItemID && x.WhsID == objOMIT.WhsID && x.ParentID == ParentID);
                        if (objITM2 == null)
                        {
                            objITM2 = new ITM2();
                            objITM2.StockID = CountM++;
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
                if (objOMIT.Date.Date != DateTime.Now.Date)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('DayClose is missing, please refresh page or do dayclose',3);", true);
                    return;
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Inserted Successfully',1);", true);
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
    }

    #endregion

    #region TeXtChange

    protected void txtTemplate_TextChanged(object sender, EventArgs e)
    {
        try
        {
            var word = txtTemplate.Text.Split("-".ToArray());
            if (word.Length == 2)
            {
                using (DDMSEntities ctx = new DDMSEntities())
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

            if (!String.IsNullOrEmpty(txt.Text))
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
                            int DivisionID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID && x.DivisionlID.HasValue).DivisionlID.Value;
                            int PriceID = ctx.OGCRDs.Where(x => x.CustomerID == ParentID && x.DivisionlID == DivisionID && x.PriceListID.HasValue).Select(x => x.PriceListID.Value).DefaultIfEmpty(0).FirstOrDefault();

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
}