using System;
using System.Data.Entity.Validation;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Master_DealerFeedBack : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected int CustType;
    String TempPath = Path.GetTempPath();

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            txtQuesNo.Enabled = ACEtxtName.Enabled = false;
            txtQuesNo.Style.Remove("background-color");
            txtQuesNo.Text = "Auto Generated";
            btnSubmit.Text = "Submit";
            txtQuestion.Style.Remove("background-color");
            txtQuestion.Focus();
        }
        else
        {
            btnSubmit.Text = "Update";
            txtQuestion.Focus();
            txtQuesNo.Enabled = ACEtxtName.Enabled = true;
            txtQuesNo.Text = "";
            txtQuesNo.Style.Add("background-color", "rgb(250, 255, 189);");
            txtQuesNo.Focus();
        }
        ChkActive.Checked = true;
        ChkMandatory.Checked = false;
        txtQuesNo.Text = txtQuestion.Text = txtPosibility.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = txtSortOrder.Text = "";
        ddlType.SelectedIndex = ddlBrand.SelectedIndex = ddlCategory.SelectedIndex = ddlSelectivetype.SelectedIndex = ddlDescriptivetype.SelectedIndex = ddlRatingType.SelectedIndex = 0;
        using (DDMSEntities ctx = new DDMSEntities())
        {
            ddlType.Items.Clear();
            ddlType.DataSource = ctx.OFBTs.Where(x => x.Active).Select(x => new { FeedbackTypeID = x.FeedbackTypeID, FeedbackName = x.FeedbackName }).ToList();
            ddlType.DataTextField = "FeedbackName";
            ddlType.DataValueField = "FeedbackTypeID";
            ddlType.DataBind();
        }
        ViewState["MstID"] = null;
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
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
                    var UserType = Session["UserType"].ToString();
                    if (Auth.OMNU.MenuType.ToUpper() == "B" || UserType.ToUpper() == "B" || UserType.ToUpper() == Auth.OMNU.MenuType.ToUpper()) { }
                    else
                        Response.Redirect("~/AccessError.aspx");

                    if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                    {
                        try
                        {
                            var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                            var unit = xml.Descendants("employee_grp_master");
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
    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #region Change Event

    protected void txtQuesNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtQuesNo.Text))
            {
                var word = txtQuesNo.Text.Split("-".ToArray());
                if (word.Length > 1)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        int ID = Convert.ToInt32(word.First().Trim());
                        var objDFQUES = ctx.DFQUES.FirstOrDefault(x => x.QuesID == ID);
                        if (objDFQUES != null)
                        {
                            txtQuesNo.Text = objDFQUES.QuesID.ToString();
                            txtQuestion.Text = objDFQUES.Question;
                            ChkActive.Checked = objDFQUES.Active;
                            ChkMandatory.Checked = objDFQUES.Mandatory;
                            ddlType.ClearSelection();
                            ddlType.Items.FindByText(objDFQUES.Type).Selected = true;
                            ddlCategory.ClearSelection();
                            ddlCategory.Items.FindByText(objDFQUES.Category).Selected = true;
                            if (objDFQUES.Category == "Selective" && (objDFQUES.SubCategory == "Any" || objDFQUES.SubCategory == "Many"))
                            {
                                ddlSelectivetype.ClearSelection();
                                ddlSelectivetype.Items.FindByText(objDFQUES.SubCategory).Selected = true;
                            }
                            else if (objDFQUES.Category == "Descriptive" && (objDFQUES.SubCategory == "Text" || objDFQUES.SubCategory == "Numeric"))
                            {
                                ddlDescriptivetype.ClearSelection();
                                ddlDescriptivetype.Items.FindByText(objDFQUES.SubCategory).Selected = true;
                            }
                            else if (objDFQUES.Category == "Rating" && objDFQUES.SubCategory == "Text")
                            {
                                ddlRatingType.ClearSelection();
                                ddlRatingType.Items.FindByText(objDFQUES.SubCategory).Selected = true;
                            }
                            txtPosibility.Text = objDFQUES.Posibility;
                            ViewState["MstID"] = objDFQUES.QuesID;
                            txtSortOrder.Text = objDFQUES.SortOrder.ToString();

                            txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objDFQUES.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                            txtCreatedTime.Text = objDFQUES.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                            txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objDFQUES.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                            txtUpdatedTime.Text = objDFQUES.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                        }
                    }
                }
            }
            else
                ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

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

    #endregion

    #region Button Click

    protected void btnSubmitClick(object sender, EventArgs e)
    {
        try
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int MstID = 0;
                if (ddlType.SelectedItem == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "infomsg('Please select at least one Feedback Type !',3);", true);
                    return;
                }
                int FeedbackId = int.TryParse(ddlType.SelectedItem.Value, out FeedbackId) ? FeedbackId : 0;
                if (FeedbackId == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "infomsg('Please select at least one Feedback Type !',3);", true);
                    return;
                }
                var objDFQUE = new DFQUE();
                Int32 Int = 0;

                if (ViewState["MstID"] != null && Int32.TryParse(ViewState["MstID"].ToString(), out MstID))
                {
                    objDFQUE = ctx.DFQUES.FirstOrDefault(x => x.QuesID == MstID);
                }
                else
                {
                    objDFQUE.QuesID = ctx.GetKey("DFQUES", "QuesID", "", 0, 0).FirstOrDefault().Value;
                    objDFQUE.ParentID =ParentID;
                    objDFQUE.CreatedDate = DateTime.Now;
                    objDFQUE.CreatedBy = UserID;
                    ctx.DFQUES.Add(objDFQUE);
                }
                if (ctx.OQUES.Any(x => x.Question.ToLower().Trim() == txtQuestion.Text.ToLower().Trim() && x.QuesID != MstID && x.Type == ddlType.SelectedItem.Text.Trim()))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Questions Already Exists!',3);", true);
                    return;
                }
                objDFQUE.EmpGroupID = null;
                objDFQUE.EmpID = null;
                objDFQUE.BranDID = null;
                objDFQUE.Question = txtQuestion.Text;
                objDFQUE.Posibility = txtPosibility.Text;
                objDFQUE.Type = ddlType.SelectedItem.Text;
                objDFQUE.FeedbackTypeID = FeedbackId;
                objDFQUE.Category = ddlCategory.SelectedItem.Text;

                if (ddlCategory.SelectedValue == "S")
                {
                    objDFQUE.SubCategory = ddlSelectivetype.SelectedItem.Text;
                }
                else if (ddlCategory.SelectedValue == "D")
                {
                    objDFQUE.SubCategory = ddlDescriptivetype.SelectedItem.Text;
                }
                else
                {
                    objDFQUE.SubCategory = ddlRatingType.SelectedItem.Text;
                }
                objDFQUE.SortOrder = Int32.TryParse(txtSortOrder.Text, out Int) ? Int : 0;
                objDFQUE.Active = ChkActive.Checked;
                objDFQUE.Mandatory = ChkMandatory.Checked;
                objDFQUE.UpdatedDate = DateTime.Now;
                objDFQUE.UpdatedBy = UserID;
                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully.',1);", true);
            }

        }
        catch (DbEntityValidationException ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + ex.EntityValidationErrors.FirstOrDefault().ValidationErrors.FirstOrDefault().ErrorMessage + "',2);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnCancelClick(object sender, EventArgs e)
    {
        Response.Redirect("DealerFeedBack.aspx");
    }

    #endregion
}