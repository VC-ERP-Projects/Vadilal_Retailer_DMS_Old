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
    public Decimal? DistributorID { get; set; }
    public String DistributorCode { get; set; }
    public Decimal? DealerID { get; set; }
    public String DealerCode { get; set; }
    public String CustGroupName { get; set; }
    public String CustGroupDesc { get; set; }
    public Int32? CustType { get; set; }
    public Int32? EmployeeID { get; set; }
    public String EmployeeName { get; set; }

    public Int32? DivisionID { get; set; }
    public String DivisionName { get; set; }
    public Boolean Active { get; set; }
    public Boolean IsInclude { get; set; }
}



public partial class Sales_MinimumOrderAmount : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    private List<CustData> MOAE1s
    {
        get { return this.ViewState["MOAE1"] as List<CustData>; }
        set { this.ViewState["MOAE1"] = value; }
    }

    private List<MOAE3> MOAE3s
    {
        get { return this.ViewState["MOAE3"] as List<MOAE3>; }
        set { this.ViewState["MOAE3"] = value; }
    }

    private List<CustData> MOAE2s
    {
        get { return this.ViewState["MOAE2"] as List<CustData>; }
        set { this.ViewState["MOAE2"] = value; }
    }

    #endregion
    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            ACEtxtCode.Enabled = txtCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCode.Text = "Auto Generated";
            txtCode.Style.Remove("background-color");
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
        txtCode.Text = txtLowerLimit.Text = txtName.Text = txtSchmCode.Text = txtDivision.Text = txtCreatedBy.Text = txtUpdatedBy.Text = txtSTime.Text = txtETime.Text = "";
        chkActive.Checked = true;
        btnSubmit.Visible = true;
        ViewState["MiniOrderEnteryID"] = ViewState["MOAE1"] = ViewState["MOAE2"] = ViewState["MOAE3"] = null;
        chkInclude.Checked = true;
        gvItemGroup.DataSource = null;
        gvItemGroup.DataBind();

        gvCustData.DataSource = null;
        gvCustData.DataBind();

        gvMissdata.DataSource = null;
        gvMissdata.DataBind();

        gvitemMisdata.DataSource = null;
        gvitemMisdata.DataBind();

        DivStartTime.Visible = false;
        DivEndTime.Visible = false;
        ddlMode_SelectedIndexChanged(ddlMode, EventArgs.Empty);

        //ClearMapping();

        btnAddGroup.Text = "Add Division";
        btnAddCustData.Text = "Add Cust Data";
        chkInclude.Checked = true;
        txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtCustGroup.Text = "";
        ViewState["LineID"] = null;
        ViewState["CustDataID"] = null;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('General', 'tabs-1');", true);
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
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if ((txtLowerLimit.Text == "" || txtLowerLimit.Text == "0") && txtSTime.Text == "" && txtETime.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter at least One Mapping.',3);", true);
                        return;
                    }

                    OMOAE objOMOAE = null;
                    int MiniOrderEnteryID;
                    if (ViewState["MiniOrderEnteryID"] != null && Int32.TryParse(ViewState["MiniOrderEnteryID"].ToString(), out MiniOrderEnteryID))
                    {
                        objOMOAE = ctx.OMOAEs.Include("MOAE1").Include("MOAE2").Include("MOAE3").FirstOrDefault(x => x.MiniOrderEnteryID == MiniOrderEnteryID);
                    }
                    else
                    {
                        objOMOAE = new OMOAE();

                        if (ctx.OMOAEs.Any(x => x.MinimumOrderCode == txtSchmCode.Text.Trim()))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Order code is not allowed!',3);", true);
                            return;
                        }
                        objOMOAE.MiniOrderEnteryID = ctx.GetKey("OMOAE", "MiniOrderEnteryID", "", 0, 0).FirstOrDefault().Value;
                        objOMOAE.CreatedDate = DateTime.Now;
                        objOMOAE.CreatedBy = UserID;
                        ctx.OMOAEs.Add(objOMOAE);
                    }

                    objOMOAE.MinimumOrderCode = txtSchmCode.Text.Trim();
                    objOMOAE.MinimumOrderName = txtName.Text.Trim();
                    objOMOAE.Active = chkActive.Checked;
                    objOMOAE.ApplicableMode = ddlMode.SelectedValue;
                    objOMOAE.UpdatedDate = DateTime.Now;
                    objOMOAE.UpdatedBy = UserID;
                    if(txtLowerLimit.Text != "")
                    {
                        objOMOAE.Price = Convert.ToDecimal(txtLowerLimit.Text);
                    }
                    
                    TimeSpan ts;
                    if (TimeSpan.TryParse(txtSTime.Text, out ts))
                        objOMOAE.StartTime = ts;
                    if (TimeSpan.TryParse(txtETime.Text, out ts))
                        objOMOAE.EndTime = ts;

                    if (MOAE1s != null)
                    {
                        objOMOAE.MOAE1.ToList().ForEach(x => ctx.MOAE1.Remove(x));

                        int MOAE1Count = ctx.GetKey("MOAE1", "MOAE1ID", "", 0, 0).FirstOrDefault().Value;
                        foreach (CustData item in MOAE1s)
                        {
                            if (item.DealerID > 0 || item.DistributorID > 0 || item.RegionID > 0 || item.EmployeeID > 0 || !string.IsNullOrEmpty(item.CustGroupDesc))
                            {
                                var CustGroupID = !string.IsNullOrEmpty(item.CustGroupDesc) && ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == item.CustGroupName) != null ? ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == item.CustGroupName).CustGroupID : 0;

                                #region

                                if (item.Active)
                                {
                                    MOAE1 objoldMOAE1 = ctx.MOAE1.FirstOrDefault(x => x.DistributorID == item.DealerID && x.Active);
                                    if (objoldMOAE1 == null)
                                    {
                                        MOAE1 objMOAE1 = new MOAE1();
                                        objMOAE1.MOAE1ID = MOAE1Count++;
                                        objMOAE1.MiniOrderEnteryID = objOMOAE.MiniOrderEnteryID;
                                        objMOAE1.EmpID = item.EmployeeID;
                                        objMOAE1.RegionID = item.RegionID;
                                        objMOAE1.DistributorID = item.DistributorID;
                                        objMOAE1.CustGroupID = CustGroupID;
                                        objMOAE1.DealerID = item.DealerID;
                                        objMOAE1.CreatedDate = DateTime.Now;
                                        objMOAE1.Active = item.Active;
                                        objMOAE1.IsInclude = item.IsInclude;
                                        objOMOAE.MOAE1.Add(objMOAE1);
                                    }
                                    else if (objoldMOAE1.MiniOrderEnteryID == objOMOAE.MiniOrderEnteryID)
                                    {
                                        MOAE1 objMOAE1 = new MOAE1();
                                        objMOAE1.MOAE1ID = MOAE1Count++;
                                        objMOAE1.MiniOrderEnteryID = objOMOAE.MiniOrderEnteryID;
                                        objMOAE1.EmpID = item.EmployeeID;
                                        objMOAE1.RegionID = item.RegionID;
                                        objMOAE1.DistributorID = item.DistributorID;
                                        objMOAE1.CustGroupID = CustGroupID;
                                        objMOAE1.DealerID = item.DealerID;
                                        objMOAE1.CreatedDate = DateTime.Now;
                                        objMOAE1.Active = item.Active;
                                        objMOAE1.IsInclude = item.IsInclude;
                                        objOMOAE.MOAE1.Add(objMOAE1);
                                    }
                                }
                                #endregion
                            }
                        }
                    }

                    MOAE2 objMOAE2 = null;
                    objOMOAE.MOAE2.ToList().ForEach(x => ctx.MOAE2.Remove(x));
                    int GroupCount = ctx.GetKey("MOAE2", "MOAE2ID", "", 0, 0).FirstOrDefault().Value;
                    if (MOAE2s != null)
                        foreach (CustData item in MOAE2s)
                        {
                            objMOAE2 = new MOAE2();
                            objMOAE2.MOAE2ID = GroupCount++;
                            objMOAE2.MiniOrderEnteryID = objOMOAE.MiniOrderEnteryID;
                            objMOAE2.IsInclude = item.IsInclude;
                            objMOAE2.DivisionID = item.DivisionID;
                            objOMOAE.MOAE2.Add(objMOAE2);
                        }

                    //MOAE3 objMOAE3 = null;
                    //objMOAE3 = new MOAE3();
                    //var objMOAE3Check = ctx.MOAE3.FirstOrDefault(x => x.MiniOrderEnteryID == objOMOAE.MiniOrderEnteryID);
                    //if (objMOAE3Check == null)
                    //{
                    //    objMOAE3.MiniOrderEnteryID = objOMOAE.MiniOrderEnteryID;
                    //    if (txtLowerLimit.Text != "")
                    //    {
                    //        objMOAE3.Price = Convert.ToDecimal(txtLowerLimit.Text);
                    //        objOMOAE.StartTime = null;
                    //        objOMOAE.EndTime = null;
                    //    }
                    //    else
                    //    {
                    //        objMOAE3.Price = 0;
                    //    }
                    //    objOMOAE.MOAE3.Add(objMOAE3);
                    //}
                    //else
                    //{
                    //    if (txtLowerLimit.Text != "")
                    //    {
                    //        objMOAE3Check.Price = Convert.ToDecimal(txtLowerLimit.Text);
                    //        objOMOAE.StartTime = null;
                    //        objOMOAE.EndTime = null;
                    //    }
                    //    else
                    //    {
                    //        objMOAE3Check.Price = 0;
                    //    }
                    //}
                    ctx.SaveChanges();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOMOAE.MinimumOrderName + "',1);", true);
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
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Sales.aspx");
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
    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtCode.Text))
            {
                btnCancleCustData_Click(btnCancleCustData, EventArgs.Empty);
                btnCancelGroup_Click(btnCancelGroup, EventArgs.Empty);
                chkActive.Checked = true;

                var Data = txtCode.Text.Split("-".ToArray());
                if (Data.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        String minimumOrderCode = Data.First().Trim();

                        var objOMOAE = ctx.OMOAEs.Include("MOAE1").Include("MOAE2").Include("MOAE3").FirstOrDefault(x => x.MinimumOrderCode == minimumOrderCode);
                        if (!objOMOAE.Active)
                            hdnIsActive.Value = "0";
                        else
                            hdnIsActive.Value = "1";

                        if (objOMOAE != null)
                        {
                            ViewState["MiniOrderEnteryID"] = objOMOAE.MiniOrderEnteryID;
                            txtName.Text = objOMOAE.MinimumOrderName;
                            txtCode.Text = objOMOAE.MiniOrderEnteryID.ToString();
                            txtSchmCode.Text = objOMOAE.MinimumOrderCode;
                            chkActive.Checked = objOMOAE.Active;
                            ddlMode.SelectedValue = objOMOAE.ApplicableMode;
                            if(objOMOAE.Price != 0)
                            {
                                txtLowerLimit.Text = Convert.ToString(objOMOAE.Price);
                            }
                            txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOMOAE.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOMOAE.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOMOAE.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOMOAE.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                            ddlMode_SelectedIndexChanged(ddlMode, EventArgs.Empty);
                            if (objOMOAE.StartTime.HasValue)
                                txtSTime.Text = Convert.ToString(objOMOAE.StartTime.Value);
                            if (objOMOAE.EndTime.HasValue)
                                txtETime.Text = Convert.ToString(objOMOAE.EndTime.Value);

                            MOAE1s = new List<CustData>();
                            foreach (MOAE1 sc in objOMOAE.MOAE1)
                            {
                                CustData item = new CustData();

                                item.RegionID = sc.RegionID;
                                item.RegionName = sc.RegionID.HasValue ? ctx.OCSTs.FirstOrDefault(z => z.StateID == sc.RegionID.Value).StateName : "";
                                item.EmployeeID = sc.EmpID;
                                item.EmployeeName = sc.EmpID.HasValue && sc.EmpID > 0 ? (ctx.OEMPs.Where(y => y.EmpID == sc.EmpID.Value).Select(x => x.Name + " - " + x.EmpCode).FirstOrDefault()) : "";
                                item.CustGroupDesc = sc.CustGroupID.HasValue && sc.CustGroupID > 0 ? (ctx.CGRPs.Where(y => y.CustGroupID == sc.CustGroupID.Value).Select(x => x.CustGroupName + " # " + x.CustGroupDesc).FirstOrDefault()) : "";
                                item.DistributorID = sc.DistributorID;
                                item.DistributorCode = sc.DistributorID > 0 ? ctx.OCRDs.Where(y => y.CustomerID == sc.DistributorID.Value).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault() : "";
                                item.DealerID = sc.DealerID;
                                item.DealerCode = sc.DealerID.HasValue && sc.DealerID > 0 ? (ctx.OCRDs.Where(y => y.CustomerID == sc.DealerID.Value).Select(x => x.CustomerName + " # " + x.CustomerCode).FirstOrDefault()) : "";
                                item.Active = sc.Active;
                                item.IsInclude = sc.IsInclude;
                                MOAE1s.Add(item);
                            }
                            gvCustData.DataSource = MOAE1s;
                            gvCustData.DataBind();

                            MOAE2s = new List<CustData>();
                            foreach (MOAE2 sc in objOMOAE.MOAE2)
                            {
                                CustData item = new CustData();
                                item.DivisionID = sc.DivisionID;
                                item.DivisionName = sc.DivisionID.HasValue && sc.DivisionID > 0 ? (ctx.ODIVs.Where(y => y.DivisionlID == sc.DivisionID.Value).Select(x => x.DivisionCode + " - " + x.DivisionName).FirstOrDefault()) : "";
                                MOAE2s.Add(item);
                            }
                            gvItemGroup.DataSource = MOAE2s;
                            gvItemGroup.DataBind();

                            //var objMOAE3 = ctx.MOAE3.FirstOrDefault(x => x.MiniOrderEnteryID == objOMOAE.MiniOrderEnteryID);
                            //if (objOMOAE != null)
                            //{
                            //    txtLowerLimit.Text = Convert.ToString(objMOAE3.Price);
                            //}
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

    #region MOAE1
    protected void btnAddCustData_Click(object sender, EventArgs e)
    {
        if (MOAE1s == null)
            MOAE1s = new List<CustData>();

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
                        Data = MOAE1s[LineID];
                        Data.DealerID = DealerID;
                        Data.DealerCode = DealerCode;
                        Data.CustType = 3;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                        Data.EmployeeID = null;
                        Data.EmployeeName = null;
                    }
                    else
                    {
                        if (!MOAE1s.Any(x => x.DealerID == DealerID))
                        {
                            Data = new CustData();
                            Data.DealerID = DealerID;
                            Data.DealerCode = DealerCode;
                            Data.CustType = 3;

                            MOAE1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Dealer name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Dealer.',3);", true);
            }
        }
        else if (!string.IsNullOrEmpty(txtCode1.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EmpID = Int32.TryParse(txtCode1.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                if (ctx.OEMPs.Any(x => x.EmpID == EmpID))
                {
                    var EmpName = ctx.OEMPs.FirstOrDefault(x => x.EmpID == EmpID).Name;

                    CustData Data = null;
                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = MOAE1s[LineID];
                        Data.EmployeeID = EmpID;
                        Data.EmployeeName = EmpName;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = 2;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                    }
                    else
                    {
                        if (!MOAE1s.Any(x => x.EmployeeID == EmpID))
                        {
                            Data = new CustData();
                            Data.EmployeeID = EmpID;
                            Data.EmployeeName = EmpName;
                            MOAE1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Emp name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Distributor.',3);", true);
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
                        Data = MOAE1s[LineID];
                        Data.DistributorID = DistID;
                        Data.DistributorCode = DistCode;
                        Data.CustType = 2;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                        Data.EmployeeID = null;
                        Data.EmployeeName = null;
                    }
                    else
                    {
                        if (!MOAE1s.Any(x => x.DistributorID == DistID))
                        {
                            Data = new CustData();
                            Data.DistributorID = DistID;
                            Data.DistributorCode = DistCode;
                            Data.CustType = 2;
                            MOAE1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Distributor name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
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
                        Data = MOAE1s[LineID];
                        Data.CustGroupName = CustGroupName;
                        Data.CustGroupDesc = CustGroupDesc;
                        Data.RegionID = null;
                        Data.RegionName = null;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = null;
                        Data.EmployeeID = null;
                        Data.EmployeeName = null;
                    }
                    else
                    {
                        if (!MOAE1s.Any(x => x.CustGroupName == CustGroupName))
                        {
                            Data = new CustData();
                            Data.CustGroupName = CustGroupName;
                            Data.CustGroupDesc = CustGroupDesc;
                            MOAE1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Customer Group name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
                    chkIsActive.Checked = true;
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Customer Group.',3);", true);
            }
        }

        else if (!string.IsNullOrEmpty(txtRegion.Text) && txtRegion.Text.Split("-".ToArray()).Length > 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
                if (ctx.OCSTs.Any(x => x.StateID == RegionID))
                {
                    CustData Data = null;
                    var RegionName = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionID).StateName;

                    if (ViewState["CustDataID"] != null && Int32.TryParse(ViewState["CustDataID"].ToString(), out LineID))
                    {
                        Data = MOAE1s[LineID];
                        Data.RegionID = RegionID;
                        Data.RegionName = RegionName;
                        Data.DealerID = null;
                        Data.DealerCode = null;
                        Data.DistributorID = null;
                        Data.DistributorCode = null;
                        Data.CustType = null;
                        Data.CustGroupName = null;
                        Data.CustGroupDesc = null;
                        Data.EmployeeID = null;
                        Data.EmployeeName = null;
                    }
                    else
                    {
                        if (!MOAE1s.Any(x => x.RegionID == RegionID))
                        {
                            Data = new CustData();
                            Data.RegionID = RegionID;
                            Data.RegionName = RegionName;
                            MOAE1s.Add(Data);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Region name is not allowed!',3);", true);
                            return;
                        }
                    }
                    Data.Active = chkIsActive.Checked;
                    Data.IsInclude = chkIsInclude.Checked;
                    ViewState["CustDataID"] = null;
                    btnAddCustData.Text = "Add Cust Data";
                    txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
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
        gvCustData.DataSource = MOAE1s;
        gvCustData.DataBind();
    }
    protected void btnCancleCustData_Click(object sender, EventArgs e)
    {
        btnAddCustData.Text = "Add Cust Data";
        txtDealer.Text = txtCode1.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
        chkIsActive.Checked = chkIsInclude.Checked = true;
        ViewState["CustDataID"] = null;
    }
    protected void gvCustData_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "deleteCustData")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            MOAE1s.RemoveAt(LineID);

            gvCustData.DataSource = MOAE1s;
            gvCustData.DataBind();
            txtDealer.Text = txtDistributor.Text = txtRegion.Text = txtCustGroup.Text = "";
            chkIsActive.Checked = chkIsInclude.Checked = true;
            ViewState["CustDataID"] = null;
            btnAddCustData.Text = "Add Cust Data";
        }
        if (e.CommandName == "editCustData")
        {

            int LineID = Convert.ToInt32(e.CommandArgument);
            var objMOAE1 = MOAE1s[LineID];

            if (!string.IsNullOrEmpty(objMOAE1.RegionName))
                txtRegion.Text = objMOAE1.RegionID + " - " + objMOAE1.RegionName;
            else
                txtRegion.Text = "";


            if (!string.IsNullOrEmpty(objMOAE1.DistributorCode))
                txtDistributor.Text = objMOAE1.DistributorCode + " - " + objMOAE1.DistributorID;
            else
                txtDistributor.Text = "";

            if (!string.IsNullOrEmpty(objMOAE1.DealerCode))
                txtDealer.Text = objMOAE1.DealerCode + " - " + objMOAE1.DealerID;
            else
                txtDealer.Text = "";


            if (!string.IsNullOrEmpty(objMOAE1.CustGroupName))
                txtCustGroup.Text = objMOAE1.CustGroupDesc;
            else
                txtCustGroup.Text = "";

            if (!string.IsNullOrEmpty(objMOAE1.EmployeeName))
                txtCode1.Text = objMOAE1.EmployeeID + " - " + objMOAE1.EmployeeName;

            else
                txtRegion.Text = "";

            chkIsActive.Checked = objMOAE1.Active;
            chkIsInclude.Checked = objMOAE1.IsInclude;

            ViewState["CustDataID"] = LineID;
            btnAddCustData.Text = "Update Cust Data";
        }

    }
    #endregion

    #region MOAE2
    protected void btnCancelGroup_Click(object sender, EventArgs e)
    {
        btnAddGroup.Text = "Add Group";
        chkInclude.Checked = true;
        txtDivision.Text = "";
        ViewState["LineID"] = null;
    }
    protected void btnAddGroup_Click(object sender, EventArgs e)
    {
        if (MOAE2s == null)
            MOAE2s = new List<CustData>();

        int LineID;
        int IntNum;

        if (!String.IsNullOrEmpty(txtDivision.Text))
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
                        CustData Data = null;
                        if (ViewState["LineID"] != null && Int32.TryParse(ViewState["LineID"].ToString(), out LineID))
                        {
                            Data = MOAE2s[LineID];
                        }
                        else
                        {
                            if (!MOAE2s.Any(x => x.DivisionID == IntNum))
                            {
                                Data = new CustData();
                                MOAE2s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same group name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.IsInclude = chkInclude.Checked;
                        Data.DivisionID = Convert.ToInt32(text.First().Trim());

                        chkInclude.Checked = true;
                        txtDivision.Text = "";
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
        gvItemGroup.DataSource = MOAE2s;
        gvItemGroup.DataBind();
    }
    protected void gvItemGroup_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "deleteItemGroup")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            MOAE2s.RemoveAt(LineID);

            gvItemGroup.DataSource = MOAE2s;
            gvItemGroup.DataBind();

            chkInclude.Checked = true;
            txtDivision.Text = "";
            ViewState["LineID"] = null;
            btnAddGroup.Text = "Add Group";
        }
        if (e.CommandName == "editItemGroup")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ViewState["GSDivisionID"] = LineID;
            var objMOAE2 = MOAE2s[LineID];

            if (objMOAE2.DivisionID.HasValue)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    ODIV objODIV = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == objMOAE2.DivisionID.Value);
                    txtDivision.Text = objODIV.DivisionlID.ToString() + " - " + objODIV.DivisionName;
                }
            }
            else
                txtDivision.Text = "";

            chkInclude.Checked = objMOAE2.IsInclude;
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
    #endregion

    protected void ddlMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMode.SelectedValue == "OA")
        {
            divLowerLimit.Visible = true;
            DivStartTime.Visible = false;
            DivEndTime.Visible = false;
            txtSTime.Text = txtETime.Text = "";
        }
        else if (ddlMode.SelectedValue == "OE")
        {
            divLowerLimit.Visible = false;
            DivStartTime.Visible = true;
            DivEndTime.Visible = true;
            txtLowerLimit.Text = "";
        }
    }
}