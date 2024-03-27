using ClaimDMS;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class Sales_ClaimDirect : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    protected bool IsHierarchy;
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

        gvRecord.DataSource = null;
        gvRecord.DataBind();

        gvRecord.Visible = gvCommon.Visible = false;
        txtDate.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        flpFileUpload.Visible = false;
        lblClaimReport.Visible = false;
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
            DateTime cdate = Convert.ToDateTime(txtDate.Text);
            gvRecord.Visible = gvCommon.Visible = false;
            var qday = Common.GetQDays(cdate, 3, Convert.ToInt32(ddlMode.SelectedValue));

            DateTime Fromdate = new DateTime(cdate.Year, cdate.Month, qday.first);
            DateTime Todate = new DateTime(cdate.Year, cdate.Month, qday.last);
            if (Session["IsDistLogin"].ToString() != "True")
            {
                // DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["UpdatedDate"].ToString());
                Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                SqlCommand Cmd = new SqlCommand();
                Cmd.Parameters.Clear();
                Cmd.CommandType = CommandType.StoredProcedure;
                Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                Cmd.Parameters.AddWithValue("@UserID", UserID);
                //Cmd.Parameters.AddWithValue("@CustomerId", 0);
                DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                if (dsdata.Tables.Count > 0)
                {
                    if (dsdata.Tables[0].Rows.Count > 0)
                    {
                        DateTime LockingDate = Todate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                        if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                        {
                            btnSAPSync.Enabled = false;

                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                            //  return;
                        }
                        else
                        {
                            btnSAPSync.Enabled = true;
                        }
                    }
                }
                else
                {
                    btnSAPSync.Enabled = true;
                }
            }
            //Please do not migrate below code to PRD forever as it is commented for testing in QA.

            //if (Todate.Date >= DateTime.Now.Date)
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not process claim before & current date',3);", true);
            //    return;
            //}
            if (ddlDisplay.SelectedValue == "1")
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == "A"
                        && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.FromDate.Day == Fromdate.Day))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
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
                    if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "TRUE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) > 0)
                    {
                        IsHierarchy = true;
                    }
                    else if (dsdata1.Tables[0].Rows[0]["IsHeirarchy"].ToString().ToUpper() == "FALSE" && Convert.ToInt16(dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString().ToUpper()) == 0)
                    {
                        IsHierarchy = true;
                    }
                    else
                    {
                        IsHierarchy = false;
                    }
                }
               
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
            }
                // End Claim Level
                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();

                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetDirectClaimDetail";
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
                Cm.Parameters.AddWithValue("@FromDate", Fromdate.ToString("yyyyMMdd"));
                Cm.Parameters.AddWithValue("@ToDate", Todate.ToString("yyyyMMdd"));
                Cm.Parameters.AddWithValue("@Display", ddlDisplay.SelectedValue);

                if (ddlDisplay.SelectedValue == "1")
                {
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        gvCommon.DataSource = ds.Tables[0];
                    }
                    gvCommon.DataBind();
                    gvCommon.Visible = true;
                }
                else
                {
                    DataSet ds = objClass.CommonFunctionForSelect(Cm);
                    if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    {
                        gvRecord.DataSource = ds.Tables[0];

                    }
                    gvRecord.DataBind();
                    gvRecord.Visible = true;
                }
                if (ddlDisplay.SelectedValue == "3")
                {
                    btnSAPSync.Visible = false;
                }
                else
                {
                    btnSAPSync.Visible = true;
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
                if (ddlDisplay.SelectedValue == "1")
                {
                    if (gvCommon.Rows.Count == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                        return;
                    }
                    DateTime cdate = Convert.ToDateTime(txtDate.Text);

                    var qday = Common.GetQDays(cdate, 3, Convert.ToInt32(ddlMode.SelectedValue));

                    DateTime Fromdate = new DateTime(cdate.Year, cdate.Month, qday.first);
                    DateTime Todate = new DateTime(cdate.Year, cdate.Month, qday.last);
                    if (Session["IsDistLogin"].ToString() != "True")
                    {
                        // DateTime ClaimRequestDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["UpdatedDate"].ToString());
                        Oledb_ConnectionClass objClass1 = new Oledb_ConnectionClass();
                        SqlCommand Cmd = new SqlCommand();
                        Cmd.Parameters.Clear();
                        Cmd.CommandType = CommandType.StoredProcedure;
                        Cmd.CommandText = "usp_CheckDistributorClaimLockingPeriod";
                        Cmd.Parameters.AddWithValue("@ParentID", ParentID);
                        Cmd.Parameters.AddWithValue("@UserID", UserID);
                        //Cmd.Parameters.AddWithValue("@CustomerId", 0);
                        DataSet dsdata = objClass1.CommonFunctionForSelect(Cmd);
                        if (dsdata.Tables.Count > 0)
                        {
                            if (dsdata.Tables[0].Rows.Count > 0)
                            {
                                DateTime LockingDate = Todate.AddDays(Convert.ToInt16(dsdata.Tables[0].Rows[0]["Days"].ToString()));
                                if ((LockingDate - System.DateTime.Today).TotalDays <= 0)
                                {
                                    btnSAPSync.Enabled = false;

                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('claim period is over. " + LockingDate.ToString("dd/MMM/yyyy") + "',3);", true);
                                    //  return;
                                }
                                else
                                {
                                    btnSAPSync.Enabled = true;
                                }
                            }
                        }
                        else
                        {
                            btnSAPSync.Enabled = true;
                        }
                    }
                    //Please do not migrate below code to PRD forever as it is commented for testing in QA.

                    //if (Todate.Date >= DateTime.Now.Date)
                    //{
                    //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you can not process claim before & current date',3);", true);
                    //    return;
                    //}

                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        if (ctx.OCLMPs.Any(x => x.ParentID == ParentID && x.SchemeType == "A"
                            && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.FromDate.Day == Fromdate.Day))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
                            return;
                        }
                        Decimal ParentCustID = Convert.ToDecimal(Session["OutletPID"]);


                        // Check Unit Mapping entry found or not  T90001150  10-Oct-22
                        if (!ctx.OCUMs.Any(x => x.CustID == ParentID))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('your unit entry not found please contact mktg department',3);", true);
                            return;
                        }

                        //
                      

                        int ClaimID = ctx.GetKey("OCLM", "ClaimID", "", ParentID, 0).FirstOrDefault().Value;
                        int CLM1ID = ctx.GetKey("CLM1", "CLM1ID", "", ParentID, 0).FirstOrDefault().Value;
                        int CLM2ID = ctx.GetKey("CLM2", "CLM2ID", "", ParentID, 0).FirstOrDefault().Value;

                        OCLMP objOCLMP = new OCLMP();
                        objOCLMP.ParentClaimID = ctx.GetKey("OCLMP", "ParentClaimID", "", ParentID, 0).FirstOrDefault().Value;
                        objOCLMP.ParentID = ParentID;
                        objOCLMP.SchemeType = "A";
                        objOCLMP.CreatedDate = DateTime.Now;
                        objOCLMP.FromDate = Fromdate;
                        objOCLMP.IsSAP = true;
                        objOCLMP.ToDate = Todate;
                        objOCLMP.CreatedBy = UserID;
                        objOCLMP.CreatedIPAddress = IPAdd;
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
                                    var ReasonId = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                                    string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
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
                                    Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId);
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
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Entry Not Found in Employee wise Reason code master. " + Region + " - " + ClaimType + "',3);", true);
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
                                    var ReasonId = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                                    string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
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
                                    Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId);
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
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Entry Not Found in Employee wise Reason code master. " + Region + " - " + ClaimType + "',3);", true);
                                        return;
                                    }
                                }
                            }
                        }
                        HttpFileCollection uploadedFiles = Request.Files;
                        string filepath = Server.MapPath("\\Document\\ClaimDocument");
                        if (IsHierarchy)
                        {
                            //Check Validation File Upload Images for Claim Submit // T900011560
                            if (!flpFileUpload.HasFile)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you have to upload Claim report pages',3);", true);
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

                        #region Direct Scheme
                        List<CLM1> MasterList = new List<CLM1>();

                        foreach (GridViewRow item in gvCommon.Rows)
                        {

                            HtmlInputHidden hdnSaleID = (HtmlInputHidden)item.FindControl("hdnSaleID");
                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSchemeID = (HtmlInputHidden)item.FindControl("hdnSchemeID");
                            HtmlInputHidden hdnCompanyContPer = (HtmlInputHidden)item.FindControl("hdnCompanyContPer");

                            Label lblDocType = (Label)item.FindControl("lblDocType");
                            Label lblSalesAmount = (Label)item.FindControl("lblSalesAmount");
                            Label lblSchemeAmount = (Label)item.FindControl("lblSchemeAmount");
                            Label lblMonthSale = (Label)item.FindControl("lblMonthSale");

                            CLM1 objCLM1 = new CLM1();
                            objCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DocType = lblDocType.Text;
                            objCLM1.SchemeType = "A";
                            objCLM1.SAPReasonItemCode = (ddlMode.SelectedValue == "1" ? "S01" : (ddlMode.SelectedValue == "2" ? "S02" : "S03"));
                            objCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objCLM1.DistContPer = 0;
                            objCLM1.CompanyCont = objCLM1.SchemeAmount;
                            objCLM1.DistCont = 0;
                            objCLM1.DistContTax = 0;
                            objCLM1.TotalCompanyCont = objCLM1.SchemeAmount;
                            MasterList.Add(objCLM1);

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

                        foreach (var item in MasterClaims)
                        {
                            OCLM objOCLM = new OCLM();
                            objOCLM.ClaimID = ClaimID++;
                            objOCLM.ParentID = ParentID;
                            objOCLM.Status = 4;
                            objOCLM.CustomerID = item.CustomerID;
                            objOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objOCLM.TotalQty = 0;
                            objOCLM.SchemeID = item.SchemeID;
                            objOCLM.SchemeType = "A";
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

                        // File Upload
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
                            //End File storage
                            // ENd File Upload
                        }
                        if (objOCLMP.OCLMs.Count > 0)
                        {
                            ctx.SaveChanges();

                            Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);
                            int ParentClaimID = objOCLMP.ParentClaimID;
                            Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); ClaimDirectScheme(ParentClaimID, ParentID, UserID); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }

                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Submittd Successfully',1);", true);
                        ClearAllInputs();
                    }
                }
                else
                {
                    if (gvRecord.Rows.Count == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Record Found',3);", true);
                        return;
                    }
                    int ParentClaimID = 0;
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        foreach (GridViewRow item in gvRecord.Rows)
                        {
                            HtmlInputHidden hdnParentClaimID = (HtmlInputHidden)item.FindControl("hdnParentClaimID");
                            HtmlInputHidden hdnParentID = (HtmlInputHidden)item.FindControl("hdnParentID");
                            HtmlInputHidden hdnClaimID = (HtmlInputHidden)item.FindControl("hdnClaimID");

                            IntNum = Int32.TryParse(hdnClaimID.Value, out IntNum) ? IntNum : 0;
                            DecNum = Decimal.TryParse(hdnParentID.Value, out DecNum) ? DecNum : 0;

                            OCLM objOCLM = ctx.OCLMs.FirstOrDefault(x => x.ClaimID == IntNum && x.ParentID == DecNum);
                            if (objOCLM != null)
                            {
                                objOCLM.ProcessDate = DateTime.Now;
                                objOCLM.Status = 4;

                                ParentClaimID = objOCLM.ParentClaimID;
                            }
                        }

                        if (ParentClaimID > 0)
                        {
                            ctx.SaveChanges();

                            Int32 IndentToSAP = Convert.ToInt32(ConfigurationManager.AppSettings["IndentToSAP"]);

                            Thread t = new Thread(() => { Thread.Sleep(IndentToSAP); ClaimDirectScheme(ParentClaimID, ParentID, UserID); });
                            t.Name = Guid.NewGuid().ToString();
                            t.Start();
                        }
                    }
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

    protected void gvRecord_PreRender(object sender, EventArgs e)
    {
        if (gvRecord.Rows.Count > 0)
        {
            gvRecord.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvRecord.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Claim Thread

    public void ClaimDirectScheme(Int32 ParentClaimID, Decimal ParentID, Int32 UserID)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                List<OCLM> List = ctx.OCLMs.Where(x => x.ParentClaimID == ParentClaimID && x.ParentID == ParentID).ToList();

                var Filterdata = List.GroupBy(x => new
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
                                     TotalPurchase = x.Sum(y => y.TotalPurchase),
                                     SchemeAmount = x.Sum(y => y.TotalCompanyCont),
                                     ApprovedAmount = x.Sum(y => y.ApprovedAmount)
                                     //Remarks = x.Aggregate("", (ag, n) => (ag == "" ? ag : ag + ",") + n.DeductionRemarks)
                                 }).ToList();

                DT_Claimdms_RequestITEM[] R1 = new DT_Claimdms_RequestITEM[Filterdata.Count];
                int i = 0;
                string UserCode = ctx.OEMPs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == UserID).UserName;
                foreach (var item in Filterdata)
                {
                    R1[i] = new DT_Claimdms_RequestITEM();

                    R1[i].MANDT = "";
                    R1[i].KUNNR = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == ParentID).CustomerCode;
                    R1[i].BUKRS = "2000";
                    R1[i].AUGRU = item.SAPReasonItemCode;
                    R1[i].SCH_ID = ParentClaimID.ToString();
                    R1[i].SCH_STDT = item.FromDate.ToString("yyyyMMdd");
                    R1[i].SCH_EDDT = item.ToDate.ToString("yyyyMMdd");
                    R1[i].CLMDT = item.CreatedDate.ToString("yyyyMMdd");
                    R1[i].CLM_APRVDT = DateTime.Now.ToString("yyyyMMdd");
                    R1[i].CLM_YRMON = item.FromDate.ToString("yyyyMM");
                    R1[i].DIS_CLMAMT = item.SchemeAmount.ToString("0.00");
                    R1[i].MKT_APRVAMT = item.ApprovedAmount.ToString("0.00");
                    R1[i].MKT_REMDED = "";
                    R1[i].ERNAM = UserCode;
                    R1[i].ERDAT = DateTime.Now.ToString("yyyyMMdd");
                    R1[i].ERZET = DateTime.Now.ToString("hhmmss");
                    R1[i].AUTO_MAN = item.IsAuto ? "A" : "M";
                    R1[i].TOTSAL_MON = "0";
                    R1[i].SCHSAL_MON = item.TotalPurchase.ToString("0.00");
                    R1[i].REFNO = "";
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
                        int parentclaimid = Convert.ToInt32(item.SCH_ID); //ParentClaimID as SCH_ID
                        //Same Distributor in one process: KUNNR
                        //Same Company Code :BUKRS
                        //Same Reason Code : AUGRU
                        //Same Claim fromDate :SCH_STDT
                        List.Where(x => x.ParentClaimID == parentclaimid && x.ParentID == ParentID).ToList().ForEach(x => { x.Status = (item.STATUS == "S" ? 3 : 2); x.SAPErrMsg = item.MESSAGE; });
                    }
                }
                catch (Exception ex)
                {
                    List.Where(x => x.ParentID == ParentID).ToList().ForEach(x => { x.Status = 2; x.SAPErrMsg = Common.GetString(ex); });
                }

                ctx.SaveChanges();
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

}