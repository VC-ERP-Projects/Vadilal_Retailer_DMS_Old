using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class CustomerFeedBack : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected String Version;



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

                    hdnUserName.Value = ctx.OEMPs.Where(x => x.EmpID == UserID && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault().ToString();

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

    private void ClearAllInputs()
    {
        txtFromDate.Text = txtToDate.Text = Common.DateTimeConvert(DateTime.Now);
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var Feedback = ctx.OFBTs.Where(x => x.Active).ToList();
                ddlType.DataSource = Feedback;
                ddlType.DataBind();
                ddlType.Items.Insert(0, new ListItem("---Select---", "0"));
            }
        }
        ScriptManager scriptManager = ScriptManager.GetCurrent(this.Page);
        scriptManager.RegisterPostBackControl(this.btnGenerat);
    }

    #endregion


    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        //ifmCustFeedBack.Attributes.Add("src", "../Reports/ViewReport.aspx?CustFeedBackFromDate=" + txtFromDate.Text + "&CustFeedBackToDate=" + txtToDate.Text + "&CustFeedBackType=" + ddlType.SelectedValue + "&CustFeedBackEmployee=" + SUserID);
        try
        {
            Int32 SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : 0;
            Int32 UserID = Int32.TryParse(Session["UserID"].ToString(), out UserID) ? UserID : 0;
            Decimal ParentID = Decimal.TryParse(Session["ParentID"].ToString(), out ParentID) ? ParentID : 0;

            SqlCommand Cm = new SqlCommand();
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();

            DateTime StartDate = Convert.ToDateTime(txtFromDate.Text);
            DateTime EndDate = Convert.ToDateTime(txtToDate.Text);

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCustomerFeedBackReport";

            Cm.Parameters.AddWithValue("@ParentID", ParentID);
            Cm.Parameters.AddWithValue("@EmpID", UserID);
            Cm.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));
            Cm.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));
            Cm.Parameters.AddWithValue("@Type", ddlType.SelectedValue);
            Cm.Parameters.AddWithValue("@SUserID", SUserID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvgrid.DataSource = objClass.CommonFunctionForSelect(Cm).Tables[0];
                gvgrid.DataBind();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found',3);", true);
                gvgrid.DataSource = null;
                gvgrid.DataBind();
            }

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void ifmCustFeedBack_Load(object sender, EventArgs e)
    {

    }

    protected void gvgrid_PreRender(object sender, EventArgs e)
    {
        if (gvgrid.Rows.Count > 0)
        {
            gvgrid.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvgrid.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}