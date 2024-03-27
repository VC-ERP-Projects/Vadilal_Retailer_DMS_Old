using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Marketing_MessageInbox : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #region Helper Method

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
                        var unit = xml.Descendants("message_inbox");
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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        edsgvMessageInbox.WhereParameters["DateNow"].DefaultValue = DateTime.Now.ToShortDateString();
    }

    #endregion

    #region Gird View Command

    protected void gvMessageInbox_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ShowMsg")
        {
            var Data = e.CommandArgument.ToString().Split(",".ToArray());
            int MSGID = Convert.ToInt32(Data[0]);
            Decimal PID = Convert.ToDecimal(Data[1]);
            var objMSG = ctx.MSG1.Include("OMSG").FirstOrDefault(x => x.MSG1ID == MSGID && x.ParentID == PID);
            txtSubject.Text = objMSG.OMSG.Subject;
            txtMessageBody.Text = objMSG.OMSG.MessageBody;
        }
        else if (e.CommandName == "DeleteMsg")
        {
            int MessageID = Convert.ToInt32(e.CommandArgument);
            var objMSG = ctx.MSG1.FirstOrDefault(x => x.MessageID == MessageID && x.ParentID == ParentID);
            ctx.MSG1.Remove(objMSG);
            ctx.SaveChanges();

            gvMessageInbox.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Message Deleted Successfully!',1);", true);
            txtMessageBody.Text = txtSubject.Text = "";
        }
    }

    #endregion
}