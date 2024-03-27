using System;
using System.Collections.Generic;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Purchase_Delivery : System.Web.UI.Page
{
    #region Property

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }


    public void ClearAllInputs()
    {
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

        // txtTemplate.Style.Add("background-color", "rgb(250, 255, 189);");

        gvItem.DataSource = null;
        gvItem.DataBind();

        txtBillAmount.Text = txtDiscount.Text = txtPaid.Text = txtPending.Text = txtRounding.Text = txtTax.Text = txtTotal.Text = "0";
        txtPaidTo.Text = txtNotes.Text = txtBillNumber.Text = "";

        txtDocNo.Text = "Auto Generated";
        ddlInwardType.DataSource = EnumList.Of<InwardType>().Where(x => x.Key < 5).ToList();
        ddlInwardType.DataBind();
        ddlInwardType.SelectedItem.Text = InwardType.Delivery.ToString();
        ddlInwardType_SelectedIndexChanged(ddlInwardType, EventArgs.Empty);
        var Data = ctx.OWHS.Where(x => x.ParentID == ParentID && x.Active).ToList();
        ddlWhs.DataSource = Data;
        ddlWhs.DataBind();
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs();
            ddlVendor.Focus();
        }
    }

    #endregion

    #region DropDown Events

    protected void ddlInwardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlInwardType.SelectedItem.Text == InwardType.Delivery.ToString())
        {
            hdnType.Value = "2";
            lblVendor.Text = "Customer";
            ddlVendor.DataSource = ctx.OCRDs.Where(x => x.ParentID == ParentID).Select(x => new { CustomerID = SqlFunctions.StringConvert((double)x.CustomerID, 20), x.CustomerName }).ToList();
            ddlVendor.DataValueField = "CustomerID";
            ddlVendor.DataTextField = "CustomerName";
            ddlVendor.DataBind();
            ddlVendor.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlVendor.Enabled = true;

            txtDocNo.Text = "Auto Generated";
            txtDocNo.Enabled = false;
            txtDocNo.Style.Remove("background-color");

            txtBillDate.Text = Common.DateTimeConvert(DateTime.Now);
            txtBillDate.Enabled = true;
            txtReceiveDate.Text = "";
            txtDate.Enabled = txtReceiveDate.Enabled = false;

            //txtTemplate.Style.Remove("background-color");
            //txtTemplate.Text = "";
            //txtTemplate.Enabled = false;
            //lblVehicle.Visible = false;
            //txtVehicleNo.Text = "";
            //txtVehicleNo.Visible = false;
        }
        else
        {
            hdnType.Value = "0";
        }

        gvItem.DataSource = null;
        gvItem.DataBind();
        txtBillAmount.Text = txtDiscount.Text = txtPaid.Text = txtPending.Text = txtRounding.Text = txtTax.Text = txtTotal.Text = "0";
        txtPaidTo.Text = txtNotes.Text = txtBillNumber.Text = "";
    }

    protected void ddlVendor_SelectedIndexChanged(object sender, EventArgs e)
    {
        int ID;
        int WhsID;
        if (Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
        {
            if (ddlInwardType.SelectedItem.Text == InwardType.Delivery.ToString())
            {
                Decimal CustID;
                if (Decimal.TryParse(ddlVendor.SelectedValue, out CustID) && CustID > 0)
                {
                    txtDocNo.Text = "";
                    txtDocNo.Enabled = true;
                    txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");
                    acetxtDocNumber.ContextKey = "1," + CustID;
                    acetxtDocNumber.Enabled = true;

                    ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Request").SingleOrDefault()).Visible = true;
                    ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Dispatch").SingleOrDefault()).Visible = true;
                    ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Reciept").SingleOrDefault()).Visible = false;
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Inward Type',3);", true);
            }
        }
        gvItem.DataBind();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
    }

    #endregion

    #region TextBox Events

    protected void txtDocNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            Int32 InwardID;
            int WhsID;
            var Data = txtDocNo.Text.Split("-".ToArray());
            if (Data.Length >= 2)
            {
                if (Int32.TryParse(Data.FirstOrDefault(), out InwardID))
                {
                    if (ddlVendor.SelectedValue != null && Int32.TryParse(ddlWhs.SelectedValue, out WhsID) && WhsID > 0)
                    {
                        OMID objOMID = null;
                        if (ddlInwardType.SelectedItem.Text == InwardType.Delivery.ToString())
                        {
                            Decimal CustID = Convert.ToDecimal(ddlVendor.SelectedValue);
                            objOMID = ctx.OMIDs.Include("MID1").Include("MID1.OITM").FirstOrDefault(x => x.ParentID == CustID && x.InwardType == (int)InwardType.Purchase && x.Status == "O" && x.InwardID == InwardID);

                            ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Request").SingleOrDefault()).Visible = true;
                            ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Dispatch").SingleOrDefault()).Visible = true;
                            ((DataControlField)gvItem.Columns.Cast<DataControlField>().Where(fld => fld.HeaderText == "Reciept").SingleOrDefault()).Visible = false;
                        }
                        if (objOMID != null)
                        {
                            gvItem.DataSource = objOMID.MID1.ToList();
                            gvItem.DataBind();

                            foreach (GridViewRow item in gvItem.Rows)
                            {
                                if (ddlInwardType.SelectedItem.Text == InwardType.Delivery.ToString())
                                {
                                    item.Cells[5].Enabled = false;
                                }
                                else
                                {
                                    item.Cells[5].Enabled = false;
                                    item.Cells[6].Enabled = false;
                                }
                            }

                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

                            txtDate.Text = Common.DateTimeConvert(objOMID.Date);
                            txtBillNumber.Text = objOMID.BillNumber;
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
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('There is a no purchase order of this number',3);", true);
                            ClearAllInputs();
                        }
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Customer First',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Order Number',3);", true);
            }
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Proper Order Number',3);", true);
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
            MID1 Data = e.Row.DataItem as MID1;
            if (Data.ItemID > 0)
            {
                Label lblUnitID = (Label)e.Row.FindControl("lblUnitID");
                Label lblUnit = (Label)e.Row.FindControl("lblUnit");
                DropDownList ddlUnit = (DropDownList)e.Row.FindControl("ddlUnit");

                if (hdnType.Value == "2")
                {
                    lblUnitID.Text = Data.UnitID + "," + Data.Price + "," + Data.PriceTax + "," + Data.MapQty;

                    lblUnitID.Visible = lblUnit.Visible = true;
                    ddlUnit.Visible = false;
                }

                Label lblItemID = (Label)e.Row.FindControl("lblItemID");
                System.Web.UI.HtmlControls.HtmlInputHidden hdnAvailQty = (System.Web.UI.HtmlControls.HtmlInputHidden)e.Row.FindControl("hdnAvailQty");

                int WhsID = Convert.ToInt32(ddlWhs.SelectedValue);
                int ItemID = Convert.ToInt32(lblItemID.Text);
                var objITM2 = ctx.ITM2.FirstOrDefault(x => x.WhsID == WhsID && x.ParentID == ParentID && x.ItemID == ItemID);
                if (objITM2 != null)
                    hdnAvailQty.Value = objITM2.TotalPacket.ToString();
            }
        }
    }

    #endregion

    #region Button Events

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Purchase.aspx");
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            ddlInwardType.SelectedValue = "2";  // for Dispatch/Delivery

            Int32 InwardTypeInt = 0;
            if (ddlInwardType.SelectedValue == null || !Int32.TryParse(ddlInwardType.SelectedValue, out InwardTypeInt))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Inward Type',3);", true);
                return;
            }
            Int32 WhsID = 0;
            if (!Int32.TryParse(ddlWhs.SelectedValue, out WhsID))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select Warehouse.',3);", true);
                return;
            }

            OMID objOMID = null;
            DateTime dt;
            Decimal DecNum;
            Int32 IntNum;
            if (InwardTypeInt == (int)InwardType.Delivery)
            {
                int InwardID;
                decimal CustID = 0;
                var DocData = txtDocNo.Text.Split("-".ToArray());
                if (DocData.Length >= 2)
                {
                    if (Int32.TryParse(DocData.FirstOrDefault(), out InwardID))
                    {
                        CustID = Convert.ToDecimal(ddlVendor.SelectedValue);
                        objOMID = ctx.OMIDs.Include("MID1").Include("MID1.OITM").FirstOrDefault(x => x.ParentID == CustID && x.InwardType == (int)InwardType.Purchase && x.Status == "O" && x.InwardID == InwardID);
                        objOMID.InwardType = InwardTypeInt;
                        objOMID.FromWhsID = WhsID;
                        objOMID.BillDate = DateTime.Now;
                        objOMID.ReceiveDate = null;
                        if (Common.DateTimeConvert(txtBillDate.Text, out dt))
                            objOMID.BillDate = dt;
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
                }
            }

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

            int Count = ctx.GetKey("MID1", "MID1ID", "", ParentID, null).FirstOrDefault().Value;
            int CountM = ctx.GetKey("ITM2", "StockID", "", ParentID, null).FirstOrDefault().Value;
            string[] Data;
            int ItemID = 0;
            foreach (GridViewRow item in gvItem.Rows)
            {
                Label lblItemID = (Label)item.FindControl("lblItemID");
                TextBox txtTotalQty = (TextBox)item.FindControl("txtTotalQty");

                if (Int32.TryParse(lblItemID.Text, out ItemID) && ItemID > 0
                    && Decimal.TryParse(txtTotalQty.Text, out DecNum))
                {
                    DropDownList ddlUnit = (DropDownList)item.FindControl("ddlUnit");
                    Label lblUnitID = (Label)item.FindControl("lblUnitID");

                    TextBox txtAvailQty = (TextBox)item.FindControl("txtAvailQty");
                    TextBox txtRequestQty = (TextBox)item.FindControl("txtRequestQty");
                    TextBox txtDisptchQty = (TextBox)item.FindControl("txtDisptchQty");
                    TextBox txtRecieptQty = (TextBox)item.FindControl("txtRecieptQty");
                    TextBox txtDiffirenceQty = (TextBox)item.FindControl("txtDiffirenceQty");

                    TextBox lblSubTotal = (TextBox)item.FindControl("lblSubTotal");
                    TextBox lblTax = (TextBox)item.FindControl("lblTax");
                    TextBox lblTotalPrice = (TextBox)item.FindControl("lblTotalPrice");

                    if (InwardTypeInt == (int)InwardType.Delivery)
                    {
                        if (Convert.ToDecimal(txtDisptchQty.Text) > Convert.ToDecimal(txtAvailQty.Text))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Dispatch quantity must be less than or equal to warehouse qty!',3);", true);
                            return;
                        }
                    }

                    if (ddlUnit.SelectedValue.Split(",".ToArray()).Length == 4)
                        Data = ddlUnit.SelectedValue.Split(",".ToArray());
                    else
                        Data = lblUnitID.Text.Split(",".ToArray());

                    if (Data.Length == 4)
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

                        objMID1.Price = Decimal.TryParse(Data[1], out DecNum) ? DecNum : 0;

                        DecNum = Convert.ToDecimal(Data[2]);
                        objMID1.PriceTax = (objMID1.Price * DecNum) / 100;

                        objMID1.MapQty = Decimal.TryParse(Data[3], out DecNum) ? DecNum : 0;

                        objMID1.AvailableQty = Decimal.TryParse(txtAvailQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.RequestQty = Decimal.TryParse(txtRequestQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.DisptchQty = Decimal.TryParse(txtDisptchQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.DiffirenceQty = Decimal.TryParse(txtDiffirenceQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.RecieptQty = Decimal.TryParse(txtRecieptQty.Text, out DecNum) ? DecNum : 0;
                        objMID1.SubTotal = Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                        objMID1.Tax = Decimal.TryParse(lblTax.Text, out DecNum) ? DecNum : 0;
                        objMID1.Total = Decimal.TryParse(lblTotalPrice.Text, out DecNum) ? DecNum : 0;

                        objOMID.MID1.Add(objMID1);

                        if (objMID1.DisptchQty > 0 && hdnType.Value == "2")
                        {
                            ITM2 ITM2 = ctx.ITM2.FirstOrDefault(x => x.ParentID == ParentID && x.WhsID == WhsID && x.ItemID == objMID1.ItemID);
                            if (ITM2 == null)
                            {
                                ITM2 = new ITM2();
                                ITM2.StockID = CountM++;
                                ITM2.ParentID = ParentID;
                                ITM2.WhsID = WhsID;
                                ITM2.ItemID = objMID1.ItemID;
                                ctx.ITM2.Add(ITM2);
                            }
                            ITM2.TotalPacket -= objMID1.TotalQty;
                        }
                    }
                }
            }
            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Order Inserted Successfully: OrderID: " + objOMID.InwardID.ToString() + "',1);", true);
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}