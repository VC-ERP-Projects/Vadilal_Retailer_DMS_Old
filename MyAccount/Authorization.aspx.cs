using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using AjaxControlToolkit;
using System.Globalization;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;
using System.Data.SqlClient;

public partial class MyAccount_Authorization : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    public int CustType;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    public void ClearAllInputs()
    {
        txtCustomer.Text = txtRegion.Text = "";
        chkIsActive.Checked = true;
        txtUpdateBy.Text = string.Empty;
        txtUpdatedDate.Text = string.Empty;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            var EmpG = ctx.OGRPs.Where(x => x.Active && x.ParentID == ParentID).Select(x => new { EmpGroupName = x.EmpGroupName + " # " + x.EmpGroupDesc, x.EmpGroupID }).ToList();
            ddlEGroup.DataSource = EmpG;
            ddlEGroup.DataBind();
            ddlEGroup.Items.Insert(0, new ListItem("---Select---", "0"));
            ddlEGroup.SelectedValue = "0";

        }
        gvAuthorization.DataSource = null;
        gvAuthorization.DataBind();
        BindGrid();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
    }

    public void ResetControls()
    {
        gvAuthorization.Columns[1].Visible = true;
        btnPriority.Visible = true;

        if (ddlFor.SelectedValue != "1" && CustType == 1)
        {
            if (ddlFor.SelectedValue == "2")
                acetxtName.ServiceMethod = "GetDistFromSSPlantState";
            else if (ddlFor.SelectedValue == "4")
                acetxtName.ServiceMethod = "GetSSFromPlantState";
            divRegion.Attributes.Remove("style");
            divDistributor.Attributes.Remove("style");
            divEmpGroup.Attributes.Add("style", "display:none");
            gvAuthorization.Columns[1].Visible = false;
            btnPriority.Visible = false;
        }
        else
        {
            if (ddlFor.SelectedValue == "2")
            {
                gvAuthorization.Columns[1].Visible = false;
                btnPriority.Visible = false;
            }
            else if (ddlFor.SelectedValue == "4")
            {
                gvAuthorization.Columns[1].Visible = false;
                btnPriority.Visible = false;
            }
            divRegion.Attributes.Add("style", "display:none");
            divDistributor.Attributes.Add("style", "display:none");
            divEmpGroup.Attributes.Remove("style");
        }
    }

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

    public void BindGrid()
    {
        try
        {
            List<OMNU> Data = new List<OMNU>();

            using (DDMSEntities ctx = new DDMSEntities())
            {
                int Type = Convert.ToInt32(ddlFor.SelectedValue);
                List<OMNU> menus = null;
                gvAuthorization.Columns[1].Visible = false;
                btnPriority.Visible = false;
                if (Type == 1)
                {
                    menus = ctx.OMNUs.Where(x => x.Active && x.Company).ToList();
                    gvAuthorization.Columns[1].Visible = true;
                    btnPriority.Visible = true;
                }
                else if (Type == 2)
                {
                    menus = ctx.OMNUs.Where(x => x.Active && x.CMS).ToList();
                }
                else if (Type == 4)
                {
                    menus = ctx.OMNUs.Where(x => x.Active && x.SS).ToList();
                }

                List<OMNU> sub1 = menus.Where(x => !x.ParentMenuID.HasValue).OrderBy(y => y.SortOrder).ToList();
                foreach (OMNU item in sub1)
                {
                    item.MenuName = item.MenuName + " ( " + (!string.IsNullOrEmpty(item.MenuType) && item.MenuType.ToLower() == "d" ? "DMS" : !string.IsNullOrEmpty(item.MenuType) && item.MenuType.ToLower() == "m" ? "RSD" : "Both") + " ) ";
                    Data.Add(item);

                    List<OMNU> sub2 = menus.Where(x => x.ParentMenuID == item.MenuID).OrderBy(y => y.SortOrder).ToList();
                    sub2.ForEach(x => x.MenuName = "&nbsp;&nbsp;&nbsp;&nbsp;----&nbsp;&nbsp;&nbsp;&nbsp;" + x.MenuName + " ( " + (!string.IsNullOrEmpty(x.MenuType) && x.MenuType.ToLower() == "d" ? "DMS" : !string.IsNullOrEmpty(x.MenuType) && x.MenuType.ToLower() == "m" ? "RSD" : "Both") + " ) ");
                    foreach (OMNU subitem in sub2)
                    {
                        Data.Add(subitem);

                        var sub3 = menus.Where(x => x.ParentMenuID == subitem.MenuID).OrderBy(y => y.SortOrder).ToList();
                        sub3.ForEach(x => x.MenuName = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;----&nbsp;&nbsp;&nbsp;&nbsp;" + x.MenuName + " ( " + (!string.IsNullOrEmpty(x.MenuType) && x.MenuType.ToLower() == "d" ? "DMS" : !string.IsNullOrEmpty(x.MenuType) && x.MenuType.ToLower() == "m" ? "RSD" : "Both") + " ) ");
                        Data.AddRange(sub3);
                    }
                }
            }

            gvAuthorization.DataSource = Data;
            gvAuthorization.DataBind();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    public void FillGrid(Decimal CustID)
    {
        using (DDMSEntities ctx = new DDMSEntities())
        {
            Int32 EGID = 0;
            List<GRP1> GRPs = new List<GRP1>();

            if (CustID > 0 || (Int32.TryParse(ddlEGroup.SelectedValue, out EGID) && EGID > 0))
            {
                if (ddlFor.SelectedValue != "1" && CustID > 0)
                {
                    GRPs = ctx.GRP1.Where(x => x.EmpGroupID == 1 && x.ParentID == CustID && x.Active).ToList();
                }
                else
                    GRPs = ctx.GRP1.Where(x => x.EmpGroupID == EGID && x.ParentID == ParentID && x.Active).ToList();

                if (GRPs != null && GRPs.Count > 0)
                {
                    foreach (GridViewRow item in gvAuthorization.Rows)
                    {
                        RadioButton chkWrite = (RadioButton)item.FindControl("chkWrite");
                        RadioButton chkNone = (RadioButton)item.FindControl("chkNone");
                        Label lblMenuID = (Label)item.FindControl("lblMenuID");
                        TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                        int MenuID;
                        if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                        {
                            var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                            if (objOMNU != null)
                            {
                                txtPriority.Text = objOMNU.SortOrder.ToString();
                            }
                            var Auth = GRPs.FirstOrDefault(x => x.MenuID == MenuID);
                            chkNone.Checked = chkWrite.Checked = false;
                            if (Auth != null)
                            {
                                if (Auth.AuthorizationType == "W")
                                    chkWrite.Checked = true;
                                else if (Auth.AuthorizationType == "N")
                                    chkNone.Checked = true;
                            }
                        }
                    }
                    var updatedBy = GRPs.LastOrDefault();
                    if (ddlFor.SelectedValue != "1" && string.IsNullOrEmpty(txtCustomer.Text) && CustType == 1)
                    {
                        txtUpdateBy.Text = string.Empty;
                        txtUpdatedDate.Text = string.Empty;
                    }
                    else
                    {
                        txtUpdateBy.Text = updatedBy != null ? ctx.OEMPs.Where(x => x.EmpID == updatedBy.UpdatedBy).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault() : string.Empty;
                        txtUpdatedDate.Text = updatedBy != null ? updatedBy.UpdatedDate.ToString() : string.Empty;
                    }
                    ResetControls();
                }
                else
                {
                    txtUpdateBy.Text = string.Empty;
                    txtUpdatedDate.Text = string.Empty;
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                    ResetControls();
                }
            }
        }
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        ResetControls();
        if (!IsPostBack)
        {
            if (CustType == 1)
            {
                divChkDistributor.Attributes.Remove("style");
            }
            else
            {
                ddlFor.SelectedValue = CustType.ToString();
                divDistributor.Attributes.Add("style", "display:none");
                divChkDistributor.Attributes.Add("style", "display:none");
            }
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
                if (ddlFor.SelectedValue != "1" && CustType == 1)
                {
                    int StateID = 0;
                    Decimal DefaultCustID = 0;
                    Boolean IsStateWise = false;
                    int Type = Convert.ToInt32(ddlFor.SelectedValue);

                    if (Decimal.TryParse(txtCustomer.Text.Split("-".ToArray()).Last().Trim(), out DefaultCustID) && DefaultCustID > 0)
                    {

                    }
                    else if (Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out StateID) && StateID > 0)
                    {
                        DefaultCustID = ctx.OCRDs.Where(x => x.ParentID == ParentID && x.Type == Type && x.Active == true
                                                                        && x.CRD1.Any(y => !y.IsDeleted && y.StateID == StateID) && x.OEMPs.Any(z => z.EmpGroupID == 1))
                                                                                .OrderBy(x => x.CustomerID).Select(x => x.CustomerID).DefaultIfEmpty(0).FirstOrDefault();

                        IsStateWise = true;
                    }
                    else if (DefaultCustID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                        divRegion.Attributes.Remove("style");
                        divDistributor.Attributes.Remove("style");
                        divEmpGroup.Attributes.Add("style", "display:none");
                        return;
                    }

                    if (DefaultCustID > 0 && gvAuthorization.Rows.Count > 1)
                    {
                        int Grp1Count = ctx.GetKey("GRP1", "GRPID", "", DefaultCustID, 0).FirstOrDefault().Value;
                        foreach (GridViewRow item in gvAuthorization.Rows)
                        {
                            bool chkWrite = ((RadioButton)item.FindControl("chkWrite")).Checked;
                            bool chkNone = ((RadioButton)item.FindControl("chkNone")).Checked;
                            Label lblMenuID = (Label)item.FindControl("lblMenuID");

                            int MenuID;

                            if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                            {
                                var objGRP1 = ctx.GRP1.FirstOrDefault(x => x.ParentID == DefaultCustID && x.MenuID == MenuID && x.EmpGroupID == 1);
                                if (objGRP1 == null)
                                {
                                    objGRP1 = new GRP1();
                                    objGRP1.EmpGroupID = 1;
                                    objGRP1.GRPID = Grp1Count++;
                                    objGRP1.ParentID = DefaultCustID;
                                    objGRP1.MenuID = Convert.ToInt32(lblMenuID.Text);
                                    ctx.GRP1.Add(objGRP1);
                                }
                                //it is used for state filteration as update null becuase same use as single use only
                                objGRP1.Notes = null;
                                objGRP1.Active = chkIsActive.Checked;
                                objGRP1.UpdatedBy = UserID;
                                objGRP1.UpdatedDate = DateTime.Now;
                                if (chkWrite == true)
                                    objGRP1.AuthorizationType = "W";
                                else if (chkNone == true)
                                    objGRP1.AuthorizationType = "N";
                                else
                                    objGRP1.AuthorizationType = "N";
                            }
                        }

                        ctx.SaveChanges();

                        if (IsStateWise)
                        {
                            Oledb_ConnectionClass objClass = new Oledb_ConnectionClass();
                            SqlCommand Cm = new SqlCommand();
                            Cm.Parameters.Clear();
                            Cm.CommandType = CommandType.StoredProcedure;
                            Cm.CommandText = "SetAuthorizationForCompany";
                            Cm.Parameters.AddWithValue("@DistributorID", DefaultCustID);
                            Cm.Parameters.AddWithValue("@StateID", StateID);
                            Cm.Parameters.AddWithValue("@Type", Type);
                            Cm.Parameters.AddWithValue("@UserId", UserID);
                            DataSet ds = objClass.CommonFunctionForSelect(Cm);
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                        ResetControls();
                        return;
                    }
                }
                else
                {
                    int EmpGroupID;
                    if (Int32.TryParse(ddlEGroup.SelectedValue, out EmpGroupID) && EmpGroupID > 0)
                    {
                        int count = ctx.GetKey("GRP1", "GRPID", "", ParentID, 0).FirstOrDefault().Value;
                        foreach (GridViewRow item in gvAuthorization.Rows)
                        {
                            bool chkWrite = ((RadioButton)item.FindControl("chkWrite")).Checked;
                            bool chkNone = ((RadioButton)item.FindControl("chkNone")).Checked;
                            Label lblMenuID = (Label)item.FindControl("lblMenuID");

                            int MenuID;

                            if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                            {
                                var objGRP1 = ctx.GRP1.FirstOrDefault(x => x.ParentID == ParentID && x.MenuID == MenuID && x.EmpGroupID == EmpGroupID);
                                if (objGRP1 == null)
                                {
                                    objGRP1 = new GRP1();
                                    objGRP1.EmpGroupID = EmpGroupID;
                                    objGRP1.GRPID = count++;
                                    objGRP1.ParentID = ParentID;

                                    objGRP1.MenuID = Convert.ToInt32(lblMenuID.Text);
                                    ctx.GRP1.Add(objGRP1);
                                }

                                objGRP1.Active = chkIsActive.Checked;
                                objGRP1.UpdatedBy = UserID;
                                objGRP1.UpdatedDate = DateTime.Now;

                                if (chkWrite == true)
                                    objGRP1.AuthorizationType = "W";
                                else if (chkNone == true)
                                    objGRP1.AuthorizationType = "N";
                                else
                                    objGRP1.AuthorizationType = "N";
                            }
                        }

                        ctx.SaveChanges();

                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper group..!',3);", true);
                        ResetControls();
                        return;
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                ClearAllInputs();
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

    protected void btnSubmitPriority_Click(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                if (ddlFor.SelectedValue != "1" && CustType == 1)
                {
                    int StateID = 0;
                    Decimal DefaultCustID = 0;

                    int Type = Convert.ToInt32(ddlFor.SelectedValue);

                    if (Decimal.TryParse(txtCustomer.Text.Split("-".ToArray()).Last().Trim(), out DefaultCustID) && DefaultCustID > 0)
                    {

                    }
                    else if (Int32.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out StateID) && StateID > 0)
                    {
                        DefaultCustID = ctx.OCRDs.Where(x => x.ParentID == ParentID && x.Type == Type
                                                                        && x.CRD1.Any(y => !y.IsDeleted && y.StateID == StateID) && x.OEMPs.Any(z => z.EmpGroupID == 1))
                                                                                .OrderBy(x => x.CustomerID).Select(x => x.CustomerID).DefaultIfEmpty(0).FirstOrDefault();
                    }
                    else if (DefaultCustID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                        divRegion.Attributes.Remove("style");
                        divDistributor.Attributes.Remove("style");
                        divEmpGroup.Attributes.Add("style", "display:none");
                        return;
                    }

                    if (DefaultCustID > 0 && gvAuthorization.Rows.Count > 1)
                    {
                        int Grp1Count = ctx.GetKey("GRP1", "GRPID", "", DefaultCustID, 0).FirstOrDefault().Value;
                        foreach (GridViewRow item in gvAuthorization.Rows)
                        {
                            Label lblMenuID = (Label)item.FindControl("lblMenuID");
                            TextBox txtPriority = (TextBox)item.FindControl("txtPriority");

                            int MenuID;

                            if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                            {
                                var objGRP1 = ctx.GRP1.FirstOrDefault(x => x.ParentID == DefaultCustID && x.MenuID == MenuID && x.EmpGroupID == 1);
                                var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                                if (objGRP1 != null)
                                {
                                    objGRP1.UpdatedBy = UserID;
                                    objGRP1.UpdatedDate = DateTime.Now;
                                }
                                int IntNum = 0;
                                if (objOMNU != null)
                                    objOMNU.SortOrder = Int32.TryParse(txtPriority.Text, out IntNum) ? IntNum : 0;
                            }
                        }
                        ctx.SaveChanges();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('No Distributor found.',3);", true);
                        ResetControls();
                        return;
                    }
                }
                else
                {
                    int EmpGroupID;
                    if (Int32.TryParse(ddlEGroup.SelectedValue, out EmpGroupID) && EmpGroupID > 0)
                    {
                        int count = ctx.GetKey("GRP1", "GRPID", "", ParentID, 0).FirstOrDefault().Value;
                        foreach (GridViewRow item in gvAuthorization.Rows)
                        {
                            Label lblMenuID = (Label)item.FindControl("lblMenuID");

                            int MenuID;

                            if (lblMenuID != null && Int32.TryParse(lblMenuID.Text, out MenuID))
                            {
                                var objGRP1 = ctx.GRP1.FirstOrDefault(x => x.ParentID == ParentID && x.MenuID == MenuID && x.EmpGroupID == EmpGroupID);
                                var objOMNU = ctx.OMNUs.Where(x => x.MenuID == MenuID && x.Active).FirstOrDefault();
                                TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                                if (objGRP1 != null)
                                {
                                    objGRP1.UpdatedBy = UserID;
                                    objGRP1.UpdatedDate = DateTime.Now;
                                }
                                int IntNum = 0;
                                if (objOMNU != null)
                                    objOMNU.SortOrder = Int32.TryParse(txtPriority.Text, out IntNum) ? IntNum : 0;
                            }
                        }
                        ctx.SaveChanges();
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper group..!',3);", true);
                        ResetControls();
                        return;
                    }
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

    #region GridView Command

    protected void gvAuthorization_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox txtPriority = (TextBox)e.Row.FindControl("txtPriority");
            if (ddlFor.SelectedValue != "1" && CustType == 1)
            {
                txtPriority.Visible = false;
            }
            else
            {
                txtPriority.Visible = true;
            }
        }
    }

    #endregion

    #region Change Event

    protected void ddlEGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlEGroup.SelectedValue != "0")
        {
            FillGrid(0);
        }
    }

    #endregion

    protected void chkForDistri_CheckedChanged(object sender, EventArgs e)
    {
        ClearAllInputs();
        ResetControls();
    }

    protected void txtCustomer_TextChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtCustomer.Text))
        {
            Decimal CustID = 0;

            if (Decimal.TryParse(txtCustomer.Text.Split("-".ToArray()).Last().Trim(), out CustID) && CustID > 0)
            {
                FillGrid(CustID);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Distributor..!',3); ClearAll();", true);
                ResetControls();
            }
        }
    }

    protected void txtRegion_TextChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtRegion.Text))
        {
            Decimal RegionID = 0;

            if (Decimal.TryParse(txtRegion.Text.Split("-".ToArray()).Last().Trim(), out RegionID) && RegionID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    Int16 RID = Convert.ToInt16(RegionID);
                    Int32 AutType = Int32.TryParse(ddlFor.SelectedValue, out AutType) ? AutType : 0;

                    // Decimal CustID = ctx.GRP1.Where(x => x.Notes == RID && ctx.OCRDs.Any(z => z.Type == AutType && z.CustomerID == x.ParentID)).OrderBy(x => x.ParentID).Select(x => x.ParentID).DefaultIfEmpty(0).FirstOrDefault();
                    Decimal CustID = ctx.OCRDs.Where(x => x.ParentID == ParentID && x.Type == AutType && x.Active == true
                                                                       && x.CRD1.Any(y => !y.IsDeleted && y.StateID == RID) && x.OEMPs.Any(z => z.EmpGroupID == 1))
                                                                               .OrderBy(x => x.CustomerID).Select(x => x.CustomerID).DefaultIfEmpty(0).FirstOrDefault();




                    if (CustID > 0)
                    {
                        FillGrid(CustID);
                    }
                    else
                    {
                        txtUpdateBy.Text = string.Empty;
                        txtUpdatedDate.Text = string.Empty;
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
                    }
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ClearAll();", true);
            }
        }
        else
        {
            txtUpdateBy.Text = string.Empty;
            txtUpdatedDate.Text = string.Empty;
        }
    }

    protected void gvAuthorization_PreRender(object sender, EventArgs e)
    {
        if (gvAuthorization.Rows.Count > 0)
        {
            gvAuthorization.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvAuthorization.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }
}