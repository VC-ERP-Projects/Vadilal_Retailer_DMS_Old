using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Transactions;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Master_CustomerMaster : System.Web.UI.Page
{
    #region Declaration

    protected int UserID, CustType;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    String TempPath = Path.GetTempPath();

    private List<CRD1> Branch
    {
        get { return this.ViewState["Branch"] as List<CRD1>; }
        set { this.ViewState["Branch"] = value; }
    }

    private List<CRD2> ContactPerson
    {
        get { return this.ViewState["ContactPerson"] as List<CRD2>; }
        set { this.ViewState["ContactPerson"] = value; }
    }

    #endregion

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
                        var unit = xml.Descendants("customer_master");
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
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('CustomerMaster', 'tabs-1');", true);

        if (chkMode.Checked)
        {
            acetxtName.Enabled = false;
            btnSubmit.Text = "Submit";
            txtCustName.Enabled = true;
            if (CustType == 1)
            {
                txtCustCode.Enabled = true;
                txtCustCode.Text = "";
            }
            else
            {
                txtCustCode.Text = "Auto Generated";
                txtCustCode.Enabled = false;
            }

            txtCustCode.Style.Remove("background-color");
        }
        else
        {
            acetxtName.Enabled = txtCustCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtCustCode.Text = "";
            txtCustCode.Style.Add("background-color", "rgb(250, 255, 189);");
            txtCustName.Enabled = false;
        }
        txtCustCode.Focus();

        int Type = Convert.ToInt32(Session["Type"]) + 1;
        edsddlGroup.Where = "it.Active==true and it.Type == " + Type;

        ddlGroup.DataBind();
        ddlGroup.Items.Insert(0, new ListItem("---Select---", "0"));
        ddlGroup.SelectedValue = "0";
        chkIsDiscount.Checked = chkActive.Checked = true;
        chkSMS.Checked = chkEMail.Checked = chkAllowNotify.Checked = false;
        txtCustName.Text = txtPhone.Text = txtFax.Text = txtEmail.Text = txtWebSite.Text = txtVATNumber.Text = txtGSTIN.Text = txtNotes.Text = txtBarcode.Text = txtCreditLimit.Text = "";
        ViewState["CUSTID"] = null;

        ClearBranchData();
        Branch = new List<CRD1>();
        gvBranch.DataSource = Branch;
        gvBranch.DataBind();

        ClearCPData();
        ContactPerson = new List<CRD2>();
        gvContactPerson.DataSource = ContactPerson;
        gvContactPerson.DataBind();

        alink.HRef = imgCustomer.ImageUrl = "~/Images/no.jpg";
    }

    private void ClearBranchData()
    {
        txtBranch.Text = txtAddress1.Text = txtAddress2.Text = txtContactPerson.Text = txtLocation.Text = txtZipCode.Text = txtPhoneNo.Text = txtBNotes.Text = string.Empty;
        ddlCity.SelectedValue = ddlState.SelectedValue = ddlCountry.SelectedValue = "0";
        ddlBranchType.SelectedValue = "B";
        ViewState["BranchID"] = null;
        txtBranch.Enabled = true;
        btnAddBranch.Text = "Add Address";
    }

    private void ClearCPData()
    {
        txtName.Text = txtBirthDay.Text = txtAnniversary.Text = txtSpecialDay.Text = txtMobile.Text = txtCEmail.Text = string.Empty;
        ViewState["ContactID"] = null;
        btnAddCP.Text = "Add Family Details";
    }

    #endregion

    #region Page Load

    protected void Page_Load(object sender, EventArgs e)
    {

        ValidateUser();
        acetxtName.ContextKey = (CustType + 1).ToString();
        if (!IsPostBack)
            ClearAllInputs();
        txtCustName.Focus();
    }

    #endregion

    #region Button Click

    protected void btnAddBranch_Click(object sender, EventArgs e)
    {
        int LineID;
        if (Branch == null)
            Branch = new List<CRD1>();
        CRD1 objCRD1 = null;
        if (ViewState["BranchID"] != null && Int32.TryParse(ViewState["BranchID"].ToString(), out LineID))
        {
            objCRD1 = Branch[LineID];
        }
        else
        {

            if (Branch.Any(x => x.Branch == txtBranch.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same Address Title is not allowed!',3);", true);
                return;
            }
            objCRD1 = new CRD1();
            Branch.Add(objCRD1);
        }
        objCRD1.Branch = txtBranch.Text;
        objCRD1.Type = ddlBranchType.SelectedValue;
        objCRD1.Address1 = txtAddress1.Text;
        objCRD1.Address2 = txtAddress2.Text;
        objCRD1.Location = txtLocation.Text;
        objCRD1.ContactPerson = txtContactPerson.Text;
        objCRD1.PhoneNumber = txtPhoneNo.Text;
        objCRD1.CityID = Convert.ToInt32(ddlCity.SelectedValue);
        objCRD1.ZipCode = txtZipCode.Text;
        objCRD1.StateID = Convert.ToInt32(ddlState.SelectedValue);
        objCRD1.CountryID = Convert.ToInt32(ddlCountry.SelectedValue);
        objCRD1.Notes = txtBNotes.Text;

        ClearBranchData();
        btnAddBranch.Text = "Add Address";

        gvBranch.DataSource = Branch;
        gvBranch.DataBind();
    }

    protected void btnAddCP_Click(object sender, EventArgs e)
    {
        if (Branch == null || Branch.Count == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Add at least one Address!',3); $.cookie('Customer',1);", true);
            return;
        }

        int LineID;
        if (ContactPerson == null)
            ContactPerson = new List<CRD2>();
        CRD2 objCRD2 = null;
        if (ViewState["ContactID"] != null && Int32.TryParse(ViewState["ContactID"].ToString(), out LineID))
        {
            objCRD2 = ContactPerson[LineID];
        }
        else
        {
            objCRD2 = new CRD2();
            ContactPerson.Add(objCRD2);
        }
        objCRD2.Name = txtName.Text;
        objCRD2.Gender = Convert.ToInt32(ddlGender.SelectedValue);
        objCRD2.RelationID = Convert.ToInt32(ddlRelation.SelectedValue);
        if (!String.IsNullOrEmpty(txtBirthDay.Text))
            objCRD2.BirthDay = Common.DateTimeConvert(txtBirthDay.Text);
        if (!String.IsNullOrEmpty(txtAnniversary.Text))
            objCRD2.Anniversary = Common.DateTimeConvert(txtAnniversary.Text);
        if (!String.IsNullOrEmpty(txtSpecialDay.Text))
            objCRD2.SpecialDay = Common.DateTimeConvert(txtSpecialDay.Text);
        objCRD2.Mobile = txtMobile.Text;
        objCRD2.Email = txtCEmail.Text;

        ClearCPData();
        btnAddCP.Text = "Add Family Details";
        gvContactPerson.DataSource = ContactPerson;
        gvContactPerson.DataBind();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            decimal CustID = 0;
            Decimal DecNum = 0;

            using (TransactionScope transaction = new TransactionScope())
            {
                OCRD objOCRD = null;
                OEMP objOEMP = null;

                if (ViewState["CUSTID"] != null && Decimal.TryParse(ViewState["CUSTID"].ToString(), out CustID))
                {
                    objOCRD = ctx.OCRDs.Include("CRD1").Include("CRD2").FirstOrDefault(x => x.CustomerID == CustID && x.ParentID == ParentID);
                }
                else
                {
                    if (ctx.OCRDs.Any(x => x.CustomerCode == txtCustCode.Text && x.ParentID == ParentID))
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Same customer code is not allowed!',3);", true);
                        return;
                    }
                    objOCRD = new OCRD();
                    objOCRD.Type = Convert.ToInt32(Session["Type"]) + 1;

                    var key = ctx.GetCustomerID("OCRD", "CustomerID", ParentID).FirstOrDefault().Value.ToString("D5");
                    var cid = objOCRD.Type.ToString() + key + ParentID.ToString().Substring(1, 10);
                    objOCRD.CustomerID = Convert.ToDecimal(cid);
                    objOCRD.ParentID = ParentID;
                    objOCRD.CustomerCode = CustType == 1 ? txtCustCode.Text : objOCRD.CustomerID.ToString();
                    objOCRD.CreatedDate = DateTime.Now;
                    objOCRD.CreatedBy = UserID;
                    objOCRD.Ratings = 0;
                    ctx.OCRDs.Add(objOCRD);

                    OGRP objOGRP = new OGRP();
                    objOGRP.EmpGroupID = ctx.GetKey("OGRP", "EmpGroupID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                    objOGRP.ParentID = objOCRD.CustomerID;
                    objOGRP.EmpGroupName = "Admin";
                    objOGRP.EmpGroupDesc = "Admin";
                    objOGRP.CreatedDate = DateTime.Now;
                    objOGRP.CreatedBy = UserID;
                    objOGRP.UpdatedDate = DateTime.Now;
                    objOGRP.UpdatedBy = UserID;
                    objOGRP.Active = true;
                    ctx.OGRPs.Add(objOGRP);

                    objOEMP = new OEMP();
                    objOEMP.EmpID = ctx.GetKey("OEMP", "EmpID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                    objOEMP.ParentID = objOCRD.CustomerID;
                    objOEMP.EmpCode = "E" + objOEMP.EmpID.ToString("D5");
                    objOEMP.UserName = objOCRD.CustomerCode;
                    objOEMP.Password = Common.EncryptNumber(objOEMP.UserName, objOEMP.UserName);
                    objOEMP.Name = txtCustName.Text;
                    objOEMP.EmpGroupID = objOGRP.EmpGroupID;
                    objOEMP.IsDiscount = false;
                    objOEMP.UserType = "d";
                    objOEMP.CreatedDate = DateTime.Now;
                    objOEMP.CreatedBy = UserID;
                    objOEMP.UpdatedDate = DateTime.Now;
                    objOEMP.UpdatedBy = UserID;

                    objOCRD.OEMPs.Add(objOEMP);

                    EMP1 objEMP1 = new EMP1();
                    objEMP1.Emp1ID = ctx.GetKey("EMP1", "Emp1ID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                    objEMP1.ParentID = objOCRD.CustomerID;
                    objEMP1.EmpID = objOEMP.EmpID;
                    objEMP1.Type = "0";
                    objOEMP.EMP1.Add(objEMP1);

                    List<OMNU> Menus = new List<OMNU>();
                    if (objOCRD.Type == 1)
                        Menus = ctx.OMNUs.Where(x => x.Active && x.Company).ToList();
                    else if (objOCRD.Type == 2)
                        Menus = ctx.OMNUs.Where(x => x.Active && x.CMS).ToList();
                    else if (objOCRD.Type == 3)
                        Menus = ctx.OMNUs.Where(x => x.Active && x.DMS).ToList();
                    else if (objOCRD.Type == 4)
                        Menus = ctx.OMNUs.Where(x => x.Active && x.SS).ToList();

                    int CountGRP1 = ctx.GetKey("GRP1", "GRPID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                    foreach (var item in Menus)
                    {
                        GRP1 objGRP1 = new GRP1();
                        objGRP1.GRPID = CountGRP1++;
                        objGRP1.ParentID = objOCRD.CustomerID;
                        objGRP1.EmpGroupID = objOGRP.EmpGroupID;
                        objGRP1.MenuID = item.MenuID;
                        objGRP1.AuthorizationType = "W";
                        objGRP1.Active = true;
                        objOGRP.GRP1.Add(objGRP1);
                    }
                }
                objOCRD.BulkSMS = chkSMS.Checked;
                objOCRD.IsDiscount = chkIsDiscount.Checked;
                objOCRD.BulkEmail = chkEMail.Checked;
                objOCRD.AllowNotify = chkAllowNotify.Checked;
                objOCRD.CustomerName = txtCustName.Text;
                objOCRD.Active = chkActive.Checked;
                objOCRD.Notes = txtNotes.Text;
                objOCRD.CustGroupID = Convert.ToInt32(ddlGroup.SelectedValue);
                objOCRD.Phone = txtPhone.Text;
                objOCRD.Fax = txtFax.Text;
                objOCRD.EMail1 = txtEmail.Text;
                objOCRD.Website = txtWebSite.Text;
                objOCRD.VATNumber = txtVATNumber.Text;
                objOCRD.GSTIN = txtGSTIN.Text;
                objOCRD.Notes = txtNotes.Text;
                objOCRD.FoodLicenceNo = "";
                objOCRD.BarCode = txtBarcode.Text;
                if (Decimal.TryParse(txtCreditLimit.Text, out DecNum))
                    objOCRD.CreditLimit = DecNum;
                objOCRD.UpdatedDate = DateTime.Now;
                objOCRD.UpdatedBy = UserID;
                //objOCRD.PlantID = ctx.OPLTs.FirstOrDefault(x => x.Active).PlantID;

                if (Session["CustPhotoFileName"] != null)
                {
                    string FileName = Session["CustPhotoFileName"].ToString();
                    string SavePath = Path.Combine(Server.MapPath(Constant.CustomerPhoto), FileName);
                    string SourcePath = TempPath + FileName;
                    File.Copy(SourcePath, SavePath);

                    if (!String.IsNullOrEmpty(objOCRD.Photo) && File.Exists(Constant.CustomerPhoto + objOCRD.Photo))
                        File.Delete(Constant.CustomerPhoto + objOCRD.Photo);

                    objOCRD.Photo = FileName;
                    Session["CustPhotoFileName"] = null;
                }
                ctx.SaveChanges();

                objOCRD.CRD1.ToList().ForEach(x => x.IsDeleted = true);

                int Count = ctx.GetCustomerIDKey("CRD1", "BranchID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                foreach (CRD1 item in Branch)
                {
                    CRD1 objCRD1 = new CRD1();
                    objCRD1.CustomerID = objOCRD.CustomerID;
                    objCRD1.BranchID = Count++;
                    objCRD1.Type = item.Type;
                    objCRD1.Branch = item.Branch;
                    objCRD1.Address1 = item.Address1;
                    objCRD1.Address2 = item.Address2;
                    objCRD1.Location = item.Location;
                    objCRD1.ContactPerson = item.ContactPerson;
                    objCRD1.PhoneNumber = item.PhoneNumber;
                    objCRD1.CityID = item.CityID;
                    objCRD1.ZipCode = item.ZipCode;
                    objCRD1.StateID = item.StateID;
                    objCRD1.CountryID = item.CountryID;
                    objCRD1.Notes = item.Notes;
                    objOCRD.CRD1.Add(objCRD1);
                }

                ctx.SaveChanges();

                if (objOCRD.CRD1.Count > 0 && objOEMP != null)
                {
                    objOEMP.BranchID = objOCRD.CRD1.FirstOrDefault().BranchID;
                }

                objOCRD.CRD2.ToList().ForEach(x => x.IsDeleted = true);

                Count = ctx.GetCustomerIDKey("CRD2", "ContactID", "", objOCRD.CustomerID, 0).FirstOrDefault().Value;
                foreach (CRD2 item in ContactPerson)
                {
                    CRD2 objCRD2 = new CRD2();
                    objCRD2.CustomerID = objOCRD.CustomerID;
                    objCRD2.ContactID = Count++;
                    objCRD2.Name = item.Name;
                    objCRD2.Gender = item.Gender;
                    objCRD2.RelationID = item.RelationID;
                    objCRD2.BirthDay = item.BirthDay;
                    objCRD2.Anniversary = item.Anniversary;
                    objCRD2.SpecialDay = item.SpecialDay;
                    objCRD2.Mobile = item.Mobile;
                    objCRD2.Email = item.Email;
                    objOCRD.CRD2.Add(objCRD2);
                }

                ctx.SaveChanges();
                transaction.Complete();
                transaction.Dispose();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully : " + objOCRD.CustomerCode + "',1);", true);
                ClearAllInputs();
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("BusinessPartner.aspx");
    }

    #endregion

    #region Change Event

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        ClearAllInputs();
    }

    protected void ddlCity_SelectedIndexChanged(object sender, EventArgs e)
    {
        int CityID = Convert.ToInt32(ddlCity.SelectedValue);
        if (CityID > 0)
        {
            var state = ctx.OCTies.Include("OCST").Include("OCST.OCRY").FirstOrDefault(x => x.CityID == CityID);

            if (state.OCST != null && !string.IsNullOrEmpty(state.OCST.StateID.ToString()))
            {
                int StateID = state.OCST.StateID;
                ddlState.SelectedValue = state.OCST.StateID.ToString();

                if (state.OCST.OCRY != null && !string.IsNullOrEmpty(state.OCST.OCRY.CountryID.ToString()))
                {
                    int CountryID = state.OCST.CountryID;
                    ddlCountry.SelectedValue = state.OCST.OCRY.CountryID.ToString();
                }
            }
            ddlCity.Focus();
        }
    }

    protected void txtCustCode_TextChanged(object sender, EventArgs e)
    {
        if (!chkMode.Checked && !String.IsNullOrEmpty(txtCustCode.Text))
        {
            var word = txtCustCode.Text.Split("-".ToArray()).First().Trim();
            var objCust = ctx.OCRDs.Include("CRD1").Include("CRD2").FirstOrDefault(x => x.CustomerCode.Contains(word) && x.ParentID == ParentID);

            if (objCust != null)
            {
                txtCustCode.Text = objCust.CustomerCode;
                txtCustName.Text = objCust.CustomerName;
                chkActive.Checked = objCust.Active;
                ddlGroup.SelectedValue = objCust.CustGroupID.ToString();
                txtPhone.Text = objCust.Phone;
                txtFax.Text = objCust.Fax;
                txtEmail.Text = objCust.EMail1;
                txtWebSite.Text = objCust.Website;
                txtVATNumber.Text = objCust.VATNumber;
                txtGSTIN.Text = objCust.GSTIN;
                txtNotes.Text = objCust.Notes;
                txtBarcode.Text = objCust.BarCode;
                txtCreditLimit.Text = objCust.CreditLimit.ToString();
                chkSMS.Checked = objCust.BulkSMS;
                chkEMail.Checked = objCust.BulkEmail;
                chkIsDiscount.Checked = true;
                chkAllowNotify.Checked = objCust.AllowNotify;
                if (!String.IsNullOrEmpty(objCust.Photo))
                    alink.HRef = imgCustomer.ImageUrl = Constant.CustomerPhoto + objCust.Photo;
                else
                    alink.HRef = imgCustomer.ImageUrl = "~/Images/no.jpg";

                ViewState["CUSTID"] = objCust.CustomerID;
                Branch = objCust.CRD1.Where(x => !x.IsDeleted).ToList();
                gvBranch.DataSource = Branch;
                gvBranch.DataBind();

                ContactPerson = objCust.CRD2.ToList();
                gvContactPerson.DataSource = ContactPerson;
                gvContactPerson.DataBind();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Select proper customer!',3);", true);
                ClearAllInputs();
            }

        }
        txtCustName.Focus();
    }

    #endregion

    #region Grid View Command

    protected void gvBranch_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditBranch")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ViewState["BranchID"] = LineID;
            txtBranch.Text = Branch[LineID].Branch;
            ddlBranchType.SelectedValue = Branch[LineID].Type;
            txtAddress1.Text = Branch[LineID].Address1;
            txtAddress2.Text = Branch[LineID].Address2;
            txtLocation.Text = Branch[LineID].Location;
            txtContactPerson.Text = Branch[LineID].ContactPerson;
            txtPhoneNo.Text = Branch[LineID].PhoneNumber;
            ddlCity.SelectedValue = Branch[LineID].CityID.ToString();
            txtZipCode.Text = Branch[LineID].ZipCode;
            ddlState.SelectedValue = Branch[LineID].StateID.ToString();
            ddlCountry.SelectedValue = Branch[LineID].CountryID.ToString();
            txtNotes.Text = Branch[LineID].Notes;
            txtBranch.Enabled = false;
            btnAddBranch.Text = "Update Address";
        }
        else if (e.CommandName == "DeleteBranch")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            Branch.RemoveAt(LineID);
            gvBranch.DataSource = Branch;
            gvBranch.DataBind();
        }
    }

    protected void gvContactPerson_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditContactPerson")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ViewState["ContactID"] = LineID;
            txtName.Text = ContactPerson[LineID].Name;
            ddlGender.Text = ContactPerson[LineID].Gender.ToString();
            ddlRelation.Text = ContactPerson[LineID].RelationID.ToString();
            if (ContactPerson[LineID].BirthDay.HasValue)
                txtBirthDay.Text = Common.DateTimeConvert(ContactPerson[LineID].BirthDay.Value);
            if (ContactPerson[LineID].Anniversary.HasValue)
                txtAnniversary.Text = Common.DateTimeConvert(ContactPerson[LineID].Anniversary.Value);
            if (ContactPerson[LineID].SpecialDay.HasValue)
                txtSpecialDay.Text = Common.DateTimeConvert(ContactPerson[LineID].SpecialDay.Value);
            txtMobile.Text = ContactPerson[LineID].Mobile;
            txtCEmail.Text = ContactPerson[LineID].Email;
            btnAddCP.Text = "Update Family Details";
        }
        else if (e.CommandName == "DeleteContactPerson")
        {
            int LineID = Convert.ToInt32(e.CommandArgument);
            ContactPerson.RemoveAt(LineID);
            gvContactPerson.DataSource = ContactPerson;
            gvContactPerson.DataBind();
        }
    }

    #endregion

    protected void afuCustomerPhoto_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuCustomerPhoto != null && afuCustomerPhoto.HasFile)
            {
                System.IO.FileInfo f = new FileInfo(afuCustomerPhoto.PostedFile.FileName);
                if (Int32.Parse(e.FileSize) > 1024000)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
                if ((f.Extension.ToLower() == ".jpg") || (f.Extension.ToLower() == ".png") || (f.Extension.ToLower() == ".gif") || (f.Extension.ToLower() == ".jpeg"))
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuCustomerPhoto.FileName);
                    Session["CustPhotoFileName"] = newFile;
                    afuCustomerPhoto.PostedFile.SaveAs(TempPath + newFile);
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('Only image is allowed!',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
}