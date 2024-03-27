using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class MyAccount_RMSAuthorization : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlEGroup.DataSource = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlEGroup.SelectedValue = "0";
        }
        chkIsActive.Checked = true;

        gvAuthorization.DataSource = null;
        gvAuthorization.DataBind();
        Bind();
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

    public void Bind()
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            List<OMNU> Data = new List<OMNU>();

            List<OMNU> parentMenu = ctx.OMNUs.Where(x => !x.ParentMenuID.HasValue && x.Active && x.RMS).OrderBy(y => y.SortOrder).ToList();
            foreach (OMNU item in parentMenu)
            {
                Data.Add(item);
                Data.AddRange(ctx.OMNUs.Where(x => x.ParentMenuID == item.MenuID && x.Active && x.RMS).OrderBy(y => y.SortOrder).ToList());
            }

            gvAuthorization.DataSource = Data;
            gvAuthorization.DataBind();
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
            ddlEGroup.Focus();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            int EmpGroupID;
            if (Int32.TryParse(ddlEGroup.SelectedValue, out EmpGroupID) && EmpGroupID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    int count = ctx.GetKey("OMNUR", "RMenuID", "", ParentID, 0).FirstOrDefault().Value;
                    int MenuID;

                    foreach (GridViewRow item in gvAuthorization.Rows)
                    {
                        Label lblMenuID = (Label)item.FindControl("lblMenuID");
                        Label lblName = (Label)item.FindControl("lblName");

                        if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                        {
                            //if (ctx.OMNUs.Any(x => x.MenuID == MenuID && x.ParentMenuID.HasValue))
                            //{
                            HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                            HtmlInputCheckBox chkWrite = ((HtmlInputCheckBox)item.FindControl("chkWrite"));

                            DropDownList ddlCallType = ((DropDownList)item.FindControl("ddlCallType"));
                            DropDownList ddlMenuType = ((DropDownList)item.FindControl("ddlMenuType"));

                            HtmlInputCheckBox chkNotification = ((HtmlInputCheckBox)item.FindControl("chkNotification"));

                            TextBox txtPriority = (TextBox)item.FindControl("txtPriority");

                            if (MenuID == 9110 && Convert.ToInt32(ddlMenuType.SelectedValue) != 1)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer is compulsory for " + lblName.Text + " ',3);", true);
                                return;
                            }
                            if (MenuID == 9112 && Convert.ToInt32(ddlMenuType.SelectedValue) != 1)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer is compulsory for " + lblName.Text + " ',3);", true);
                                return;
                            }
                            if (MenuID == 9145 && Convert.ToInt32(ddlMenuType.SelectedValue) != 1)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Customer is compulsory for " + lblName.Text + " ',3);", true);
                                return;
                            }

                            var objOMNUR = ctx.OMNURs.FirstOrDefault(x => x.ParentID == ParentID && x.MenuID == MenuID && x.EmpGroupID == EmpGroupID);
                            if (objOMNUR == null)
                            {
                                objOMNUR = new OMNUR();
                                objOMNUR.RMenuID = count++;
                                objOMNUR.ParentID = ParentID;
                                objOMNUR.MenuID = MenuID;
                                objOMNUR.EmpGroupID = EmpGroupID;
                                ctx.OMNURs.Add(objOMNUR);
                            }
                            int IntNum = 0;
                            objOMNUR.Priority = Int32.TryParse(txtPriority.Text, out IntNum) ? IntNum : 0;
                            objOMNUR.Mandatory = chkCheck.Checked;

                            objOMNUR.Notification = chkNotification.Checked;
                            objOMNUR.MenuType = Convert.ToInt32(ddlMenuType.SelectedValue);
                            objOMNUR.CallType = Convert.ToInt32(ddlCallType.SelectedValue);

                            objOMNUR.Active = chkIsActive.Checked;

                            if (chkWrite.Checked)
                                objOMNUR.AuthorizationType = "W";
                            else
                                objOMNUR.AuthorizationType = "N";
                            //}
                        }
                    }
                    ctx.SaveChanges();
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                ClearAllInputs();

            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper group!',3);", true);
            }
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

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lblName = (Label)e.Row.FindControl("lblName");
            var data = e.Row.DataItem as OMNU;
            if (data.ParentMenuID.HasValue)
            {
                lblName.Attributes.Add("Style", "float:left; padding-left:40px;");
                lblName.Text = "-- " + lblName.Text;
            }
            else
            {
                HtmlInputCheckBox chkWrite = (HtmlInputCheckBox)e.Row.FindControl("chkWrite");
                DropDownList ddlMenuType = (DropDownList)e.Row.FindControl("ddlMenuType");
                DropDownList ddlCallType = (DropDownList)e.Row.FindControl("ddlCallType");
                TextBox txtPriority = (TextBox)e.Row.FindControl("txtPriority");

                HtmlInputCheckBox chkNotification = (HtmlInputCheckBox)e.Row.FindControl("chkNotification");
                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)e.Row.FindControl("chkCheck");

                ddlMenuType.Visible = ddlCallType.Visible = txtPriority.Visible = chkNotification.Visible = chkCheck.Visible = false;
                lblName.Attributes.Add("Style", "float:left;");
            }
        }
    }

    #endregion

    #region Change Event

    protected void ddlEGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlEGroup.SelectedValue == "0")
        {
            ClearAllInputs();
        }
        else
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int EGID = Convert.ToInt32(ddlEGroup.SelectedValue);
                int MenuID;

                var objOMNURs = ctx.OMNURs.Where(x => x.EmpGroupID == EGID && x.ParentID == ParentID && x.Active).ToList();

                if (objOMNURs != null && objOMNURs.Count > 0)
                {
                    foreach (GridViewRow item in gvAuthorization.Rows)
                    {
                        Label lblMenuID = (Label)item.FindControl("lblMenuID");
                        if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                        {
                            OMNUR objOMNUR = objOMNURs.FirstOrDefault(x => x.MenuID == MenuID);

                            if (objOMNUR != null)
                            {
                                HtmlInputCheckBox chkWrite = (HtmlInputCheckBox)item.FindControl("chkWrite");
                                DropDownList ddlMenuType = (DropDownList)item.FindControl("ddlMenuType");
                                DropDownList ddlCallType = (DropDownList)item.FindControl("ddlCallType");
                                TextBox txtPriority = (TextBox)item.FindControl("txtPriority");

                                HtmlInputCheckBox chkNotification = (HtmlInputCheckBox)item.FindControl("chkNotification");
                                HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");

                                txtPriority.Text = objOMNUR.Priority.ToString();
                                chkWrite.Checked = objOMNUR.AuthorizationType == "W" ? true : false;
                                chkCheck.Checked = objOMNUR.Mandatory;
                                ddlMenuType.SelectedValue = objOMNUR.MenuType.ToString();
                                ddlCallType.SelectedValue = objOMNUR.CallType.ToString();
                                chkNotification.Checked = objOMNUR.Notification;
                            }
                        }
                    }
                }
                else
                {
                    Bind();
                }
            }
        }
        ddlEGroup.Focus();
    }

    #endregion
    protected void gvAuthorization_PreRender(object sender, EventArgs e)
    {
        if (gvAuthorization.Rows.Count > 0)
        {
            gvAuthorization.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvAuthorization.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}