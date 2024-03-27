using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_EmployeeWiseBeatListing : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    protected decimal ParentID;
    protected String AuthType;

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
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
            ddlEGroup.DataSource = EmpG;
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));

            int EGID = Convert.ToInt32(Session["GroupID"]);
            if (ctx.OGRPs.Any(x => x.EmpGroupID == EGID && x.ParentID == ParentID && x.EmpGroupName.ToLower() == "dms team"))
                btnExportBeatDump.Visible = true;
            else
                btnExportBeatDump.Visible = false;
        }
        txtCode.Text = "";
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
    }

    #endregion

    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnExportBeatDump);
    }
    #endregion

    #region Button Events
    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        string GRPID = ddlEGroup.SelectedValue;
        int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : UserID;
        if (EmpID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Employee.',3);", true);
            return;
        }

        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmBeatlisting.Attributes.Add("src", "../Reports/ViewReport.aspx?BeatEmp=" + EmpID + "&BeatEmpGrpID=" + GRPID + "&IsDetail=" + IsDetail + "&BeatStatus=" + ddlBeatStatus.SelectedValue + "&EmpStatus=" + ddlEmpStatus.SelectedValue + "&BeatOption=" + ddlBeatOption.SelectedValue + "&SUserID=" + SUserID);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        string GRPID = ddlEGroup.SelectedValue;
        int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : UserID;
        if (EmpID == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper Employee.',3);", true);
            return;
        }

        Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;

        string IsDetail = chkIsDetail.Checked ? "1" : "0";
        ifmBeatlisting.Attributes.Add("src", "../Reports/ViewReport.aspx?BeatEmp=" + EmpID + "&BeatEmpGrpID=" + GRPID + "&IsDetail=" + IsDetail + "&BeatStatus=" + ddlBeatStatus.SelectedValue + "&EmpStatus=" + ddlEmpStatus.SelectedValue + "&BeatOption=" + ddlBeatOption.SelectedValue + "&SUserID=" + SUserID + "&Export=1");
    }

    protected void btnExportBeatDump_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ClearContent();
            Response.AddHeader("content-disposition", "attachment; filename=BeatDump.xls");
            Response.ContentType = "application/vnd.ms-excel";

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "ExportBeatDump";
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            GridView excel = new GridView();
            excel.DataSource = ds.Tables[0];
            excel.DataBind();
            excel.RenderControl(new HtmlTextWriter(Response.Output));
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);

        }
        Response.End();
    }

    protected void ifmBeatlisting_Load(object sender, EventArgs e)
    {

    }

    #endregion

}