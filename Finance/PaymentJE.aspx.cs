using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Finance_PaymentJE : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    decimal sumFooterValue = 0;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            gvVendor.DataSource = null;
            gvVendor.DataBind();
            txtNotes.Text = "";
            txtJEDate.Text = Common.DateTimeConvert(DateTime.Now);
            txtVendor.Style.Add("background-color", "rgb(250, 255, 189);");
            txtTotalAmount.Text = txtBankName.Text = txtDocumentNo.Text = "";
            ddlPayMode.DataSource = EnumList.Of<PurchasePaymentMode>().ToList();
            ddlPayMode.DataBind();
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
                            var unit = xml.Descendants("journal_entry");
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

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtFromDate.Text = txtTodate.Text = Common.DateTimeConvert(DateTime.Now);
            txtJEDate.Focus();
        }

    }

    #endregion

    #region Change Event

    //protected void ddlVendor_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    try
    //    {
    //        var Data = ddlVendor.SelectedValue.Split(",".ToArray());
    //        if (Data.Length == 2)
    //        {
    //            int vid = Convert.ToInt32(Data.FirstOrDefault());
    //            Decimal vpid = Convert.ToDecimal(Data.LastOrDefault());
    //            using (DDMSEntities ctx = new DDMSEntities())
    //            {
    //                var Payments = (from c in ctx.OMIDs
    //                                where new Int32[] { 3, 4, 7 }.Contains(c.InwardType) && c.Pending > 0 && c.ParentID == ParentID && c.VendorID == vid
    //                                && c.VendorParentID == vpid
    //                                select c).ToList();

    //            gvVendor.DataSource = Payments;
    //            gvVendor.DataBind();
    //            }
    //            txtBankName.Text = "";
    //            txtDocumentNo.Text = "";
    //            txtTotalAmount.Text = "";

    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
    //    }
    //}

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            bool errFound = true;

            if (Page.IsValid)
            {
                Decimal Amount = 0;
                int InwardID = 0;

                for (int i = 0; i < gvVendor.Rows.Count; i++)
                {
                    HtmlInputCheckBox chk = (HtmlInputCheckBox)gvVendor.Rows[i].FindControl("chkSelect");
                    if (chk.Checked == true)
                    {
                        errFound = false;
                    }
                }
                if (errFound == true)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select atleast one row!',3);", true);
                    return;
                }
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int CountM = ctx.GetKey("MID2", "MID2ID", "", ParentID, null).FirstOrDefault().Value;
                    int CountMJET = ctx.GetKey("MJET", "MJETID", "", ParentID, 0).FirstOrDefault().Value;

                    OPYM objOPYM = null;
                    // if General-Bulk Payment then make entry in OPYM
                    if (ddlPayOption.SelectedValue == "2")
                    {
                        foreach (GridViewRow item in gvVendor.Rows)
                        {
                            if (ddlPayMode.SelectedValue == ((int)PaymentMode.CreditNote).ToString())
                            {
                                int ID = Convert.ToInt32(txtDocumentNo.Text);
                                var objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == ID && x.ParentID == ParentID && x.Status == "C");

                                if (objOCNT == null && objOCNT.RemainAmount >= Amount)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Credit Note No: " + ID + " is not available or limit exceeded for this customer',1);", true);
                                    return;
                                }
                            }
                        }
                        int paymentID = ctx.GetKey("OPYM", "PaymentID", "", ParentID, 0).FirstOrDefault().Value;
                        objOPYM = new OPYM();
                        objOPYM.PaymentID = paymentID++;
                        objOPYM.ParentID = ParentID;
                        objOPYM.PaymentMode = Convert.ToInt32(ddlPayMode.SelectedValue);
                        objOPYM.DocumentName = txtBankName.Text;
                        objOPYM.DocumentNo = txtDocumentNo.Text;
                        objOPYM.Amount = Convert.ToDecimal(txtTotalAmount.Text);
                        objOPYM.CreatedDate = DateTime.Now;
                        objOPYM.Active = true;
                        objOPYM.CreatedBy = UserID;
                        ctx.OPYMs.Add(objOPYM);
                    }


                    foreach (GridViewRow item in gvVendor.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkSelect");
                        TextBox txtAmount = item.FindControl("txtAmount") as TextBox;
                        Label lblInwardID = item.FindControl("lblInwardID") as Label;
                        if (chkCheck.Checked && Decimal.TryParse(txtAmount.Text, out Amount) && Amount > 0 && Int32.TryParse(lblInwardID.Text, out InwardID))
                        {
                            DropDownList ddlMode = item.FindControl("ddlMode") as DropDownList;
                            TextBox txtNote = item.FindControl("txtNote") as TextBox;
                            TextBox txtDocNo = item.FindControl("txtDocNo") as TextBox;
                            TextBox txtDocName = item.FindControl("txtDocName") as TextBox;

                            var objOMID = ctx.OMIDs.FirstOrDefault(x => x.InwardID == InwardID && x.ParentID == ParentID);
                            if (objOMID != null)
                            {
                                MID2 objMID2 = new MID2();
                                objMID2.MID2ID = CountM++;
                                objMID2.ParentID = ParentID;
                                objMID2.InwardID = InwardID;
                                objMID2.Date = DateTime.Now;

                                // if Individual Payment then enter Row level data
                                if (ddlPayOption.SelectedValue == "1")
                                {
                                    objMID2.DocName = txtDocName.Text;
                                    objMID2.DocNo = txtDocNo.Text;
                                    objMID2.PaymentMode = Convert.ToInt32(ddlMode.SelectedValue);
                                }
                                else
                                {
                                    // if General-Bulk Payment then enter PaymentID
                                    objMID2.PaymentID = objOPYM.PaymentID;
                                }

                                objMID2.Amount = Amount;
                                objMID2.Status = "C";
                                ctx.MID2.Add(objMID2);

                                objOMID.Paid += Amount;
                                objOMID.Pending = objOMID.Total - objOMID.Paid;

                                if (ddlPayOption.SelectedValue == "1")
                                {
                                    if (ddlMode.SelectedValue == ((int)PaymentMode.CreditNote).ToString())
                                    {
                                        var cnote = txtDocNo.Text.Split("-".ToArray());
                                        if (cnote.Length != 2)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper credit note.',1);", true);
                                            return;
                                        }

                                        int ID = Convert.ToInt32(cnote.First().Trim());
                                        var objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == ID && x.ParentID == ParentID && x.Status == "C");
                                        if (objOCNT != null && objOCNT.RemainAmount >= Amount)
                                        {
                                            objOCNT.RemainAmount -= Amount;
                                            if (objOCNT.RemainAmount <= 0)
                                                objOCNT.Status = "U";
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Credit Note No: " + ID + " is not available or limit exceeded for this customer',1);", true);
                                            return;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                    ClearAllInputs();
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
        Response.Redirect("Finance.aspx");
    }

    #endregion

    protected void gvVendor_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DropDownList ddlMode = (DropDownList)e.Row.FindControl("ddlMode");
            TextBox lblTotalAmount = (TextBox)e.Row.FindControl("lblTotalAmount");

            using (DDMSEntities ctx = new DDMSEntities())
            {
                int id = 0;
                Label VendorID = (Label)e.Row.FindControl("lblVendorID");
                if (VendorID != null && Int32.TryParse(VendorID.Text, out id) && id > 0)
                {
                    Label lblName = (Label)e.Row.FindControl("lblVName");
                    lblName.Text = ctx.OVNDs.FirstOrDefault(x => x.VendorID == id).VendorName;
                }
            }
            sumFooterValue += Convert.ToDecimal(lblTotalAmount.Text);
            ddlMode.DataSource = EnumList.Of<PurchasePaymentMode>().ToList();
            ddlMode.DataBind();
        }

        if (e.Row.RowType == DataControlRowType.Footer)
        {
            TextBox lblTotBillAmount = (TextBox)e.Row.FindControl("lblTotBillAmount");
            lblTotBillAmount.Text = sumFooterValue.ToString();
        }
    }

    protected void gvVendor_PreRender(object sender, EventArgs e)
    {
        if (gvVendor.Rows.Count > 0)
        {
            gvVendor.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvVendor.FooterRow.TableSection = TableRowSection.TableFooter;
        }
        ClientScriptManager cs = Page.ClientScript;
        foreach (GridViewRow row in gvVendor.Rows)
        {
            HtmlInputCheckBox chkSelect = (HtmlInputCheckBox)row.FindControl("chkSelect");
            cs.RegisterArrayDeclaration("chkSelect_chk", String.Concat("'", chkSelect.ClientID, "'"));
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            ViewState["VendorID"] = null;
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var word = txtVendor.Text.Split("-".ToArray());
                    if (word.Length > 1)
                    {
                        string vendorcode = word.First().Trim();
                        var objVendor = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == vendorcode && x.Active);
                        if (objVendor != null)
                        {
                            DateTime st = Common.DateTimeConvert(txtFromDate.Text);
                            DateTime et = Common.DateTimeConvert(txtTodate.Text);

                            ViewState["VendorID"] = objVendor.VendorID;

                            var Payments = (from c in ctx.OMIDs
                                            where new Int32[] { 3, 4, 7 }.Contains(c.InwardType) && c.Pending > 0 && EntityFunctions.TruncateTime(c.InvoiceDate) >= st && EntityFunctions.TruncateTime(c.InvoiceDate) <= et
                                            && c.ParentID == ParentID && c.VendorID == objVendor.VendorID && c.VendorParentID == objVendor.ParentID
                                            select c).ToList();

                            gvVendor.DataSource = Payments;
                            gvVendor.DataBind();
                            txtBankName.Text = "";
                            txtDocumentNo.Text = "";
                            txtTotalAmount.Text = "";
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Vendor!',3);", true);
                            txtVendor.Text = "";
                            gvVendor.DataSource = null;
                        }
                    }
                    else
                    {
                        DateTime st = Common.DateTimeConvert(txtFromDate.Text);
                        DateTime et = Common.DateTimeConvert(txtTodate.Text);
                        var Payments = (from c in ctx.OMIDs
                                        where new Int32[] { 3, 4, 7 }.Contains(c.InwardType) && c.ParentID == ParentID && c.Pending > 0 && EntityFunctions.TruncateTime(c.InvoiceDate) >= st && EntityFunctions.TruncateTime(c.InvoiceDate) <= et
                                        select c).ToList();

                        gvVendor.DataSource = Payments;
                        gvVendor.DataBind();

                        txtBankName.Text = "";
                        txtDocumentNo.Text = "";
                        txtTotalAmount.Text = "";
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }


}