using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class EmailSettings : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helpers Method

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
                        var unit = xml.Descendants("email_settings");
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
        var objOEML = ctx.OEMLs.FirstOrDefault(x => x.ParentID == ParentID && x.EmpID == UserID);

        if (objOEML != null && objOEML.EmailID > 0)
        {
            txtEmailID.Text = objOEML.Email;
            txtPassword.Text = objOEML.Password;
            txtDomain.Text = objOEML.Domain;
            txtPort.Text = objOEML.Port.ToString();
            txtUserName.Text = objOEML.UserName;
            btnSubmit.Text = "Submit";
            ViewState["EmailID"] = objOEML.EmailID;
        }
        else
        {
            txtDomain.Text = txtEmailID.Text = txtPassword.Text = txtPort.Text = txtUserName.Text = "";
            btnSubmit.Text = "Submit";
            ViewState["EmailID"] = null;
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

    #region Button Save Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            OEML objOEML = null;
            int EmailID;

            if (ViewState["EmailID"] != null && Int32.TryParse(ViewState["EmailID"].ToString(), out EmailID))
            {
                objOEML = ctx.OEMLs.FirstOrDefault(x => x.EmailID == EmailID);
                objOEML.Email = txtEmailID.Text;
                objOEML.UserName = txtUserName.Text;
                objOEML.Password = txtPassword.Text;
                objOEML.Domain = txtDomain.Text;
                objOEML.Port = Convert.ToInt32(txtPort.Text);
               
                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Email settings updated successfully!',1);", true);
            }
            else
            {

                objOEML = new OEML();
                objOEML.EmailID = ctx.GetKey("OEML", "EmailID", "", ParentID, 0).FirstOrDefault().Value;
                objOEML.EmpID = UserID;
                objOEML.ParentID = ParentID;
                objOEML.Email = txtEmailID.Text;
                objOEML.UserName = txtUserName.Text;
                objOEML.Password = txtPassword.Text;
                objOEML.Domain = txtDomain.Text;
                objOEML.Port = Convert.ToInt32(txtPort.Text);

                ctx.OEMLs.Add(objOEML);

                ctx.SaveChanges();
                ClearAllInputs();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Mail configured successfully!',1);", true);
            }
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Page is invalid!',3);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("MyAccount.aspx");
    }

    #endregion
}