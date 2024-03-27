using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_DeviceInfo : System.Web.UI.Page
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
        }
        txtCode.Text = "";
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        txtToDate.Text = txtFromDate.Text = Common.DateTimeConvert(DateTime.Now);
        gvdevice.DataSource = null;
        gvdevice.DataBind();
        // ddlEGroup.SelectedValue = "0";
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


    }

    #endregion

    #region Griedview Events

    protected void gvdevice_Prerender(object sender, EventArgs e)
    {
        if (gvdevice.Rows.Count > 0)
        {
            gvdevice.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvdevice.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    #region Button Events

    protected void btnGenerat_Click(object sender, EventArgs e)
    {

        try
        {
            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);
            int EmpID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out EmpID) ? EmpID : 0;

            decimal GRPID = Convert.ToInt32(ddlEGroup.SelectedValue);
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetDeviceInfo";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@FromDate", StartDate);
            Cm.Parameters.AddWithValue("@ToDate", EndDate);
            Cm.Parameters.AddWithValue("@EmpID", EmpID);
            Cm.Parameters.AddWithValue("@GroupID", GRPID);

            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            gvdevice.DataSource = ds.Tables[0];
            gvdevice.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }

    }

    #endregion
}