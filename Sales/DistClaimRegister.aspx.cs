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

public partial class Sales_DistClaimRegister : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    public int CustType;
    protected String Version;
    String ReasonCode = "";
    protected bool IsHierarchy;
    List<usp_GetMangerList_Result> Data;
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
                CustType = Convert.ToInt32(Session["Type"]);
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
        ddlClaimStatus.SelectedValue = "0";
       // ddlMode.SelectedIndex = 0;
        ifmMaterialPurchase.Visible = false;
        if (CustType == 4) // SS
        {
            divDealer.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "4";
            txtSSCode.Enabled = ddlSaleBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var SS = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtSSCode.Text = SS.CustomerCode + " - " + SS.CustomerName + " - " + SS.CustomerID;
            }
        }
        else if (CustType == 2)
        {
            divSS.Attributes.Add("style", "display:none;");
            ddlSaleBy.SelectedValue = "2";
            txtDistCode.Enabled = ddlSaleBy.Enabled = false;

            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Data = ctx.OCRDs.Where(x => x.CustomerID == ParentID).Select(x => new { x.CustomerID, x.CustomerCode, CustomerName = x.CustomerName.Replace("-", "") }).FirstOrDefault();
                txtDistCode.Text = Data.CustomerCode + " - " + Data.CustomerName + " - " + Data.CustomerID;
            }
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
            txtDate.Text = DateTime.Now.AddMonths(-1).ToString("MM/yyyy");
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
            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;

            Decimal CustomerId = DistID > 0 ? DistID : SSID;

             

            if (ddlSaleBy.SelectedValue == "4" && DistID == 0 && SSID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one SS / Dist.',3);", true);
                return;
            }
            else if (ddlSaleBy.SelectedValue == "2" && DistID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one Dist / Dealer.',3);", true);
                return;
            }
            //using (DDMSEntities ctx = new DDMSEntities())
            //{
            //    if (ctx.DOCLMPs.Any(x => x.ParentID == CustomerId && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true))
            //    {
            //        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
            //        //    return;
            //        var ProcessDate = ctx.DOCLMPs.Where(x => x.ParentID == CustomerId && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year).Select(x => new { x.CreatedDate }).FirstOrDefault();
            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Already Processed On " + ProcessDate.CreatedDate.ToString("dd-MMM-yy HH:mm") + "',3);", true);
            //        return;
            //    }

            //}
            DateTime Comparedate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month));
            if (Todate >= Comparedate)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not process next or current month claim.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetClaimDetailsForDistributorClaimRegisterGenerate";
            Cm.Parameters.AddWithValue("@ParentID", CustomerId);
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
                   // gvMasterScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "S")
                {
                    gvQPSScheme.DataSource = ds.Tables[0];
                    gvQPSScheme.DataBind();
                  //  gvQPSScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "D")
                {
                    gvMachineScheme.DataSource = ds.Tables[0];
                    gvMachineScheme.DataBind();
                   // gvMachineScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "P")
                {
                    gvParlourScheme.DataSource = ds.Tables[0];
                    gvParlourScheme.DataBind();
                 //   gvParlourScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "V")
                {
                    gvVRSDiscount.DataSource = ds.Tables[0];
                    gvVRSDiscount.DataBind();
                  //  gvVRSDiscount.Visible = true;
                }
                else if (ddlMode.SelectedValue == "F")
                {
                    gvFOWScheme.DataSource = ds.Tables[0];
                    gvFOWScheme.DataBind();
                 //   gvFOWScheme.Visible = true;
                }
                else if (ddlMode.SelectedValue == "T")
                {
                    gvSecFreight.DataSource = ds.Tables[0];
                    gvSecFreight.DataBind();
                  //  gvSecFreight.Visible = true;
                }
                else if (ddlMode.SelectedValue == "R")
                {
                    gvRateDiff.DataSource = ds.Tables[0];
                    gvRateDiff.DataBind();
                 //   gvRateDiff.Visible = true;
                }
                else if (ddlMode.SelectedValue == "I")
                {
                    gvIOU.DataSource = ds.Tables[0];
                    gvIOU.DataBind();
                 //   gvIOU.Visible = true;
                }
                txtDate.Enabled = ddlMode.Enabled = false;
                btnSubmit_Click(sender, e);
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
           // UserID = 1;
            if (String.IsNullOrEmpty(txtDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Month.',3);", true);
                txtDate.Text = "";
                txtDate.Focus();
                return;
            }
            DateTime Fromdate = Convert.ToDateTime(txtDate.Text);
            DateTime Todate = new DateTime(Fromdate.Year, Fromdate.Month, DateTime.DaysInMonth(Fromdate.Year, Fromdate.Month));


            Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;
            Decimal DistID = Decimal.TryParse(txtDistCode.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;

            Decimal CustomerId = DistID > 0 ? DistID : SSID;



            string IPAdd = hdnIPAdd.Value;
            if (IPAdd == "undefined")
                IPAdd = "";
            if (IPAdd.Length > 15)
                IPAdd = IPAdd = IPAdd.Substring(0, 15);
 
            Decimal ApprovedAmount = 0;
            Decimal TotalPurchase = 0;


            if (gvSecFreight.Rows.Count > 0 || gvMasterScheme.Rows.Count > 0 || gvQPSScheme.Rows.Count > 0 || gvMachineScheme.Rows.Count > 0
                || gvParlourScheme.Rows.Count > 0 || gvVRSDiscount.Rows.Count > 0 || gvFOWScheme.Rows.Count > 0 || gvRateDiff.Rows.Count > 0 || gvIOU.Rows.Count > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ctx.DOCLMPs.Any(x => x.ParentID == CustomerId && x.SchemeType == ddlMode.SelectedValue && x.FromDate.Month == Fromdate.Month && x.FromDate.Year == Fromdate.Year && x.IsActive == true))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('you are already processed same month claim',3);", true);
                        return;
                    }

                    Int32 IntNum = 0;
                    Decimal DecNum = 0;

                    Decimal ParentCustID = Convert.ToDecimal(Session["OutletPID"]);
                    // Check Unit Mapping entry found or not  T90001150  10-Oct-22
                    if (!ctx.OCUMs.Any(x => x.CustID == CustomerId))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('your unit entry not found please contact mktg department',3);", true);
                        return;
                    }
                  
                    int ClaimID = ctx.GetKey("DOCLM", "DClaimID", "", CustomerId, 0).FirstOrDefault().Value;
                    int DCLM1ID = ctx.GetKey("DCLM1", "DCLM1ID", "", CustomerId, 0).FirstOrDefault().Value;


                    DOCLMP objDOCLMP = new DOCLMP();
                    objDOCLMP.DParentClaimID = ctx.GetKey("DOCLMP", "DParentClaimID", "", CustomerId, 0).FirstOrDefault().Value;
                    objDOCLMP.ParentID = CustomerId;
                    objDOCLMP.SchemeType = ddlMode.SelectedValue;
                    objDOCLMP.CreatedDate = DateTime.Now;
                    objDOCLMP.FromDate = Fromdate;
                    objDOCLMP.IsSAP = true;
                    objDOCLMP.ToDate = Todate;
                    objDOCLMP.CreatedBy = UserID;
                    objDOCLMP.CreatedIPAddress = IPAdd;
                    objDOCLMP.IsActive = true;
                    ctx.DOCLMPs.Add(objDOCLMP);
                     
                    if (ddlMode.SelectedValue == "M")
                    {
                        #region Master Scheme
                        List<DCLM1> MasterList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "M";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            MasterList.Add(objDCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == CustomerId && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "M";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = MasterList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;
                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "S")
                    {
                        #region QPS Scheme
                        List<DCLM1> QPSList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            if (Int32.TryParse(hdnItemID.Value, out IntNum) && IntNum > 0)
                                objDCLM1.ItemID = IntNum;
                            objDCLM1.TotalQty = Decimal.TryParse(lblTotalQty.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            QPSList.Add(objDCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == CustomerId && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.ItemID = item.ItemID;
                            objDOCLM.TotalQty = item.TotalQty;
                            objDOCLM.SchemeType = "S";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = QPSList.Where(x => x.CustomerID == item.CustomerID && x.SchemeID == item.SchemeID && x.ItemID == item.ItemID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = "S";
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.TotalQty = DCLM1.TotalQty;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "D")
                    {
                        #region Machine Scheme
                        List<DCLM1> MachineList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "D";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            MachineList.Add(objDCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == CustomerId && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "D";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = MachineList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "P")
                    {
                        #region Parlour Scheme
                        List<DCLM1> ParlourList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "P";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            ParlourList.Add(objDCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == CustomerId && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "P";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = ParlourList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "V")  // VRS Discount scheme
                    {
                        #region VRS Discount
                        List<DCLM1> VRSList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "V";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = Decimal.TryParse(lblDistContTax.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(lblTotalCompanyCont.Text, out DecNum) ? DecNum : 0;

                            VRSList.Add(objDCLM1);

                        }

                        if (ctx.POS3.Count(x => x.ParentID == CustomerId && x.Mode == ddlMode.SelectedValue && x.OPOS.Date.Month == Fromdate.Month && x.OPOS.Date.Year == Fromdate.Year)
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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "V";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = VRSList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                            // 1    objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "F")
                    {
                        #region FOW Scheme
                        List<DCLM1> FOWList = new List<DCLM1>();

                        foreach (GridViewRow item in gvFOWScheme.Rows)
                        {

                            HtmlInputHidden hdnCustomerID = (HtmlInputHidden)item.FindControl("hdnCustomerID");
                            HtmlInputHidden hdnSAPReasonItemCode = (HtmlInputHidden)item.FindControl("hdnSAPReasonItemCode");

                            Literal lblDocType = (Literal)item.FindControl("lblDocType");
                            Literal lblSalesAmount = (Literal)item.FindControl("lblSalesAmount");
                            Literal lblSchemeAmount = (Literal)item.FindControl("lblSchemeAmount");

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "F";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = 0;
                            objDCLM1.DistContPer = 0;
                            objDCLM1.CompanyCont = 0;
                            objDCLM1.DistCont = 0;
                            objDCLM1.DistContTax = 0;
                            objDCLM1.TotalCompanyCont = 0;

                            FOWList.Add(objDCLM1);

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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = 0;
                            objDOCLM.SchemeType = "F";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = 0;
                            objDOCLM.DistCont = 0;
                            objDOCLM.DistContTax = 0;
                            objDOCLM.TotalCompanyCont = item.SchemeAmount;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.SchemeAmount;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = FOWList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "T")
                    {
                        #region Sec Freight Scheme
                        List<DCLM1> SecFreightList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "T";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = Int32.TryParse(hdnSchemeID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = 0;
                            objDCLM1.CompanyCont = 0;
                            objDCLM1.DistCont = 0;
                            objDCLM1.DistContTax = 0;
                            objDCLM1.TotalCompanyCont = objDCLM1.SchemeAmount;

                            SecFreightList.Add(objDCLM1);

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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "T";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = SecFreightList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "R")
                    {
                        #region Rate Diff Scheme


                        List<DCLM1> RateDiffList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnSaleID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = lblDocType.Text;
                            objDCLM1.SchemeType = "R";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = 0;
                            objDCLM1.SubTotal = Decimal.TryParse(lblSalesAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnCompanyContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContPer = Decimal.TryParse(hdnDistContPer.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.CompanyCont = Decimal.TryParse(lblCompanyCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistCont = Decimal.TryParse(lblDistCont.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.DistContTax = 0;
                            objDCLM1.TotalCompanyCont = objDCLM1.CompanyCont;

                            RateDiffList.Add(objDCLM1);

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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = 0;
                            objDOCLM.SchemeID = item.SchemeID;
                            objDOCLM.SchemeType = "R";
                            objDOCLM.SchemeAmount = item.SchemeAmount;
                            objDOCLM.CompanyCont = item.CompanyCont;
                            objDOCLM.DistCont = item.DistCont;
                            objDOCLM.DistContTax = item.DistContTax;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = item.TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = RateDiffList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode && x.SchemeID == item.SchemeID).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;
                                objDCLM1.DistContPer = DCLM1.DistContPer;
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;
                                objDCLM1.DistCont = DCLM1.DistCont;
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }
                    else if (ddlMode.SelectedValue == "I")
                    {
                        #region IOU Auto Claim
                        List<DCLM1> IOUList = new List<DCLM1>();

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

                            DCLM1 objDCLM1 = new DCLM1();
                            objDCLM1.SaleID = Int32.TryParse(hdnOINVRID.Value, out IntNum) ? IntNum : 0; //OINVR [IOU dist. entry] table.
                            objDCLM1.CustomerID = Decimal.TryParse(hdnCustomerID.Value, out DecNum) ? DecNum : 0;
                            objDCLM1.DocType = "SALE";
                            objDCLM1.SchemeType = "I";
                            objDCLM1.SAPReasonItemCode = hdnSAPReasonItemCode.Value;
                            objDCLM1.SchemeID = 0;
                            objDCLM1.ItemID = Int32.TryParse(hdnItemID.Value, out IntNum) ? IntNum : 0;
                            objDCLM1.TotalQty = Decimal.TryParse(lblTotalQty.Text, out DecNum) ? DecNum : 0;
                            objDCLM1.SubTotal = Decimal.TryParse(hdnGrossPurchaseDist.Value, out DecNum) ? DecNum : 0; // Total purchase of dist for claiming month.
                            objDCLM1.SchemeAmount = Decimal.TryParse(lblSchemeAmount.Text, out DecNum) ? DecNum : 0; // Distributor's Claim Amt[Entered amt by dist.]
                            objDCLM1.CompanyContPer = Decimal.TryParse(hdnPerClaim.Value, out DecNum) ? DecNum : 0; // % of Claim Amt
                            objDCLM1.DistContPer = Decimal.TryParse(hdnPerPurchase.Value, out DecNum) ? DecNum : 0;// % of Purchase Amt
                            objDCLM1.CompanyCont = Decimal.TryParse(lblPerClaimAmt.Text, out DecNum) ? DecNum : 0;// Amount [% of Claim Amt]
                            objDCLM1.DistCont = Decimal.TryParse(hdnClaimPurAmtForPer.Value, out DecNum) ? DecNum : 0;// Amount [% of Purchase Amt]
                            objDCLM1.TotalCompanyCont = Decimal.TryParse(hdnFinalClaimAmt.Value, out DecNum) ? DecNum : 0;// Final Claim Calulated amt [Min of two amt.] 
                            objDCLM1.DistContTax = 0;
                            IOUList.Add(objDCLM1);

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
                            DOCLM objDOCLM = new DOCLM();
                            objDOCLM.DClaimID = ClaimID++;
                            objDOCLM.ParentID = CustomerId;
                            objDOCLM.Status = 1;
                            objDOCLM.CustomerID = item.CustomerID;
                            objDOCLM.SAPReasonItemCode = item.SAPReasonItemCode;
                            objDOCLM.TotalQty = item.TotalQty;
                            objDOCLM.SchemeID = 0;
                            objDOCLM.SchemeType = "I";
                            objDOCLM.SchemeAmount = item.SchemeAmount; // Distributor's Claim Amt[Entered amt by dist.]
                            objDOCLM.CompanyCont = item.CompanyCont;//SUM Amount [% of Claim Amt]
                            objDOCLM.DistCont = item.DistCont;//SUM Amount [% of Purchase Amt]
                            objDOCLM.DistContTax = 0;
                            objDOCLM.TotalCompanyCont = item.TotalCompanyCont;// Final Claim Calulated amt [Min of two amt.] 
                            objDOCLM.Deduction = 0;
                            objDOCLM.ApprovedAmount = item.TotalCompanyCont;
                            objDOCLM.TotalPurchase = TotalPurchase;
                            objDOCLM.Total = 0;
                            objDOCLM.IsAuto = true;
                            objDOCLMP.DOCLMs.Add(objDOCLM);

                            var FiltedList = IOUList.Where(x => x.CustomerID == item.CustomerID && x.SAPReasonItemCode == item.SAPReasonItemCode).ToList();
                            foreach (DCLM1 DCLM1 in FiltedList)
                            {
                                DCLM1 objDCLM1 = new DCLM1();
                                objDCLM1.DCLM1ID = DCLM1ID++;
                                objDCLM1.SaleID = DCLM1.SaleID;//OINVR [IOU dist. entry] table.
                                objDCLM1.CustomerID = DCLM1.CustomerID;
                                objDCLM1.DocType = DCLM1.DocType;
                                objDCLM1.SchemeType = DCLM1.SchemeType;
                                objDCLM1.SchemeID = DCLM1.SchemeID;
                                objDCLM1.ItemID = DCLM1.ItemID;
                                objDCLM1.TotalQty = DCLM1.TotalQty;
                                objDCLM1.SAPReasonItemCode = DCLM1.SAPReasonItemCode;
                                objDCLM1.SubTotal = DCLM1.SubTotal;           // Total purchase of dist for claiming month.
                                objDCLM1.SchemeAmount = DCLM1.SchemeAmount;   // Distributor's Claim Amt[Entered amt by dist.]
                                objDCLM1.CompanyContPer = DCLM1.CompanyContPer;// % of Claim Amt
                                objDCLM1.DistContPer = DCLM1.DistContPer;// % of Purchase Amt
                                objDCLM1.CompanyCont = DCLM1.CompanyCont;// Amount [% of Claim Amt]
                                objDCLM1.DistCont = DCLM1.DistCont;// Amount [% of Purchase Amt]
                                objDCLM1.DistContTax = DCLM1.DistContTax;
                                objDCLM1.TotalCompanyCont = DCLM1.TotalCompanyCont;// Final Claim Calulated amt [Min of two amt.]

                                objDOCLM.DCLM1.Add(objDCLM1);
                            }
                        }

                        #endregion
                    }

                     

                    ctx.SaveChanges();
                    txtDate.Enabled = ddlMode.Enabled = true;
                    ClearAllInputs();
                    // }  // 14-Dec-22

                    // Generate Claim Register
                    var ItemDetail = chkItemDetail.Checked ? "1" : "0";
                    if (ddlMode.SelectedValue == "S")
                    {
                        ItemDetail = "0";
                    }
                    int ReasonId = ctx.ORSNs.Where(x => x.SAPReasonItemCode == ReasonCode).FirstOrDefault().ReasonID;
                    string ipvalue = (string.IsNullOrEmpty(IPAdd) ? "" : " / " + IPAdd);

                    ifmMaterialPurchase.Attributes.Add("src", "../Reports/ViewReport.aspx?DIstClaimRegFromDate=" + Fromdate.ToShortDateString() + "&DistClaimRegToDate=" + Todate.ToShortDateString() + "&ClaimRegClaimStatus=0&ClaimRegDealerID=0&ClaimRegDistID=" + DistID + "&ClaimRegSSID=" + SSID + "&ClaimItemDetail=" + ItemDetail + "&Stype=" + ReasonId.ToString() + "&ReportBy=" + ddlSaleBy.SelectedValue + "&SUserID=" + UserID + "&IpAddress=" + ipvalue + "&CompCust=" + CustomerId);
                    ifmMaterialPurchase.Visible = true;
                    //
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
        Response.Redirect("DistClaimRegister.aspx");
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
    protected void ifmMaterialPurchase_Load(object sender, EventArgs e)
    {

    }
}