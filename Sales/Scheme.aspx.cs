using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

[Serializable]
public class CustData
{
    public Int32? RegionID { get; set; }
    public String RegionName { get; set; }
    public Int32? PlantID { get; set; }
    public String PlantName { get; set; }
    public Decimal? DistributorID { get; set; }
    public String DistributorCode { get; set; }
    public Decimal? DealerID { get; set; }
    public String DealerCode { get; set; }
    public String CustGroupName { get; set; }
    public String CustGroupDesc { get; set; }
    public Decimal? CouponAmount { get; set; }
    public Decimal? UsedCoupon { get; set; }
    public Int32? CustType { get; set; }
    public String AssetCode { get; set; }
    public Boolean Active { get; set; }
    public Boolean IsInclude { get; set; }
    public DateTime? SyncDate { get; set; }
}

public partial class Marketing_Scheme : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    private List<CustData> SCM1s
    {
        get { return this.ViewState["SCM1"] as List<CustData>; }
        set { this.ViewState["SCM1"] = value; }
    }

    private List<SCM4> SCM4s
    {
        get { return this.ViewState["SCM4"] as List<SCM4>; }
        set { this.ViewState["SCM4"] = value; }
    }

    private List<SCM3> SCM3s
    {
        get { return this.ViewState["SCM3"] as List<SCM3>; }
        set { this.ViewState["SCM3"] = value; }
    }

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            ACEtxtCode.Enabled = txtCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCode.Text = "Auto Generated";
            txtCode.Style.Remove("background-color");
            btnCopyQPS.Visible = false;
            txtSchmCode.Focus();
        }
        else
        {
            ACEtxtCode.Enabled = txtCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCode.Text = "";
            txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCode.Focus();
        }
        txtUsedCoupon.Text = txtCouponAmount.Text = txtCode.Text = txtDiscount.Text = txtCompanyDisc.Text = txtDistributorDisc.Text = txtEDate.Text =
           txtPrice.Text = txtETime.Text = txtGroup.Text = txtHigherLimit.Text = txtLowerLimit.Text = txtMat.Text = txtMatName.Text = txtName.Text = txtQuantity.Text =
           txtAssetCode.Text = txtRemarks.Text = txtSchmCode.Text = txtSDate.Text = txtSTime.Text = txtSubGroup.Text = txtDivision.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = "";
        chkActive.Checked = chkMonday.Checked = chkTuesday.Checked = chkWednesday.Checked = chkThursday.Checked = chkFriday.Checked = chkSaturday.Checked = chkSunday.Checked = true;
        chkQPSTempDlr.Checked = chkQPSFOWDlr.Checked = chkIsSAP.Checked = chkTaxApp.Checked = false;
        ddlQPSSchemeEligible.SelectedValue = "3";
        btnSubmit.Visible = true;
        ViewState["SchemeID"] = ViewState["SCM1"] = ViewState["SCM3"] = ViewState["SCM4"] = null;
        chkInclude.Checked = rdbper.Checked = true;
        ddlMode_SelectedIndexChanged(ddlMode, EventArgs.Empty);
        ddlApplcableOn_SelectedIndexChanged(ddlApplcableOn, EventArgs.Empty);
        txtPrice.Enabled = true;
        txtAssetCode.Enabled = true;
        gvItemGroup.DataSource = null;
        gvItemGroup.DataBind();

        gvScheme.DataSource = null;
        gvScheme.DataBind();

        gvCustData.DataSource = null;
        gvCustData.DataBind();

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();

        gvitemMisdata.DataSource = null;
        gvitemMisdata.DataBind();

        gvProductMappingMissData.DataSource = null;
        gvProductMappingMissData.DataBind();

        ClearMapping();

        btnAddGroup.Text = "Add Group";
        btnAddCustData.Text = "Add Cust Data";
        chkInclude.Checked = true;
        txtUsedCoupon.Text = txtCouponAmount.Text = txtGroup.Text = txtSubGroup.Text = txtMatName.Text = txtRegion.Text = txtPlant.Text = txtDistributor.Text = txtDealer.Text = txtCustGroup.Text = "";
        ViewState["LineID"] = null;
        ViewState["CustDataID"] = null;
        divUnit.Visible = false;
        ddlIsPair.SelectedValue = "0";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('Scheme', 'tabs-1');", true);
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
                            var unit = xml.Descendants("customer_grp_master");
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

    private void ClearMapping()
    {
        txtPrice.Text = txtOccurrence.Text = txtLowerLimit.Text = txtHigherLimit.Text =  txtDiscount.Text = txtCompanyDisc.Text = txtDistributorDisc.Text = "0.00";
        txtQuantity.Text = "0";
        txtMat.Text = "";
        ddlBasedOn.SelectedValue = "1";
        ViewState["GSchemeID"] = null;
        btnScheme.Text = "Add Scheme";
        rdbper.Checked = true;
        rdbdis.Checked = false;
        txtPrice.Enabled = true;
        ddlIsPair.SelectedValue = "-1";
    }

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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(btnCUpload);
        scriptManager.RegisterPostBackControl(btnItemUpload);
        scriptManager.RegisterPostBackControl(btnMappingUpload);
    }

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {

                    if (SCM4s == null || SCM4s.Count == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter at least One Mapping.',3);", true);
                        return;
                    }
                    if ((ddlMode.SelectedValue == "M" || ddlMode.SelectedValue == "D" || ddlMode.SelectedValue == "P" || ddlMode.SelectedValue == "V")
                        && SCM4s.Any(x => x.ItemID.HasValue))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select item in Master OR Machine scheme.',3);", true);
                        return;
                    }
                    if ((ddlMode.SelectedValue == "A") && SCM4s.Any(x => x.DistributorDisc.GetValueOrDefault(0) > 0))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not enter Distributor Discount in S To D scheme.',3);", true);
                        return;
                    }

                    DateTime dt;
                    TimeSpan ts;

                    OSCM objOSCM = null;
                    int SchemeID;
                    if (ViewState["SchemeID"] != null && Int32.TryParse(ViewState["SchemeID"].ToString(), out SchemeID))
                    {
                        objOSCM = ctx.OSCMs.Include("SCM1").Include("SCM2").Include("SCM3").Include("SCM4").FirstOrDefault(x => x.SchemeID == SchemeID);
                    }
                    else
                    {
                        objOSCM = new OSCM();

                        if (ctx.OSCMs.Any(x => x.SchemeCode == txtSchmCode.Text.Trim()))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same scheme code is not allowed!',3);", true);
                            return;
                        }
                        objOSCM.SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                        objOSCM.CreatedDate = DateTime.Now;
                        objOSCM.CreatedBy = UserID;
                        objOSCM.IsSAP = false;
                        ctx.OSCMs.Add(objOSCM);
                    }
                    if (objOSCM.IsSAP == true)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not allow SAP Scheme.',3);", true);
                        return;
                    }
                    if (Common.DateTimeConvert(txtSDate.Text, out dt))
                        objOSCM.StartDate = dt;
                    if (TimeSpan.TryParse(txtSTime.Text, out ts))
                        objOSCM.StartTime = ts;
                    if (Common.DateTimeConvert(txtEDate.Text, out dt))
                        objOSCM.EndDate = dt;
                    if (TimeSpan.TryParse(txtETime.Text, out ts))
                        objOSCM.EndTime = ts;

                    objOSCM.SchemeCode = txtSchmCode.Text.Trim();
                    objOSCM.SchemeName = txtName.Text.Trim();
                    objOSCM.Active = chkActive.Checked;
                    objOSCM.SchemeCondition = Convert.ToInt32(ddlQPSSchemeEligible.SelectedValue);
                    objOSCM.ForFOW = chkQPSFOWDlr.Checked;
                    objOSCM.ForTemp = chkQPSTempDlr.Checked;
                    objOSCM.ApplicableMode = ddlMode.SelectedValue;
                    objOSCM.ReasonID = Convert.ToInt32(ddlReason.SelectedValue);
                    if (objOSCM.ApplicableMode == "M")
                    {
                        if (ctx.ORSNs.Any(x => x.ReasonDesc == "M" && x.Active))
                        {
                            objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "M" && x.Active).ReasonID;
                        }
                    }
                    else if (objOSCM.ApplicableMode == "S")
                    {
                        if (ctx.ORSNs.Any(x => x.ReasonDesc == "S" && x.Active))
                        {
                            objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "S" && x.Active).ReasonID;
                        }
                    }
                    else if (objOSCM.ApplicableMode == "D")
                    {
                        if (ctx.ORSNs.Any(x => x.ReasonDesc == "D" && x.Active))
                        {
                            objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "D" && x.Active).ReasonID;
                        }
                    }
                    else if (objOSCM.ApplicableMode == "P")
                    {
                        if (ctx.ORSNs.Any(x => x.ReasonDesc == "P" && x.Active))
                        {
                            objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "P" && x.Active).ReasonID;
                        }
                    }
                    else if (objOSCM.ApplicableMode == "V") // Find Reason code for VRS Discount 
                    {
                        if (ctx.ORSNs.Any(x => x.ReasonDesc == "V" && x.Active))
                        {
                            objOSCM.ReasonID = ctx.ORSNs.FirstOrDefault(x => x.ReasonDesc == "V" && x.Active).ReasonID;
                        }
                    }

                    objOSCM.ApplicableOn = Convert.ToInt32(ddlApplcableOn.SelectedValue);
                    objOSCM.BirthDay = false;
                    objOSCM.Anniversary = false;
                    objOSCM.SpecialDay = false;
                    objOSCM.Monday = chkMonday.Checked;
                    objOSCM.Tuesday = chkTuesday.Checked;
                    objOSCM.Wednesday = chkWednesday.Checked;
                    objOSCM.Thursday = chkThursday.Checked;
                    objOSCM.Friday = chkFriday.Checked;
                    objOSCM.Saturday = chkSaturday.Checked;
                    objOSCM.Sunday = chkSunday.Checked;
                    objOSCM.IsTaxApplicable = chkTaxApp.Checked;
                    objOSCM.Remarks = txtRemarks.Text;
                    objOSCM.UpdatedDate = DateTime.Now;
                    objOSCM.UpdatedBy = UserID;

                    if (SCM1s != null)
                    {
                        objOSCM.SCM1.ToList().ForEach(x => ctx.SCM1.Remove(x));

                        int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                        int AssetCount = ctx.GetKey("OAST", "AssetID", "", 0, 0).FirstOrDefault().Value;
                        foreach (CustData item in SCM1s)
                        {
                            if (item.DealerID > 0 || item.DistributorID > 0 || item.PlantID > 0 || item.RegionID > 0 || !string.IsNullOrEmpty(item.CustGroupDesc))
                            {
                                var CustGroupID = !string.IsNullOrEmpty(item.CustGroupDesc) && ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == item.CustGroupName) != null ? ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == item.CustGroupName).CustGroupID : 0;

                                if (objOSCM.ApplicableMode == "P" || objOSCM.ApplicableMode == "D" || objOSCM.ApplicableMode == "V")
                                {
                                    #region Machine / Parlour / VRS Discount
                                    if (item.DealerID == null || item.DealerID == 0)
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select dealer at line :" + (SCM1s.IndexOf(item) + 1).ToString() + "',3);", true);
                                        return;
                                    }
                                    Decimal DistID = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == item.DealerID.Value).ParentID;
                                    if (!ctx.OGCRDs.Any(x => x.CustomerID == DistID && x.PlantID.HasValue && x.PlantID > 0))
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Plant code does not exist for selected dealer parent at line :" + (SCM1s.IndexOf(item) + 1).ToString() + "',3);", true);
                                        return;
                                    }
                                    if (item.DealerID == 0)
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Dealer selection is compulsory for same scheme.',3);", true);
                                        return;
                                    }
                                    if (string.IsNullOrEmpty(item.AssetCode))
                                    {
                                        if (objOSCM.ApplicableMode == "V")
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset is complasary for VRS Discount Scheme.',3);", true);
                                            txtAssetCode.Enabled = true;
                                            return;
                                        }
                                        else
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset is complasary for Machine / Parlour Scheme.',3);", true);
                                            txtAssetCode.Enabled = true;
                                            return;
                                        }
                                    }
                                    OAST objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == item.AssetCode.Trim());
                                    if (objOAST == null)
                                    {
                                        objOAST = new OAST();
                                        objOAST.AssetID = AssetCount++;
                                        objOAST.AssetCode = item.AssetCode;
                                        objOAST.AssetName = item.AssetCode;
                                        objOAST.AssetTypeID = 4;
                                        objOAST.ModelNumber = item.AssetCode;
                                        objOAST.SerialNumber = item.AssetCode;
                                        objOAST.AdditionalIdentifier = "99999";
                                        objOAST.HoldByCustomerID = item.DealerID;
                                        objOAST.CreatedDate = DateTime.Now;
                                        objOAST.CreatedBy = UserID;
                                        objOAST.UpdatedDate = DateTime.Now;
                                        objOAST.UpdatedBy = UserID;
                                        objOAST.Active = true;
                                        objOAST.AssetSubnumber = "0001";
                                        objOAST.Location = ctx.CRD1.FirstOrDefault(x => x.CustomerID == item.DealerID.Value).OCTY.CityName;
                                        objOAST.AcqDate = DateTime.Now;
                                        objOAST.PlantID = ctx.OGCRDs.FirstOrDefault(x => x.CustomerID == DistID && x.PlantID.HasValue).PlantID;
                                        objOAST.Volume = 1;
                                        ctx.OASTs.Add(objOAST);
                                    }
                                    if (ctx.SCM1.Any(x => x.AssetID == objOAST.AssetID && x.Active && x.CustomerID != item.DealerID))
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Asset : " + item.AssetCode + " is already mapped with customer.',3);", true);
                                        return;
                                    }

                                    if (item.Active)
                                    {
                                        SCM1 objoldSCM1 = ctx.SCM1.FirstOrDefault(x => x.AssetID == objOAST.AssetID && x.CustomerID == item.DealerID && x.Active);
                                        if (objoldSCM1 == null)
                                        {
                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DealerID;
                                            objSCM1.Type = item.CustType.Value;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.UsedCoupon = 0;
                                            objSCM1.CouponAmount = item.CouponAmount;
                                            objSCM1.AssetID = objOAST.AssetID;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                        else if (objoldSCM1.SchemeID == objOSCM.SchemeID)
                                        {
                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DealerID;
                                            objSCM1.Type = item.CustType.Value;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.UsedCoupon = objoldSCM1.UsedCoupon;
                                            objSCM1.CouponAmount = item.CouponAmount;
                                            objSCM1.AssetID = objoldSCM1.AssetID;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                        else
                                        {
                                            objoldSCM1.Active = false;

                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DealerID;
                                            objSCM1.Type = item.CustType.Value;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.UsedCoupon = objoldSCM1.UsedCoupon;
                                            objSCM1.CouponAmount = item.CouponAmount;
                                            objSCM1.AssetID = objoldSCM1.AssetID;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                    }
                                    else
                                    {
                                        SCM1 objSCM1 = new SCM1();
                                        objSCM1.SCM1ID = SCM1Count++;
                                        objSCM1.CustomerID = item.DealerID;
                                        objSCM1.Type = item.CustType.Value;
                                        objSCM1.CreatedDate = item.SyncDate;
                                        objSCM1.Active = item.Active;
                                        objSCM1.IsInclude = item.IsInclude;
                                        objSCM1.UsedCoupon = item.UsedCoupon;
                                        objSCM1.CouponAmount = item.CouponAmount;
                                        objSCM1.AssetID = objOAST.AssetID;
                                        objSCM1.CustGroupID = CustGroupID;
                                        objOSCM.SCM1.Add(objSCM1);
                                    }
                                    #endregion
                                }
                                else if (objOSCM.ApplicableMode == "M")
                                {
                                    #region Master
                                    if (objOSCM.ApplicableOn == 2)
                                    {
                                        if (objOSCM.ApplicableOn == 2 && item.DistributorID.GetValueOrDefault(0) == 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Distributor selection is compulsory for same scheme.',3);", true);
                                            return;
                                        }
                                        if (item.Active && (ctx.SCM1.Any(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.Active  && x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DistributorID && x.Active)))
                                        {
                                            string strData = "", SchemeId = "";
                                            SchemeId = ctx.SCM1.Where(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DistributorID && x.Active).Select(x => x.SchemeID).FirstOrDefault().ToString();
                                            ctx.SCM1.Where(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DistributorID && x.Active).Select(x => SchemeId + " # " + x.OSCM.SchemeCode).ToList().ForEach(x => strData += x + " # " + item.DistributorCode + ", ");
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Master Scheme Code " + strData.TrimEnd(", ".ToArray()) + " already available.',3);", true);
                                            return;
                                        }
                                        else
                                        {
                                            if (item.Active)
                                            {
                                                ctx.SCM1.Where(x => x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DistributorID && x.Active).ToList().ForEach(x => x.Active = false);
                                            }

                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DistributorID;
                                            objSCM1.Type = 2;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                    }
                                    else if (objOSCM.ApplicableOn == 3)
                                    {
                                        if (objOSCM.ApplicableOn == 3 && item.DealerID.GetValueOrDefault(0) == 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Dealer selection is compulsory for same scheme.',3);", true);
                                            return;
                                        }
                                        if (item.Active && (ctx.SCM1.Any(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DealerID && x.Active)))
                                        {
                                            string strData = "";
                                            ctx.SCM1.Where(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DealerID && x.Active).Select(x => x.OSCM.SchemeCode).ToList().ForEach(x => strData += x + " # " + item.DealerCode + ", ");
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Master Scheme Code " + strData.TrimEnd(", ".ToArray()) + " already available.',3);", true);
                                            return;
                                        }
                                        else
                                        {
                                            if (item.Active)
                                            {
                                                ctx.SCM1.Where(x => x.OSCM.ApplicableMode == "M" && x.CustomerID == item.DealerID && x.Active).ToList().ForEach(x => x.Active = false);
                                            }

                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DealerID;
                                            objSCM1.Type = 3;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Applicable Mode is not proper.',3);", true);
                                        return;
                                    }


                                    #endregion
                                }
                                else if (objOSCM.ApplicableMode == "A")
                                {
                                    #region S to D
                                    if (objOSCM.ApplicableOn == 2)
                                    {
                                        if (objOSCM.ApplicableOn == 2 && item.DistributorID.GetValueOrDefault(0) == 0)
                                        {
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Distributor selection is compulsory for same scheme.',3);", true);
                                            return;
                                        }
                                        //Logic Change by Jigneshbhai on date 02-Mar-21 on telephonic .. to solve the case of adding new distributor and then all distributor are changed as in-active.
                                        if (item.Active && (ctx.SCM1.Any(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "A" && x.CustomerID == item.DistributorID && x.Active)))
                                        {
                                            string strData = "";
                                            ctx.SCM1.Where(x => x.SchemeID != objOSCM.SchemeID && x.OSCM.ApplicableMode == "A" && x.CustomerID == item.DistributorID && x.Active).Select(x => x.OSCM.SchemeCode).ToList().ForEach(x => strData += x + " # " + item.DistributorCode + ", ");
                                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('STOD Scheme Code " + strData.TrimEnd(", ".ToArray()) + " already available.',3);", true);
                                            return;
                                        }
                                        else
                                        {
                                            if (item.Active)
                                            {
                                                ctx.SCM1.Where(x => x.OSCM.ApplicableMode == "A" && x.CustomerID == item.DistributorID && x.Active).ToList().ForEach(x => x.Active = false);
                                            }
                                            SCM1 objSCM1 = new SCM1();
                                            objSCM1.SCM1ID = SCM1Count++;
                                            objSCM1.CustomerID = item.DistributorID;
                                            objSCM1.Type = 2;
                                            objSCM1.CreatedDate = item.SyncDate;
                                            objSCM1.Active = item.Active;
                                            objSCM1.IsInclude = item.IsInclude;
                                            objSCM1.CustGroupID = CustGroupID;
                                            objOSCM.SCM1.Add(objSCM1);
                                        }
                                    }
                                    else
                                    {
                                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Distributor selection is compulsory for same scheme.',3);", true);
                                        return;
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region QPS

                                    SCM1 objSCM1 = new SCM1();
                                    objSCM1.SCM1ID = SCM1Count++;

                                    if (item.RegionID.GetValueOrDefault(0) > 0)
                                        objSCM1.RegionID = item.RegionID;
                                    else
                                        objSCM1.RegionID = null;

                                    if (item.PlantID.GetValueOrDefault(0) > 0)
                                        objSCM1.PlantID = item.PlantID;
                                    else
                                        objSCM1.PlantID = null;

                                    if (item.DealerID.GetValueOrDefault(0) > 0 && item.CustType == 3)
                                    {
                                        objSCM1.CustomerID = item.DealerID;
                                        objSCM1.Type = 3;
                                    }
                                    else if (item.DistributorID.GetValueOrDefault(0) > 0 && item.CustType == 2)
                                    {
                                        objSCM1.CustomerID = item.DistributorID;
                                        objSCM1.Type = 2;
                                    }
                                    else
                                    {
                                        objSCM1.CustomerID = null;
                                        objSCM1.Type = 0;
                                    }
                                    objSCM1.CustGroupID = CustGroupID;
                                    objSCM1.CreatedDate = item.SyncDate;
                                    objSCM1.Active = item.Active;
                                    objSCM1.IsInclude = item.IsInclude;
                                    objOSCM.SCM1.Add(objSCM1);
                                    #endregion
                                }
                            }
                        }
                    }

                    SCM3 objSCM3 = null;
                    objOSCM.SCM3.ToList().ForEach(x => ctx.SCM3.Remove(x));
                    int GroupCount = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                    if (SCM3s != null)
                        foreach (SCM3 item in SCM3s)
                        {
                            objSCM3 = new SCM3();
                            objSCM3.SCM3ID = GroupCount++;
                            objSCM3.SchemeID = objOSCM.SchemeID;
                            objSCM3.ItemID = item.ItemID;
                            objSCM3.ItemGroupID = item.ItemGroupID;
                            objSCM3.ItemSubGroupID = item.ItemSubGroupID;
                            objSCM3.IsInclude = item.IsInclude;
                            objSCM3.DivisionID = item.DivisionID;
                            objOSCM.SCM3.Add(objSCM3);
                        }

                    SCM4 objSCM4 = null;
                    objOSCM.SCM4.ToList().ForEach(x => ctx.SCM4.Remove(x));
                    int SchemeCount = ctx.GetKey("SCM4", "SCM4ID", "", 0, 0).FirstOrDefault().Value;

                    foreach (SCM4 item in SCM4s)
                    {
                        if (ddlMode.SelectedValue == "S")
                        {
                            //if (item.DiscountType == "P" && item.Price <= 0)
                            //{
                            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('With Selecting Discount Type % then QPS Master Rate should be compulsory at Line Number :" + (SCM4s.IndexOf(item) + 1).ToString() + "',3);", true);
                            //    return;
                            //}
                            if (item.DiscountType == "A" && item.Price > 0)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('With Selecting Discount Type ₹ then QPS Master Rate should be 0 at Line Number :" + (SCM4s.IndexOf(item) + 1).ToString() + "',3);", true);
                                return;
                            }
                        }
                        objSCM4 = new SCM4();
                        objSCM4.SCM4ID = SchemeCount++;
                        objSCM4.SchemeID = objOSCM.SchemeID;
                        objSCM4.LowerLimit = item.LowerLimit;
                        objSCM4.HigherLimit = item.HigherLimit;
                        objSCM4.ItemGroupID = item.ItemGroupID;
                        objSCM4.ItemSubGroupID = item.ItemSubGroupID;
                        objSCM4.ItemID = item.ItemID;
                        objSCM4.Occurrence = item.Occurrence;
                        objSCM4.Quantity = item.Quantity;
                        objSCM4.BasedOn = item.BasedOn;
                        objSCM4.Discount = item.Discount;
                        objSCM4.DiscountType = item.DiscountType;
                        objSCM4.CompanyDisc = item.CompanyDisc;
                        objSCM4.DistributorDisc = item.DistributorDisc;
                        objSCM4.UnitID = item.UnitID;
                        objSCM4.Price = item.Price;
                        objSCM4.IsPair = item.IsPair;
                        objOSCM.SCM4.Add(objSCM4);
                    }

                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOSCM.SchemeName + "',1);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (DbEntityValidationException ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.EntityValidationErrors.FirstOrDefault().ValidationErrors.FirstOrDefault().ErrorMessage + "',2);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("Sales.aspx");
    }

    protected void btnCopyQPS_Click(object sender, EventArgs e)
    {
        Int32 QPSSchemeID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).First().Trim(), out QPSSchemeID) ? QPSSchemeID : 0;
        try
        {
            if (Page.IsValid)
            {
                if (hdnCopyActive.Value == "0")
                {
                    ClearAllInputs();
                    btnCopyQPS.Visible = false;
                    return;
                }

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (!ctx.OSCMs.Any(x => x.SchemeID == QPSSchemeID && x.ApplicableMode == "S"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Selected Scheme is not QPS,  you can’t create the same',2);", true);
                        return;
                    }
                    if (ctx.OSCMs.Any(x => x.SchemeCode == "QPSCOPY"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Scheme QPSCOPY is available,  you can’t create the same',2);", true);
                        return;
                    }

                    OSCM objOSCMFrom = ctx.OSCMs.Include("SCM1").Include("SCM3").FirstOrDefault(x => x.SchemeID == QPSSchemeID);
                    OSCM objOSCMTo = new OSCM();

                    var properties = CollectionExtensions.GetProperty(typeof(OSCM).GetProperties());
                    foreach (string item in properties)
                        objOSCMTo.GetType().GetProperty(item).SetValue(objOSCMTo, objOSCMFrom.GetType().GetProperty(item).GetValue(objOSCMFrom, null), null);

                    objOSCMTo.SchemeID = ctx.GetKey("OSCM", "SchemeID", "", 0, 0).FirstOrDefault().Value;
                    objOSCMTo.SchemeCode = "QPSCOPY";
                    objOSCMTo.SchemeName = "QPSCOPY";
                    objOSCMTo.CreatedDate = DateTime.Now;
                    objOSCMTo.CreatedBy = UserID;
                    objOSCMTo.UpdatedDate = DateTime.Now;
                    objOSCMTo.UpdatedBy = UserID;
                    objOSCMTo.IsSAP = false;
                    ctx.OSCMs.Add(objOSCMTo);

                    int SCM1Count = ctx.GetKey("SCM1", "SCM1ID", "", 0, 0).FirstOrDefault().Value;
                    foreach (SCM1 objSCM1From in objOSCMFrom.SCM1.OrderBy(x => x.SCM1ID).ToList())
                    {
                        SCM1 objSCM1To = new SCM1();
                        properties = CollectionExtensions.GetProperty(typeof(SCM1).GetProperties());
                        foreach (string item in properties)
                            objSCM1To.GetType().GetProperty(item).SetValue(objSCM1To, objSCM1From.GetType().GetProperty(item).GetValue(objSCM1From, null), null);

                        objSCM1To.SCM1ID = SCM1Count++;
                        objSCM1To.CreatedDate = DateTime.Now;
                        objOSCMTo.SCM1.Add(objSCM1To);
                    }

                    int SCM3Count = ctx.GetKey("SCM3", "SCM3ID", "", 0, 0).FirstOrDefault().Value;
                    foreach (SCM3 objSCM3From in objOSCMFrom.SCM3.OrderBy(x => x.SCM3ID).ToList())
                    {
                        SCM3 objSCM3To = new SCM3();
                        properties = CollectionExtensions.GetProperty(typeof(SCM3).GetProperties());
                        foreach (string item in properties)
                            objSCM3To.GetType().GetProperty(item).SetValue(objSCM3To, objSCM3From.GetType().GetProperty(item).GetValue(objSCM3From, null), null);

                        objSCM3To.SCM3ID = SCM3Count++;
                        objOSCMTo.SCM3.Add(objSCM3To);
                    }
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOSCMTo.SchemeName + "',1);", true);
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

    #region Change Event

    protected void txtCodeTextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtCode.Text))
            {
                //SCM1 Clear
                btnCancleCustData_Click(btnCancleCustData, EventArgs.Empty);
                //SCM4 Clear
                ClearMapping();
                //SCM3 Clear
                btnCancelGroup_Click(btnCancelGroup, EventArgs.Empty);
                // for General tab Clear
                txtSDate.Text = txtEDate.Text = txtSTime.Text = txtETime.Text = "";
                chkActive.Checked = true;
                chkTaxApp.Checked = false;

                var Data = txtCode.Text.Split("-".ToArray());
                if (Data.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        String SchemeCode = Data.First().Trim();

                        if (ctx.OSCMs.Any(x => x.SchemeCode == SchemeCode && x.ApplicableMode == "S"))
                            btnCopyQPS.Visible = true;
                        else
                            btnCopyQPS.Visible = false;
                        var objOSCM = ctx.OSCMs.Include("SCM1").Include("SCM2").Include("SCM3").Include("SCM4").Include("SCM4.OUNT").FirstOrDefault(x => x.SchemeCode == SchemeCode);
                        if (!objOSCM.Active)
                            hdnIsActive.Value = "0";
                        else
                            hdnIsActive.Value = "1";

                        if (objOSCM != null)
                        {
                            if (objOSCM.IsSAP)
                                btnSubmit.Visible = false;
                            else
                                btnSubmit.Visible = true;

                            ViewState["SchemeID"] = objOSCM.SchemeID;
                            txtName.Text = objOSCM.SchemeName;
                            txtCode.Text = objOSCM.SchemeID.ToString();
                            txtSchmCode.Text = objOSCM.SchemeCode;
                            chkActive.Checked = objOSCM.Active;
                            if (ddlReason.Items.FindByValue(objOSCM.ReasonID.ToString()) != null)
                                ddlReason.SelectedValue = objOSCM.ReasonID.ToString();
                            ddlQPSSchemeEligible.SelectedValue = objOSCM.SchemeCondition.ToString();
                            chkQPSFOWDlr.Checked = objOSCM.ForFOW;
                            chkQPSTempDlr.Checked = objOSCM.ForTemp;
                            ddlMode.SelectedValue = objOSCM.ApplicableMode;
                            ddlApplcableOn.SelectedValue = objOSCM.ApplicableOn.ToString();
                            ddlMode_SelectedIndexChanged(ddlMode, EventArgs.Empty);
                            ddlApplcableOn_SelectedIndexChanged(ddlApplcableOn, EventArgs.Empty);
                            if (objOSCM.StartDate.HasValue)
                                txtSDate.Text = Common.DateTimeConvert(objOSCM.StartDate.Value);
                            if (objOSCM.StartTime.HasValue)
                                txtSTime.Text = Convert.ToString(objOSCM.StartTime.Value);
                            if (objOSCM.EndDate.HasValue)
                                txtEDate.Text = Common.DateTimeConvert(objOSCM.EndDate.Value);
                            if (objOSCM.EndTime.HasValue)
                                txtETime.Text = Convert.ToString(objOSCM.EndTime.Value);
                            chkMonday.Checked = objOSCM.Monday;
                            chkTuesday.Checked = objOSCM.Tuesday;
                            chkWednesday.Checked = objOSCM.Wednesday;
                            chkThursday.Checked = objOSCM.Thursday;
                            chkFriday.Checked = objOSCM.Friday;
                            chkSaturday.Checked = objOSCM.Saturday;
                            chkSunday.Checked = objOSCM.Sunday;
                            chkTaxApp.Checked = objOSCM.IsTaxApplicable;
                            chkIsSAP.Checked = objOSCM.IsSAP;
                            txtRemarks.Text = objOSCM.Remarks;

                            txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCM.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCM.CreatedDate.ToString("dd/MM/yyyy HH:mm") + "  " + objOSCM.CreatedIPAddress;
                            txtCreatedTime.Text = objOSCM.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCM.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCM.UpdatedDate.ToString("dd/MM/yyyy HH:mm") + "  " + objOSCM.UpdatedIPAddress;
                            txtUpdatedTime.Text = objOSCM.UpdatedDate.ToString("dd/MM/yyyy HH:mm");

                            SCM1s = new List<CustData>();

                            foreach (SCM1 sc in objOSCM.SCM1)
                            {
                                CustData item = new CustData();

                                item.RegionID = sc.RegionID;
                                item.RegionName = sc.RegionID.HasValue ? ctx.OCSTs.FirstOrDefault(z => z.StateID == sc.RegionID.Value).StateName : "";
                                item.PlantID = sc.PlantID;
                                item.PlantName = sc.PlantID.HasValue ? (ctx.OPLTs.FirstOrDefault(y => y.PlantID == sc.PlantID).PlantName) : "";
                                item.DistributorID = sc.Type == 2 ? sc.CustomerID : null;
                                item.DistributorCode = sc.Type == 2 ? sc.OCRD.CustomerCode + " # " + sc.OCRD.CustomerName : "";
                                item.DealerID = sc.Type == 3 ? sc.CustomerID : null;
                                item.DealerCode = sc.Type == 3 ? sc.OCRD.CustomerCode + " # " + sc.OCRD.CustomerName : "";
                                item.CustGroupName = sc.CustGroupID.HasValue && sc.CustGroupID > 0 ? (ctx.CGRPs.FirstOrDefault(x => x.CustGroupID == sc.CustGroupID.Value).CustGroupName) : "";
                                item.CustGroupDesc = sc.CustGroupID.HasValue && sc.CustGroupID > 0 ? (ctx.CGRPs.Where(y => y.CustGroupID == sc.CustGroupID.Value).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault()) : "";
                                item.CustType = sc.Type;
                                item.Active = sc.Active;
                                if (sc.AssetID.HasValue)
                                    item.AssetCode = ctx.OASTs.FirstOrDefault(x => x.AssetID == sc.AssetID).AssetCode;
                                item.CouponAmount = sc.CouponAmount;
                                item.UsedCoupon = sc.UsedCoupon;
                                item.IsInclude = sc.IsInclude;
                                item.SyncDate = sc.CreatedDate.HasValue ? sc.CreatedDate : null;
                                SCM1s.Add(item);
                            }

                            gvCustData.DataSource = SCM1s;
                            gvCustData.DataBind();

                            SCM3s = objOSCM.SCM3.ToList();
                            foreach (SCM3 item in SCM3s)
                            {
                                if (item.ItemSubGroupID.HasValue)
                                {
                                    item.OITB = item.OITG.OITB;
                                }
                            }
                            gvItemGroup.DataSource = SCM3s;
                            gvItemGroup.DataBind();

                            SCM4s = objOSCM.SCM4.OrderBy(x => x.LowerLimit).ToList();
                            gvScheme.DataSource = SCM4s;
                            gvScheme.DataBind();
                            btnAddGroup.Text = "Add Group";
                            btnAddCustData.Text = "Add Cust Data";
                            btnScheme.Text = "Add Scheme";
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Scheme!',3);", true);
                            ClearAllInputs();
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtName.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void ddlMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMode.SelectedValue == "M")
        {
            ddlApplcableOn.Enabled = true;
        }
        else if (ddlMode.SelectedValue == "A")
        {
            ddlApplcableOn.Enabled = false;
            if (ddlApplcableOn.SelectedValue != "2")
            {
                SCM1s = new List<CustData>();
                gvCustData.DataSource = SCM1s;
                gvCustData.DataBind();
            }
            ddlApplcableOn.SelectedValue = "2";
        }
        else
        {
            ddlApplcableOn.Enabled = false;
            if (ddlApplcableOn.SelectedValue != "3")
            {
                SCM1s = new List<CustData>();
                gvCustData.DataSource = SCM1s;
                gvCustData.DataBind();
            }
            ddlApplcableOn.SelectedValue = "3";
        }
    }

    protected void ddlApplcableOn_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlApplcableOn.SelectedValue == "2")
        {
            lblDealer.Visible = false;
            txtDealer.Visible = false;
        }
        else
        {
            lblDealer.Visible = true;
            txtDealer.Visible = true;
        }
        SCM1s = new List<CustData>();
        gvCustData.DataSource = SCM1s;
        gvCustData.DataBind();
    }

    #endregion

    #region SCM1

    protected void btnAddCustData_Click(object sender, EventArgs e)
    {
        if (SCM1s == null)
            SCM1s = new List<CustData>();

        int LineID;

        if (!string.IsNullOrEmpty(txtDealer.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal DealerID = Decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;

                if (ctx.OCRDs.Any(x => x.CustomerID == DealerID && x.Type == 3 && x.Active))
                {
                    string DealerCode = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();

                    CustData Data = null;
                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = SCM1s[LineID];
                        Data.DealerID = DealerID;
                        Data.DealerCode = DealerCode;
                        Data.CustType = 3;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.PlantName = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.PlantID = null;
                        Data.PlantName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                    }
                    else
                    {
                        if (!SCM1s.Any(x => x.DealerID == DealerID))
                        {
                            Data = new CustData();
                            Data.DealerID = DealerID;
                            Data.DealerCode = DealerCode;
                            Data.CustType = 3;

                            SCM1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Dealer name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Decimal DecNum;
                    Data.AssetCode = txtAssetCode.Text;
                    Data.SyncDate = DateTime.Now;
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    Data.CouponAmount = Decimal.TryParse(txtCouponAmount.Text, out DecNum) ? DecNum : 0;
                    //Data.UsedCoupon = 0;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtAssetCode.Text = txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
                    txtAssetCode.Enabled = true;
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Dealer.',3);", true);
            }
        }
        else if (!string.IsNullOrEmpty(txtDistributor.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                Decimal DistID = Decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last().Trim(), out DistID) ? DistID : 0;

                if (ctx.OCRDs.Any(x => x.CustomerID == DistID && x.Type == 2 && x.Active))
                {
                    string DistCode = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Type == 2 && x.Active).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();

                    CustData Data = null;
                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = SCM1s[LineID];
                        Data.DistributorID = DistID;
                        Data.DistributorCode = DistCode;
                        Data.CustType = 2;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.PlantName = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.PlantID = null;
                        Data.PlantName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                    }
                    else
                    {
                        if (!SCM1s.Any(x => x.DistributorID == DistID))
                        {
                            Data = new CustData();
                            Data.DistributorID = DistID;
                            Data.DistributorCode = DistCode;
                            Data.CustType = 2;
                            SCM1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Distributor name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.SyncDate = DateTime.Now;
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Distributor.',3);", true);
            }
        }
        else if (!string.IsNullOrEmpty(txtCustGroup.Text) && txtCustGroup.Text.Split("#".ToArray()).Length > 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                string CustGroupName = txtCustGroup.Text.Split("#".ToArray()).First().Trim();
                if (!string.IsNullOrEmpty(CustGroupName) && ctx.CGRPs.Any(x => x.CustGroupName == CustGroupName))
                {
                    CustData Data = null;
                    string CustGroupDesc = ctx.CGRPs.Where(x => x.CustGroupName == CustGroupName).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault();

                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = SCM1s[LineID];
                        Data.CustGroupName = CustGroupName;
                        Data.CustGroupDesc = CustGroupDesc;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = null;
                        Data.PlantID = null;
                        Data.PlantName = null;
                    }
                    else
                    {
                        if (!SCM1s.Any(x => x.CustGroupName == CustGroupName))
                        {
                            Data = new CustData();
                            Data.CustGroupName = CustGroupName;
                            Data.CustGroupDesc = CustGroupDesc;
                            SCM1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Customer Group name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.SyncDate = DateTime.Now;
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Customer Group.',3);", true);
            }
        }
        else if (!string.IsNullOrEmpty(txtPlant.Text) && txtPlant.Text.Split("-".ToArray()).Length > 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int PlantID = Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) ? PlantID : 0;
                if (ctx.OPLTs.Any(x => x.PlantID == PlantID))
                {
                    var PlantName = ctx.OPLTs.FirstOrDefault(x => x.PlantID == PlantID).PlantName;

                    CustData Data = null;
                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = SCM1s[LineID];
                        Data.PlantID = PlantID;
                        Data.PlantName = PlantName;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                    }
                    else
                    {
                        if (!SCM1s.Any(x => x.PlantID == PlantID))
                        {
                            Data = new CustData();
                            Data.PlantID = PlantID;
                            Data.PlantName = PlantName;
                            SCM1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Plant name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.SyncDate = DateTime.Now;
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Plant.',3);", true);
            }
        }
        else if (!string.IsNullOrEmpty(txtRegion.Text) && txtRegion.Text.Split("-".ToArray()).Length > 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).First().Trim(), out RegionID) ? RegionID : 0;
                if (ctx.OCSTs.Any(x => x.StateID == RegionID))
                {
                    CustData Data = null;
                    var RegionName = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionID).StateName;

                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = SCM1s[LineID];
                        Data.RegionID = RegionID;
                        Data.RegionName = RegionName;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = null;
                        Data.PlantID = null;
                        Data.PlantName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                    }
                    else
                    {
                        if (!SCM1s.Any(x => x.RegionID == RegionID))
                        {
                            Data = new CustData();
                            Data.RegionID = RegionID;
                            Data.RegionName = RegionName;
                            SCM1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Region name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.SyncDate = DateTime.Now;
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Region.',3);", true);
            }
        }

        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one data.',3);", true);
            return;
        }
        gvCustData.DataSource = SCM1s;
        gvCustData.DataBind();
    }

    protected void btnCancleCustData_Click(object sender, EventArgs e)
    {
        btnAddCustData.Text = "Add Cust Data";
        txtAssetCode.Text = txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
        chkIsActive.Checked = chkIsInclude.Checked = true;
        txtAssetCode.Enabled = true;
        ViewState["CustDataID"] = null;
    }

    protected void gvCustData_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "deleteCustData")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            SCM1s.RemoveAt(LineID);

            gvCustData.DataSource = SCM1s;
            gvCustData.DataBind();
            txtAssetCode.Text = txtUsedCoupon.Text = txtCouponAmount.Text = txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtPlant.Text = txtCustGroup.Text = "";
            chkIsActive.Checked = chkIsInclude.Checked = true;
            txtAssetCode.Enabled = true;
            ViewState["CustDataID"] = null;
            btnAddCustData.Text = "Add Cust Data";
        }
        if (e.CommandName == "editCustData")
        {

            int LineID = Convert.ToInt32(e.CommandArgument);
            var objSCM1 = SCM1s[LineID];

            if (!string.IsNullOrEmpty(objSCM1.RegionName))
                txtRegion.Text = objSCM1.RegionID + " - " + objSCM1.RegionName;
            else
                txtRegion.Text = "";

            if (!string.IsNullOrEmpty(objSCM1.PlantName))
                txtPlant.Text = objSCM1.PlantID + " - " + objSCM1.PlantName;
            else
                txtPlant.Text = "";

            if (!string.IsNullOrEmpty(objSCM1.DistributorCode))
                txtDistributor.Text = objSCM1.DistributorCode + " - " + objSCM1.DistributorID;
            else
                txtDistributor.Text = "";

            if (!string.IsNullOrEmpty(objSCM1.DealerCode))
                txtDealer.Text = objSCM1.DealerCode + " - " + objSCM1.DealerID;
            else
                txtDealer.Text = "";

            if (!string.IsNullOrEmpty(objSCM1.AssetCode))
                txtAssetCode.Text = objSCM1.AssetCode;
            else
                txtAssetCode.Text = "";

            if (!string.IsNullOrEmpty(objSCM1.CustGroupName))
                txtCustGroup.Text = objSCM1.CustGroupDesc;
            else
                txtCustGroup.Text = "";

            txtAssetCode.Enabled = false;
            chkIsActive.Checked = objSCM1.Active;
            chkIsInclude.Checked = objSCM1.IsInclude;

            txtCouponAmount.Text = objSCM1.CouponAmount.HasValue ? objSCM1.CouponAmount.Value.ToString("0.00") : "0.00";
            txtUsedCoupon.Text = objSCM1.UsedCoupon.HasValue ? objSCM1.UsedCoupon.Value.ToString("0.00") : "0.00";
            ViewState["CustDataID"] = LineID;
            btnAddCustData.Text = "Update Cust Data";
        }

    }

    protected void btnCUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("RegionCode");
            missdata.Columns.Add("PlantCode");
            missdata.Columns.Add("DistributorCode");
            missdata.Columns.Add("DealerCode");
            missdata.Columns.Add("AssestCode");
            missdata.Columns.Add("CustGroupName");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;
            Decimal DecNum = 0;

            if (flCUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flCUpload.PostedFile.FileName));
                flCUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flCUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String RegionCode = item["RegionCode"].ToString().Trim();
                                String PlantCode = item["PlantCode"].ToString().Trim();
                                String DistributorCode = item["DistributorCode"].ToString().Trim();
                                String DealerCode = item["DealerCode"].ToString().Trim();
                                String CoupenAmount = item["CoupenAmount"].ToString().Trim();
                                String IsInclude = item["IsInclude"].ToString().Trim();
                                string CustGroupName = item["CustGroupName"].ToString().Trim();

                                if (string.IsNullOrEmpty(RegionCode) && string.IsNullOrEmpty(PlantCode) && string.IsNullOrEmpty(DistributorCode) && string.IsNullOrEmpty(DealerCode) && string.IsNullOrEmpty(CustGroupName))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                if (!string.IsNullOrEmpty(DealerCode) && !ctx.OCRDs.Any(x => x.CustomerCode == DealerCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Dealer Code: " + DealerCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(DistributorCode) && !ctx.OCRDs.Any(x => x.CustomerCode == DistributorCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Distributor Code: " + DistributorCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(PlantCode) && !ctx.OPLTs.Any(x => x.PlantCode == PlantCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Plant Code: " + PlantCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(RegionCode) && !ctx.OCSTs.Any(x => x.StateDesc == RegionCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Region Code: " + RegionCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(CustGroupName) && !ctx.CGRPs.Any(x => x.CustGroupName == CustGroupName.Replace("#", "")))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Customer Group: " + CustGroupName + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(IsInclude) && !(IsInclude.ToLower() == "true" || IsInclude.ToLower() == "false"))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Plesase enter data properly in IsInclude column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(IsInclude))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["RegionCode"] = RegionCode;
                                    missdr["PlantCode"] = PlantCode;
                                    missdr["DistributorCode"] = DistributorCode;
                                    missdr["DealerCode"] = DealerCode;
                                    missdr["CustGroupName"] = CustGroupName;
                                    missdr["ErrorMsg"] = "Please enter data in IsInclude column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }

                            if (flag)
                            {
                                try
                                {
                                    if (SCM1s == null)
                                        SCM1s = new List<CustData>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {
                                        String RegionCode = item["RegionCode"].ToString().Trim();
                                        String PlantCode = item["PlantCode"].ToString().Trim();
                                        String DistributorCode = item["DistributorCode"].ToString().Trim();
                                        String DealerCode = item["DealerCode"].ToString().Trim();
                                        String CustGroupName = item["CustGroupName"].ToString().Trim();
                                        String AssetCode = item["AssetCode"].ToString().Trim();
                                        String CoupenAmount = item["CoupenAmount"].ToString().Trim();
                                        Boolean IsInclude = Convert.ToBoolean(item["IsInclude"].ToString().Trim());

                                        if (!string.IsNullOrEmpty(RegionCode) || !string.IsNullOrEmpty(PlantCode) || !string.IsNullOrEmpty(DistributorCode) || !string.IsNullOrEmpty(DealerCode) || !string.IsNullOrEmpty(CustGroupName))
                                        {
                                            CustData Data = new CustData();

                                            if (!string.IsNullOrEmpty(DealerCode))
                                            {
                                                var objDealer = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DealerCode);

                                                Data.DealerID = objDealer.CustomerID;
                                                Data.DealerCode = objDealer.CustomerCode + " # " + objDealer.CustomerName;
                                                Data.CustType = objDealer.Type;
                                                Data.DistributorID = null;
                                                Data.DistributorCode = null;
                                                Data.PlantName = null;
                                                Data.RegionID = null;
                                                Data.RegionName = null;
                                                Data.PlantID = null;
                                                Data.PlantName = null;
                                                Data.CustGroupName = null;
                                                Data.CustGroupDesc = null;
                                                Data.CouponAmount = Decimal.TryParse(CoupenAmount, out DecNum) ? DecNum : 0;
                                                Data.AssetCode = AssetCode;
                                                Data.SyncDate = DateTime.Now;
                                                SCM1s.Add(Data);
                                            }
                                            else if (!string.IsNullOrEmpty(DistributorCode))
                                            {
                                                var objDistributor = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == DistributorCode);

                                                Data.DistributorID = objDistributor.CustomerID;
                                                Data.DistributorCode = objDistributor.CustomerCode + " # " + objDistributor.CustomerName;
                                                Data.CustType = objDistributor.Type;
                                                Data.DealerID = null;
                                                Data.DealerCode = null;
                                                Data.PlantName = null;
                                                Data.RegionID = null;
                                                Data.RegionName = null;
                                                Data.PlantID = null;
                                                Data.PlantName = null;
                                                Data.CustGroupName = null;
                                                Data.CustGroupDesc = null;
                                                Data.CouponAmount = 0;
                                                Data.SyncDate = DateTime.Now;
                                                SCM1s.Add(Data);
                                            }
                                            else if (!string.IsNullOrEmpty(PlantCode))
                                            {
                                                var objOPLT = ctx.OPLTs.FirstOrDefault(x => x.PlantCode == PlantCode);

                                                Data.PlantID = objOPLT.PlantID;
                                                Data.PlantName = objOPLT.PlantName;
                                                Data.DealerID = null;
                                                Data.DealerCode = null;
                                                Data.DistributorID = null;
                                                Data.DistributorCode = null;
                                                Data.CustType = null;
                                                Data.RegionID = null;
                                                Data.RegionName = null;
                                                Data.CustGroupName = null;
                                                Data.CustGroupDesc = null;
                                                Data.CouponAmount = 0;
                                                Data.SyncDate = DateTime.Now;
                                                SCM1s.Add(Data);
                                            }
                                            else if (!string.IsNullOrEmpty(RegionCode))
                                            {
                                                var objOCST = ctx.OCSTs.FirstOrDefault(x => x.StateDesc == RegionCode);

                                                Data.RegionID = objOCST.StateID;
                                                Data.RegionName = objOCST.StateName;
                                                Data.DealerID = null;
                                                Data.DealerCode = null;
                                                Data.DistributorID = null;
                                                Data.DistributorCode = null;
                                                Data.CustType = null;
                                                Data.PlantID = null;
                                                Data.PlantName = null;
                                                Data.CustGroupName = null;
                                                Data.CustGroupDesc = null;
                                                Data.CouponAmount = 0;
                                                Data.SyncDate = DateTime.Now;
                                                SCM1s.Add(Data);
                                            }
                                            else if (!string.IsNullOrEmpty(CustGroupName))
                                            {
                                                var objCGRP = ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == CustGroupName.Replace("#", ""));

                                                Data.RegionID = null;
                                                Data.RegionName = null;
                                                Data.DealerID = null;
                                                Data.DealerCode = null;
                                                Data.DistributorID = null;
                                                Data.DistributorCode = null;
                                                Data.CustType = null;
                                                Data.PlantID = null;
                                                Data.PlantName = null;
                                                Data.CustGroupName = objCGRP.CustGroupName;
                                                Data.CustGroupDesc = objCGRP.CustGroupName + " # " + objCGRP.CustGroupDesc;
                                                Data.CouponAmount = 0;
                                                Data.SyncDate = DateTime.Now;
                                                SCM1s.Add(Data);
                                            }
                                            Data.Active = true;
                                            Data.IsInclude = IsInclude;
                                        }
                                    }
                                    gvMissdata.Visible = false;
                                    gvCustData.DataSource = SCM1s;
                                    gvCustData.DataBind();
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

                            }
                            else
                            {
                                gvMissdata.Visible = true;
                                gvMissdata.DataSource = missdata;
                                gvMissdata.DataBind();
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region SCM3

    protected void btnCancelGroup_Click(object sender, EventArgs e)
    {
        btnAddGroup.Text = "Add Group";
        chkInclude.Checked = true;
        txtDivision.Text = txtGroup.Text = txtSubGroup.Text = txtMatName.Text = "";
        ViewState["LineID"] = null;
    }

    protected void btnAddGroup_Click(object sender, EventArgs e)
    {
        if (SCM3s == null)
            SCM3s = new List<SCM3>();

        int LineID;
        int IntNum;

        if (!String.IsNullOrEmpty(txtMatName.Text))
        {
            var text = txtMatName.Text.Split("-".ToArray());
            if (text.Length > 1)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    IntNum = Convert.ToInt32(text.First().Trim());
                    var objOITM = ctx.OITMs.Include("OITB").Include("OITG").FirstOrDefault(x => x.ItemID == IntNum);
                    if (objOITM != null)
                    {
                        SCM3 Data = null;
                        if (ViewState["LineID"] != null && Int32.TryParse(ViewState["LineID"].ToString(), out LineID))
                            Data = SCM3s[LineID];
                        else
                        {
                            if (!SCM3s.Any(x => x.ItemID == IntNum))
                            {
                                Data = new SCM3();
                                SCM3s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same item name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.IsInclude = chkInclude.Checked;
                        Data.ItemGroupID = null; // objOITM.GroupID;
                        Data.ItemSubGroupID = null; // objOITM.SubGroupID;
                        Data.ItemID = objOITM.ItemID;

                        if (!String.IsNullOrEmpty(txtDivision.Text))
                        {
                            var div = txtDivision.Text.Split("-".ToArray());
                            if (div.Length > 1)
                                Data.DivisionID = Convert.ToInt32(div.First().Trim());
                            else
                                Data.DivisionID = null;
                        }
                        else
                            Data.DivisionID = null;

                        Data.OITB = objOITM.OITB;
                        Data.OITG = objOITM.OITG;
                        Data.OITM = objOITM;

                        chkInclude.Checked = true;
                        txtGroup.Text = txtSubGroup.Text = txtMatName.Text = txtDivision.Text = "";
                        ViewState["LineID"] = null;
                        btnAddGroup.Text = "Add Group";
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
                }
            }
            else
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
        }
        else if (!String.IsNullOrEmpty(txtSubGroup.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var text = txtSubGroup.Text.Split("-".ToArray());
                if (text.Length > 1)
                {

                    IntNum = Convert.ToInt32(text.First().Trim());
                    var objOITG = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupID == IntNum);
                    if (objOITG != null)
                    {
                        SCM3 Data = null;
                        if (ViewState["LineID"] != null && Int32.TryParse(ViewState["LineID"].ToString(), out LineID))
                            Data = SCM3s[LineID];
                        else
                        {
                            if (!SCM3s.Any(x => x.ItemSubGroupID == IntNum))
                            {
                                Data = new SCM3();
                                SCM3s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same sub group name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.IsInclude = chkInclude.Checked;
                        Data.ItemGroupID = null; // objOITG.ItemGroupID;
                        Data.ItemSubGroupID = objOITG.ItemSubGroupID;
                        Data.ItemID = null;
                        if (!String.IsNullOrEmpty(txtDivision.Text))
                        {
                            var div = txtDivision.Text.Split("-".ToArray());
                            if (div.Length > 1)
                                Data.DivisionID = Convert.ToInt32(div.First().Trim());
                            else
                                Data.DivisionID = null;
                        }
                        else
                            Data.DivisionID = null;

                        Data.OITB = objOITG.OITB;
                        Data.OITG = objOITG;
                        Data.OITM = null;
                        chkInclude.Checked = true;
                        txtGroup.Text = txtSubGroup.Text = txtGroup.Text = txtDivision.Text = "";
                        ViewState["LineID"] = null;
                        btnAddGroup.Text = "Add Group";
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
            }
        }
        else if (!String.IsNullOrEmpty(txtGroup.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var text = txtGroup.Text.Split("-".ToArray());
                if (text.Length > 1)
                {
                    IntNum = Convert.ToInt32(text.First().Trim());
                    var objOITB = ctx.OITBs.FirstOrDefault(x => x.ItemGroupID == IntNum);
                    if (objOITB != null)
                    {
                        SCM3 Data = null;
                        if (ViewState["LineID"] != null && Int32.TryParse(ViewState["LineID"].ToString(), out LineID))
                        {
                            Data = SCM3s[LineID];
                        }
                        else
                        {
                            if (!SCM3s.Any(x => x.ItemGroupID == IntNum))
                            {
                                Data = new SCM3();
                                SCM3s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same group name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.IsInclude = chkInclude.Checked;
                        Data.ItemGroupID = objOITB.ItemGroupID;
                        Data.ItemSubGroupID = null;
                        Data.ItemID = null;
                        if (!String.IsNullOrEmpty(txtDivision.Text))
                        {
                            var div = txtDivision.Text.Split("-".ToArray());
                            if (div.Length > 1)
                                Data.DivisionID = Convert.ToInt32(div.First().Trim());
                            else
                                Data.DivisionID = null;
                        }
                        else
                            Data.DivisionID = null;
                        Data.OITB = objOITB;
                        Data.OITG = null;
                        Data.OITM = null;

                        chkInclude.Checked = true;
                        txtGroup.Text = txtSubGroup.Text = txtMatName.Text = txtDivision.Text = "";
                        ViewState["LineID"] = null;
                        btnAddGroup.Text = "Add Group";
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
            }
        }
        else if (!String.IsNullOrEmpty(txtDivision.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var text = txtDivision.Text.Split("-".ToArray());
                if (text.Length > 1)
                {
                    IntNum = Convert.ToInt32(text.First().Trim());
                    var objOITB = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == IntNum);
                    if (objOITB != null)
                    {
                        SCM3 Data = null;
                        if (ViewState["LineID"] != null && Int32.TryParse(ViewState["LineID"].ToString(), out LineID))
                        {
                            Data = SCM3s[LineID];
                        }
                        else
                        {
                            if (!SCM3s.Any(x => x.DivisionID == IntNum))
                            {
                                Data = new SCM3();

                                SCM3s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same group name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.IsInclude = chkInclude.Checked;
                        Data.ItemGroupID = null;
                        Data.ItemSubGroupID = null;
                        Data.ItemID = null;
                        Data.DivisionID = Convert.ToInt32(text.First().Trim());
                        Data.OITG = null;
                        Data.OITM = null;

                        chkInclude.Checked = true;
                        txtGroup.Text = txtSubGroup.Text = txtMatName.Text = txtDivision.Text = "";
                        ViewState["LineID"] = null;
                        btnAddGroup.Text = "Add Group";
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper item.',3);", true);
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one data.',3);", true);
            return;
        }
        gvItemGroup.DataSource = SCM3s;
        gvItemGroup.DataBind();
    }

    protected void gvItemGroup_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "deleteItemGroup")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            SCM3s.RemoveAt(LineID);

            gvItemGroup.DataSource = SCM3s;
            gvItemGroup.DataBind();

            chkInclude.Checked = true;
            txtGroup.Text = txtSubGroup.Text = txtMatName.Text = txtDivision.Text = "";
            ViewState["LineID"] = null;
            btnAddGroup.Text = "Add Group";
        }
        if (e.CommandName == "editItemGroup")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            var objSCM3 = SCM3s[LineID];

            if (objSCM3.OITG != null)
                txtSubGroup.Text = objSCM3.OITG.ItemSubGroupID + " - " + objSCM3.OITG.ItemSubGroupName;
            else
                txtSubGroup.Text = "";

            if (objSCM3.OITB != null)
                txtGroup.Text = objSCM3.OITB.ItemGroupID + " - " + objSCM3.OITB.ItemGroupName;
            else
                txtGroup.Text = "";

            if (objSCM3.OITM != null)
                txtMatName.Text = objSCM3.OITM.ItemID + " - " + objSCM3.OITM.ItemName;
            else
                txtMatName.Text = "";

            if (objSCM3.DivisionID.HasValue)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {

                    ODIV objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objSCM3.DivisionID.Value);
                    txtDivision.Text = objODIV.DivisionlID.ToString() + " - " + objODIV.DivisionName;
                }
            }
            else
                txtDivision.Text = "";

            chkInclude.Checked = objSCM3.IsInclude;
            ViewState["LineID"] = LineID;
            btnAddGroup.Text = "Update Group";
        }
    }

    protected void gvItemGroup_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int id = 0;
                Label lbldivID = (Label)e.Row.FindControl("lbldivID");
                if (lbldivID != null && Int32.TryParse(lbldivID.Text, out id) && id > 0)
                {
                    Label lblName = (Label)e.Row.FindControl("lbldivName");
                    lblName.Text = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == id).DivisionName;
                }
            }
        }
    }

    protected void btnItemUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("ItemGroupName");
            missdata.Columns.Add("ItemSubGroupName");
            missdata.Columns.Add("ItemCode");
            missdata.Columns.Add("DivisionName");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flItemUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flItemUpload.PostedFile.FileName));
                flItemUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flItemUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String ItemGroupName = item["ItemGroupName"].ToString().Trim();
                                String ItemSubGroupName = item["ItemSubGroupName"].ToString().Trim();
                                String ItemCode = item["ItemCode"].ToString().Trim();
                                String DivisionName = item["DivisionName"].ToString().Trim();
                                String IsInclude = item["IsInclude"].ToString().Trim();

                                if (string.IsNullOrEmpty(ItemGroupName) && string.IsNullOrEmpty(ItemSubGroupName) && string.IsNullOrEmpty(ItemCode) && string.IsNullOrEmpty(DivisionName))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                if (!string.IsNullOrEmpty(ItemGroupName) && !ctx.OITBs.Any(x => x.ItemGroupName == ItemGroupName))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "ItemGroup Name: " + ItemGroupName + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(ItemSubGroupName) && !ctx.OITGs.Any(x => x.ItemSubGroupName == ItemSubGroupName))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "ItemSubGroup Name: " + ItemSubGroupName + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(ItemCode) && !ctx.OITMs.Any(x => x.ItemCode == ItemCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "Item Code: " + ItemCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(DivisionName) && !ctx.ODIVs.Any(x => x.DivisionName == DivisionName))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "Division Name: " + DivisionName + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(IsInclude) && !(IsInclude.ToLower() == "true" || IsInclude.ToLower() == "false"))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "Plesase enter data properly in IsInclude column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(IsInclude))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["ItemGroupName"] = ItemGroupName;
                                    missdr["ItemSubGroupName"] = ItemSubGroupName;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["DivisionName"] = DivisionName;
                                    missdr["ErrorMsg"] = "Please enter data in IsInclude column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                            }

                            if (flag)
                            {
                                try
                                {
                                    if (SCM3s == null)
                                        SCM3s = new List<SCM3>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {
                                        String ItemGroupName = item["ItemGroupName"].ToString().Trim();
                                        String ItemSubGroupName = item["ItemSubGroupName"].ToString().Trim();
                                        String ItemCode = item["ItemCode"].ToString().Trim();
                                        String DivisionName = item["DivisionName"].ToString().Trim();
                                        Boolean IsInclude = Convert.ToBoolean(item["IsInclude"].ToString().Trim());

                                        if (!string.IsNullOrEmpty(ItemGroupName) || !string.IsNullOrEmpty(ItemSubGroupName) || !string.IsNullOrEmpty(ItemCode) || !string.IsNullOrEmpty(DivisionName))
                                        {

                                            SCM3 Data = new SCM3();
                                            if (!string.IsNullOrEmpty(ItemCode))
                                            {
                                                var objOITM = ctx.OITMs.Include("OITB").Include("OITG").FirstOrDefault(x => x.ItemCode == ItemCode);

                                                Data.ItemID = objOITM.ItemID;
                                                Data.ItemGroupID = null;
                                                Data.ItemSubGroupID = null;
                                                if (!string.IsNullOrEmpty(DivisionName))
                                                    Data.DivisionID = ctx.ODIVs.FirstOrDefault(x => x.DivisionName == DivisionName).DivisionlID;
                                                else
                                                    Data.DivisionID = null;
                                                Data.OITM = objOITM;
                                                Data.OITB = objOITM.OITB;
                                                Data.OITG = objOITM.OITG;
                                                SCM3s.Add(Data);
                                            }
                                            else if (!string.IsNullOrEmpty(ItemSubGroupName))
                                            {
                                                var objOITG = ctx.OITGs.FirstOrDefault(x => x.ItemSubGroupName == ItemSubGroupName);

                                                Data.ItemSubGroupID = objOITG.ItemSubGroupID;
                                                Data.ItemGroupID = null;
                                                Data.ItemID = null;
                                                if (!string.IsNullOrEmpty(DivisionName))
                                                    Data.DivisionID = ctx.ODIVs.FirstOrDefault(x => x.DivisionName == DivisionName).DivisionlID;
                                                else
                                                    Data.DivisionID = null;
                                                Data.OITB = objOITG.OITB;
                                                Data.OITG = objOITG;
                                                Data.OITM = null;
                                                SCM3s.Add(Data);
                                            }

                                            else if (!string.IsNullOrEmpty(ItemGroupName))
                                            {
                                                var objOITB = ctx.OITBs.FirstOrDefault(x => x.ItemGroupName == ItemGroupName);

                                                Data.ItemGroupID = objOITB.ItemGroupID;
                                                Data.ItemSubGroupID = null;
                                                Data.ItemID = null;
                                                if (!string.IsNullOrEmpty(DivisionName))
                                                    Data.DivisionID = ctx.ODIVs.FirstOrDefault(x => x.DivisionName == DivisionName).DivisionlID;
                                                else
                                                    Data.DivisionID = null;
                                                Data.OITB = objOITB;
                                                Data.OITG = null;
                                                Data.OITM = null;
                                                SCM3s.Add(Data);
                                            }

                                            else if (!string.IsNullOrEmpty(DivisionName))
                                            {
                                                if (!string.IsNullOrEmpty(DivisionName))
                                                    Data.DivisionID = ctx.ODIVs.FirstOrDefault(x => x.DivisionName == DivisionName).DivisionlID;
                                                else
                                                    Data.DivisionID = null;
                                                Data.ItemGroupID = null;
                                                Data.ItemSubGroupID = null;
                                                Data.ItemID = null;

                                                Data.OITG = null;
                                                Data.OITM = null;
                                                SCM3s.Add(Data);
                                            }
                                            Data.SyncStatus = false;
                                            Data.IsInclude = IsInclude;
                                        }
                                    }
                                    gvitemMisdata.Visible = false;
                                    gvItemGroup.DataSource = SCM3s;
                                    gvItemGroup.DataBind();
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

                            }
                            else
                            {
                                gvitemMisdata.Visible = true;
                                gvitemMisdata.DataSource = missdata;
                                gvitemMisdata.DataBind();
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region SCM4

    protected void btnSchemeClick(object sender, EventArgs e)
    {
        Decimal DecNum;
        int LineID;
        if (SCM4s == null)
            SCM4s = new List<SCM4>();
        SCM4 objSCM4 = null;
        using (DDMSEntities ctx = new DDMSEntities())
        {

            if ((String.IsNullOrEmpty(txtLowerLimit.Text) && String.IsNullOrEmpty(txtHigherLimit.Text)) || (txtLowerLimit.Text == "0" && txtHigherLimit.Text == "0"))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter atleast one limit!',3);", true);
                return;
            }
            if (ddlMode.SelectedValue == "S")
            {
                if (rdbper.Checked && (Decimal.TryParse(txtPrice.Text, out DecNum) ? DecNum : 0) <= 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('With Selecting Discount Type % then QPS Master Rate should be compulsory.!',3);", true);
                    return;
                }
                if (rdbdis.Checked && (Decimal.TryParse(txtPrice.Text, out DecNum) ? DecNum : 0) > 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('With Selecting Discount Type ₹ then QPS Master Rate should be 0.!',3);", true);
                    return;
                }
            }
            if (ddlIsPair.SelectedValue == "-1")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Is Pair?',3);", true);
                return;
            }
            if (ViewState["GSchemeID"] != null && Int32.TryParse(ViewState["GSchemeID"].ToString(), out LineID))
            {
                objSCM4 = SCM4s[LineID];
            }
            else
            {
                objSCM4 = new SCM4();
                SCM4s.Add(objSCM4);
            }
            objSCM4.LowerLimit = Decimal.TryParse(txtLowerLimit.Text, out DecNum) ? DecNum : 0;
            objSCM4.HigherLimit = Decimal.TryParse(txtHigherLimit.Text, out DecNum) ? DecNum : 0;
            objSCM4.IsPair = Convert.ToBoolean(ddlIsPair.SelectedValue.ToString());
            objSCM4.UnitID = null;
            var Data = txtMat.Text.Split("-".ToArray());

            if (Data.Length > 1)
            {
                objSCM4.ItemID = Convert.ToInt32(Data.First().Trim());
                var objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemID == objSCM4.ItemID);
                if (objOITM != null)
                {
                    objSCM4.OITM = objOITM;
                    objSCM4.ItemID = objOITM.ItemID;
                    objSCM4.UnitID = Convert.ToInt32(ddlUnit.SelectedValue);
                }
                else
                {
                    objSCM4.ItemSubGroupID = null;
                    objSCM4.ItemGroupID = null;
                    objSCM4.ItemID = null;
                    objSCM4.OITM = null;
                }
            }
            else
            {
                objSCM4.ItemSubGroupID = null;
                objSCM4.ItemGroupID = null;
                objSCM4.ItemID = null;
                objSCM4.OITM = null;
            }

            objSCM4.Quantity = Decimal.TryParse(txtQuantity.Text, out DecNum) ? DecNum : 0;
            objSCM4.Price = Decimal.TryParse(txtPrice.Text, out DecNum) ? DecNum : 0;
            objSCM4.BasedOn = Convert.ToInt32(ddlBasedOn.SelectedValue);
            objSCM4.Discount = Decimal.TryParse(txtDiscount.Text, out DecNum) ? DecNum : 0;

            objSCM4.CompanyDisc = Decimal.TryParse(txtCompanyDisc.Text, out DecNum) ? DecNum : 0;
            objSCM4.DistributorDisc = Decimal.TryParse(txtDistributorDisc.Text, out DecNum) ? DecNum : 0;

            objSCM4.Occurrence = Decimal.TryParse(txtOccurrence.Text, out DecNum) ? DecNum : 0;
            objSCM4.DiscountType = rdbper.Checked ? "P" : "A";


            objSCM4.OUNT = ctx.OUNTs.FirstOrDefault(x => x.UnitID == objSCM4.UnitID);
            ClearMapping();
            btnScheme.Text = "Add Scheme";
            gvScheme.DataSource = SCM4s;
            gvScheme.DataBind();
        }
    }

    protected void btnCancelMapping_Click(object sender, EventArgs e)
    {
        ClearMapping();
    }

    protected void gvScheme_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditScheme")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ViewState["GSchemeID"] = LineID;
            txtLowerLimit.Text = SCM4s[LineID].LowerLimit.ToString("0.00");
            txtHigherLimit.Text = SCM4s[LineID].HigherLimit.ToString("0.00");

            if (SCM4s[LineID].ItemID != null)
            {
                txtMat.Text = SCM4s[LineID].ItemID.ToString() + " - " + SCM4s[LineID].OITM.ItemName;
                txtMat_TextChanged(null, null);
            }
            else
                txtMat.Text = "";

            if (SCM4s[LineID].IsPair != null)
            {
                ddlIsPair.SelectedValue = SCM4s[LineID].IsPair.ToString().ToLower();
            }
            else
                ddlIsPair.SelectedValue = "0";


            if (SCM4s[LineID].UnitID != null)
                ddlUnit.SelectedValue = SCM4s[LineID].UnitID.ToString();
            else
                ddlUnit.Items.Clear();
            if (SCM4s[LineID].Quantity > 0)
                txtQuantity.Text = SCM4s[LineID].Quantity.ToString("0");
            else
                txtQuantity.Text = "0";
            if (SCM4s[LineID].Price > 0)
                txtPrice.Text = SCM4s[LineID].Price.ToString("0.00");
            else
                txtPrice.Text = "0";
            ddlBasedOn.SelectedValue = SCM4s[LineID].BasedOn.ToString();
            if (SCM4s[LineID].Occurrence.HasValue)
                txtOccurrence.Text = SCM4s[LineID].Occurrence.Value.ToString("0.00");
            else
                txtOccurrence.Text = "0";
            if (SCM4s[LineID].Discount > 0)
                txtDiscount.Text = SCM4s[LineID].Discount.ToString("0.00");
            else
                txtDiscount.Text = "0";

            if (SCM4s[LineID].CompanyDisc != null)
                txtCompanyDisc.Text = SCM4s[LineID].CompanyDisc.Value.ToString("0.00");
            else
                txtCompanyDisc.Text = "0.00";
            if (SCM4s[LineID].DistributorDisc != null)
                txtDistributorDisc.Text = SCM4s[LineID].DistributorDisc.Value.ToString("0.00");
            else
                txtDistributorDisc.Text = "0.00";
            if (SCM4s[LineID].DiscountType.Trim().ToUpper() == "P")
            {
                rdbper.Checked = true;
                rdbdis.Checked = false;
                if (ddlMode.SelectedValue == "S")
                    txtPrice.Enabled = true;
            }
            else
            {
                rdbdis.Checked = true;
                rdbper.Checked = false;
                if (ddlMode.SelectedValue == "S")
                    txtPrice.Enabled = false;
            }
            btnScheme.Text = "Update Mapping";
        }
        if (e.CommandName == "DeleteScheme")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            SCM4s.RemoveAt(LineID);

            gvScheme.DataSource = SCM4s;
            gvScheme.DataBind();
            ClearMapping();
        }
    }

    protected void txtMat_TextChanged(object sender, EventArgs e)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            int ItemID = 0;
            Int32.TryParse(txtMat.Text.Split("-".ToArray()).First().Trim(), out ItemID);
            if (ctx.ITM5.Any(x => x.PurchaseItemID == ItemID && x.IsActive == true))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This item is exist in Ctn. v/s Pcs. Item Code Mapping!',3);", true);
            }
            var objUnit = ctx.ITM1.Include("OUNT").Where(x => x.ItemID == ItemID).Select(x => new { x.OUNT.UnitName, x.OUNT.UnitID }).ToList();
            ddlUnit.DataTextField = "UnitName";
            ddlUnit.DataValueField = "UnitID";
            ddlUnit.DataSource = objUnit;
            ddlUnit.DataBind();
        }
    }

    protected void btnMappingUpload_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable missdata = new DataTable();
            missdata.Columns.Add("Lowerlimit");
            missdata.Columns.Add("Higherlimit");
            missdata.Columns.Add("Occurence");
            missdata.Columns.Add("BaseOn");
            missdata.Columns.Add("CompanyDisc");
            missdata.Columns.Add("CustomerDisc");
            missdata.Columns.Add("DiscInPer_Rs");
            missdata.Columns.Add("Quantity");
            missdata.Columns.Add("Price");
            missdata.Columns.Add("ItemCode");
            missdata.Columns.Add("IsPair");
            missdata.Columns.Add("ErrorMsg");

            bool flag = true;

            if (flIMappingUpload.HasFile)
            {
                if (!System.IO.Directory.Exists(Server.MapPath("~/Document/UploadedFiles/")))
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Document/UploadedFiles/"));
                string fileName = Path.Combine(Server.MapPath("~/Document/UploadedFiles"), Guid.NewGuid().ToString("N") + Path.GetExtension(flIMappingUpload.PostedFile.FileName));
                flIMappingUpload.PostedFile.SaveAs(fileName);
                string ext = Path.GetExtension(flIMappingUpload.PostedFile.FileName);
                if (ext.ToLower() == ".csv")
                {
                    DataTable dtPOH = new DataTable();
                    try
                    {
                        TransferCSVToTable(fileName, dtPOH);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Validation Message. please check data in your file.',3);", true);
                        return;
                    }

                    if (dtPOH != null && dtPOH.Rows != null && dtPOH.Rows.Count > 0)
                    {
                        gvProductMappingMissData.DataSource = null;
                        using (DDMSEntities ctx = new DDMSEntities())
                        {
                            foreach (DataRow item in dtPOH.Rows)
                            {
                                String Lowerlimit = item["Lowerlimit"].ToString().Trim();
                                String Higherlimit = item["Higherlimit"].ToString().Trim();
                                String Occurence = item["Occurence"].ToString().Trim();
                                String BaseOn = item["BaseOn"].ToString().Trim();
                                String CompanyDisc = item["CompanyDisc"].ToString().Trim();
                                String CustomerDisc = item["CustomerDisc"].ToString().Trim();
                                String DiscInPerRs = item["DiscInPer_Rs"].ToString().Trim();
                                String Quantity = item["Quantity"].ToString().Trim();
                                String Price = item["Price"].ToString().Trim();
                                String ItemCode = item["ItemCode"].ToString().Trim();
                                String IsPair = item["IsPair"].ToString().Trim();

                                Decimal PriceDec = Decimal.TryParse(item["Price"].ToString().Trim(), out PriceDec) ? PriceDec : 0;
                                Decimal LowerlimitD = Decimal.TryParse(item["Lowerlimit"].ToString().Trim(), out LowerlimitD) ? LowerlimitD : 0;
                                Decimal HigherlimitD = Decimal.TryParse(item["Higherlimit"].ToString().Trim(), out HigherlimitD) ? HigherlimitD : 0;

                                if (string.IsNullOrEmpty(Lowerlimit) && string.IsNullOrEmpty(Higherlimit) && string.IsNullOrEmpty(Occurence) && string.IsNullOrEmpty(BaseOn) &&
                                    string.IsNullOrEmpty(CompanyDisc) && string.IsNullOrEmpty(CustomerDisc) && string.IsNullOrEmpty(DiscInPerRs) &&
                                    string.IsNullOrEmpty(Quantity) && string.IsNullOrEmpty(Price) && string.IsNullOrEmpty(ItemCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Blank row found please remove blank row.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                else if (string.IsNullOrEmpty(Lowerlimit) && string.IsNullOrEmpty(Higherlimit))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Plesase Enter atleast one limit.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                else if (LowerlimitD <= 0 && HigherlimitD <= 0)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Plesase Enter atleast one limit.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }

                                else if ((LowerlimitD > 0 && HigherlimitD > 0) && LowerlimitD > HigherlimitD)
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Plesase Enter Higherlimit more than Lowerlimit.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(BaseOn) || !(BaseOn.ToLower() == "gross amount" || BaseOn.ToLower() == "purchase qty" || BaseOn.ToLower() == "unit"))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Plesase enter data properly in BaseOn column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (!string.IsNullOrEmpty(ItemCode) && !ctx.OITMs.Any(x => x.ItemCode == ItemCode))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "ItemCode : " + ItemCode + " does not exist.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (string.IsNullOrEmpty(DiscInPerRs) || !(DiscInPerRs.Trim().ToLower() == "a" || DiscInPerRs.Trim().ToLower() == "p"))
                                {
                                    DataRow missdr = missdata.NewRow();
                                    missdr["Lowerlimit"] = Lowerlimit;
                                    missdr["Higherlimit"] = Higherlimit;
                                    missdr["Occurence"] = Occurence;
                                    missdr["BaseOn"] = BaseOn;
                                    missdr["CompanyDisc"] = CompanyDisc;
                                    missdr["CustomerDisc"] = CustomerDisc;
                                    missdr["DiscInPer_Rs"] = DiscInPerRs;
                                    missdr["Quantity"] = Quantity;
                                    missdr["Price"] = Price;
                                    missdr["ItemCode"] = ItemCode;
                                    missdr["IsPair"] = IsPair;
                                    missdr["ErrorMsg"] = "Plesase enter data properly in DiscInPer_Rs column.";
                                    missdata.Rows.Add(missdr);
                                    flag = false;
                                }
                                else if (ddlMode.SelectedValue == "S")
                                {
                                    if (DiscInPerRs.ToLower() == "p" && PriceDec <= 0)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Lowerlimit"] = Lowerlimit;
                                        missdr["Higherlimit"] = Higherlimit;
                                        missdr["Occurence"] = Occurence;
                                        missdr["BaseOn"] = BaseOn;
                                        missdr["CompanyDisc"] = CompanyDisc;
                                        missdr["CustomerDisc"] = CustomerDisc;
                                        missdr["DiscInPer_Rs"] = DiscInPerRs;
                                        missdr["Quantity"] = Quantity;
                                        missdr["Price"] = Price;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["IsPair"] = IsPair;
                                        missdr["ErrorMsg"] = "With Selecting Discount Type '%' then QPS Master Rate should be compulsory.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                    else if (DiscInPerRs.ToLower() == "a" && PriceDec > 0)
                                    {
                                        DataRow missdr = missdata.NewRow();
                                        missdr["Lowerlimit"] = Lowerlimit;
                                        missdr["Higherlimit"] = Higherlimit;
                                        missdr["Occurence"] = Occurence;
                                        missdr["BaseOn"] = BaseOn;
                                        missdr["CompanyDisc"] = CompanyDisc;
                                        missdr["CustomerDisc"] = CustomerDisc;
                                        missdr["DiscInPer_Rs"] = DiscInPerRs;
                                        missdr["Quantity"] = Quantity;
                                        missdr["Price"] = Price;
                                        missdr["ItemCode"] = ItemCode;
                                        missdr["IsPair"] = IsPair;
                                        missdr["ErrorMsg"] = "With Selecting Discount Type '₹' then QPS Master Rate should be 0.";
                                        missdata.Rows.Add(missdr);
                                        flag = false;
                                    }
                                }
                            }

                            if (flag)
                            {
                                try
                                {
                                    if (SCM4s == null)
                                        SCM4s = new List<SCM4>();

                                    foreach (DataRow item in dtPOH.Rows)
                                    {
                                        Decimal Lowerlimit = Decimal.TryParse(item["Lowerlimit"].ToString().Trim(), out Lowerlimit) ? Lowerlimit : 0;
                                        Decimal Higherlimit = Decimal.TryParse(item["Higherlimit"].ToString().Trim(), out Higherlimit) ? Higherlimit : 0;
                                        Decimal Occurence = Decimal.TryParse(item["Occurence"].ToString().Trim(), out Occurence) ? Occurence : 0;
                                        String BaseOn = item["BaseOn"].ToString().Trim();
                                        Decimal CompanyDisc = Decimal.TryParse(item["CompanyDisc"].ToString().Trim(), out CompanyDisc) ? CompanyDisc : 0;
                                        Decimal CustomerDisc = Decimal.TryParse(item["CustomerDisc"].ToString().Trim(), out CustomerDisc) ? CustomerDisc : 0;
                                        String DiscInPerRs = item["DiscInPer_Rs"].ToString().Trim();
                                        Decimal Quantity = Decimal.TryParse(item["Quantity"].ToString().Trim(), out Quantity) ? Quantity : 0;
                                        Decimal Price = Decimal.TryParse(item["Price"].ToString().Trim(), out Price) ? Price : 0;
                                        String ItemCode = item["ItemCode"].ToString().Trim();
                                        String IsPair = item["IsPair"].ToString().Trim();

                                        if (!(Lowerlimit < 0 || Higherlimit < 0))
                                        {
                                            SCM4 Data = new SCM4();

                                            Data.LowerLimit = Lowerlimit;
                                            Data.HigherLimit = Higherlimit;
                                            if (!string.IsNullOrEmpty(ItemCode))
                                            {
                                                var objOITM = ctx.OITMs.FirstOrDefault(x => x.ItemCode == ItemCode);
                                                Data.ItemID = objOITM.ItemID;
                                                Data.OITM = objOITM;
                                                Data.ItemGroupID = null;
                                                Data.ItemSubGroupID = null;

                                                var objOUNT = ctx.ITM1.Include("OUNT").Where(x => x.ItemID == objOITM.ItemID).FirstOrDefault();
                                                Data.UnitID = objOUNT.UnitID;
                                                Data.OUNT = objOUNT.OUNT;
                                            }
                                            Data.Quantity = Quantity;
                                            if (!string.IsNullOrEmpty(BaseOn))
                                                Data.BasedOn = BaseOn.ToLower() == "gross amount" ? 1 : BaseOn.ToLower() == "purchase qty" ? 2 : BaseOn.ToLower() == "unit" ? 3 : 1;
                                            Data.Discount = CompanyDisc + CustomerDisc;
                                            Data.DiscountType = DiscInPerRs.ToUpper();
                                            Data.SyncStatus = false;
                                            Data.Occurrence = Occurence;
                                            Data.CompanyDisc = CompanyDisc;
                                            Data.DistributorDisc = CustomerDisc;
                                            Data.Price = Price;
                                            Data.IsPair = IsPair.ToLower() == "yes" ? true : false;
                                            SCM4s.Add(Data);
                                        }
                                    }
                                    gvProductMappingMissData.Visible = false;
                                    gvScheme.DataSource = SCM4s;
                                    gvScheme.DataBind();
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

                            }
                            else
                            {
                                gvProductMappingMissData.Visible = true;
                                gvProductMappingMissData.DataSource = missdata;
                                gvProductMappingMissData.DataBind();
                            }
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Please upload valid file!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

}