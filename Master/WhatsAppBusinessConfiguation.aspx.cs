using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Data.Objects.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_WhatsAppBusinessConfiguation : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    public class WhatsAppBusinessEmp
    {
        public string Text { get; set; }
        public decimal Value { get; set; }
    }

    private List<ScheduleData> SCHDL1s
    {
        get { return this.ViewState["SCHDL1"] as List<ScheduleData>; }
        set { this.ViewState["SCHDL1"] = value; }
    }

    public object MessageBox { get; private set; }

    [Serializable]
    public class ScheduleData
    {
        public String MessageTo { get; set; }
        public String MessagePeriod { get; set; }
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
        public Decimal? SSID { get; set; }
        public String SSCode { get; set; }
        public DateTime? CreatedDate { get; set; }
        public DateTime? UpdateDate { get; set; }
        public Boolean Active { get; set; }
        public Boolean IsInclude { get; set; }
        public string WeekDayName { get; set; }
        public string WeekDays { get; set; }
        public int Day1 { get; set; }
        public int Day2 { get; set; }
        public int Day3 { get; set; }
        public string MessageType { get; set; }
        public Int32 OWPMID { get; set; }
        //  public string MessageFor { get; set; }
    }
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
                            var unit = xml.Descendants("message_broadcast");
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnSubmit);

        if (!IsPostBack)
        {
            ClearAllInputs();
            ddlMsgFor_SelectedIndexChanged(sender, e);
            ddlAppliFor_SelectedIndexChanged(sender, e);
            ddlMessageFor_SelectedIndexChanged(sender, e);
            txtfromdate.Text = DateTime.Now.ToString("dd/MM/yyyy");
            txttodate.Text = DateTime.Now.ToString("dd/MM/yyyy");
            for (int i = 0; i <= 31; i++)
            {
                ddlDay1.Items.Insert(i, new ListItem(i.ToString(), i.ToString()));
                ddlDay2.Items.Insert(i, new ListItem(i.ToString(), i.ToString()));
                ddlDay3.Items.Insert(i, new ListItem(i.ToString(), i.ToString()));
            }
            
            // txtSubject.Focus();
        }
    }

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            acetxtMessageCode.Enabled = txtMessageCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtMessageCode.Text = "Auto Generated";
            txtMessageCode.Style.Remove("background-color");
            // txtfromdate.Focus();
            ddlMessageType.Enabled = true;
            ddlMsgFor.Enabled = true;
            chkMode.Focus();
        }
        else
        {
            txtMessageCode.Text = "";
            acetxtMessageCode.Enabled = txtMessageCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtMessageCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtMessageCode.Focus();
        }

        txtCreatedBy.Text = txtUpdatedBy.Text = "";
        ddlMsgFor.SelectedValue = "E";
        ddlMsgFor_SelectedIndexChanged(null, null);
        ddlAppliFor.SelectedValue = "D";
        ddlAppliFor_SelectedIndexChanged(null, null);
        imgMessage.ImageUrl = "";
        //txtfromdate.Text = Common.DateTimeConvert(DateTime.Now);
        //txttodate = DateTime.Now.ToString("HH");

        ViewState["LineID"] = ViewState["SCHDL1"] = ViewState["ScheduleID"] = ViewState["ScheduleDataID"] = null;
        chkActive.Checked = true;

        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
        chkSunday.Checked = false;
        chkMonday.Checked = false;
        chkTuesday.Checked = false;
        chkWednesday.Checked = false;
        chkThursday.Checked = false;
        chkFriday.Checked = false;
        chkSaturday.Checked = false;
        ddlDay1.SelectedValue = "0";
        ddlDay2.SelectedValue = "0";
        ddlDay3.SelectedValue = "0";
        btnAddScheduleData.Text = "Add Configuration Data";
        chkIsActive.Checked = true;
        txtEmpCode.Text = txtEmpGroup.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = "";

        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('WhatsappConfig', 'tabs-1');", true);
    }


    private bool Validation()
    {
        if (ddlAppliFor.SelectedValue == "W")
        {
            int SelectDay = 0;
            if (chkSunday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkMonday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkTuesday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkWednesday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkThursday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkFriday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (chkSaturday.Checked)
            {
                SelectDay = SelectDay + 1;
            }
            if (SelectDay == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select at least one day.',3);", true);
                return false;
            }
            if (SelectDay > 2)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select only 2 days.',3);", true);
                return false;
            }
        }
        else if (ddlAppliFor.SelectedValue == "M")
        {
            Int16 Day1 = Convert.ToInt16(ddlDay1.SelectedValue);
            Int16 Day2 = Convert.ToInt16(ddlDay2.SelectedValue);
            Int16 Day3 = Convert.ToInt16(ddlDay3.SelectedValue);
            if (Day1 == 0 && Day2 == 0 && Day3 == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select at least 1 date.',3);", true);
                return false;
            }
            if (Day1 > 0 && Day2 > 0)
            {
                if (Day1 == Day2)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 1 and Date 2.',3);", true);
                    return false;
                }
            }
            if (Day1 > 0 && Day3 > 0)
            {
                if (Day1 == Day3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 1 and Date 3',3);", true);
                    return false;
                }
            }
            if (Day2 > 0 && Day3 > 0)
            {
                if (Day2 == Day3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 2 and Date 3',3);", true);
                    return false;
                }
            }
        }
        return true;
    }
    #endregion

    #region TextChanged

    protected void txtMessageCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtMessageCode.Text))
            {
                btnCancleScheduleData_Click(btnCancleScheduleData, EventArgs.Empty);
                // txtSDate.Text = txtTime.Text = txtNextRunDate.Text = txtDay.Text = txtLastInvXdays.Text = txtCreatedBy.Text = txtUpdatedBy.Text = "";
                chkActive.Checked = true;
                chkIsActive.Checked = true;

                var Data = txtMessageCode.Text.Split("-".ToArray());
                if (Data.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        int ScheduleID;
                        ScheduleID = Convert.ToInt32(txtMessageCode.Text.Split("-".ToArray()).Last().Trim());

                        var objOSCHDL = ctx.OWPMs.Include("WPM1").FirstOrDefault(x => x.OWPMID == ScheduleID);
                        //if (!objOSCHDL.active)
                        //    hdnIsActive.Value = "0";
                        //else
                        //    hdnIsActive.Value = "1";

                        if (objOSCHDL != null)
                        {
                            //   txtfromdate.Enabled = txttodate.Enabled = false;

                            ViewState["ScheduleID"] = objOSCHDL.OWPMID;
                            txtfromdate.Text = Convert.ToDateTime(objOSCHDL.FromDate).ToString("dd/MM/yyyy");
                            txttodate.Text = Convert.ToDateTime(objOSCHDL.ToDate).ToString("dd/MM/yyyy");
                            txtMobileNo.Text = objOSCHDL.MobileNo.ToString();
                            txtMessageCode.Text = objOSCHDL.OWPMID.ToString();
                            ddlAppliFor.SelectedValue = objOSCHDL.MessagePeriod.Trim();
                            ddlMessageType.SelectedValue = objOSCHDL.MessageType.Trim();
                            ddlMessageType.Enabled = false;
                            ddlMsgFor.Enabled = false;
                            ddlMsgFor.SelectedValue = objOSCHDL.MessageTo.Trim();
                            ddlMsgFor_SelectedIndexChanged(sender, e);
                            if (ddlMsgFor.SelectedValue == "C")
                            {
                                ddlMessageFor.SelectedValue = objOSCHDL.MessageFor.Trim();
                                ddlMessageFor_SelectedIndexChanged(sender, e);
                            }
                            ddlAppliFor_SelectedIndexChanged(sender, e);
                            ddlMessageType_SelectedIndexChanged(sender, e);
                            chkActive.Checked = Convert.ToBoolean(objOSCHDL.Active);
                            //txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCHDL.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            //txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.UpdateBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + "  " + objOSCHDL.UpdateDate.ToString("dd/MM/yyyy HH:mm");
                            txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + " " + Convert.ToDateTime(objOSCHDL.CreatedDate).ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOSCHDL.UpdateBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() + " " + Convert.ToDateTime(objOSCHDL.UpdateDate).ToString("dd/MM/yyyy HH:mm");
                            imgMessage.ImageUrl = string.IsNullOrEmpty(objOSCHDL.ImageUpload) ? "" : "/Document/WhatsAppMessageBroadCast/" + objOSCHDL.ImageUpload;
                            hdnImageHasValue.Value = string.IsNullOrEmpty(objOSCHDL.ImageUpload) ? "" : objOSCHDL.ImageUpload;
                            if (!string.IsNullOrEmpty(objOSCHDL.ImageUpload))
                            {
                                imgMessage.Visible = true;
                            }

                            SCHDL1s = new List<ScheduleData>();

                            foreach (WPM1 sc in objOSCHDL.WPM1)
                            {
                                ScheduleData item = new ScheduleData();
                                if (objOSCHDL.MessageTo.Trim() == "C")
                                {
                                    item.EmpID = sc.EmpID;
                                    item.EmpName = sc.EmpID.HasValue ? ctx.OEMPs.Where(x => x.EmpID == sc.EmpID.Value && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault() : "";
                                    var objOCST = ctx.OCSTs.FirstOrDefault(x => x.StateID == sc.DistRegionID);
                                    item.RegionID = sc.DistRegionID;
                                    item.RegionName = objOCST != null ? objOCST.StateName : ""; //objOCST.GSTStateCode + " - " + objOCST.StateName + " - " + objOCST.StateID : "";
                                    item.DistributorID = sc.DistributorID;
                                    item.DistributorCode = sc.DistributorID.HasValue ? ctx.OCRDs.Where(x => x.CustomerID == sc.DistributorID.Value && x.Type == 2).Select(x => x.CustomerCode + " - " + x.CustomerName).FirstOrDefault() : "";
                                    item.DealerID = sc.DealerID;
                                    item.DealerCode = sc.DealerID.HasValue ? ctx.OCRDs.Where(x => x.CustomerID == sc.DealerID.Value && x.Type == 3).Select(x => x.CustomerCode + " - " + x.CustomerName).FirstOrDefault() : "";
                                    item.SSID = sc.SSID;
                                    item.SSCode = sc.SSID.HasValue ? ctx.OCRDs.Where(x => x.CustomerID == sc.SSID.Value && x.Type == 4).Select(x => x.CustomerCode + " - " + x.CustomerName).FirstOrDefault() : "";
                                }
                                if (objOSCHDL.MessageTo.Trim() == "E")
                                {
                                    item.EmpID = sc.EmpID;
                                    item.EmpName = sc.EmpID.HasValue ? ctx.OEMPs.Where(x => x.EmpID == sc.EmpID.Value && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault() : "";
                                    item.EmpGroupID = sc.EmpGroupID == null ? 0 : sc.EmpGroupID;
                                    item.EmpGroup = sc.EmpGroupID.HasValue ? ctx.OGRPs.Where(x => x.EmpGroupID == sc.EmpGroupID.Value && x.ParentID == ParentID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).FirstOrDefault() : "";
                                }
                                item.Active = Convert.ToBoolean(sc.Active);
                                item.MessageTo = objOSCHDL.MessageTo.Trim();
                                item.IsInclude = Convert.ToBoolean(sc.IsInclude);
                                item.CreatedDate = sc.CreatedDate.HasValue ? sc.CreatedDate : null;
                                item.UpdateDate = sc.UpdatedDate.HasValue ? sc.UpdatedDate : null;
                                item.WeekDays = sc.WeekDays;
                                item.WeekDayName = "";
                                if (ddlAppliFor.SelectedValue == "W")
                                {
                                    if (item.WeekDays != "")
                                    {
                                        string weekname = "";
                                        string[] week = sc.WeekDays.Split(',');
                                        for (int i = 0; i < week.Length; i++)
                                        {
                                            if (week[i] == "1")
                                            {
                                                weekname = weekname + "Sunday,";
                                            }
                                            if (week[i] == "2")
                                            {
                                                weekname = weekname + "Monday,";
                                            }
                                            if (week[i] == "3")
                                            {
                                                weekname = weekname + "Tuesday,";
                                            }
                                            if (week[i] == "4")
                                            {
                                                weekname = weekname + "Wednesday,";
                                            }
                                            if (week[i] == "5")
                                            {
                                                weekname = weekname + "Thursday,";
                                            }
                                            if (week[i] == "6")
                                            {
                                                weekname = weekname + "Friday,";
                                            }
                                            if (week[i] == "7")
                                            {
                                                weekname = weekname + "Saturday,";
                                            }
                                        }
                                        item.WeekDayName = weekname;
                                    }
                                    divweekly.Visible = true;
                                    divMonthly.Visible = false;
                                }
                                else if (ddlAppliFor.SelectedValue == "M")
                                {
                                    divweekly.Visible = false;
                                    divMonthly.Visible = true;
                                }
                                else
                                {
                                    divMonthly.Visible = false;
                                    divweekly.Visible = false;
                                }

                                item.Day1 = Convert.ToInt16(sc.Day1);
                                item.Day2 = Convert.ToInt16(sc.Day2);
                                item.Day3 = Convert.ToInt16(sc.Day3);
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
        txtMessageCode.Focus();
    }

    [WebMethod(EnableSession = true)]
    public static List<dynamic> GetMessageDetailByID(string MessageID)
    {
        Decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"].ToString());

        List<dynamic> result = new List<dynamic>();
        try
        {
            Int32 MsgID = Int32.TryParse(MessageID, out MsgID) ? MsgID : 0;
            if (MsgID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ctx.OWPMs.Any(x => x.OWPMID == MsgID))
                    {
                        OWPM objOMSG = ctx.OWPMs.Include("WPM1").FirstOrDefault(x => x.ParentID == ParentID && x.OWPMID == MsgID);
                        var HeaderData = new
                        {
                            MessageID = objOMSG.OWPMID,
                            FromDate = objOMSG.FromDate,
                            ToDate = objOMSG.ToDate,
                            MobileNO = objOMSG.ToString(),
                            CreatedTime = objOMSG.CreatedDate.ToString(),
                            UpdatedTime = objOMSG.UpdateDate.ToString(),
                            CreatedBy = ctx.OEMPs.Where(z => z.ParentID == ParentID && z.EmpID == objOMSG.CreatedBy).Select(z => z.EmpCode + " # " + z.Name).FirstOrDefault(),
                            UpdatedBy = ctx.OEMPs.Where(z => z.ParentID == ParentID && z.EmpID == objOMSG.UpdateBy).Select(z => z.EmpCode + " # " + z.Name).FirstOrDefault(),
                            AppliFor = objOMSG.MessagePeriod,
                            MessageTo = objOMSG.MessageTo,
                            IsActive = objOMSG.Active,
                            ImageUpload = string.IsNullOrEmpty(objOMSG.ImageUpload) ? "" : "/Document/WhatsAppMessageBroadCast/" + objOMSG.ImageUpload
                        };
                        result.Add(HeaderData);
                        if (objOMSG.WPM1.Count() > 0)
                        {
                            foreach (var item in objOMSG.WPM1)
                            {
                                var ItemData = new
                                {
                                    AppliFor = objOMSG.MessageTo.Trim(),
                                    RegionID = item.DistRegionID != null && item.DistRegionID > 0 ? item.DistRegionID : 0,
                                    Region = item.DistRegionID != null && item.DistRegionID > 0 ? ctx.OCSTs.Where(y => y.StateID == item.DistRegionID).Select(x => x.GSTStateCode + "#" + x.StateName).FirstOrDefault() : "",

                                    DealerID = item.DealerID != null && item.DealerID > 0 ? item.DealerID : 0,
                                    DealerEmp = item.DealerID != null && item.DealerID > 0 ? ctx.OCRDs.Where(y => y.CustomerID == item.DealerID && y.Type == 3).Select(x => x.CustomerCode + "#" + x.CustomerName).FirstOrDefault() : "",

                                    EmpCustGroupID = item.EmpGroupID != null && item.EmpGroupID > 0 ? item.EmpGroupID : 0,
                                    EmpCustGroup = objOMSG.MessageTo.Trim() == "E" ? ctx.OGRPs.Where(m => m.EmpGroupID == item.EmpGroupID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).FirstOrDefault() : "",

                                    EmpCustID = item.EmpID != null && item.EmpID > 0 ? item.EmpID : 0,
                                    EmpCustName = objOMSG.MessageTo.Trim() != null && item.EmpID != null && item.EmpID > 0 ?
                                                    (objOMSG.MessageTo.Trim() == "C" ? ctx.OCRDs.Where(y => y.CustomerID == item.EmpID).Select(x => x.CustomerCode + "#" + x.CustomerName).FirstOrDefault() :
                                                     ctx.OEMPs.Where(y => y.EmpID == item.EmpID && y.ParentID == ParentID).Select(x => x.EmpCode + "#" + x.Name).FirstOrDefault()) : "",

                                    DistributorID = item.DistributorID != null && item.DistributorID > 0 ? item.DistributorID : 0,
                                    DistributorEmp = item.DistributorID != null && item.DistributorID > 0 ? ctx.OCRDs.Where(y => y.CustomerID == item.DistributorID && y.ParentID == ParentID && y.Type == 2).Select(x => x.CustomerCode + "#" + x.CustomerName).FirstOrDefault() : "",
                                    SSID = item.SSID != null && item.SSID > 0 ? item.SSID : 0,
                                    SSName = item.SSID != null && item.SSID > 0 ? ctx.OCRDs.Where(y => y.CustomerID == item.SSID && y.ParentID == ParentID && y.Type == 4).Select(x => x.CustomerCode + "#" + x.CustomerName).FirstOrDefault() : "",
                                    WeekDays = item.WeekDays,
                                    Day1 = item.Day1,
                                    Day2 = item.Day2,
                                    Day3 = item.Day3,
                                    IsInclude = Convert.ToBoolean(item.IsInclude) ? true : false
                                };


                                result.Add(ItemData);
                            }
                        }
                    }
                    else
                    {
                        result.Add("ERROR=No Message Detail found.");
                    }
                }
            }
            else
            {
                result.Add("ERROR=Please select proper Message.");
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;
    }

    [WebMethod]
    public static Int32 GetCustGroupID(string CustGroupName)
    {
        Int32 CustGroupID = 0;

        using (DDMSEntities ctx = new DDMSEntities())
        {
            if (ctx.CGRPs.Any(x => x.CustGroupName == CustGroupName))
                CustGroupID = ctx.CGRPs.FirstOrDefault(x => x.CustGroupName == CustGroupName).CustGroupID;
        }

        return CustGroupID;
    }

    //[WebMethod]
    //public static Int32 GetEmpGroupID(string EmpGroupName)
    //{
    //    Int32 EmpGroupID = 0;

    //    using (DDMSEntities ctx = new DDMSEntities())
    //    {
    //        if (ctx.OGRPs.Any(x => x.EmpGroupName == EmpGroupName))
    //            EmpGroupID = ctx.OGRPs.FirstOrDefault(x => x.EmpGroupName == EmpGroupName).EmpGroupID;
    //    }

    //    return EmpGroupID;
    //}

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<WhatsAppBusinessEmp> SearchEmployeeGroup(string prefixText)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            List<WhatsAppBusinessEmp> StrCust = new List<WhatsAppBusinessEmp>();
            if (prefixText == "*")
            {
                // StrCust = ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new WhatsAppBusinessEmp
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }
            else
            {
                //StrCust = ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).Take(20).ToList();
                StrCust = (from c in ctx.OGRPs.Where(x => x.EmpGroupName.Contains(prefixText) && x.ParentID == ParentID).OrderBy(x => x.EmpGroupName)
                           select new WhatsAppBusinessEmp
                           {
                               Text = (c.EmpGroupName + " # " + c.EmpGroupDesc + " # " + SqlFunctions.StringConvert((double)c.EmpGroupID).Trim()),
                               Value = c.EmpGroupID
                           }).Take(20).ToList();
            }

            return StrCust;
        }
    }

    [WebMethod]
    //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<WhatsAppBusinessEmp> SearchEmployee(string prefixText, string strEmpGroupId)
    {
        using (var ctx = new DDMSEntities())
        {
            decimal ParentID = Convert.ToDecimal(HttpContext.Current.Session["ParentID"]);
            Int32 EmpId = Convert.ToInt32(HttpContext.Current.Session["UserID"]);
            OEMP ObjEmp = ctx.OEMPs.Where(x => x.EmpID == EmpId).FirstOrDefault();
            int EmpGroupId = Int32.TryParse(strEmpGroupId, out EmpGroupId) && EmpGroupId > 0 ? EmpGroupId : 0;
            List<WhatsAppBusinessEmp> StrCust = new List<WhatsAppBusinessEmp>();
            if (prefixText == "*")
            {
                StrCust = (from c in ctx.OEMPs.Where(x => x.ParentID == ParentID && (EmpGroupId == 0 || x.EmpGroupID == EmpGroupId)).OrderBy(x => x.Name)
                           select new WhatsAppBusinessEmp
                           {
                               Text = (c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()),
                               Value = c.EmpID
                           }).Take(20).ToList();
            }
            else
            {
                StrCust = (from c in ctx.OEMPs.Where(x => (x.UserName.Contains(prefixText) || x.EmpCode.Contains(prefixText) || x.Name.Contains(prefixText)) && x.ParentID == ParentID && (EmpGroupId == 0 || x.EmpGroupID == EmpGroupId)).OrderBy(x => x.Name)
                           select new WhatsAppBusinessEmp
                           {
                               Text = (c.EmpCode + " - " + c.Name + " - " + SqlFunctions.StringConvert((double)c.EmpID).Trim()).Trim(),
                               Value = c.EmpID
                           }).Take(20).ToList();
            }

            return StrCust;
        }
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
            chkActive.Checked = chkIsActive.Checked = true;
            ViewState["ScheduleDataID"] = null;
            btnAddScheduleData.Text = "Add Configuration Data";
        }
        if (e.CommandName == "editData")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            var objSCHDL1 = SCHDL1s[LineID];
            ddlMsgFor.SelectedValue = objSCHDL1.MessageTo.ToString();
            ctx = new DDMSEntities();
            if (ddlMsgFor.SelectedValue == "E")
            {
                divEmpGroup.Visible = true;
                divEmp.Visible = true;
                divSS.Visible = false;
                divEmpCustomer.Visible = false;
                divDist.Visible = false;
                divDealer.Visible = false;
                divRegion.Visible = false;
                if (!string.IsNullOrEmpty(objSCHDL1.EmpGroup))
                    txtEmpGroup.Text = objSCHDL1.EmpGroup + " # " + objSCHDL1.EmpGroupID; // ctx.OGRPs.FirstOrDefault(x => x.EmpGroupID == objSCHDL1.EmpGroupID) " # " + objSCHDL1.EmpGroupID;
                else
                    txtEmpGroup.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.EmpName))
                    txtEmpCode.Text = objSCHDL1.EmpName + " - " + objSCHDL1.EmpID;
                else
                    txtEmpCode.Text = "";
            }
            else if (ddlMsgFor.SelectedValue == "C")
            {
                if (!string.IsNullOrEmpty(objSCHDL1.RegionName))
                    txtRegion.Text = ctx.OCSTs.FirstOrDefault(x => x.StateID == objSCHDL1.RegionID).GSTStateCode + " - " + objSCHDL1.RegionName + " - " + objSCHDL1.RegionID;
                else
                    txtRegion.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.DistributorCode))
                    txtDistributor.Text = objSCHDL1.DistributorCode + " - " + objSCHDL1.DistributorID;
                else
                    txtDistributor.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.SSCode))
                    txtSSCode.Text = objSCHDL1.SSCode + " - " + objSCHDL1.SSID;
                else
                    txtSSCode.Text = "";
                if (!string.IsNullOrEmpty(objSCHDL1.DealerCode))
                    txtDealer.Text = objSCHDL1.DealerCode + " - " + objSCHDL1.DealerID;
                else
                    txtDealer.Text = "";

                if (!string.IsNullOrEmpty(objSCHDL1.EmpName))
                    txtEmpCustCode.Text = objSCHDL1.EmpName + " - " + objSCHDL1.EmpID;
                else
                    txtEmpCustCode.Text = "";
            }
            if (ddlAppliFor.SelectedValue == "W")
            {
                divweekly.Visible = true;
                divMonthly.Visible = false;
                string[] week = objSCHDL1.WeekDays.Split(',');
                int j = 0;
                for (int i = 0; i < week.Length; i++)
                {
                    if (week[i] == "1")
                    {
                        chkSunday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkSunday.Checked = false;
                        }
                    }
                    if (week[i] == "2")
                    {
                        chkMonday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkMonday.Checked = false;
                        }
                    }
                    if (week[i] == "3")
                    {
                        chkTuesday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkTuesday.Checked = false;
                        }
                    }
                    if (week[i] == "4")
                    {
                        chkWednesday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkWednesday.Checked = false;
                        }
                    }
                    if (week[i] == "5")
                    {
                        chkThursday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkThursday.Checked = false;
                        }
                    }
                    if (week[i] == "6")
                    {
                        chkFriday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkFriday.Checked = false;
                        }
                    }
                    if (week[i] == "7")
                    {
                        chkSaturday.Checked = true;
                    }
                    else
                    {
                        if (j == 0)
                        {
                            chkSaturday.Checked = false;
                        }
                    }
                    j++;
                }
            }
            else if (ddlAppliFor.SelectedValue == "M")
            {
                divweekly.Visible = false;
                divMonthly.Visible = true;
                ddlDay1.SelectedValue = objSCHDL1.Day1.ToString();
                ddlDay2.SelectedValue = objSCHDL1.Day2.ToString();
                ddlDay3.SelectedValue = objSCHDL1.Day3.ToString();
            }
            else
            {
                divweekly.Visible = false;
                divMonthly.Visible = false;
                chkSunday.Checked = false;
                chkMonday.Checked = false;
                chkTuesday.Checked = false;
                chkWednesday.Checked = false;
                chkThursday.Checked = false;
                chkFriday.Checked = false;
                chkSaturday.Checked = false;
                ddlDay1.SelectedValue = "0";
                ddlDay1.SelectedValue = "0";
                ddlDay1.SelectedValue = "0";
            }
            // ddlAppliFor_SelectedIndexChanged(sender, e);
            chkIsActive.Checked = objSCHDL1.Active;
            chkIsInclude.Checked = objSCHDL1.IsInclude;
            ViewState["ScheduleDataID"] = LineID;
            btnAddScheduleData.Text = "Update Configuration Data";
        }
    }
    #endregion

    #region Button Click
    protected void btnAddScheduleData_Click(object sender, EventArgs e)
    {
        if (SCHDL1s == null || SCHDL1s.Count == 0)
            SCHDL1s = new List<ScheduleData>();

        int LineID;
        string weekDay = "", DayofWeek = "";
        Int16 Day1 = 0, Day2 = 0, Day3 = 0;
        Int32 msgcode = 0;
        if (!string.IsNullOrEmpty(txtMessageCode.Text))
        {
            msgcode = txtMessageCode.Text == "Auto Generated" ? 0 : Convert.ToInt32(txtMessageCode.Text);
        }
        if (!Validation()) return;
        if (ddlAppliFor.SelectedValue == "W")
        {
            int SelectDay = 0;
            if (chkSunday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Sunday,";
                DayofWeek = DayofWeek + "1,";
            }
            if (chkMonday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Monday,";
                DayofWeek = DayofWeek + "2,";
            }
            if (chkTuesday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Tuesday,";
                DayofWeek = DayofWeek + "3,";
            }
            if (chkWednesday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Wednesday,";
                DayofWeek = DayofWeek + "4,";
            }
            if (chkThursday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Thursday,";
                DayofWeek = DayofWeek + "5,";
            }
            if (chkFriday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Friday,";
                DayofWeek = DayofWeek + "6,";
            }
            if (chkSaturday.Checked)
            {
                SelectDay = SelectDay + 1;
                weekDay = weekDay + "Saturday,";
                DayofWeek = DayofWeek + "7,";
            }
            if (SelectDay == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select at least one day.',3);", true);
                return;
            }
            if (SelectDay > 2)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select only 2 days.',3);", true);
                return;
            }
        }
        else if (ddlAppliFor.SelectedValue == "M")
        {
            Day1 = Convert.ToInt16(ddlDay1.SelectedValue);
            Day2 = Convert.ToInt16(ddlDay2.SelectedValue);
            Day3 = Convert.ToInt16(ddlDay3.SelectedValue);
            if (Day1 == 0 && Day2 == 0 && Day3 == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Select at least 1 date.',3);", true);
                return;
            }
            if (Day1 > 0 && Day2 > 0)
            {
                if (Day1 == Day2)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 1 and Date 2.',3);", true);
                    return;
                }
            }
            if (Day1 > 0 && Day3 > 0)
            {
                if (Day1 == Day3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 1 and Date 3',3);", true);
                    return;
                }
            }
            if (Day2 > 0 && Day3 > 0)
            {
                if (Day2 == Day3)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You can not select same Date on Date 2 and Date 3',3);", true);
                    return;
                }
            }

        }
        if (ddlMsgFor.SelectedValue == "E")
        {
            if (!string.IsNullOrEmpty(txtEmpGroup.Text) || !string.IsNullOrEmpty(txtEmpCode.Text))
            {
                Int32 EmpGroupID = 0; Int32 EmpID = 0;
                EmpID = Int32.TryParse(txtEmpCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (!string.IsNullOrEmpty(txtEmpCode.Text))
                    {
                        if (ctx.OEMPs.Any(x => x.EmpID == EmpID))
                        {
                            ScheduleData Data = null;

                            string EmpGroup = ctx.OGRPs.Where(x => x.EmpGroupID == EmpGroupID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).FirstOrDefault();
                            string EmpName = "";

                            if (!string.IsNullOrEmpty(txtEmpCode.Text))
                            {
                                if (ctx.OEMPs.Any(x => x.EmpID == EmpID))
                                {
                                    EmpName = ctx.OEMPs.Where(x => x.EmpID == EmpID).Select(x => x.EmpCode + " - " + x.Name).FirstOrDefault();
                                }
                            }
                            if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                            {
                                Data = SCHDL1s[LineID];

                                Data.DealerID = null;
                                Data.DealerCode = null;
                                Data.DistributorID = null;
                                Data.DistributorCode = null;
                                Data.SSID = null;
                                Data.SSCode = null;
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
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Employee  - " + txtEmpCode.Text + "  - is already exist.',3);", true);
                                    return;
                                }
                            }
                            Data.WeekDayName = weekDay.TrimEnd(',');
                            Data.WeekDays = DayofWeek.TrimEnd(',');
                            Data.Day1 = Day1;
                            Data.Day2 = Day2;
                            Data.Day3 = Day3;
                            Data.MessageTo = ddlMsgFor.SelectedValue;
                            Data.MessagePeriod = ddlAppliFor.SelectedValue;
                            Data.MessageType = ddlMessageType.SelectedValue.ToString();
                            Data.CreatedDate = DateTime.Now;
                            Data.UpdateDate = DateTime.Now;
                            Data.Active = chkIsActive.Checked;
                            Data.IsInclude = chkIsInclude.Checked;
                            ViewState["ScheduleDataID"] = null;
                            btnAddScheduleData.Text = "Add Configuration Data";
                            txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpGroup.Text = txtSSCode.Text = txtEmpCustCode.Text = "";
                            chkIsInclude.Checked = chkIsActive.Checked = true;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper employee.',3);", true);
                            return;
                        }
                    }
                    else if (!string.IsNullOrEmpty(txtEmpGroup.Text))
                    {
                        ScheduleData Data = null;

                        string empGroupName = txtEmpGroup.Text.Split("#".ToArray()).First().Trim();
                        if (ctx.OGRPs.Any(x => x.EmpGroupName == empGroupName))
                        {
                            EmpGroupID = ctx.OGRPs.FirstOrDefault(x => x.EmpGroupName == empGroupName).EmpGroupID;

                            if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                            {
                                Data = SCHDL1s[LineID];

                                Data.DealerID = null;
                                Data.DealerCode = null;
                                Data.DistributorID = null;
                                Data.DistributorCode = null;
                                Data.SSID = null;
                                Data.SSCode = null;
                                Data.RegionID = null;
                                Data.RegionName = null;
                                Data.EmpID = null;
                                Data.EmpName = null;
                                Data.EmpGroupID = EmpGroupID;
                                Data.EmpGroup = ctx.OGRPs.Where(x => x.EmpGroupID == EmpGroupID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).DefaultIfEmpty().FirstOrDefault();
                            }
                            else
                            {
                                if (!SCHDL1s.Any(x => x.EmpGroupID == EmpGroupID))
                                {
                                    Data = new ScheduleData();
                                    Data.EmpGroupID = EmpGroupID;
                                    Data.EmpGroup = ctx.OGRPs.Where(x => x.EmpGroupID == EmpGroupID).Select(x => x.EmpGroupName + " # " + x.EmpGroupDesc).DefaultIfEmpty().FirstOrDefault();

                                    SCHDL1s.Add(Data);
                                }
                                else
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Employee group  - " + txtEmpGroup.Text + "  - is already exist.',3);", true);
                                    return;
                                }
                            }
                            Data.WeekDayName = weekDay.TrimEnd(',');
                            Data.WeekDays = DayofWeek.TrimEnd(',');
                            Data.Day1 = Day1;
                            Data.Day2 = Day2;
                            Data.Day3 = Day3;
                            Data.MessageTo = ddlMsgFor.SelectedValue;
                            Data.MessagePeriod = ddlAppliFor.SelectedValue;
                            Data.MessageType = ddlMessageType.SelectedValue.ToString();
                            Data.CreatedDate = DateTime.Now;
                            Data.UpdateDate = DateTime.Now;
                            Data.Active = chkIsActive.Checked;
                            Data.IsInclude = chkIsInclude.Checked;
                            ViewState["ScheduleDataID"] = null;
                            btnAddScheduleData.Text = "Add Configuration Data";
                            txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpGroup.Text = txtSSCode.Text = txtEmpCustCode.Text = "";
                            chkIsInclude.Checked = chkIsActive.Checked = true;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper employee group.',3);", true);
                            return;
                        }
                    }
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please add at least one configuration.',3);", true);
                return;
            }
        }
        else if (ddlMsgFor.SelectedValue == "C")
        {
            if (!string.IsNullOrEmpty(txtDealer.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Decimal DealerID = Decimal.TryParse(txtDealer.Text.Split("-".ToArray()).Last().Trim(), out DealerID) ? DealerID : 0;
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
                            Data.SSID = null;
                            Data.SSCode = null;
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
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Dealer  - " + txtDealer.Text + "  - is already exist.',3);", true);
                                return;
                            }
                        }
                        Data.WeekDayName = weekDay.TrimEnd(',');
                        Data.WeekDays = DayofWeek.TrimEnd(',');
                        Data.Day1 = Day1;
                        Data.Day2 = Day2;
                        Data.Day3 = Day3;
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        Data.MessagePeriod = ddlAppliFor.SelectedValue;
                        Data.MessageType = ddlMessageType.SelectedValue.ToString();
                        Data.CreatedDate = DateTime.Now;
                        Data.UpdateDate = DateTime.Now;
                        Data.Active = chkIsActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Configuration Data";
                        txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpGroup.Text = txtSSCode.Text = txtEmpCustCode.Text = "";
                        chkIsInclude.Checked = chkIsActive.Checked = true;
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
                            Data.SSID = null;
                            Data.SSCode = null;
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
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Distributor  - " + txtDistributor.Text + "  - is already exist.',3);", true);
                                return;
                            }
                        }
                        Data.WeekDayName = weekDay.TrimEnd(',');
                        Data.WeekDays = DayofWeek.TrimEnd(',');
                        Data.Day1 = Day1;
                        Data.Day2 = Day2;
                        Data.Day3 = Day3;
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        Data.MessagePeriod = ddlAppliFor.SelectedValue;
                        Data.CreatedDate = DateTime.Now;
                        Data.UpdateDate = DateTime.Now;
                        Data.Active = chkIsActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        Data.MessageType = ddlMessageType.SelectedValue.ToString();
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Configuration Data";
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        txtSSCode.Text = txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpCustCode.Text = "";
                        chkIsActive.Checked = chkIsInclude.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Distributor.',3);", true);
                }
            }
            else if (!string.IsNullOrEmpty(txtSSCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Decimal SSID = Decimal.TryParse(txtSSCode.Text.Split("-".ToArray()).Last().Trim(), out SSID) ? SSID : 0;

                    if (ctx.OCRDs.Any(x => x.CustomerID == SSID && x.Type == 4))
                    {
                        string SSCode = ctx.OCRDs.Where(x => x.CustomerID == SSID && x.Type == 4).Select(x => x.CustomerCode + " # " + x.CustomerName).FirstOrDefault();

                        ScheduleData Data = null;
                        if (ViewState["ScheduleDataID"] != null && Int32.TryParse(ViewState["ScheduleDataID"].ToString(), out LineID))
                        {
                            Data = SCHDL1s[LineID];

                            Data.DealerID = null;
                            Data.DealerCode = null;
                            Data.DistributorID = null;
                            Data.DistributorCode = null;
                            Data.SSID = SSID;
                            Data.SSCode = SSCode;
                            Data.RegionID = null;
                            Data.RegionName = null;
                            Data.EmpID = null;
                            Data.EmpName = null;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.SSID == SSID))
                            {
                                Data = new ScheduleData();
                                Data.SSID = SSID;
                                Data.SSCode = SSCode;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Super Stockist  - " + txtSSCode.Text + "  - is already exist.',3);", true);
                                return;
                            }
                        }
                        Data.WeekDayName = weekDay.TrimEnd(',');
                        Data.WeekDays = DayofWeek.TrimEnd(',');
                        Data.Day1 = Day1;
                        Data.Day2 = Day2;
                        Data.Day3 = Day3;
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        Data.MessagePeriod = ddlAppliFor.SelectedValue;
                        Data.CreatedDate = DateTime.Now;
                        Data.UpdateDate = DateTime.Now;
                        Data.Active = chkIsActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        Data.MessageType = ddlMessageType.SelectedValue.ToString();
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Configuration Data";
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        txtSSCode.Text = txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpCustCode.Text = "";
                        chkIsActive.Checked = chkIsInclude.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Super Stockist.',3);", true);
                }
            }
            else if (!string.IsNullOrEmpty(txtEmpCustCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int EmpID = Int32.TryParse(txtEmpCustCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

                    if (ctx.OEMPs.Any(x => x.EmpID == EmpID && x.ParentID == ParentID))
                    {
                        var EmpCodeName = ctx.OEMPs.Where(x => x.EmpID == EmpID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).DefaultIfEmpty().FirstOrDefault();

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
                            Data.SSID = null;
                            Data.SSCode = null;
                            Data.EmpID = EmpID;
                            Data.EmpName = EmpCodeName;
                            Data.EmpGroupID = null;
                            Data.EmpGroup = null;
                        }
                        else
                        {
                            if (!SCHDL1s.Any(x => x.EmpID == EmpID))
                            {
                                Data = new ScheduleData();
                                Data.EmpID = EmpID;
                                Data.EmpName = EmpCodeName;

                                SCHDL1s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Employee  - " + txtEmpCustCode.Text + "  - is already exist.',3);", true);
                                return;
                            }
                        }
                        Data.WeekDayName = weekDay.TrimEnd(',');
                        Data.WeekDays = DayofWeek.TrimEnd(',');
                        Data.Day1 = Day1;
                        Data.Day2 = Day2;
                        Data.Day3 = Day3;
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        Data.MessagePeriod = ddlAppliFor.SelectedValue;
                        Data.CreatedDate = DateTime.Now;
                        Data.UpdateDate = DateTime.Now;
                        Data.Active = chkIsActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        Data.MessageType = ddlMessageType.SelectedValue.ToString();
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Configuration Data";
                        Data.MessageTo = ddlMsgFor.SelectedValue;

                        txtSSCode.Text = txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpCustCode.Text = "";
                        // ddlEmpCategory.SelectedValue = "0";
                        chkIsActive.Checked = chkIsInclude.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Employee.',3);", true);
                }
            }
            else if (!string.IsNullOrEmpty(txtRegion.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;

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
                            Data.SSID = null;
                            Data.SSCode = null;
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
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Region  - " + txtRegion.Text + "  - is already exist.',3);", true);
                                return;
                            }
                        }
                        Data.WeekDayName = weekDay.TrimEnd(',');
                        Data.WeekDays = DayofWeek.TrimEnd(',');
                        Data.Day1 = Day1;
                        Data.Day2 = Day2;
                        Data.Day3 = Day3;
                        Data.MessageTo = ddlMsgFor.SelectedValue;
                        Data.MessagePeriod = ddlAppliFor.SelectedValue;
                        Data.Active = chkIsActive.Checked;
                        Data.IsInclude = chkIsInclude.Checked;
                        Data.CreatedDate = DateTime.Now;
                        Data.UpdateDate = DateTime.Now;
                        Data.MessageType = ddlMessageType.SelectedValue.ToString();
                        ViewState["ScheduleDataID"] = null;
                        btnAddScheduleData.Text = "Add Configuration Data";
                        Data.MessageTo = ddlMsgFor.SelectedValue;

                        txtSSCode.Text = txtEmpCode.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtEmpCustCode.Text = "";
                        // ddlEmpCategory.SelectedValue = "0";
                        chkIsActive.Checked = chkIsInclude.Checked = true;
                    }
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper Region.',3);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please add at least one configuration.',3);", true);
                return;
            }
        }
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
        ddlDay1.SelectedValue = "0";
        ddlDay2.SelectedValue = "0";
        ddlDay3.SelectedValue = "0";
        chkMonday.Checked = false;
        chkTuesday.Checked = false;
        chkWednesday.Checked = false;
        chkThursday.Checked = false;
        chkFriday.Checked = false;
        chkSaturday.Checked = false;
        chkSunday.Checked = false;
    }

    protected void btnCancleScheduleData_Click(object sender, EventArgs e)
    {
        btnAddScheduleData.Text = "Add Configuration Data";
        txtEmpCode.Text = txtEmpGroup.Text = txtRegion.Text = txtDistributor.Text = txtDealer.Text = txtSSCode.Text = txtEmpCustCode.Text = ""; // txtfromdate.Text = txttodate.Text =
        //ddlAppliFor.SelectedValue = "D";
        //ddlMsgFor.SelectedValue = "E";
        chkActive.Checked = chkIsActive.Checked = true;
        ViewState["ScheduleDataID"] = null;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (string.IsNullOrEmpty(txtfromdate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select from date!',3);", true);
                    return;
                }
                if (string.IsNullOrEmpty(txttodate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select to date!',3);", true);
                    return;
                }
                if(string.IsNullOrEmpty(txtMobileNo.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Enter CCMobile Number!',3);", true);
                    return;
                }
                
                if (txtMobileNo.Text.Length != 10)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please Enter valid CCMobile Number!',3);", true);
                    return;
                }
                if (chkMode.Checked && Convert.ToDateTime(txtfromdate.Text).Date < DateTime.Now.Date)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select future date!',3);", true);
                    return;
                }
                if (SCHDL1s == null || SCHDL1s.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select at least one configration!',3);", true);
                    return;
                }
                // if (!Validation()) return;
                int ScheduleID;
                ctx = new DDMSEntities();
                string fileName = flCUpload.FileName;
                OWPM objOWPM = new OWPM();
                if (ViewState["ScheduleID"] != null && Int32.TryParse(ViewState["ScheduleID"].ToString(), out ScheduleID))
                {
                    if (hdnImageHasValue.Value != "")
                    {
                        fileName = hdnImageHasValue.Value;
                    }
                    else
                    {
                        if (ddlMessageType.SelectedValue == "Promotional")
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", true);
                            return;
                        }
                           
                    }
                    objOWPM = ctx.OWPMs.Include("WPM1").FirstOrDefault(x => x.OWPMID == ScheduleID);
                    if (!flCUpload.HasFile)
                    {
                        fileName = hdnImageHasValue.Value;
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(fileName))
                        {
                            string ext = System.IO.Path.GetExtension(flCUpload.FileName);
                            if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".bmp" || ext.ToLower() == ".eml" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf" || ext.ToLower() == ".mp4" || ext.ToLower() == ".xls" || ext.ToLower() == ".xlsx")
                            {
                                if (!Directory.Exists(Server.MapPath("~/Document/WhatsAppMessageBroadCast/")))
                                {
                                    Directory.CreateDirectory(Server.MapPath("~/Document/WhatsAppMessageBroadCast/"));
                                }
                                string filePath = Server.MapPath("~/Document/WhatsAppMessageBroadCast/") + objOWPM.ImageUpload;
                                if (System.IO.File.Exists(filePath))
                                {
                                    System.IO.File.Delete(filePath);
                                }
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", true);
                                return;
                            }
                            fileName = System.IO.Path.Combine(Guid.NewGuid().ToString("N") + System.IO.Path.GetExtension(flCUpload.FileName));
                            flCUpload.SaveAs(Server.MapPath("~/Document/WhatsAppMessageBroadCast/") + fileName);
                        }
                    }
                }
                else
                {
                    if (flCUpload.HasFile)
                    {
                        string ext = System.IO.Path.GetExtension(flCUpload.FileName);
                        if (ext.ToLower() == ".png" || ext.ToLower() == ".jpg" || ext.ToLower() == ".bmp" || ext.ToLower() == ".eml" || ext.ToLower() == ".jpeg" || ext.ToLower() == ".pdf" || ext.ToLower() == ".mp4" || ext.ToLower() == ".xls" || ext.ToLower() == ".xlsx")
                        {
                            
                            string filePath = Server.MapPath("~/Document/WhatsAppMessageBroadCast/") + objOWPM.ImageUpload;
                            if (System.IO.File.Exists(filePath))
                            {
                                System.IO.File.Delete(filePath);
                            }
                            fileName = System.IO.Path.Combine(Guid.NewGuid().ToString("N") + System.IO.Path.GetExtension(flCUpload.FileName));
                            flCUpload.SaveAs(Server.MapPath("~/Document/WhatsAppMessageBroadCast/") + fileName);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", true);
                            return;    
                        }
                    }
                    else
                    {
                        if (ddlMessageType.SelectedValue == "Promotional")
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", true);
                            return;
                        } 
                    }

                    objOWPM = new OWPM();
                    // objOWPM.OWPMID = ctx.GetKey("OWPM", "OWPMID", "", ParentID, 0).FirstOrDefault().Value;
                    objOWPM.ParentID = ParentID;
                    //objOMSG.MessageDate = DateTime.Now;
                    //objOMSG.MessageTime = DateTime.Now.TimeOfDay;

                    objOWPM.CreatedDate = DateTime.Now;
                    objOWPM.CreatedBy = UserID;
                    objOWPM.MobileNo = Convert.ToDecimal(txtMobileNo.Text);
                    ctx.OWPMs.Add(objOWPM);
                }
                if (!chkMode.Checked && objOWPM.WPM1 != null && objOWPM.WPM1.Count() > 0)
                {
                    objOWPM.WPM1.ToList().ForEach(x => ctx.WPM1.Remove(x));
                }
                objOWPM.ImageUpload = fileName;
                objOWPM.FromDate = Convert.ToDateTime(txtfromdate.Text);
                objOWPM.ToDate = Convert.ToDateTime(txttodate.Text);
                objOWPM.MobileNo = Convert.ToDecimal(txtMobileNo.Text);
                objOWPM.MessagePeriod = ddlAppliFor.SelectedValue.ToString();
                objOWPM.MessageTo = ddlMsgFor.SelectedValue.ToString().Trim();
                objOWPM.Active = chkActive.Checked;
                objOWPM.ParentID = ParentID;
                objOWPM.UpdateDate = DateTime.Now;
                objOWPM.UpdateBy = UserID;
                objOWPM.MessageType = ddlMessageType.SelectedValue.ToString();
                objOWPM.MessageFor = ddlMessageFor.SelectedValue.ToString();
                if (ddlMsgFor.SelectedValue == "E")
                {
                    objOWPM.MessageFor = null;
                }

                //int Count = ctx.GetKey("WPM1", "WPM1ID", "", ParentID, 0).FirstOrDefault().Value;

                if (!chkMode.Checked && objOWPM.WPM1 != null && objOWPM.WPM1.Count() > 0)
                {
                    objOWPM.WPM1.ToList().ForEach(x => ctx.WPM1.Remove(x));
                }

                if (SCHDL1s != null)
                {
                    objOWPM.WPM1.ToList().ForEach(x => ctx.WPM1.Remove(x));

                    foreach (ScheduleData item in SCHDL1s)
                    {
                        if (item.DistributorID > 0 || item.RegionID > 0 || item.EmpID > 0 || item.EmpGroupID > 0 || item.DealerID > 0 || item.SSID > 0)
                        {
                            WPM1 objWPM1 = new WPM1();

                            if (ddlMsgFor.SelectedValue == "C")
                            {
                                if (item.RegionID.GetValueOrDefault(0) > 0)
                                    objWPM1.DistRegionID = item.RegionID;
                                else
                                    objWPM1.DistRegionID = null;

                                if (item.SSID.GetValueOrDefault(0) > 0)
                                    objWPM1.SSID = item.SSID;
                                else
                                    objWPM1.SSID = null;

                                if (item.DistributorID.GetValueOrDefault(0) > 0)
                                    objWPM1.DistributorID = item.DistributorID;
                                else
                                    objWPM1.DistributorID = null;

                                if (item.DealerID.GetValueOrDefault(0) > 0)
                                    objWPM1.DealerID = item.DealerID;
                                else
                                    objWPM1.DealerID = null;
                                if (item.EmpID.GetValueOrDefault(0) > 0)
                                    objWPM1.EmpID = item.EmpID;
                                else
                                    objWPM1.EmpID = null;

                                objWPM1.EmpGroupID = 0;

                            }
                            else
                            {
                                objWPM1.DistRegionID = 0;
                                objWPM1.SSID = 0; objWPM1.DistributorID = 0; objWPM1.DealerID = 0;
                                if (item.EmpGroupID.GetValueOrDefault(0) > 0)
                                    objWPM1.EmpGroupID = item.EmpGroupID;
                                else
                                    objWPM1.EmpGroupID = null;

                                if (item.EmpID.GetValueOrDefault(0) > 0)
                                    objWPM1.EmpID = item.EmpID;
                                else
                                    objWPM1.EmpID = null;
                            }
                            objWPM1.WeekDays = item.WeekDays == null ? "" : Convert.ToString(item.WeekDays).TrimEnd(',');
                            objWPM1.Day1 = Convert.ToInt16(Convert.ToString(item.Day1));
                            objWPM1.Day2 = Convert.ToInt16(Convert.ToString(item.Day2));
                            objWPM1.Day3 = Convert.ToInt16(Convert.ToString(item.Day3));
                            objWPM1.CreatedDate = DateTime.Now;
                            objWPM1.CreatedBy = UserID;
                            objWPM1.UpdatedDate = DateTime.Now;
                            objWPM1.UpdateBy = UserID;
                            objWPM1.IsInclude = item.IsInclude;
                            objWPM1.Active = item.Active;
                            objWPM1.IsDeleted = false;
                            objOWPM.WPM1.Add(objWPM1);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Enter at least One Mapping!',3);", true);
                            return;
                        }
                    }
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOWPM.OWPMID + "',1);", true);
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
        Response.Redirect("WhatsAppBusinessConfiguation.aspx");
    }
    #endregion

    #region CheckBox Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
        
    }
    #endregion

    #region dropdown change events
    protected void ddlMsgFor_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMsgFor.SelectedValue == "C")
        {
            divEmpGroup.Visible = false;
            divEmp.Visible = false;
            divSS.Visible = true;
            divDist.Visible = true;
            divDealer.Visible = true;
            divRegion.Visible = true;
            divmessageFor.Visible = true;
            divEmpCustomer.Visible = true;
            ddlMessageFor_SelectedIndexChanged(sender, e);
            if (ddlMessageType.SelectedValue == "Sales Invoice" || ddlMessageType.SelectedValue == "Sales Return")
            {
                ddlMessageFor.Items.Clear();
                ddlMessageFor.Items.Insert(0, new ListItem("Distributor", "Distributor"));
                ddlMessageFor.Items.Insert(1, new ListItem("Dealer", "Dealer"));
                divSS.Visible = false;
                divDist.Visible = true;
                //imgMessage.Visible = false;
            }
            else
            {
                //imgMessage.Visible = false;
                divSS.Visible = true;
                divDist.Visible = false;
                ddlMessageFor.Items.Clear();
                ddlMessageFor.Items.Insert(0, new ListItem("Super Stockist", "SS"));
                ddlMessageFor.Items.Insert(1, new ListItem("Distributor", "Distributor"));
                ddlMessageFor.Items.Insert(2, new ListItem("Dealer", "Dealer"));

            }


        }
        else if (ddlMsgFor.SelectedValue == "E")
        {
            divmessageFor.Visible = false;
            divEmpGroup.Visible = true;
            divEmp.Visible = true;
            divSS.Visible = false;
            divDist.Visible = false;
            divDealer.Visible = false;
            divRegion.Visible = false;
            divEmpCustomer.Visible = false;
        }
        ddlMessageFor_SelectedIndexChanged(sender, e);
        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
    }

    protected void ddlAppliFor_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlAppliFor.SelectedValue == "W")
        {
            divweekly.Visible = true;
            divMonthly.Visible = false;
        }
        else if (ddlAppliFor.SelectedValue == "M")
        {
            divweekly.Visible = false;
            divMonthly.Visible = true;
        }
        else
        {
            divMonthly.Visible = false;
            divweekly.Visible = false;
        }
        //ddlAppliFor_SelectedIndexChanged(sender, e);
        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();
    }

    protected void ddlMessageFor_SelectedIndexChanged(object sender, EventArgs e)
    {
        
        if (ddlMsgFor.SelectedValue == "C")
        {
            //if (ddlMessageType.SelectedValue == "Sales Invoice" || ddlMessageType.SelectedValue == "Sales Return")
            //{
            //    divSS.Visible = false;
            //}
            //else
            //{
            //    divSS.Visible = true;
            //}
            if (ddlMessageFor.SelectedValue == "SS")
            {
                
                
                divEmp.Visible = false;
                divEmpCustomer.Visible = true;
                divSS.Visible = true;
                divDist.Visible = false;
                divDealer.Visible = false;
            }
            else if (ddlMessageFor.SelectedValue == "Distributor")
            {
                divDist.Visible = true;
                divEmp.Visible = false;
                divEmpCustomer.Visible = true;
                divSS.Visible = false;
                divDealer.Visible = false;
                
            }
            else if (ddlMessageFor.SelectedValue == "Dealer")
            {
                divDist.Visible = true;
                divEmp.Visible = false;
                divEmpCustomer.Visible = true;
               
                divDealer.Visible = true;
                divSS.Visible = false;
            }
            txtRegion.Text = txtEmpCustCode.Text = txtSSCode.Text = txtDistributor.Text = txtDealer.Text = "";
        }
        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();

    }

    protected void ddlMessageType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMessageType.SelectedValue == "Sales Invoice" || ddlMessageType.SelectedValue == "Sales Return")
        {
            ddlMessageFor.Items.Clear();
            ddlMessageFor.Items.Insert(0, new ListItem("Distributor", "Distributor"));
            ddlMessageFor.Items.Insert(1, new ListItem("Dealer", "Dealer"));
            imgMessage.Visible = false;
            
            //divSS.Visible = false;
            divSS.Visible = false;
            divDist.Visible = true;
           // divDist.Visible = false;
        }
        else
        {
            ddlMessageFor.Items.Clear();
            ddlMessageFor.Items.Insert(0, new ListItem("Super Stockist", "SS"));
            ddlMessageFor.Items.Insert(1, new ListItem("Distributor", "Distributor"));
            ddlMessageFor.Items.Insert(2, new ListItem("Dealer", "Dealer"));
            imgMessage.Visible = true;
           divSS.Visible = true;
           //divDistributor.Visible = false;
           divDist.Visible = false;

        }
        if (ddlMessageType.SelectedValue== "Sales Invoice")
        {
            flCUpload.Visible = false;
            // ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", false);

            
        }
        else if(ddlMessageType.SelectedValue== "Sales Return")
        {
            flCUpload.Visible = false;
            
            //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select jpg, png, gif, jpeg, pdf,mp4,eml,xlsx and xls file!',3);", false);

            

        }
        else if (ddlMessageType.SelectedValue== "Promotional")
        {
            flCUpload.Visible = true;
        }
        
        SCHDL1s = new List<ScheduleData>();
        gvScheduleData.DataSource = SCHDL1s;
        gvScheduleData.DataBind();

    }
    #endregion

}