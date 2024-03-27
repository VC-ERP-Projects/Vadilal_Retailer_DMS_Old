using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Asset_AssetRegister : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    String TempPath = Path.GetTempPath();

    private List<AST1> Attachments
    {
        get { return this.ViewState["Attachments"] as List<AST1>; }
        set { this.ViewState["Attachments"] = value; }
    }

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        ViewState["AssetID"] = null;
        if (chkMode.Checked)
        {
            acetxtAssetCode.Enabled = false;
            btnSubmit.Text = "Submit";
            txtAssetCode.Visible = true;
            txtCode.Visible = false;
            txtAssetCode.Focus();
            //  txtCode.Style.Remove("background-color");
        }
        else
        {
            acetxtAssetCode.Enabled = true;
            btnSubmit.Text = "Submit";
            txtAssetCode.Visible = false;
            txtCode.Visible = true;
            txtCode.Enabled = true;
            txtCode.Focus();
            txtCode.Style.Add("background-color", "rgb(250, 255, 189);");
        }
        chkActive.Checked = true;
        txtCode.Text = "";
        txtAssetCode.Text = txtAssetName.Text = txtModelNo.Text = txtSerialNo.Text = txtAdditional.Text = "";

        txtDescription.Text = txtVendor.Text = txtInvoiceNo.Text = txtInvoiceDate.Text = txtWarrantyDate.Text = txtLeadTime.Text = "";

        ddlAssignTo.SelectedValue = ddlAssetCondition.SelectedValue = ddlAssetGroup.SelectedValue = ddlAssetStatus.SelectedValue = ddlAssetType.SelectedValue = ddlAssetBrand.SelectedValue = ddlAssetSize.SelectedValue = "0";

        txtAttachment.Text = txtAtchReminderDate.Text = txtAtchNotes.Text = "";
        Attachments = new List<AST1>();
        gvAttach.DataSource = Attachments;
        gvAttach.DataBind();

        //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('AssetRegister', 'tabs-1');", true);
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
        acetxtAssetCode.ContextKey = ParentID.ToString();
        ScriptManager scriptMgr = ScriptManager.GetCurrent(this.Page);
        scriptMgr.RegisterPostBackControl(this.btnImageUpload);

        if (!IsPostBack)
        {
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('AssetRegister', 'tabs-1');", true);
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
                int IntNum = 0;
                OAST objOAST;
                if (ViewState["AssetID"] != null && Int32.TryParse(ViewState["AssetID"].ToString(), out IntNum))
                {
                    objOAST = ctx.OASTs.Include("AST1").FirstOrDefault(x => x.AssetID == IntNum);
                }
                else
                {
                    objOAST = new OAST();
                    objOAST.AssetID = ctx.GetKey("OAST", "AssetID", "", 0, 0).FirstOrDefault().Value;
                    //"AST" + objOAST.AssetID.ToString("D5");
                    objOAST.CreatedBy = UserID;
                    objOAST.CreatedDate = DateTime.Now;
                    ctx.OASTs.Add(objOAST);
                }

                if ((ctx.OASTs.Any(x => x.AssetCode == txtAssetCode.Text)) && IntNum == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('AssetCode already exist. Please enter other Assetcode.!',3);", true);
                    ViewState["AssetID"] = null;
                    return;
                }

                //if (ctx.OASTs.Any(x => x.AssetCode == txtAssetCode.Text && x.AssetID != IntNum && IntNum != 0))
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('AssetCode already exist. Please enter other Assetcode.!',3);", true);
                //}

                objOAST.AssetCode = txtAssetCode.Text;
                objOAST.AssetName = txtAssetName.Text;
                objOAST.Active = chkActive.Checked;
                objOAST.ModelNumber = txtModelNo.Text;
                objOAST.SerialNumber = txtSerialNo.Text;
                objOAST.AdditionalIdentifier = txtAdditional.Text;
                objOAST.VendorDetails = txtVendor.Text;
                objOAST.InvoiceNumber = txtInvoiceNo.Text;

                if (txtInvoiceDate.Text != "")
                {
                    objOAST.InvoiceDate = Convert.ToDateTime(txtInvoiceDate.Text);
                }
                if (txtWarrantyDate.Text != "")
                {
                    objOAST.WarrantyExpDate = Convert.ToDateTime(txtWarrantyDate.Text);
                }

                objOAST.AssetGroupID = Convert.ToInt32(ddlAssetGroup.SelectedValue);
                objOAST.AssetStatusID = Convert.ToInt32(ddlAssetStatus.SelectedValue);
                objOAST.AssetConditionID = Convert.ToInt32(ddlAssetCondition.SelectedValue);
                objOAST.AssetTypeID = Convert.ToInt32(ddlAssetType.SelectedValue);
                objOAST.AssignToCustomerID = Convert.ToDecimal(ddlAssignTo.SelectedValue);
                objOAST.AssetBrandID = Convert.ToInt32(ddlAssetBrand.SelectedValue);
                objOAST.AssetSizeID = Convert.ToInt32(ddlAssetSize.SelectedValue);
                objOAST.RegisterByCustomerID = ParentID;

                objOAST.Description = txtDescription.Text;
                objOAST.UpdatedBy = UserID;
                objOAST.UpdatedDate = DateTime.Now;

                foreach (AST1 item in Attachments)
                {
                    AST1 objAST1 = null;
                    if (item.AssetAttachID == 0)
                    {
                        objAST1 = new AST1();
                        objAST1.Active = true;
                        objAST1.CreatedDate = DateTime.Now;
                        objAST1.CreatedBy = UserID;
                        ctx.AST1.Add(objAST1);
                    }
                    else
                    {
                        objAST1 = ctx.AST1.FirstOrDefault(x => x.AssetAttachID == item.AssetAttachID);
                        if (item.EState == EState.Deleted)
                            objAST1.Active = false;
                    }

                    if (objAST1.FileName != item.FileName)
                    {
                        if (item.FileName != null && item.FileName != "")
                        {
                            string sourceFile = Path.Combine(TempPath, item.FileName);
                            if (File.Exists(sourceFile))
                            {
                                decimal assinTo = Convert.ToDecimal(ddlAssignTo.SelectedValue);
                                string myPath = Server.MapPath(Constant.AssetRegister) + "/" + assinTo;
                                if (!Directory.Exists(myPath))
                                {
                                    Directory.CreateDirectory(myPath);
                                }

                                string destFile = Path.Combine(myPath, item.FileName);
                                File.Copy(sourceFile, destFile);
                                if (objAST1.FileName != null)
                                {
                                    string ExistFile = Path.Combine(myPath, objAST1.FileName);
                                    if (File.Exists(sourceFile))
                                        File.Delete(sourceFile);
                                }
                                objAST1.FileName = item.FileName;
                            }
                        }
                    }

                    objAST1.AssetID = objOAST.AssetID;
                    objAST1.Subject = item.Subject;
                    objAST1.ReminderDate = item.ReminderDate;
                    objAST1.Notes = item.Notes;
                    objAST1.UpdatedDate = DateTime.Now;
                    objAST1.UpdatedBy = UserID;

                }
                ctx.SaveChanges();
                ViewState["AssetID"] = null;

                foreach (AST1 item in Attachments)
                {
                    if (item.FileName != null && item.FileName != "")
                    {
                        string sourceFile = Path.Combine(TempPath, item.FileName);
                        if (File.Exists(sourceFile))
                            File.Delete(sourceFile);
                    }
                }

                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Record submitted successfully',1); $.cookie('AssetRegister', 'tabs-1');", true);
            }
            else
            {
                ViewState["AssetID"] = null;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please enter proper data!',3);", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Asset.aspx");
    }

    protected void afuAssetReg_UploadedComplete(object sender, AsyncFileUploadEventArgs e)
    {
        try
        {
            if (afuAssetReg != null && afuAssetReg.HasFile)
            {
                if (Int32.Parse(e.FileSize) < 1024000)
                {
                    string newFile = Guid.NewGuid().ToString("N") + Path.GetExtension(afuAssetReg.FileName);
                    Session["FileName"] = newFile;
                    afuAssetReg.PostedFile.SaveAs(TempPath + newFile);
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "size", "ModelMsg('File size is greater than 1MB!',3);", true);
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void btnImageUpload_Click(object sender, EventArgs e)
    {
        try
        {
            if (String.IsNullOrEmpty(txtAttachment.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Subject is required.',3);", true);
                return;
            }
            int Rowindex;
            AST1 objOatt;
            if (ViewState["Rowindex"] != null && Int32.TryParse(ViewState["Rowindex"].ToString(), out Rowindex))
            {
                objOatt = Attachments[Rowindex];
            }
            else
            {
                //if (Session["FileName"] == null)
                //{
                //    ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File is not uploaded properly!',3);", true);
                //    return;
                //}
                objOatt = new AST1();
                if (Attachments == null)
                    Attachments = new List<AST1>();
                Attachments.Add(objOatt);
            }
            objOatt.Active = true;
            objOatt.Subject = txtAttachment.Text;
            if (Session["FileName"] != null)
            {
                objOatt.FileName = Session["FileName"].ToString();
                Session["FileName"] = null;
            }
            objOatt.Notes = txtAtchNotes.Text;
            if (!String.IsNullOrEmpty(txtAtchReminderDate.Text))
                objOatt.ReminderDate = Common.DateTimeConvert(txtAtchReminderDate.Text);

            txtAttachment.Text = "";
            txtAtchNotes.Text = "";
            txtAtchReminderDate.Text = "";
            btnImageUpload.Text = "Add Attachment";
            ViewState["Rowindex"] = null;
            gvAttach.DataSource = Attachments.Where(x => x.Active).ToList();
            gvAttach.DataBind();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Attachment uploaded Successfully!',1);", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void gvAttach_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int Rowindex = Convert.ToInt32(e.CommandArgument);
        var obj = Attachments[Rowindex];
        if (e.CommandName == "DeleteMode")
        {
            obj.Active = false;
            obj.EState = EState.Deleted;
            gvAttach.DataSource = Attachments.Where(x => x.Active).ToList();
            gvAttach.DataBind();

            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('Record deleted successfully!',1);", true);
        }
        else if (e.CommandName == "Download")
        {
            string strURL;
            var dir = Path.GetTempPath();
            string myPath = "";
            if (obj.OAST != null)
            {
                myPath = Server.MapPath(Constant.AssetRegister) + "/" + obj.OAST.AssignToCustomerID + "/";
            }

            if (File.Exists(myPath + obj.FileName))
            {
                strURL = myPath + obj.FileName;
            }
            else if (File.Exists(dir + obj.FileName))
            {
                strURL = dir + obj.FileName;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "", "ModelMsg('File does not exist!',3);", true);
                return;
            }
            WebClient req = new WebClient();
            HttpResponse response = HttpContext.Current.Response;
            response.Clear();
            response.ClearContent();
            response.ClearHeaders();
            response.Buffer = true;
            response.AddHeader("Content-Disposition", "attachment;filename=\"" + obj.FileName + "\"");
            byte[] data = req.DownloadData(strURL);
            response.BinaryWrite(data);
            response.End();
        }
        else if (e.CommandName == "EditMode")
        {
            ViewState["Rowindex"] = Rowindex;
            txtAttachment.Text = obj.Subject;
            txtAtchNotes.Text = obj.Notes;
            if (obj.ReminderDate.HasValue)
                txtAtchReminderDate.Text = Common.DateTimeConvert(obj.ReminderDate.Value);
            btnImageUpload.Text = "Update Attachment";
        }
    }

    #endregion


    #region Change Event
    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        try
        {
            if (!chkMode.Checked && txtCode != null && !String.IsNullOrEmpty(txtCode.Text))
            {
                var word = txtCode.Text.Split(" - ".ToArray()).First().Trim();
                var objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == word);
                if (objOAST != null)
                {
                    ViewState["AssetID"] = objOAST.AssetID;

                    txtAssetCode.Text = objOAST.AssetCode;
                    txtCode.Text = objOAST.AssetCode;
                    txtAssetName.Text = objOAST.AssetName;
                    chkActive.Checked = objOAST.Active;
                    txtDescription.Text = objOAST.Description;

                    txtModelNo.Text = objOAST.ModelNumber;
                    txtSerialNo.Text = objOAST.SerialNumber;
                    txtAdditional.Text = objOAST.AdditionalIdentifier;

                    txtVendor.Text = objOAST.VendorDetails;
                    txtInvoiceNo.Text = objOAST.InvoiceNumber;

                    if (objOAST.InvoiceDate != null)
                    {
                        txtInvoiceDate.Text = objOAST.InvoiceDate.Value.ToString("dd/MM/yyyy");
                    }
                    if (objOAST.WarrantyExpDate != null)
                    {
                        txtWarrantyDate.Text = objOAST.WarrantyExpDate.Value.ToString("dd/MM/yyyy");
                    }

                    txtLeadTime.Text = objOAST.LeadTime;
                    ddlAssetCondition.SelectedValue = objOAST.AssetConditionID.Value.ToString();
                    ddlAssetGroup.SelectedValue = objOAST.AssetGroupID.Value.ToString();
                    ddlAssetStatus.SelectedValue = objOAST.AssetStatusID.Value.ToString();
                    ddlAssetType.SelectedValue = objOAST.AssetTypeID.Value.ToString();
                    ddlAssignTo.SelectedValue = objOAST.AssignToCustomerID.Value.ToString();
                    ddlAssetBrand.SelectedValue = objOAST.AssetBrandID.Value.ToString();
                    ddlAssetSize.SelectedValue = objOAST.AssetSizeID.Value.ToString();

                    Attachments = ctx.AST1.Where(x => x.AssetID == objOAST.AssetID && x.Active).ToList();
                    gvAttach.DataSource = Attachments;
                    gvAttach.DataBind();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper asset!',3);", true);
                }
            }
            txtAssetName.Focus();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    protected void chkMode_Checked(object sender, EventArgs e)
    {
        try
        {
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('AssetRegister', 'tabs-1');", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "ModelMsg('" + Common.GetString(ex) + "',2);", true);
        }
    }

    #endregion

}