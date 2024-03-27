using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Reports_EmpHierarchyTree : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    public decimal ParentID;
    protected String AuthType;
    List<GetEmpHierarchyTree_Result> Data;

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

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
    }

    #endregion

    #region ButtonClick

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {

            int SUserID = Int32.TryParse(txtCode.Text.Split("-".ToArray()).Last().Trim(), out SUserID) ? SUserID : UserID;
            if (!string.IsNullOrEmpty(txtCode.Text) && SUserID == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper User.',3);", true);
                return;
            }
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ctx.OEMPs.Any(x => x.EmpID == SUserID && x.ParentID == ParentID && x.IsAdmin))
                {
                    SUserID = ctx.OCFGs.FirstOrDefault().CurrentAdminManagerID.GetValueOrDefault(0);
                }
                hdnSUserID.Value = SUserID.ToString();
                Data = ctx.GetEmpHierarchyTree(SUserID, ParentID).ToList();
                treeview.DataSource = Data.Where(x => x.MANAGERID.GetValueOrDefault(0) == 0).ToList();
                treeview.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    protected void treeview_ItemDataBound1(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.DataItem != null)
        {
            GetEmpHierarchyTree_Result listitem = e.Item.DataItem as GetEmpHierarchyTree_Result;
            if (Data.Any(x => x.MANAGERID == listitem.EMPID))
            {
                //determine type and get the properties
                Type type = sender.GetType();
                PropertyInfo[] properties = type.GetProperties();
                Object obj = type.InvokeMember("", BindingFlags.CreateInstance, null, sender, null);

                //copy the properties
                foreach (PropertyInfo propertyInfo in properties)
                {
                    if (propertyInfo.CanWrite)
                    {
                        propertyInfo.SetValue(obj, propertyInfo.GetValue(sender, null), null);
                    }
                }

                //cast the created object back to a repeater
                Repeater nestedRepeater = obj as Repeater;

                //fill the child repeater with the sub menu items
                nestedRepeater.DataSource = Data.Where(x => x.MANAGERID == listitem.EMPID).ToList();

                //attach the itemdatabound event
                nestedRepeater.ItemDataBound += treeview_ItemDataBound1;

                //bind the data
                nestedRepeater.DataBind();

                //find the placeholder and add the created Repeater
                PlaceHolder ph = e.Item.FindControl("PlaceHolder1") as PlaceHolder;
                ph.Controls.Add(nestedRepeater);
            }
        }
    }
}