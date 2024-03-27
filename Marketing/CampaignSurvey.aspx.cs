using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Marketing_CampaignSurvey : System.Web.UI.Page
{
    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #region Helper Method

    private void ClearAllInputs()
    {
        chkNewLetterSubscription.Checked = true;
        ddlCampaign.SelectedValue = "0";
        txtCompanyName.Text = txtContactName.Text = txtFollowUpDate.Text = txtEmail.Text = txtIndustry.Text = txtPhoneNumber.Text = txtWebsite.Text = txtNotes.Text = "";
        gvCampaignQuestion.Visible = false;
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

                if (Session["Lang"] != null && Session["Lang"].ToString() == "gujarati")
                {
                    try
                    {
                        var xml = XDocument.Load(Server.MapPath("../Document/forlanguage.xml"));
                        var unit = xml.Descendants("campaign_survey");
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
        if (!IsPostBack)
        {
            ClearAllInputs();
            ddlCampaign.Focus();
        }
    }

    #endregion

    #region Save Button Click Event

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                using (var ctx = new DDMSEntities())
                {
                    var objMCMP = new MCMP();

                    objMCMP.MCMPID = ctx.GetKey("MCMP", "MCMPID", "", ParentID, 0).FirstOrDefault().Value;
                    objMCMP.ParentID = ParentID;
                    objMCMP.CampaignID = Convert.ToInt32(ddlCampaign.SelectedValue);
                    objMCMP.CompanyName = txtCompanyName.Text;
                    objMCMP.Contact_Name = txtContactName.Text;
                    objMCMP.NewsletterSubscription = chkNewLetterSubscription.Checked;
                    objMCMP.FollowUpDate = Common.DateTimeConvert(txtFollowUpDate.Text);

                    objMCMP.EMail = txtEmail.Text;
                    objMCMP.Industry = txtIndustry.Text;
                    objMCMP.Phone = txtPhoneNumber.Text;
                    objMCMP.Website = txtWebsite.Text;
                    objMCMP.Notes = txtNotes.Text;

                    objMCMP.CreatedDate = DateTime.Now;
                    objMCMP.CreatedBy = UserID;
                    objMCMP.UpdatedBy = UserID;
                    objMCMP.UpdatedDate = DateTime.Now;

                    ctx.MCMPs.Add(objMCMP);

                    int Count = ctx.GetKey("CMP1", "CMP1ID", "", ParentID, 0).FirstOrDefault().Value;
                    String YesNO = "";
                    foreach (GridViewRow item in gvCampaignQuestion.Rows)
                    {
                        Label lblQuesID = (Label)item.FindControl("lblQuesID");
                        RadioButton rbAnsYes = (RadioButton)item.FindControl("rbAnsYes");

                        var objCMP1 = new CMP1();
                        objCMP1.ParentID = ParentID;
                        objCMP1.CMP1ID = Count++;
                        objCMP1.MCMPID = objMCMP.MCMPID;
                        objCMP1.QuesID = Convert.ToInt32(lblQuesID.Text);
                        if (rbAnsYes.Checked)
                            YesNO = "Y";
                        else
                            YesNO = "N";

                        objCMP1.Answer = YesNO;
                        objMCMP.CMP1.Add(objCMP1);
                    }
                    ctx.SaveChanges();
                    ClearAllInputs();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted sucessfully!',1);", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Page is invalid!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Marketing.aspx");
    }

    #endregion


    protected void ddlCampaign_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvCampaignQuestion.Visible = true;
        edsgvCampaignQue.Where = "it.CampaignID =" + ddlCampaign.SelectedValue + " and it.Active=true and it.DocType == 'C'";
        gvCampaignQuestion.DataSourceID = "edsgvCampaignQue";
        gvCampaignQuestion.DataBind();
    }
}