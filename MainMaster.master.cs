using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MainMaster : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "Pageload", "Panel_Click();", true);
        using (var ctx = new DDMSEntities())
        {
            int lIndex = Request.ServerVariables["script_name"].ToString().LastIndexOf('/');
            string pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
            if (Session["LoginFlag"] != null && Session["LoginFlag"].ToString() == "2" && pagename != "ChangePassword.aspx")
            {
                Response.Redirect("~/MyAccount/ChangePassword.aspx?flag=true");
            }
            else if (Session["LoginFlag"] != null && Session["LoginFlag"].ToString() == "3" && pagename != "DayClose.aspx")
            {
                Response.Redirect("~/Sales/DayClose.aspx");
            }
            Decimal ParentID = Convert.ToDecimal(Session["ParentID"]);
            if (ParentID > 0)
            {
                int Gid = Convert.ToInt32(Session["GroupID"]);
                int CustType = Convert.ToInt32(Session["Type"]);

                string usertype = Session["UserType"].ToString();

                if (Request.QueryString["MID"] != null)
                {
                    lblUserTest.Text = Session["FirstName"].ToString();
                    int menuid = Convert.ToInt32(Request.QueryString["MID"]);
                    var objOMNU = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename && x.MenuID == menuid);
                    if (objOMNU != null)
                    {
                        lnkTitle.Text = objOMNU.MenuName;
                        int pmenuid = ctx.OMNUs.FirstOrDefault(x => x.MenuID == objOMNU.ParentMenuID.Value).ParentMenuID.Value;
                        lnkTitle.PostBackUrl = ctx.OMNUs.FirstOrDefault(x => x.MenuID == pmenuid).MenuPath;

                        List<OMNU> SubMenus = ctx.OMNUs.Where(x => x.Active && x.ParentMenuID.HasValue && x.ParentMenuID.Value == menuid
                               && (CustType == 1 ? x.Company : CustType == 2 ? x.CMS : CustType == 3 ? x.DMS : CustType == 4 ? x.SS : false)
                               && (x.GRP1.Any(y => y.ParentID == ParentID && y.EmpGroupID == Gid && y.AuthorizationType != "N"))
                               && (x.MenuType.ToUpper() == "B" || usertype.ToUpper() == "B" || x.MenuType == usertype)).OrderBy(x => x.SortOrder).ToList();

                        lvMenu.DataSource = SubMenus;
                        lvMenu.DataBind();
                    }

                }
                else
                {
                    var objOMNU = ctx.OMNUs.FirstOrDefault(x => x.PageName == pagename);
                    if (objOMNU != null)
                    {
                        lnkTitle.Text = objOMNU.MenuName;
                        lblUserTest.Text = Session["FirstName"].ToString();
                        if (objOMNU.ParentMenuID.HasValue)
                        {
                            int pmenuid = ctx.OMNUs.FirstOrDefault(x => x.MenuID == objOMNU.ParentMenuID.Value).ParentMenuID.Value;
                            lnkTitle.PostBackUrl = ctx.OMNUs.FirstOrDefault(x => x.MenuID == pmenuid).MenuPath;

                            List<OMNU> SubMenus = ctx.OMNUs.Where(x => x.Active && x.ParentMenuID.HasValue && x.ParentMenuID.Value == objOMNU.ParentMenuID.Value
                               && (CustType == 1 ? x.Company : CustType == 2 ? x.CMS : CustType == 3 ? x.DMS : CustType == 4 ? x.SS : false)
                               && (x.GRP1.Any(y => y.ParentID == ParentID && y.EmpGroupID == Gid && y.AuthorizationType != "N"))
                               && (x.MenuType.ToUpper() == "B" || usertype.ToUpper() == "B" || x.MenuType == usertype)).OrderBy(x => x.SortOrder).ToList();

                            lvMenu.DataSource = SubMenus;
                            lvMenu.DataBind();
                        }
                        else
                        {

                            lnkTitle.PostBackUrl = "~/Home.aspx";
                            lblUserTest.Text = Session["FirstName"].ToString();
                            List<OMNU> SubMenus = ctx.OMNUs.Where(x => x.Active && x.ParentMenuID.HasValue && x.ParentMenuID.Value == objOMNU.MenuID
                               && (CustType == 1 ? x.Company : CustType == 2 ? x.CMS : CustType == 3 ? x.DMS : CustType == 4 ? x.SS : false)
                               && ctx.OMNUs.Any(z => z.ParentMenuID == x.MenuID && x.Active && z.GRP1.Any(a => a.ParentID == ParentID && a.EmpGroupID == Gid && a.AuthorizationType != "N"))
                               && (x.GRP1.Any(y => y.ParentID == ParentID && y.EmpGroupID == Gid && y.AuthorizationType != "N"))
                               && (x.MenuType.ToUpper() == "B" || usertype.ToUpper() == "B" || x.MenuType == usertype)).OrderBy(x => x.SortOrder).ToList();

                            lvMenu.DataSource = SubMenus;
                            lvMenu.DataBind();
                        }
                    }
                }
            }
        }
    }
}
