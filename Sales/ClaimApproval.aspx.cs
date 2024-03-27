using ClaimDMS;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class Sales_ClaimApproval : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;

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
                Version = Convert.ToString(ConfigurationManager.AppSettings["Version"]);

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
                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");
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
        gvCommon.DataSource = null;
        gvCommon.DataBind();
        txtCustCode.Text = txtDate.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.Items.Add(new ListItem("--- Select ---", "0"));
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "SAPReasonItemCode";
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.SAPReasonItemCode }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataBind();

                var ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).ManagerID;
                if (ManagerID.HasValue)
                {
                    var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ManagerID && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                    txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                }
                else
                {
                    divManger.Visible = false;
                    //  btnSumbit.Visible = false;
                    btnSAPSync.Enabled = btnSumbit.Enabled = false;
                }
            }
            txtDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
        }
    }

    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }

            Decimal DistID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

            DDMSEntities ctx = new DDMSEntities();
            // Start Unit and Reason Code Validation for Claim / mtkg User   Ticket # T900011560
            // Emp Reason
            //String ReasonCode = ddlMode.SelectedValue.ToString();
            //int ReasonID = ctx.ORSNs.FirstOrDefault(x => x.SAPReasonItemCode == ReasonCode).ReasonID;
            //var EmpGroupId = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID).EmpGroupID;
            //if (EmpGroupId == 2 || EmpGroupId == 3 || EmpGroupId == 4 || EmpGroupId == 9)
            //{
            //    if (!ctx.OERMs.Any(x => x.EmpId == UserID && x.ReasonId == ReasonID && x.Active == true))
            //    {
            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this reason claim.',3);", true);
            //        return;
            //    }
            //    var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == DistID && x.Active == true).Unit;
            //    if (!ctx.OCUMs.Any(x => x.CustID == UserID && x.OptionId == 1 && x.Unit == DistUnitId))
            //    {
            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this unit claim.',3);", true);
            //        return;
            //    }
            //}

            // End Unit and Reason code validation
            if (ddlMode.SelectedValue.ToString() == "57")
            {

                // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimApproval";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@DistID", DistID);
            Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@UserID", UserID);
            Cm.Parameters.AddWithValue("@Reason", ddlMode.SelectedValue);
            Cm.Parameters.AddWithValue("@Type", ddlDisplay.SelectedValue);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {

                gvCommon.DataSource = ds.Tables[0];
                if (ddlDisplay.SelectedValue == "3")
                {
                    gvCommon.Enabled = false;
                    btnSAPSync.Visible = false;
                }
                else
                {
                    gvCommon.Enabled = true;
                    btnSAPSync.Visible = true;
                }
                if (ddlMode.SelectedValue != "4" || ddlMode.SelectedValue != "5" || ddlMode.SelectedValue != "12" || ddlMode.SelectedValue != "13" || ddlMode.SelectedValue != "14" || ddlMode.SelectedValue != "15" || ddlMode.SelectedValue != "65" || ddlMode.SelectedValue != "70" || ddlMode.SelectedValue != "72")
                {
                    if (Session["IsDistLogin"].ToString() != "True")
                    {
                        DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["UpdatedDate"].ToString());
                        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                        SqlCommand Cmd = new SqlCommand();
                        Cmd.Parameters.Clear();
                        Cmd.CommandType = CommandType.StoredProcedure;
                        Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                        Cmd.Parameters.AddWithValue("@UserID", UserID);
                        Cmd.Parameters.AddWithValue("@CustomerId", 0);
                        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                        if (dsdata.Tables.Count > 0)
                        {
                            if (dsdata.Tables[0].Rows.Count > 0)
                            {
                                DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                {
                                    btnSAPSync.Enabled = btnSumbit.Enabled = false;

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                    //  return;
                                }
                                else
                                {
                                    btnSAPSync.Enabled = btnSumbit.Enabled = true;
                                }
                            }
                        }
                        else
                        {
                            btnSAPSync.Enabled = btnSumbit.Enabled = true;
                        }
                    }
                }
            }
            gvCommon.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSumbit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                int EmpID = 0;
                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                if (txtManager.Text.Split("-".ToArray()).Length > 2 && Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out EmpID) && EmpID > 0)
                {
                    //
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Manager',3);", true);
                    return;
                }
                if (EmpID == UserID)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not set your Code as Approver.',3);", true);
                    return;
                }
                if (gvCommon.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                    return;
                }
                if (ddlMode.SelectedValue.ToString() == "57")
                {

                    // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                    return;
                }
                DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
                DateTime enddate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

                Decimal DecNum = 0;
                Int32 IntNum = 0;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (!ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpID == EmpID && x.IsApprover && x.Active))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Manager code is not set as Approver.',3);", true);
                        return;
                    }
                    int Count = ctx.GetKey("OCLMRA", "ClaimApprovalID", "", ParentID, 0).FirstOrDefault().Value;
                    foreach (GridViewRow item in gvCommon.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                        if (chkCheck.Checked)
                        {
                            HtmlInputHidden hdnClaimRequestID = (HtmlInputHidden)item.FindControl("hdnClaimRequestID");
                            HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");
                            #region Claim Locking Period Validation
                            HtmlInputHidden hdnCreateDate = (HtmlInputHidden)item.FindControl("hdnCreateDate");
                            DateTime ClaimRequestDate = Convert.ToDateTime(hdnCreateDate.Value);
                            HiddenField hdnCustomerID = (HiddenField)item.FindControl("hdnCustomerID");
                            if (Session["IsDistLogin"].ToString() != "True")
                            {
                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                SqlCommand Cmd = new SqlCommand();
                                Cmd.Parameters.Clear();
                                Cmd.CommandType = CommandType.StoredProcedure;
                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                Cmd.Parameters.AddWithValue("@CustomerId", hdnCustomerID.Value);
                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                if (dsdata.Tables.Count > 0)
                                {
                                    if (dsdata.Tables[0].Rows.Count > 0)
                                    {
                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                            return;

                                        }
                                    }
                                }
                            }
                            #endregion
                            TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");

                            Decimal Deduction = Decimal.TryParse(txtDeduction.Text, out Deduction) ? Deduction : 0;
                            IntNum = Int32.TryParse(hdnClaimRequestID.Value, out IntNum) ? IntNum : 0;
                            DecNum = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            Decimal DistParentId = DecNum;
                            OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ClaimRequestID == IntNum && x.CustomerID == DistParentId);
                            if (objOCLMRQ != null)
                            {
                                if (objOCLMRQ.Status == 6)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Claim is Deleted.',3);", true);
                                    return;
                                }
                                if (objOCLMRQ.NextManagerID == EmpID)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not set your Code as Approver.',3);", true);
                                    return;
                                }
                                if (objOCLMRQ.NextManagerID != UserID)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim is already inprocess.',3);", true);
                                    return;
                                }
                                TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                if (string.IsNullOrEmpty(txtRemarks.Text) && Deduction != 0)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Remarks is mandatory.',3);", true);
                                    return;
                                }

                                TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                LinkButton lblPrevApprovedAmt = (LinkButton)item.FindControl("lblPrevApprovedAmt");
                                Label lblMonthSale = (Label)item.FindControl("lblMonthSale");
                                Decimal ApprovedAmt = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                if (ApprovedAmt > objOCLMRQ.SchemeAmount)
                                {
                                    if (Deduction > objOCLMRQ.SchemeAmount && Deduction != objOCLMRQ.PrevApprovedAmount)
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Approved amount must be less than claim amount.',3);", true);
                                        return;
                                    }
                                }
                                //objOCLMRQ.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                //objOCLMRQ.DeductionRemarks = txtRemarks.Text;
                                objOCLMRQ.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                objOCLMRQ.UpdatedDate = DateTime.Now;
                                objOCLMRQ.UpdatedBy = UserID;
                                objOCLMRQ.LevelNo++;
                                objOCLMRQ.NextManagerID = EmpID;
                                objOCLMRQ.Deduction = (objOCLMRQ.Deduction + Deduction);
                                objOCLMRQ.Status = 1;

                                CLMRQ1 ObjectCLMRQ1 = ctx.CLMRQ1.Where(x => x.ClaimRequestID == IntNum && x.CustomerID == DistParentId).OrderByDescending(x => x.LevelNo).FirstOrDefault();
                                if (ObjectCLMRQ1 != null)
                                {
                                    CLMRQ1 objCLMRQ1 = new CLMRQ1();
                                 //   objCLMRQ1.CLMRQ1ID = ctx.GetKey("CLMRQ1", "CLMRQ1ID", "", DistParentId, 0).FirstOrDefault().Value;//CLMRQ1ID++;
                                    objCLMRQ1.ClaimChildID = objOCLMRQ.ClaimChildID;
                                    objCLMRQ1.ClaimChildParentID = objOCLMRQ.ParentID;
                                    objCLMRQ1.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                    objCLMRQ1.ParentID = ParentID;
                                    objCLMRQ1.IsSAP = ObjectCLMRQ1.IsSAP;
                                    objCLMRQ1.DocNo = objOCLMRQ.DocNo;
                                    objCLMRQ1.CustomerID = ObjectCLMRQ1.CustomerID;
                                    objCLMRQ1.ParentClaimID = ObjectCLMRQ1.ParentClaimID;
                                    objCLMRQ1.FromDate = ObjectCLMRQ1.FromDate;
                                    objCLMRQ1.ToDate = ObjectCLMRQ1.ToDate;
                                    objCLMRQ1.ClaimDate = ObjectCLMRQ1.CreatedDate;
                                    objCLMRQ1.SchemeAmount = ObjectCLMRQ1.SchemeAmount;
                                    objCLMRQ1.Deduction = (ObjectCLMRQ1.Deduction + Deduction);
                                    objCLMRQ1.DeductionRemarks = txtRemarks.Text;
                                    objCLMRQ1.ApprovedAmount = Decimal.TryParse(lblPrevApprovedAmt.Text, out DecNum) ? DecNum : 0;
                                    int Level = ObjectCLMRQ1.LevelNo;
                                    objCLMRQ1.ReasonCode = ObjectCLMRQ1.ReasonCode;
                                    objCLMRQ1.IsAuto = ObjectCLMRQ1.IsAuto;
                                    objCLMRQ1.TotalSale = ObjectCLMRQ1.TotalSale;
                                    objCLMRQ1.SchemeSale = ObjectCLMRQ1.SchemeSale;
                                    objCLMRQ1.CreatedDate = DateTime.Now;
                                    objCLMRQ1.CreatedBy = UserID;
                                    objCLMRQ1.UpdatedDate = DateTime.Now;
                                    objCLMRQ1.UpdatedBy = UserID;
                                    objCLMRQ1.Status = 1;
                                    objCLMRQ1.LevelNo = Level + 1;
                                    objCLMRQ1.NextManagerID = objOCLMRQ.NextManagerID;
                                    objCLMRQ1.CreatedIPAddress = IPAdd;
                                    ctx.CLMRQ1.Add(objCLMRQ1);
                                }
                                OCLMRA objOCLMRA = new OCLMRA();
                                objOCLMRA.ClaimApprovalID = Count++;
                                objOCLMRA.ParentID = ParentID;
                                objOCLMRA.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                objOCLMRA.SchemeAmount = objOCLMRQ.SchemeAmount;

                                objOCLMRA.Deduction = Deduction;
                                objOCLMRA.DeductionRemarks = txtRemarks.Text;
                                objOCLMRA.ApprovedAmount = objOCLMRQ.ApprovedAmount;
                                objOCLMRA.PrevApprovedAmount = Decimal.TryParse(lblPrevApprovedAmt.Text, out DecNum) ? DecNum : 0;
                                objOCLMRA.LevelNo = objOCLMRQ.LevelNo - 1;
                                objOCLMRA.NextManagerID = objOCLMRQ.NextManagerID;
                                objOCLMRA.Status = objOCLMRQ.Status;
                                objOCLMRA.CreatedDate = DateTime.Now;
                                objOCLMRA.CreatedBy = UserID;
                                objOCLMRA.UpdatedDate = DateTime.Now;
                                objOCLMRA.UpdatedBy = UserID;
                                objOCLMRA.CreatedIPAddress = IPAdd;
                                ctx.OCLMRAs.Add(objOCLMRA);



                            }
                        }
                    }
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submittd Successfully',1);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSAPSync_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                Decimal DecNum = 0;
                Int32 IntNum = 0;
                List<int> REQIDs = new List<int>();
                if (gvCommon.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                    return;
                }
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int Count = ctx.GetKey("OCLMRA", "ClaimApprovalID", "", ParentID, 0).FirstOrDefault().Value;
                    int EGID = Convert.ToInt32(Session["GroupID"]);
                    foreach (GridViewRow item in gvCommon.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                        if (chkCheck.Checked)
                        {
                            HtmlInputHidden hdnClaimRequestID = (HtmlInputHidden)item.FindControl("hdnClaimRequestID");
                            HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");
                            TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");

                            Decimal Deduction = Decimal.TryParse(txtDeduction.Text, out Deduction) ? Deduction : 0;
                            IntNum = Int32.TryParse(hdnClaimRequestID.Value, out IntNum) ? IntNum : 0;
                            DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                            OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ClaimRequestID == IntNum && x.ParentID == DecNum);
                            if (objOCLMRQ != null)
                            {
                                if (objOCLMRQ.Status == 6)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Claim is Deleted.',3);", true);
                                    return;
                                }
                                if (objOCLMRQ.NextManagerID != UserID)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim is already inprocess.',3);", true);
                                    return;
                                }
                                if (objOCLMRQ.IsSAP == false && ctx.OGRPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpGroupID == EGID).EmpGroupName.ToLower() != "acteam")
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not submit Super Stockiest Distributor Claim.',3);", true);
                                    return;
                                }
                                if (!objOCLMRQ.NextManagerID.HasValue)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim is already inprocess.',3);", true);
                                    return;
                                }
                                TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                if (string.IsNullOrEmpty(txtRemarks.Text) && Deduction != 0)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Remarks is mandatory.',3);", true);
                                    return;
                                }

                                TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                LinkButton lblPrevApprovedAmt = (LinkButton)item.FindControl("lblPrevApprovedAmt");
                                Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                //objOCLMRQ.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                //objOCLMRQ.DeductionRemarks = txtRemarks.Text;
                                objOCLMRQ.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                objOCLMRQ.UpdatedDate = DateTime.Now;
                                objOCLMRQ.UpdatedBy = UserID;
                                objOCLMRQ.LevelNo++;
                                objOCLMRQ.NextManagerID = null;
                                objOCLMRQ.Status = 4;
                                objOCLMRQ.Deduction = (objOCLMRQ.Deduction + Deduction);
                                CLMRQ1 ObjectCLMRQ1 = ctx.CLMRQ1.Where(x => x.ClaimRequestID == IntNum && x.ParentID == DecNum).FirstOrDefault();
                                if (ObjectCLMRQ1 != null)
                                {
                                    CLMRQ1 objCLMRQ1 = new CLMRQ1();
                                  //  objCLMRQ1.CLMRQ1ID = ctx.GetKey("CLMRQ1", "CLMRQ1ID", "", ParentID, 0).FirstOrDefault().Value;//CLMRQ1ID++;
                                    objCLMRQ1.ClaimChildID = objOCLMRQ.ClaimChildID;
                                    objCLMRQ1.ClaimChildParentID = objOCLMRQ.ParentID;
                                    objCLMRQ1.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                    objCLMRQ1.ParentID = ParentID;
                                    objCLMRQ1.IsSAP = ObjectCLMRQ1.IsSAP;
                                    objCLMRQ1.DocNo = objOCLMRQ.DocNo;
                                    objCLMRQ1.CustomerID = ObjectCLMRQ1.CustomerID;
                                    objCLMRQ1.ParentClaimID = ObjectCLMRQ1.ParentClaimID;
                                    objCLMRQ1.FromDate = ObjectCLMRQ1.FromDate;
                                    objCLMRQ1.ToDate = ObjectCLMRQ1.ToDate;
                                    objCLMRQ1.ClaimDate = ObjectCLMRQ1.CreatedDate;
                                    objCLMRQ1.SchemeAmount = ObjectCLMRQ1.SchemeAmount;
                                    objCLMRQ1.Deduction = (ObjectCLMRQ1.Deduction + Deduction);
                                    objCLMRQ1.DeductionRemarks = txtRemarks.Text;
                                    objCLMRQ1.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                    int level = ObjectCLMRQ1.LevelNo;
                                    objCLMRQ1.ReasonCode = ObjectCLMRQ1.ReasonCode;
                                    objCLMRQ1.IsAuto = ObjectCLMRQ1.IsAuto;
                                    objCLMRQ1.TotalSale = ObjectCLMRQ1.TotalSale;
                                    objCLMRQ1.SchemeSale = ObjectCLMRQ1.SchemeSale;
                                    objCLMRQ1.CreatedDate = DateTime.Now;
                                    objCLMRQ1.CreatedBy = UserID;
                                    objCLMRQ1.UpdatedDate = DateTime.Now;
                                    objCLMRQ1.UpdatedBy = UserID;
                                    objCLMRQ1.Status = 4;
                                    objCLMRQ1.LevelNo = level + 1;
                                    objCLMRQ1.NextManagerID = null;
                                    objCLMRQ1.CreatedIPAddress = IPAdd;
                                    ctx.CLMRQ1.Add(objCLMRQ1);
                                }
                                //CLMRQ1 objOCLMRQ1 = ctx.CLMRQ1.FirstOrDefault(x => x.ClaimRequestID == IntNum && x.ParentID == DecNum);
                                //if (objOCLMRQ1 != null)
                                //{
                                //    objOCLMRQ1.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                //    objOCLMRQ1.UpdatedDate = DateTime.Now;
                                //    objOCLMRQ1.UpdatedBy = UserID;
                                //    objOCLMRQ1.LevelNo++;
                                //    objOCLMRQ1.NextManagerID = null;
                                //    objOCLMRQ1.Status = 4;
                                //}

                                OCLMRA objOCLMRA = new OCLMRA();
                                objOCLMRA.ClaimApprovalID = Count++;
                                objOCLMRA.ParentID = ParentID;
                                objOCLMRA.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                objOCLMRA.SchemeAmount = objOCLMRQ.SchemeAmount;

                                objOCLMRA.Deduction = Deduction;
                                objOCLMRA.DeductionRemarks = txtRemarks.Text;
                                objOCLMRA.ApprovedAmount = objOCLMRQ.ApprovedAmount;
                                objOCLMRA.PrevApprovedAmount = Decimal.TryParse(lblPrevApprovedAmt.Text, out DecNum) ? DecNum : 0;
                                objOCLMRA.LevelNo = objOCLMRQ.LevelNo - 1;
                                objOCLMRA.NextManagerID = null;
                                objOCLMRA.Status = objOCLMRQ.Status;
                                objOCLMRA.CreatedDate = DateTime.Now;
                                objOCLMRA.CreatedBy = UserID;
                                objOCLMRA.UpdatedDate = DateTime.Now;
                                objOCLMRA.UpdatedBy = UserID;
                                objOCLMRA.CreatedIPAddress = IPAdd;
                                ctx.OCLMRAs.Add(objOCLMRA);

                                REQIDs.Add(objOCLMRQ.ClaimRequestID);
                            }
                        }
                    }
                    if (REQIDs.Count > 0)
                    {
                        ctx.SaveChanges();
                        Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

                        Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); ClaimScheme(REQIDs, ParentID, UserID); });
                        t.Name = Guid.NewGuid().ToString();
                        t.Start();
                    }

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submitted Successfully',1);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnDocRecv_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (gvCommon.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                    return;
                }
                Decimal DecNum = 0;
                Int32 IntNum = 0;
                int RowCount = 1;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    foreach (GridViewRow item in gvCommon.Rows)
                    {
                        CheckBox chkCheck = (CheckBox)item.FindControl("chkDoc");
                        if (chkCheck.Checked)
                        {
                            HtmlInputHidden hdnClaimRequestID = (HtmlInputHidden)item.FindControl("hdnClaimRequestID");
                            HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                            IntNum = Int32.TryParse(hdnClaimRequestID.Value, out IntNum) ? IntNum : 0;
                            DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                            OCLMRA objOCLMRA = ctx.OCLMRAs.Where(x => x.ClaimRequestID == IntNum && x.ParentID == DecNum).OrderByDescending(x => x.ClaimApprovalID).FirstOrDefault();
                            if (objOCLMRA != null)
                            {
                                if (objOCLMRA.DocumentDate == null)
                                {
                                    objOCLMRA.DocumentDate = DateTime.Now;
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You cannot submit document date because you are first user at row number : " + RowCount + "',3);", true);
                                return;
                            }
                        }
                        RowCount++;
                    }
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Document Date Submitted Successfully',1);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    //protected void btnReject_Click(object sender, EventArgs e)
    //{
    //    try
    //    {
    //        if (Page.IsValid)
    //        {
    //            if (gvCommon.Rows.Count == 0)
    //            {
    //                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
    //                return;
    //            }
    //            Decimal DecNum = 0;
    //            Int32 IntNum = 0;
    //            using (DDMSEntities ctx = new DDMSEntities())
    //            {
    //                int Count = ctx.GetKey("OCLMRA", "ClaimApprovalID", "", ParentID, 0).FirstOrDefault().Value;
    //                foreach (GridViewRow item in gvCommon.Rows)
    //                {
    //                    HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
    //                    if (chkCheck.Checked)
    //                    {
    //                        HtmlInputHidden hdnClaimRequestID = (HtmlInputHidden)item.FindControl("hdnClaimRequestID");
    //                        HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

    //                        IntNum = Int32.TryParse(hdnClaimRequestID.Value, out IntNum) ? IntNum : 0;
    //                        DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

    //                        OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ClaimRequestID == IntNum && x.ParentID == DecNum);
    //                        if (objOCLMRQ != null)
    //                        {
    //                            TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
    //                            TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
    //                            TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
    //                            LinkButton lblPrevApprovedAmt = (LinkButton)item.FindControl("lblPrevApprovedAmt");
    //                            Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

    //                            //objOCLMRQ.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
    //                            //objOCLMRQ.DeductionRemarks = txtRemarks.Text;
    //                            objOCLMRQ.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
    //                            objOCLMRQ.UpdatedDate = DateTime.Now;
    //                            objOCLMRQ.UpdatedBy = UserID;
    //                            objOCLMRQ.LevelNo++;
    //                            objOCLMRQ.NextManagerID = null;
    //                            objOCLMRQ.Status = 5;

    //                            OCLMRA objOCLMRA = new OCLMRA();
    //                            objOCLMRA.ClaimApprovalID = Count++;
    //                            objOCLMRA.ParentID = ParentID;
    //                            objOCLMRA.ClaimRequestID = objOCLMRQ.ClaimRequestID;
    //                            objOCLMRA.SchemeAmount = objOCLMRQ.SchemeAmount;

    //                            objOCLMRA.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
    //                            objOCLMRA.DeductionRemarks = txtRemarks.Text;
    //                            objOCLMRA.ApprovedAmount = objOCLMRQ.ApprovedAmount;
    //                            objOCLMRA.PrevApprovedAmount = Decimal.TryParse(lblPrevApprovedAmt.Text, out DecNum) ? DecNum : 0;
    //                            objOCLMRA.LevelNo = objOCLMRQ.LevelNo - 1;
    //                            objOCLMRA.NextManagerID = null;
    //                            objOCLMRA.Status = objOCLMRQ.Status;
    //                            objOCLMRA.CreatedDate = DateTime.Now;
    //                            objOCLMRA.CreatedBy = UserID;
    //                            objOCLMRA.UpdatedDate = DateTime.Now;
    //                            objOCLMRA.UpdatedBy = UserID;
    //                            objOCLMRA.CreatedIPAddress = IPAdd;
    //                            ctx.OCLMRAs.Add(objOCLMRA);

    //                        }
    //                    }
    //                }
    //                ctx.SaveChanges();

    //                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submittd Successfully',1);", true);
    //                ClearAllInputs();
    //            }
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
    //    }
    //}

    #endregion

    #region Gridview Events

    protected void gvCommon_PreRender(object sender, EventArgs e)
    {
        if (gvCommon.Rows.Count > 0)
        {
            gvCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCommon.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Claim Thread

    public void ClaimScheme(List<int> REQIDs, Decimal ParentID, Int32 UserID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<OCLMRQ> objOCLMRQs = ctx.OCLMRQs.Where(x => REQIDs.Contains(x.ClaimRequestID) && x.ParentID == ParentID && x.Status == 4).ToList();

                List<CLMRQ1> objCLMRQ1s = ctx.CLMRQ1.Where(x => REQIDs.Contains(x.ClaimRequestID) && x.ParentID == ParentID && x.Status == 4).ToList();
                if (objOCLMRQs.Any(x => x.IsSAP == true))
                {

                    var Filterdata = objOCLMRQs.Where(x => x.IsSAP == true).ToList();
                    var FilterCLMRQ1 = objCLMRQ1s.Where(x => x.IsSAP == true).ToList();

                    DT_Claimdms_RequestITEM[] R1 = new DT_Claimdms_RequestITEM[Filterdata.Count];
                    int i = 0;
                    string UserCode = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == UserID).UserName;
                    foreach (OCLMRQ item in Filterdata)
                    {
                        R1[i] = new DT_Claimdms_RequestITEM();

                        R1[i].MANDT = "";
                        R1[i].KUNNR = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == item.CustomerID).CustomerCode;
                        R1[i].BUKRS = "2000";
                        R1[i].AUGRU = item.ReasonCode;
                        R1[i].SCH_ID = item.ClaimRequestID.ToString();
                        R1[i].SCH_STDT = item.FromDate.ToString("yyyyMMdd");
                        R1[i].SCH_EDDT = item.ToDate.ToString("yyyyMMdd");
                        R1[i].CLMDT = item.ClaimDate.ToString("yyyyMMdd");
                        R1[i].CLM_APRVDT = DateTime.Now.ToString("yyyyMMdd");
                        R1[i].CLM_YRMON = item.FromDate.ToString("yyyyMM");
                        R1[i].DIS_CLMAMT = item.SchemeAmount.ToString("0.00");
                        R1[i].MKT_APRVAMT = item.ApprovedAmount.ToString("0.00");
                        R1[i].MKT_REMDED = ctx.OCLMRAs.Where(x => x.ClaimRequestID == item.ClaimRequestID && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault().DeductionRemarks;
                        R1[i].ERNAM = UserCode;
                        R1[i].ERDAT = DateTime.Now.ToString("yyyyMMdd");
                        R1[i].ERZET = DateTime.Now.ToString("hhmmss");
                        R1[i].AUTO_MAN = item.IsAuto ? "A" : "M";
                        R1[i].TOTSAL_MON = item.TotalSale.ToString("0.00");
                        R1[i].SCHSAL_MON = item.SchemeSale.ToString("0.00");
                        R1[i].REFNO = item.DocNo;
                        i++;

                    }

                    try
                    {
                        OCFG objOCFG = ctx.OCFGs.FirstOrDefault();

                        DT_Claimdms_Request Req_MASTER = new DT_Claimdms_Request();
                        Req_MASTER.GIT_CLAIMS = R1;
                        Req_MASTER.FLAG_C = "I";

                        DT_Claimdms_Response Res_MASTER = new DT_Claimdms_Response();
                        SI_SynchOut_ClaimDMSService _proxy_MASTER = new SI_SynchOut_ClaimDMSService();
                        _proxy_MASTER.Url = objOCFG.SAPMasterClaimLink;
                        _proxy_MASTER.Credentials = new NetworkCredential(objOCFG.UserID, objOCFG.Password);
                        _proxy_MASTER.Timeout = 3000000;

                        Res_MASTER = _proxy_MASTER.SI_SynchOut_ClaimDMS(Req_MASTER);

                        DT_Claimdms_ResponseITEM[] Res = Res_MASTER.GIT_CLAIMS;

                        foreach (DT_Claimdms_ResponseITEM item in Res)
                        {
                            int ClaimRequestID = Convert.ToInt32(item.SCH_ID); //ClaimRequestID as SCH_ID
                            //Same Distributor in one process: KUNNR
                            //Same Company Code :BUKRS
                            //Same Reason Code : AUGRU
                            //Same Claim fromDate :SCH_STDT

                            OCLMRQ objREQ = Filterdata.FirstOrDefault(x => x.ClaimRequestID == ClaimRequestID);
                            CLMRQ1 objREQ1 = FilterCLMRQ1.FirstOrDefault(x => x.ClaimRequestID == ClaimRequestID);
                            OCLMRA objAPP = ctx.OCLMRAs.Where(x => x.ClaimRequestID == ClaimRequestID && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();

                            objREQ.Status = item.STATUS == "S" ? 3 : 2;
                            objAPP.Status = objREQ.Status;

                            objREQ.ErrMsg = item.MESSAGE;

                            if (item.STATUS != "S")
                            {
                                objREQ.NextManagerID = UserID;
                                objAPP.NextManagerID = UserID;
                            }


                            //

                            objREQ1.Status = item.STATUS == "S" ? 3 : 2;
                            objREQ1.Status = objREQ.Status;

                            objREQ1.ErrMsg = item.MESSAGE;

                            if (item.STATUS != "S")
                            {
                                objREQ1.NextManagerID = UserID;
                            }

                            ctx.OCLMs.Where(x => x.ParentClaimID == objREQ.ParentClaimID && x.ParentID == objREQ.CustomerID).ToList().ForEach(x => { x.Status = (item.STATUS == "S" ? 3 : 2); x.SAPErrMsg = item.MESSAGE; });
                        }
                    }
                    catch (Exception ex)
                    {
                        Filterdata.ToList().ForEach(x => { x.Status = 2; x.ErrMsg = Common.GetString(ex); x.NextManagerID = UserID; });
                        FilterCLMRQ1.ToList().ForEach(x => { x.Status = 2; x.ErrMsg = Common.GetString(ex); x.NextManagerID = UserID; });

                        var Lists = Filterdata.Select(x => new { x.ParentClaimID, x.CustomerID }).ToList();
                        foreach (int claimrequestid in REQIDs)
                        {
                            OCLMRA objAPP = ctx.OCLMRAs.Where(x => x.ClaimRequestID == claimrequestid && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
                            objAPP.Status = 2;
                            objAPP.NextManagerID = UserID;
                        }
                        //ctx.OCLMRAs.Where(x => REQIDs.Contains(x.ClaimRequestID) && x.ParentID == ParentID).ToList().ForEach(x => { });

                        foreach (var item in Lists)
                        {
                            ctx.OCLMs.Where(x => x.ParentClaimID == item.ParentClaimID && x.ParentID == item.CustomerID).ToList().ForEach(x =>
                            { x.Status = 2; x.SAPErrMsg = Common.GetString(ex); });
                        }
                    }

                    ctx.SaveChanges();
                }
                if (objOCLMRQs.Any(x => x.IsSAP == false))
                {
                    var Filterdata = objOCLMRQs.Where(x => x.IsSAP == false).ToList();
                    foreach (OCLMRQ objREQ in Filterdata)
                    {
                        CLMRQ1 ObjReq1 = ctx.CLMRQ1.Where(x => x.ClaimRequestID == objREQ.ClaimRequestID && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();
                        OCLMRA objAPP = ctx.OCLMRAs.Where(x => x.ClaimRequestID == objREQ.ClaimRequestID && x.ParentID == ParentID).OrderByDescending(x => x.LevelNo).FirstOrDefault();

                        try
                        {

                            OCLMCLD objOCLMCLD = ctx.OCLMCLDs.FirstOrDefault(x => x.ClaimChildID == objREQ.ClaimChildID && x.ParentID == objREQ.ClaimChildParentID);
                            if (objOCLMCLD != null)
                            {
                                OCLMDM objOCLMDMS = new OCLMDM();
                                objOCLMDMS.ClaimDMSID = ctx.GetKey("OCLMDMS", "ClaimDMSID", "", objOCLMCLD.ParentID, 0).FirstOrDefault().Value;
                                objOCLMDMS.ParentID = objOCLMCLD.ParentID;
                                objOCLMDMS.CustomerID = objOCLMCLD.CustomerID;
                                objOCLMDMS.ReasonCode = objREQ.ReasonCode;
                                objOCLMDMS.ClaimRequestID = objREQ.ClaimRequestID;
                                objOCLMDMS.FromDate = objREQ.FromDate;
                                objOCLMDMS.ToDate = objREQ.ToDate;
                                objOCLMDMS.ClaimDate = objREQ.ClaimDate;
                                objOCLMDMS.ApproveDate = DateTime.Now;
                                objOCLMDMS.SchemeAmount = objREQ.SchemeAmount;
                                objOCLMDMS.ApprovedAmount = objREQ.ApprovedAmount;
                                objOCLMDMS.Remarks = objAPP.DeductionRemarks;
                                objOCLMDMS.CreartedBy = UserID;
                                objOCLMDMS.CreatedDate = DateTime.Now;
                                objOCLMDMS.IsAuto = objREQ.IsAuto;
                                objOCLMDMS.TotalSale = objREQ.TotalSale;
                                objOCLMDMS.SchemeSale = objREQ.SchemeSale;
                                objOCLMDMS.RefNo = objOCLMCLD.DocNo;
                                ctx.OCLMDMS.Add(objOCLMDMS);

                                OCLMSUM objOCLMSUM = ctx.OCLMSUMs.FirstOrDefault(x => x.ParentID == objOCLMCLD.ParentID && x.CustomerID == objOCLMCLD.CustomerID);

                                if (objOCLMSUM == null)
                                {
                                    objOCLMSUM = new OCLMSUM();
                                    objOCLMSUM.ClaimSumID = ctx.GetKey("OCLMSUM", "ClaimSumID", "", objOCLMCLD.ParentID, 0).FirstOrDefault().Value;
                                    objOCLMSUM.ParentID = objOCLMCLD.ParentID;
                                    objOCLMSUM.CustomerID = objOCLMCLD.CustomerID;
                                    objOCLMSUM.CreatedBy = UserID;
                                    objOCLMSUM.CreatedDate = DateTime.Now;
                                    objOCLMSUM.ApprovedAmount = 0;
                                    objOCLMSUM.DeductionAmount = 0;
                                    ctx.OCLMSUMs.Add(objOCLMSUM);
                                }
                                objOCLMSUM.ApprovedAmount += objOCLMDMS.ApprovedAmount;
                                objOCLMSUM.UpdatedBy = UserID;
                                objOCLMSUM.UpdatedDate = DateTime.Now;

                                objOCLMCLD.Status = 3;
                                objREQ.Status = 3;
                                objREQ.ErrMsg = "Success";
                                objAPP.Status = 3;


                                ObjReq1.Status = 3;
                                ObjReq1.ErrMsg = "Success";
                                ctx.OCLMs.Where(x => x.ParentClaimID == objREQ.ParentClaimID && x.ParentID == objREQ.CustomerID).ToList().ForEach(x =>
                                { x.Status = 3; x.SAPErrMsg = "Success"; });

                                ctx.SaveChanges();
                            }
                        }
                        catch (Exception ex)
                        {

                            objREQ.Status = 2;
                            objREQ.ErrMsg = Common.GetString(ex);
                            objREQ.NextManagerID = UserID;

                            ObjReq1.Status = 2;
                            ObjReq1.ErrMsg = Common.GetString(ex);
                            ObjReq1.NextManagerID = UserID;

                            objAPP.Status = 3;
                            objAPP.NextManagerID = UserID;

                            ctx.OCLMs.Where(x => x.ParentClaimID == objREQ.ParentClaimID && x.ParentID == objREQ.CustomerID).ToList().ForEach(x =>
                            { x.Status = 2; x.SAPErrMsg = Common.GetString(ex); });

                            ctx.SaveChanges();
                        }


                    }

                }
            }
        }
        catch (Exception ex)
        {
            var FileName = Server.MapPath("~/Document/SchemeLog/") + DateTime.Now.ToString("ddMMyyyyhhmmss") + ".txt";
            TraceService(FileName, Common.GetString(ex));
        }
    }

    private void TraceService(string path, string content)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
        StreamWriter sw = new StreamWriter(fs);
        sw.BaseStream.Seek(0, SeekOrigin.End);
        sw.WriteLine(content);
        sw.Close();
    }

    #endregion

    protected void gvCommon_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvCommon.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerID") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimID") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }

    protected void gvCommon_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblClmLevel = e.Row.FindControl("lblClmLevel") as Label;
            if (Convert.ToInt16(lblClmLevel.Text) >= 0)
            {
                lblimg.Enabled = true;
            }
            else
            {
                lblimg.Enabled = false;
            }
        }
    }
}