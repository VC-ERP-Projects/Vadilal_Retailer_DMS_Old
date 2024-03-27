using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

public partial class Asset_AssetTransfer : System.Web.UI.Page
{
    #region Declaration

    protected int UserID;
    protected decimal ParentID;
    protected String AuthType;
    DDMSEntities ctx;
    String TempPath = Path.GetTempPath();

    private List<ASTF1> Attachments
    {
        get { return this.ViewState["Attachments"] as List<ASTF1>; }
        set { this.ViewState["Attachments"] = value; }
    }

    #endregion

    #region Helper Method

    private void ClearAllInputs()
    {
        acetxtAssetCode.Enabled = true;
        btnSubmit.Text = "Submit";
        txtCode.Enabled = true;
        txtCode.Text = "";
        txtCode.Focus();
        txtCode.Style.Add("background-color", "rgb(250, 255, 189);");

        txtAssetName.Text = txtModelNo.Text = txtSerialNo.Text = txtBrand.Text = txtAdditional.Text = "";
        txtDescription.Text = txtSize.Text = "";

        ddlTransferTo.SelectedValue = ddlAssetCondition.SelectedValue = ddlTransferReason.SelectedValue = ddlAssetStatus.SelectedValue = "0";

        txtAttachment.Text = txtAtchNotes.Text = "";
        txtTransferDate.Text = DateTime.Now.ToString("dd/MM/yyyy");
        txtTransferTime.Text = DateTime.Now.ToString("hh:mm:ss");

        Attachments = new List<ASTF1>();
        gvAttach.DataSource = Attachments;
        gvAttach.DataBind();

        //ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('AssetTransfer', 'tabs-1');", true);
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

    protected void Page_Load(object sender, EventArgs e)
    {
        ValidateUser();
        acetxtAssetCode.ContextKey = ParentID.ToString();
        if (!IsPostBack)
        {
            ClearAllInputs();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "$.cookie('AssetTransfer', 'tabs-1');", true);
        }
    }
    protected void txtCode_TextChanged(object sender, EventArgs e)
    {
        if (!String.IsNullOrEmpty(txtCode.Text))
        {
            var word = txtCode.Text.Split(" - ".ToArray()).First().Trim();
            var objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == word);
            if (objOAST != null)
            {
                ViewState["AssetID"] = objOAST.AssetID;

                txtCode.Text = objOAST.AssetCode;
                txtAssetName.Text = objOAST.AssetName;

                txtModelNo.Text = objOAST.ModelNumber;
                txtSerialNo.Text = objOAST.SerialNumber;
                txtBrand.Text = objOAST.OASTB.AssetBrandName;
                txtAdditional.Text = objOAST.AdditionalIdentifier;
                txtSize.Text = objOAST.OASTZ.AssetSizeName;
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please search proper asset!',3);", true);
            }
        }
        txtAssetName.Focus();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (Page.IsValid)
            {
                var word = txtCode.Text.Split(" - ".ToArray()).First().Trim();
                var objOAST = ctx.OASTs.FirstOrDefault(x => x.AssetCode == word);
                if (objOAST == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Please select proper asset!',3);", true);
                }

                OASTF objOASTF = new OASTF();
                objOASTF.AssetID = objOAST.AssetID;
                objOASTF.AssetTransferID = ctx.GetKey("OASTF", "AssetTransferID", "", 0, 0).FirstOrDefault().Value;
                objOASTF.AssetTransferCode = "ASTF" + objOASTF.AssetTransferID.ToString("D5");
                objOASTF.CreatedBy = UserID;
                objOASTF.CreatedDate = DateTime.Now;

                if (txtShippingDate.Text != "")
                {
                    objOASTF.ShippingDate = Convert.ToDateTime(txtShippingDate.Text);
                }
                if (txtTransferDate.Text != "")
                {
                    objOASTF.TransferDate = Convert.ToDateTime(txtTransferDate.Text);
                }
                if (txtShippingTime.Text != "")
                {
                    objOASTF.ShippingTime = TimeSpan.Parse(txtShippingTime.Text).ToString();
                }
                if (txtTransferTime.Text != "")
                {
                    objOASTF.TransferTime = TimeSpan.Parse(txtTransferTime.Text).ToString();
                }

                objOASTF.TransferReasonID = Convert.ToInt32(ddlTransferReason.SelectedValue);
                objOASTF.AssetStatusID = Convert.ToInt32(ddlAssetStatus.SelectedValue);
                objOASTF.AssetConditionID = Convert.ToInt32(ddlAssetCondition.SelectedValue);
                objOASTF.TransferToCustomerID = Convert.ToDecimal(ddlTransferTo.SelectedValue);
                objOASTF.TransferByCustomerID = ParentID;
                objOASTF.ShippingCriteria = txtShippingDetail.Text;
                objOASTF.DocketNumber = txtDocketNo.Text;
                objOASTF.Remarks = txtDescription.Text;
                objOASTF.UpdatedBy = UserID;
                objOASTF.UpdatedDate = DateTime.Now;
                objOASTF.AssetTransferDate = DateTime.Now;
                objOASTF.IsConfirm = false;
                objOASTF.Active = true;

                ctx.OASTFs.Add(objOASTF);

                foreach (ASTF1 item in Attachments)
                {
                    ASTF1 objASTF1 = new ASTF1();
                    objASTF1.Active = true;
                    objASTF1.CreatedDate = DateTime.Now;
                    objASTF1.CreatedBy = UserID;
                    ctx.ASTF1.Add(objASTF1);

                    if (objASTF1.FileName != item.FileName)
                    {
                        if (item.FileName != null && item.FileName != "")
                        {
                            string sourceFile = Path.Combine(TempPath, item.FileName);
                            if (File.Exists(sourceFile))
                            {
                                string myPath = Server.MapPath(Constant.AssetTransfer) + "/" + objOASTF.TransferToCustomerID;
                                if (!Directory.Exists(myPath))
                                {
                                    Directory.CreateDirectory(myPath);
                                }

                                string destFile = Path.Combine(myPath, item.FileName);
                                File.Copy(sourceFile, destFile);
                                if (objASTF1.FileName != null)
                                {
                                    string ExistFile = Path.Combine(myPath, objASTF1.FileName);
                                    if (File.Exists(sourceFile))
                                        File.Delete(sourceFile);
                                }
                                objASTF1.FileName = item.FileName;
                            }
                        }
                    }

                    objASTF1.AssetTransferID = objOASTF.AssetTransferID;
                    objASTF1.Subject = item.Subject;
                    objASTF1.Type = item.Type;
                    objASTF1.Notes = item.Notes;
                    objASTF1.UpdatedDate = DateTime.Now;
                    objASTF1.UpdatedBy = UserID;
                }
                ctx.SaveChanges();

                foreach (ASTF1 item in Attachments)
                {
                    if (item.FileName != null && item.FileName != "")
                    {
                        string sourceFile = Path.Combine(TempPath, item.FileName);
                        if (File.Exists(sourceFile))
                            File.Delete(sourceFile);
                    }
                }

                ClearAllInputs();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ModelMsg", "ModelMsg('Asset transferred successfully',1); $.cookie('AssetTransfer', 'tabs-1');", true);
            }
            else
            {
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
    protected void afuAssetReg_UploadedComplete(object sender, AjaxControlToolkit.AsyncFileUploadEventArgs e)
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
            ASTF1 objOatt;
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
                objOatt = new ASTF1();
                if (Attachments == null)
                    Attachments = new List<ASTF1>();
                Attachments.Add(objOatt);
            }
            objOatt.Active = true;
            objOatt.Subject = txtAttachment.Text;
            objOatt.Type = txtType.Text;

            if (Session["FileName"] != null)
            {
                objOatt.FileName = Session["FileName"].ToString();
                Session["FileName"] = null;
            }
            objOatt.Notes = txtAtchNotes.Text;

            txtAttachment.Text = "";
            txtAtchNotes.Text = "";
            //txtType.Text = "Transfer";
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
            if (obj.OASTF != null)
            {
                myPath = Server.MapPath(Constant.AssetTransfer) + "/" + obj.OASTF.TransferToCustomerID + "/";
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
            btnImageUpload.Text = "Update Attachment";
        }
    }
}