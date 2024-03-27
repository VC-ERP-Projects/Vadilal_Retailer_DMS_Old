using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Sales_ManualClaim : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    List<GetEmpHierarchyTree_Result> Data;
    protected bool IsHierarchy;
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
        ddlMode.SelectedIndex = 0;
        txtEntryDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtCustCode.Text = txtRegion.Text = txtPlant.Text = txtTotalSale.Text = txtDate.Text = txtMKTAmnt.Text = txtMKTRemarks.Text = txtDisMonthSale.Text = txtClaimAmnt.Text = txtSAPRefno.Text = "";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                ddlMode.DataTextField = "ReasonName";
                ddlMode.DataValueField = "ReasonID";
                ddlMode.DataSource = ctx.ORSNs.Where(x => x.Type == "S").Select(x => new { ReasonName = x.ReasonName + " # " + (x.Active ? "ACTIVE" : "INACTIVE"), x.ReasonID }).OrderBy(x => x.ReasonName).ToList();
                ddlMode.DataBind();
            }
        }
    }

    #endregion

    #region ButtonClick

    protected void btngenerate_CLick(object sender, EventArgs e)
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
            Decimal SSID = Decimal.TryParse(txtSSDistCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            if (DistID == 0 && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select Proper Distributor or Super Stockiest',3);", true);
                return;
            }
            Decimal CustomerID = DistID > 0 ? DistID : SSID;
            
            DateTime ClaimFromdate = Convert.ToDateTime(txtDate.Text);
            DateTime ClaimTodate = new DateTime(ClaimFromdate.Year, ClaimFromdate.Month, DateTime.DaysInMonth(ClaimFromdate.Year, ClaimFromdate.Month));

            Decimal SchemeAmount = Decimal.TryParse(txtClaimAmnt.Text, out SchemeAmount) ? SchemeAmount : 0;
            Decimal ApproveAmount = Decimal.TryParse(txtMKTAmnt.Text, out ApproveAmount) ? ApproveAmount : 0;
            Decimal SchemeSale = Decimal.TryParse(txtDisMonthSale.Text, out SchemeSale) ? SchemeSale : 0;

            if (SchemeAmount == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Amount must be greater than ZERO',3);", true);
                return;
            }
            if (SchemeSale < SchemeAmount)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not enter Claim Amount more than Scheme Sale Amount.',3);", true);
                return;
            }
            if (SchemeAmount < ApproveAmount)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not enter Apporve Amount more than Claim Amount.',3);", true);
                return;
            }

            Decimal Deduction = SchemeAmount - ApproveAmount;
            if (Deduction > 0)
            {
                if (String.IsNullOrEmpty(txtMKTRemarks.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter Remarks !',3);", true);
                    return;
                }
            }
            Decimal DecNum = 0;

            using (DDMSEntities ctx = new DDMSEntities())
            {

                var DistUnitId = ctx.OCUMs.FirstOrDefault(x => x.CustID == CustomerID && x.Active == true).Unit;
                if (!ctx.OCUMs.Any(x => x.CustID == UserID && x.OptionId == 1 && x.Unit == DistUnitId))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are not authorize for this unit claim.',3);", true);
                    return;
                }

                string IPAdd = hdnIPAdd.Value;
                if (IPAdd == "undefined")
                    IPAdd = "";
                if (IPAdd.Length > 15)
                    IPAdd = IPAdd = IPAdd.Substring(0, 15);
                int ReasonID = Convert.ToInt32(ddlMode.SelectedValue);

                var ReasonData = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonID);

                if (ctx.OCLMPs.Any(x => x.SchemeType == ReasonData.ReasonDesc && EntityFunctions.TruncateTime(x.FromDate) == EntityFunctions.TruncateTime(ClaimFromdate)
                    && EntityFunctions.TruncateTime(x.ToDate) == EntityFunctions.TruncateTime(ClaimTodate) && x.ParentID == CustomerID && (!x.OCLMs.Any(z => z.Status == 6))))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Claim is already exists, you can not process same claim again.',3);", true);
                    return;
                }
                if ((ReasonData.ReasonDesc == "M" || ReasonData.ReasonDesc == "S") && txtSAPRefno.Text == "")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('SAP REF NO is mandatory in this claim.',3);", true);
                    return;
                }

                OCLMP objOCLMP = new OCLMP();
                objOCLMP.ParentClaimID = ctx.GetKey("OCLMP", "ParentClaimID", "", CustomerID, 0).FirstOrDefault().Value;
                objOCLMP.ParentID = CustomerID;
                objOCLMP.SchemeType = ReasonData.ReasonDesc;
                objOCLMP.CreatedDate = DateTime.Now;
                objOCLMP.FromDate = ClaimFromdate;
                objOCLMP.ToDate = ClaimTodate;
                objOCLMP.CreatedBy = UserID;
                objOCLMP.IsSAP = true;
                objOCLMP.CreatedIPAddress = IPAdd;
                // Check Claim Level Hierarchy
                objOCLMP.HierarchyManagerId = 0;
                Oledb_ConnectionClass objClass12 = new Oledb_ConnectionClass();
                SqlCommand Cmd2 = new SqlCommand();
                Cmd2.Parameters.Clear();
                Cmd2.CommandType = CommandType.StoredProcedure;
                Cmd2.CommandText = "usp_CheckDistributorClaimLevelHierarchyHardCode";
                Cmd2.Parameters.AddWithValue("@ParentID", CustomerID);
                Cmd2.Parameters.AddWithValue("@UserID", UserID);
                Cmd2.Parameters.AddWithValue("@ClaimDate", ClaimFromdate);
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
                            var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).StateID;
                            string Region = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId).StateName;
                            var ReasonId1 = ctx.ORSNs.Where(x => x.ReasonDesc == ddlMode.SelectedValue).FirstOrDefault().ReasonID;
                            string ClaimType1 = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId1).ReasonName;
                            Int16 OEMP = Convert.ToInt16(dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                            //  Data = ctx.GetEmpHierarchyTree(OEMP, 1000010000000000).ToList();
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
                        }
                        //var RegionId = ctx.CRD1.FirstOrDefault(x => x.CustomerID == CustomerID).StateID;
                        //string Region = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionId).StateName;
                        //Int16 ReasonId = Convert.ToInt16(ddlMode.SelectedValue);
                        //string ClaimType = ctx.ORSNs.FirstOrDefault(x => x.ReasonID == ReasonId).ReasonName;
                        //Int16 ManageId = 0;
                        //Oledb_ConnectionClass objClass13 = new Oledb_ConnectionClass();
                        //SqlCommand Cmd3 = new SqlCommand();
                        //Cmd3.Parameters.Clear();
                        //Cmd3.CommandType = CommandType.StoredProcedure;
                        //Cmd3.CommandText = "CheckHierarchyManagerId";
                        //Cmd3.Parameters.AddWithValue("@IsHeirarchy", false);
                        //Cmd3.Parameters.AddWithValue("@ClaimLevel", dsdata1.Tables[0].Rows[0]["ClaimLevel"].ToString());
                        //Cmd3.Parameters.AddWithValue("@EmpId", dsdata1.Tables[0].Rows[0]["EmpId"].ToString());
                        //Cmd3.Parameters.AddWithValue("@ReasonId", ReasonId);
                        //Cmd3.Parameters.AddWithValue("@RegionId", RegionId);
                        //DataSet dsdata2 = objClass13.CommonFunctionForSelect(Cmd3);
                        //if (dsdata2.Tables.Count > 0)
                        //{
                        //    if (dsdata2.Tables[0].Rows.Count > 0)
                        //    {
                        //        ManageId = Convert.ToInt16(dsdata2.Tables[0].Rows[0]["HierarchyManagerId"].ToString());
                        //    }
                        //}
                        //objOCLMP.HierarchyManagerId = ManageId;
                        //if (objOCLMP.HierarchyManagerId == 0)
                        //{
                        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Entry Not Found in Employee wise Reason code master. " + Region + " - " + ClaimType + "',3);", true);
                        //    return;
                        //}
                    }
                }

                objOCLMP.ClaimLevel = -1;
                Decimal cparentid = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == CustomerID).ParentID;
                if (!ctx.OCRDs.Any(x => x.CustomerID == cparentid))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Parent Entry Not found. please refresh and try again.',3);", true);
                    return;
                }
                if (ctx.OCRDs.FirstOrDefault(x => x.CustomerID == cparentid).Type == 4)// Process for Dist of SS
                {
                    objOCLMP.IsSAP = false;
                }
                ctx.OCLMPs.Add(objOCLMP);

                OCLM objOCLM = new OCLM();
                objOCLM.ClaimID = ctx.GetKey("OCLM", "ClaimID", "", CustomerID, 0).FirstOrDefault().Value;
                objOCLM.ParentID = CustomerID;
                objOCLM.Status = 1;
                objOCLM.SAPReasonItemCode = ReasonData.SAPReasonItemCode;
                objOCLM.TotalQty = 0;
                objOCLM.SchemeID = 0;
                objOCLM.SchemeType = ReasonData.ReasonDesc;
                objOCLM.SchemeAmount = SchemeAmount;
                objOCLM.CompanyCont = SchemeAmount;
                objOCLM.DistCont = 0;
                objOCLM.DistContTax = 0;
                objOCLM.TotalCompanyCont = SchemeAmount;
                objOCLM.Deduction = Deduction;
                objOCLM.DeductionRemarks = txtMKTRemarks.Text;
                objOCLM.ApprovedAmount = ApproveAmount;
                objOCLM.Total = Decimal.TryParse(txtTotalSale.Text, out DecNum) ? DecNum : 0;
                objOCLM.TotalPurchase = SchemeSale;
                objOCLM.IsAuto = false;
                objOCLM.SAPDocNo = txtSAPRefno.Text;
                objOCLMP.OCLMs.Add(objOCLM);

                if (objOCLMP.IsSAP == false)
                {
                    OCLMCLD objOCLMCLD = new OCLMCLD();
                    objOCLMCLD.ClaimChildID = ctx.GetKey("OCLMCLD", "ClaimChildID", "", cparentid, 0).FirstOrDefault().Value;
                    objOCLMCLD.ParentID = cparentid;
                    objOCLMCLD.DocNo = DateTime.Now.ToString("yyMMdd") + objOCLMCLD.ClaimChildID.ToString("D7");
                    objOCLMCLD.CustomerID = objOCLMP.ParentID;
                    objOCLMCLD.ParentClaimID = objOCLMP.ParentClaimID;
                    objOCLMCLD.FromDate = objOCLMP.FromDate;
                    objOCLMCLD.ToDate = objOCLMP.ToDate;
                    objOCLMCLD.ClaimDate = objOCLMP.CreatedDate;
                    objOCLMCLD.SchemeAmount = objOCLM.SchemeAmount;
                    objOCLMCLD.Deduction = 0;
                    objOCLMCLD.ApprovedAmount = objOCLM.SchemeAmount;
                    objOCLMCLD.DeductionRemarks = null;
                    objOCLMCLD.ReasonCode = objOCLM.SAPReasonItemCode;
                    objOCLMCLD.IsAuto = true;
                    objOCLMCLD.TotalSale = objOCLM.Total;
                    objOCLMCLD.SchemeSale = objOCLM.TotalPurchase;
                    objOCLMCLD.CreatedDate = DateTime.Now;
                    objOCLMCLD.CreatedBy = UserID;
                    objOCLMCLD.UpdatedDate = DateTime.Now;
                    objOCLMCLD.UpdatedBy = UserID;
                    objOCLMCLD.Status = 1;
                    ctx.OCLMCLDs.Add(objOCLMCLD);
                }

                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3);", true);
        }
    }

    #endregion
}