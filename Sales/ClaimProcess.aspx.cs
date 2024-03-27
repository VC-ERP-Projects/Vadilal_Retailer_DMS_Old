using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Validation;
using System.Data.Objects;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_ClaimProcess : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    String ReasonCode = "";
    protected bool IsHierarchy;
    //   List<usp_GetMangerList_Result> Data;
    protected String LogoURL;
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
                LogoURL = Common.GetLogo(ParentID);
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

                    OCRD objOCRD = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID);
                    hdnUserName.Value = objOCRD != null ? objOCRD.CustomerCode + " - " + objOCRD.CustomerName : "";
                    hdnRegionName.Value = objOCRD != null && objOCRD.CRD1.Any(x => x.IsDeleted == false && x.StateID > 0) ? objOCRD.CRD1.FirstOrDefault(x => x.IsDeleted == false && x.StateID > 0).OCST.StateName : "";
                    hdnCustType.Value = CustType.ToString();

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("reports");
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
        gvSecFreight.Visible = gvFOWScheme.Visible = gvParlourScheme.Visible = gvVRSDiscount.Visible = gvMachineScheme.Visible = gvMasterScheme.Visible = gvQPSScheme.Visible = gvRateDiff.Visible = gvIOU.Visible = false;

        gvMasterScheme.DataSource = null;
        gvMasterScheme.DataBind();

        gvMachineScheme.DataSource = null;
        gvMachineScheme.DataBind();

        gvQPSScheme.DataSource = null;
        gvQPSScheme.DataBind();

        gvParlourScheme.DataSource = null;
        gvParlourScheme.DataBind();

        gvVRSDiscount.DataSource = null;
        gvVRSDiscount.DataBind();

        gvFOWScheme.DataSource = null;
        gvFOWScheme.DataBind();

        gvSecFreight.DataSource = null;
        gvSecFreight.DataBind();

        gvRateDiff.DataSource = null;
        gvRateDiff.DataBind();

        gvIOU.DataSource = null;
        gvIOU.DataBind();


    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            txtDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
            IsHierarchy = false;
            flpFileUpload.Visible = false;
            lblClaimReport.Visible = false;
        }
    }

    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == false))
                {
                }
                else
                {

                    if (Session["IsDistLogin"].ToString() != "True")
                    {
                        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                        SqlCommand Cmd = new SqlCommand();
                        Cmd.Parameters.Clear();
                        Cmd.CommandType = CommandType.StoredProcedure;
                        Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                        Cmd.Parameters.AddWithValue("@UserID", UserID);
                        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                        if (dsdata.Tables.Count > 0)
                        {
                            if (dsdata.Tables[0].Rows.Count > 0)
                            {

                                DateTime LockingDate = Todate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                if ((LockingDate - System.DateTime.Today).TotalDays < 0)
                                {
                                    btnSubmit.Enabled = false;
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                    //  return;
                                }
                                else
                                {
                                    btnSubmit.Enabled = true;
                                }
                            }
                        }
                        else
                        {
                            btnSubmit.Enabled = true;
                        }
                    }

                }
            }
            DateTime Comparedate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month));
            if (Todate >= Comparedate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not process next or current month claim.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }


            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true))
                {
                    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
                    //    return;
                    var ProcessDate = ctx.OCLMPs.Where(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true).Select(x => new { x.CreatedDate, x.HierarchyManagerId, x.ParentClaimID }).FirstOrDefault();
                    OEMP ObjEE = null;
                    if (ProcessDate.HierarchyManagerId != null)
                    {
                        Int32 ParentClaimId = Convert.ToInt32(ProcessDate.ParentClaimID);
                        OCLM ObjOcl = ctx.OCLMs.Where(x => x.ParentID == ParentID && x.ParentClaimID == ParentClaimId).FirstOrDefault();
                        if (ObjOcl.Status != 3)
                        {

                            Int32 MngrId = Convert.ToInt32(ProcessDate.HierarchyManagerId);
                            ObjEE = ctx.OEMPs.Where(x => x.EmpID == MngrId).FirstOrDefault();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Already Processed On " + ProcessDate.CreatedDate.ToString("dd-MMM-yy HH:mm") + "<br> Currently Pending with " + ObjEE.Name + "',3);", true);
                            return;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Already Processed On " + ProcessDate.CreatedDate.ToString("dd-MMM-yy HH:mm") + "<br> Currently Pending with Accounts Team',3);", true);
                            return;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Already Processed On " + ProcessDate.CreatedDate.ToString("dd-MMM-yy HH:mm") + "',3);", true);
                        return;
                    }
                }

            }


            // Check Claim Level Hierarchy
            Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
            SqlCommand Cmd2 = new SqlCommand();
            Cmd2.Parameters.Clear();
            Cmd2.CommandType = CommandType.StoredProcedure;
            Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchyHardCode";
            Cmd2.Parameters.AddWithValue("@ParentID", ParentID);
            Cmd2.Parameters.AddWithValue("@UserID", UserID);
            Cmd2.Parameters.AddWithValue("@ClaimDate", Fromdate);
            DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
            if (dsdata1.Tables.Count > 0)
            {
                if (dsdata1.Tables[0].Rows.Count > 0)
                {
                    if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE")
                    {
                        if (Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()) >= 0)
                        {
                            IsHierarchy = true;
                        }
                    }
                    else if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "FALSE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()) == 0)
                    {
                        IsHierarchy = true;
                    }
                    else
                    {
                        if (Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()) == -1)
                        {
                            IsHierarchy = false;
                        }
                    }
                }
            }
            // End // Check Claim Level Hierarchy


            if (IsHierarchy)
            {
                flpFileUpload.Visible = true;
                lblClaimReport.Visible = true;
            }
            else
            {
                flpFileUpload.Visible = false;
                lblClaimReport.Visible = false;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimDetail";
            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
            Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));

            Cm.Parameters.AddWithValue("@Mode", ddlMode.SelectedValue);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                ReasonCode = ds.Tables[0].Rows[0]["SAPReasonItemCode"].ToString();
                if (ddlMode.SelectedValue == "M")
                {
                    gvMasterScheme.DataSource = ds.Tables[0];
                    gvMasterScheme.DataBind();
                    gvMasterScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "S")
                {
                    gvQPSScheme.DataSource = ds.Tables[0];
                    gvQPSScheme.DataBind();
                    gvQPSScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "D")
                {
                    gvMachineScheme.DataSource = ds.Tables[0];
                    gvMachineScheme.DataBind();
                    gvMachineScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "P")
                {
                    gvParlourScheme.DataSource = ds.Tables[0];
                    gvParlourScheme.DataBind();
                    gvParlourScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "V")
                {
                    gvVRSDiscount.DataSource = ds.Tables[0];
                    gvVRSDiscount.DataBind();
                    gvVRSDiscount.Visible = true;
                }
                else if (ddlMode.SelectedValue == "F")
                {
                    gvFOWScheme.DataSource = ds.Tables[0];
                    gvFOWScheme.DataBind();
                    gvFOWScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "T")
                {
                    gvSecFreight.DataSource = ds.Tables[0];
                    gvSecFreight.DataBind();
                    gvSecFreight.Visible = true;
                }
                else if (ddlMode.SelectedValue == "R")
                {
                    gvRateDiff.DataSource = ds.Tables[0];
                    gvRateDiff.DataBind();
                    gvRateDiff.Visible = true;
                }
                else if (ddlMode.SelectedValue == "I")
                {
                    gvIOU.DataSource = ds.Tables[0];
                    gvIOU.DataBind();
                    gvIOU.Visible = true;
                }
                txtDate.Enabled = ddlMode.Enabled = false;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found',3);", true);
                return;
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
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
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == false))
                {
                }
                else
                {
                    if (Session["IsDistLogin"].ToString() != "True")
                    {
                        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                        SqlCommand Cmd = new SqlCommand();
                        Cmd.Parameters.Clear();
                        Cmd.CommandType = CommandType.StoredProcedure;
                        Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                        Cmd.Parameters.AddWithValue("@UserID", UserID);
                        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                        if (dsdata.Tables.Count > 0)
                        {
                            if (dsdata.Tables[0].Rows.Count > 0)
                            {
                                DateTime LockingDate = Todate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                if ((LockingDate - System.DateTime.Today).TotalDays < 0)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                    return;
                                }
                            }
                        }
                    }


                }
            }
            string IPAdd = hdnIPAdd.Value;
            if (IPAdd == "undefined")
                IPAdd = "";
            if (IPAdd.Length > 15)
                IPAdd = IPAdd = IPAdd.Substring(0, 15);

            DateTime Comparedate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month));
            if (Todate >= Comparedate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not process next or current month claim.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }

            Decimal ApprovedAmount = 0;
            Decimal TotalPurchase = 0;


            if (gvSecFreight.Rows.Count > 0 || gvMasterScheme.Rows.Count > 0 || gvQPSScheme.Rows.Count > 0 || gvMachineScheme.Rows.Count > 0
                || gvParlourScheme.Rows.Count > 0 || gvVRSDiscount.Rows.Count > 0 || gvFOWScheme.Rows.Count > 0 || gvRateDiff.Rows.Count > 0 || gvIOU.Rows.Count > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
                        return;
                    }

                    Int32 IntNum = 0;
                    Decimal DecNum = 0;

                    Decimal ParentCustID = Convert.ToDecimal(Session["OutletPID"]);
                    // Check Unit Mapping entry found or not  T90001150  10-Oct-22
                    if (!ctx.OCUMs.Any(x => x.CustID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('your unit entry not found please contact mktg department',3);", true);
                        return;
                    }
                    //Check Validation File Upload Images for Claim Submit // T900011560
                    HttpFileCollection uploadedFiles = Request.Files;
                    string filepath = Server.MapPath("\\Document\\ClaimDocument");

                    int CLM2ID = ctx.GetKey("CLM2", "CLM2ID", "", ParentID, 0).FirstOrDefault().Value;
                    //// ENd File Upload Distibutor Process claim Again if reject 23-Nov-22  // 14-Dec-22
                    //OCLMP ObjectOCL = ctx.OCLMPs.Where(x => x.ParentID == ParentID && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year).FirstOrDefault();
                    //if (ObjectOCL != null)
                    //{
                    //    ObjectOCL.CreatedBy = UserID;
                    //    ObjectOCL.CreatedDate = DateTime.Now;
                    //    ObjectOCL.IsActive = true;

                    //    // Check Claim Level Hierarchy
                    //    Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                    //    SqlCommand Cmd2 = new SqlCommand();
                    //    Cmd2.Parameters.Clear();
                    //    Cmd2.CommandType = CommandType.StoredProcedure;
                    //    Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchy";
                    //    Cmd2.Parameters.AddWithValue("@ParentID", ParentID);
                    //    Cmd2.Parameters.AddWithValue("@UserID", UserID);
                    //    DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
                    //    if (dsdata1.Tables.Count > 0)
                    //    {
                    //        if (dsdata1.Tables[0].Rows.Count > 0)
                    //        {
                    //            if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) > 0)
                    //            {
                    //                ObjectOCL.ClaimLevel = 1;
                    //                ObjectOCL.HierarchyManagerId = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                    //            }
                    //            else
                    //            {
                    //                var ReasonId = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                    //                var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == ParentID && x.Active == true).Unit;
                    //                List<OCUM> ObjectOcum = ctx.OCUMs.Where(x => x.OptionId == 1 && x.Unit == DistUnitId && x.Active == true).ToList();
                    //                ObjectOCL.HierarchyManagerId = 0;
                    //                if (ObjectOcum != null)
                    //                {
                    //                    foreach (OCUM ObjUnit in ObjectOcum)
                    //                    {
                    //                        Decimal OEmpId = Convert.ToDecimal(ObjUnit.CustID);
                    //                        OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == OEmpId && x.Active == true && x.ReasonId == ReasonId);
                    //                        if (ObjERM != null)
                    //                        {
                    //                            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == OEmpId && x.ParentID == 1000010000000000 && x.EmpGroupID == 9 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                    //                            if (objOEMP != null)
                    //                            {
                    //                                ObjectOCL.HierarchyManagerId = objOEMP.EmpID;
                    //                                break;
                    //                            }
                    //                            else
                    //                            {
                    //                                ObjectOCL.HierarchyManagerId = 0;
                    //                            }

                    //                        }
                    //                    }
                    //                    //if (txtManager.Text == "")
                    //                    //{
                    //                    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Hierarchy in-complete for this claim type.',3);", true);
                    //                    //    return;
                    //                    //}
                    //                }
                    //                ObjectOCL.ClaimLevel = 0;
                    //            }
                    //        }
                    //    }
                    //    // Delete existing file
                    //    var deleteOrderDetails =
                    //                                from details in ctx.CLM2
                    //                                where details.ParentID == ParentID && details.ParentClaimID == ObjectOCL.ParentClaimID
                    //                                select details;

                    //    foreach (var detail in deleteOrderDetails)
                    //    {

                    //        if (File.Exists(filepath + "\\" + detail.ImageName))
                    //        {
                    //            FileInfo f = new FileInfo(filepath + "\\" + detail.ImageName);
                    //            f.Delete();
                    //        }
                    //        ctx.CLM2.Remove(detail);
                    //    }
                    //    // end delete existing file
                    //    if (IsHierarchy)
                    //    {
                    //        string[] ArrFileName = new string[uploadedFiles.Count];
                    //        for (int i = 0; i < uploadedFiles.Count; i++)
                    //        {
                    //            string strFilePath = "";
                    //            HttpPostedFile userPostedFile = uploadedFiles[i];
                    //            string ext = System.IO.Path.GetExtension(userPostedFile.FileName);
                    //            if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                    //            {
                    //                double filesize = userPostedFile.ContentLength;
                    //                if (filesize < (1024000))   // 1 MB File Size
                    //                {
                    //                    strFilePath = ParentID + "_" + ddlMode.SelectedValue.ToString() + "_" + Fromdate.Month + "_" + Fromdate.Year + "_" + i.ToString() + ext;
                    //                    userPostedFile.SaveAs(filepath + "\\" + Path.GetFileName(strFilePath));
                    //                    ArrFileName[i] = strFilePath;
                    //                }
                    //                else
                    //                {
                    //                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not upload more than 1 MB File size.!',3);", true);
                    //                    return;
                    //                }
                    //            }
                    //            else
                    //            {
                    //                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png,  jpeg, pdf file!',3);", true);
                    //                return;
                    //            }

                    //        }
                    //        // Store File in Table

                    //        for (int j = 0; j < ArrFileName.Length; j++)
                    //        {
                    //            CLM2 objCLM2 = new CLM2();
                    //            objCLM2.CLM2ID = CLM2ID++;
                    //            objCLM2.ParentID = ParentID;
                    //            objCLM2.ParentClaimID = ObjectOCL.ParentClaimID;
                    //            objCLM2.SchemeType = ddlMode.SelectedValue;
                    //            objCLM2.ImageName = ArrFileName[j].ToString();
                    //            ctx.CLM2.Add(objCLM2);
                    //        }
                    //    }
                    //    //End File storage
                    //    // ENd File Upload
                    //    ctx.SaveChanges();
                    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Inserted Successfully And forward to " + NextMgrName + "',1);", true);
                    //    txtDate.Enabled = ddlMode.Enabled = true;
                    //    ClearAllInputs();
                    //}
                    //else
                    //{
                    int ClaimID = ctx.GetKey("OCLM", "ClaimID", "", ParentID, 0).FirstOrDefault().Value;
                    int CLM1ID = ctx.GetKey("CLM1", "CLM1ID", "", ParentID, 0).FirstOrDefault().Value;


                    OCLMP objOCLMP = new OCLMP();
                    objOCLMP.ParentClaimID = ctx.GetKey("OCLMP", "ParentClaimID", "", ParentID, 0).FirstOrDefault().Value;
                    objOCLMP.ParentID = ParentID;
                    objOCLMP.SchemeType = ddlMode.SelectedValue;
                    objOCLMP.CreatedDate = DateTime.Now;
                    objOCLMP.FromDate = Fromdate;
                    objOCLMP.IsSAP = ParentCustID == 1000010000000000 ? true : false;
                    objOCLMP.ToDate = Todate;
                    objOCLMP.CreatedBy = UserID;
                    objOCLMP.CreatedIPAddress = IPAdd;
                    objOCLMP.IsActive = true;
                    // Check Claim Level Hierarchy
                    Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                    SqlCommand Cmd2 = new SqlCommand();
                    Cmd2.Parameters.Clear();
                    Cmd2.CommandType = CommandType.StoredProcedure;
                    Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchyHardCode";
                    Cmd2.Parameters.AddWithValue("@ParentID", ParentID);
                    Cmd2.Parameters.AddWithValue("@UserID", UserID);
                    Cmd2.Parameters.AddWithValue("@ClaimDate", Fromdate);
                    DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
                    if (dsdata1.Tables.Count > 0)
                    {
                        if (dsdata1.Tables[0].Rows.Count > 0)
                        {
                            if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) > 0)
                            {

                                IsHierarchy = true;
                                objOCLMP.ClaimLevel = 1;
                                objOCLMP.HierarchyManagerId = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());

                            }
                            else if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "FALSE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) == 0)
                            {
                                objOCLMP.HierarchyManagerId = 0;
                                objOCLMP.ClaimLevel = 0;
                                var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID).StateID;
                                string Region = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId).StateName;
                                var ReasonId1 = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                                string ClaimType1 = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId1).ReasonName;
                                // var ManageId = ctx.CheckHierarchyManagerId(true, Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()), Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString()), ReasonId, RegionId);
                                Int16 ManageId = 0;
                                Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                                SqlCommand Cmd3 = new SqlCommand();
                                Cmd3.Parameters.Clear();
                                Cmd3.CommandType = CommandType.StoredProcedure;
                                Cmd3.CommandText = "CheckHierarchyManagerId";
                                Cmd3.Parameters.AddWithValue("@IsHeirarchy", false);
                                Cmd3.Parameters.AddWithValue("@ClaimLevel", dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString());
                                Cmd3.Parameters.AddWithValue("@EmpId", dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                                Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId1);
                                Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                                DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                if (dsdata2.Tables.Count > 0)
                                {
                                    if (dsdata2.Tables[0].Rows.Count > 0)
                                    {
                                        ManageId = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                                    }
                                }
                                objOCLMP.HierarchyManagerId = ManageId;
                                IsHierarchy = true;
                                if (objOCLMP.HierarchyManagerId == 0)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Entry Not Found in Employee wise Reason code master. " + Region + " - " + ClaimType1 + "',3);", true);
                                    return;
                                }

                            }
                            else
                            {
                                IsHierarchy = false;
                                objOCLMP.HierarchyManagerId = 0;
                                objOCLMP.ClaimLevel = -1;
                                var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == ParentID).StateID;
                                string Region = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId).StateName;
                                var ReasonId2 = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                                string ClaimType2 = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId2).ReasonName;
                                // var ManageId = ctx.CheckHierarchyManagerId(true, Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()), Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString()), ReasonId, RegionId);
                                Int16 ManageId = 0;
                                Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                                SqlCommand Cmd3 = new SqlCommand();
                                Cmd3.Parameters.Clear();
                                Cmd3.CommandType = CommandType.StoredProcedure;
                                Cmd3.CommandText = "CheckHierarchyManagerId";
                                Cmd3.Parameters.AddWithValue("@IsHeirarchy", false);
                                Cmd3.Parameters.AddWithValue("@ClaimLevel", dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString());
                                Cmd3.Parameters.AddWithValue("@EmpId", dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                                Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId2);
                                Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                                DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                if (dsdata2.Tables.Count > 0)
                                {
                                    if (dsdata2.Tables[0].Rows.Count > 0)
                                    {
                                        ManageId = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                                    }
                                }
                                objOCLMP.HierarchyManagerId = ManageId;
                                if (objOCLMP.HierarchyManagerId == 0)
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Entry Not Found in Employee wise Reason code master. " + Region + " - " + ClaimType2 + "',3);", true);
                                    return;
                                }
                                //var ReasonId = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                                //var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == ParentID && x.Active == true).Unit;
                                //List<OCUM> ObjectOcum = ctx.OCUMs.Where(x => x.OptionId == 1 && x.Unit == DistUnitId && x.Active == true).ToList();
                                //objOCLMP.HierarchyManagerId = 0;
                                //if (ObjectOcum != null)
                                //{
                                //    foreach (OCUM ObjUnit in ObjectOcum)
                                //    {
                                //        Decimal OEmpId = Convert.ToDecimal(ObjUnit.CustID);
                                //        OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == OEmpId && x.Active == true && x.ReasonId == ReasonId);
                                //        if (ObjERM != null)
                                //        {
                                //            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == OEmpId && x.ParentID == 1000010000000000 && x.EmpGroupID == 9 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                //            if (objOEMP != null)
                                //            {
                                //                objOCLMP.HierarchyManagerId = objOEMP.EmpID;
                                //                break;
                                //            }
                                //            else
                                //            {
                                //                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Hierarchy in-complete for this claim type.',3);", true);
                                //                return;
                                //                objOCLMP.HierarchyManagerId = 0;
                                //            }

                                //        }
                                //    }
                                //    //if (txtManager.Text == "")
                                //    //{
                                //    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Hierarchy in-complete for this claim type.',3);", true);
                                //    //    return;
                                //    //}
                                //}

                            }
                        }
                    }
                    if (objOCLMP.HierarchyManagerId == null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Manager Id not found please try after some time.',3);", true);
                        return;
                    }
                    if (IsHierarchy)
                    {
                        if (!flpFileUpload.HasFile)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you have to upload Claim report with sign and Stamp',3);", true);
                            return;
                        }
                        for (int i = 0; i < uploadedFiles.Count; i++)
                        {

                            HttpPostedFile userPostedFile = uploadedFiles[i];
                            string ext = System.IO.Path.GetExtension(userPostedFile.FileName);
                            if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                            {
                                double filesize = userPostedFile.ContentLength;
                                if (filesize < (1024000))   // 1 MB File Size
                                {

                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not upload more than 1 MB File size.!',3);", true);
                                    return;
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png,  jpeg, pdf file!',3);", true);
                                return;
                            }

                        }
                    }
                    // End // Check Claim Level Hierarchy
                    ctx.OCLMPs.Add(objOCLMP);
                    if (IsHierarchy)
                    {
                        string[] ArrFileName = new string[uploadedFiles.Count];
                        for (int i = 0; i < uploadedFiles.Count; i++)
                        {
                            string strFilePath = "";
                            HttpPostedFile userPostedFile = uploadedFiles[i];
                            string ext = System.IO.Path.GetExtension(userPostedFile.FileName);
                            if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf")
                            {
                                double filesize = userPostedFile.ContentLength;
                                if (filesize < (1024000))   // 1 MB File Size
                                {
                                    strFilePath = ParentID + "_" + ddlMode.SelectedValue.ToString() + "_" + Fromdate.Month + "_" + Fromdate.Year + "_" + i.ToString() + ext;
                                    userPostedFile.SaveAs(filepath + "\\" + Path.GetFileName(strFilePath));
                                    ArrFileName[i] = strFilePath;
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not upload more than 1 MB File size.!',3);", true);
                                    return;
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png,  jpeg, pdf file!',3);", true);
                                return;
                            }

                        }
                        // Store File in Table
                        for (int j = 0; j < ArrFileName.Length; j++)
                        {

                            CLM2 objCLM2 = new CLM2();
                            objCLM2.CLM2ID = CLM2ID++;
                            objCLM2.ParentID = ParentID;
                            objCLM2.ParentClaimID = objOCLMP.ParentClaimID;
                            objCLM2.SchemeType = ddlMode.SelectedValue;
                            objCLM2.ImageName = ArrFileName[j].ToString();
                            ctx.CLM2.Add(objCLM2);
                        }
                    }
                    //End File storage
                    // ENd File Upload
                    if (ddlMode.SelectedValue == "M")
                    {
                        #region Master Scheme
                        List<CLM1> MasterList = new List<CLM1>();

                        foreach (GridViewRow item in gvMasterScheme.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistContTax = (Literal)item.FindControl("lblDistContTax");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");
                            Literal lblTotalCompanyCont = (Literal)item.FindControl("lblTotalCompanyCont");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "M";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            MasterList.Add(objCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == ParentID && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
                            != MasterList.Count(y => y.DocType == "SALE"))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your claim is not submitted properly, please refrsh and try again.',3);", true);
                            return;
                        }

                        var MasterClaims = (from c in MasterList
                                            group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                            select new
                                            {
                                                CustomerID = g.Key.CustomerID,
                                                SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                                SchemeID = g.Key.SchemeID,
                                                SchemeAmount = g.Sum(x => x.SchemeAmount),
                                                CompanyCont = g.Sum(x => x.CompanyCont),
                                                DistCont = g.Sum(x => x.DistCont),
                                                DistContTax = g.Sum(x => x.DistContTax),
                                                TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                                TotalPurchase = g.Sum(x => x.SubTotal)
                                            }).ToList();

                        ApprovedAmount = MasterClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = MasterClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = MasterClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in MasterClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "M";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = MasterList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "S")
                    {
                        #region QPS Scheme
                        List<CLM1> QPSList = new List<CLM1>();

                        foreach (GridViewRow item in gvQPSScheme.Rows)
                        {
                            HtmlInputHidden hdnItemID = (HtmlInputHidden)item.FindControl("hdnItemID");
                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistContTax = (Literal)item.FindControl("lblDistContTax");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");
                            Literal lblTotalCompanyCont = (Literal)item.FindControl("lblTotalCompanyCont");
                            Literal lblTotalQty = (Literal)item.FindControl("lblTotalQty");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            if (Int32.TryParse(hdnItemID.Value, out IntNum) && IntNum > 0)
                                objCLM1.ItemID = IntNum;
                            objCLM1.TotalQty = Decimal.TryParse(lblTotalQty.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            QPSList.Add(objCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == ParentID && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
                            != QPSList.Count(y => y.DocType == "SALE"))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your claim is not submitted properly, please refrsh and try again.',3);", true);
                            return;
                        }

                        var QPSClaims = (from c in QPSList
                                         group c by new { c.CustomerID, c.SAPReasonItemCode, c.ItemID, c.SchemeID } into g
                                         select new
                                         {
                                             CustomerID = g.Key.CustomerID,
                                             SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                             ItemID = g.Key.ItemID,
                                             SchemeID = g.Key.SchemeID,
                                             TotalQty = g.Sum(x => x.TotalQty),
                                             SchemeAmount = g.Sum(x => x.SchemeAmount),
                                             CompanyCont = g.Sum(x => x.CompanyCont),
                                             DistCont = g.Sum(x => x.DistCont),
                                             DistContTax = g.Sum(x => x.DistContTax),
                                             TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                             TotalPurchase = g.Sum(x => x.SubTotal)
                                         }).ToList();

                        ApprovedAmount = QPSClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = QPSClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = QPSClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in QPSClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.ItemID = item.ItemID;
                            objOCLM.TotalQty = item.TotalQty;
                            objOCLM.SchemeType = "S";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = QPSList.Where(x => x.CustomerID == item.CustomerID && x.SchemeID == item.SchemeID && x.ItemID == item.ItemID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = "S";
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.TotalQty = clm1.TotalQty;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "D")
                    {
                        #region Machine Scheme
                        List<CLM1> MachineList = new List<CLM1>();

                        foreach (GridViewRow item in gvMachineScheme.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistContTax = (Literal)item.FindControl("lblDistContTax");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");
                            Literal lblTotalCompanyCont = (Literal)item.FindControl("lblTotalCompanyCont");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "D";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            MachineList.Add(objCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == ParentID && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
                            != MachineList.Count(y => y.DocType == "SALE"))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your claim is not submitted properly, please refrsh and try again.',3);", true);
                            return;
                        }

                        var MachineClaims = (from c in MachineList
                                             group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                             select new
                                             {
                                                 CustomerID = g.Key.CustomerID,
                                                 SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                                 SchemeID = g.Key.SchemeID,
                                                 SchemeAmount = g.Sum(x => x.SchemeAmount),
                                                 CompanyCont = g.Sum(x => x.CompanyCont),
                                                 DistCont = g.Sum(x => x.DistCont),
                                                 DistContTax = g.Sum(x => x.DistContTax),
                                                 TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                                 TotalPurchase = g.Sum(x => x.SubTotal)
                                             }).ToList();

                        ApprovedAmount = MachineClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = MachineClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = MachineClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in MachineClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "D";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = MachineList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "P")
                    {
                        #region Parlour Scheme
                        List<CLM1> ParlourList = new List<CLM1>();

                        foreach (GridViewRow item in gvParlourScheme.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistContTax = (Literal)item.FindControl("lblDistContTax");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");
                            Literal lblTotalCompanyCont = (Literal)item.FindControl("lblTotalCompanyCont");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "P";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            ParlourList.Add(objCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == ParentID && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
                            != ParlourList.Count(y => y.DocType == "SALE"))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your claim is not submitted properly, please refrsh and try again.',3);", true);
                            return;
                        }

                        var ParlourClaims = (from c in ParlourList
                                             group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                             select new
                                             {
                                                 CustomerID = g.Key.CustomerID,
                                                 SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                                 SchemeID = g.Key.SchemeID,
                                                 SchemeAmount = g.Sum(x => x.SchemeAmount),
                                                 CompanyCont = g.Sum(x => x.CompanyCont),
                                                 DistCont = g.Sum(x => x.DistCont),
                                                 DistContTax = g.Sum(x => x.DistContTax),
                                                 TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                                 TotalPurchase = g.Sum(x => x.SubTotal)
                                             }).ToList();

                        ApprovedAmount = ParlourClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = ParlourClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = ParlourClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in ParlourClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "P";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = ParlourList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "V")  // VRS Discount scheme
                    {
                        #region VRS Discount
                        List<CLM1> VRSList = new List<CLM1>();

                        foreach (GridViewRow item in gvVRSDiscount.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistContTax = (Literal)item.FindControl("lblDistContTax");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");
                            Literal lblTotalCompanyCont = (Literal)item.FindControl("lblTotalCompanyCont");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "V";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            VRSList.Add(objCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == ParentID && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
                            != VRSList.Count(y => y.DocType == "SALE"))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Your claim is not submitted properly, please refrsh and try again.',3);", true);
                            return;
                        }

                        var VRSClaims = (from c in VRSList
                                         group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                         select new
                                         {
                                             CustomerID = g.Key.CustomerID,
                                             SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                             SchemeID = g.Key.SchemeID,
                                             SchemeAmount = g.Sum(x => x.SchemeAmount),
                                             CompanyCont = g.Sum(x => x.CompanyCont),
                                             DistCont = g.Sum(x => x.DistCont),
                                             DistContTax = g.Sum(x => x.DistContTax),
                                             TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                             TotalPurchase = g.Sum(x => x.SubTotal)
                                         }).ToList();

                        ApprovedAmount = VRSClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = VRSClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = VRSClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in VRSClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "V";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = VRSList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "F")
                    {
                        #region FOW Scheme
                        List<CLM1> FOWList = new List<CLM1>();

                        foreach (GridViewRow item in gvFOWScheme.Rows)
                        {

                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "F";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = 0;
                            objCLM1.DistContPer = 0;
                            objCLM1.CompanyCont = 0;
                            objCLM1.DistCont = 0;
                            objCLM1.DistContTax = 0;
                            objCLM1.TotalCompanyCont = 0;

                            FOWList.Add(objCLM1);

                        }

                        var FOWClaims = (from c in FOWList
                                         group c by new { c.CustomerID, c.SAPReasonItemCode } into g
                                         select new
                                         {
                                             CustomerID = g.Key.CustomerID,
                                             SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                             SchemeAmount = g.Sum(x => x.SchemeAmount),
                                             TotalPurchase = g.Sum(x => x.SubTotal)
                                         }).ToList();

                        ApprovedAmount = FOWClaims.Sum(x => x.SchemeAmount);
                        TotalPurchase = FOWClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = FOWClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in FOWClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = 0;
                            objOCLM.SchemeType = "F";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = 0;
                            objOCLM.DistCont = 0;
                            objOCLM.DistContTax = 0;
                            objOCLM.TotalCompanyCont = item.SchemeAmount;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.SchemeAmount;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = FOWList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "T")
                    {
                        #region Sec Freight Scheme
                        List<CLM1> SecFreightList = new List<CLM1>();

                        foreach (GridViewRow item in gvSecFreight.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "T";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = 0;
                            objCLM1.CompanyCont = 0;
                            objCLM1.DistCont = 0;
                            objCLM1.DistContTax = 0;
                            objCLM1.TotalCompanyCont = objCLM1.SchemeAmount;

                            SecFreightList.Add(objCLM1);

                        }

                        var SecFreightClaims = (from c in SecFreightList
                                                group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                                select new
                                                {
                                                    CustomerID = g.Key.CustomerID,
                                                    SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                                    SchemeID = g.Key.SchemeID,
                                                    SchemeAmount = g.Sum(x => x.SchemeAmount),
                                                    CompanyCont = g.Sum(x => x.CompanyCont),
                                                    DistCont = g.Sum(x => x.DistCont),
                                                    DistContTax = g.Sum(x => x.DistContTax),
                                                    TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                                    TotalPurchase = g.Sum(x => x.SubTotal)
                                                }).ToList();

                        ApprovedAmount = SecFreightClaims.Sum(x => x.TotalCompanyCont);
                        TotalPurchase = SecFreightClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = SecFreightClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in SecFreightClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "T";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = SecFreightList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "R")
                    {
                        #region Rate Diff Scheme


                        List<CLM1> RateDiffList = new List<CLM1>();

                        foreach (GridViewRow item in gvRateDiff.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");
                            HtmlInputHidden hdnDistContPer = (HtmlInputHidden)item.FindControl("hdnDistContPer");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblCompanyCont = (Literal)item.FindControl("lblCompanyCont");
                            Literal lblDistCont = (Literal)item.FindControl("lblDistCont");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "R";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objCLM1.DistContTax = 0;
                            objCLM1.TotalCompanyCont = objCLM1.CompanyCont;

                            RateDiffList.Add(objCLM1);

                        }
                        var RateDiffClaims = (from c in RateDiffList
                                              group c by new { c.CustomerID, c.SAPReasonItemCode, c.SchemeID } into g
                                              select new
                                              {
                                                  CustomerID = g.Key.CustomerID,
                                                  SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                                  SchemeID = g.Key.SchemeID,
                                                  SchemeAmount = g.Sum(x => x.SchemeAmount),
                                                  CompanyCont = g.Sum(x => x.CompanyCont),
                                                  DistCont = g.Sum(x => x.DistCont),
                                                  DistContTax = g.Sum(x => x.DistContTax),
                                                  TotalCompanyCont = g.Sum(x => x.TotalCompanyCont),
                                                  TotalPurchase = g.Sum(x => x.SubTotal)
                                              }).ToList();

                        ApprovedAmount = RateDiffClaims.Sum(x => x.TotalCompanyCont);
                        if (ApprovedAmount == 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Amount is zero so you can not claim.',3);", true);
                            return;

                        }

                        TotalPurchase = RateDiffClaims.Sum(x => x.TotalPurchase);
                        ReasonCode = RateDiffClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in RateDiffClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "R";
                            objOCLM.SchemeAmount = item.SchemeAmount;
                            objOCLM.CompanyCont = item.CompanyCont;
                            objOCLM.DistCont = item.DistCont;
                            objOCLM.DistContTax = item.DistContTax;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = item.TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = RateDiffList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;
                                objCLM1.SchemeAmount = clm1.SchemeAmount;
                                objCLM1.CompanyContPer = clm1.CompanyContPer;
                                objCLM1.DistContPer = clm1.DistContPer;
                                objCLM1.CompanyCont = clm1.CompanyCont;
                                objCLM1.DistCont = clm1.DistCont;
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "I")
                    {
                        #region IOU Auto Claim
                        List<CLM1> IOUList = new List<CLM1>();

                        foreach (GridViewRow item in gvIOU.Rows)
                        {
                            HtmlInputHidden hdnItemID = (HtmlInputHidden)item.FindControl("hdnItemID");
                            HtmlInputHidden hdnOINVRID = (HtmlInputHidden)item.FindControl("hdnOINVRID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");
                            HtmlInputHidden hdnPerClaim = (HtmlInputHidden)item.FindControl("hdnPerClaim");
                            HtmlInputHidden hdnPerPurchase = (HtmlInputHidden)item.FindControl("hdnPerPurchase");
                            HtmlInputHidden hdnClaimPurAmtForPer = (HtmlInputHidden)item.FindControl("hdnClaimPurAmtForPer");
                            HtmlInputHidden hdnFinalClaimAmt = (HtmlInputHidden)item.FindControl("hdnFinalClaimAmt");
                            HtmlInputHidden hdnGrossPurchaseDist = (HtmlInputHidden)item.FindControl("hdnGrossPurchaseDist");

                            Literal lblTotalQty = (Literal)item.FindControl("lblTotalQty");
                            Literal lblGrossPurchase = (Literal)item.FindControl("lblGrossPurchase");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");
                            Literal lblPerClaimAmt = (Literal)item.FindControl("lblPerClaimAmt");
                            Literal lblPerPurchaseAmt = (Literal)item.FindControl("lblPerPurchaseAmt");
                            Literal lblFinalClaimAmt = (Literal)item.FindControl("lblFinalClaimAmt");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnOINVRID.Value, out IntNum) ? IntNum : 0; //OINVR [IOU dist. entry] table.
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = "SALE";
                            objCLM1.SchemeType = "I";
                            objCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objCLM1.SchemeID = 0;
                            objCLM1.ItemID = Int32.TryParse(hdnItemID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.TotalQty = Decimal.TryParse(lblTotalQty.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(hdnGrossPurchaseDist.Value, out DecNum) ? DecNum : 0; // Total purchase of dist for claiming month.
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0; // Distributor's Claim Amt[Entered amt by dist.]
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnPerClaim.Value, out DecNum) ? DecNum : 0; // % of Claim Amt
                            objCLM1.DistContPer = Decimal.TryParse(hdnPerPurchase.Value, out DecNum) ? DecNum : 0;// % of Purchase Amt
                            objCLM1.CompanyCont = Decimal.TryParse(lblPerClaimAmt.Text, out DecNum) ? DecNum : 0;// Amount [% of Claim Amt]
                            objCLM1.DistCont = Decimal.TryParse(hdnClaimPurAmtForPer.Value, out DecNum) ? DecNum : 0;// Amount [% of Purchase Amt]
                            objCLM1.TotalCompanyCont = Decimal.TryParse(hdnFinalClaimAmt.Value, out DecNum) ? DecNum : 0;// Final Claim Calulated amt [Min of two amt.] 
                            objCLM1.DistContTax = 0;
                            IOUList.Add(objCLM1);

                        }

                        var IOUClaims = (from c in IOUList
                                         group c by new { c.CustomerID, c.SAPReasonItemCode, c.SubTotal, c.DistCont, c.TotalCompanyCont } into g
                                         select new
                                         {
                                             CustomerID = g.Key.CustomerID,
                                             SAPReasonItemCode = g.Key.SAPReasonItemCode,
                                             SchemeID = 0,
                                             TotalPurchase = g.Key.SubTotal,
                                             SchemeAmount = g.Sum(x => x.SchemeAmount),
                                             TotalQty = g.Sum(x => x.TotalQty),
                                             CompanyCont = g.Sum(x => x.CompanyCont),
                                             DistCont = g.Key.DistCont,
                                             TotalCompanyCont = g.Key.TotalCompanyCont
                                         }).ToList();

                        ApprovedAmount = IOUClaims.FirstOrDefault().TotalCompanyCont;
                        TotalPurchase = IOUClaims.FirstOrDefault().TotalPurchase; //TotalPurchase by dist..
                        ReasonCode = IOUClaims.FirstOrDefault().SAPReasonItemCode;

                        foreach (var item in IOUClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 1;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = item.TotalQty;
                            objOCLM.SchemeID = 0;
                            objOCLM.SchemeType = "I";
                            objOCLM.SchemeAmount = item.SchemeAmount; // Distributor's Claim Amt[Entered amt by dist.]
                            objOCLM.CompanyCont = item.CompanyCont;//SUM Amount [% of Claim Amt]
                            objOCLM.DistCont = item.DistCont;//SUM Amount [% of Purchase Amt]
                            objOCLM.DistContTax = 0;
                            objOCLM.TotalCompanyCont = item.TotalCompanyCont;// Final Claim Calulated amt [Min of two amt.] 
                            objOCLM.Deduction = 0;
                            objOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objOCLM.TotalPurchase = TotalPurchase;
                            objOCLM.Total = 0;
                            objOCLM.IsAuto = true;
                            objOCLMP.OCLMs.Add(objOCLM);

                            var FiltedList = IOUList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (CLM1 clm1 in FiltedList)
                            {
                                CLM1 objCLM1 = new CLM1();
                                objCLM1.CLM1ID = CLM1ID++;
                                objCLM1.SaleID = clm1.SaleID;//OINVR [IOU dist. entry] table.
                                objCLM1.CustomerID = clm1.CustomerID;
                                objCLM1.DocType = clm1.DocType;
                                objCLM1.SchemeType = clm1.SchemeType;
                                objCLM1.SchemeID = clm1.SchemeID;
                                objCLM1.ItemID = clm1.ItemID;
                                objCLM1.TotalQty = clm1.TotalQty;
                                objCLM1.SAPReasonItemCode = clm1.SAPReasonItemCode;
                                objCLM1.SubTotal = clm1.SubTotal;           // Total purchase of dist for claiming month.
                                objCLM1.SchemeAmount = clm1.SchemeAmount;   // Distributor's Claim Amt[Entered amt by dist.]
                                objCLM1.CompanyContPer = clm1.CompanyContPer;// % of Claim Amt
                                objCLM1.DistContPer = clm1.DistContPer;// % of Purchase Amt
                                objCLM1.CompanyCont = clm1.CompanyCont;// Amount [% of Claim Amt]
                                objCLM1.DistCont = clm1.DistCont;// Amount [% of Purchase Amt]
                                objCLM1.DistContTax = clm1.DistContTax;
                                objCLM1.TotalCompanyCont = clm1.TotalCompanyCont;// Final Claim Calulated amt [Min of two amt.]

                                objOCLM.CLM1.Add(objCLM1);
                            }
                        }

                        #endregion
                    }

                    if (objOCLMP.IsSAP == false)
                    {
                        OCLMCLD objOCLMCLD = new OCLMCLD();
                        objOCLMCLD.ClaimChildID = ctx.GetKey("OCLMCLD", "ClaimChildID", "", ParentCustID, 0).FirstOrDefault().Value;
                        objOCLMCLD.ParentID = ParentCustID;
                        objOCLMCLD.DocNo = DateTime.Now.ToString("yyMMdd") + objOCLMCLD.ClaimChildID.ToString("D7");
                        objOCLMCLD.CustomerID = objOCLMP.ParentID;
                        objOCLMCLD.ParentClaimID = objOCLMP.ParentClaimID;
                        objOCLMCLD.FromDate = objOCLMP.FromDate;
                        objOCLMCLD.ToDate = objOCLMP.ToDate;
                        objOCLMCLD.ClaimDate = objOCLMP.CreatedDate;
                        objOCLMCLD.SchemeAmount = ApprovedAmount;
                        objOCLMCLD.Deduction = 0;
                        objOCLMCLD.ApprovedAmount = ApprovedAmount;
                        objOCLMCLD.DeductionRemarks = null;
                        objOCLMCLD.ReasonCode = ReasonCode;
                        objOCLMCLD.IsAuto = true;
                        objOCLMCLD.TotalSale = ctx.OPOS.Where(x => x.ParentID == ParentID && x.Date.Month == Fromdate.Month && x.Date.Year == Fromdate.Year).Select(x => x.SubTotal).DefaultIfEmpty(0).Sum();
                        objOCLMCLD.SchemeSale = TotalPurchase;
                        objOCLMCLD.CreatedDate = DateTime.Now;
                        objOCLMCLD.CreatedBy = UserID;
                        objOCLMCLD.UpdatedDate = DateTime.Now;
                        objOCLMCLD.UpdatedBy = UserID;
                        objOCLMCLD.Status = 1;
                        ctx.OCLMCLDs.Add(objOCLMCLD);
                    }


                    string NextMgrName = "";
                    if (objOCLMP.HierarchyManagerId > 0)
                    {
                        var objOEMP = ctx.OEMPs.Where(x => x.EmpID == objOCLMP.HierarchyManagerId).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                        NextMgrName = objOEMP.Name;
                    }
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Inserted Successfully And forward to " + NextMgrName + "',1);", true);
                    txtDate.Enabled = ddlMode.Enabled = true;
                    // Next Manager Claim  Notification IN DMS
                    string title = "Claim Submit By Distributor";
                    OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == objOCLMP.HierarchyManagerId).FirstOrDefault();
                    OCRD ObjDist = ctx.OCRDs.Where(x => x.CustomerID == ParentID).FirstOrDefault();
                    var ReasonId = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                    string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
                    string body = "Claim Submit By " + ObjDist.CustomerCode + "-" + System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(ObjDist.CustomerName) + ". for the month of " + Fromdate.ToString("MMM") + "/" + Fromdate.ToString("yyyy") + " and Claim Type " + ClaimType + " and amount Rs. " + ApprovedAmount.ToString("0.00");
                    String NBody = System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(body);
                    OGCM objOGCM = null;
                    objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == objOCLMP.HierarchyManagerId && x.IsActive);

                    if (objOGCM != null)
                    {
                        GCM1 objGCM1 = new GCM1();
                        //  objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", objOCLMP.HierarchyManagerId, 0).FirstOrDefault().Value;
                        objGCM1.ParentID = 1000010000000000;
                        objGCM1.DeviceID = objOGCM.DeviceID;
                        objGCM1.CreatedDate = DateTime.Now;
                        objGCM1.CreatedBy = Convert.ToInt16(objOCLMP.HierarchyManagerId);
                        objGCM1.Body = NBody;
                        objGCM1.Title = title;
                        objGCM1.UnRead = true;
                        objGCM1.IsDeleted = false;
                        objGCM1.SentOn = true;
                        ctx.GCM1.Add(objGCM1);
                    }
                    ctx.SaveChanges();
                    ClearAllInputs();

                    // }  // 14-Dec-22
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found.',3);", true);
            }
        }
        catch (DbEntityValidationException ex)
        {
            var error = ex.EntityValidationErrors.First().ValidationErrors.First();
            if (error != null)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + error.ErrorMessage.Replace("'", "") + "',2);", true);
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
            return;
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtDate.Enabled = ddlMode.Enabled = btnSubmit.Enabled = true;
        // 
        txtDate.Text = "";
        ddlMode.SelectedValue = "M";
        ClearAllInputs();
    }

    #endregion

    #region Gridview Events

    protected void gvMasterScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMasterScheme.Rows.Count > 0)
        {
            gvMasterScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMasterScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvMachineScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMachineScheme.Rows.Count > 0)
        {
            gvMachineScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMachineScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvQPSScheme_PreRender(object sender, EventArgs e)
    {
        if (gvQPSScheme.Rows.Count > 0)
        {
            gvQPSScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvQPSScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvParlourScheme_PreRender(object sender, EventArgs e)
    {
        if (gvParlourScheme.Rows.Count > 0)
        {
            gvParlourScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvParlourScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvVRSDiscount_PreRender(object sender, EventArgs e)
    {
        if (gvVRSDiscount.Rows.Count > 0)
        {
            gvVRSDiscount.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvVRSDiscount.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvFOWScheme_PreRender(object sender, EventArgs e)
    {
        if (gvFOWScheme.Rows.Count > 0)
        {
            gvFOWScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvFOWScheme.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvSecFreight_PreRender(object sender, EventArgs e)
    {
        if (gvSecFreight.Rows.Count > 0)
        {
            gvSecFreight.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSecFreight.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvRateDiff_PreRender(object sender, EventArgs e)
    {
        if (gvRateDiff.Rows.Count > 0)
        {
            gvRateDiff.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvRateDiff.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvIOU_PreRender(object sender, EventArgs e)
    {
        if (gvIOU.Rows.Count > 0)
        {
            gvIOU.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvIOU.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion

}