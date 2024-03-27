using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Linq;

public partial class Finance_ChartOfAccount : System.Web.UI.Page
{
    #region Declaretion

    protected int UserID;
    protected decimal ParentID;
    protected decimal ParentCustID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Hepler Method

    private void ClearAllInputs()
    {
        ddlGLGroupName.Focus();
        if (chkMode.Checked)
        {
            acettxtGLCode.Enabled = false;
            btnSubmit.Text = "Add";
            ddlGLGroupName.Enabled = ddlParentGL.Enabled = true;
            lblGLAccCode.Visible = false;
        }
        else
        {
            acettxtGLCode.Enabled = true;
            btnSubmit.Text = "Update";
            ddlGLGroupName.Enabled = ddlParentGL.Enabled = false;
            txtGLAccCode.Style.Add("background-color", "rgb(250, 255, 189);");
            lblGLAccCode.Visible = true;
        }
        lblACName.Visible = false;
        txtGLName.Enabled = true;
        ViewState["GLAccID"] = null;
        ddlGLGroupName.DataBind();
        ddlGLGroupName.Items.Insert(0, new ListItem("---Select---", "0"));
        ddlGLGroupName.SelectedValue = "0";
        ddlParentGL.SelectedValue = "0";
        txtGLAmount.Text = "0";
        txtCrrditLimit.Text = "0";
        txtGLAccCode.Text = txtGLName.Text = txtCreditDays.Text = txtGLAmount.Text = txtNotes.Text = txtACName.Text = "";
        ChartofAccount.Attributes.Remove("src");
    }

    public void ValidateUser()
    {
        if (Session["UserID"] != null && Session["ParentID"] != null &&
          Int32.TryParse(Session["UserID"].ToString(), out UserID) && Decimal.TryParse(Session["ParentID"].ToString(), out ParentID))
        {
            ctx = new DDMSEntities();
            int EGID = Convert.ToInt32(Session["GroupID"]);
            int CustType = Convert.ToInt32(Session["Type"]);
            ParentCustID = Convert.ToDecimal(Session["OutletPID"]);
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
                        var unit = xml.Descendants("chart_of_account");
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
        }
    }

    #endregion

    #region Save Update Mode Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            int GLID;
            int IntNum = 0;
            Decimal DecNum = 0;
            var objOGLA = new OGLA();
            if (Page.IsValid)
            {
                if (ViewState["GLAccID"] != null && Int32.TryParse(ViewState["GLAccID"].ToString(), out GLID))
                {
                    objOGLA = ctx.OGLAs.FirstOrDefault(x => x.GLAccID == GLID && x.ParentID == ParentID);
                    if (ddlParentGL.SelectedItem.Text == "Sundry Debtor")
                    {
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var ACCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode.Contains(Acname) && x.ParentID == ParentID);
                        if (ACCust != null && !ctx.OGLAs.Any(x => x.UserID == ACCust.CustomerID && x.ParentID == ParentID && x.GLAccID != objOGLA.GLAccID && x.ParentGL == 14))
                            objOGLA.UserID = ACCust.CustomerID;
                    }
                    else if (ddlParentGL.SelectedItem.Text == "Employee Outstanding")
                    {
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var ACEmp = ctx.OEMPs.FirstOrDefault(x => x.EmpCode.Contains(Acname) && x.ParentID == ParentID);
                        if (ACEmp != null && !ctx.OGLAs.Any(x => x.UserID == ACEmp.EmpID && x.ParentID == ParentID && x.GLAccID != objOGLA.GLAccID && x.ParentGL == 15))
                        {
                            objOGLA.UserID = ACEmp.EmpID;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select employee A/C name!',3);", true);
                            txtGLName.Text = txtACName.Text = "";
                            txtACName.Focus();
                            return;
                        }
                    }
                    else if (ddlParentGL.SelectedItem.Text == "Sundry Creditor")
                    {
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var ACEmp = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == Acname && x.ParentID == ParentID);
                        if (ACEmp != null && !ctx.OGLAs.Any(x => x.UserID == ACEmp.VendorID && x.ParentID == ParentID && x.ParentGL == 21))
                            objOGLA.UserID = ACEmp.VendorID;
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select vendor A/C name!',3);", true);
                            txtGLName.Text = txtACName.Text = "";
                            txtACName.Focus();
                            return;
                        }
                    }
                    if (txtGLAmount.Text != "0")
                    {
                        if (!chkIsActive.Checked)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('This GL Account can not be deactivated!',3);", true);
                            return;
                        }
                    }
                }
                else
                {
                    objOGLA.GLAccID = ctx.GetKey("OGLA", "GLAccID", "", ParentID, 0).FirstOrDefault().Value;
                    objOGLA.ParentID = ParentID;
                    objOGLA.GLAccCode = ddlGLGroupName.SelectedItem.Text.Substring(0, 1) + objOGLA.GLAccID.ToString("D5");
                    objOGLA.GLAccGroupID = Convert.ToInt32(ddlGLGroupName.SelectedValue);
                    if (ddlParentGL.SelectedItem.Text == "Sundry Debtor")
                    {
                        objOGLA.ParentGL = Convert.ToInt32(ddlParentGL.SelectedValue);
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var ACCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerCode == Acname && x.ParentID == ParentID);
                        if (ACCust != null && !ctx.OGLAs.Any(x => x.UserID == ACCust.CustomerID && x.ParentID == ParentID && x.ParentGL == 14))
                            objOGLA.UserID = ACCust.CustomerID;
                    }
                    else if (ddlParentGL.SelectedItem.Text == "Employee Outstanding")
                    {
                        objOGLA.ParentGL = Convert.ToInt32(ddlParentGL.SelectedValue);
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var ACEmp = ctx.OEMPs.FirstOrDefault(x => x.EmpCode == Acname && x.ParentID == ParentID);
                        if (ACEmp != null && !ctx.OGLAs.Any(x => x.UserID == ACEmp.EmpID && x.ParentID == ParentID && x.ParentGL == 15))
                            objOGLA.UserID = ACEmp.EmpID;
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select employee A/C name!',3);", true);
                            txtGLName.Text = txtACName.Text = "";
                            txtACName.Focus();
                            return;
                        }
                    }
                    else if (ddlParentGL.SelectedItem.Text == "Sundry Creditor")
                    {
                        objOGLA.ParentGL = Convert.ToInt32(ddlParentGL.SelectedValue);
                        var Acname = txtACName.Text.Split("-".ToArray()).First().Trim();
                        var LiveOVND = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == Acname && x.ParentID == ParentCustID);
                        var LocalOVND = ctx.OVNDs.FirstOrDefault(x => x.VendorCode == Acname && x.ParentID == ParentID);
                        if (LiveOVND != null && !ctx.OGLAs.Any(x => x.UserID == LiveOVND.VendorID && x.ParentID == ParentID && x.ParentUserID == ParentCustID && x.ParentGL == 21))
                        {
                            objOGLA.UserID = LiveOVND.VendorID;
                            objOGLA.ParentUserID = LiveOVND.ParentID;
                        }
                        else if (LocalOVND != null && !ctx.OGLAs.Any(x => x.UserID == LocalOVND.VendorID && x.ParentID == ParentID && x.ParentUserID == ParentID && x.ParentGL == 21))
                        {
                            objOGLA.UserID = LocalOVND.VendorID;
                            objOGLA.ParentUserID = LocalOVND.ParentID;
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select vendor A/C name!',3);", true);
                            txtGLName.Text = txtACName.Text = "";
                            txtACName.Focus();
                            return;
                        }
                    }
                    else if (ddlParentGL.SelectedValue != "0")
                        objOGLA.ParentGL = Convert.ToInt32(ddlParentGL.SelectedValue);
                    else
                        objOGLA.ParentGL = objOGLA.GLAccGroupID;

                    objOGLA.CreatedDate = DateTime.Now;
                    objOGLA.CreatedBy = UserID;
                    ctx.OGLAs.Add(objOGLA);
                }

                objOGLA.GLType = "A";
                objOGLA.GLAccName = txtGLName.Text;
                if (Int32.TryParse(txtCreditDays.Text, out IntNum))
                    objOGLA.CreditDays = IntNum;
                if (Decimal.TryParse(txtCrrditLimit.Text, out DecNum))
                    objOGLA.CreditLimit = DecNum;

                if (Int32.TryParse(txtGLAmount.Text, out IntNum))
                    objOGLA.GLAmount = IntNum;
                objOGLA.Notes = txtNotes.Text;
                objOGLA.Active = chkIsActive.Checked;
                objOGLA.UpdatedBy = UserID;
                objOGLA.UpdatedDate = DateTime.Now;
                objOGLA.Currency = Constant.Currency;

                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('Record submitted successfully : " + objOGLA.GLAccCode + "',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Page is invalid!',3);", true);
            }
        }
        catch (DbEntityValidationException ex)
        {
            var error = ex.EntityValidationErrors.First().ValidationErrors.First();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Finance.aspx");
    }

    #endregion

    #region Change Event

    protected void GLCode_OnTextChanged(object sender, EventArgs e)
    {
        if (!chkMode.Checked && !String.IsNullOrEmpty(txtGLAccCode.Text))
        {
            var word = txtGLAccCode.Text.Split("-".ToArray()).First().Trim();
            var objOGLA = ctx.OGLAs.FirstOrDefault(x => x.GLAccCode == word && x.ParentID == ParentID);

            if (objOGLA != null)
            {
                txtGLAccCode.Text = objOGLA.GLAccCode;
                txtGLName.Text = objOGLA.GLAccName;
                txtGLAmount.Text = objOGLA.GLAmount.ToString();
                txtCrrditLimit.Text = objOGLA.CreditLimit.ToString();
                txtCreditDays.Text = objOGLA.CreditDays.ToString();
                chkIsActive.Checked = objOGLA.Active;
                ddlGLGroupName.SelectedValue = objOGLA.GLAccGroupID.ToString();
                ddlGLGroupName_SelectedIndexChanged(ddlGLGroupName, EventArgs.Empty);
                if (objOGLA.ParentGL.HasValue)
                    ddlParentGL.SelectedValue = objOGLA.ParentGL.ToString();
                else
                    ddlParentGL.SelectedValue = null;

                if (ddlParentGL.SelectedItem.Text == "Sundry Debtor")
                {
                    lblACName.Visible = true;
                    var ACCust = ctx.OCRDs.FirstOrDefault(x => x.CustomerID == objOGLA.UserID && x.ParentID == ParentID);
                    if (ACCust != null)
                        txtACName.Text = (ACCust.CustomerCode + " - " + ACCust.CustomerName).ToString();
                }
                else if (ddlParentGL.SelectedItem.Text == "Employee Outstanding")
                {
                    lblACName.Visible = true;
                    var objOEMP = ctx.OEMPs.FirstOrDefault(x => x.EmpID == objOGLA.UserID && x.ParentID == ParentID);
                    if (objOEMP != null)
                        txtACName.Text = (objOEMP.EmpCode + " - " + objOEMP.Name).ToString();
                }
                else if (ddlParentGL.SelectedItem.Text == "Sundry Creditor")
                {
                    lblACName.Visible = true;
                    var objOVND = ctx.OVNDs.FirstOrDefault(x => x.VendorID == objOGLA.UserID && x.ParentID == ParentID);
                    if (objOVND != null)
                        txtACName.Text = (objOVND.VendorCode + " - " + objOVND.VendorName).ToString();
                }
                else
                {
                    txtACName.Text = "";
                    lblACName.Visible = false;
                }
                txtACName.Enabled = false;
                txtNotes.Text = objOGLA.Notes;
                ViewState["GLAccID"] = objOGLA.GLAccID;
                if (objOGLA.IsSystem)
                {
                    txtGLName.Enabled = false;
                }
                else
                {
                    txtGLName.Enabled = true;
                }
            }
            else
            {
                txtGLName.Text = "";
                txtGLName.Focus();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper GL Account!',3);", true);
            }
        }
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void ddlGLGroupName_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlParentGL.Items.Clear();
        lblACName.Visible = false;
        if (ddlGLGroupName.SelectedValue != "0")
        {
            int GID = Convert.ToInt32(ddlGLGroupName.SelectedValue);
            if (chkMode.Checked)
                ddlParentGL.DataSource = ctx.OGLAs.Where(x => x.Active == true && x.ParentID == ParentID && x.GLAccGroupID == GID && x.GLType == "T" && x.ParentGL.HasValue).ToList();
            else
                ddlParentGL.DataSource = ctx.OGLAs.Where(x => x.Active == true && x.ParentID == ParentID && x.GLAccGroupID == GID).ToList();
        }
        else
        {
            ddlParentGL.DataSource = null;
        }
        ddlParentGL.DataBind();
        ddlParentGL.Items.Insert(0, new ListItem("---Select---", "0"));
    }

    protected void ddlParentGL_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlParentGL.SelectedItem.Text == "Sundry Debtor" || ddlParentGL.SelectedItem.Text == "Sundry Creditor" || ddlParentGL.SelectedItem.Text == "Employee Outstanding")
        {
            acettxtGL.ContextKey = ddlParentGL.SelectedItem.Text;
            lblACName.Visible = true;
            txtACName.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        else
        {
            lblACName.Visible = false;
            txtACName.Style.Remove("background-color");
        }
        txtACName.Text = "";
    }

    #endregion

    protected void btnReport_Click(object sender, EventArgs e)
    {
        if (ctx.OJETs.Any(x => x.ParentID == ParentID))
        {
            var PLAccount = (from c in ctx.OJETs.Include("OGLA")
                             where c.ParentID == ParentID && c.OGLA.ParentID == ParentID && new int[] { 2, 4 }.Contains(c.OGLA.ParentGL.Value)
                             && c.CreatedDate <= DateTime.Now
                             select c).ToList();
            if (PLAccount != null && PLAccount.Count > 0)
            {
                OGLA objOGLA = ctx.OGLAs.FirstOrDefault(x => x.GLAccCode == "GL0502" && x.ParentID == ParentID);
                objOGLA.GLAmount = PLAccount.Sum(x => (x.Debit - x.Credit));
                ctx.SaveChanges();
            }
        }
        ChartofAccount.Attributes.Add("src", "../Reports/ViewReport.aspx?GLReport=1");
    }
}
