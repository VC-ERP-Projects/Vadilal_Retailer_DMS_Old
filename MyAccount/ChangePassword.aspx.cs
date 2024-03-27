using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_ChangePassword : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

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
                            var unit = xml.Descendants("change_password");
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
            txtOldPassword.Focus();
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (Request.QueryString["flag"] != null && Request.QueryString["flag"].ToString() == "true")
                {
                    lblError.Visible = true;
                }
                else
                {
                    lblError.Visible = false;
                }

                if (Session["IsDistLogin"] != null && Session["IsDistLogin"].ToString() == "True")
                {
                    var objUser = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID);
                    txtOldPassword.Text = Common.DecryptNumber(objUser.UserName, objUser.Password);
                    txtOldPassword.Enabled = false;
                    txtOldPassword.Attributes.Add("value", Common.DecryptNumber(objUser.UserName, objUser.Password));
                }
            }
        }

    }

    #endregion

    #region Save Mode Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            using (var ctx = new DDMSEntities())
            {
                if (txtNewPassword.Text != txtConfirmPassword.Text)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('New Password and Confirm Password does not match!',3);", true);
                    return;
                }
                var objUser = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID && x.ParentID == ParentID);
                var Pwd = Common.DecryptNumber(objUser.UserName, objUser.Password);

                if (Pwd == txtNewPassword.Text)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('New password should be different from old password!',3);", true);
                    return;
                }
                if (Session["IsDistLogin"] != null && Session["IsDistLogin"].ToString() == "True")
                {
                    //Company Login allow same password
                }
                else if (objUser.UserName.ToLower() == txtNewPassword.Text.ToLower())
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Password should not be same as UserName!',3);", true);
                    return;
                }

                if (Pwd != txtOldPassword.Text)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Old password does not match!',3);", true);
                    return;
                }
                else
                {
                    objUser.Password = Common.EncryptNumber(objUser.UserName, txtNewPassword.Text);
                    objUser.Active = true;
                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Password changed successfully.',1);", true);
                    if (Session["LoginFlag"] != null && Session["LoginFlag"].ToString() == "2")
                    {
                        Session["LoginFlag"] = "1";
                        Response.Redirect("~/Login.aspx");
                    }
                    else
                    {
                        Session["LoginFlag"] = "1";
                        Response.Redirect("~/Home.aspx");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("MyAccount.aspx");
    }

    #endregion
}