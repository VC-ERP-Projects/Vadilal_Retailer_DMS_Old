using AjaxControlToolkit;
using System;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Finance_ReceiptJE : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        gvVendor.DataSource = null;
        gvVendor.DataBind();
        txtNotes.Text = "";
        txtFromDate.Text = txtTodate.Text = txtJEDate.Text = Common.DateTimeConvert(DateTime.Now);

        txtCustomer.Text = txtTotalAmount.Text = txtBankName.Text = txtDocumentNo.Text = "";
        txtCustomer.Style.Add("background-color", "rgb(250, 255, 189);");

        ddlPayMode.DataSource = EnumList.Of<PaymentMode>().ToList();
        ddlPayMode.DataBind();
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
            txtJEDate.Focus();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnUpload);
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            bool errFound = true;

            if (Page.IsValid)
            {
                Decimal DecNum = 0;
                int SaleID = 0;

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
                    int CountM = ctx.GetKey("POS2", "POS2ID", "", ParentID, null).FirstOrDefault().Value;
                    int CountMJET = ctx.GetKey("MJET", "MJETID", "", ParentID, 0).FirstOrDefault().Value;

                    OPYM objOPYM = null;
                    // if General-Bulk Payment then make entry in OPYM
                    if (ddlPayOption.SelectedValue == "2")
                    {
                        DecNum = Convert.ToDecimal(txtTotalAmount.Text);

                        if (ddlPayMode.SelectedValue == ((int)PaymentMode.CreditNote).ToString())
                        {
                            int ID = Convert.ToInt32(txtDocumentNo.Text);
                            var objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == ID && x.ParentID == ParentID && x.Status == "C");
                            if (objOCNT == null && objOCNT.RemainAmount >= DecNum)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Credit Note No: " + ID + " is not available or limit exceeded for this customer',1);", true);
                                return;
                            }
                        }

                        int paymentID = ctx.GetKey("OPYM", "PaymentID", "", ParentID, 0).FirstOrDefault().Value;
                        objOPYM = new OPYM();
                        objOPYM.PaymentID = paymentID++;
                        objOPYM.ParentID = ParentID;
                        objOPYM.PaymentMode = Convert.ToInt32(ddlPayMode.SelectedValue);
                        objOPYM.DocumentName = txtBankName.Text;
                        objOPYM.DocumentNo = txtDocumentNo.Text;
                        objOPYM.Amount = DecNum;
                        objOPYM.CreatedDate = DateTime.Now;
                        objOPYM.Active = true;
                        objOPYM.CreatedBy = UserID;
                        ctx.OPYMs.Add(objOPYM);
                    }

                    foreach (GridViewRow item in gvVendor.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkSelect");

                        TextBox txtAmount = item.FindControl("txtAmount") as TextBox;
                        Label lblSaleID = item.FindControl("lblSaleID") as Label;

                        if (chkCheck.Checked && Decimal.TryParse(txtAmount.Text, out DecNum) && DecNum > 0 && Int32.TryParse(lblSaleID.Text, out SaleID))
                        {
                            OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.SaleID == SaleID && x.ParentID == ParentID);
                            if (objOPOS != null)
                            {
                                DropDownList ddlMode = item.FindControl("ddlMode") as DropDownList;
                                TextBox txtNote = item.FindControl("txtNote") as TextBox;

                                TextBox txtDocNo = item.FindControl("txtDocNo") as TextBox;
                                TextBox txtDocName = item.FindControl("txtDocName") as TextBox;

                                //Adjust Master CN 
                                Label lblMasterCN = item.FindControl("lblMasterCN") as Label;
                                HtmlInputHidden hdnCreditNoteID = item.FindControl("hdnCreditNoteID") as HtmlInputHidden;

                                Int32 MasterCNID = 0;
                                Decimal MasterAmount = 0;

                                if (Int32.TryParse(hdnCreditNoteID.Value, out MasterCNID) && MasterCNID > 0 && Decimal.TryParse(lblMasterCN.Text, out MasterAmount) && MasterAmount > 0)
                                {
                                    POS2 objCNPOS2 = new POS2();
                                    objCNPOS2.POS2ID = CountM++;
                                    objCNPOS2.ParentID = ParentID;
                                    objCNPOS2.SaleID = objOPOS.SaleID;
                                    objCNPOS2.Date = DateTime.Now;
                                    objCNPOS2.DocName = "";
                                    objCNPOS2.DocNo = MasterCNID.ToString();
                                    objCNPOS2.PaymentMode = (int)PaymentMode.CreditNote;
                                    objCNPOS2.Amount = MasterAmount;
                                    objCNPOS2.Status = "C";
                                    ctx.POS2.Add(objCNPOS2);

                                    objOPOS.Paid += MasterAmount;
                                    objOPOS.Pending = objOPOS.Total - objOPOS.Paid;
                                }

                                POS2 objPOS2 = new POS2();
                                objPOS2.POS2ID = CountM++;
                                objPOS2.ParentID = ParentID;
                                objPOS2.SaleID = objOPOS.SaleID;
                                objPOS2.Date = DateTime.Now;

                                // if Individual Payment then enter Row level data
                                if (ddlPayOption.SelectedValue == "1")
                                {
                                    objPOS2.DocName = txtDocName.Text;
                                    objPOS2.DocNo = txtDocNo.Text;
                                    objPOS2.PaymentMode = Convert.ToInt32(ddlMode.SelectedValue);
                                }
                                else
                                {
                                    // if General-Bulk Payment then enter PaymentID
                                    objPOS2.PaymentID = objOPYM.PaymentID;
                                }

                                objPOS2.Amount = DecNum;
                                objPOS2.Status = "C";

                                ctx.POS2.Add(objPOS2);

                                objOPOS.Paid += DecNum;
                                objOPOS.Pending = objOPOS.Total - objOPOS.Paid;

                                if (ddlPayOption.SelectedValue == "1")
                                {
                                    if (ddlMode.SelectedValue == ((int)PaymentMode.CreditNote).ToString())
                                    {
                                        var cnote = txtDocNo.Text.Split("-".ToArray());
                                        int ID = 0;
                                        if (cnote.Length > 0 && Int32.TryParse(cnote.First().Trim(), out ID) && ID > 0)
                                        {
                                            OCNT objOCNT = ctx.OCNTs.FirstOrDefault(x => x.CreditNoteID == ID && x.CreditNoteType == "R" && x.ParentID == ParentID && x.Status == "C");
                                            if (objOCNT != null && objOCNT.RemainAmount >= DecNum)
                                            {
                                                objOCNT.RemainAmount -= DecNum;
                                                if (objOCNT.RemainAmount <= 0)
                                                    objOCNT.Status = "U";
                                            }
                                            else
                                            {
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Credit Note No: " + ID + " is not available or limit exceeded for this customer',2);", true);
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper credit note.',1);", true);
                                            return;
                                        }
                                    }
                                }
                                if (ddlMode.SelectedValue == ((int)PaymentMode.Cheque).ToString())
                                {
                                    objPOS2.Status = "P";
                                }
                            }
                        }
                        else if (chkCheck.Checked && Decimal.TryParse(txtAmount.Text, out DecNum) && DecNum <= 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter Amount properly in selected row!',3);", true);
                            return;
                        }
                    }

                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                }
                ClearAllInputs();
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

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var word = txtCustomer.Text.Split("-".ToArray());
                    if (word.Length > 1)
                    {
                        var CustID = word.First().Trim();
                        var objCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustID && x.ParentID == ParentID && x.Active);
                        if (objCust != null)
                        {
                            DateTime st = Common.DateTimeConvert(txtFromDate.Text);
                            DateTime et = Common.DateTimeConvert(txtTodate.Text);

                            var Data = (from c in ctx.OPOS
                                        where new int[] { 12, 13 }.Contains(c.OrderType) && c.ParentID == ParentID && c.Pending > 0 && c.CustomerID == objCust.CustomerID
                                        && EntityFunctions.TruncateTime(c.Date) >= st && EntityFunctions.TruncateTime(c.Date) <= et
                                        select new
                                        {
                                            c.SaleID,
                                            c.InvoiceNumber,
                                            c.Date,
                                            c.OCRD.CustomerName,
                                            c.CustomerID,
                                            c.Total,
                                            c.Paid,
                                            c.Pending,
                                            MasterCN = c.WaitingID.HasValue ?
                                                  c.POS2.Any(z => z.PaymentMode == 5 && z.DocNo == SqlFunctions.StringConvert((Decimal)c.WaitingID.Value).Trim()) ? 0 : Math.Round(c.POS3.Where(x => x.Mode == "M").Sum(y => y.Amount), 2) : 0,
                                            CreditNoteID = c.WaitingID.HasValue ?
                                                    c.POS2.Any(z => z.PaymentMode == 5 && z.DocNo == SqlFunctions.StringConvert((Decimal)c.WaitingID.Value).Trim()) ? 0 : c.WaitingID.Value : 0,
                                        }).OrderBy(x => x.Date).ToList();

                            gvVendor.DataSource = Data;
                            gvVendor.DataBind();

                            txtBankName.Text = "";
                            txtDocumentNo.Text = "";
                            txtTotalAmount.Text = "";
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ChangeQuantity();", true);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer!',3);", true);
                            txtCustomer.Text = "";
                            gvVendor.DataSource = null;
                        }
                    }
                    else
                    {
                        DateTime st = Common.DateTimeConvert(txtFromDate.Text);
                        DateTime et = Common.DateTimeConvert(txtTodate.Text);

                        var Data = (from c in ctx.OPOS
                                    where new int[] { 12, 13 }.Contains(c.OrderType) && c.ParentID == ParentID && c.Pending > 0
                                    && EntityFunctions.TruncateTime(c.Date) >= st && EntityFunctions.TruncateTime(c.Date) <= et
                                    select new
                                    {
                                        c.SaleID,
                                        c.InvoiceNumber,
                                        c.Date,
                                        c.OCRD.CustomerName,
                                        c.CustomerID,
                                        c.Total,
                                        c.Paid,
                                        c.Pending,
                                        MasterCN = c.WaitingID.HasValue ?
                                                c.POS2.Any(z => z.PaymentMode == 5 && z.DocNo == SqlFunctions.StringConvert((Decimal)c.WaitingID.Value).Trim()) ? 0 : Math.Round(c.POS3.Where(x => x.Mode == "M").Sum(y => y.Amount), 2) : 0,
                                        CreditNoteID = c.WaitingID.HasValue ?
                                                c.POS2.Any(z => z.PaymentMode == 5 && z.DocNo == SqlFunctions.StringConvert((Decimal)c.WaitingID.Value).Trim()) ? 0 : c.WaitingID.Value : 0,
                                    }).OrderBy(x => x.Date).ToList();

                        gvVendor.DataSource = Data;
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

    #endregion

    #region GirdView

    protected void gvVendor_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DropDownList ddlMode = (DropDownList)e.Row.FindControl("ddlMode");
            ddlMode.DataSource = EnumList.Of<PaymentMode>().ToList();
            ddlMode.DataBind();
        }
    }

    protected void gvVendor_PreRender(object sender, EventArgs e)
    {
        if (gvVendor.Rows.Count > 0)
        {
            gvVendor.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvVendor.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region CSVUPLOAD

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

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        DataTable missdata = new DataTable();
        missdata.Columns.Add("Customer Code");
        missdata.Columns.Add("Customer Name");
        missdata.Columns.Add("ErrorMsg");

        try
        {
            if (flCSVUpload.HasFile)
            {
                decimal DecNum = 0;
                DataTable dtOutStanding = new DataTable();
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCSVUpload.PostedFile.FileName));
                flCSVUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCSVUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    TransferCSVToTable(fileName, dtOutStanding);
                    if (dtOutStanding != null && dtOutStanding.Rows != null && dtOutStanding.Rows.Count > 0)
                    {
                        bool IsError = false;

                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            IsError = false;

                            int SaleID = ctx.GetKey("OPOS", "SaleID", "", ParentID, 0).FirstOrDefault().Value;

                            string CustomerCode = "";
                            Decimal OutStandingAmt = 0;

                            for (int i = 0; i < dtOutStanding.Rows.Count; i++)
                            {
                                try
                                {
                                    CustomerCode = dtOutStanding.Rows[i]["CustomerCode"].ToString();
                                    OutStandingAmt = Decimal.TryParse(dtOutStanding.Rows[i]["Amount"].ToString(), out DecNum) ? DecNum : 0;

                                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == CustomerCode && x.ParentID == ParentID);

                                    if (objOCRD != null)
                                    {
                                        OPOS objOPOS = ctx.OPOS.FirstOrDefault(x => x.CustomerID == objOCRD.CustomerID && x.Notes.ToLower() == "customer outstanding");
                                        if (objOPOS == null && OutStandingAmt > 0)
                                        {
                                            objOPOS = new OPOS();
                                            objOPOS.SaleID = SaleID++;
                                            objOPOS.ParentID = ParentID;
                                            objOPOS.Status = "O";
                                            objOPOS.OrderType = 13;
                                            objOPOS.CustomerID = objOCRD.CustomerID;
                                            objOPOS.CreatedDate = DateTime.Now;
                                            objOPOS.CreatedBy = UserID;
                                            objOPOS.Date = Common.DateTimeConvert(txtJEDate.Text).Add(DateTime.Now.TimeOfDay);

                                            objOPOS.SubTotal = OutStandingAmt;
                                            objOPOS.Rounding = 0;
                                            objOPOS.Tax = 0;
                                            objOPOS.Total = OutStandingAmt;
                                            objOPOS.Paid = 0;
                                            objOPOS.Pending = OutStandingAmt;
                                            objOPOS.Notes = "Customer OutStanding";
                                            objOPOS.BillRefNo = "0pening";
                                            objOPOS.UpdatedDate = DateTime.Now;
                                            objOPOS.UpdatedBy = UserID;
                                            ctx.OPOS.Add(objOPOS);
                                        }
                                        else
                                        {
                                            DataRow missdr = missdata.NewRow();
                                            missdr["Customer Code"] = objOCRD.CustomerCode;
                                            missdr["Customer Name"] = objOCRD.CustomerName;
                                            missdr["ErrorMsg"] = "OutStanding entry found.";
                                            missdata.Rows.Add(missdr);
                                            IsError = true;
                                        }
                                    }
                                    else
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Customer Code"] = CustomerCode;
                                        missdr["Customer Name"] = "";
                                        missdr["ErrorMsg"] = "Customer not found.";
                                        missdata.Rows.Add(missdr);
                                        IsError = true;
                                    }
                                }
                                catch (DbEntityValidationException ex)
                                {
                                    var error = ex.EntityValidationErrors.First().ValidationErrors.First();

                                    DataRow missdr = missdata.NewRow();
                                    missdr["Customer Code"] = "";
                                    missdr["Customer Name"] = "";
                                    missdr["ErrorMsg"] = error.ErrorMessage.Replace("'", "");
                                    missdata.Rows.Add(missdr);
                                    IsError = true;
                                }
                                catch (Exception ex)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Customer Code"] = "";
                                    missdr["Customer Name"] = "";
                                    missdr["ErrorMsg"] = Common.GetString(ex);
                                    missdata.Rows.Add(missdr);
                                    IsError = true;
                                }
                            }

                            if (IsError == false)
                            {
                                ctx.SaveChanges();
                                gvMissdata.DataSource = null;
                                gvMissdata.DataBind();
                                divMissData.Attributes.Add("style", "display: none");
                            }
                            else
                            {
                                gvMissdata.DataSource = missdata;
                                gvMissdata.DataBind();
                            }

                            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File upload successfully.',1);", true);
                            ClearAllInputs();

                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('No record found.',2);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Upload only CSV file format.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload file.',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}