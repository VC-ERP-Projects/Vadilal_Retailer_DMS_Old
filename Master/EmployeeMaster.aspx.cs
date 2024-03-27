using System;
using System.Data.Objects.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_EmployeeMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        if (chkMode.Checked)
        {
            acettxtEmployeeCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCode.Enabled = false;
            txtCode.Text = "Auto Generated";
            txtName.Focus();
            txtCode.Style.Remove("background-color");
        }
        else
        {
            acettxtEmployeeCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCode.Enabled = true;
            txtCode.Text = "";
            txtCode.Focus();
            txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        btnSubmit.Visible = true;
        chkIsAdmin.Checked = chkIsApprover.Checked = chkMobile.Checked = chkIsDiscount.Checked = false;
        txtMinDis.Text = txtMaxDis.Text = txtName.Text = txtWorkPhone.Text = txtExtension.Text = txtWorkEmail.Text = txtMobile.Text = txtHomePhone.Text = txtPersonnelEmail.Text = txtPinCode.Text =
        txtblock.Text = txtStreet.Text = txtLocation.Text = txtContactPerson.Text = txtCity.Text = txtState.Text = txtCountry.Text = txtMobileAddress.Text = txtPhoneAddress.Text = txtPanNumber.Text =
        txtSalary.Text = txtBankName.Text = txtBranchCode.Text = txtJoiningDate.Text = txtEducation.Text = txtLicenceNumber.Text = txtExpiryDate.Text = txtHeadQuarter.Text = txtCertificate.Text =
        txtDescription.Text = txtHomeRadius.Text = txtTermsConditions.Text = txtLoginName.Text = txtPassword.Text = txtSecAns.Text = txtManager.Text = txtFieldStaffManager.Text = txtCreatedBy.Text = txtCreatedTime.Text = txtUpdatedBy.Text = txtUpdatedTime.Text = txtTraceInterval.Text = "";
        chkIsDMS.Checked = chkIsActive.Checked = chkIsSAPActive.Checked = true;
        ddlTypeAddress.SelectedValue = ddlTYpeHR.SelectedValue = ddlBranch.SelectedValue = ddlGender.SelectedValue =
          ddlPaymentMode.SelectedValue = ddlGroup.SelectedValue = ddlSecQue.SelectedValue = "0";
        ViewState["EmpMasterID"] = null;

        ddlBranch.Enabled = txtName.Enabled = txtWorkPhone.Enabled = txtExtension.Enabled = txtWorkEmail.Enabled =
                          txtMobile.Enabled = txtHomePhone.Enabled = txtPersonnelEmail.Enabled = ddlGender.Enabled = chkIsActive.Enabled = txtHomeRadius.Enabled =
                          txtDescription.Enabled = txtblock.Enabled = txtStreet.Enabled = txtLocation.Enabled = txtPinCode.Enabled
                          = txtCity.Enabled = txtContactPerson.Enabled = txtMobileAddress.Enabled = txtPhoneAddress.Enabled =
                          ddlTYpeHR.Enabled = ddlGroup.Enabled = txtManager.Enabled = txtJoiningDate.Enabled = txtEducation.Enabled = txtHeadQuarter.Enabled = txtCertificate.Enabled =
                          txtLoginName.Enabled = ddlSecQue.Enabled = txtSecAns.Enabled = txtLicenceNumber.Enabled = txtExpiryDate.Enabled = txtTermsConditions.Enabled = true;
        txtPassword.Attributes.Add("Value", "");
        txtLoginName.Attributes.Add("Value", "");
        ddlUserType.SelectedValue = "";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('EmployeeMaster', 'tabs-1');", true);
        //$.cookie("EmployeeMaster", "tabs-1");
    }

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
                            var unit = xml.Descendants("employee_master");
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

    protected void btnSubmit_Click(object sender, System.EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                OEMP objOEMP;
                EMP1 objEMP1 = null;
                int EmpID;
                Decimal Temp;

                using (DDMSEntities ctx = new DDMSEntities())
                {
                    if (ViewState["EmpMasterID"] != null && Int32.TryParse(ViewState["EmpMasterID"].ToString(), out EmpID))
                    {
                        objOEMP = ctx.OEMPs.Include("EMP1").FirstOrDefault(x => x.EmpID == EmpID && x.ParentID == ParentID);
                        objEMP1 = objOEMP.EMP1.FirstOrDefault();
                        if (objEMP1 == null)
                        {
                            objEMP1 = new EMP1();
                            objEMP1.Emp1ID = ctx.GetKey("EMP1", "Emp1ID", "", ParentID, 0).FirstOrDefault().Value;
                            objEMP1.EmpID = objOEMP.EmpID;
                            objOEMP.EMP1.Add(objEMP1);
                        }
                    }
                    else
                    {
                        objOEMP = new OEMP();
                        if (ctx.OEMPs.Any(x => x.UserName == txtLoginName.Text) && txtLoginName.Text != "")
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('UserName already exists!',3);", true);
                            return;
                        }
                        var MainEmp = ctx.OEMPs.Where(x => x.ParentID == ParentID && x.Active).OrderBy(x => x.EmpID).FirstOrDefault();
                        if (MainEmp != null)
                        {
                            objOEMP.Password2 = MainEmp.Password2;
                            objOEMP.Password3 = MainEmp.Password3;
                            objOEMP.Password4 = MainEmp.Password4;
                        }
                        objOEMP.EmpID = ctx.GetKey("OEMP", "EmpID", "", ParentID, 0).FirstOrDefault().Value;
                        objOEMP.ParentID = ParentID;
                        objOEMP.EmpCode = "E" + objOEMP.EmpID.ToString("D5");
                        objOEMP.CreatedDate = DateTime.Now;
                        objOEMP.CreatedBy = UserID;
                        objOEMP.IsSAP = false;
                        objOEMP.IsDMS = true;
                        ctx.OEMPs.Add(objOEMP);

                        if (objEMP1 == null)
                        {
                            objEMP1 = new EMP1();
                            objEMP1.Emp1ID = ctx.GetKey("EMP1", "Emp1ID", "", ParentID, 0).FirstOrDefault().Value;
                            objEMP1.EmpID = objOEMP.EmpID;

                            objOEMP.EMP1.Add(objEMP1);
                        }
                    }
                    if (chkMobile.Checked)
                        objOEMP.MobileName = objOEMP.GCMID = objOEMP.GCM2ID = null;
                    objOEMP.Name = txtName.Text;
                    objOEMP.BranchID = Convert.ToInt32(ddlBranch.SelectedValue);
                    if (txtManager.Text != "")
                        objOEMP.ManagerID = Convert.ToInt32(txtManager.Text.Split("-".ToArray()).Last().Trim());
                    else
                        objOEMP.ManagerID = null;

                    if (txtFieldStaffManager.Text != "")
                        objOEMP.FieldStaffManagerID = Convert.ToInt32(txtFieldStaffManager.Text.Split("-".ToArray()).Last().Trim());
                    else
                        objOEMP.FieldStaffManagerID = null;

                    objOEMP.Mobile = txtMobile.Text;
                    objOEMP.HomePhone = txtMobile.Text;
                    objOEMP.WorkPhone = txtWorkPhone.Text;
                    objOEMP.Extension = txtExtension.Text;
                    objOEMP.PersonalEmail = txtPersonnelEmail.Text;
                    objOEMP.WorkEmail = txtWorkEmail.Text;
                    objOEMP.MobileID = txtTraceInterval.Text;
                    objOEMP.Active = chkIsActive.Checked;
                    objOEMP.IsApprover = chkIsApprover.Checked;
                    objOEMP.IsAdmin = chkIsAdmin.Checked;
                    objOEMP.Gender = ddlGender.SelectedValue;
                    objOEMP.Notes = txtDescription.Text;
                    objOEMP.HomeDistance = Decimal.TryParse(txtHomeRadius.Text, out Temp) ? Temp : 0;
                    objOEMP.TermsNConditions = txtTermsConditions.Text;

                    if (!String.IsNullOrEmpty(txtLoginName.Text) && !String.IsNullOrEmpty(txtPassword.Text))
                        objOEMP.Password = Common.EncryptNumber(txtLoginName.Text, txtPassword.Text);
                    else
                        objOEMP.Password = null;

                    objOEMP.PANNumber = txtPanNumber.Text;
                    objOEMP.Bank = txtBankName.Text;
                    objOEMP.BankBranch = txtBranchCode.Text;
                    objOEMP.Education = txtEducation.Text;
                    objOEMP.Certificate = txtCertificate.Text;
                    objOEMP.HeadQuarter = txtHeadQuarter.Text;
                    objOEMP.LicenceNumber = txtLicenceNumber.Text;
                    objOEMP.UserName = txtLoginName.Text;
                    objOEMP.IsDiscount = chkIsDiscount.Checked;
                    objOEMP.UpdatedDate = DateTime.Now;
                    objOEMP.UpdatedBy = UserID;
                    objOEMP.SecAns = txtSecAns.Text;

                    if (Decimal.TryParse(txtMinDis.Text, out Temp))
                        objOEMP.MinDiscount = Temp;
                    else
                        objOEMP.MinDiscount = null;

                    if (Decimal.TryParse(txtMaxDis.Text, out Temp))
                        objOEMP.MaxDiscount = Temp;
                    else
                        objOEMP.MaxDiscount = null;

                    if (ddlSecQue.SelectedValue != "0")
                        objOEMP.SecQueID = Convert.ToInt32(ddlSecQue.SelectedValue);
                    if (Decimal.TryParse(txtSalary.Text, out Temp))
                        objOEMP.Salary = Temp;
                    if (ddlPaymentMode.SelectedValue != "0")
                        objOEMP.PaymentMode = ddlPaymentMode.SelectedValue;
                    if (ddlTYpeHR.SelectedValue != "0")
                        objOEMP.Type = ddlTYpeHR.SelectedValue.ToString();
                    if (ddlGroup.SelectedValue != "0")
                        objOEMP.EmpGroupID = Convert.ToInt32(ddlGroup.SelectedValue);
                    if (txtJoiningDate.Text != "")
                        objOEMP.JoiningDate = Common.DateTimeConvert(txtJoiningDate.Text);

                    if (txtExpiryDate.Text != "")
                        objOEMP.LicenseExpDt = Common.DateTimeConvert(txtExpiryDate.Text);

                    objEMP1.Type = ddlTypeAddress.SelectedValue;
                    objEMP1.Block = txtblock.Text;
                    objEMP1.Street = txtStreet.Text;
                    objEMP1.Location = txtLocation.Text;

                    int CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
                    if (CityID != 0)
                        objEMP1.CityID = CityID;
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select City',3);", true);
                        return;
                    }

                    int StateID = Int32.TryParse(txtState.Text.Split("-".ToArray()).Last().Trim(), out StateID) ? StateID : 0;
                    if (StateID != 0)
                        objEMP1.StateID = StateID;
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select State',3);", true);
                        return;
                    }

                    int CountryID = Int32.TryParse(txtCountry.Text.Split("-".ToArray()).Last().Trim(), out CountryID) ? CountryID : 0;
                    if (CountryID != 0)
                        objEMP1.CountryID = CountryID;
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select Country',3);", true);
                        return;
                    }
                    objEMP1.ZipCode = txtPinCode.Text;
                    objEMP1.ContactPerson = txtContactPerson.Text;
                    objEMP1.Mobile = txtMobileAddress.Text;
                    objEMP1.Phone = txtPhoneAddress.Text;
                    objOEMP.UserType = ddlUserType.SelectedValue.ToString();
                    ctx.SaveChanges();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOEMP.EmpCode + "',1);", true);
                    ClearAllInputs();
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Master.aspx");
    }

    #endregion

    #region Change Event

    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && txtCode != null && !String.IsNullOrEmpty(txtCode.Text))
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var word = txtCode.Text.Split("-".ToArray()).First().Trim();
                    var objOEMP = ctx.OEMPs.Include("EMP1").FirstOrDefault(x => x.EmpCode == word && x.ParentID == ParentID);
                    if (objOEMP != null)
                    {
                        ViewState["EmpMasterID"] = objOEMP.EmpID;

                        txtCode.Text = objOEMP.EmpCode;
                        txtName.Text = objOEMP.Name;
                        if (objOEMP.BranchID.HasValue)
                            ddlBranch.SelectedValue = objOEMP.BranchID.ToString();
                        txtWorkPhone.Text = objOEMP.WorkPhone;
                        txtExtension.Text = objOEMP.Extension;
                        txtWorkEmail.Text = objOEMP.WorkEmail;
                        txtMobile.Text = objOEMP.Mobile;
                        txtHomePhone.Text = objOEMP.HomePhone;
                        txtPersonnelEmail.Text = objOEMP.PersonalEmail;
                        chkIsActive.Checked = objOEMP.Active;
                        chkIsSAPActive.Checked = objOEMP.SAPActive;
                        chkIsApprover.Checked = objOEMP.IsApprover;
                        chkIsAdmin.Checked = objOEMP.IsAdmin;
                        chkIsDMS.Checked = objOEMP.IsDMS;
                        ddlGender.SelectedValue = objOEMP.Gender;
                        txtPanNumber.Text = objOEMP.PANNumber;
                        txtTraceInterval.Text = objOEMP.MobileID;
                        txtSalary.Text = objOEMP.Salary.ToString();
                        txtBankName.Text = objOEMP.Bank;
                        txtBranchCode.Text = objOEMP.BankBranch;
                        txtDescription.Text = objOEMP.Notes;
                        txtTermsConditions.Text = objOEMP.TermsNConditions;
                        txtHomeRadius.Text = objOEMP.HomeDistance.ToString();

                        txtCreatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEMP.CreatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtCreatedTime.Text = objOEMP.CreatedDate.ToString("dd/MM/yyyy HH:mm");
                        txtUpdatedBy.Text = ctx.OEMPs.Where(x => x.EmpID == objOEMP.UpdatedBy && x.ParentID == ParentID).Select(x => x.EmpCode + " # " + x.Name).FirstOrDefault();
                        txtUpdatedTime.Text = objOEMP.UpdatedDate.ToString("dd/MM/yyyy HH:mm");
                        ddlUserType.SelectedValue = objOEMP.UserType;
                        if (objOEMP.ManagerID.HasValue)
                        {
                            Int32 Manager = 0;
                            if (objOEMP.ManagerID != null && Int32.TryParse(objOEMP.ManagerID.ToString(), out Manager) && Manager > 0)
                            {
                                txtManager.Text = ctx.OEMPs.Where(x => x.EmpID == Manager && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).FirstOrDefault();
                            }
                            else
                                txtManager.Text = "";
                        }
                        else
                            txtManager.Text = "";

                        if (objOEMP.FieldStaffManagerID.HasValue)
                        {
                            Int32 FieldStaffManagerID = 0;
                            if (objOEMP.FieldStaffManagerID != null && Int32.TryParse(objOEMP.FieldStaffManagerID.ToString(), out FieldStaffManagerID) && FieldStaffManagerID > 0)
                            {
                                txtFieldStaffManager.Text = ctx.OEMPs.Where(x => x.EmpID == FieldStaffManagerID && x.ParentID == ParentID).Select(x => x.EmpCode + " - " + x.Name + " - " + SqlFunctions.StringConvert((double)x.EmpID).Trim()).FirstOrDefault();
                            }
                            else
                                txtFieldStaffManager.Text = "";
                        }
                        else
                            txtFieldStaffManager.Text = "";

                        if (objOEMP.EmpGroupID.HasValue)
                            ddlGroup.SelectedValue = objOEMP.EmpGroupID.Value.ToString();
                        if (!String.IsNullOrEmpty(objOEMP.Type))
                            ddlTYpeHR.SelectedValue = objOEMP.Type;
                        if (objOEMP.JoiningDate.HasValue)
                            txtJoiningDate.Text = Common.DateTimeConvert(objOEMP.JoiningDate.Value);
                        txtEducation.Text = objOEMP.Education;
                        txtHeadQuarter.Text = objOEMP.HeadQuarter;
                        txtCertificate.Text = objOEMP.Certificate;
                        txtLicenceNumber.Text = objOEMP.LicenceNumber;
                        if (objOEMP.LicenseExpDt.HasValue)
                            txtExpiryDate.Text = Common.DateTimeConvert(objOEMP.LicenseExpDt.Value);
                        txtLoginName.Text = objOEMP.UserName;

                        if (objOEMP.MinDiscount.HasValue)
                            txtMinDis.Text = objOEMP.MinDiscount.Value.ToString("0.00");
                        if (objOEMP.MaxDiscount.HasValue)
                            txtMaxDis.Text = objOEMP.MaxDiscount.Value.ToString("0.00");

                        if (!String.IsNullOrEmpty(objOEMP.Password))
                        {
                            var pwd = Common.DecryptNumber(objOEMP.UserName, objOEMP.Password);
                            txtPassword.Text = pwd;
                            txtPassword.Attributes.Add("value", pwd);
                        }
                        if (objOEMP.SecQueID.HasValue && ddlSecQue.Items.FindByValue(objOEMP.SecQueID.ToString()) != null)
                            ddlSecQue.SelectedValue = objOEMP.SecQueID.ToString();
                        txtSecAns.Text = objOEMP.SecAns;
                        chkIsDiscount.Checked = objOEMP.IsDiscount;

                        txtCountry.Text = txtState.Text = txtCity.Text = txtPinCode.Text = txtblock.Text = txtStreet.Text = txtLocation.Text = txtContactPerson.Text = txtMobileAddress.Text = txtPhoneAddress.Text = "";
                        ddlTypeAddress.SelectedValue = "0";

                        var objEMP11 = objOEMP.EMP1.FirstOrDefault();
                        if (objEMP11 != null)
                        {
                            if (!String.IsNullOrEmpty(objEMP11.ZipCode))
                                txtPinCode.Text = objEMP11.ZipCode.ToString();
                            if (!String.IsNullOrEmpty(objEMP11.Type))
                                ddlTypeAddress.SelectedValue = objEMP11.Type.ToString();
                            if (!String.IsNullOrEmpty(objEMP11.Block))
                                txtblock.Text = objEMP11.Block;
                            if (!String.IsNullOrEmpty(objEMP11.Street))
                                txtStreet.Text = objEMP11.Street;
                            if (!String.IsNullOrEmpty(objEMP11.Location))
                                txtLocation.Text = objEMP11.Location;
                            if (objEMP11.CityID.HasValue)
                            {
                                var Data = ctx.OCTies.Where(x => x.CityID == objEMP11.CityID).Select(x => new { x.CityID, x.CityName }).FirstOrDefault();
                                txtCity.Text = Data.CityName + " - " + Data.CityID;
                            }
                            if (objEMP11.StateID.HasValue)
                            {
                                var Data = ctx.OCSTs.Where(x => x.StateID == objEMP11.StateID).Select(x => new { x.StateDesc, x.StateName, x.StateID }).FirstOrDefault();
                                txtState.Text = Data.StateDesc + " - " + Data.StateName + " - " + Data.StateID;
                            }
                            if (objEMP11.CountryID.HasValue)
                            {
                                var Data = ctx.OCRies.Where(x => x.CountryID == objEMP11.CountryID).Select(x => new { x.CountryID, x.CountryName }).FirstOrDefault();
                                txtCountry.Text = Data.CountryName + " - " + Data.CountryID;
                            }

                            if (!String.IsNullOrEmpty(objEMP11.ContactPerson))
                                txtContactPerson.Text = objEMP11.ContactPerson;
                            if (!String.IsNullOrEmpty(objEMP11.Mobile))
                                txtMobileAddress.Text = objEMP11.Mobile.ToString();
                            if (!String.IsNullOrEmpty(objEMP11.Phone))
                                txtPhoneAddress.Text = objEMP11.Phone.ToString();
                        }
                        if (objOEMP.IsSAP)
                        {
                            ddlBranch.Enabled = txtName.Enabled = txtExtension.Enabled = txtWorkEmail.Enabled =
                               txtMobile.Enabled = txtHomePhone.Enabled = txtPersonnelEmail.Enabled = ddlGender.Enabled =
                               txtDescription.Enabled = txtblock.Enabled = txtStreet.Enabled = txtLocation.Enabled = txtPinCode.Enabled
                               = txtCity.Enabled = txtContactPerson.Enabled = txtMobileAddress.Enabled = txtPhoneAddress.Enabled =
                               ddlTYpeHR.Enabled = ddlGroup.Enabled = txtManager.Enabled = txtJoiningDate.Enabled = txtEducation.Enabled = txtHeadQuarter.Enabled = txtCertificate.Enabled =
                               txtLoginName.Enabled = ddlSecQue.Enabled = txtSecAns.Enabled = txtLicenceNumber.Enabled = txtExpiryDate.Enabled = txtTermsConditions.Enabled = false;
                        }
                        else
                        {
                            ddlBranch.Enabled = txtName.Enabled = txtWorkPhone.Enabled = txtExtension.Enabled = txtWorkEmail.Enabled =
                              txtMobile.Enabled = txtHomePhone.Enabled = txtPersonnelEmail.Enabled = ddlGender.Enabled =
                              txtDescription.Enabled = txtblock.Enabled = txtStreet.Enabled = txtLocation.Enabled = txtPinCode.Enabled
                              = txtCity.Enabled = txtContactPerson.Enabled = txtMobileAddress.Enabled = txtPhoneAddress.Enabled =
                              ddlTYpeHR.Enabled = ddlGroup.Enabled = txtManager.Enabled = txtJoiningDate.Enabled = txtEducation.Enabled = txtHeadQuarter.Enabled = txtCertificate.Enabled =
                              txtLoginName.Enabled = ddlSecQue.Enabled = txtSecAns.Enabled = txtLicenceNumber.Enabled = txtExpiryDate.Enabled = txtTermsConditions.Enabled = true;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper employee!',3);", true);
                    }
                }
            }
            txtName.Focus();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCode.Focus();
    }

    protected void txtCity_TextChanged(object sender, EventArgs e)
    {
        try
        {
            int CityID = Int32.TryParse(txtCity.Text.Split("-".ToArray()).Last().Trim(), out CityID) ? CityID : 0;
            if (CityID > 0)
            {
                using (DDMSEntities ctx = new DDMSEntities())
                {
                    var state = ctx.OCTies.Include("OCST").Include("OCST.OCRY").FirstOrDefault(x => x.CityID == CityID);

                    if (state.OCST != null && !string.IsNullOrEmpty(state.OCST.StateID.ToString()))
                    {
                        var Data = ctx.OCSTs.Where(x => x.StateID == state.OCST.StateID).Select(x => new { x.StateDesc, x.StateName, x.StateID }).FirstOrDefault();
                        txtState.Text = Data.StateDesc + " - " + Data.StateName + " - " + Data.StateID;

                        if (state.OCST.OCRY != null && !string.IsNullOrEmpty(state.OCST.OCRY.CountryID.ToString()))
                        {
                            int CountryID = state.OCST.CountryID;
                            var Data2 = ctx.OCRies.Where(x => x.CountryID == state.OCST.OCRY.CountryID).Select(x => new { x.CountryID, x.CountryName }).FirstOrDefault();
                            txtCountry.Text = Data2.CountryName + " - " + Data2.CountryID;
                        }
                    }
                }
            }
            txtPinCode.Focus();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
        txtCity.Focus();
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion
}