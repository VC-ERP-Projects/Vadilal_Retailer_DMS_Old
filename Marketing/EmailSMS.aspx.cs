using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;


public partial class Marketing_EmailSMS : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;

    #endregion

    #region Helper Method

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
        else
        {
            Response.Redirect("~/Login.aspx");
        }

    }

    private void ClearAllInputs()
    {

        if (chkMode.Checked)
        {
            ACEtxtSubject.Enabled = false;
            btnSubmit.Text = "Submit";
            txtSubject.Style.Remove("background-color");
            txtTime.Text = DateTime.Now.ToString(Constant.TimeFormat);
        }
        else
        {
            ACEtxtSubject.Enabled = true;
            btnSubmit.Text = "Submit";
            txtSubject.Style.Add("background-color", "rgb(250, 255, 189);");
        }

        var Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
        gvEmployee.DataSource = Employee;
        gvEmployee.DataBind();

        ViewState["EmailID"] = null;
        chkIsActive.Checked = true;
        txtSubject.Text = txtDay.Text = txtQuery.Text = "";

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

    #region Change Event

    protected void txtSubject_TextChanged(object sender, EventArgs e)
    {
        if (!chkMode.Checked && txtSubject != null && !String.IsNullOrEmpty(txtSubject.Text))
        {
            var objEmail = ctx.EEMLs.Include("EML1").FirstOrDefault(x => x.Subject == txtSubject.Text && x.ParentID == ParentID);
            if (objEmail != null)
            {
                ClearAllInputs();
                txtSubject.Text = objEmail.Subject;
                txtDay.Text = objEmail.FreqDay.ToString();
                txtTime.Text = objEmail.FreqTime.ToString();
                txtQuery.Text = objEmail.SQLQuery;
                ViewState["EmailID"] = objEmail.EmailID;

                var Employee = ctx.OEMPs.Where(x => x.Active && x.ParentID == ParentID).ToList();
                gvEmployee.DataSource = Employee;
                gvEmployee.DataBind();

                for (int i = 0; i < Employee.Count; i++)
                {
                    Label lblEmpID = (Label)gvEmployee.Rows[i].FindControl("lblEmpID");
                    System.Web.UI.HtmlControls.HtmlInputCheckBox CkhBox = (System.Web.UI.HtmlControls.HtmlInputCheckBox)gvEmployee.Rows[i].FindControl("chkCheck");
                    int EMEmpID = Convert.ToInt32(lblEmpID.Text);
                    if (ctx.EML1.Any(x => x.EmpID == EMEmpID && x.EmailID == objEmail.EmailID && x.Active && x.ParentID == ParentID))
                        CkhBox.Checked = true;
                    else
                        CkhBox.Checked = false;
                }

            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper employee!',3);", true);
            }
        }

        txtSubject.Focus();
    }

    #endregion

    #region Button Click

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                if (!String.IsNullOrEmpty(txtQuery.Text))
                {
                    if (txtQuery.Text.ToLower().Contains("delete"))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Query should not have delete word.',3);", true);
                        return;
                    }
                    try
                    {
                        var re = ctx.Database.ExecuteSqlCommand(txtQuery.Text);
                    }
                    catch (Exception)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Query is not proper format.',3);", true);
                        return;
                    }
                }

                if (txtDay.Text == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter valid frequency Day!',3);", true);
                    return;
                }

                int EmailID;
                EEML objEEML;
                if (ViewState["EmailID"] != null && Int32.TryParse(ViewState["EmailID"].ToString(), out EmailID))
                {
                    objEEML = ctx.EEMLs.Include("EML1").FirstOrDefault(x => x.EmailID == EmailID && x.ParentID == ParentID);
                    if (objEEML.Subject != txtSubject.Text)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Subject cannot be changed!',3);", true);
                        return;
                    }
                }
                else
                {
                    if (ctx.EEMLs.Any(x => x.Subject == txtSubject.Text && x.ParentID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same subject name is not allowed!',3);", true);
                        return;
                    }

                    objEEML = new EEML();
                    objEEML.EmailID = ctx.GetKey("EEML", "EmailID", "", ParentID, 0).FirstOrDefault().Value;
                    objEEML.ParentID = ParentID;
                    objEEML.CreatedDate = DateTime.Now;
                    objEEML.CreatedBy = UserID;

                    ctx.EEMLs.Add(objEEML);
                }
                objEEML.Subject = txtSubject.Text;
                objEEML.FreqDay = Convert.ToInt32(txtDay.Text);
                if (!String.IsNullOrEmpty(txtTime.Text))
                    objEEML.FreqTime = TimeSpan.Parse(txtTime.Text);
                objEEML.SQLQuery = txtQuery.Text;
                objEEML.Active = chkIsActive.Checked;
                objEEML.UpdatedDate = DateTime.Now;
                objEEML.UpdatedBy = UserID;
                objEEML.NextDate = DateTime.Now.AddDays(objEEML.FreqDay);

                int Count = ctx.GetKey("EML1", "EML1ID", "", ParentID, null).FirstOrDefault().Value;
                var EML1s = objEEML.EML1.ToList();
                foreach (GridViewRow item in gvEmployee.Rows)
                {
                    EML1 objEML1 = null;
                    if (EML1s.Count > item.RowIndex)
                        objEML1 = EML1s[item.RowIndex];
                    if (objEML1 == null)
                    {
                        objEML1 = new EML1();
                        objEML1.EML1ID = Count++;
                        objEML1.ParentID = ParentID;
                        objEML1.EmailID = objEEML.EmailID;
                        objEEML.EML1.Add(objEML1);
                    }
                    Label lblEmpID = (Label)item.FindControl("lblEmpID");
                    System.Web.UI.HtmlControls.HtmlInputCheckBox CkhBox = (System.Web.UI.HtmlControls.HtmlInputCheckBox)item.FindControl("chkCheck");

                    objEML1.EmpID = Convert.ToInt32(lblEmpID.Text);
                    objEML1.Active = CkhBox.Checked;
                }
                ctx.SaveChanges();
                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objEEML.Subject + "',1);", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Employee',3);", true);
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

    #region CheckBox Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    #endregion

}