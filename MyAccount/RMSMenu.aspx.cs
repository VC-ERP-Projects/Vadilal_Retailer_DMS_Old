using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_RMSMenu : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
        SqlCommand Cm = new SqlCommand();

        Cm.Parameters.Clear();
        Cm.CommandType = CommandType.StoredProcedure;
        Cm.CommandText = "RmsMenu";
        DataSet ds = objClass.CommonFunctionForSelect(Cm);

        gvAuthorization.DataSource = ds.Tables[0];
        gvAuthorization.DataBind();
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
                            var unit = xml.Descendants("authorization");
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
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int Count = ctx.GetKey("OMNUR", "RMenuID", "", 0, 0).FirstOrDefault().Value;
                int MenuID;

                foreach (GridViewRow item in gvAuthorization.Rows)
                {
                    Label lblMenuID = (Label)item.FindControl("lblMenuID");
                    if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID) && ctx.OMNUs.Any(x => x.MenuID == MenuID && x.ParentMenuID != null))
                    {

                        TextBox txtRef1 = (TextBox)item.FindControl("txtRef1");
                        TextBox txtRef2 = (TextBox)item.FindControl("txtRef2");
                        TextBox txtRef3 = (TextBox)item.FindControl("txtRef3");
                        TextBox txtRef4 = (TextBox)item.FindControl("txtRef4");
                        TextBox txtRef5 = (TextBox)item.FindControl("txtRef5");

                        var objOMNURs = ctx.OMNURs.Where(x => x.MenuID == MenuID);
                        foreach (OMNUR objOMNUR in objOMNURs)
                        {
                            objOMNUR.Ref1 = txtRef1.Text;
                            objOMNUR.Ref2 = txtRef2.Text;
                            objOMNUR.Ref3 = txtRef3.Text;
                            objOMNUR.Ref4 = txtRef4.Text;
                            objOMNUR.Ref5 = txtRef5.Text;
                        }
                    }
                }
                ctx.SaveChanges();
            }
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("MyAccount.aspx");
    }

    #endregion

    #region GridView Command

    protected void gvAuthorization_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        TextBox txtPriority = (TextBox)e.Row.FindControl("txtPriority");
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblName = (Label)e.Row.FindControl("lblName");
            var data = e.Row.DataItem as DataRowView;
            if (!string.IsNullOrEmpty(data[2].ToString()))
            {
                lblName.Attributes.Add("Style", "float:left; padding-left:40px;");
                lblName.Text = "-- " + lblName.Text;
            }
            else
            {
                e.Row.BackColor = Color.LightBlue;

                TextBox txtRef1 = (TextBox)e.Row.FindControl("txtRef1");
                TextBox txtRef2 = (TextBox)e.Row.FindControl("txtRef2");
                TextBox txtRef3 = (TextBox)e.Row.FindControl("txtRef3");
                TextBox txtRef4 = (TextBox)e.Row.FindControl("txtRef4");
                TextBox txtRef5 = (TextBox)e.Row.FindControl("txtRef5");

                txtRef1.Visible = txtRef2.Visible = txtRef3.Visible = txtRef4.Visible = txtRef5.Visible = false;
            }
        }
    }

    #endregion
}