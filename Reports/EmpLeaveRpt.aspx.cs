using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_EmpLeaveRpt : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx = new DDMSEntities();

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
                var UserType = Session["UserType"].ToString();
                int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
                string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
                int menuid = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && (UserType == "b" ? true : x.MenuType == UserType)).MenuID;
                var Auth = ctx.GRP1.Include("OMNU").FirstOrDefault(x => x.MenuID == menuid && x.EmpGroupID == EGID && x.ParentID == ParentID);
                if (Auth == null || Auth.AuthorizationType == "N")
                    Response.Redirect("~/AccessError.aspx");
                else if (!(CustType == 1 ? Auth.OMNU.Company : CustType == 2 ? Auth.OMNU.CMS : CustType == 3 ? Auth.OMNU.DMS : CustType == 4 ? Auth.OMNU.SS : false))
                    Response.Redirect("~/AccessError.aspx");
                else
                {
                    AuthType = Auth.AuthorizationType;
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
                        {

                        }
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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
            ddlEGroup.DataSource = EmpG;
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        }
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var LeaveID = ctx.OLVTies.Where(x => x.Active).ToList();
            ddlLeaveType.DataSource = LeaveID;
            ddlLeaveType.DataBind();
            ddlLeaveType.Items.Insert(0, new ListItem("---Select---", "0"));
        }
        txtToDate.Text = txtFromDate.Text = (DateTime.Now.Month - 1) + "/" + DateTime.Now.Year.ToString();
    }

    #endregion

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            var Status = ctx.OEAS.Where(x => x.Active && x.StatusFilter.Contains("E")).ToList();
            ddlStatus.DataSource = Status;
            ddlStatus.DataBind();
            ddlStatus.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }
    #endregion

    #region ButtonEvent
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        DateTime Todate1 = Convert.ToDateTime(txtToDate.Text);
        DateTime Todate = new DateTime(Todate1.Year, Todate1.Month, DateTime.DaysInMonth(Todate1.Year, Todate1.Month));

        int EmpGroupID = Convert.ToInt32(ddlEGroup.SelectedValue);
        int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.!',3);", true);
            return;
        }
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);
        ifmLeaveReq.Attributes.Add("src", "../Reports/ViewReport.aspx?EmpLeaveRptFromDate=" + Fromdate + "&EmpLeaveRptToDate=" + Todate + "&EmpID=" + UserID + "&LeaveRqstStatusID=" + ddlStatus.SelectedValue + "&LeaveTypeID=" + ddlLeaveType.SelectedValue + "&EmpGroupID=" + EmpGroupID + "&SUserID=" + SUserID + "&IpAddress=" + IPAdd);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        DateTime Fromdate = Convert.ToDateTime(txtFromDate.Text);
        DateTime Todate1 = Convert.ToDateTime(txtToDate.Text);
        DateTime Todate = new DateTime(Todate1.Year, Todate1.Month, DateTime.DaysInMonth(Todate1.Year, Todate1.Month));

        int EmpGroupID = Convert.ToInt32(ddlEGroup.SelectedValue);
        int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
        if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.!',3);", true);
            return;
        }
        string IPAdd = hdnIPAdd.Value;
        if (IPAdd == "undefined")
            IPAdd = "";
        if (IPAdd.Length > 15)
            IPAdd = IPAdd = IPAdd.Substring(0, 15);
        ifmLeaveReq.Attributes.Add("src", "../Reports/ViewReport.aspx?EmpLeaveRptFromDate=" + Fromdate + "&EmpLeaveRptToDate=" + Todate + "&EmpID=" + UserID + "&LeaveRqstStatusID=" + ddlStatus.SelectedValue + "&LeaveTypeID=" + ddlLeaveType.SelectedValue + "&EmpGroupID=" + EmpGroupID + "&SUserID=" + SUserID + "&IpAddress=" + IPAdd + "&Export=1");
    }
    #endregion

}