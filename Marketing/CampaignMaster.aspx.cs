using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Marketing_CampaignMaster : System.Web.UI.Page
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
        if (chkMode.Checked)
        {
            acettxtCampaignName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCampaignName.Style.Remove("background-color");
        }
        else
        {
            acettxtCampaignName.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCampaignName.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        chkActive.Checked = true;
        txtCampaignName.Focus();
        txtCampaignName.Text = txtDesc.Text = "";
        txtEDate.Text = "";
        txtSDate.Text = "";
        foreach (ListItem item in cblTppl.Items)
        {
            item.Selected = false;
        }
        foreach (ListItem item in cblType.Items)
        {
            item.Selected = false;
        }
        ViewState["CampaignID"] = null;
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
                        var unit = xml.Descendants("campaign_master");
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
        acettxtCampaignName.ContextKey = ParentID.ToString();
        if (!IsPostBack)
        {
            ClearAllInputs();
        }
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                var objOCMP = new OCMP();
                int CID;
                if (ViewState["CampaignID"] != null && Int32.TryParse(ViewState["CampaignID"].ToString(), out CID))
                {
                    objOCMP = ctx.OCMPs.FirstOrDefault(x => x.CampaignID == CID);
                }
                else
                {

                    if (ctx.OCMPs.Any(x => x.CampaignName == txtCampaignName.Text && x.ParentID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same campaign Name is not allowed!',3);", true);
                        return;
                    }

                    objOCMP.CampaignID = ctx.GetKey("OCMP", "CampaignID", "", ParentID, 0).FirstOrDefault().Value;
                    objOCMP.ParentID = ParentID;
                    objOCMP.CreatedDate = DateTime.Now;
                    objOCMP.CreatedBy = UserID;
                    ctx.OCMPs.Add(objOCMP);
                }
                objOCMP.CampaignName = txtCampaignName.Text;
                objOCMP.CampaignDesc = txtDesc.Text;
                objOCMP.Active = chkActive.Checked;
                objOCMP.UpdatedDate = DateTime.Now;
                objOCMP.UpdatedBy = UserID;
                objOCMP.StartDate = Common.DateTimeConvert(txtSDate.Text);
                objOCMP.EndDate = Common.DateTimeConvert(txtEDate.Text);

                string temp = "";
                foreach (ListItem item in cblTppl.Items)
                {
                    if (item.Selected)
                        temp += item.Value + ",";
                }
                objOCMP.TargertPeoples = temp.TrimEnd(",".ToArray());

                temp = "";
                foreach (ListItem item in cblType.Items)
                {
                    if (item.Selected)
                        temp += item.Value + ",";
                }
                objOCMP.Type = temp.TrimEnd(",".ToArray());

                ctx.SaveChanges();

                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOCMP.CampaignName + "',1);", true);
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
        Response.Redirect("../Marketing/Marketing.aspx");
    }

    #endregion

    #region Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void txtCampaignName_OnTextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && !string.IsNullOrEmpty(txtCampaignName.Text))
            {
                var objOCMP = ctx.OCMPs.FirstOrDefault(x => x.CampaignName == txtCampaignName.Text && x.ParentID == ParentID);
                if (objOCMP != null)
                {
                    txtCampaignName.Text = objOCMP.CampaignName;
                    txtDesc.Text = objOCMP.CampaignDesc;
                    chkActive.Checked = objOCMP.Active;
                    txtSDate.Text = Common.DateTimeConvert(objOCMP.StartDate);
                    txtEDate.Text = Common.DateTimeConvert(objOCMP.EndDate);

                    foreach (ListItem item in cblTppl.Items)
                    {
                        if (item.Value.Contains(objOCMP.TargertPeoples))
                            item.Selected = true;
                        else
                            item.Selected = false;
                    }
                    foreach (ListItem item in cblType.Items)
                    {
                        if (item.Value.Contains(objOCMP.Type))
                            item.Selected = true;
                        else
                            item.Selected = false;
                    }
                    ViewState["CampaignID"] = objOCMP.CampaignID;
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper campaign',3);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCampaignName.Focus();
    }

    #endregion
}