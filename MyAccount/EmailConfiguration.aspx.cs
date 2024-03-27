using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

[Serializable]
public class ConfigData
{
    public int PlantID { get; set; }
    public String PlantCode { get; set; }
    public String PlantName { get; set; }
    public String DocType { get; set; }
    public String SuccessEmail { get; set; }
    public String FailureEmail { get; set; }
    public String SuccessSMS { get; set; }
    public String FailureSMS { get; set; }
    public Boolean Active { get; set; }
}

public partial class MyAccount_EmailConfiguration : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    private List<ConfigData> EML2s
    {
        get { return this.ViewState["EML2"] as List<ConfigData>; }
        set { this.ViewState["EML2"] = value; }
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
                            var unit = xml.Descendants("Inward");
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

    private void ClearAllInputs()
    {

        txtPlant.Style.Add("background-color", "rgb(250, 255, 189);");
        txtCopyFrmPlant.Style.Add("background-color", "rgb(250, 255, 189);");

        ViewState["ConfigID"] = null;
        btnAddConfig.Text = "Add Configuration";

        txtPlant.Enabled = ddlType.Enabled = true;

        txtPlant.Text = txtFailureEmail.Text = txtSucessEmail.Text = txtFailureMsgMobile.Text = txtSucessMsgMobile.Text = "";
        gvEmailConfig.DataSource = null;
        gvEmailConfig.DataBind();
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

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (EML2s != null)
                {
                    using (DDMSEntities ctx = new DDMSEntities())
                    {
                        int EML2Count = ctx.GetKey("EML2", "EML2ID", "", ParentID, 0).FirstOrDefault().Value;

                        foreach (ConfigData item in EML2s)
                        {
                            if (item.PlantID > 0 && !string.IsNullOrEmpty(item.DocType))
                            {
                                EML2 objEML2 = ctx.EML2.FirstOrDefault(x => x.PlantID == item.PlantID && x.DocType == item.DocType);
                                if (objEML2 == null)
                                {
                                    objEML2 = new EML2();
                                    objEML2.EML2ID = EML2Count++;
                                    objEML2.CreatedDate = DateTime.Now;
                                    objEML2.CreatedBy = UserID;
                                    ctx.EML2.Add(objEML2);
                                }
                                objEML2.PlantID = item.PlantID;
                                objEML2.ParentID = ParentID;
                                objEML2.DocType = item.DocType;
                                objEML2.SuccessEmail = item.SuccessEmail;
                                objEML2.FailureEmail = item.FailureEmail;
                                objEML2.SuccessSMS = item.SuccessSMS;
                                objEML2.FailureSMS = item.FailureSMS;
                                objEML2.Active = item.Active;
                                objEML2.UpdatedDate = DateTime.Now;
                                objEML2.UpdatedBy = UserID;
                            }
                        }
                        ctx.SaveChanges();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1);", true);
                        ClearAllInputs();
                    }

                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ViewState["ConfigID"] = null;
        btnAddConfig.Text = "Add Configuration";

        ClearAllInputs();
    }

    #endregion

    #region Change Event

    protected void txtPlant_TextChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtPlant.Text))
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                int PlantID;
                var DocType = ddlType.SelectedValue.ToString();
                if (Int32.TryParse(txtPlant.Text.Split("-".ToArray()).First().Trim(), out PlantID) && PlantID > 0)
                {
                    EML2s = ctx.EML2.Where(x => x.PlantID == PlantID).Select(x => new ConfigData
                    {
                        PlantID = x.PlantID,
                        PlantName = ctx.OPLTs.FirstOrDefault(y => y.PlantID == PlantID).PlantName,
                        PlantCode = ctx.OPLTs.FirstOrDefault(y => y.PlantID == PlantID).PlantCode,
                        DocType = x.DocType,
                        SuccessEmail = x.SuccessEmail,
                        FailureEmail = x.FailureEmail,
                        SuccessSMS = x.SuccessSMS,
                        FailureSMS = x.FailureSMS,
                        Active = x.Active
                    }).ToList();

                    gvEmailConfig.DataSource = EML2s;
                    gvEmailConfig.DataBind();
                }
            }
        }
    }

    #endregion

    #region Configuration Data

    protected void btnAddConfig_Click(object sender, EventArgs e)
    {
        if (EML2s == null)
            EML2s = new List<ConfigData>();

        int LineID, PlantID;

        if (!string.IsNullOrEmpty(txtPlant.Text) && txtPlant.Text.Split("-".ToArray()).Length > 1)
        {
            using (DDMSEntities ctx = new DDMSEntities())
            {
                var objPlant = txtPlant.Text.Split("-".ToArray());
                if (Int32.TryParse(objPlant.First().Trim(), out PlantID) && PlantID > 0)
                {
                    ConfigData Data = null;
                    if (ViewState["ConfigID"] != null && Int32.TryParse(ViewState["ConfigID"].ToString(), out LineID))
                    {
                        Data = EML2s[LineID];
                        Data.PlantID = PlantID;
                        Data.PlantCode = objPlant[1].ToString();
                        Data.PlantName = objPlant[2].ToString();
                        Data.DocType = ddlType.SelectedValue;
                        Data.SuccessEmail = txtSucessEmail.Text;
                        Data.FailureEmail = txtFailureEmail.Text;
                        Data.SuccessSMS = txtSucessMsgMobile.Text;
                        Data.FailureSMS = txtFailureMsgMobile.Text;
                        Data.Active = chkIsActive.Checked;
                    }
                    else
                    {
                        if (!EML2s.Any(x => x.PlantID == PlantID && x.DocType == ddlType.SelectedValue))
                        {
                            if (!ctx.EML2.Any(x => x.PlantID == PlantID && x.DocType == ddlType.SelectedValue))
                            {
                                Data = new ConfigData();
                                Data.PlantID = PlantID;
                                Data.PlantCode = objPlant[1].ToString();
                                Data.PlantName = objPlant[2].ToString();
                                Data.DocType = ddlType.SelectedValue;
                                Data.SuccessEmail = txtSucessEmail.Text;
                                Data.FailureEmail = txtFailureEmail.Text;
                                Data.SuccessSMS = txtSucessMsgMobile.Text;
                                Data.FailureSMS = txtFailureMsgMobile.Text;
                                Data.Active = chkIsActive.Checked;
                                EML2s.Add(Data);
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Plant - Type name is already exist!',3);", true);
                                return;
                            }
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Plant - Type name is not allowed!',3);", true);
                            return;
                        }
                    }
                    ViewState["ConfigID"] = null;
                    btnAddConfig.Text = "Add Configuration";
                    txtPlant.Text = txtSucessEmail.Text = txtFailureEmail.Text = txtFailureMsgMobile.Text = txtSucessMsgMobile.Text = "";
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('select proper plant.',3);", true);

                gvEmailConfig.DataSource = EML2s;
                gvEmailConfig.DataBind();
                txtPlant.Enabled = true;
                ddlType.Enabled = true;
            }
        }

    }

    protected void gvEmailConfig_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteConfig")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            EML2s.RemoveAt(LineID);

            gvEmailConfig.DataSource = EML2s;
            gvEmailConfig.DataBind();
        }
        if (e.CommandName == "EditConfig")
        {
            txtPlant.Enabled = false;
            ddlType.Enabled = false;
            int LineID = Convert.ToInt32(e.CommandArgument);
            var objEML2 = EML2s[LineID];

            if (!string.IsNullOrEmpty(objEML2.PlantName) && objEML2.PlantID > 0)
                txtPlant.Text = objEML2.PlantID + " - " + objEML2.PlantCode + " - " + objEML2.PlantName;
            else
                txtPlant.Text = "";

            if (!string.IsNullOrEmpty(objEML2.DocType))
                ddlType.SelectedValue = objEML2.DocType;

            if (!string.IsNullOrEmpty(objEML2.FailureEmail))
                txtFailureEmail.Text = objEML2.FailureEmail;
            else
                txtFailureEmail.Text = "";

            if (!string.IsNullOrEmpty(objEML2.SuccessEmail))
                txtSucessEmail.Text = objEML2.SuccessEmail;
            else
                txtSucessEmail.Text = "";

            if (!string.IsNullOrEmpty(objEML2.SuccessSMS))
                txtSucessMsgMobile.Text = objEML2.SuccessSMS;
            else
                txtSucessMsgMobile.Text = "";

            if (!string.IsNullOrEmpty(objEML2.FailureSMS))
                txtFailureMsgMobile.Text = objEML2.FailureSMS;
            else
                txtFailureMsgMobile.Text = "";

            chkIsActive.Checked = objEML2.Active;

            ViewState["ConfigID"] = LineID;
            btnAddConfig.Text = "Update Configuration";
        }
    }

    protected void gvEmailConfig_PreRender(object sender, EventArgs e)
    {

        if (gvEmailConfig.Rows.Count > 0)
        {
            gvEmailConfig.HeaderRow.TableSection = TableRowSection.TableHeader;
            gvEmailConfig.FooterRow.TableSection = TableRowSection.TableFooter;
        }
    }

    #endregion
}