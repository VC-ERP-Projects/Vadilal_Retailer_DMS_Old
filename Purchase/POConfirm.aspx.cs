using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using WebReference;

public partial class Purchase_POConfirm : System.Web.UI.Page
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
                        objOMID.InProcess = true;
                        ctx.SaveChanges();
                        if (ctx.OGCRDs.Any(x => x.SaleOrgID.HasValue && x.CustomerID == ParentID)
                            && ctx.OGCRDs.Any(x => x.PlantID.HasValue && x.DivisionlID == DivisionID && x.CustomerID == ParentID))
                        {

                            OPLT objOPLT = ctx.OGCRDs.FirstOrDefault(x => x.PlantID.HasValue && x.DivisionlID == DivisionID && x.CustomerID == ParentID).OPLT;
                            objOMID.PlantID = objOPLT.PlantID;
                            #region Indent Order

                            try
                            {
                                DT_IndentCreation_Response Response = new DT_IndentCreation_Response();
                                SI_SynchOut_IndentCreationService _proxy = new SI_SynchOut_IndentCreationService();
                                _proxy.Url = objOCFG.SAPLINK;
                                _proxy.Timeout = 3000000;
                                _proxy.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);

                                DT_IndentCreation_Request Request = new DT_IndentCreation_Request();
                                DT_IndentCreation_RequestItem[] D4 = new DT_IndentCreation_RequestItem[1];
                                DT_IndentCreation_RequestItem1[] D5 = new DT_IndentCreation_RequestItem1[objOMID.MID1.Count];

                                Request = new DT_IndentCreation_Request();
                                D4 = new DT_IndentCreation_RequestItem[1];

                                int j = 0;
                                D4[j] = new DT_IndentCreation_RequestItem();
                                D4[j].DistributionChannel = "11";
                                D4[j].Division = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == DivisionID).DivisionCode;
                                D4[j].DocumentType = "ZORD";
                                D4[j].SalesOrganization = ctx.OGCRDs.FirstOrDefault(x => x.SaleOrgID.HasValue && x.DivisionlID == DivisionID && x.PlantID == objOPLT.PlantID && x.CustomerID == ParentID).OSRG.SaleOrgCode;
                                D4[j].ShipToParty = objOCRD.CustomerCode;
                                D4[j].SoldToParty = objOCRD.CustomerCode;
                                D4[j].TransactionType = "A";
                                D4[j].Plant = objOPLT.PlantCode;
                                D4[j].DMS_REFNO = objOMID.InwardID.ToString();

                                int i = 0;
                                D5 = new DT_IndentCreation_RequestItem1[objOMID.MID1.Count];
                                foreach (MID1 obj in objOMID.MID1)
                                {
                                    if (i > objOMID.MID1.Count)
                                    {
                                        break;
                                    }
                                    D5[i] = new DT_IndentCreation_RequestItem1();
                                    D5[i].MaterialNumber = ctx.OITMs.FirstOrDefault(x => x.ItemID == obj.ItemID).ItemCode;
                                    D5[i].Quantity = obj.RequestQty.ToString("0.000");
                                    i = i + 1;
                                }
                                Request.REPEAT_FLAG = "X";
                                Request.IT_HEADER = D4;
                                Request.IT_ITEM = D5;
                                Response = _proxy.SI_SynchOut_IndentCreation(Request);
                                objOMID.Ref1 = Response.MESSAGE;
                                objOMID.Ref2 = Response.FLAG;
                                objOMID.Ref3 = Response.NUMBER_INDENT;
                                objOMID.Ref4 = Response.STATUS;
                                objOMID.UpdatedDate = DateTime.Now;
                                objOMID.InProcess = false;
                                ctx.SaveChanges();
                            }
                            catch (Exception ex)
                            {
                                objOMID.Ref1 = Common.GetString(ex);
                                objOMID.Ref2 = "ERROR";
                                objOMID.UpdatedDate = DateTime.Now;
                                objOMID.InProcess = false;
                                ctx.SaveChanges();
                            }

                            #endregion

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
                                        var Message = Common.GetMailBodyPurchase(InwardID, ParentID);
                                        Common.SendMail("Vadilal - Purchase Order", Message, objOCRD.EMail1, "", null, null);
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
                                    if (objOMID.Ref2 != "SUCCESS")
                                    {
                                        try
                                        {
                                            var Message = Common.GetMailBodyPurchase(InwardID, ParentID, objOMID.Ref1);
                                            Common.SendMail("(ERROR) Vadilal - Purchase Order", Message, objEML2.FailureEmail, "", null, null);
                                        }
                                        catch (Exception)
                                        {

                                        }

                                        var SMSs = objEML2.FailureSMS.Split(",".ToArray());
                                        foreach (string item in SMSs)
                                        {
                                            if (!string.IsNullOrEmpty(item))
                                            {
                                                string Message = "Dear+Customer+Purchase Order+" + objOMID.InvoiceNumber + "+Dt.+" + Common.DateTimeConvert(objOMID.Date) + "+at+" + objOMID.Date.ToString("hh:mm tt")
                                                    + "+Qty+:+" + objOMID.MID1.Sum(x => x.TotalQty).ToString("0") + "+Rs.+" + objOMID.Total.Value.ToString("0.00") + "+generated+for+"
                                                    + objOCRD.CustomerCode + ",+" + objOCRD.CustomerName + ",+" + objOCRD.CRD1.FirstOrDefault().OCTY.CityName;

                                                Service wb = new Service();
                                                wb.SendSMS(item, Message);
                                            }
                                        }
                                    }
                                    else
                                    {
                                        try
                                        {
                                            var Message = Common.GetMailBodyPurchase(InwardID, ParentID);
                                            Common.SendMail("Vadilal - Purchase Order", Message, objEML2.SuccessEmail, "", null, null);
                                        }
                                        catch (Exception)
                                        {

                                        }

                                        var SMSs = objEML2.SuccessSMS.Split(",".ToArray());
                                        foreach (string item in SMSs)
                                        {
                                            if (!string.IsNullOrEmpty(item))
                                            {
                                                string Message = "Dear+Customer+Purchase Order+" + objOMID.InvoiceNumber + "+Dt.+" + Common.DateTimeConvert(objOMID.Date) + "+at+" + objOMID.Date.ToString("hh:mm tt")
                                                    + "+Qty+:+" + objOMID.MID1.Sum(x => x.TotalQty).ToString("0") + "+Rs.+" + objOMID.Total.Value.ToString("0.00") + "+generated+for+"
                                                    + objOCRD.CustomerCode + ",+" + objOCRD.CustomerName + ",+" + objOCRD.CRD1.FirstOrDefault().OCTY.CityName;

                                                Service wb = new Service();
                                                wb.SendSMS(item, Message);
                                            }
                                        }
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

    public void ClearAllInputs()
    {
        txtdealer.Text = "";
        txtDocNo.Text = "Auto Generated";
        txtDocNo.Enabled = false;
        txtDocNo.Style.Remove("background-color");

        txtdealer.Style.Add("background-color", "rgb(250, 255, 189);");

        txtDate.Enabled = false;

        gvItem.DataSource = null;
        gvItem.DataBind();
        txtBillAmount.Text = txtDiscount.Text = txtPaid.Text = txtPending.Text = txtRounding.Text = txtTax.Text = txtTotal.Text = "0";
        txtPaidTo.Text = txtNotes.Text = txtBillNumber.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        acetxtdealer.ContextKey = "2";
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtdealer.Focus();
        }
    }

    #endregion

    #region DropDown Events

    protected void ddlVendor_SelectedIndexChanged(object sender, EventArgs e)
    {
        Decimal CustID;
        string data = txtdealer.Text.Split("-".ToArray()).Last().Trim();
        if (Decimal.TryParse(data, out CustID) && CustID > 0)
        {
            txtDocNo.Text = "";
            txtDocNo.Enabled = true;
            txtDocNo.Style.Add("background-color", "rgb(250, 255, 189);");
            acetxtDocNumber.ContextKey = "1," + CustID;
            acetxtDocNumber.Enabled = true;
        }
        gvItem.DataSource = null;
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
            Decimal CustID;

            string Data = txtDocNo.Text.Split("-".ToArray()).First().Trim();
            string custdata = txtdealer.Text.Split("-".ToArray()).Last().Trim();

            if (!string.IsNullOrEmpty(Data) && !string.IsNullOrEmpty(custdata))
            {
                if (Int32.TryParse(Data, out InwardID) && InwardID > 0 && Decimal.TryParse(custdata, out CustID) && CustID > 0)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        OMID objOMID = ctx.OMIDs.Include("MID1").Include("MID1.OITM").FirstOrDefault(x => x.ParentID == CustID && x.InwardType == (int)InwardType.Purchase && x.Status == "O" && x.InwardID == InwardID);

                        if (objOMID != null)
                        {
                            gvItem.DataSource = objOMID.MID1.ToList();
                            gvItem.DataBind();

                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);

                            txtDate.Text = Common.DateTimeConvert(objOMID.Date);
                            txtBillNumber.Text = objOMID.InvoiceNumber;
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

                lblUnitID.Text = Data.UnitID + "," + Data.Price + "," + Data.PriceTax + "," + Data.MapQty;
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
            OMID objOMID = null;

            Decimal DecNum;
            Int32 IntNum;

            Int32 InwardID = 0;
            Decimal CustID;
            Int32 DivisionID = 0;
            Decimal CParentID = 0;
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string docData = txtDocNo.Text.Split("-".ToArray()).First().Trim();
                string custdata = txtdealer.Text.Split("-".ToArray()).Last().Trim();


                if (!string.IsNullOrEmpty(docData) && !string.IsNullOrEmpty(custdata))
                {
                    if (Int32.TryParse(docData, out InwardID) && InwardID > 0 && Decimal.TryParse(custdata, out CustID) && CustID > 0)
                    {
                        objOMID = ctx.OMIDs.Include("MID1").Include("MID1.OITM").FirstOrDefault(x => x.ParentID == CustID && x.InwardType == (int)InwardType.Purchase && x.Status == "O" && x.InwardID == InwardID);
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
                objOMID.UpdatedDate = DateTime.Now;
                objOMID.UpdatedBy = UserID;
                objOMID.Status = "O";
                objOMID.SubTotal = Decimal.TryParse(txtBillAmount.Text, out DecNum) ? DecNum : 0;
                objOMID.Discount = Decimal.TryParse(txtDiscount.Text, out DecNum) ? DecNum : 0;
                objOMID.Rounding = Decimal.TryParse(txtRounding.Text, out DecNum) ? DecNum : 0;
                objOMID.Tax = Decimal.TryParse(txtTax.Text, out DecNum) ? DecNum : 0;
                objOMID.Total = Decimal.TryParse(txtTotal.Text, out DecNum) ? DecNum : 0;
                objOMID.Paid = Decimal.TryParse(txtPaid.Text, out DecNum) ? DecNum : 0;
                objOMID.Pending = Decimal.TryParse(txtPending.Text, out DecNum) ? DecNum : 0;
                objOMID.Notes = txtNotes.Text;
                objOMID.PaidTo = txtPaidTo.Text;

                CParentID = objOMID.ParentID;

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
                        Label lblUnitID = (Label)item.FindControl("lblUnitID");

                        TextBox txtAvailQty = (TextBox)item.FindControl("txtAvailQty");
                        TextBox txtRequestQty = (TextBox)item.FindControl("txtRequestQty");

                        TextBox lblSubTotal = (TextBox)item.FindControl("lblSubTotal");
                        TextBox lblTax = (TextBox)item.FindControl("lblTax");
                        TextBox lblTotalPrice = (TextBox)item.FindControl("lblTotalPrice");
                        if (DivisionID == 0)
                        {
                            DivisionID = ctx.OGITMs.FirstOrDefault(x => x.ItemID == ItemID && x.DivisionlID.HasValue).DivisionlID.Value;
                        }
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
                            objMID1.TotalQty = Decimal.TryParse(txtTotalQty.Text, out DecNum) ? DecNum : 0;
                            objMID1.SubTotal = Decimal.TryParse(lblSubTotal.Text, out DecNum) ? DecNum : 0;
                            objMID1.Tax = Decimal.TryParse(lblTax.Text, out DecNum) ? DecNum : 0;
                            objMID1.Total = Decimal.TryParse(lblTotalPrice.Text, out DecNum) ? DecNum : 0;
                        }
                    }
                }

                ctx.SaveChanges();
            }
            Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

            Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); SendPurchaseinSAP(InwardID, CParentID, DivisionID); });
            t.Name = Guid.NewGuid().ToString();
            t.Start();

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Order Confirmed  Successfully: OrderID: " + objOMID.InwardID.ToString() + "',1);", true);
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}