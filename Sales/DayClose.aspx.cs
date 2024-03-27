using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.EntityClient;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Mail;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using MigraDoc.Rendering;

public partial class Sales_DayClose : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected decimal BillAmount = 0, Tax = 0, Total = 0;
    protected String AuthType;
    DDMSEntities ctx;

    private List<EOD3> EOD3s
    {
        get { return this.ViewState["EOD3s"] as List<EOD3>; }
        set { this.ViewState["EOD3s"] = value; }
    }

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        var CDate = Common.DateTimeConvert(txtDate.Text);

        var DayCloseData = ctx.CheckDayClose(CDate, ParentID).FirstOrDefault();

        btnSubmit.Visible = true;
        if (!String.IsNullOrEmpty(DayCloseData))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
            btnSubmit.Visible = false;
            var arrData = DayCloseData.Split('=');
            if (!arrData[0].Contains("Day already has been closed."))
            {
                if (arrData[0].Contains("Next date "))
                {
                    btnSubmit.Visible = false;
                }
                else
                {
                    CDate = Common.DateTimeConvert(arrData[1].ToString());
                    txtDate.Text = arrData[1].ToString().Trim();
                    btnSubmit.Visible = true;
                }
            }
            else
            {
                CDate = Common.DateTimeConvert(arrData[1].ToString());
                txtDate.Text = arrData[1].ToString().Trim();
                btnSubmit.Visible = false;
            }
        }

        var OpeningAmt = (from c in ctx.OEODs
                          where c.EmpID == UserID && c.ParentID == ParentID && !(c.Date.Day == CDate.Day && c.Date.Month == CDate.Month && c.Date.Year == CDate.Year)
                          orderby c.Date descending
                          select c).FirstOrDefault();

        if (OpeningAmt != null)
            txtOpening.Text = OpeningAmt.PettyCash.ToString("0.00");
        else
            txtOpening.Text = "0.00";


        var Item = ctx.DayCloseItem(ParentID, Common.DateTimeConvert(txtDate.Text), UserID).ToList();
        gvItem.DataSource = Item;
        gvItem.DataBind();

        EOD3s = new List<EOD3>();
        EOD3s.Add(new EOD3());
        gvExpense.DataSource = EOD3s;
        gvExpense.DataBind();
        var ObjPurchase = ctx.OMIDs.Include("MID1").Where(x => (x.InwardType == (int)InwardType.DirectReceipt || x.InwardType == (int)InwardType.Receipt) && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day && x.ParentID == ParentID).ToList();
        txtPurchase.Text = ObjPurchase.Sum(x => x.Total).GetValueOrDefault(0).ToString("0.00");
        txtPurchaseReturn.Text = ctx.ORETs.Where(x => x.ParentID == ParentID && (x.Type == "3" || x.Type == "4") && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day).ToList().Sum(x => x.Amount).ToString("0.00");
        txtPPayment.Text = ObjPurchase.Sum(x => x.MID2.Sum(y => y.Amount)).ToString("0.00");

        txtSaleCash.Text = ctx.OPOS.Where(x => (new int[] { 12, 13 }.Contains(x.OrderType)) && x.ParentID == ParentID && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day).Select(x => x.Total).DefaultIfEmpty(0).Sum().ToString("0.00");
        txtSaleOther.Text = ctx.POS2.Where(x => x.ParentID == ParentID && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day && x.PaymentMode != 1).Select(x => x.Amount).DefaultIfEmpty(0).Sum().ToString("0.00");

        txtOpenSO.Text = ctx.OPOS.Where(x => x.ParentID == ParentID && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day && x.OrderType == (int)SaleOrderType.Order).ToList().Sum(x => x.Total).ToString("0.00");
        txtAdvance.Text = "";

        txtDispatch.Text = ctx.OMIDs.Where(x => (x.InwardType == (int)InwardType.Receipt || x.InwardType == (int)InwardType.Delivery) && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day && x.VendorParentID == ParentID).ToList().Sum(x => x.Total).GetValueOrDefault(0).ToString("0.00");
        // txtTransfer.Text = ctx.OMIDs.Where(x => (x.InwardType == (int)InwardType.TransferReceipt || x.InwardType == (int)InwardType.Transfer) && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day && x.VendorParentID == ParentID).ToList().Sum(x => x.Total).GetValueOrDefault(0).ToString("0.00");
        txtConsume.Text = ctx.OMITs.Where(x => x.ParentID == ParentID && x.Type == "M" && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day).ToList().Sum(x => x.Amount).ToString("0.00");
        txtWastage.Text = ctx.OMITs.Where(x => x.ParentID == ParentID && x.Type == "W" && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day).ToList().Sum(x => x.Amount).ToString("0.00");
        txtReturn.Text = ctx.ORETs.Where(x => x.ParentID == ParentID && (x.Type == "1" || x.Type == "2") && x.Date.Year == CDate.Year && x.Date.Month == CDate.Month && x.Date.Day == CDate.Day).ToList().Sum(x => x.Amount).ToString("0.00");

        txtCashClosingNote.Text = "";
        txtMisExp.Text = txtActualAmount.Text = txtOtherClosing.Text = txtPettyCash.Text = txtCashClosing.Text = "0.00";
        txt1000.Text = txt500.Text = txt100.Text = txt50.Text = txt20.Text = txt10.Text = txt5.Text = txt2.Text = txt1.Text = txt0.Text = "";
        chkIsConfirm.Checked = false;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "Summary(); $.cookie('DayClose', 'tabs-1');", true);
    }

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
                        var unit = xml.Descendants("employee_master");
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            txtDate.Text = Common.DateTimeConvert(DateTime.Now);
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, System.EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                var CDate = Common.DateTimeConvert(txtDate.Text);

                var DayCloseData = ctx.CheckDayClose(CDate, ParentID).FirstOrDefault();

                if (!String.IsNullOrEmpty(DayCloseData))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + DayCloseData + "',3);", true);
                    return;
                }

                Decimal DecNum = 0;
                int IntNum = 0;
                if (gvItem.Rows.Count > 0)
                {
                    OEOD objOEOD = new OEOD();
                    objOEOD = ctx.OEODs.Include("EOD1").Include("EOD2").FirstOrDefault(x => x.EmpID == UserID && x.Date == CDate && x.ParentID == ParentID);
                    if (objOEOD == null)
                    {
                        objOEOD = new OEOD();
                        objOEOD.DayCloseID = ctx.GetKey("OEOD", "DayCloseID", "", ParentID, 0).FirstOrDefault().Value;
                        objOEOD.ParentID = ParentID;
                        objOEOD.Date = CDate;
                        objOEOD.EmpID = UserID;
                        ctx.OEODs.Add(objOEOD);
                    }

                    if (Decimal.TryParse(txtOpening.Text, out DecNum))
                        objOEOD.Opening = DecNum;
                    if (Decimal.TryParse(txtPurchase.Text, out DecNum))
                        objOEOD.Inward = DecNum;
                    if (Decimal.TryParse(txtPurchaseReturn.Text, out DecNum))
                        objOEOD.ReturnQty = DecNum;
                    if (Decimal.TryParse(txtPPayment.Text, out DecNum))
                        objOEOD.PPayment = DecNum;
                    if (Decimal.TryParse(txtDispatch.Text, out DecNum))
                        objOEOD.Dispatch = DecNum;
                    if (Decimal.TryParse(txtTransfer.Text, out DecNum))
                        objOEOD.Transfer = DecNum;
                    if (Decimal.TryParse(txtSaleCash.Text, out DecNum))
                        objOEOD.RetailSales = DecNum;
                    if (Decimal.TryParse(txtSaleOther.Text, out DecNum))
                        objOEOD.OtherSales = DecNum;
                    if (Decimal.TryParse(txtOpenSO.Text, out DecNum))
                        objOEOD.OtherSale = DecNum;
                    if (Decimal.TryParse(txtReturn.Text, out DecNum))
                        objOEOD.SaleRturn = DecNum;
                    if (Decimal.TryParse(txtAdvance.Text, out DecNum))
                        objOEOD.Advance = DecNum;
                    if (Decimal.TryParse(txtMisExp.Text, out DecNum))
                        objOEOD.MiscExpense = DecNum;
                    if (Decimal.TryParse(txtConsume.Text, out DecNum))
                        objOEOD.Consume = DecNum;
                    if (Decimal.TryParse(txtWastage.Text, out DecNum))
                        objOEOD.Wastage = DecNum;
                    if (Decimal.TryParse(txtActualAmount.Text, out DecNum))
                        objOEOD.PaidAmount = DecNum;
                    if (Decimal.TryParse(txtPettyCash.Text, out DecNum))
                        objOEOD.PettyCash = DecNum;
                    if (Decimal.TryParse(txtCashClosing.Text, out DecNum))
                        objOEOD.Closing = DecNum;
                    if (Decimal.TryParse(txtOtherClosing.Text, out DecNum))
                        objOEOD.OtherClosing = DecNum;

                    objOEOD.WholeSales = 0;
                    objOEOD.UnPaidAmount = 0;
                    objOEOD.Notes = txtCashClosingNote.Text;
                    //objOEOD.IsConfirm = true;

                    if (chkIsConfirm.Checked == true)
                        objOEOD.IsConfirm = true;
                    else
                        objOEOD.IsConfirm = false;

                    int Count2 = ctx.GetKey("EOD2", "EOD2ID", "", ParentID, null).FirstOrDefault().Value;
                    int Count3 = ctx.GetKey("EOD3", "EOD3ID", "", ParentID, null).FirstOrDefault().Value;
                    int Count4 = ctx.GetKey("EOD4", "EOD4ID", "", ParentID, null).FirstOrDefault().Value;
                    int ItemID = 0;

                    if (Decimal.TryParse(txtActualAmount.Text, out DecNum) && DecNum > 0)
                    {
                        EOD1 objEOD1 = objOEOD.EOD1.FirstOrDefault();
                        if (objEOD1 == null)
                        {
                            objEOD1 = new EOD1();
                            objEOD1.EOD1ID = ctx.GetKey("EOD1", "EOD1ID", "", ParentID, 0).FirstOrDefault().Value;
                            objOEOD.EOD1.Add(objEOD1);
                        }

                        objEOD1.Note1000 = Int32.TryParse(txt1000.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note500 = Int32.TryParse(txt500.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note100 = Int32.TryParse(txt100.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note50 = Int32.TryParse(txt50.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note20 = Int32.TryParse(txt20.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note10 = Int32.TryParse(txt10.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note5 = Int32.TryParse(txt5.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note2 = Int32.TryParse(txt2.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Note1 = Int32.TryParse(txt1.Text, out IntNum) ? IntNum : 0;
                        objEOD1.Other = Decimal.TryParse(txt0.Text, out DecNum) ? DecNum : 0;
                        objEOD1.Amount = Decimal.TryParse(txtActualAmount.Text, out DecNum) ? DecNum : 0;
                    }

                    foreach (GridViewRow item in gvItem.Rows)
                    {
                        Label lblItemID = (Label)item.FindControl("lblItemID");
                        if (lblItemID != null && Int32.TryParse(lblItemID.Text, out ItemID))
                        {
                            EOD2 objEOD2 = objOEOD.EOD2.FirstOrDefault(x => x.ItemID == ItemID);
                            if (objEOD2 == null)
                            {
                                objEOD2 = new EOD2();
                                objEOD2.EOD2ID = Count2++;
                                objEOD2.ParentID = ParentID;
                                objEOD2.DayCloseID = objOEOD.DayCloseID;
                                objEOD2.ItemID = ItemID;
                                objOEOD.EOD2.Add(objEOD2);
                            }
                            Label lblOpening = item.FindControl("lblOpening") as Label;
                            Label lblInward = item.FindControl("lblInward") as Label;
                            Label lblDispatch = item.FindControl("lblDispatch") as Label;
                            Label lblReturn = item.FindControl("lblReturn") as Label;
                            Label lblConsume = item.FindControl("lblConsume") as Label;
                            Label lblWastage = item.FindControl("lblWastage") as Label;
                            Label lblSaleOrder = item.FindControl("lblSaleOrder") as Label;
                            Label lblGodwonSales = item.FindControl("lblGodwonSales") as Label;
                            Label lblRetailSales = item.FindControl("lblRetailSales") as Label;
                            Label lblSaleReturn = item.FindControl("lblSaleReturn") as Label;
                            Label lblGainLoss = item.FindControl("lblGainLoss") as Label;
                            Label lblClosing = item.FindControl("lblClosing") as Label;

                            objEOD2.Opening = Decimal.TryParse(lblOpening.Text, out DecNum) ? DecNum : 0;
                            objEOD2.Inward = Decimal.TryParse(lblInward.Text, out DecNum) ? DecNum : 0;
                            objEOD2.Dispatch = Decimal.TryParse(lblDispatch.Text, out DecNum) ? DecNum : 0;
                            objEOD2.PurchaseReturn = Decimal.TryParse(lblReturn.Text, out DecNum) ? DecNum : 0;
                            objEOD2.Transfer = 0;
                            objEOD2.Consume = Decimal.TryParse(lblConsume.Text, out DecNum) ? DecNum : 0;
                            objEOD2.GodownSale = Decimal.TryParse(lblGodwonSales.Text, out DecNum) ? DecNum : 0;
                            objEOD2.OtherSale = Decimal.TryParse(lblSaleOrder.Text, out DecNum) ? DecNum : 0;
                            objEOD2.RetailSale = Decimal.TryParse(lblRetailSales.Text, out DecNum) ? DecNum : 0;
                            objEOD2.WholeSale = 0;
                            objEOD2.SaleReturn = Decimal.TryParse(lblSaleReturn.Text, out DecNum) ? DecNum : 0;
                            objEOD2.Wastage = Decimal.TryParse(lblWastage.Text, out DecNum) ? DecNum : 0;
                            objEOD2.GainLoss = Decimal.TryParse(lblGainLoss.Text, out DecNum) ? DecNum : 0;
                            objEOD2.Closing = Decimal.TryParse(lblClosing.Text, out DecNum) ? DecNum : 0;
                            objEOD2.UnitPrice = 0;

                        }
                    }

                    //objOEOD.EOD3.ToList().ForEach(x => ctx.EOD3.Remove(x));
                    objOEOD.EOD3.ToList().ForEach(x => x.IsDeleted = true);
                    foreach (EOD3 item in EOD3s)
                    {
                        if (item.ExpenseID > 0)
                        {
                            EOD3 objEOD3 = new EOD3();
                            objEOD3.EOD3ID = Count3++;
                            objEOD3.ExpenseID = item.ExpenseID;
                            objEOD3.Amount = item.Amount;
                            objEOD3.Notes = item.Notes;
                            objOEOD.EOD3.Add(objEOD3);
                        }
                    }

                    if (chkIsConfirm.Checked && objOEOD.EOD4.Count() == 0)
                    {
                        foreach (EOD2 item in objOEOD.EOD2)
                        {
                            var Ids = ctx.ITM3.Where(x => x.ItemID == item.ItemID).Select(x => new { x.UnitID, x.Qty }).ToList();
                            foreach (var id in Ids)
                            {
                                EOD4 objEOD4 = new EOD4();
                                objEOD4.EOD4ID = Count4++;
                                objEOD4.ItemID = item.ItemID;
                                objEOD4.UnitID = id.UnitID;
                                objEOD4.Qty = id.Qty;
                                objOEOD.EOD4.Add(objEOD4);
                            }
                        }
                    }

                    ctx.SaveChanges();
                    if (chkIsConfirm.Checked)
                        Session["LoginFlag"] = "1";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOEOD.DayCloseID + "',1);", true);

                    //int DaycloseID = objOEOD.DayCloseID;
                    //DateTime date = objOEOD.Date;

                    //Thread t = new Thread(() => { SendDayCloseMail(DaycloseID, ParentID, date); });
                    //t.Name = Guid.NewGuid().ToString();
                    //t.Start();

                    ClearAllInputs();


                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No item found for day close!',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Sales.aspx");
    }

    #endregion

    #region GridView Events

    protected void gvItem_PreRender(object sender, EventArgs e)
    {
        if (gvItem.Rows.Count > 0)
        {
            gvItem.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvItem.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region TextChangeEvents

    protected void txtDate_TextChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void txtExpName_TextChanged(object sender, EventArgs e)
    {
        if (EOD3s == null)
        {
            EOD3s = new List<EOD3>();
            EOD3s.Add(new EOD3());
        }
        TextBox txtExpName = (TextBox)sender;

        GridViewRow Currentgvr = (GridViewRow)txtExpName.NamingContainer;
        Decimal Amount;
        if (txtExpName.ID == "txtAmount" && Decimal.TryParse(txtExpName.Text, out Amount))
        {
            EOD3s[Currentgvr.RowIndex].Amount = Amount;
        }
        else if (txtExpName.ID == "txtNotes")
        {
            EOD3s[Currentgvr.RowIndex].Notes = txtExpName.Text;
        }
        else if (txtExpName.ID == "txtExpName")
        {
            if (txtExpName != null && !String.IsNullOrEmpty(txtExpName.Text))
            {
                var Data = txtExpName.Text.Split("-".ToArray());
                if (Data.Length > 1)
                {
                    int ID = Convert.ToInt32(Data[0].Trim());
                    var objOEXP = ctx.OEXPs.FirstOrDefault(x => x.ExpenseID == ID && x.ParentID == ParentID);
                    if (objOEXP != null)
                    {
                        if (!EOD3s.Any(x => x.ExpenseID == objOEXP.ExpenseID))
                        {
                            EOD3s[Currentgvr.RowIndex].ExpenseID = objOEXP.ExpenseID;
                            EOD3s[Currentgvr.RowIndex].OEXP = objOEXP;
                            EOD3s.Add(new EOD3());
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same expense is not allowed.',3);", true);
                            txtExpName.Text = "";
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper expense.',3);", true);
                        txtExpName.Text = "";
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper expense.',3);", true);
                    txtExpName.Text = "";
                }
            }
            else
            {
                EOD3s.RemoveAt(Currentgvr.RowIndex);
            }
            gvExpense.DataSource = EOD3s;
            gvExpense.DataBind();
        }
        txtExpName.Focus();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeExpense();", true);
    }

    #endregion

    protected void gvExpense_PreRender(object sender, EventArgs e)
    {
        if (gvExpense.Rows.Count > 0)
        {
            gvExpense.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvExpense.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    public void SendDayCloseMail(int DaycloseID, Decimal ParentID, DateTime date)
    {

        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OCRD ObjOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                if (ObjOCRD.OGCRDs.Any(x => x.PlantID.HasValue))
                {
                    int PlantID = ObjOCRD.OGCRDs.FirstOrDefault(x => x.PlantID.HasValue).PlantID.Value;
                    EML2 objEML2 = ctx.EML2.FirstOrDefault(x => x.DocType == "D" && x.PlantID == PlantID);

                    if (objEML2 != null)
                    {
                        String SavePath = "";
                        List<String> Emails = new List<string>();
                        List<String> Attachments = new List<string>();
                        List<String> rptNames = new List<string>();
                        ConnectionInfo myConnectionInfo = new ConnectionInfo();

                        string connectString = System.Configuration.ConfigurationManager.ConnectionStrings["DDMSEntities"].ToString();
                        EntityConnectionStringBuilder Builder = new EntityConnectionStringBuilder(connectString);
                        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(Builder.ProviderConnectionString);

                        #region Material Status

                        ReportDocument myReport = new ReportDocument();
                        myReport.Load(Server.MapPath("~/Reports/CrystalReports/MaterialStatus.rpt"));

                        myReport.SetParameterValue("@FromDate", date);
                        myReport.SetParameterValue("@ToDate", date);
                        myReport.SetParameterValue("@ItemGroupID", "0");

                        myReport.SetParameterValue("@EmpID", UserID);
                        myReport.SetParameterValue("@ParentID", ParentID);
                        myReport.SetParameterValue("@LogoImage", ObjOCRD.Photo != null ? Server.MapPath(Constant.CustomerPhoto) + ObjOCRD.Photo : Server.MapPath("~/Images/LOGO.jpg"));

                        Tables myTables = myReport.Database.Tables;

                        foreach (CrystalDecisions.CrystalReports.Engine.Table myTable in myTables)
                        {
                            TableLogOnInfo myTableLogonInfo = myTable.LogOnInfo;
                            myConnectionInfo.ServerName = builder.DataSource;
                            myConnectionInfo.DatabaseName = builder.InitialCatalog;
                            myConnectionInfo.UserID = builder.UserID;
                            myConnectionInfo.Password = builder.Password;
                            myTableLogonInfo.ConnectionInfo = myConnectionInfo;
                            myTable.ApplyLogOnInfo(myTableLogonInfo);
                        }

                        SavePath = Server.MapPath("~/Document/ReportPDF/" + "MaterialStatus" + "_" + date.ToString("ddMMyyyyHHmmss") + ".pdf");
                        myReport.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, SavePath);

                        Attachments.Add(SavePath);

                        #endregion

                        #region Gross Dealer Summary

                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();

                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetDealerSummary";

                        Cm.Parameters.AddWithValue("@FromDate", date);
                        Cm.Parameters.AddWithValue("@ToDate", date);
                        Cm.Parameters.AddWithValue("@CustomerID", "0");
                        Cm.Parameters.AddWithValue("@DisCust", "0");
                        Cm.Parameters.AddWithValue("@ParentID", ParentID);

                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        DataTable dt = ds.Tables[0];
                        if (dt.Columns.Count > 1)
                        {
                            dt.Columns.Remove("CustomerID");
                            dt.Columns.Remove("Discount");
                        }


                        String Body = "Hello Sir,   <br /> <br /> Report Details of " + ObjOCRD.CustomerName + " Outlet for the date " + date.ToString(Constant.DateFormat) + "<br /> Thanks";
                        String Subject = "Dealer Summary of " + ObjOCRD.CustomerName + " for the date " + date.ToString("ddMMyyyy");

                        PDFForm pdfForm = new PDFForm(dt, Server.MapPath("~/Images/logo.png"), Subject, ObjOCRD.CustomerName, date.ToString("ddMMyyyy"));
                        MigraDoc.DocumentObjectModel.Document document = pdfForm.CreateDocument();
                        document.UseCmykColor = true;
                        PdfDocumentRenderer pdfRenderer = new PdfDocumentRenderer(true);
                        pdfRenderer.Document = document;
                        pdfRenderer.RenderDocument();

                        SavePath = Server.MapPath("~/Document/ReportPDF/" + "GrossDealerSummary" + "_" + date.ToString("ddMMyyyyHHmmss") + ".pdf");
                        pdfRenderer.Save(SavePath);

                        Attachments.Add(SavePath);

                        #endregion

                        Common.SendMail("Vadilal - Report Detail", Body, objEML2.SuccessEmail, "", Attachments, null);
                    }
                }
            }
        }
        catch (Exception)
        {

        }
    }

}