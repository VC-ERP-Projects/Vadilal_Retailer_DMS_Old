using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_ClaimFwd : System.Web.UI.Page
{
    protected int UserID, CustType;
    protected decimal ParentID, CustomerID;
    DDMSEntities ctx;
    protected String AuthType;

    #region Helper Method

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
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
        else
        {
            Response.Redirect("~/Login.aspx");
        }
    }

    #endregion

    #region PageLoad

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        OEMP ObjEmp = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID);
        if (ObjEmp != null)
        {
            hdnFwdUser.Value = ObjEmp.EmpCode + " # " + ObjEmp.Name + "  # " + ObjEmp.EmpID;
        }
    }

    #endregion

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid(1, "");
    }
    private void BindGrid(int pageIndex, string pageName)
    {
        try
        {
            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
            SqlCommand Cm = new SqlCommand();
            Int32 RegionID = Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) ? RegionID : 0;
            Cm.Parameters.Clear();
            Cm.CommandType = CommandType.StoredProcedure;
            Cm.CommandText = "usp_GetPendingClaimForFwd";
            Cm.Parameters.AddWithValue("@RegionId", RegionID);
            Cm.Parameters.AddWithValue("@Type", ddlReportBy.SelectedValue);
            Cm.Parameters.AddWithValue("@UserId", UserID);
            DataSet ds = objClass.CommonFunctionForSelect(Cm);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                gvOrder.DataSource = ds.Tables[0];
                gvOrder.DataBind();
            }
            else
            {
				ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Data Found',3);", true);
                gvOrder.DataSource = null;
                gvOrder.DataBind();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void gvOrder_Prerender(object sender, EventArgs e)
    {
        if (gvOrder.Rows.Count > 0)
        {
            gvOrder.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvOrder.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    protected void btnGenerat_Click(object sender, EventArgs e)
    {
        bool errFound = true;
        try
        {
            for (int i = 0; i < gvOrder.Rows.Count; i++)
            {
                HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");
                if (chk.Checked == true)
                {
                    errFound = false;
                }
            }
            if (errFound == true)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select atleast one row!',3);", true);
                return;
            }

            for (int i = 0; i < gvOrder.Rows.Count; i++)
            {
                HtmlInputCheckBox chk = (HtmlInputCheckBox)gvOrder.Rows[i].FindControl("chkCheck");

                if (chk.Checked)
                {
                    Label lblParentId = (Label)gvOrder.Rows[i].FindControl("lblParentId");
                    Label lblParentClaimId = (Label)gvOrder.Rows[i].FindControl("lblParentClaimId");
                    TextBox txtUserId = (TextBox)gvOrder.Rows[i].FindControl("AutoEmpName");
                    if (txtUserId.Text == "")
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please Select Forward User',3);", true);
                        return;
                    }
                    Int32 ParentClaimId = Int32.TryParse(lblParentClaimId.Text, out ParentClaimId) ? ParentClaimId : 0;
                    Decimal CustParentId = Decimal.TryParse(lblParentId.Text, out CustParentId) ? CustParentId : 0;
                    Int32 EUserId = Int32.TryParse(txtUserId.Text.Split("#".ToArray())[2], out EUserId) ? EUserId : 0;
                    OCLMP ObjCLMP = ctx.OCLMPs.Where(x => x.ParentID == CustParentId && x.ParentClaimID == ParentClaimId).FirstOrDefault();
                    if (ObjCLMP != null)
                    {
                        ObjCLMP.ClaimLevel = -1;
                        ObjCLMP.HierarchyManagerId = EUserId;
                        ObjCLMP.IsActive = true;
                    }
                }
            }
            ctx.SaveChanges();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Claim Detail Forward to Successfully',1);", true);
            ClearAllInputs(true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }
    public void ClearAllInputs(Boolean allclear)
    {
        gvOrder.DataSource = null;
        gvOrder.DataBind();
        txtRegion.Text = "";
    }
    //protected void gvOrder_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        TextBox txtUserId = e.Row.FindControl("AutoEmpName") as TextBox;
    //        OEMP ObjEmp = ctx.OEMPs.FirstOrDefault(x => x.EmpID == UserID);
    //        if (ObjEmp != null)
    //        {
    //            txtUserId.Text = ObjEmp.EmpCode + " # " + ObjEmp.Name + "  # " + ObjEmp.EmpID;
    //        }
    //        else
    //        {
    //            txtUserId.Text = "";
    //        }
    //    }
    //}

    protected void ddlReportBy_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearAllInputs(true);
    }
}