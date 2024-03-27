using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Objects.SqlClient;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_EmpDALConflictUpdate : System.Web.UI.Page
{

    #region Declaration

    protected int UserID;
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
                int CustType = Convert.ToInt32(Session["Type"]);
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
        txtDealerCode.Text = "";
        gvCustomerData.DataSource = null;
        gvCustomerData.DataBind();
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

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        try
        {
            Decimal CustomerID = Decimal.TryParse(txtDealerCode.Text.Split("-".ToArray()).Last().Trim(), out CustomerID) ? CustomerID : 0;

            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetEmpDealerDALConflictData";
            Cm.Parameters.AddWithValue("@CustomerID", CustomerID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds != null && ds.Tables != null && ds.Tables.Count > 0)
            {
                gvCustomerData.DataSource = objClass.CommonFunctionForSelect(Cm).Tables[0];
                gvCustomerData.DataBind();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No records found.',1);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnSumbit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    bool AnyChange = false;
                    foreach (GridViewRow item in gvCustomerData.Rows)
                    {
                        HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");
                        HtmlInputHidden hdnIsChange = (HtmlInputHidden)item.FindControl("IsChange");

                        if (!chkCheck.Checked)
                        {
                            HtmlInputHidden hdnOASTCMID = (HtmlInputHidden)item.FindControl("hdnOASTCMID");
                            int IntNum = Int32.TryParse(hdnOASTCMID.Value, out IntNum) ? IntNum : 0;
                            int IsChange = Int32.TryParse(hdnIsChange.Value, out IsChange) ? IsChange : 0;

                            OASTCM objOASTCM = ctx.OASTCMs.FirstOrDefault(x => x.OASTCMID == IntNum);
                            if (objOASTCM != null)
                            {
                                if (IsChange == 1)
                                {
                                    AnyChange = true;
                                    objOASTCM.IsConflict = chkCheck.Checked;
                                    objOASTCM.UpdatedBy = UserID;
                                    objOASTCM.UpdatedDate = DateTime.Now;
                                }
                            }
                        }
                    }
                    if (AnyChange)
                    {
                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Conflict Data Updated Successfully',1);", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('You have not changed anything.',1);", true);
                    }
                }

                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

    #region Gridview Events

    protected void gvCustomerData_PreRender(object sender, EventArgs e)
    {
        if (gvCustomerData.Rows.Count > 0)
        {
            gvCustomerData.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCustomerData.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion
}