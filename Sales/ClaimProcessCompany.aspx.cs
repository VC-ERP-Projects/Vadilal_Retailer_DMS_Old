﻿using ClaimDMS;
using Scheme;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_ClaimProcessCompany : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;
    protected bool IsHierarchy = false;
    List<GetEmpHierarchyTree_Result> Data;
    //  List<usp_GetMangerList_Result> DataManager;
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

                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

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

    public void ClearAllInputs(Boolean allclear)
    {
        gvCommon.Visible = gvSecFreight.Visible = gvFOWScheme.Visible = gvParlourScheme.Visible = gvRateDiff.Visible = gvVRSDiscount.Visible = gvMachineScheme.Visible = gvMasterScheme.Visible = gvQPSScheme.Visible = gvIOUClaim.Visible = false;
        gvCommon.Enabled = gvSecFreight.Enabled = gvFOWScheme.Enabled = gvParlourScheme.Enabled = gvRateDiff.Enabled = gvVRSDiscount.Enabled = gvMachineScheme.Enabled = gvQPSScheme.Enabled = gvMasterScheme.Enabled = gvIOUClaim.Enabled = true;
        gvMasterScheme.DataSource = null;
        gvMasterScheme.DataBind();

        gvMachineScheme.DataSource = null;
        gvMachineScheme.DataBind();

        gvQPSScheme.DataSource = null;
        gvQPSScheme.DataBind();

        gvParlourScheme.DataSource = null;
        gvParlourScheme.DataBind();

        gvRateDiff.DataSource = null;
        gvRateDiff.DataBind();

        gvVRSDiscount.DataSource = null;
        gvVRSDiscount.DataBind();

        gvFOWScheme.DataSource = null;
        gvFOWScheme.DataBind();

        gvSecFreight.DataSource = null;
        gvSecFreight.DataBind();

        gvIOUClaim.DataSource = null;
        gvIOUClaim.DataBind();

        gvCommon.DataSource = null;
        gvCommon.DataBind();

        if (allclear)
        {
            txtNotes.Text = txtSSDist.Text = txtCustCode.Text = txtDate.Text = "";
            txtSSDist.Enabled = txtCustCode.Enabled = txtDate.Enabled = ddlMode.Enabled = txtManager.Enabled = true;
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();

        if (!IsPostBack)
        {
            ClearAllInputs(true);

            txtDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
            using (DDMSEntities ctx = new DDMSEntities())
            {
                OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == UserID).FirstOrDefault();
                if (ObjEmp.EmpGroupID == 9)
                {
                    ddlMode.DataTextField = "ReasonName";
                    ddlMode.DataValueField = "ReasonID";
                    ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                    ddlMode.DataBind();
                }
                else
                {
                    ddlMode.DataTextField = "ReasonName";
                    ddlMode.DataValueField = "ReasonID";
                    ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S" && x.IsAuto == true).Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID, x.IsAuto }).OrderByDescending(x => x.IsAuto).ToList();
                    ddlMode.DataBind();
                }

                var ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).ManagerID;
                if (ManagerID.HasValue)
                {
                    //if (ManagerID == 30 || ManagerID == 45)
                    //{
                    //    var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ManagerID && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                    //    txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                    //}
                    //else
                    //{
                    var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ManagerID && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                    txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                    //}
                }

                var objectEMP = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => new { x.EmpGroupID }).FirstOrDefault();
                if (objectEMP != null)
                {
                    if (objectEMP.EmpGroupID.HasValue)
                    {
                        if (objectEMP.EmpGroupID == 2 || objectEMP.EmpGroupID == 3 || objectEMP.EmpGroupID == 4 || objectEMP.EmpGroupID == 9 || objectEMP.EmpGroupID == 12 || objectEMP.EmpGroupID == 13 || objectEMP.EmpGroupID == 14 || objectEMP.EmpGroupID == 15)
                        {
                            // btnRejectClaim.Visible = true;
                            txtManager.Enabled = false;
                        }
                        else
                        {
                            btnRejectClaim.Visible = false;
                        }
                        btnRejectClaim.Visible = false;
                        //int RouteId = ctx.RUT1.FirstOrDefault(x => x.CustomerID == CustomerID && x.Active == true).RouteID;
                        //var PreSalesId = ctx.ORUTs.FirstOrDefault(x => x.RouteID == RouteId).PrefSalesPersonID;
                        //if (PreSalesId == UserID)
                        //{
                        //    ddlDisplay.Enabled = true;
                        //}
                        //else
                        //{
                        //    ddlDisplay.Enabled = false;
                        //}
                    }
                }
                //if (ctx.OAWRKs.Any(x => x.RequestTypeMenuID == 161 && x.Status == 2))
                //{
                //    txtManager.Text = "";
                //    txtManager.Enabled = true;

                //    OAWRK objOAWRK = ctx.OAWRKs.Where(x => x.RequestTypeMenuID == 161 && x.Status == 2).OrderBy(x => x.LevelNo).FirstOrDefault();
                //    if (objOAWRK.IsManager)
                //    {
                //        var ManagerID = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID).ManagerID;
                //        if (ManagerID.HasValue)
                //        {
                //            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ManagerID && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                //            txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                //            txtManager.Enabled = false;
                //        }
                //    }
                //    else if (objOAWRK.UserID.HasValue)
                //    {
                //        var objOEMP = ctx.OEMPs.Where(x => x.EmpID == objOAWRK.UserID.Value && x.ParentID == ParentID).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                //        txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                //        txtManager.Enabled = false;
                //    }
                //}
                //else
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Approval WorkFlow Found',3);", true);
                //    return;
                //}
            }
            //txtDate.Text = "08/2021";
            //txtCustCode.Text = "DABS9440 - SAGAR CORP. [I/C DIST] BAPUNAGAR - 2000010000100000";
            //ddlMode.SelectedValue = "72";
        }
    }

    #endregion

    #region Button Click

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs(false);
            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }
            Decimal SSID = Decimal.TryParse(txtSSDist.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
            if (DistID == 0 && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist',3);", true);
                return;
            }
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));
            Decimal CustomerID = DistID > 0 ? DistID : SSID;
            if (CustomerID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);

                    ORSN ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);
                    if (ReasonID.ToString() == "57")
                    {

                        // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                        return;
                    }
                    int RouteId = ctx.RUT1.FirstOrDefault(x => x.CustomerID == CustomerID && x.Active == true).RouteID;
                    var PreSalesId = ctx.ORUTs.FirstOrDefault(x => x.RouteID == RouteId).PrefSalesPersonID;
                    if (PreSalesId == UserID)
                    {
                        btnRejectClaim.Visible = false;
                    }
                    else
                    {
                        btnRejectClaim.Visible = true;
                    }
                    var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).StateID;

                    // Start Unit and Reason Code Validation for Claim / mtkg User   Ticket # T900011560
                    // Emp Reason
                    var EmpGroupId = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID).EmpGroupID;
                    if (EmpGroupId == 2 || EmpGroupId == 3 || EmpGroupId == 4 || EmpGroupId == 9)
                    {
                        //if (ReasonData.ReasonDesc == "R" && UserID != 3534)
                        //{
                        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this claim.',3);", true);
                        //    ClearAllInputs(true);
                        //    return;
                        //}

                        if (!ctx.OERMs.Any(x => x.FwdToEmpId == UserID && x.ReasonId == ReasonID && x.RegionId == RegionId && x.Active == true))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this reason claim.',3);", true);
                            ClearAllInputs(true);
                            return;
                        }
					 	if (!ctx.OCUMs.Any(x => x.CustID == CustomerID && x.Active == true))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer unit entry not found please contact mktg department',3);", true);
                            ClearAllInputs(true);
                            return;
                        }
                        var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == CustomerID && x.Active == true).Unit;
                        if (!ctx.OCUMs.Any(x => x.CustID == UserID && x.OptionId == 1 && x.Unit == DistUnitId))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this unit claim.',3);", true);
                            ClearAllInputs(true);
                            return;
                        }
                    }

                    // End Unit and Reason code validation
                    if (ctx.OCLMPs.Any(x => x.ParentID == CustomerID && x.SchemeType == ReasonData.ReasonDesc
                         && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year))
                    {
                        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                        SqlCommand Cm = new SqlCommand();

                        var cparentid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                        Boolean isdms = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == cparentid).Type == 4;

                        if (isdms && !ctx.OCLMCLDs.Any(x => x.CustomerID == CustomerID && x.ReasonCode == ReasonData.SAPReasonItemCode
                         && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim is not approved from his parent.',3);", true);
                            return;
                        }
                        Cm.Parameters.Clear();
                        Cm.CommandType = CommandType.StoredProcedure;
                        Cm.CommandText = "GetClaimDetailCompany";
                        Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
                        Cm.Parameters.AddWithValue("@ParentID", cparentid);
                        Cm.Parameters.AddWithValue("@IsSAP", 0);
                        Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
                        Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
                        Cm.Parameters.AddWithValue("@Type", ddlDisplay.SelectedValue);
                        Cm.Parameters.AddWithValue("@Mode", ReasonData.ReasonDesc);
                        Cm.Parameters.AddWithValue("@UserId", UserID);
                        DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        {

                            if (ds.Tables[2].Rows.Count > 0)
                            {
                                lblLastProceedby.Text =  ds.Tables[2].Rows[0][0].ToString();
                                lblaa.Visible = true;
                            }
                            string Region = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId).StateName;
                            Int16 ReasonId = Convert.ToInt16(ddlMode.SelectedValue);
                            string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
                            int ParentClaimId = 0;
                            int ClaimId = Convert.ToInt32(ds.Tables[0].Rows[0]["ClaimID"].ToString());
                            ParentClaimId = ctx.OCLMs.Where(x => x.ClaimID == ClaimId && x.ParentID == CustomerID).FirstOrDefault().ParentClaimID;
                            // Check Claim Level Hierarchy
                            Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                            SqlCommand Cmd2 = new SqlCommand();
                            Cmd2.Parameters.Clear();
                            Cmd2.CommandType = CommandType.StoredProcedure;
                            Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchyHardCode";
                            Cmd2.Parameters.AddWithValue("@ParentID", CustomerID);
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
                                        btnRejectClaim.Visible = true;
                                        int ClaimLevel = 1;
                                        if (ctx.OCLMPs.Any(x => x.ParentID == CustomerID && x.ParentClaimID == ParentClaimId))
                                        {
                                            OCLMP objOclm = ctx.OCLMPs.Where(x => x.ParentID == CustomerID && x.ParentClaimID == ParentClaimId).FirstOrDefault();
                                            ClaimLevel = Convert.ToInt16(objOclm.ClaimLevel);
                                            if (EmpGroupId != 2 || EmpGroupId != 3 || EmpGroupId != 4 || EmpGroupId != 9)
                                            {
                                                if (ClaimLevel == Convert.ToInt32(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()))
                                                {
                                                    Int32 ManageId = 0;
                                                    Int16 OEMP = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                                                    // var ManageId = ctx.CheckHierarchyManagerId(true, Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()), Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString()), ReasonId, RegionId);
                                                    Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                                                    SqlCommand Cmd3 = new SqlCommand();
                                                    Cmd3.Parameters.Clear();
                                                    Cmd3.CommandType = CommandType.StoredProcedure;
                                                    Cmd3.CommandText = "CheckHierarchyManagerId";
                                                    Cmd3.Parameters.AddWithValue("@IsHeirarchy", true);
                                                    Cmd3.Parameters.AddWithValue("@ClaimLevel", dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString());
                                                    Cmd3.Parameters.AddWithValue("@EmpId", dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                                                    Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId);
                                                    Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                                                    DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                                    if (dsdata2.Tables.Count > 0)
                                                    {
                                                        if (dsdata2.Tables[0].Rows.Count > 0)
                                                        {
                                                            ManageId = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                                                            lblOERMId.Text = dsdata2.Tables[0].Rows[0]["OERMID"].ToString();
                                                        }
                                                    }
                                                    Int16 FwdEmp = Convert.ToInt16(ManageId);
                                                    var objOEMP = ctx.OEMPs.Where(x => x.EmpID == FwdEmp && x.ParentID == 1000010000000000 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                                    if (objOEMP != null)
                                                    {
                                                        txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                                    }
                                                    //Data = ctx.GetEmpHierarchyTree(OEMP, 1000010000000000).ToList();
                                                    //for (int i = 0; i < Data.Count; i++)
                                                    //{
                                                    //    int DataEmpId = Convert.ToInt16(Data[i].EMPID);
                                                    //    Int16 OEmpId = Convert.ToInt16(Data.Where(x => x.MANAGERID == DataEmpId).FirstOrDefault().EMPID);
                                                    //    OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == OEmpId && x.Active == true && x.ReasonId == ReasonId && x.RegionId == RegionId);
                                                    //    if (ObjERM != null)
                                                    //    {
                                                    //        var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ObjERM.FwdToEmpId && x.ParentID == 1000010000000000 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                                    //        if (objOEMP != null)
                                                    //        {
                                                    //            txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                                    //            break;
                                                    //        }
                                                    //    }
                                                    //}
                                                    if (txtManager.Text == "")
                                                    {
                                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Hierarchy in-complete for this claim type.',3);", true);
                                                        return;
                                                    }
                                                    //var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == CustomerID && x.Active == true).Unit;
                                                    //List<OCUM> ObjectOcum = ctx.OCUMs.Where(x => x.OptionId == 1 && x.Unit == DistUnitId && x.Active == true).ToList();
                                                    //if (ObjectOcum != null)
                                                    //{
                                                    //    foreach (OCUM ObjUnit in ObjectOcum)
                                                    //    {
                                                    //        Decimal OEmpId = Convert.ToDecimal(ObjUnit.CustID);
                                                    //        OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == OEmpId && x.Active == true && x.ReasonId == ReasonID);
                                                    //        if (ObjERM != null)
                                                    //        {
                                                    //            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == OEmpId && x.ParentID == ParentID && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                                    //            if (objOEMP != null)
                                                    //            {
                                                    //                txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                                    //                break;
                                                    //            }
                                                    //            else
                                                    //            {
                                                    //                txtManager.Text = "";
                                                    //            }

                                                    //        }
                                                    //    }
                                                    //    if (txtManager.Text == "")
                                                    //    {
                                                    //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Hierarchy in-complete for this claim type.',3);", true);
                                                    //        return;
                                                    //    }
                                                    //}

                                                    //}
                                                }
                                                //else
                                                //{
                                                //    if (ctx.OERMs.Any(x => x.EmpId == UserID && x.Active == true && x.RegionId == RegionId && x.ReasonId == ReasonID && x.SubEmpId == 0))
                                                //    {
                                                //        OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == UserID && x.Active == true && x.ReasonId == ReasonID && x.RegionId == RegionId && x.SubEmpId == 0);
                                                //        if (ObjERM != null)
                                                //        {
                                                //            var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ObjERM.FwdToEmpId && x.ParentID == 1000010000000000 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                                //            if (objOEMP != null)
                                                //            {
                                                //                txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                                //            }
                                                //        }

                                                //    }
                                                //    else
                                                //    {
                                                //        Int16 OEMPId = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                                                //        DataManager = ctx.usp_GetMangerList(1000010000000000, OEMPId).ToList();
                                                //        for (int i = 0; i < DataManager.Count; i++)
                                                //        {
                                                //            int DataEmpId = Convert.ToInt16(DataManager[i].EmpID);
                                                //            OERM ObjERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == UserID && x.Active == true && x.ReasonId == ReasonId && x.RegionId == RegionId && x.SubEmpId == DataEmpId);
                                                //            if (ObjERM != null)
                                                //            {
                                                //                var objOEMP = ctx.OEMPs.Where(x => x.EmpID == ObjERM.FwdToEmpId && x.ParentID == 1000010000000000 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                                //                if (objOEMP != null)
                                                //                {
                                                //                    txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                                //                }
                                                //            }

                                                //        }
                                                //    }
                                                //}
                                            }
                                        }
                                    }
                                    else if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "FALSE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) == 0)
                                    {
                                        IsHierarchy = true;
                                        btnRejectClaim.Visible = false;

                                    }
                                    else
                                    {
                                        if (Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString()) == -1)
                                        {
                                            IsHierarchy = false;
                                            btnRejectClaim.Visible = false;
                                        }
                                    }
                                }
                            }
                            Int32 Empid = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out Empid) ? Empid : 0;
                            if (Empid == 30 || Empid == 45 || Empid == 0)
                            {
                                Int16 OEMP = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
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
                                Cmd3.Parameters.AddWithValue("@ReasonId", ReasonID);
                                Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                                DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                if (dsdata2.Tables.Count > 0)
                                {
                                    if (dsdata2.Tables[0].Rows.Count > 0)
                                    {
                                        ManageId = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                                       // lblOERMId.Text = dsdata2.Tables[0].Rows[0]["OERMID"].ToString();
                                    }
                                }
                                Int16 FwdEmp = Convert.ToInt16(ManageId);
                                var objOEMP = ctx.OEMPs.Where(x => x.EmpID == FwdEmp && x.ParentID == 1000010000000000 && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                                if (objOEMP != null)
                                {
                                    txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                                }
                            }
                            //OERM OOERM = ctx.OERMs.FirstOrDefault(x => x.EmpId == UserID && x.Active == true && x.ReasonId == ReasonID && x.RegionId == RegionId);
                            //if (OOERM != null)
                            //{
                            //    var objOEMP = ctx.OEMPs.Where(x => x.EmpID == OOERM.FwdToEmpId && x.ParentID == ParentID && x.Active == true).Select(x => new { x.EmpID, x.Name, x.EmpCode }).FirstOrDefault();
                            //    if (objOEMP != null)
                            //    {
                            //        txtManager.Text = objOEMP.EmpCode + " - " + objOEMP.Name + " - " + objOEMP.EmpID;
                            //    }
                            //}
                            //else
                            //{
                            //    txtManager.Text = "";
                            //}

                            // End // Check Claim Level Hierarchy
                            if (ReasonData.ReasonDesc == "M")
                            {
                                gvMasterScheme.DataSource = ds.Tables[0];
                                gvMasterScheme.DataBind();
                                gvMasterScheme.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "S")
                            {
                                gvQPSScheme.DataSource = ds.Tables[0];
                                gvQPSScheme.DataBind();
                                gvQPSScheme.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "D")
                            {
                                gvMachineScheme.DataSource = ds.Tables[0];
                                gvMachineScheme.DataBind();
                                gvMachineScheme.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "P")
                            {
                                gvParlourScheme.DataSource = ds.Tables[0];
                                gvParlourScheme.DataBind();
                                gvParlourScheme.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "V")
                            {
                                gvVRSDiscount.DataSource = ds.Tables[0];
                                gvVRSDiscount.DataBind();
                                gvVRSDiscount.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "F")
                            {
                                gvFOWScheme.DataSource = ds.Tables[0];
                                gvFOWScheme.DataBind();
                                gvFOWScheme.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "T")
                            {
                                gvSecFreight.DataSource = ds.Tables[0];
                                gvSecFreight.DataBind();
                                gvSecFreight.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "R")
                            {
                                gvRateDiff.DataSource = ds.Tables[0];
                                gvRateDiff.DataBind();
                                gvRateDiff.Visible = true;
                            }
                            else if (ReasonData.ReasonDesc == "I")
                            {
                                gvIOUClaim.DataSource = ds.Tables[0];
                                gvIOUClaim.DataBind();
                                gvIOUClaim.Visible = true;
                            }

                            else
                            {
                                gvCommon.DataSource = ds.Tables[0];
                                gvCommon.DataBind();
                                gvCommon.Visible = true;
                            }
                            txtSSDist.Enabled = txtCustCode.Enabled = txtDate.Enabled = ddlMode.Enabled = txtManager.Enabled = false;
                            DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["CreatedDate"].ToString());
                            if (Session["IsDistLogin"].ToString() != "True")
                            {
                                if (ddlMode.SelectedValue != "4" || ddlMode.SelectedValue != "5" || ddlMode.SelectedValue != "12" || ddlMode.SelectedValue != "13" || ddlMode.SelectedValue != "14" || ddlMode.SelectedValue != "15" || ddlMode.SelectedValue != "65" || ddlMode.SelectedValue != "70" || ddlMode.SelectedValue != "72")
                                {
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
                                                btnSumbit.Enabled = false;
                                                btnRejectClaim.Enabled = false;
                                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                //  return;
                                            }
                                            else
                                            {
                                                btnSumbit.Enabled = true;
                                                btnRejectClaim.Enabled = true;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        btnSumbit.Enabled = true;
                                        btnRejectClaim.Enabled = true;
                                    }
                                }
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim not found',3);", true);
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim not found',3);", true);
                    }
                }
            }
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
                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                if (String.IsNullOrEmpty(txtDate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                    txtDate.Text = "";
                    txtDate.Focus();
                    return;
                }
                Decimal DecNum = 0;
                Int32 IntNum = 0;
                DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
                DateTime enddate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

                int EmpID = 0;
                int ParentClaimID = 0;
                Decimal TotalSale = 0, SchemeAmt = 0, ApprovedAmt = 0;
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
                Decimal SSID = Decimal.TryParse(txtSSDist.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
                Decimal DistID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
                if (DistID == 0 && SSID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
                    return;
                }


                Decimal CustomerID = DistID > 0 ? DistID : SSID;
                if (CustomerID > 0)
                {
                    DateTime ClaimRequestDate;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        if (!ctx.OEMPs.Any(x => x.ParentID == ParentID && x.EmpID == EmpID && x.IsApprover && x.Active))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Manager code is not set as Approver.',3);", true);
                            return;
                        }
                        int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);
                        if (ReasonID.ToString() == "57")
                        {

                            // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
                            return;
                        }
                        ORSN ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);

                        //if (ReasonData.ReasonDesc == "R" && !new int[] { 3, 4 }.Contains(EmpID))
                        //{
                        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not send this claim to this user.',3);", true);
                        //    return;
                        //}

                        var cparentid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                        Boolean isdms = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == cparentid).Type == 4;
                        if (isdms && !ctx.OCLMCLDs.Any(x => x.CustomerID == CustomerID && x.ReasonCode == ReasonData.SAPReasonItemCode
                         && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim is not approved from his parent.',3);", true);
                            return;
                        }

                        List<OCLM> List = new List<OCLM>();

                        if (ReasonData.ReasonDesc == "M")
                        {
                            #region Master Scheme
                            foreach (GridViewRow item in gvMasterScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "S")
                        {
                            #region QPS
                            foreach (GridViewRow item in gvQPSScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "D")
                        {
                            #region Machine Scheme
                            foreach (GridViewRow item in gvMachineScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "P")
                        {
                            #region Parlour Scheme
                            foreach (GridViewRow item in gvParlourScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over   " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "V")
                        {
                            #region VRS Discount Scheme
                            foreach (GridViewRow item in gvVRSDiscount.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "F")
                        {
                            #region FOW Scheme
                            foreach (GridViewRow item in gvFOWScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "T")
                        {
                            #region Sec Freight Scheme

                            foreach (GridViewRow item in gvSecFreight.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "R")
                        {
                            #region Rate Difference
                            foreach (GridViewRow item in gvRateDiff.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "I")
                        {
                            #region IOU Claim
                            foreach (GridViewRow item in gvIOUClaim.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        HtmlInputHidden txtRemarks = (HtmlInputHidden)item.FindControl("hdnDeductionRemarks");
                                        HtmlInputHidden txtDeduction = (HtmlInputHidden)item.FindControl("hdnIOUDeduction");

                                        HtmlInputHidden lblMonthSale = (HtmlInputHidden)item.FindControl("hdnlblMonthSale");
                                        HtmlInputHidden lblApproved = (HtmlInputHidden)item.FindControl("hdnAprAmt");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Value, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Value;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Value, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Value, out DecNum) ? DecNum : 0;
                                        SchemeAmt = objOCLM.TotalCompanyCont;
                                        ApprovedAmt = objOCLM.ApprovedAmount;
                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else
                        {
                            #region Common Scheme

                            foreach (GridViewRow item in gvCommon.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        //#region Claim Locking Period Validation
                                        //HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        //ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        //if (objOCLM.IsAuto)
                                        //{
                                        //    if (Session["IsDistLogin"].ToString() != "True")
                                        //    {
                                        //        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                        //        SqlCommand Cmd = new SqlCommand();
                                        //        Cmd.Parameters.Clear();
                                        //        Cmd.CommandType = CommandType.StoredProcedure;
                                        //        Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                        //        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                        //        Cmd.Parameters.AddWithValue("@UserID", UserID);
                                        //        Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                        //        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                        //        if (dsdata != null)
                                        //        {
                                        //            if (dsdata.Tables.Count > 0)
                                        //            {
                                        //                if (dsdata.Tables[0].Rows.Count > 0)
                                        //                {
                                        //                    DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                        //                    if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                        //                    {
                                        //                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                        //                        return;
                                        //                    }
                                        //                }
                                        //            }
                                        //        }
                                        //    }
                                        //}
                                        //#endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 4;
                                        objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }

                        if (List.Count > 0)
                        {
                            var objFiltered = List.GroupBy(x => new
                            {
                                // x.SchemeID,
                                CreatedDate = x.OCLMP.CreatedDate,
                                x.OCLMP.FromDate,
                                x.OCLMP.ToDate,
                                x.SAPReasonItemCode,
                                x.IsAuto

                            }).ToList().Select(x =>
                           new
                           {
                               //x.Key.SchemeID,
                               x.Key.CreatedDate,
                               x.Key.FromDate,
                               x.Key.ToDate,
                               x.Key.SAPReasonItemCode,
                               x.Key.IsAuto,
                               TotalPurchase = (ReasonData.ReasonDesc == "I") ? SchemeAmt : x.Sum(y => y.TotalPurchase),
                               SchemeAmount = (ReasonData.ReasonDesc == "I") ? SchemeAmt : x.Sum(y => y.TotalCompanyCont),
                               ApprovedAmount = (ReasonData.ReasonDesc == "I") ? ApprovedAmt : x.Sum(y => y.ApprovedAmount)

                               //Remarks = x.Aggregate("", (ag, n) => (ag == "" ? ag : ag + ",") + n.DeductionRemarks)
                           }).ToList();


                            // Check Claim Level Hierarchy
                            Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                            SqlCommand Cmd2 = new SqlCommand();
                            Cmd2.Parameters.Clear();
                            Cmd2.CommandType = CommandType.StoredProcedure;
                            Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchyHardCode";
                            Cmd2.Parameters.AddWithValue("@ParentID", CustomerID);
                            Cmd2.Parameters.AddWithValue("@UserID", UserID);
                            Cmd2.Parameters.AddWithValue("@ClaimDate", Fromdate);
                            DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
                            OCLMP ObjOCLMP = ctx.OCLMPs.FirstOrDefault(x => x.ParentID == CustomerID && x.SchemeType == ReasonData.ReasonDesc && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true);
                            if (dsdata1.Tables.Count > 0)
                            {

                                if (dsdata1.Tables[0].Rows.Count > 0)
                                {
                                    if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE")
                                    {

                                        if (ObjOCLMP != null)
                                        {
                                            ObjOCLMP.HierarchyManagerId = EmpID;
                                            ObjOCLMP.ClaimLevel = ObjOCLMP.ClaimLevel + 1;
                                        }
                                    }
                                    else
                                    {
                                        ObjOCLMP.HierarchyManagerId = EmpID;
                                    }
                                }
                            }
                            else
                            {
                                ObjOCLMP.HierarchyManagerId = EmpID;
                            }
                            // End // Check Claim Level Hierarchy

                            foreach (var item in objFiltered)
                            {

                                if (!ctx.OCLMRQs.Any(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID))
                                {
                                    OCLMCLD objOCLMCLD = ctx.OCLMCLDs.FirstOrDefault(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID);
                                    OCLMRQ objOCLMRQ = new OCLMRQ();
                                    // DateTime CliamRequestDate = objOCLMCLD.ClaimDate;
                                    if (isdms)
                                    {
                                        if (objOCLMCLD == null)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim is not approved from his parent.',3);", true);
                                            return;
                                        }
                                        else
                                        {
                                            objOCLMRQ.ClaimChildID = objOCLMCLD.ClaimChildID;
                                            objOCLMRQ.ClaimChildParentID = objOCLMCLD.ParentID;
                                        }
                                    }

                                    objOCLMRQ.ClaimRequestID = ctx.GetKey("OCLMRQ", "ClaimRequestID", "", ParentID, 0).FirstOrDefault().Value;
                                    objOCLMRQ.ParentID = ParentID;
                                    objOCLMRQ.IsSAP = !isdms;
                                    objOCLMRQ.DocNo = item.FromDate.ToString("yyMMdd") + objOCLMRQ.ClaimRequestID.ToString("D7");
                                    objOCLMRQ.CustomerID = CustomerID;
                                    objOCLMRQ.ParentClaimID = ParentClaimID;
                                    objOCLMRQ.FromDate = item.FromDate;
                                    objOCLMRQ.ToDate = item.ToDate;
                                    objOCLMRQ.ClaimDate = item.CreatedDate;
                                    objOCLMRQ.SchemeAmount = item.SchemeAmount;
                                    objOCLMRQ.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    objOCLMRQ.ApprovedAmount = item.ApprovedAmount;
                                    objOCLMRQ.DeductionRemarks = txtNotes.Text;
                                    objOCLMRQ.ReasonCode = item.SAPReasonItemCode;
                                    objOCLMRQ.IsAuto = item.IsAuto;
                                    objOCLMRQ.TotalSale = TotalSale;
                                    objOCLMRQ.SchemeSale = item.TotalPurchase;
                                    objOCLMRQ.CreatedDate = DateTime.Now;
                                    objOCLMRQ.CreatedBy = UserID;
                                    objOCLMRQ.UpdatedDate = DateTime.Now;
                                    objOCLMRQ.UpdatedBy = UserID;
                                    objOCLMRQ.Status = 1;
                                    objOCLMRQ.LevelNo = objOCLMRQ.LevelNo++;
                                    objOCLMRQ.NextManagerID = EmpID;
                                    objOCLMRQ.CreatedIPAddress = IPAdd;
                                    ctx.OCLMRQs.Add(objOCLMRQ);


                                    CLMRQ1 objCLMRQ1 = new CLMRQ1();
                                    // objCLMRQ1.CLMRQ1ID = ctx.GetKey("CLMRQ1", "CLMRQ1ID", "", ParentID, 0).FirstOrDefault().Value;//CLMRQ1ID++;
                                    objCLMRQ1.ClaimChildID = objOCLMRQ.ClaimChildID;
                                    objCLMRQ1.ClaimChildParentID = objOCLMRQ.ParentID;
                                    objCLMRQ1.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                    objCLMRQ1.ParentID = ParentID;
                                    objCLMRQ1.IsSAP = !isdms;
                                    objCLMRQ1.DocNo = objOCLMRQ.DocNo;
                                    objCLMRQ1.CustomerID = CustomerID;
                                    objCLMRQ1.ParentClaimID = ParentClaimID;
                                    objCLMRQ1.FromDate = item.FromDate;
                                    objCLMRQ1.ToDate = item.ToDate;
                                    objCLMRQ1.ClaimDate = item.CreatedDate;
                                    objCLMRQ1.SchemeAmount = item.SchemeAmount;
                                    objCLMRQ1.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    objCLMRQ1.DeductionRemarks = txtNotes.Text;
                                    objCLMRQ1.ApprovedAmount = item.ApprovedAmount;

                                    objCLMRQ1.ReasonCode = item.SAPReasonItemCode;
                                    objCLMRQ1.IsAuto = item.IsAuto;
                                    objCLMRQ1.TotalSale = TotalSale;
                                    objCLMRQ1.SchemeSale = item.TotalPurchase;
                                    objCLMRQ1.CreatedDate = DateTime.Now;
                                    objCLMRQ1.CreatedBy = UserID;
                                    objCLMRQ1.UpdatedDate = DateTime.Now;
                                    objCLMRQ1.UpdatedBy = UserID;
                                    objCLMRQ1.Status = 1;
                                    objCLMRQ1.LevelNo = objOCLMRQ.LevelNo++ == 0 ? 1 : objOCLMRQ.LevelNo++;
                                    objCLMRQ1.NextManagerID = EmpID;
                                    objCLMRQ1.CreatedIPAddress = IPAdd;
                                    ctx.CLMRQ1.Add(objCLMRQ1);
                                }
                                else
                                {
                                    OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID);
                                    int ProcessLevel = 0;
                                    if (objOCLMRQ != null)
                                    {
                                        ProcessLevel = objOCLMRQ.LevelNo;
                                        objOCLMRQ.LevelNo = objOCLMRQ.LevelNo + 1;
                                        objOCLMRQ.NextManagerID = EmpID;
                                        objOCLMRQ.ApprovedAmount = item.ApprovedAmount;
                                        objOCLMRQ.DeductionRemarks = txtNotes.Text;
                                        objOCLMRQ.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    }

                                    CLMRQ1 objCLMRQ1 = new CLMRQ1();
                                    //  objCLMRQ1.CLMRQ1ID = ctx.GetKey("CLMRQ1", "CLMRQ1ID", "", ParentID, 0).FirstOrDefault().Value;//CLMRQ1ID++;
                                    objCLMRQ1.ClaimChildID = objOCLMRQ.ClaimChildID;
                                    objCLMRQ1.ClaimChildParentID = objOCLMRQ.ParentID;
                                    objCLMRQ1.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                    objCLMRQ1.ParentID = ParentID;
                                    objCLMRQ1.IsSAP = !isdms;
                                    objCLMRQ1.DocNo = objOCLMRQ.DocNo;
                                    objCLMRQ1.CustomerID = CustomerID;
                                    objCLMRQ1.ParentClaimID = ParentClaimID;
                                    objCLMRQ1.FromDate = item.FromDate;
                                    objCLMRQ1.ToDate = item.ToDate;
                                    objCLMRQ1.ClaimDate = item.CreatedDate;
                                    objCLMRQ1.SchemeAmount = item.SchemeAmount;
                                    objCLMRQ1.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    objCLMRQ1.DeductionRemarks = txtNotes.Text;
                                    objCLMRQ1.ApprovedAmount = item.ApprovedAmount;

                                    objCLMRQ1.ReasonCode = item.SAPReasonItemCode;
                                    objCLMRQ1.IsAuto = item.IsAuto;
                                    objCLMRQ1.TotalSale = TotalSale;
                                    objCLMRQ1.SchemeSale = item.TotalPurchase;
                                    objCLMRQ1.CreatedDate = DateTime.Now;
                                    objCLMRQ1.CreatedBy = UserID;
                                    objCLMRQ1.UpdatedDate = DateTime.Now;
                                    objCLMRQ1.UpdatedBy = UserID;
                                    objCLMRQ1.Status = 1;
                                    objCLMRQ1.LevelNo = (ProcessLevel + 1) == 0 ? 1 : (ProcessLevel + 1);
                                    objCLMRQ1.NextManagerID = EmpID;
                                    objCLMRQ1.CreatedIPAddress = IPAdd;
                                    ctx.CLMRQ1.Add(objCLMRQ1);
                                }
                                // Next Manager Claim  Notification IN DMS
                                string title = "Claim Approved";
                                OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == UserID).FirstOrDefault();
                                OCRD ObjDist = ctx.OCRDs.Where(x => x.CustomerID == CustomerID).FirstOrDefault();
                                Int16 ReasonId = Convert.ToInt16(ddlMode.SelectedValue);
                                string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
                                string body = "Claim Approved By  " + System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(ObjEmp.Name) + " Of " + ObjDist.CustomerCode + "-" + System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(ObjDist.CustomerName) + ". for the month of " + Fromdate.ToString("MMM") + "/" + Fromdate.ToString("yyyy") + " and Claim Type " + ClaimType + " and amount Rs. " + item.SchemeAmount.ToString("0.00") + "   " + txtNotes.Text;
                                String NBody = System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(body);
                                OGCM objOGCM = null;
                                objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == CustomerID && x.IsActive);
                                GCM1 objGCM1 = new GCM1();
                                //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                                objGCM1.ParentID = 1000010000000000;
                                 if (objOGCM != null)
                                {
                                objGCM1.DeviceID = objOGCM.DeviceID;
                                objGCM1.CreatedDate = DateTime.Now;
                                objGCM1.CreatedBy = EmpID;
                                objGCM1.Body = NBody;
                                objGCM1.Title = title;
                                objGCM1.UnRead = true;
                                objGCM1.IsDeleted = false;
                                objGCM1.SentOn = true;
                                ctx.GCM1.Add(objGCM1);
							}
                            }

                            ctx.SaveChanges();

                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                            return;
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submitted Successfully and sent to ' " + txtManager.Text + "',1);", true);
                        ClearAllInputs(true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtDate.Enabled = btnSumbit.Enabled = btnRejectClaim.Enabled = true;
        ClearAllInputs(true);
        txtManager.Enabled = false;
    }

    protected void btnRejectClaim_Click(object sender, EventArgs e)
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
                if (String.IsNullOrEmpty(txtDate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                    txtDate.Text = "";
                    txtDate.Focus();
                    return;
                }
                if (String.IsNullOrEmpty(txtNotes.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter Rejection Remarks.',3);", true);
                    txtNotes.Text = "";
                    txtNotes.Focus();
                    return;
                }
                Decimal DecNum = 0;
                Int32 IntNum = 0;
                DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
                DateTime enddate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));

                int EmpID = 0;
                int ParentClaimID = 0;
                Decimal TotalSale = 0, SchemeAmt = 0, ApprovedAmt = 0;

                Decimal SSID = Decimal.TryParse(txtSSDist.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
                Decimal DistID = Decimal.TryParse(txtCustCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;
                if (DistID == 0 && SSID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
                    return;
                }


                Decimal CustomerID = DistID > 0 ? DistID : SSID;
                if (CustomerID > 0)
                {
                    DateTime ClaimRequestDate;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {

                        int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);
                        ORSN ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);

                        //if (ReasonData.ReasonDesc == "R" && !new int[] { 3, 4 }.Contains(EmpID))
                        //{
                        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not send this claim to this user.',3);", true);
                        //    return;
                        //}

                        var cparentid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                        Boolean isdms = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == cparentid).Type == 4;
                        if (isdms && !ctx.OCLMCLDs.Any(x => x.CustomerID == CustomerID && x.ReasonCode == ReasonData.SAPReasonItemCode
                         && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim is not reject from his parent.',3);", true);
                            return;
                        }

                        List<OCLM> List = new List<OCLM>();

                        if (ReasonData.ReasonDesc == "M")
                        {
                            #region Master Scheme
                            foreach (GridViewRow item in gvMasterScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        //    objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //   objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //    objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "S")
                        {
                            #region QPS
                            foreach (GridViewRow item in gvQPSScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        // objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        // objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //   objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "D")
                        {
                            #region Machine Scheme
                            foreach (GridViewRow item in gvMachineScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        //  objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //   objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //   objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "P")
                        {
                            #region Parlour Scheme
                            foreach (GridViewRow item in gvParlourScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over   " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        //  objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //   objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //  objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "V")
                        {
                            #region VRS Discount Scheme
                            foreach (GridViewRow item in gvVRSDiscount.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        // objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //  objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //  objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "F")
                        {
                            #region FOW Scheme
                            foreach (GridViewRow item in gvFOWScheme.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        //   objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //  objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //   objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "T")
                        {
                            #region Sec Freight Scheme

                            foreach (GridViewRow item in gvSecFreight.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        // objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //  objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //    objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "R")
                        {
                            #region Rate Difference
                            foreach (GridViewRow item in gvRateDiff.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        #region Claim Locking Period Validation
                                        HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        if (objOCLM.IsAuto)
                                        {
                                            if (Session["IsDistLogin"].ToString() != "True")
                                            {
                                                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                                SqlCommand Cmd = new SqlCommand();
                                                Cmd.Parameters.Clear();
                                                Cmd.CommandType = CommandType.StoredProcedure;
                                                Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                                Cmd.Parameters.AddWithValue("@UserID", UserID);
                                                Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                                if (dsdata.Tables.Count > 0)
                                                {
                                                    if (dsdata.Tables[0].Rows.Count > 0)
                                                    {
                                                        DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                                        {
                                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        #endregion
                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        // objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //  objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //  objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else if (ReasonData.ReasonDesc == "I")
                        {
                            #region IOU Claim
                            foreach (GridViewRow item in gvIOUClaim.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        HtmlInputHidden txtRemarks = (HtmlInputHidden)item.FindControl("hdnDeductionRemarks");
                                        HtmlInputHidden txtDeduction = (HtmlInputHidden)item.FindControl("hdnIOUDeduction");

                                        HtmlInputHidden lblMonthSale = (HtmlInputHidden)item.FindControl("hdnlblMonthSale");
                                        HtmlInputHidden lblApproved = (HtmlInputHidden)item.FindControl("hdnAprAmt");

                                        // objOCLM.Deduction = Decimal.TryParse(txtDeduction.Value, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Value;
                                        //   objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Value, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //  objOCLM.Total = Decimal.TryParse(lblMonthSale.Value, out DecNum) ? DecNum : 0;
                                        SchemeAmt = objOCLM.TotalCompanyCont;
                                        ApprovedAmt = objOCLM.ApprovedAmount;
                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }
                            #endregion
                        }
                        else
                        {
                            #region Common Scheme

                            foreach (GridViewRow item in gvCommon.Rows)
                            {
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                                if (chkCheck.Checked)
                                {
                                    HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");
                                    HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");

                                    IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                                    DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                                    OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                                    if (objOCLM != null)
                                    {
                                        //#region Claim Locking Period Validation
                                        //HtmlInputHidden hdnClaimRequestDate = (HtmlInputHidden)item.FindControl("hdnClaimRequestDate");
                                        //ClaimRequestDate = Convert.ToDateTime(hdnClaimRequestDate.Value);
                                        //if (objOCLM.IsAuto)
                                        //{
                                        //    if (Session["IsDistLogin"].ToString() != "True")
                                        //    {
                                        //        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                                        //        SqlCommand Cmd = new SqlCommand();
                                        //        Cmd.Parameters.Clear();
                                        //        Cmd.CommandType = CommandType.StoredProcedure;
                                        //        Cmd.CommandText = "usp_CheckProductUserClaimLockingPeriod";
                                        //        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                                        //        Cmd.Parameters.AddWithValue("@UserID", UserID);
                                        //        Cmd.Parameters.AddWithValue("@CustomerId", CustomerID);
                                        //        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                                        //        if (dsdata != null)
                                        //        {
                                        //            if (dsdata.Tables.Count > 0)
                                        //            {
                                        //                if (dsdata.Tables[0].Rows.Count > 0)
                                        //                {
                                        //                    DateTime LockingDate = ClaimRequestDate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                        //                    if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                        //                    {
                                        //                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Process Period is Over  " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                        //                        return;
                                        //                    }
                                        //                }
                                        //            }
                                        //        }
                                        //    }
                                        //}
                                        //#endregion

                                        TextBox txtDeduction = (TextBox)item.FindControl("txtDeduction");
                                        TextBox txtRemarks = (TextBox)item.FindControl("txtRemarks");
                                        TextBox lblApproved = (TextBox)item.FindControl("lblApproved");
                                        Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                                        //objOCLM.Deduction = Decimal.TryParse(txtDeduction.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.DeductionRemarks = txtRemarks.Text;
                                        //  objOCLM.ApprovedAmount = Decimal.TryParse(lblApproved.Text, out DecNum) ? DecNum : 0;
                                        objOCLM.ProcessDate = DateTime.Now;
                                        objOCLM.Status = 5;
                                        //   objOCLM.Total = Decimal.TryParse(lblMonthSale.Text, out DecNum) ? DecNum : 0;

                                        ParentClaimID = objOCLM.ParentClaimID;
                                        TotalSale = objOCLM.Total;

                                        List.Add(objOCLM);
                                    }
                                }
                            }

                            #endregion
                        }

                        if (List.Count > 0)
                        {
                            var objFiltered = List.GroupBy(x => new
                            {
                                // x.SchemeID,
                                CreatedDate = x.OCLMP.CreatedDate,
                                x.OCLMP.FromDate,
                                x.OCLMP.ToDate,
                                x.SAPReasonItemCode,
                                x.IsAuto
                                // x.DeductionRemarks
                            }).ToList().Select(x =>
                           new
                           {
                               //x.Key.SchemeID,
                               x.Key.CreatedDate,
                               x.Key.FromDate,
                               x.Key.ToDate,
                               x.Key.SAPReasonItemCode,
                               x.Key.IsAuto,
                               TotalPurchase = (ReasonData.ReasonDesc == "I") ? SchemeAmt : x.Sum(y => y.TotalPurchase),
                               SchemeAmount = (ReasonData.ReasonDesc == "I") ? SchemeAmt : x.Sum(y => y.TotalCompanyCont),
                               ApprovedAmount = (ReasonData.ReasonDesc == "I") ? ApprovedAmt : x.Sum(y => y.ApprovedAmount)
                               // x.Key.DeductionRemarks
                               //Remarks = x.Aggregate("", (ag, n) => (ag == "" ? ag : ag + ",") + n.DeductionRemarks)
                           }).ToList();

                            //// T900015320 Claim Reject
                            //// Check Claim Level Hierarchy
                            //Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                            //SqlCommand Cmd2 = new SqlCommand();
                            //Cmd2.Parameters.Clear();
                            //Cmd2.CommandType = CommandType.StoredProcedure;
                            //Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchy";
                            //Cmd2.Parameters.AddWithValue("@ParentID", CustomerID);
                            //Cmd2.Parameters.AddWithValue("@UserID", UserID);
                            //DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
                            //if (dsdata1.Tables.Count > 0)
                            //{
                            //    if (dsdata1.Tables[0].Rows.Count > 0)
                            //    {
                            //        if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) > 0)
                            //        {
                            //            OCLMP ObjOCLMP = ctx.OCLMPs.FirstOrDefault(x => x.ParentID == CustomerID && x.SchemeType == ReasonData.ReasonDesc && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year);
                            //            if (ObjOCLMP != null)
                            //            {
                            //                Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                            //                SqlCommand Cmd3 = new SqlCommand();
                            //                Cmd3.Parameters.Clear();
                            //                Cmd3.CommandType = CommandType.StoredProcedure;
                            //                Cmd3.CommandText = "usp_GetDistributorBeatEmployee";
                            //                Cmd3.Parameters.AddWithValue("@ParentID", ParentID);
                            //                Cmd3.Parameters.AddWithValue("@CustomerID", CustomerID);
                            //                DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                            //                if (dsdata2.Tables.Count > 0)
                            //                {
                            //                    if (dsdata2.Tables[0].Rows.Count > 0)
                            //                    {
                            //                        EmpID = Int32.TryParse(dsdata2.Tables[0].Rows[0]["PrefSalesPersonID"].ToString(), out EmpID) ? EmpID : 0;
                            //                        ObjOCLMP.HierarchyManagerId = EmpID;
                            //                        ObjOCLMP.ClaimLevel = 1;
                            //                    }
                            //                }
                            //            }
                            //        }
                            //        // Claim Send to Direct Distributor 
                            //        else if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE")
                            //        {
                            OCLMP ObjOCLMP = ctx.OCLMPs.FirstOrDefault(x => x.ParentID == CustomerID && x.SchemeType == ReasonData.ReasonDesc && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true);
                            if (ObjOCLMP != null)
                            {
                                ObjOCLMP.HierarchyManagerId = null;
                                ObjOCLMP.ClaimLevel = 1;
                                ObjOCLMP.IsActive = false;
                            }
                            //        }
                            //    }
                            //}
                            // End // Check Claim Level Hierarchy

                            foreach (var item in objFiltered)
                            {
                                // Distributor Claim Reject Notification IN DMS
                                string title = "Claim Reject";
                                OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == UserID).FirstOrDefault();
                                OCRD ObjDist = ctx.OCRDs.Where(x => x.CustomerID == CustomerID).FirstOrDefault();
                                Int16 ReasonId = Convert.ToInt16(ddlMode.SelectedValue);
                                string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
                                string body = "Claim Rejected By " + System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(ObjEmp.Name) + " Of " + ObjDist.CustomerCode + "-" + System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(ObjDist.CustomerName) + ". for the month of " + Fromdate.ToString("MMM") + "/" + Fromdate.ToString("yyyy") + " and Claim Type " + ClaimType + " and amount Rs. " + item.SchemeAmount.ToString("0.00") + " Due to " + txtNotes.Text;
                                String NBody = System.Globalization.CultureInfo.CurrentUICulture.TextInfo.ToTitleCase(body);
                                OGCM objOGCM = null;
                                objOGCM = ctx.OGCMs.FirstOrDefault(x => x.ParentID == CustomerID && x.IsActive);
                                GCM1 objGCM1 = new GCM1();
                                //objGCM1.GCM1ID = ctx.GetKey("GCM1", "GCM1ID", "", ParentID, 0).FirstOrDefault().Value;
                                if (objOGCM != null)
                                {
                                objGCM1.ParentID = CustomerID;
                                objGCM1.DeviceID = objOGCM.DeviceID;
                                objGCM1.CreatedDate = DateTime.Now;
                                objGCM1.CreatedBy = UserID;
                                objGCM1.Body = NBody;
                                objGCM1.Title = title;
                                objGCM1.UnRead = true;
                                objGCM1.IsDeleted = false;
                                objGCM1.SentOn = true;
                                ctx.GCM1.Add(objGCM1);
                          }
                                // End DMS Notification
                                //// 15-Dec-22  // Check Claim Level Hierarchy and Send Notification to Sales staff
                                //Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                                //SqlCommand Cmd2 = new SqlCommand();
                                //Cmd2.Parameters.Clear();
                                //Cmd2.CommandType = CommandType.StoredProcedure;
                                //Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchy";
                                //Cmd2.Parameters.AddWithValue("@ParentID", CustomerID);
                                //Cmd2.Parameters.AddWithValue("@UserID", UserID);
                                //DataSet dsdata1 = objClass12.CommonFunctionForSelect(Cmd2);
                                //if (dsdata1.Tables.Count > 0)
                                //{
                                //    if (dsdata1.Tables[0].Rows.Count > 0)
                                //    {
                                //        if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) > 0)
                                //        {

                                //            // Check Claim Level Hierarchy and Send Notification to Sales staff
                                //            Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                                //            SqlCommand Cmd3 = new SqlCommand();
                                //            Cmd3.Parameters.Clear();
                                //            Cmd3.CommandType = CommandType.StoredProcedure;
                                //            Cmd3.CommandText = "usp_GetMangerList";
                                //            Cmd3.Parameters.AddWithValue("@ParentId", 1000010000000000);
                                //            Cmd3.Parameters.AddWithValue("@UserID", UserID);
                                //            DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                                //            int NextMgrId = UserID;
                                //            Boolean NotiSend = true;
                                //            Boolean IsExclude = false;
                                //            if (dsdata2.Tables[0].Rows.Count > 0)
                                //            {
                                //            step1:
                                //                DataTable dt = dsdata2.Tables[0].Select("ManagerID =" + NextMgrId).CopyToDataTable();
                                //                if (dt.Rows.Count > 0)
                                //                {
                                //                    NotiSend = true;
                                //                    IsExclude = false;
                                //                    for (int i = 0; i < dt.Rows.Count; i++)
                                //                    {
                                //                        NextMgrId = Convert.ToInt32(dt.Rows[0]["EmpId"].ToString());
                                //                        objOGCM = ctx.OGCMs.FirstOrDefault(x => x.EmpID == NextMgrId && x.ParentID == ParentID && x.IsActive);

                                //                        if (objOGCM != null && NotiSend && !IsExclude)
                                //                        {
                                //                            WebRequest tRequest = WebRequest.Create("https://fcm.googleapis.com/fcm/send");
                                //                            tRequest.Method = "post";
                                //                            tRequest.ContentType = "application/json";
                                //                            var data = new
                                //                            {
                                //                                to = objOGCM.Token,
                                //                                notification = new
                                //                                {
                                //                                    body = NBody,
                                //                                    title = title,
                                //                                    sound = "Enabled"
                                //                                }
                                //                            };
                                //                            JavaScriptSerializer serializer = new JavaScriptSerializer();
                                //                            string json = serializer.Serialize(data);
                                //                            Byte[] byteArray = Encoding.UTF8.GetBytes(json);
                                //                            tRequest.Headers.Add(string.Format("Authorization: key={0}", "AAAAW1mlymM:APA91bGzosQ6zJ4OXUI5XzMQDW182fB495uVg-m_uKkfRFudegUeef0TOmH6gK_XAnk3K_x6LUJVw0aU85tvmXrDQZ8qKC_T-dfwb6GH-XpjsKPv9-x081LDEO_n_G7Mw20db9Xz3HvT"));
                                //                            tRequest.Headers.Add(string.Format("Sender: id={0}", "392346061411"));
                                //                            tRequest.ContentLength = byteArray.Length;
                                //                            using (Stream dataStream = tRequest.GetRequestStream())
                                //                            {
                                //                                dataStream.Write(byteArray, 0, byteArray.Length);
                                //                                using (WebResponse tResponse = tRequest.GetResponse())
                                //                                {
                                //                                    using (Stream dataStreamResponse = tResponse.GetResponseStream())
                                //                                    {
                                //                                        using (StreamReader tReader = new StreamReader(dataStreamResponse))
                                //                                        {
                                //                                            var Result = tReader.ReadToEnd();
                                //                                            if (!string.IsNullOrEmpty(Result))
                                //                                            {
                                //                                                objGCM1 = new GCM1();
                                //                                                objGCM1.ParentID = ParentID;
                                //                                                objGCM1.DeviceID = objOGCM.DeviceID;
                                //                                                objGCM1.CreatedDate = DateTime.Now;
                                //                                                objGCM1.CreatedBy = UserID;
                                //                                                objGCM1.Body =NBody;
                                //                                                objGCM1.Title = title;
                                //                                                objGCM1.UnRead = true;
                                //                                                objGCM1.IsDeleted = false;
                                //                                                if (Result.IndexOf("\"success\":", StringComparison.CurrentCultureIgnoreCase) > 0)
                                //                                                    objGCM1.SentOn = true;
                                //                                                else
                                //                                                    objGCM1.SentOn = false;
                                //                                                ctx.GCM1.Add(objGCM1);
                                //                                                ctx.SaveChanges();
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                }
                                //                            }
                                //                        }
                                //                        goto step1;
                                //                    }
                                //                }
                                //            }

                                //        }
                                //    }
                                //} //// 15-Dec-22 Sales Staff pulse notification sent
                                if (!ctx.OCLMRQs.Any(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID))
                                {
                                    OCLMCLD objOCLMCLD = ctx.OCLMCLDs.FirstOrDefault(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID);
                                    OCLMRQ objOCLMRQ = new OCLMRQ();
                                    // DateTime CliamRequestDate = objOCLMCLD.ClaimDate;
                                    if (isdms)
                                    {
                                        if (objOCLMCLD == null)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim is not approved from his parent.',3);", true);
                                            return;
                                        }
                                        else
                                        {
                                            objOCLMRQ.ClaimChildID = objOCLMCLD.ClaimChildID;
                                            objOCLMRQ.ClaimChildParentID = objOCLMCLD.ParentID;
                                        }
                                    }

                                    objOCLMRQ.ClaimRequestID = ctx.GetKey("OCLMRQ", "ClaimRequestID", "", ParentID, 0).FirstOrDefault().Value;
                                    objOCLMRQ.ParentID = ParentID;
                                    objOCLMRQ.IsSAP = !isdms;
                                    objOCLMRQ.DocNo = item.FromDate.ToString("yyMMdd") + objOCLMRQ.ClaimRequestID.ToString("D7");
                                    objOCLMRQ.CustomerID = CustomerID;
                                    objOCLMRQ.ParentClaimID = ParentClaimID;
                                    objOCLMRQ.FromDate = item.FromDate;
                                    objOCLMRQ.ToDate = item.ToDate;
                                    objOCLMRQ.ClaimDate = item.CreatedDate;
                                    objOCLMRQ.SchemeAmount = item.SchemeAmount;
                                    objOCLMRQ.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    objOCLMRQ.ApprovedAmount = item.ApprovedAmount;
                                    objOCLMRQ.DeductionRemarks = txtNotes.Text;
                                    objOCLMRQ.ReasonCode = item.SAPReasonItemCode;
                                    objOCLMRQ.IsAuto = item.IsAuto;
                                    objOCLMRQ.TotalSale = TotalSale;
                                    objOCLMRQ.SchemeSale = item.TotalPurchase;
                                    objOCLMRQ.CreatedDate = DateTime.Now;
                                    objOCLMRQ.CreatedBy = UserID;
                                    objOCLMRQ.UpdatedDate = DateTime.Now;
                                    objOCLMRQ.UpdatedBy = UserID;
                                    objOCLMRQ.Status = 5;
                                    objOCLMRQ.LevelNo = 1;
                                    objOCLMRQ.NextManagerID = 0;
                                    objOCLMRQ.CreatedIPAddress = IPAdd;
                                    ctx.OCLMRQs.Add(objOCLMRQ);
                                }
                                else
                                {
                                    OCLMRQ objOCLMRQ = ctx.OCLMRQs.FirstOrDefault(x => x.ParentClaimID == ParentClaimID && x.CustomerID == CustomerID);
                                    // Insert Claim Approve Histroy T900011560
                                    int ProcessLevel = 0;
                                    if (objOCLMRQ != null)
                                    {
                                        ProcessLevel = objOCLMRQ.LevelNo;
                                        objOCLMRQ.LevelNo = objOCLMRQ.LevelNo + 1;
                                        objOCLMRQ.NextManagerID = EmpID;
                                        objOCLMRQ.ApprovedAmount = item.ApprovedAmount;
                                        objOCLMRQ.UpdatedBy = UserID;
                                    }
                                    CLMRQ1 objCLMRQ1 = new CLMRQ1();
                                    //  objCLMRQ1.CLMRQ1ID = ctx.GetKey("CLMRQ1", "CLMRQ1ID", "", ParentID, 0).FirstOrDefault().Value;
                                    objCLMRQ1.ClaimChildID = objOCLMRQ.ClaimChildID;
                                    objCLMRQ1.ClaimChildParentID = objOCLMRQ.ParentID;
                                    objCLMRQ1.ClaimRequestID = objOCLMRQ.ClaimRequestID;
                                    objCLMRQ1.ParentID = ParentID;
                                    objCLMRQ1.IsSAP = !isdms;
                                    objCLMRQ1.DocNo = objOCLMRQ.DocNo;
                                    objCLMRQ1.CustomerID = CustomerID;
                                    objCLMRQ1.ParentClaimID = ParentClaimID;
                                    objCLMRQ1.FromDate = item.FromDate;
                                    objCLMRQ1.ToDate = item.ToDate;
                                    objCLMRQ1.ClaimDate = item.CreatedDate;
                                    objCLMRQ1.SchemeAmount = item.SchemeAmount;
                                    objCLMRQ1.Deduction = item.SchemeAmount - item.ApprovedAmount;
                                    objCLMRQ1.DeductionRemarks = txtNotes.Text;
                                    objCLMRQ1.ApprovedAmount = item.ApprovedAmount;

                                    objCLMRQ1.ReasonCode = item.SAPReasonItemCode;
                                    objCLMRQ1.IsAuto = item.IsAuto;
                                    objCLMRQ1.TotalSale = TotalSale;
                                    objCLMRQ1.SchemeSale = item.TotalPurchase;
                                    objCLMRQ1.CreatedDate = DateTime.Now;
                                    objCLMRQ1.CreatedBy = UserID;
                                    objCLMRQ1.UpdatedDate = DateTime.Now;
                                    objCLMRQ1.UpdatedBy = UserID;
                                    objCLMRQ1.Status = 5;
                                    objCLMRQ1.LevelNo = (ProcessLevel + 1) == 0 ? 1 : (ProcessLevel + 1);
                                    objCLMRQ1.NextManagerID = 0;
                                    objCLMRQ1.CreatedIPAddress = IPAdd;
                                    ctx.CLMRQ1.Add(objCLMRQ1);
                                }
                                //
                            }

                            ctx.SaveChanges();
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                            return;
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submitted Successfully',1);", true);
                        ClearAllInputs(true);
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

    #region Gridview Events

    protected void gvMasterScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMasterScheme.Rows.Count > 0)
        {
            gvMasterScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMasterScheme.FooterRow.TableSection = TableRowSection.TableFooter;
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

    protected void gvMachineScheme_PreRender(object sender, EventArgs e)
    {
        if (gvMachineScheme.Rows.Count > 0)
        {
            gvMachineScheme.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMachineScheme.FooterRow.TableSection = TableRowSection.TableFooter;
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

    protected void gvCommon_PreRender(object sender, EventArgs e)
    {
        if (gvCommon.Rows.Count > 0)
        {
            gvCommon.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCommon.FooterRow.TableSection = TableRowSection.TableFooter;
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

    protected void gvIOUClaim_PreRender(object sender, EventArgs e)
    {
        if (gvIOUClaim.Rows.Count > 0)
        {
            gvIOUClaim.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvIOUClaim.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }


    protected void gvVRSDiscount_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvVRSDiscount.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvFOWScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvFOWScheme.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvMasterScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvMasterScheme.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }

    }
    protected void gvQPSScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvQPSScheme.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvMachineScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvMachineScheme.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }

    protected void gvParlourScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvParlourScheme.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvSecFreight_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvSecFreight.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvRateDiff_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvRateDiff.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvIOUClaim_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvIOUClaim.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }
    }
    protected void gvCommon_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Image")
        {
            //Determine the RowIndex of the Row whose Button was clicked.
            int rowIndex = Convert.ToInt32(e.CommandArgument);

            //Reference the GridView Row.
            GridViewRow row = gvCommon.Rows[rowIndex];

            //Fetch value of Name.
            string ParentId = (row.FindControl("hdnCustomerId") as HiddenField).Value;
            string ClaimId = (row.FindControl("hdnParentClaimId") as HiddenField).Value;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "OpenItemImage('" + ClaimId + "','" + ParentId + "');", true);
        }

    }


    protected void gvMachineScheme_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }

    protected void gvMasterScheme_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvQPSScheme_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvParlourScheme_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvVRSDiscount_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvFOWScheme_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvSecFreight_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvRateDiff_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvIOUClaim_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    protected void gvCommon_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button lblimg = e.Row.FindControl("lblimg") as Button;
            Label lblIsAuto = e.Row.FindControl("lblIsAuto") as Label;
            if (!IsHierarchy && lblIsAuto.Text == "True")
            {
                lblimg.Enabled = false;
            }
            else if (!IsHierarchy && lblIsAuto.Text == "False")
			{
                lblimg.Enabled = false;
            }
            else if (lblIsAuto.Text == "False")
            {
                lblimg.Enabled = false;
            }
            else
            {
                lblimg.Enabled = true;
            }
        }
    }
    #endregion



    protected void ddlMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);
        if (ReasonID.ToString() == "57")
        {

            // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select this claim type because it is direct sync to SAP Z-Table.',3);", true);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('તમે આ ક્લેમ ટાઈપ સિલેક્ટ નાં કરી શકો કારણ કે તે ડાયરેક્ટ SAP ના Z - Table માં Sync થાય છે.',3);", true);
            return;
        }
    }
}