using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class Master_MaterialSequence : System.Web.UI.Page
{
    #region Declaration
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        var strtype = Session["Lang"].ToString();

        if (chkMode.Checked)
        {
            txtTNo.Text = "Auto generated";
            txtTNo.Enabled = ACEtxtName.Enabled = false;
            txtTNo.Style.Remove("background-color");
            txtTName.Focus();
        }
        else
        {
            txtTNo.Text = "";
            txtTNo.Enabled = ACEtxtName.Enabled = true;
            txtTNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtTNo.Focus();
        }


        List<ODIV> lstDivision = ctx.ODIVs.Where(x => x.Active).OrderBy(x => x.DivisionName).ToList();
        ddlDivision.DataSource = lstDivision;
        ddlDivision.DataTextField = "DivisionName";
        ddlDivision.DataValueField = "DivisionlID";
        ddlDivision.DataBind();
        ddlDivision.Items.Insert(0, new ListItem("--Select--", "0"));

        ddlDivision.Enabled = true;

        gvMaterial.DataSource = null;
        gvMaterial.DataBind();
        txtTName.Text = "";
        ACEtxtName.ContextKey = ParentID.ToString();
        chkActive.Checked = true;
        chkDefault.Checked = false;
        ViewState["TemplateID"] = null;
    }

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
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                OTMP objOTMP;
                int TemplateID;
                int Temp = 0;

                if (ViewState["TemplateID"] != null && Int32.TryParse(ViewState["TemplateID"].ToString(), out TemplateID))
                {
                    objOTMP = ctx.OTMPs.FirstOrDefault(x => x.TemplateID == TemplateID && x.ParentID == ParentID);
                }
                else
                {
                    if (ctx.OTMPs.Any(x => x.TemplateName == txtTName.Text && x.ParentID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same template name is not allowed!',3);", true);
                        return;
                    }

                    objOTMP = new OTMP();
                    objOTMP.TemplateID = ctx.GetKey("OTMP", "TemplateID", "", ParentID, 0).FirstOrDefault().Value;
                    objOTMP.ParentID = ParentID;
                    objOTMP.CreatedDate = DateTime.Now;
                    objOTMP.CreatedBy = UserID;
                    ctx.OTMPs.Add(objOTMP);
                }
                objOTMP.TemplateName = txtTName.Text;
                objOTMP.UpdatedDate = DateTime.Now;
                objOTMP.UpdatedBy = UserID;
                objOTMP.Active = chkActive.Checked;
                if (Convert.ToInt32(ddlDivision.SelectedValue) != 0)
                {
                    objOTMP.DivisionlID = Convert.ToInt32(ddlDivision.SelectedValue);
                }
                else
                {
                    objOTMP.DivisionlID = null;
                }
                if (chkDefault.Checked)
                {
                    ctx.OTMPs.Where(x => x.ParentID == ParentID).ToList().ForEach(x => x.IsDefault = false);
                    objOTMP.IsDefault = chkDefault.Checked;
                }
                int Count = ctx.GetKey("SITM", "SITMID", "", ParentID, 0).FirstOrDefault().Value;

                foreach (GridViewRow item in gvMaterial.Rows)
                {
                    HtmlInputCheckBox chkCheck = (HtmlInputCheckBox)item.FindControl("chkCheck");

                    Label lblItemID = (Label)item.FindControl("lblItemID");
                    TextBox txtPriority = (TextBox)item.FindControl("txtPriority");
                    //TextBox txtMinStock = (TextBox)item.FindControl("txtMinStock");
                    //TextBox txtMaxStock = (TextBox)item.FindControl("txtMaxStock");
                    int ItemID = Convert.ToInt32(lblItemID.Text);
                    if (chkCheck.Checked)
                    {
                        var objSITM = ctx.SITMs.FirstOrDefault(x => x.ParentID == ParentID && x.ItemID == ItemID && x.TemplateID == objOTMP.TemplateID);
                        if (objSITM == null)
                        {
                            objSITM = new SITM();
                            objSITM.SITMID = Count++;
                            objSITM.ParentID = ParentID;
                            objSITM.TemplateID = objOTMP.TemplateID;
                            objSITM.ItemID = ItemID;
                            ctx.SITMs.Add(objSITM);
                        }

                        objSITM.Priority = Int32.TryParse(txtPriority.Text, out Temp) ? Temp : item.RowIndex + 1;
                        objSITM.MinStock = 0;
                        objSITM.MaxStock = 0;
                    }
                    else
                    {
                        var objSITM = ctx.SITMs.FirstOrDefault(x => x.ParentID == ParentID && x.ItemID == ItemID && x.TemplateID == objOTMP.TemplateID);
                        if (objSITM != null)
                        {
                            ctx.SITMs.Remove(objSITM);
                        }
                    }
                }
                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully!',1);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    protected void gvMaterial_PreRender(object sender, EventArgs e)
    {
        if (gvMaterial.Rows.Count > 0)
        {
            gvMaterial.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvMaterial.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void txtTNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtTNo.Text))
            {
                var dataID = Convert.ToInt32(txtTNo.Text.Split("-".ToArray()).First().Trim());
                var objOTMP = ctx.OTMPs.Include("SITMs").FirstOrDefault(x => x.TemplateID == dataID && x.ParentID == ParentID);
                var strtype = Session["Lang"].ToString();

                if (objOTMP != null)
                {
                    ViewState["TemplateID"] = objOTMP.TemplateID;
                    txtTName.Text = objOTMP.TemplateName;
                    txtTNo.Text = objOTMP.TemplateID.ToString();
                    chkDefault.Checked = objOTMP.IsDefault;
                    chkActive.Checked = objOTMP.Active;
                    int divisionID = 0;
                    if (!chkDefault.Checked)
                    {
                        divisionID = objOTMP.DivisionlID.Value;
                        ddlDivision.SelectedValue = objOTMP.DivisionlID.Value.ToString();
                        ddlDivision.Enabled = true;
                        gvMaterial.DataSource = (from t in ctx.OITMs.Include("SITM").Include("ITM2")
                                                 where t.Active && t.OGITMs.Any(x => x.DivisionlID == divisionID)
                                                 select new
                                                 {
                                                     t.ItemID,
                                                     ItemCode = t.ItemCode,
                                                     ItemName = strtype == "gujarati" ? t.GujaratiItemName : t.ItemName,
                                                     UnitName = ctx.ITM1.FirstOrDefault(x => x.ItemID == t.ItemID && x.IsBaseUnit).OUNT.UnitName,
                                                     Priority = t.SITMs.Any(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID) ? t.SITMs.FirstOrDefault(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID).Priority.Value : 0,
                                                     Active = t.SITMs.Any(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID),
                                                     Division = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == t.OGITMs.FirstOrDefault(y => y.DivisionlID == divisionID && y.ItemID == t.ItemID).DivisionlID).DivisionName,
                                                 }).OrderBy(x => x.Division).OrderByDescending(n => n.Active).ThenBy(m => m.ItemCode).ToList();
                    }
                    else
                    {
                        ddlDivision.Enabled = false;
                        gvMaterial.DataSource = (from t in ctx.OITMs.Include("SITM").Include("ITM2")
                                                 where t.Active
                                                 select new
                                                 {
                                                     t.ItemID,
                                                     ItemCode = t.ItemCode,
                                                     ItemName = strtype == "gujarati" ? t.GujaratiItemName : t.ItemName,
                                                     UnitName = ctx.ITM1.FirstOrDefault(x => x.ItemID == t.ItemID && x.IsBaseUnit).OUNT.UnitName,
                                                     Priority = t.SITMs.Any(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID) ? t.SITMs.FirstOrDefault(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID).Priority.Value : 0,
                                                     Active = t.SITMs.Any(x => x.TemplateID == objOTMP.TemplateID && x.ParentID == ParentID),
                                                     Division = ctx.ODIVs.FirstOrDefault(x => x.DivisionlID == t.OGITMs.FirstOrDefault(y => y.DivisionlID == x.DivisionlID && y.ItemID == t.ItemID).DivisionlID).DivisionName,
                                                 }).OrderBy(x => x.Division).OrderByDescending(n => n.Active).ThenBy(m => m.ItemCode).ToList();
                    }



                    gvMaterial.DataBind();

                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper Template!',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtTNo.Focus();
    }

    protected void ddlDivision_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (chkDefault.Checked)
        {
            ddlDivision.Enabled = false;
            ddlDivision.SelectedIndex = 0;
            gvMaterial.DataSource = (from t in ctx.OITMs
                                     where t.Active
                                     select new
                                     {
                                         t.ItemID,
                                         ItemCode = t.ItemCode,
                                         ItemName = t.ItemName,
                                         UnitName = ctx.ITM1.FirstOrDefault(x => x.ItemID == t.ItemID && x.IsBaseUnit).OUNT.UnitName,
                                         Priority = "",
                                         Active = false
                                     }).OrderBy(x => x.ItemName).ToList();
        }
        else
        {
            ddlDivision.Enabled = true;
            if (ddlDivision.SelectedValue == "--Select--")
            {
                gvMaterial.DataSource = null;
                gvMaterial.DataBind();
                return;
            }

            int divisionID = Convert.ToInt32(ddlDivision.SelectedValue);
            gvMaterial.DataSource = (from t in ctx.OITMs
                                     where t.Active && t.OGITMs.Any(x => x.DivisionlID == divisionID)
                                     select new
                                     {
                                         t.ItemID,
                                         ItemCode = t.ItemCode,
                                         ItemName = t.ItemName,
                                         UnitName = ctx.ITM1.FirstOrDefault(x => x.ItemID == t.ItemID && x.IsBaseUnit).OUNT.UnitName,
                                         Priority = "",
                                         Active = false
                                     }).OrderBy(x => x.ItemName).ToList();
        }
        gvMaterial.DataBind();
    }
}