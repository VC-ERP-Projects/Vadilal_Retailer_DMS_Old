using System;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_ResetOrderNo : System.Web.UI.Page
{
    #region Declaration
    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected string pagename;
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
                CustType = Convert.ToInt32(Session["Type"]);

                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
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
                            var unit = xml.Descendants("change_password");
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

    private void ClearAllInput()
    {
        Decimal DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : ParentID;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var objOSEQ = ctx.OSEQs.Where(x => x.ParentID == DistributorID && !x.IsDeleted).Select(x => new
            {
                SequenceID = x.SequenceID,
                ParentID = x.ParentID,
                Prefix = x.Prefix,
                FromDate = x.FromDate,
                ToDate = x.ToDate,
                RorderNo = x.RorderNo,
                Type = x.Type == "S" ? "Retail Sales" : x.Type == "T" ? "Tax Sales" : x.Type == "P" ? "Purchase Order" : x.Type == "PR" ? "Purchase Return" : x.Type == "SR" ? "Sales Return"
                            : x.Type == "C" ? "Consume" : x.Type == "W" ? "Wastage" : x.Type == "O" ? "Sales Order" : x.Type == "PC" ? "Purchase Receipt" : "Other",
                CreatedDate = x.CreatedDate,
                CreatedBy = ctx.OEMPs.Where(m => m.EmpID == x.CreatedBy && m.ParentID == (x.CreatedType != 1 ? DistributorID : ParentID)).Select(m => m.EmpCode + " # " + m.Name).FirstOrDefault(),
                UpdatedDate = x.UpdatedDate,
                UpdatedBy = ctx.OEMPs.Where(m => m.EmpID == x.UpdatedBy && m.ParentID == 1000010000000000).Select(m => m.EmpCode + " # " + m.Name).FirstOrDefault(),
            }).OrderByDescending(x => new { x.FromDate, x.ToDate }).ThenBy(x => x.Type).ToList();

            if (objOSEQ.Count > 0)
                btnCopy.Visible = true;
            else
                btnCopy.Visible = false;

            gvResetOrder.DataSource = objOSEQ;
            gvResetOrder.DataBind();
            ddlType.Enabled = true;
        }
        txtOrderNo.Text = txtPrefix.Text = "";
        txtFromDate.Text = txtToDate.Text = DateTime.Now.ToString("dd/MM/yyyy");
        ViewState["SequenceID"] = null;
        btnSubmit.Text = "Submit";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            if (CustType == 1)
            {
                divDistributor.Visible = true;
            }
            else
            {
                divDistributor.Visible = false;
                gvResetOrder.Columns[10].Visible = false;
            }
            ClearAllInput();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (String.IsNullOrEmpty(txtFromDate.Text) || String.IsNullOrEmpty(txtToDate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Enter Proper FromDate and ToDate',3);", true);
                    return;
                }

                var Fromdate = Common.DateTimeConvert(txtFromDate.Text);
                var Todate = Common.DateTimeConvert(txtToDate.Text);
                Decimal DistributorID;

                if (CustType == 1)
                {
                    DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    if (DistributorID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select Proper Customer',3);", true);
                        return;
                    }
                }
                else
                    DistributorID = ParentID;

                int SequenceID = 0;

                if (ViewState["SequenceID"] != null && Int32.TryParse(ViewState["SequenceID"].ToString(), out SequenceID))
                {
                    OSEQ objOSEQ = ctx.OSEQs.FirstOrDefault(x => x.SequenceID == SequenceID && x.ParentID == DistributorID && !x.IsDeleted);
                    if (objOSEQ == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select proper data',3);", true);
                        return;
                    }
                    var count = ctx.OSEQs.Any(x => x.SequenceID != objOSEQ.SequenceID && x.ParentID == DistributorID && !x.IsDeleted && x.Type == ddlType.SelectedValue &&
                       ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(Todate))
                    || (EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(Todate) >= EntityFunctions.TruncateTime(x.ToDate))
                    || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.ToDate))
                    || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Todate) && EntityFunctions.TruncateTime(Todate) <= EntityFunctions.TruncateTime(x.ToDate))));

                    if (count)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sequence Already set Before " + Todate.ToShortDateString() + "',3);", true);
                        return;
                    }
                    objOSEQ.Year = UserID;
                    objOSEQ.UpdatedDate = DateTime.Now;
                    objOSEQ.UpdatedBy = UserID;
                    objOSEQ.Prefix = txtPrefix.Text;
                    objOSEQ.RorderNo = Convert.ToInt32(txtOrderNo.Text);
                    objOSEQ.Type = ddlType.SelectedValue;
                    objOSEQ.FromDate = Fromdate;
                    objOSEQ.ToDate = Todate;
                }
                else
                {
                    var count = ctx.OSEQs.Any(x => x.ParentID == DistributorID && x.Type == ddlType.SelectedValue && !x.IsDeleted &&
                       ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(Todate))
                    || (EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(Todate) >= EntityFunctions.TruncateTime(x.ToDate))
                    || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.ToDate))
                    || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Todate) && EntityFunctions.TruncateTime(Todate) <= EntityFunctions.TruncateTime(x.ToDate))));

                    if (count)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sequence Already set Before " + Todate.ToShortDateString() + "',3);", true);
                        return;
                    }
                    OSEQ objOSEQ = new OSEQ();
                    objOSEQ.SequenceID = ctx.GetKey("OSEQ", "SequenceID", "", DistributorID, 0).FirstOrDefault().Value;
                    objOSEQ.ParentID = DistributorID;
                    objOSEQ.CreatedDate = DateTime.Now;
                    objOSEQ.CreatedBy = UserID;
                    objOSEQ.CreatedType = CustType;
                    objOSEQ.Prefix = txtPrefix.Text;
                    objOSEQ.RorderNo = Convert.ToInt32(txtOrderNo.Text);
                    objOSEQ.Type = ddlType.SelectedValue;
                    objOSEQ.FromDate = Fromdate;
                    objOSEQ.ToDate = Todate;
                    ctx.OSEQs.Add(objOSEQ);
                }
                ctx.SaveChanges();
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sequence Set Successfully. <br> Transaction Number will be start from " + (Convert.ToInt32(txtOrderNo.Text) + 1) + " <br> For " + ddlType.SelectedItem.Text + ".',1);", true);
            ClearAllInput();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    protected void btnCopy_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal DistributorID;
                gvSeqCopy.DataSource = null;
                gvSeqCopy.DataBind();

                if (CustType == 1)
                {
                    if (ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpID == UserID && !x.IsAdmin))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not set sequence,Contact to DMS Team Only',3);", true);
                        return;
                    }
                    DistributorID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                    if (DistributorID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select Proper Customer',3);", true);
                        return;
                    }
                    txtPopupCustCode.Text = txtCustCode.Text;
                }
                else
                {
                    var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                    txtPopupCustCode.Text = string.IsNullOrEmpty(txtCustCode.Text) ? Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID : txtCustCode.Text;
                }

                DistributorID = Decimal.TryParse(txtPopupCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "SequenceOrderNumber";
                Cm.Parameters.AddWithValue("@CustomerID", DistributorID);

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                DataTable dt = ds.Tables[0];

                string[] typeValues = new string[] { "P", "PC", "O", "T", "PR", "SR", "C", "W" };

                if (dt != null)
                {
                    foreach (var typeValue in typeValues)
                    {
                        var typeDesc = typeValue == "T" ? "Tax Sales" : typeValue == "P" ? "Purchase Order" : typeValue == "PR" ? "Purchase Return" : typeValue == "SR" ? "Sales Return"
                               : typeValue == "C" ? "Consume" : typeValue == "W" ? "Wastage" : typeValue == "O" ? "Sales Order" : typeValue == "PC" ? "Purchase Receipt" : "Other";
                        var typePrefix = typeValue == "T" ? "TS" : typeValue == "P" ? "PO" : typeValue == "PR" ? "PR" : typeValue == "SR" ? "SR"
                                : typeValue == "C" ? "C" : typeValue == "W" ? "W" : typeValue == "O" ? "SO" : typeValue == "PC" ? "PREC" : string.Empty;

                        bool ifExist = dt.AsEnumerable().Any(p => p.Field<string>("Type") == typeValue);

                        if (!ifExist)
                        {
                            DataRow toInsert = dt.NewRow();
                            toInsert[0] = 1;
                            toInsert[1] = typeDesc;
                            toInsert[2] = "Not found in last year";
                            toInsert[3] = typePrefix;
                            toInsert["Type"] = typeValue;
                            dt.Rows.Add(toInsert);
                        }
                    }
                }
                gvSeqCopy.DataSource = dt;
                gvSeqCopy.DataBind();
                ddlType.Enabled = true;
            }
            lblModalTitle.Text = "Number Setting (Yearly)";
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myCopyModal", "$('#myCopyModal').modal();", true);

            fromDateSeq.Text = DateTime.Now.ToString("dd/MM/yyyy");
            endDateSeq.Text = DateTime.Now.AddYears(1).ToString("dd/MM/yyyy");
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region Gridview Event

    protected void gvResetOrder_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(e.CommandArgument.ToString()))
            {
                Int32 SequenceID = Int32.TryParse(e.CommandArgument.ToString().Split(",".ToArray()).First(), out SequenceID) ? SequenceID : 0;
                Decimal DistriID = Decimal.TryParse(e.CommandArgument.ToString().Split(",".ToArray()).Last(), out DistriID) ? DistriID : 0;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (e.CommandName.Trim() == "EditMode" && SequenceID > 0 && DistriID > 0)
                    {
                        OSEQ objOSEQ = ctx.OSEQs.FirstOrDefault(x => x.SequenceID == SequenceID && x.ParentID == DistriID && !x.IsDeleted);
                        txtPrefix.Text = objOSEQ.Prefix;
                        ddlType.SelectedValue = objOSEQ.Type;
                        if (objOSEQ.FromDate.HasValue)
                            txtFromDate.Text = Common.DateTimeConvert(objOSEQ.FromDate.Value);
                        if (objOSEQ.ToDate.HasValue)
                            txtToDate.Text = Common.DateTimeConvert(objOSEQ.ToDate.Value);
                        txtOrderNo.Text = objOSEQ.RorderNo.ToString();
                        ViewState["SequenceID"] = objOSEQ.SequenceID;
                        btnSubmit.Text = "Update";
                        ddlType.Enabled = false;
                    }
                    else if ((e.CommandName.Trim() == "DeleteMode" && SequenceID > 0 && DistriID > 0))
                    {
                        OSEQ objOSEQ = ctx.OSEQs.FirstOrDefault(x => x.SequenceID == SequenceID && x.ParentID == DistriID && !x.IsDeleted);
                        objOSEQ.IsDeleted = true;
                        objOSEQ.UpdatedDate = DateTime.Now;
                        objOSEQ.UpdatedBy = UserID;
                        ctx.SaveChanges();
                        ClearAllInput();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvResetOrder_PreRender(object sender, EventArgs e)
    {
        if (gvResetOrder.Rows.Count > 0)
        {
            gvResetOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvResetOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvSeqCopy_PreRender(object sender, EventArgs e)
    {
        int YearStFinalVal, YearEDFinalVal;
        if (DateTime.Now.Month <= 4)
        {
            YearStFinalVal = DateTime.Now.Year;
        }
        else
        {
            YearStFinalVal = DateTime.Now.AddYears(1).Year;
        }
        YearEDFinalVal = YearStFinalVal + 1;
        fromDateSeq.Text = new DateTime(YearStFinalVal, 04, 01).ToShortDateString();
        endDateSeq.Text = new DateTime(YearEDFinalVal, 03, 31).ToShortDateString();

        if (gvSeqCopy.Rows.Count > 0)
        {
            gvSeqCopy.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSeqCopy.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region TextBox Event

    protected void txtCustCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(txtCustCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Decimal CustomerID;
                    if (Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) && CustomerID > 0)
                    {
                        var objOSEQ = ctx.OSEQs.Where(x => x.ParentID == CustomerID && !x.IsDeleted).
                            Select(x => new
                        {
                            SequenceID = x.SequenceID,
                            ParentID = x.ParentID,
                            Prefix = x.Prefix,
                            FromDate = x.FromDate,
                            ToDate = x.ToDate,
                            RorderNo = x.RorderNo,
                            Type = x.Type == "S" ? "Retail Sales" : x.Type == "T" ? "Tax Sales" : x.Type == "P" ? "Purchase Order" : x.Type == "PR" ? "Purchase Return" : x.Type == "SR" ? "Sales Return"
                                        : x.Type == "C" ? "Consume" : x.Type == "W" ? "Wastage" : x.Type == "O" ? "Sales Order" : x.Type == "PC" ? "Purchase Receipt" : "Other",
                            CreatedDate = x.CreatedDate,
                            CreatedBy = ctx.OEMPs.Where(m => m.EmpID == x.CreatedBy && m.ParentID == (x.CreatedType != 1 ? CustomerID : ParentID)).Select(m => m.EmpCode + " # " + m.Name).FirstOrDefault(),
                            UpdatedDate = x.UpdatedDate,
                            UpdatedBy = ctx.OEMPs.Where(m => m.EmpID == x.UpdatedBy && m.ParentID == ParentID).Select(m => m.EmpCode + " # " + m.Name).FirstOrDefault()
                        }).OrderByDescending(x => new { x.FromDate, x.ToDate }).ThenBy(x => x.Type).ToList();

                        if (objOSEQ.Count > 0)
                            btnCopy.Visible = true;
                        else
                            btnCopy.Visible = false;

                        gvResetOrder.DataSource = objOSEQ;
                        gvResetOrder.DataBind();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Proper Customer.',3);", true);
                        return;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region Seq Save data

    protected void btnSaveData_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Fromdate = Common.DateTimeConvert(fromDateSeq.Text);
                var Todate = Common.DateTimeConvert(endDateSeq.Text);

                var dateDiff = (Todate - Fromdate).TotalDays;
                var toalDateDiff = 365;
                if ((Todate.Year % 4 == 0 && Todate.Year % 100 != 0) || (Todate.Year % 400 == 0))
                {
                    toalDateDiff += 1;
                }
                if (dateDiff > toalDateDiff)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter Proper FromDate and ToDate',3); hideModal();", true);
                    return;
                }
                if (String.IsNullOrEmpty(txtFromDate.Text) || String.IsNullOrEmpty(txtToDate.Text) || Todate < Fromdate)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter Proper FromDate and ToDate',3); hideModal();", true);
                    return;
                }

                Decimal DistributorID = Decimal.TryParse(txtPopupCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistributorID) ? DistributorID : 0;
                if (DistributorID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select Proper Customer',3);", true);
                    return;
                }
                int OSEQcount = ctx.GetKey("OSEQ", "SequenceID", "", DistributorID, 0).FirstOrDefault().Value;
                foreach (GridViewRow item in gvSeqCopy.Rows)
                {

                    var newPrefix = ((TextBox)item.FindControl("txtNewPrefix")).Text;
                    var existingPrefix = ((Label)item.FindControl("txtExType")).Text;
                    var TypeCode = ((HiddenField)item.FindControl("lblTypeCode")).Value;

                    var count = ctx.OSEQs.Any(x => x.ParentID == DistributorID && !x.IsDeleted && x.Type == TypeCode &&
                                   ((EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(x.ToDate) >= EntityFunctions.TruncateTime(Todate))
                                || (EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.FromDate) && EntityFunctions.TruncateTime(Todate) >= EntityFunctions.TruncateTime(x.ToDate))
                                || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Fromdate) && EntityFunctions.TruncateTime(Fromdate) <= EntityFunctions.TruncateTime(x.ToDate))
                                || (EntityFunctions.TruncateTime(x.FromDate) <= EntityFunctions.TruncateTime(Todate) && EntityFunctions.TruncateTime(Todate) <= EntityFunctions.TruncateTime(x.ToDate))));

                    if (count)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sequence is already set for selected dates.',3); hideModal();", true);
                        return;
                    }

                    OSEQ objOOSEQ = new OSEQ();
                    objOOSEQ.SequenceID = OSEQcount;
                    objOOSEQ.ParentID = DistributorID;
                    objOOSEQ.CreatedDate = DateTime.Now;
                    objOOSEQ.CreatedBy = UserID;
                    objOOSEQ.CreatedType = CustType;
                    objOOSEQ.Prefix = newPrefix;
                    objOOSEQ.RorderNo = 0;
                    objOOSEQ.Type = TypeCode;
                    objOOSEQ.FromDate = Fromdate;
                    objOOSEQ.ToDate = Todate;
                    ctx.OSEQs.Add(objOOSEQ);
                    OSEQcount++;
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Sequence Set Successfully',1); hideModal();", true);
                ClearAllInput();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3); hideModal();", true);
        }
    }
    #endregion
}