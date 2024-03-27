using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

[Serializable]
public class ScheduleData
{
    public String MessageTo { get; set; }
    public Int32? RegionID { get; set; }
    public String RegionName { get; set; }
    public Int32? EmpID { get; set; }
    public String EmpName { get; set; }
    public Int32? EmpGroupID { get; set; }
    public String EmpGroup { get; set; }
    public Decimal? DistributorID { get; set; }
    public String DistributorCode { get; set; }
    public Decimal? DealerID { get; set; }
    public String DealerCode { get; set; }
    public DateTime? CreatedDate { get; set; }
    public Boolean Active { get; set; }
    public Boolean IsInclude { get; set; }
}
public partial class Master_NoSaleEmailSMS : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    private List<ScheduleData> SCHDL1s
    {
        get { return this.ViewState["SCHDL1"] as List<ScheduleData>; }
        set { this.ViewState["SCHDL1"] = value; }
    }

    #endregion

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
                        var unit = xml.Descendants("Inward");
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            ACEtxtNo.Enabled = txtNo.Enabled = false;
            btnSubmit.Text = "Submit";
            txtNo.Text = "Auto Generated";
            txtNo.Style.Remove("background-color");
            ddlSchedulePeriod.Focus();
        }
        else
        {
            txtNo.Text = "";
            ACEtxtNo.Enabled = txtNo.Enabled = true;
            btnSubmit.Text = "Submit";
            txtNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtNo.Focus();
        }
        txtNo.Text = txtNextRunDate.Text = txtLastInvXdays.Text = txtDay.Text = txtCreatedBy.Text = txtUpdatedBy.Text = "";
        ddlMessageTo.SelectedValue = "Distributor";
        ddlSchedulePeriod.SelectedValue = "Daily";
        txtSDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtTime.Text = DateTime.Now.ToString("HH");

        ViewState["LineID"] = ViewState["SCHDL1"] = ViewState["ScheduleID"] = null;
        chkIsActive.Checked = true;

        gvScheduleData.DataSource = null;
        gvScheduleData.DataBind();

        btnAddScheduleData.Text = "Add Schedule Data";
        chkIsInclude.Checked = true;
        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";

        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
            ddlEmpCategory.DataSource = EmpG;
            ddlEmpCategory.DataBind();
            ddlEmpCategory.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlEmpCategory.SelectedValue = "0";
        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('NoSaleEmailSMS', 'tabs-1');", true);
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
    }

    #endregion

    #region CheckBox Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

    #region Grid Events
    protected void gvScheduleData_PreRender(object sender, EventArgs e)
    {
        if (gvScheduleData.Rows.Count > 0)
        {
            gvScheduleData.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvScheduleData.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvSchedule_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "deleteData")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            SCHDL1s.RemoveAt(LineID);

            gvScheduleData.DataSource = SCHDL1s;
            gvScheduleData.DataBind();
            txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
            ddlEmpCategory.SelectedValue = "0";
            chkIsActive.Checked = chkIsInclude.Checked = true;
            ViewState["ScheduleDataID"] = null;
            btnAddScheduleData.Text = "Add Schedule Data";
        }
        if (e.CommandName == "editData")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            var objSCHDL1 = SCHDL1s[LineID];

            ddlMessageTo.SelectedValue = objSCHDL1.MessageTo;

            if (ddlMessageTo.SelectedValue == "Distributor")
            {
                if (!string.IsNullOrEmpty(objSCHDL1.RegionName))
                    txtDistRegion.Text = ctx.OCSTs.FirstOrDefault(x => x.StateID == objSCHDL1.RegionID).GSTStateCode + " - " + objSCHDL1.RegionName + " - " + objSCHDL1.RegionID;
                else
                    txtDistRegion.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.DistributorCode))
                    txtDistributor.Text = objSCHDL1.DistributorCode + " - " + objSCHDL1.DistributorID;
                else
                    txtDistributor.Text = "";
            }
            if (ddlMessageTo.SelectedValue == "Employee Category")
            {
                if (!string.IsNullOrEmpty(objSCHDL1.EmpName))
                    txtCode.Text = objSCHDL1.EmpName + " - " + objSCHDL1.EmpID;
                else
                    txtCode.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.EmpGroup))
                    ddlEmpCategory.SelectedValue = objSCHDL1.EmpGroupID.ToString();
                else
                    ddlEmpCategory.SelectedValue = "0";
            }

            if (!string.IsNullOrEmpty(objSCHDL1.DealerCode))
                txtDealerCode.Text = objSCHDL1.DealerCode + " - " + objSCHDL1.DealerID;
            else
                txtDealerCode.Text = "";

            chkActive.Checked = objSCHDL1.Active;
            chkIsInclude.Checked = objSCHDL1.IsInclude;
            ViewState["ScheduleDataID"] = LineID;
            btnAddScheduleData.Text = "Update Schedule Data";
        }

    }
    #endregion

    #region Textbox change events

    protected void txtNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtNo.Text))
            {
                btnCancleScheduleData_Click(btnCancleScheduleData, EventArgs.Empty);
                txtSDate.Text = txtTime.Text = txtNextRunDate.Text = txtDay.Text = txtLastInvXdays.Text = txtCreatedBy.Text = txtUpdatedBy.Text = "";
                chkActive.Checked = true;
                chkIsInclude.Checked = true;

                var Data = txtNo.Text.Split("-".ToArray());
                if (Data.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        int ScheduleID;
                        ScheduleID = Convert.ToInt32(txtNo.Text.Split("-".ToArray()).Last().Trim());

                        var objOSCHDL = ctx.OSCHDLs.Include("SCHDL1").FirstOrDefault(x => x.ScheduleID == ScheduleID);
                        if (!objOSCHDL.Active)
                            hdnIsActive.Value = "0";
                        else
                            hdnIsActive.Value = "1";

                        if (objOSCHDL != null)
                        {
                            txtSDate.Enabled = txtTime.Enabled = false;
                            ViewState["ScheduleID"] = objOSCHDL.ScheduleID;
                            txtSDate.Text = Common.DateTimeConvert(objOSCHDL.StartDate);
                            txtTime.Text = objOSCHDL.StartDate.ToString("HH");
                            txtNo.Text = objOSCHDL.ScheduleID.ToString();
                            ddlSchedulePeriod.SelectedValue = objOSCHDL.SchedulePeriod;
                            chkIsActive.Checked = objOSCHDL.Active;
                            txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCHDL.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCHDL.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtDay.Text = objOSCHDL.PeriodNo.HasValue ? Convert.ToString(objOSCHDL.PeriodNo) : "0";
                            txtLastInvXdays.Text = Convert.ToString(objOSCHDL.LastInvDay);
                            ddlMessageTo.SelectedValue = objOSCHDL.MessageTo;

                            DateTime NextRunDate = objOSCHDL.LastRunDate.HasValue ? objOSCHDL.LastRunDate.Value : objOSCHDL.StartDate;

                            if (objOSCHDL.SchedulePeriod == "Daily")
                            {
                                txtNextRunDate.Text = NextRunDate.AddDays(objOSCHDL.PeriodNo.Value).ToString("dd/MM/yy");
                            }
                            else if (objOSCHDL.SchedulePeriod == "Weekly")
                            {
                                txtNextRunDate.Text = NextRunDate.AddDays(7 * objOSCHDL.PeriodNo.Value).ToString("dd/MM/yy");
                            }
                            else
                            {
                                txtNextRunDate.Text = NextRunDate.AddMonths(objOSCHDL.PeriodNo.Value).ToString("dd/MM/yy");
                            }

                            SCHDL1s = new List<ScheduleData>();

                            foreach (SCHDL1 sc in objOSCHDL.SCHDL1)
                            {
                                ScheduleData item = new ScheduleData();
                                if (objOSCHDL.MessageTo == "Distributor")
                                {
                                    item.RegionID = sc.RegionID;
                                    item.RegionName = sc.RegionID.HasValue ? ctx.OCSTs.Where(z => z.StateID == sc.RegionID.Value).Select(z => z.StateName).FirstOrDefault() : "";
                                    item.DistributorID = sc.DistID;
                                    item.DistributorCode = sc.DistID.HasValue ? ctx.OCRDs.Where(x => x.CustomerID == sc.DistID.Value && x.Type == 2).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault() : "";
                                }
                                if (objOSCHDL.MessageTo == "Employee Category")
                                {
                                    item.EmpID = sc.EmpID;
                                    item.EmpName = sc.EmpID.HasValue ? ctx.OEMPs.Where(x => x.EmpID == sc.EmpID.Value && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : "";
                                    item.EmpGroupID = sc.EmpGroupID;
                                    item.EmpGroup = sc.EmpGroupID.HasValue ? ctx.OGRPs.FirstOrDefault(x => x.EmpGroupID == sc.EmpGroupID.Value && x.ParentID == ParentID).EmpGroupName : "";
                                }
                                item.DealerID = sc.DealerID;
                                item.DealerCode = sc.DealerID.HasValue ? ctx.OCRDs.Where(x => x.CustomerID == sc.DealerID.Value && x.Type == 3).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault() : "";
                                item.MessageTo = objOSCHDL.MessageTo;
                                item.Active = sc.Active;
                                item.IsInclude = sc.IsInclude;
                                item.CreatedDate = sc.CreatedDate.HasValue ? sc.CreatedDate : null;
                                SCHDL1s.Add(item);
                            }
                            gvScheduleData.DataSource = SCHDL1s;
                            gvScheduleData.DataBind();
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper No!',3);", true);
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
        txtCode.Focus();
    }

    protected void ddlMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
    }

    #endregion

    #region Button Click

    protected void btnAddScheduleData_Click(object sender, EventArgs e)
    {
        if (SCHDL1s == null)
            SCHDL1s = new List<ScheduleData>();

        int LineID;

        if (ddlMessageTo.SelectedValue == "Distributor")
        {
            if (!string.IsNullOrEmpty(txtDealerCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    if (ctx.OCRDs.Any(x => x.CustomerID == DealerID && x.Type == 3))
                    {
                        string DealerCode = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = DealerID;
                            Data.DealerCode = DealerCode;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.DealerID == DealerID))
                            {
                                Data = new ScheduleData();
                                Data.DealerID = DealerID;
                                Data.DealerCode = DealerCode;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Dealer name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        Data.MessageTo = ddlMessageTo.SelectedValue;

                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
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

                    if (ctx.OCRDs.Any(x => x.CustomerID == DistID && x.Type == 2))
                    {
                        string DistCode = ctx.OCRDs.Where(x => x.CustomerID == DistID && x.Type == 2).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();

                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = null;
                            Data.DealerCode = null;
                            Data.DistributorID = DistID;
                            Data.DistributorCode = DistCode;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.DistributorID == DistID))
                            {
                                Data = new ScheduleData();
                                Data.DistributorID = DistID;
                                Data.DistributorCode = DistCode;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Distributor name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        Data.MessageTo = ddlMessageTo.SelectedValue;

                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Distributor.',3);", true);
                }
            }
            else if (!string.IsNullOrEmpty(txtDistRegion.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int RegionID = Int32.TryParse(txtDistRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;

                    if (ctx.OCSTs.Any(x => x.StateID == RegionID))
                    {
                        var RegionName = ctx.OCSTs.FirstOrDefault(x => x.StateID == RegionID).StateName;

                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = null;
                            Data.DealerCode = null;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.RegionID = RegionID;
                            Data.RegionName = RegionName;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.RegionID == RegionID))
                            {
                                Data = new ScheduleData();
                                Data.RegionID = RegionID;
                                Data.RegionName = RegionName;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Region name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        Data.MessageTo = ddlMessageTo.SelectedValue;

                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Dist. Region.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one data.',3);", true);
                return;
            }
        }
        else if (ddlMessageTo.SelectedValue == "Employee Category")
        {
            if (!string.IsNullOrEmpty(txtDealerCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Decimal DealerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
                    if (ctx.OCRDs.Any(x => x.CustomerID == DealerID && x.Type == 3))
                    {
                        string DealerCode = ctx.OCRDs.Where(x => x.CustomerID == DealerID && x.Type == 3).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();
                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = DealerID;
                            Data.DealerCode = DealerCode;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.DealerID == DealerID))
                            {
                                Data = new ScheduleData();
                                Data.DealerID = DealerID;
                                Data.DealerCode = DealerCode;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Dealer name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        Data.MessageTo = ddlMessageTo.SelectedValue;

                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Dealer.',3);", true);
                }
            }
            else if (!string.IsNullOrEmpty(txtCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                    if (ctx.OEMPs.Any(x => x.EmpID == EmpID && x.ParentID == ParentID))
                    {
                        string EmpName = ctx.OEMPs.Where(x => x.EmpID == EmpID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();

                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = null;
                            Data.DealerCode = null;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = EmpID;
                            Data.EmpName = EmpName;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.EmpID == EmpID))
                            {
                                Data = new ScheduleData();
                                Data.EmpID = EmpID;
                                Data.EmpName = EmpName;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Employee is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        Data.MessageTo = ddlMessageTo.SelectedValue;

                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Employee.',3);", true);
                }
            }
            else if (ddlEmpCategory.SelectedValue != "0")
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int EmpGroupID = Int32.TryParse(ddlEmpCategory.Text.Split("-".ToArray()).First().Trim(), out EmpGroupID) ? EmpGroupID : 0;

                    if (ctx.OGRPs.Any(x => x.EmpGroupID == EmpGroupID && x.ParentID == ParentID))
                    {
                        var EmpGroup = ctx.OGRPs.Where(x => x.EmpGroupID == EmpGroupID && x.ParentID == ParentID).Select(x => x.EmpGroupName).FirstOrDefault();

                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = null;
                            Data.DealerCode = null;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = EmpGroupID;
                            Data.EmpGroup = EmpGroup;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.EmpGroupID == EmpGroupID))
                            {
                                Data = new ScheduleData();
                                Data.EmpGroupID = EmpGroupID;
                                Data.EmpGroup = EmpGroup;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Employee group name is not allowed!',3);", true);
                                return;
                            }
                        }
                        Data.CreatedDate = DateTime.Now;
                        Data.Active = chkActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        Data.MessageTo = ddlMessageTo.SelectedValue;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Schedule Data";
                        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
                        ddlEmpCategory.SelectedValue = "0";
                        chkActive.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Employee Category.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select at least one data.',3);", true);
                return;
            }
        }
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
    }

    protected void btnCancleScheduleData_Click(object sender, EventArgs e)
    {
        btnAddScheduleData.Text = "Add Schedule Data";
        txtCode.Text = txtDistRegion.Text = txtDistributor.Text = txtDealerCode.Text = "";
        ddlEmpCategory.SelectedValue = "0";
        chkIsActive.Checked = chkIsInclude.Checked = true;
        ViewState["ScheduleDataID"] = null;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (chkMode.Checked && Convert.ToDateTime(txtSDate.Text).Date < DateTime.Now.Date)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select future date!',3);", true);
                    return;
                }
                if (string.IsNullOrEmpty(txtDay.Text) || txtDay.Text == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter valid Period Day!',3);", true);
                    return;
                }

                if (string.IsNullOrEmpty(txtLastInvXdays.Text) || txtLastInvXdays.Text == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter valid Last Invoice Day!',3);", true);
                    return;
                }

                int ScheduleID;
                OSCHDL objOSCHDL;
                int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last(), out SUserID) ? SUserID : 0;
                decimal DistributorID = decimal.TryParse(txtDistributor.Text.Split("-".ToArray()).Last(), out DistributorID) ? DistributorID : 0;
                decimal DealerID = decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last(), out DealerID) ? DealerID : 0;

                if (ViewState["ScheduleID"] != null && Int32.TryParse(ViewState["ScheduleID"].ToString(), out ScheduleID))
                {
                    objOSCHDL = ctx.OSCHDLs.Include("SCHDL1").FirstOrDefault(x => x.ScheduleID == ScheduleID);
                }
                else
                {
                    objOSCHDL = new OSCHDL();

                    objOSCHDL.CreatedDate = DateTime.Now;
                    objOSCHDL.CreatedBy = UserID;
                    ctx.OSCHDLs.Add(objOSCHDL);
                }
                objOSCHDL.MessageTo = ddlMessageTo.SelectedValue;
                objOSCHDL.SchedulePeriod = ddlSchedulePeriod.SelectedValue;

                var time = txtTime.Text.Split(":".ToArray()).First().Trim();
                objOSCHDL.StartDate = Convert.ToDateTime(txtSDate.Text).Date.AddHours(Convert.ToDouble(txtTime.Text.Split(":".ToArray()).First().Trim()));
                objOSCHDL.LastInvDay = Convert.ToInt32(txtLastInvXdays.Text);
                objOSCHDL.PeriodNo = Convert.ToInt16(txtDay.Text);
                objOSCHDL.Active = chkIsActive.Checked;
                objOSCHDL.UpdatedDate = DateTime.Now;
                objOSCHDL.UpdatedBy = UserID;

                if (SCHDL1s != null)
                {
                    objOSCHDL.SCHDL1.ToList().ForEach(x => ctx.SCHDL1.Remove(x));

                    foreach (ScheduleData item in SCHDL1s)
                    {
                        if (item.DistributorID > 0 || item.RegionID > 0 || item.EmpID > 0 || item.EmpGroupID > 0 || item.DealerID > 0)
                        {
                            SCHDL1 objSCHDL1 = new SCHDL1();

                            if (ddlMessageTo.SelectedValue == "Distributor")
                            {
                                if (item.RegionID.GetValueOrDefault(0) > 0)
                                    objSCHDL1.RegionID = item.RegionID;
                                else
                                    objSCHDL1.RegionID = null;

                                if (item.DistributorID.GetValueOrDefault(0) > 0)
                                    objSCHDL1.DistID = item.DistributorID;
                                else
                                    objSCHDL1.DistID = null;
                            }
                            else
                            {
                                if (item.EmpGroupID.GetValueOrDefault(0) > 0)
                                    objSCHDL1.EmpGroupID = item.EmpGroupID;
                                else
                                    objSCHDL1.EmpGroupID = null;

                                if (item.EmpID.GetValueOrDefault(0) > 0)
                                    objSCHDL1.EmpID = item.EmpID;
                                else
                                    objSCHDL1.EmpID = null;
                            }

                            if (item.DealerID.GetValueOrDefault(0) > 0)
                                objSCHDL1.DealerID = item.DealerID;
                            else
                                objSCHDL1.DealerID = null;

                            objSCHDL1.Active = item.Active;
                            objSCHDL1.IsInclude = item.IsInclude;
                            objSCHDL1.CreatedDate = item.CreatedDate;

                            objOSCHDL.SCHDL1.Add(objSCHDL1);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter at least One Mapping!',3);", true);
                            return;
                        }
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOSCHDL.ScheduleID + "',1);", true);
                ClearAllInputs();
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
        Response.Redirect("NoSaleEmailSMS.aspx");
    }

    #endregion
}

