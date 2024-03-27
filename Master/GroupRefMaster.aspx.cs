using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_GroupRefMaster : System.Web.UI.Page
{
    #region Declaration
    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    protected string pagename;
    protected String Version;

    #endregion
    #region PageLoad
    protected void Page_Load(object sender, EventArgs e)
    {
        // ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInput();
        }
    }
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
                pagename = Request.ServerVariables["script_name"].ToString().Substring(lIndex + 1);
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
    private void ClearAllInput()
    {

        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetGroupRefMasterData";
            Cm.Parameters.AddWithValue("@ForOption", ddlOption.SelectedValue.ToString());
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables[0].Rows.Count > 0)
            {
                gvCategory.DataSource = ds.Tables[0];
                gvCategory.DataBind();
            }
            // ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myCopyModal", "jQueryDataTable();", true);

        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

        // txtCategoryCode.Text = txtDescription.Text = "";
        hdnCategoryId.Value = "0";
        chkActive.Checked = false;
        saveData.Text = "Submit";
        // btnSubmit.Text = "Submit";
    }
    #endregion

    #region Button Click Event

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<dynamic> LoadReport(string strIsHistory)
    {
        List<dynamic> result = new List<dynamic>();
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();

            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "GetCategoryMasterReport";
            Cm.Parameters.AddWithValue("@IsHistory", strIsHistory.ToLower() == "true" ? "1" : "0");
            DataSet DS = objClass.CommonFunctionForSelect(Cm);
            DataTable dt;
            if (DS.Tables[0] != null && DS.Tables[0].Rows.Count > 0)
            {
                dt = DS.Tables[0];
                result.Add(JsonConvert.SerializeObject(dt));
            }
        }
        catch (Exception ex)
        {
            result.Add("ERROR=" + "" + Common.GetString(ex));
        }

        return result;

    }

    protected void saveData_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (String.IsNullOrEmpty(txtCategoryCode.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select enter category code',3);", true);
                    return;
                }
                //if (String.IsNullOrEmpty(txtDescription.Text))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Select enter category description',3);", true);
                //    return;
                //}
                int CategoryId = int.TryParse(hdnCategoryId.Value, out CategoryId) ? CategoryId : 0;
                OGRPM objGrp = ctx.OGRPMs.FirstOrDefault(x => x.DiscountGroupId == CategoryId);
                if (objGrp != null)
                {
                    objGrp.PageName = "AllDisc";
                    objGrp.ForOption = ddlOption.SelectedValue.ToString();
                    objGrp.GroupName = txtCategoryCode.Text;
                    objGrp.FromDate = Convert.ToDateTime(txtFromDate.Text);
                    objGrp.ToDate = Convert.ToDateTime(txtToDate.Text);
                    // objCtg.Description = txtDescription.Text;
                    objGrp.Active = chkActive.Checked;
                    objGrp.UpdatedBy = UserID;
                    objGrp.UpdatedDate = DateTime.Now;
                }
                else
                {
                    OGRPM objectCTG = new OGRPM();
                    objGrp.PageName = "AllDisc";
                    objGrp.ForOption = ddlOption.SelectedValue.ToString();
                    objGrp.GroupName = txtCategoryCode.Text;
                    objGrp.FromDate = Convert.ToDateTime(txtFromDate.Text);
                    objGrp.ToDate = Convert.ToDateTime(txtToDate.Text);
                    objectCTG.Active = chkActive.Checked;
                    objectCTG.Deleted = false;
                    objectCTG.CreatedBy = UserID;
                    objectCTG.CreatedDate = DateTime.Now;
                    objectCTG.UpdatedBy = UserID;
                    objectCTG.UpdatedDate = DateTime.Now;
                    ctx.OGRPMs.Add(objectCTG);
                }
                ctx.SaveChanges();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record Added Successfully',1); hideModal();", true);
                ClearAllInput();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',3); hideModal();", true);
        }
    }
    #endregion

    #region GridView Event
    protected void gvCategory_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(e.CommandArgument.ToString()))
            {
                Int32 CategoryId = Int32.TryParse(e.CommandArgument.ToString(), out CategoryId) ? CategoryId : 0;
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (e.CommandName.Trim() == "EditMode" && CategoryId > 0)
                    {
                        OGRPM objCtg = ctx.OGRPMs.FirstOrDefault(x => x.DiscountGroupId == CategoryId && x.Deleted == false);
                        hdnCategoryId.Value = objCtg.DiscountGroupId.ToString();
                        ddlOption.SelectedValue = objCtg.ForOption.ToString();
                        txtCategoryCode.Text = objCtg.GroupName;
                        txtFromDate.Text = objCtg.FromDate.ToString();
                        txtToDate.Text = objCtg.ToDate.ToString();
                        //txtDescription.Text = objCtg.Description;
                        chkActive.Checked = Convert.ToBoolean(objCtg.Active);
                        saveData.Text = "Update";
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "myCopyModal", "$('#myCopyModal').modal();", true);
                    }
                    else if ((e.CommandName.Trim() == "DeleteMode" && CategoryId > 0))
                    {
                        OGRPM objOSEQ = ctx.OGRPMs.FirstOrDefault(x => x.DiscountGroupId == CategoryId && x.Deleted == false);
                        objOSEQ.Deleted = true;
                        objOSEQ.UpdatedDate = DateTime.Now;
                        objOSEQ.UpdatedBy = UserID;
                        ctx.SaveChanges();
                        ClearAllInput();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void gvCategory_PreRender(object sender, EventArgs e)
    {
        if (gvCategory.Rows.Count > 0)
        {
            gvCategory.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvCategory.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
    #endregion
}