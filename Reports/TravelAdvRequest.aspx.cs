using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_TravelAdvRequest : System.Web.UI.Page
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
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
    }

    #endregion

    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ClearAllInputs();
            var TypeID = ctx.OEXTs.Where(x => x.Active).ToList();
            ddlExpenseType.DataSource = TypeID;
            ddlExpenseType.DataBind();
            ddlExpenseType.Items.Insert(0, new ListItem("---Select---", "0"));
            var ModeID = ctx.OEXMs.Where(x => x.Active).ToList();
            ddlExpenseMode.DataSource = ModeID;
            ddlExpenseMode.DataBind();
            ddlExpenseMode.Items.Insert(0, new ListItem("---Select---", "0"));
            var Status = ctx.OEAS.Where(x => x.Active).ToList();
            ddlStatus.DataSource = Status;
            ddlStatus.DataBind();
            ddlStatus.Items.Insert(0, new ListItem("---Select---", "0"));
        }
    }
    #endregion

    #region ButtonEvent

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
        int Manager = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out Manager) ? Manager : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmTrvlAdvReq.Attributes.Add("src", "../Reports/ViewReport.aspx?TravelRequestFromDate=" + txtFromDate.Text + "&TravelRequestToDate=" + txtToDate.Text + "&TravelRqstEmpID=" + EmpID + "&TravelRqstManagerID=" + Manager + "&TravelRqstStatusID=" + ddlStatus.SelectedValue + "&TravelTypeID=" + ddlExpenseType.SelectedValue + "&TravelModeID=" + ddlExpenseMode.SelectedValue + "&IsDetail=" + IsDetail);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;
        int Manager = Int32.TryParse(txtManager.Text.Split("-".ToArray()).Last().Trim(), out Manager) ? Manager : 0;
        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmTrvlAdvReq.Attributes.Add("src", "../Reports/ViewReport.aspx?TravelRequestFromDate=" + txtFromDate.Text + "&TravelRequestToDate=" + txtToDate.Text + "&TravelRqstEmpID=" + EmpID + "&TravelRqstManagerID=" + Manager + "&TravelRqstStatusID=" + ddlStatus.SelectedValue + "&TravelTypeID=" + ddlExpenseType.SelectedValue + "&TravelModeID=" + ddlExpenseMode.SelectedValue + "&IsDetail=" + IsDetail + "&Export=1");
    }

    protected void ifmTrvlAdvReq_Load(object sender, EventArgs e)
    {

    }
    #endregion

}