using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Reports_AttendenceRegister : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();
                    hdnIsAdmin.Value = ctx.OEMPs.Any(x => x.EmpID == UserID && x.ParentID == ParentID && x.IsAdmin == true).ToString();
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
        }
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        gvattendence.DataSource = null;
        gvattendence.DataBind();
        gvSummary.DataSource = null;
        gvSummary.DataBind();
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        //if (UserID == 1)
        //{
        //    divTHead.Visible = true;
        divEmpCode.Visible = false;
        //}
        //else
        //{
        //    divTHead.Visible = false;
        //    divEmpCode.Visible = true;
        //}

        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<DisData2> Data = new List<DisData2>();
            Data.AddRange(ctx.OLVTies.Where(m => m.Active).Select(x => new DisData2 { Value = x.LeaveCode, Text = x.LeaveName }).ToList());
            Data.AddRange(ctx.OATSTUs.Where(n => n.Active).Select(y => new DisData2 { Value = y.Code, Text = y.FullName }).ToList());
            Data.Add(new DisData2("PE", "Pending"));
            Data.Add(new DisData2("PI", "Punch In"));
            gvLeaveType.DataSource = Data;
            gvLeaveType.DataBind();
        }
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Griedview Events

    protected void gvattendence_Prerender(object sender, EventArgs e)
    {
        if (gvattendence.Rows.Count > 0)
        {
            gvattendence.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvattendence.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvSummary_PreRender(object sender, EventArgs e)
    {
        if (gvSummary.Rows.Count > 0)
        {
            gvSummary.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvSummary.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvDate_PreRender(object sender, EventArgs e)
    {
        if (gvDate.Rows.Count > 0)
        {
            gvDate.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvDate.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void gvLeaveType_PreRender(object sender, EventArgs e)
    {
        if (gvLeaveType.Rows.Count > 0)
        {
            gvLeaveType.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvLeaveType.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        DateTime FromDate = Convert.ToDateTime(txtFromDate.Text);
        DateTime ToDate = Convert.ToDateTime(txtToDate.Text);
        if ((ToDate - FromDate).TotalDays >= 31)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Date difference should be only 31 days.',3);", true);
            return;
        }
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {

                decimal GRPID = Convert.ToInt32(ddlEGroup.SelectedValue);
                Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
                if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                    return;
                }

                Int32 THeadID = Int32.TryParse(txtTtryHead.Text.Split("-".ToArray()).Last().Trim(), out THeadID) ? THeadID : 0;
                if (!string.IsNullOrEmpty(txtTtryHead.Text) && THeadID == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                    txtTtryHead.Focus();
                    return;
                }

                Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                SqlCommand Cm = new SqlCommand();
                Cm.Parameters.Clear();
                Cm.CommandType = CommandType.StoredProcedure;
                Cm.CommandText = "GetAttendenceRegister";
                Cm.Parameters.AddWithValue("@STARTDATE", FromDate);
                Cm.Parameters.AddWithValue("@ENDDATE", ToDate);
                Cm.Parameters.AddWithValue("@ParentID", ParentID);
                Cm.Parameters.AddWithValue("@EmpID", THeadID > 0 ? THeadID : UserID);
                Cm.Parameters.AddWithValue("@SUserID", SUserID);
                Cm.Parameters.AddWithValue("@GroupID", GRPID);
                Cm.Parameters.AddWithValue("@EmpType", ddlEmpType.SelectedValue);

                DataSet ds = objClass.CommonFunctionForSelect(Cm);
                if (ds.Tables.Count == 3)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        gvattendence.DataSource = ds.Tables[0];
                        gvattendence.DataBind();
                    }
                    if (ds.Tables[1].Rows.Count > 0)
                    {
                        gvDate.DataSource = ds.Tables[1];
                        gvDate.DataBind();
                    }
                    if (ds.Tables[2].Rows.Count > 0)
                    {
                        gvSummary.DataSource = ds.Tables[2];
                        gvSummary.DataBind();
                    }
                }
                else
                {
                    gvattendence.DataSource = null;
                    gvattendence.DataBind();
                    gvDate.DataSource = null;
                    gvDate.DataBind();
                    gvSummary.DataSource = null;
                    gvSummary.DataBind();
                }

            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    #endregion

}